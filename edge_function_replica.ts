// supabase/functions/irrigation-recommendation/index.ts
//
// Deploy with:  supabase functions deploy irrigation-recommendation
//
// Handles two actions:
//   "recommend"      → fetch live weather + run algorithm → return irrigation advice
//   "update_balance" → user logged actual water given → persist carry balance
//
// Weather source: Open-Meteo (https://open-meteo.com) — free, no API key needed.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────
// Calibration constants  (mirror of recommendations.py)
// ─────────────────────────────────────────────────────────────
const IRRIGATION_THRESHOLD_ML = 150.0;
const FUTURE_DAYS = 1;
const ET_ML_PER_MM = 20.0;
const ASSESSMENT_CSV_WEIGHT = 0.80;
const ASSESSMENT_ET_WEIGHT = 0.20;
const NON_ASSESSMENT_ET_SHARE = 0.15;
const MAX_CARRY_CREDIT_ML = -300.0;
const MAX_CARRY_DEFICIT_ML = 2500.0;
const MAX_DAILY_RECOMMENDATION_ML = 1200.0;

// ─────────────────────────────────────────────────────────────
// Utility helpers
// ─────────────────────────────────────────────────────────────
function clamp(x: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, x));
}

function safeFloat(x: unknown, def = 0.0): number {
  const n = Number(x);
  return isNaN(n) || x === null || x === undefined ? def : n;
}

function mmToMl(mm: number): number {
  return mm * ET_ML_PER_MM;
}

// ─────────────────────────────────────────────────────────────
// FAO-56 potato crop-coefficient curve
// ─────────────────────────────────────────────────────────────
function potatoKc(day: number): [number, string] {
  if (day <= 25) return [0.5, "initial"];
  if (day <= 55) return [0.5 + ((day - 25) / 30) * 0.65, "development"];
  if (day <= 95) return [1.15, "mid"];
  if (day <= 125) return [1.15 + ((day - 95) / 30) * (0.75 - 1.15), "late"];
  return [0.75, "late"];
}

// ─────────────────────────────────────────────────────────────
// Weather adjustment percentages  (small additive corrections)
// ─────────────────────────────────────────────────────────────
function temperaturePct(t: number): number {
  if (t < 5) return -0.08;
  if (t < 10) return -0.05;
  if (t < 16) return -0.02;
  if (t <= 22) return 0.0;
  if (t <= 28) return 0.04;
  if (t <= 32) return 0.08;
  return 0.1;
}
function humidityPct(h: number): number {
  if (h >= 90) return -0.08;
  if (h >= 80) return -0.05;
  if (h >= 70) return -0.02;
  if (h >= 55) return 0.0;
  if (h >= 40) return 0.03;
  return 0.06;
}
function windPct(w: number): number {
  if (w < 1) return -0.04;
  if (w < 3) return 0.0;
  if (w < 5) return 0.03;
  if (w < 8) return 0.06;
  return 0.1;
}
function radiationPct(r: number): number {
  if (r < 5) return -0.08;
  if (r < 10) return -0.04;
  if (r < 18) return 0.0;
  if (r < 25) return 0.05;
  return 0.08;
}
function cloudPct(c: number): number {
  if (c >= 90) return -0.08;
  if (c >= 70) return -0.05;
  if (c >= 50) return -0.02;
  if (c >= 30) return 0.0;
  return 0.04;
}
function soilMoisturePct(s: number): number {
  if (s >= 90) return -0.22;
  if (s >= 80) return -0.15;
  if (s >= 70) return -0.08;
  if (s >= 60) return -0.04;
  if (s >= 40) return 0.0;
  if (s >= 25) return 0.06;
  return 0.1;
}
function vpdPct(v: number): number {
  if (v < 0.4) return -0.06;
  if (v < 0.8) return -0.03;
  if (v < 1.2) return 0.0;
  if (v < 1.6) return 0.04;
  if (v < 2.0) return 0.08;
  return 0.1;
}

interface WeatherData {
  temperature: number;
  humidity: number;
  wind_speed: number;
  solar_radiation: number;
  cloud_cover: number;
  soil_moisture: number;
  vpd: number;
  rain_mm: number;
  eto: number;
  etc: number; // 0 when not available — algorithm falls back to eto*kc
}

function weatherAdjustmentPct(w: WeatherData): number {
  const pct =
    temperaturePct(w.temperature) +
    humidityPct(w.humidity) +
    windPct(w.wind_speed) +
    radiationPct(w.solar_radiation) +
    cloudPct(w.cloud_cover) +
    soilMoisturePct(w.soil_moisture) +
    vpdPct(w.vpd);
  return clamp(pct, -0.2, 0.2);
}

// ─────────────────────────────────────────────────────────────
// Rain effectiveness
// ─────────────────────────────────────────────────────────────
function rainEfficiencyFactor(rainMm: number, soilMoisture: number): number {
  if (rainMm <= 0) return 0;
  const sf = rainMm < 1 ? 0.5 : rainMm < 5 ? 0.65 : rainMm < 15 ? 0.78 : 0.85;
  const mf =
    soilMoisture >= 85 ? 0.72
    : soilMoisture >= 70 ? 0.84
    : soilMoisture >= 50 ? 0.92
    : soilMoisture >= 30 ? 1.0
    : 1.05;
  return clamp(sf * mf, 0.35, 0.9);
}

function effectiveRainMl(rainMm: number, soilMoisture: number, demandMl: number): number {
  if (rainMm <= 0) return 0;
  const grossMl = mmToMl(clamp(rainMm, 0, 200));
  const ml = grossMl * rainEfficiencyFactor(rainMm, soilMoisture);
  const cap = Math.max(40, demandMl * 0.85 + 60);
  return Math.round(Math.min(ml, cap) * 100) / 100;
}

// ─────────────────────────────────────────────────────────────
// Core daily water-need estimator (direct port of estimate_daily_need)
// ─────────────────────────────────────────────────────────────
interface DailyNeedResult {
  need_ml: number;
  rain_credit_ml: number;
  basis: string;
  kc: number;
  kc_stage: string;
  et_source: string;
  et_reference_ml: number;
  weather_pct: number;
  target_before_rain_ml: number;
}

function estimateDailyNeed(
  day: number,
  baseMl: number,
  weather: WeatherData,
  isAssessmentDay: boolean,
): DailyNeedResult {
  const temp = clamp(safeFloat(weather.temperature), -5, 50);
  const humidity = clamp(safeFloat(weather.humidity), 0, 100);
  const windSpeed = clamp(safeFloat(weather.wind_speed), 0, 25);
  const solarRad = clamp(safeFloat(weather.solar_radiation), 0, 35);
  const cloudCover = clamp(safeFloat(weather.cloud_cover), 0, 100);
  const soilMoisture = clamp(safeFloat(weather.soil_moisture), 0, 100);
  const vpd = clamp(safeFloat(weather.vpd), 0, 5);
  const rainMm = clamp(safeFloat(weather.rain_mm), 0, 200);
  const eto = clamp(safeFloat(weather.eto), 0, 15);
  const etc = clamp(safeFloat(weather.etc), 0, 20);
  baseMl = Math.max(0, safeFloat(baseMl));

  const normW: WeatherData = {
    temperature: temp, humidity, wind_speed: windSpeed,
    solar_radiation: solarRad, cloud_cover: cloudCover,
    soil_moisture: soilMoisture, vpd, rain_mm: rainMm, eto, etc,
  };

  let kc = 0, kcStage = "", etSource = "none", etMm = 0;
  if (etc > 0) {
    etSource = "ETc"; etMm = etc;
  } else if (eto > 0) {
    [kc, kcStage] = potatoKc(day);
    etSource = "ET0*Kc"; etMm = eto * kc;
  }

  const etRefMl = etMm > 0 ? mmToMl(etMm) * 0.85 : 0;
  const weatherPct = weatherAdjustmentPct(normW);

  let targetMl: number, basis: string;
  if (isAssessmentDay) {
    const blended = etRefMl > 0
      ? ASSESSMENT_CSV_WEIGHT * baseMl + ASSESSMENT_ET_WEIGHT * etRefMl
      : baseMl;
    targetMl = clamp(
      blended * (1 + weatherPct),
      baseMl * 0.75,
      Math.max(150, baseMl * 1.25 + 60),
    );
    basis = `assessment: CSV + ${etSource} blend`;
  } else {
    const raw = etRefMl > 0
      ? etRefMl * NON_ASSESSMENT_ET_SHARE
      : baseMl * 0.2;
    targetMl = clamp(raw * (1 + weatherPct), 0, 250);
    basis = `maintenance: ${etSource}`;
  }

  const rainCreditMl = effectiveRainMl(rainMm, soilMoisture, targetMl);
  const needMl = clamp(Math.max(0, targetMl - rainCreditMl), 0, MAX_DAILY_RECOMMENDATION_ML);

  const r = (n: number, d = 2) => Math.round(n * 10 ** d) / 10 ** d;
  return {
    need_ml: r(needMl),
    rain_credit_ml: r(rainCreditMl),
    basis,
    kc: r(kc, 3),
    kc_stage: kcStage,
    et_source: etSource,
    et_reference_ml: r(etRefMl),
    weather_pct: r(weatherPct * 100, 1),
    target_before_rain_ml: r(targetMl),
  };
}

// ─────────────────────────────────────────────────────────────
// Open-Meteo weather fetcher
//
// Returns weather for day_offset 0 (today) or 1 (tomorrow).
// Mapping from Open-Meteo fields:
//   temperature    → (temperature_2m_max + temperature_2m_min) / 2   [daily]
//   rain_mm        → precipitation_sum                                [daily, mm]
//   solar_radiation→ shortwave_radiation_sum                          [daily, MJ/m²]
//   eto            → et0_fao_evapotranspiration                       [daily, mm]
//   wind_speed     → wind_speed_10m_max                               [daily, m/s]
//   humidity       → relative_humidity_2m noon value                  [hourly]
//   cloud_cover    → cloud_cover noon value                           [hourly]
//   soil_moisture  → soil_moisture_0_to_1cm noon * 100               [hourly, vol%]
//   vpd            → vapour_pressure_deficit noon                     [hourly, kPa]
//   etc            → 0 (not available; algorithm uses eto * kc)
// ─────────────────────────────────────────────────────────────
async function fetchWeather(lat: number, lon: number, dayOffset: 0 | 1): Promise<WeatherData> {
  const url = new URL("https://api.open-meteo.com/v1/forecast");
  url.searchParams.set("latitude", lat.toFixed(4));
  url.searchParams.set("longitude", lon.toFixed(4));
  url.searchParams.set(
    "daily",
    [
      "temperature_2m_max",
      "temperature_2m_min",
      "precipitation_sum",
      "shortwave_radiation_sum",
      "et0_fao_evapotranspiration",
      "wind_speed_10m_max",
    ].join(","),
  );
  url.searchParams.set(
    "hourly",
    [
      "relative_humidity_2m",
      "cloud_cover",
      "soil_moisture_0_to_1cm",
      "vapour_pressure_deficit",
    ].join(","),
  );
  url.searchParams.set("timezone", "auto");
  url.searchParams.set("forecast_days", "2");

  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`Open-Meteo error ${res.status}: ${await res.text()}`);
  const data = await res.json();

  const d = data.daily;
  const h = data.hourly;
  const i = dayOffset; // 0 = today, 1 = tomorrow in the daily arrays

  const tmax = safeFloat(d.temperature_2m_max[i]);
  const tmin = safeFloat(d.temperature_2m_min[i]);
  const temperature = (tmax + tmin) / 2;

  // Hourly noon index: day 0 = [12], day 1 = [36]
  const noonIdx = dayOffset === 0 ? 12 : 36;
  const humidity = safeFloat(h.relative_humidity_2m[noonIdx]);
  const cloud_cover = safeFloat(h.cloud_cover[noonIdx]);
  // Open-Meteo soil moisture is in m³/m³ volumetric; multiply × 100 for %
  const soil_moisture = safeFloat(h.soil_moisture_0_to_1cm[noonIdx]) * 100;
  const vpd = safeFloat(h.vapour_pressure_deficit[noonIdx]);

  return {
    temperature,
    humidity,
    wind_speed: safeFloat(d.wind_speed_10m_max[i]),
    solar_radiation: safeFloat(d.shortwave_radiation_sum[i]),
    cloud_cover,
    soil_moisture,
    vpd,
    rain_mm: safeFloat(d.precipitation_sum[i]),
    eto: safeFloat(d.et0_fao_evapotranspiration[i]),
    etc: 0, // not provided by Open-Meteo; algorithm uses ET0 * Kc
  };
}

// ─────────────────────────────────────────────────────────────
// Future surplus calculation (lookahead of FUTURE_DAYS=1)
// Only temperature, humidity, vpd, rain, and ET are used here
// (mirrors calculate_future_surplus in Python)
// ─────────────────────────────────────────────────────────────
async function calculateFutureSurplus(
  tomorrowDay: number,
  tomorrowBaseMl: number,
  lat: number,
  lon: number,
): Promise<number> {
  if (FUTURE_DAYS <= 0) return 0;
  try {
    const fw = await fetchWeather(lat, lon, 1);

    let futurEtMm = 0;
    if (fw.etc > 0) {
      futurEtMm = fw.etc;
    } else if (fw.eto > 0) {
      const [kc] = potatoKc(tomorrowDay);
      futurEtMm = fw.eto * kc;
    }

    let futureEtMl = mmToMl(futurEtMm) * 0.85;
    const futurePct = clamp(
      temperaturePct(fw.temperature) + humidityPct(fw.humidity) + vpdPct(fw.vpd),
      -0.2,
      0.2,
    );
    futureEtMl *= 1 + futurePct;

    const futureRainCreditMl = effectiveRainMl(fw.rain_mm, 50, futureEtMl);
    return Math.round((futureRainCreditMl - futureEtMl) * 100) / 100;
  } catch {
    return 0; // if tomorrow's forecast fails, skip lookahead
  }
}

// ─────────────────────────────────────────────────────────────
// Edge function entry-point
// ─────────────────────────────────────────────────────────────
Deno.serve(async (req: Request) => {
  // CORS pre-flight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  try {
    const body = await req.json();
    const { action, user_id, day, actual_watered_ml, is_today } = body;

    if (!user_id) return jsonError("user_id is required", 400);

    // ── ACTION: update_balance ─────────────────────────────────
    // Called after user logs how much water they actually gave.
    // Reads pending_net_need stored during the last recommend call.
    if (action === "update_balance") {
      const watered = Math.max(0, safeFloat(actual_watered_ml));

      const { data: state } = await supabase
        .from("user_irrigation_state")
        .select("pending_net_need_ml")
        .eq("user_id", user_id)
        .maybeSingle();

      const pendingNetNeed = safeFloat(state?.pending_net_need_ml ?? 0);
      let newCarry = clamp(pendingNetNeed - watered, MAX_CARRY_CREDIT_ML, MAX_CARRY_DEFICIT_ML);

      await supabase.from("user_irrigation_state").upsert({
        user_id,
        carry_balance_ml: newCarry,
        pending_net_need_ml: 0,
        updated_at: new Date().toISOString(),
      });

      return jsonOk({ carry_balance_ml: newCarry });
    }

    // ── ACTION: recommend ─────────────────────────────────────
    if (action === "recommend") {
      if (day == null) {
        return jsonError("day is required for recommend action", 400);
      }
      // fetch lon, lat from profile table
      const { data: profileRow, error: profileErr } = await supabase
            .from("profile")
            .select("latitude, longitude")
            .eq("id", user_id)
            .maybeSingle();

          if (profileErr) return jsonError(`DB error (profile): ${profileErr.message}`, 500);
          if (!profileRow?.latitude || !profileRow?.longitude) {
            return jsonError("Location not found. Please set your location in your profile.", 400);
          }
          const lat = profileRow.latitude;
          const lon = profileRow.longitude;

      const dayNum = Math.max(1, Math.min(109, parseInt(day)));

      // 1. Base recommendation from DB (agronomist CSV anchor)
      const { data: baseRow, error: baseErr } = await supabase
        .from("potato_base_recommendations")
        .select("water_ml")
        .eq("day", dayNum)
        .maybeSingle();

      if (baseErr) return jsonError(`DB error (base): ${baseErr.message}`, 500);
      const baseMl = safeFloat(baseRow?.water_ml ?? 0);
      const isAssessmentDay = baseMl > 0;

      // 2. Read carry balance
      const { data: stateRow } = await supabase
      .from("user_irrigation_state")
      .select("carry_balance_ml, pending_net_need_ml, last_processed_day")
      .eq("user_id", user_id)
      .maybeSingle();

    let carryBalance = safeFloat(stateRow?.carry_balance_ml ?? 0);
    const lastProcessedDay = stateRow?.last_processed_day ?? 0;
    const unresolvedPending = safeFloat(stateRow?.pending_net_need_ml ?? 0);

    if (lastProcessedDay > 0 && lastProcessedDay < dayNum && unresolvedPending !== 0) {
      carryBalance = clamp(unresolvedPending, MAX_CARRY_CREDIT_ML, MAX_CARRY_DEFICIT_ML);
      await supabase.from("user_irrigation_state").upsert({
        user_id,
        carry_balance_ml: carryBalance,
        pending_net_need_ml: 0,
        last_processed_day: lastProcessedDay,
        updated_at: new Date().toISOString(),
      });
      console.log(`Auto-carried ${unresolvedPending} ml from day ${lastProcessedDay} → new carry: ${carryBalance}`);
    }


      // 3. Fetch today's real weather from Open-Meteo
      const todayWeather = await fetchWeather(lat, lon, 0);

      // 4. Estimate today's water need
      const result = estimateDailyNeed(dayNum, baseMl, todayWeather, isAssessmentDay);

      // 5. Apply carry balance (accumulated deficit from previous days)
      const grossNeedMl = carryBalance + result.need_ml;
      const netNeedMl = clamp(grossNeedMl - result.rain_credit_ml, MAX_CARRY_CREDIT_ML, MAX_CARRY_DEFICIT_ML);

      // 6. Lookahead: fetch tomorrow's surplus/deficit
      let tomorrowBaseMl = 0;
      if (dayNum < 109) {
        const { data: nextRow } = await supabase
          .from("potato_base_recommendations")
          .select("water_ml")
          .eq("day", dayNum + 1)
          .maybeSingle();
        tomorrowBaseMl = safeFloat(nextRow?.water_ml ?? 0);
      }
      const futureSurplusMl = -1 * await calculateFutureSurplus(dayNum + 1, tomorrowBaseMl, lat, lon);

      // 7. Final recommendation
      let finalRecommendationMl = 0;
      if (FUTURE_DAYS === 0) {
        if (netNeedMl >= IRRIGATION_THRESHOLD_ML) finalRecommendationMl = netNeedMl;
      } else {
        if (futureSurplusMl <= 0) {
          if (netNeedMl >= IRRIGATION_THRESHOLD_ML) finalRecommendationMl = netNeedMl;
        } else {
          const adjustedNeed = netNeedMl - futureSurplusMl;
          finalRecommendationMl = adjustedNeed >= IRRIGATION_THRESHOLD_ML ? adjustedNeed : 0;
        }
      }
      finalRecommendationMl = Math.max(0, Math.round(finalRecommendationMl * 100) / 100);

      // Log the recommendation shown to the user
      await supabase.from("recommendation_history").insert({
        user_id: user_id,
        day: dayNum,
        recommendation_ml: finalRecommendationMl,
        is_prediction: is_today === false // Mark as prediction if navigating timeline
      });


      // Step 8 — only persist state for today's recommendation, not history views
      if (is_today === true) {
        await supabase.from("user_irrigation_state").upsert({
          user_id,
          carry_balance_ml: carryBalance,
          pending_net_need_ml: netNeedMl,
          last_processed_day: dayNum,
          updated_at: new Date().toISOString(),
        });
      }

      // 9. Determine crop stage label for UI
      const [kc, kcStage] = potatoKc(dayNum);
      const cropStageLabel = `${kcStage.charAt(0).toUpperCase() + kcStage.slice(1)} stage (Kc=${kc.toFixed(2)})`;

      return jsonOk({
        day: dayNum,
        // ── Primary recommendation fields (match your existing Map keys) ──
        crop_stage: cropStageLabel,
        water_requirement: finalRecommendationMl > 0
          ? `${finalRecommendationMl.toFixed(0)} ml recommended`
          : "No irrigation needed today",
        nutrient_application: isAssessmentDay
          ? "Assessment day — check nutrient schedule"
          : "Maintenance day",

        // ── Detailed breakdown for advanced UI ──
        details: {
          final_recommendation_ml: finalRecommendationMl,
          is_assessment_day: isAssessmentDay,
          base_csv_ml: baseMl,
          carry_balance_ml: carryBalance,
          gross_need_ml: Math.round(grossNeedMl * 100) / 100,
          net_need_ml: Math.round(netNeedMl * 100) / 100,
          future_surplus_ml: futureSurplusMl,
          threshold_ml: IRRIGATION_THRESHOLD_ML,
          ...result,
          weather: todayWeather,
        },
      });
    }

    return jsonError(`Unknown action: ${action}`, 400);
  } catch (e) {
    console.error(e);
    return jsonError(`Internal error: ${(e as Error).message}`, 500);
  }
});

function jsonOk(data: unknown): Response {
  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
  });
}
function jsonError(msg: string, status: number): Response {
  return new Response(JSON.stringify({ error: msg }), {
    status,
    headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
  });
}

