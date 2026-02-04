import 'package:flutter/material.dart';

class Step4Content extends StatelessWidget {
  final String locale; // Added locale parameter

  const Step4Content({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    // --- LOCALIZATION DATA ---
    final Map<String, Map<String, String>> _texts = {
      'en': {
        'title': "Sowing & Field Preparation",
        'subtitle':
            "Success starts with the right timing and a perfectly prepared seedbed.",
        'sec_window': "The Sowing Window",
        'win_long': "Long-Duration (135–140 Days)",
        'date_long': "10 Nov – 30 Nov",
        'desc_long':
            "BEST YIELD: Early sowing allows better tillering and heavier grains.",
        'win_short': "Short-Duration (120–125 Days)",
        'date_short': "Up to 15 Dec",
        'desc_short':
            "LATE SOWING: Yield potential drops quickly after mid-December.",
        'warning': "Sowing after 15 Dec leads to shriveled grains due to heat.",
        'sec_prep': "Field Preparation",
        'prep1_t': "Tilth Quality",
        'prep1_d':
            "One disking followed by harrowing. Aim for moderately fine soil (not powdery) and a well-levelled field.",
        'prep1_p1': "Correct seed depth placement",
        'prep1_p2': "Better germination & uniform growth",
        'prep2_t': "Zero Tillage",
        'prep2_d':
            "Sowing without ploughing, especially useful after rice harvest.",
        'prep2_p1': "Saves time, fuel, and costs",
        'prep2_p2': "Conserves soil moisture",
        'prep2_p3': "Allows early sowing for higher yield",
        'prep3_t': "Dibbling",
        'prep3_d':
            "Placing seeds manually in lines or holes. Can be done in prepared fields or zero tillage.",
        'prep3_p1': "Requires less seed quantity",
        'prep3_p2': "Ensures precise depth and spacing",
        'prep3_p3': "Better crop establishment",
        'sec_method': "Choosing a Sowing Method",
        'm1_t': "Broadcasting",
        'm1_d': "Seeds are scattered by hand. Simple but less uniform.",
        'm2_t': "Behind the plough",
        'm2_d': "Seeds are dropped in the furrow made by the plough.",
        'm3_t': "Drilling",
        'm3_d': "Using a seed drill for right depth and spacing.",
        'm4_t': "FIRB System",
        'm4_d': "Raised beds with furrows. Saves water and improves aeration.",
      },
      'hi': {
        'title': "बुआई और खेत की तैयारी",
        'subtitle':
            "सफलता सही समय और पूरी तरह से तैयार बीज-शय्या (Seedbed) से शुरू होती है।",
        'sec_window': "बुआई का समय",
        'win_long': "लंबी अवधि (135–140 दिन)",
        'date_long': "10 नवंबर – 30 नवंबर",
        'desc_long':
            "सर्वोत्तम उपज: अगेती बुआई से कल्ले बेहतर निकलते हैं और दाने भारी होते हैं।",
        'win_short': "कम अवधि (120–125 दिन)",
        'date_short': "15 दिसंबर तक",
        'desc_short':
            "पछेती बुआई: दिसंबर के मध्य के बाद उपज की क्षमता तेजी से गिरती है।",
        'warning':
            "15 दिसंबर के बाद बुआई करने से गर्मी के कारण दाने सिकुड़ जाते हैं।",
        'sec_prep': "खेत की तैयारी",
        'prep1_t': "मिट्टी की गुणवत्ता",
        'prep1_d':
            "एक बार डिस्क हैरो और फिर हैरो चलाएं। मिट्टी को मध्यम दानेदार रखें और खेत को समतल करें।",
        'prep1_p1': "बीज को सही गहराई पर रखना",
        'prep1_p2': "बेहतर अंकुरण और समान विकास",
        'prep2_t': "जीरो टिलेज",
        'prep2_d':
            "बिना जुताई के बुआई, विशेष रूप से धान की कटाई के बाद उपयोगी।",
        'prep2_p1': "समय, ईंधन और लागत की बचत",
        'prep2_p2': "मिट्टी की नमी को सुरक्षित रखता है",
        'prep2_p3': "अधिक उपज के लिए अगेती बुआई संभव",
        'prep3_t': "डिबलिंग (Dibbling)",
        'prep3_d':
            "हाथ से लाइनों या छेदों में बीज रखना। तैयार खेत या जीरो टिलेज में किया जा सकता है।",
        'prep3_p1': "कम बीज की आवश्यकता होती है",
        'prep3_p2': "सटीक गहराई और दूरी सुनिश्चित करता है",
        'prep3_p3': "फसल की बेहतर स्थापना",
        'sec_method': "बुआई की विधि का चयन",
        'm1_t': "छिटकवां विधि (Broadcasting)",
        'm1_d': "बीजों को हाथ से बिखेरा जाता है। सरल लेकिन कम समान।",
        'm2_t': "हल के पीछे",
        'm2_d': "हल द्वारा बनाई गई कूंड (furrow) में बीज गिराए जाते हैं।",
        'm3_t': "ड्रिलिंग (Drilling)",
        'm3_d': "सही गहराई और दूरी के लिए सीड ड्रिल का उपयोग।",
        'm4_t': "FIRB प्रणाली",
        'm4_d':
            "नालियों के साथ उठी हुई क्यारियाँ। पानी बचाता है और हवा का संचार बढ़ाता है।",
      },
      'ta': {
        'title': "விதைப்பு மற்றும் நிலம் தயாரித்தல்",
        'subtitle':
            "வெற்றி என்பது சரியான நேரம் மற்றும் சரியாகத் தயாரிக்கப்பட்ட நிலத்தில் தொடங்குகிறது.",
        'sec_window': "விதைப்பு காலம்",
        'win_long': "நீண்ட கால ரகங்கள் (135–140 நாட்கள்)",
        'date_long': "நவ 10 – நவ 30",
        'desc_long':
            "சிறந்த மகசூல்: முன்கூட்டியே விதைப்பது அதிக கிளைகள் மற்றும் கனமான தானியங்களைத் தரும்.",
        'win_short': "குறுகிய கால ரகங்கள் (120–125 நாட்கள்)",
        'date_short': "டிச 15 வரை",
        'desc_short':
            "தாமதமான விதைப்பு: டிசம்பர் பாதியில் விதைத்தால் மகசூல் வேகமாக குறையும்.",
        'warning':
            "டிசம்பர் 15-க்கு பிறகு விதைத்தால் வெப்பத்தினால் தானியங்கள் சுருங்கிவிடும்.",
        'sec_prep': "நிலம் தயாரித்தல்",
        'prep1_t': "மண் தரம்",
        'prep1_d':
            "மண்ணை ஒருமுறை தட்டையான கலப்பை கொண்டும், பின் பரம்பு அடித்தும் சமப்படுத்தவும்.",
        'prep1_p1': "விதை ஆழம் சரியாக இருத்தல்",
        'prep1_p2': "சீரான முளைப்பு மற்றும் வளர்ச்சி",
        'prep2_t': "பூஜ்ஜிய உழவு (Zero Tillage)",
        'prep2_d':
            "உழவு செய்யாமல் விதைப்பது, குறிப்பாக நெல் அறுவடைக்கு பின் சிறந்தது.",
        'prep2_p1': "நேரம், எரிபொருள் மற்றும் செலவு மிச்சம்",
        'prep2_p2': "மண் ஈரப்பதத்தை பாதுகாக்கும்",
        'prep2_p3': "அதிக மகசூலுக்கு முன்கூட்டியே விதைக்கலாம்",
        'prep3_t': "டிப்ளிங் (Dibbling)",
        'prep3_d':
            "கையால் வரிசையாக விதைகளை நடுதல். நிலம் தயாரித்த அல்லது உழவு செய்யாத நிலத்திலும் செய்யலாம்.",
        'prep3_p1': "குறைந்த அளவு விதைகளே போதும்",
        'prep3_p2': "துல்லியமான ஆழம் மற்றும் இடைவெளி",
        'prep3_p3': "பயிர்கள் நன்கு வளர உதவும்",
        'sec_method': "விதைப்பு முறையைத் தேர்ந்தெடுத்தல்",
        'm1_t': "தூவுதல் (Broadcasting)",
        'm1_d': "கைகளால் விதைகளைத் தூவுதல். எளிமையானது ஆனால் சீராக இருக்காது.",
        'm2_t': "கலப்பைக்கு பின் விதைத்தல்",
        'm2_d': "கலப்பையால் ஏற்படும் பள்ளங்களில் விதைகளை இடுதல்.",
        'm3_t': "துளையிடுதல் (Drilling)",
        'm3_d':
            "சரியான ஆழம் மற்றும் இடைவெளிக்கு விதைப்புக் கருவி பயன்படுத்துதல்.",
        'm4_t': "FIRB முறை",
        'm4_d': "பாத்திகள் அமைத்து விதைத்தல். நீர் சேமிக்கப்படும்.",
      },
      'te': {
        'title': "విత్తడం & పొలం తయారీ",
        'subtitle': "సరైన సమయం మరియు విత్తన మడి తయారీతోనే విజయం మొదలవుతుంది.",
        'sec_window': "విత్తే సమయం",
        'win_long': "దీర్ఘకాలిక రకాలు (135–140 రోజులు)",
        'date_long': "నవంబర్ 10 – నవంబర్ 30",
        'desc_long':
            "అధిక దిగుబడి: ముందుగా విత్తితే పిలకలు బాగా వచ్చి గింజ బరువు పెరుగుతుంది.",
        'win_short': "అల్పకాలిక రకాలు (120–125 రోజులు)",
        'date_short': "డిసెంబర్ 15 వరకు",
        'desc_short':
            "ఆలస్యంగా విత్తితే: డిసెంబర్ మధ్య తర్వాత దిగుబడి గణనీయంగా తగ్గుతుంది.",
        'warning':
            "డిసెంబర్ 15 తర్వాత విత్తితే వేడి వల్ల గింజలు ముడుచుకుపోతాయి.",
        'sec_prep': "పొలం తయారీ",
        'prep1_t': "దుక్కి నాణ్యత",
        'prep1_d':
            "ఒకసారి డిస్క్ హారో తర్వాత గుంటకతో దున్నాలి. మట్టి మెత్తగా మరియు చదునుగా ఉండాలి.",
        'prep1_p1': "విత్తనం సరైన లోతులో పడటం",
        'prep1_p2': "మంచి మొలకశాతం మరియు సమాన పెరుగుదల",
        'prep2_t': "జీరో టిల్లేజ్",
        'prep2_d':
            "దున్నకుండానే విత్తడం, ముఖ్యంగా వరి కోత తర్వాత ఇది చాలా ఉపయోగకరం.",
        'prep2_p1': "సమయం, ఇంధనం మరియు ఖర్చు ఆదా",
        'prep2_p2': "నేల తేమను కాపాడుతుంది",
        'prep2_p3': "ముందుగా విత్తడానికి అవకాశం",
        'prep3_t': "డిబ్లింగ్ (Dibbling)",
        'prep3_d':
            "చేతితో విత్తనాలను వరుసల్లో నాటడం. ఇది దుక్కి చేసిన లేదా చేయని పొలాల్లో చేయవచ్చు.",
        'prep3_p1': "తక్కువ విత్తన మోతాదు సరిపోతుంది",
        'prep3_p2': "ఖచ్చితమైన లోతు మరియు దూరం",
        'prep3_p3': "మొక్కలు దృఢంగా పెరుగుతాయి",
        'sec_method': "విత్తే పద్ధతిని ఎంచుకోవడం",
        'm1_t': "చల్లడం (Broadcasting)",
        'm1_d': "చేత్తో విత్తనాలను చల్లడం. సులభం కానీ అంతా సమానంగా ఉండదు.",
        'm2_t': "నాగలి వెనుక విత్తడం",
        'm2_d': "నాగలి చేసే చాలులో విత్తనాలను వేయడం.",
        'm3_t': "డ్రిల్లింగ్ (Drilling)",
        'm3_d': "సరైన లోతు మరియు దూరం కోసం విత్తన యంత్రాన్ని వాడటం.",
        'm4_t': "FIRB పద్ధతి",
        'm4_d': "బోదెలపై విత్తడం. నీటిని ఆదా చేస్తుంది.",
      },
      'kn': {
        'title': "ಬಿತ್ತನೆ ಮತ್ತು ಭೂಮಿ ಸಿದ್ಧತೆ",
        'subtitle':
            "ಬಿತ್ತನೆ ಮಾಡುವ ಸರಿಯಾದ ಸಮಯ ಮತ್ತು ಭೂಮಿಯ ಸಿದ್ಧತೆಯ ಮೇಲೆ ಯಶಸ್ಸು ನಿರ್ಧಾರವಾಗುತ್ತದೆ.",
        'sec_window': "ಬಿತ್ತನೆಯ ಅವಧಿ",
        'win_long': "ದೀರ್ಘಾವಧಿ ರಕಗಳು (135–140 ದಿನಗಳು)",
        'date_long': "ನವೆಂಬರ್ 10 – ನವೆಂಬರ್ 30",
        'desc_long':
            "ಉತ್ತಮ ಇಳುವರಿ: ಮುಂಗಡ ಬಿತ್ತನೆಯಿಂದ ಹೆಚ್ಚಿನ ಪಿಳ್ಳೆಗಳು ಬರುತ್ತವೆ ಮತ್ತು ಕಾಳು ತೂಕವಾಗಿರುತ್ತದೆ.",
        'win_short': "ಅಲ್ಪಾವಧಿ ರಕಗಳು (120–125 ದಿನಗಳು)",
        'date_short': "ಡಿಸೆಂಬರ್ 15 ರವರೆಗೆ",
        'desc_short':
            "ತಡವಾದ ಬಿತ್ತನೆ: ಡಿಸೆಂಬರ್ ಮಧ್ಯಭಾಗದ ನಂತರ ಇಳುವರಿ ವೇಗವಾಗಿ ಕುಂಠಿತವಾಗುತ್ತದೆ.",
        'warning':
            "ಡಿಸೆಂಬರ್ 15 ರ ನಂತರ ಬಿತ್ತನೆ ಮಾಡಿದರೆ ಶಾಖದಿಂದಾಗಿ ಕಾಳುಗಳು ಸುಕ್ಕುಗಟ್ಟುತ್ತವೆ.",
        'sec_prep': "ಭೂಮಿ ಸಿದ್ಧತೆ",
        'prep1_t': "ಮಣ್ಣಿನ ಗುಣಮಟ್ಟ",
        'prep1_d': "ಮಣ್ಣನ್ನು ಚೆನ್ನಾಗಿ ಹದಗೊಳಿಸಿ ಸಮತಟ್ಟಾಗಿ ಇರಿಸಿ.",
        'prep1_p1': "ಬೀಜವನ್ನು ಸರಿಯಾದ ಆಳದಲ್ಲಿ ಬಿತ್ತುವುದು",
        'prep1_p2': "ಉತ್ತಮ ಮೊಳಕೆಯೊಡೆಯುವಿಕೆ",
        'prep2_t': "ಶೂನ್ಯ ಉಳುಮೆ (Zero Tillage)",
        'prep2_d':
            "ಉಳುಮೆ ಮಾಡದೆಯೇ ಬಿತ್ತನೆ ಮಾಡುವುದು, ಭತ್ತದ ಕೊಯ್ಲಿನ ನಂತರ ಇದು ಉಪಯುಕ್ತ.",
        'prep2_p1': "ಸಮಯ, ಇಂಧನ ಮತ್ತು ಹಣ ಉಳಿತಾಯ",
        'prep2_p2': "ಮಣ್ಣಿನ ತೇವಾಂಶ ಸಂರಕ್ಷಣೆ",
        'prep2_p3': "ಬೇಗನೆ ಬಿತ್ತನೆ ಮಾಡಲು ಸಹಕಾರಿ",
        'prep3_t': "ಡಿಬ್ಲಿಂಗ್ (Dibbling)",
        'prep3_d': "ಕೈಯಿಂದ ಸಾಲುಗಳಲ್ಲಿ ಬೀಜಗಳನ್ನು ಊರುವುದು.",
        'prep3_p1': "ಕಡಿಮೆ ಬೀಜದ ಅವಶ್ಯಕತೆ",
        'prep3_p2': "ನಿಖರವಾದ ಆಳ ಮತ್ತು ಅಂತರ",
        'prep3_p3': "ಸಸಿಗಳ ಉತ್ತಮ ಬೆಳವಣಿಗೆ",
        'sec_method': "ಬಿತ್ತನೆ ವಿಧಾನದ ಆಯ್ಕೆ",
        'm1_t': "ಚದರಿಸುವಿಕೆ (Broadcasting)",
        'm1_d': "ಕೈಯಿಂದ ಬೀಜಗಳನ್ನು ಹರಡುವುದು.",
        'm2_t': "ನೇಗಿಲಿನ ಹಿಂದೆ ಬಿತ್ತುವುದು",
        'm2_d': "ನೇಗಿಲು ಮಾಡಿದ ಸಾಲುಗಳಲ್ಲಿ ಬೀಜ ಹಾಕುವುದು.",
        'm3_t': "ಡ್ರಿಲ್ಲಿಂಗ್ (Drilling)",
        'm3_d': "ಸರಿಯಾದ ಅಂತರಕ್ಕಾಗಿ ಬಿತ್ತನೆ ಯಂತ್ರ ಬಳಸುವುದು.",
        'm4_t': "FIRB ವಿಧಾನ",
        'm4_d': "ಏರುಮಡಿಗಳಲ್ಲಿ ಬಿತ್ತನೆ. ನೀರಿನ ಉಳಿತಾಯವಾಗುತ್ತದೆ.",
      },
      'mr': {
        'title': "पेरणी आणि शेतीची तयारी",
        'subtitle':
            "यश हे पेरणीच्या अचूक वेळेवर आणि योग्य मशागतीवर अवलंबून असते.",
        'sec_window': "पेरणीचा कालावधी",
        'win_long': "दीर्घ कालावधी (135–140 दिवस)",
        'date_long': "10 नोव्हेंबर – 30 नोव्हेंबर",
        'desc_long':
            "सर्वोत्कृष्ट उत्पन्न: लवकर पेरणीमुळे फुटवे चांगले येतात आणि दाणे भरतात.",
        'win_short': "कमी कालावधी (120–125 दिवस)",
        'date_short': "15 डिसेंबर पर्यंत",
        'desc_short':
            "उशिरा पेरणी: डिसेंबरच्या मध्यांतरानंतर उत्पादनात वेगाने घट होते.",
        'warning':
            "15 डिसेंबरनंतर पेरणी केल्यास उष्णतेमुळे दाणे बारीक आणि सुरकुतलेले होतात.",
        'sec_prep': "शेतीची तयारी",
        'prep1_t': "जमिनीची मशागत",
        'prep1_d': "जमीन नांगरून व कुळवून भुसभुशीत आणि समतल करा.",
        'prep1_p1': "बीज योग्य खोलीवर पडते",
        'prep1_p2': "चांगली उगवण आणि समान वाढ",
        'prep2_t': "झिरो टिलेज (Zero Tillage)",
        'prep2_d': "विना नांगरणी पेरणी, भात कापणीनंतर विशेषतः उपयुक्त.",
        'prep2_p1': "वेळ, इंधन आणि खर्चाची बचत",
        'prep2_p2': "जमिनीतील ओलावा टिकवून ठेवते",
        'prep2_p3': "लवकर पेरणीसाठी सोयीचे",
        'prep3_t': "टोचण पद्धत (Dibbling)",
        'prep3_d': "हाताने ठराविक अंतरावर बी टोचणे.",
        'prep3_p1': "कमी बियाणे लागते",
        'prep3_p2': "अचूक खोली आणि अंतर मिळते",
        'prep3_p3': "पिकाची चांगली मांडणी होते",
        'sec_method': "पेरणीची पद्धत निवडणे",
        'm1_t': "फेकून पेरणी (Broadcasting)",
        'm1_d': "हाताने बी विस्कटणे. सोपे पण असमान.",
        'm2_t': "तिफणीच्या मागे पेरणी",
        'm2_d': "नांगराच्या तासात बी सोडणे.",
        'm3_t': "पेरणी यंत्र (Drilling)",
        'm3_d': "योग्य खोली आणि अंतरासाठी यंत्राचा वापर.",
        'm4_t': "FIRB पद्धत",
        'm4_d': "गादी वाफ्यावर पेरणी. पाण्याची बचत होते.",
      },
      'pa': {
        'title': "ਬਿਜਾਈ ਅਤੇ ਖੇਤ ਦੀ ਤਿਆਰੀ",
        'subtitle':
            "ਕਾਮਯਾਬੀ ਸਹੀ ਸਮੇਂ ਅਤੇ ਖੇਤ ਦੀ ਚੰਗੀ ਤਿਆਰੀ ਨਾਲ ਸ਼ੁਰੂ ਹੁੰਦੀ ਹੈ।",
        'sec_window': "ਬਿਜਾਈ ਦਾ ਸਮਾਂ",
        'win_long': "ਲੰਬੇ ਸਮੇਂ ਵਾਲੀਆਂ (135–140 ਦਿਨ)",
        'date_long': "10 ਨਵੰਬਰ – 30 ਨਵੰਬਰ",
        'desc_long':
            "ਵਧੀਆ ਝਾੜ: ਅਗੇਤੀ ਬਿਜਾਈ ਨਾਲ ਫੁਟਾਰਾ ਚੰਗਾ ਹੁੰਦਾ ਹੈ ਅਤੇ ਦਾਣਾ ਭਾਰੀ ਬਣਦਾ ਹੈ।",
        'win_short': "ਘੱਟ ਸਮੇਂ ਵਾਲੀਆਂ (120–125 ਦਿਨ)",
        'date_short': "15 ਦਸੰਬਰ ਤੱਕ",
        'desc_short':
            "ਪਛੇਤੀ ਬਿਜਾਈ: ਦਸੰਬਰ ਦੇ ਅੱਧ ਤੋਂ ਬਾਅਦ ਝਾੜ ਦੀ ਸਮਰੱਥਾ ਤੇਜ਼ੀ ਨਾਲ ਘਟਦੀ ਹੈ।",
        'warning':
            "15 ਦਸੰਬਰ ਤੋਂ ਬਾਅਦ ਬਿਜਾਈ ਕਰਨ ਨਾਲ ਗਰਮੀ ਕਰਕੇ ਦਾਣਾ ਪਤਲਾ ਰਹਿ ਜਾਂਦਾ ਹੈ।",
        'sec_prep': "ਖੇਤ ਦੀ ਤਿਆਰੀ",
        'prep1_t': "ਮਿੱਟੀ ਦੀ ਗੁਣਵੱਤਾ",
        'prep1_d': "ਇੱਕ ਵਾਰ ਡਿਸਕ ਹੈਰੋ ਤੇ ਫਿਰ ਹੈਰੋ ਚਲਾ ਕੇ ਖੇਤ ਨੂੰ ਪੱਧਰਾ ਕਰੋ।",
        'prep1_p1': "ਬੀਜ ਸਹੀ ਡੂੰਘਾਈ 'ਤੇ ਪੈਂਦਾ ਹੈ",
        'prep1_p2': "ਵਧੀਆ ਜੰਮ ਅਤੇ ਇਕਸਾਰ ਵਾਧਾ",
        'prep2_t': "ਜ਼ੀਰੋ ਟਿਲੇਜ (Zero Tillage)",
        'prep2_d': "ਬਿਨਾਂ ਵਾਹੇ ਬਿਜਾਈ, ਝੋਨੇ ਦੀ ਕਟਾਈ ਤੋਂ ਬਾਅਦ ਬਹੁਤ ਲਾਹੇਵੰਦ।",
        'prep2_p1': "ਸਮਾਂ, ਡੀਜ਼ਲ ਅਤੇ ਖ਼ਰਚੇ ਦੀ ਬੱਚਤ",
        'prep2_p2': "ਮਿੱਟੀ ਦੀ ਨਮੀ ਬਚਾਉਂਦਾ ਹੈ",
        'prep2_p3': "ਅਗੇਤੀ ਬਿਜਾਈ ਵਿੱਚ ਮਦਦਗਾਰ",
        'prep3_t': "ਡਿਬਲਿੰਗ (Dibbling)",
        'prep3_d': "ਹੱਥ ਨਾਲ ਲਾਈਨਾਂ ਵਿੱਚ ਬੀਜ ਲਾਉਣਾ।",
        'prep3_p1': "ਬੀਜ ਘੱਟ ਲੱਗਦਾ ਹੈ",
        'prep3_p2': "ਸਹੀ ਡੂੰਘਾਈ ਅਤੇ ਫ਼ਾਸਲਾ",
        'prep3_p3': "ਫ਼ਸਲ ਦਾ ਵਧੀਆ ਜਮਾਅ",
        'sec_method': "ਬਿਜਾਈ ਦਾ ਤਰੀਕਾ ਚੁਣਨਾ",
        'm1_t': "ਛਿੱਟਾ ਦੇਣਾ (Broadcasting)",
        'm1_d': "ਹੱਥ ਨਾਲ ਬੀਜ ਖਿਲਾਰਨਾ। ਸੌਖਾ ਪਰ ਇਕਸਾਰ ਨਹੀਂ।",
        'm2_t': "ਹਲ ਪਿੱਛੇ ਬਿਜਾਈ",
        'm2_d': "ਹਲ ਦੁਆਰਾ ਬਣਾਈ ਸਿਆੜ ਵਿੱਚ ਬੀਜ ਪਾਉਣਾ।",
        'm3_t': "ਡਰਿੱਲ ਨਾਲ ਬਿਜਾਈ",
        'm3_d': "ਸੀਡ ਡਰਿੱਲ ਨਾਲ ਸਹੀ ਦੂਰੀ 'ਤੇ ਬਿਜਾਈ।",
        'm4_t': "FIRB ਸਿਸਟਮ",
        'm4_d': "ਬੈੱਡ ਬਣਾ ਕੇ ਬਿਜਾਈ। ਪਾਣੀ ਦੀ ਬੱਚਤ ਹੁੰਦੀ ਹੈ।",
      },
      'ur': {
        'title': "بوائی اور کھیت کی تیاری",
        'subtitle': "کامیابی کا انحصار صحیح وقت اور کھیت کی بہتر تیاری پر ہے۔",
        'sec_window': "بوائی کا وقت",
        'win_long': "طویل مدت (135–140 دن)",
        'date_long': "10 نومبر – 30 نومبر",
        'desc_long':
            "بہترین پیداوار: وقت پر بوائی سے شاخیں زیادہ بنتی ہیں اور دانہ وزنی ہوتا ہے۔",
        'win_short': "کم مدت (120–125 دن)",
        'date_short': "15 دسمبر تک",
        'desc_short':
            "دیر سے بوائی: دسمبر کے وسط کے بعد پیداوار کی صلاحیت تیزی سے کم ہوتی ہے۔",
        'warning':
            "15 دسمبر کے بعد بوائی کرنے سے گرمی کی وجہ سے دانہ سکڑ جاتا ہے۔",
        'sec_prep': "کھیت کی تیاری",
        'prep1_t': "مٹی کی ہمواری",
        'prep1_d': "کھیت کو اچھی طرح جوت کر ہموار کریں تاکہ مٹی بھربھری رہے۔",
        'prep1_p1': "بیج کی صحیح گہرائی",
        'prep1_p2': "بہتر اگاؤ اور یکساں نشوونما",
        'prep2_t': "زیرو ٹلیج (Zero Tillage)",
        'prep2_d': "بغیر ہل چلائے بوائی، دھان کی کٹائی کے بعد مفید۔",
        'prep2_p1': "وقت، ایندھن اور خرچے کی بچت",
        'prep2_p2': "مٹی کی نمی برقرار رہتی ہے",
        'prep2_p3': "وقت پر بوائی ممکن بناتی ہے",
        'prep3_t': "ڈبلنگ (Dibbling)",
        'prep3_d': "ہاتھ سے قطاروں میں بیج لگانا۔",
        'prep3_p1': "بیج کی مقدار کم لگتی ہے",
        'prep3_p2': "صحیح گہرائی اور فاصلہ",
        'prep3_p3': "فصل کی بہتر ترتیب",
        'sec_method': "بوائی کا طریقہ منتخب کرنا",
        'm1_t': "چھٹا مارنا (Broadcasting)",
        'm1_d': "ہاتھ سے بیج بکھیرنا۔ آسان مگر غیر یکساں۔",
        'm2_t': "ہل کے پیچھے بوائی",
        'm2_d': "ہل سے بنی لکیروں میں بیج ڈالنا۔",
        'm3_t': "ڈرلنگ (Drilling)",
        'm3_d': "سیڈ ڈرل کے ذریعے صحیح فاصلے پر بوائی۔",
        'm4_t': "FIRB سسٹم",
        'm4_d': "پٹریوں پر بوائی۔ پانی کی بچت ہوتی ہے۔",
      },
      'gu': {
        'title': "વાવણી અને ખેતરની તૈયારી",
        'subtitle':
            "સફળતાની શરૂઆત યોગ્ય સમય અને સંપૂર્ણ તૈયાર ક્યારી (Seedbed) થી થાય છે.",
        'sec_window': "વાવણીનો સમયગાળો",
        'win_long': "લાંબી અવધિ (135–140 દિવસ)",
        'date_long': "10 નવેમ્બર – 30 નવેમ્બર",
        'desc_long':
            "શ્રેષ્ઠ ઉપજ: વહેલી વાવણીથી ફૂટ સારી થાય છે અને દાણા ભારે બને છે.",
        'win_short': "ટૂંકી અવધિ (120–125 દિવસ)",
        'date_short': "15 ડિસેમ્બર સુધી",
        'desc_short':
            "મોડી વાવણી: ડિસેમ્બરના મધ્ય પછી ઉપજની ક્ષમતા ઝડપથી ઘટે છે.",
        'warning':
            "15 ડિસેમ્બર પછી વાવણી કરવાથી ગરમીને કારણે દાણા કરચલીવાળા થઈ જાય છે.",
        'sec_prep': "ખેતરની તૈયારી",
        'prep1_t': "જમીનની ગુણવત્તા",
        'prep1_d': "જમીનને ખેડીને અને સમાર ફેરવીને સમતળ બનાવો.",
        'prep1_p1': "બીજની યોગ્ય ઊંડાઈ જળવાય છે",
        'prep1_p2': "વધુ સારું અંકુરણ અને સમાન વિકાસ",
        'prep2_t': "ઝીરો ટિલેજ (Zero Tillage)",
        'prep2_d': "ખેડ્યા વિના વાવણી, ડાંગરની કાપણી પછી વિશેષ ઉપયોગી.",
        'prep2_p1': "સમય, બળતણ અને ખર્ચની બચત",
        'prep2_p2': "જમીનનો ભેજ જાળવી રાખે છે",
        'prep2_p3': "વહેલી વાવણીમાં મદદરૂપ",
        'prep3_t': "ડિબલિંગ (Dibbling)",
        'prep3_d': "હાથથી હારમાં બીજ રોપવા.",
        'prep3_p1': "ઓછા બિયારણની જરૂર પડે છે",
        'prep3_p2': "ચોક્કસ ઊંડાઈ અને અંતર નિશ્ચિત કરે છે",
        'prep3_p3': "પાકનો સારો વિકાસ",
        'sec_method': "વાવણીની પદ્ધતિ પસંદ કરવી",
        'm1_t': "પૂંખીને વાવણી (Broadcasting)",
        'm1_d': "હાથથી બીજ છાંટવા. સરળ પણ અસમાન.",
        'm2_t': "હળની પાછળ વાવણી",
        'm2_d': "હળ દ્વારા થતી નીક (furrow) માં બીજ નાખવા.",
        'm3_t': "ડ્રિલિંગ (Drilling)",
        'm3_d': "સીડ ડ્રિલ દ્વારા યોગ્ય અંતરે વાવણી.",
        'm4_t': "FIRB પદ્ધતિ",
        'm4_d': "બેડ બનાવી વાવણી કરવી. પાણી બચાવે છે.",
      },
      'bn': {
        'title': "বপন ও জমি প্রস্তুতি",
        'subtitle': "সাফল্য শুরু হয় সঠিক সময় এবং একটি নিখুঁত বীজতলার মাধ্যমে।",
        'sec_window': "বপনের সময়সূচী",
        'win_long': "দীর্ঘমেয়াদী (১৩৫–১৪০ দিন)",
        'date_long': "১০ নভেম্বর – ৩০ নভেম্বর",
        'desc_long': "সেরা ফলন: আগাম বপন করলে কুশি ভালো হয় এবং দানা ভারী হয়।",
        'win_short': "স্বল্পমেয়াদী (১২০–১২৫ দিন)",
        'date_short': "১৫ ডিসেম্বর পর্যন্ত",
        'desc_short':
            "নাবী বপন: ডিসেম্বরের মাঝামাঝির পর ফলন ক্ষমতা দ্রুত কমে যায়।",
        'warning': "১৫ ডিসেম্বরের পর বপন করলে তাপের কারণে দানা কুঁচকে যায়।",
        'sec_prep': "জমি প্রস্তুতি",
        'prep1_t': "মাটির গুণমান",
        'prep1_d': "জমি চাষ দিয়ে এবং মই দিয়ে ঝুরঝুরে ও সমতল করে নিন।",
        'prep1_p1': "সঠিক গভীরতায় বীজ স্থাপন",
        'prep1_p2': "ভালো অঙ্কুরোদগম ও সমান বৃদ্ধি",
        'prep2_t': "জিরো টিলেজ (Zero Tillage)",
        'prep2_d': "জমি চাষ না করে বপন, ধান কাটার পর এটি বিশেষ কার্যকর।",
        'prep2_p1': "সময়, জ্বালানি ও খরচ সাশ্রয়",
        'prep2_p2': "মাটির আর্দ্রতা রক্ষা করে",
        'prep2_p3': "আগাম বপনের সুযোগ দেয়",
        'prep3_t': "ডিবলিং (Dibbling)",
        'prep3_d': "হাত দিয়ে সারিবদ্ধভাবে বীজ রোপণ করা।",
        'prep3_p1': "কম বীজের প্রয়োজন হয়",
        'prep3_p2': "সঠিক গভীরতা ও দূরত্ব নিশ্চিত করে",
        'prep3_p3': "ফসল ভালোভাবে প্রতিষ্ঠিত হয়",
        'sec_method': "বপন পদ্ধতি নির্বাচন",
        'm1_t': "ছিটিয়ে বপন (Broadcasting)",
        'm1_d': "হাত দিয়ে বীজ ছড়িয়ে দেওয়া। সহজ কিন্তু অসম।",
        'm2_t': "লাঙ্গলের পিছনে বপন",
        'm2_d': "লাঙ্গলের রেখায় বীজ ফেলা হয়।",
        'm3_t': "ড্রিলিং (Drilling)",
        'm3_d': "সীড ড্রিল ব্যবহার করে সঠিক দূরত্বে বপন।",
        'm4_t': "FIRB পদ্ধতি",
        'm4_d': "উঁচু বেড তৈরি করে বপন। জল সাশ্রয় করে।",
      },
      'ml': {
        'title': "വിതയ്ക്കലും നിലം ഒരുക്കലും",
        'subtitle':
            "വിജയം ആരംഭിക്കുന്നത് കൃത്യസമയത്തുള്ള വിതയിലും മികച്ച നിലം ഒരുക്കലിലുമാണ്.",
        'sec_window': "വിതയ്ക്കാനുള്ള സമയം",
        'win_long': "കൂടുതൽ കാലാവധിയുള്ളവ (135–140 ദിവസം)",
        'date_long': "നവംബർ 10 – നവംബർ 30",
        'desc_long':
            "മികച്ച വിളവ്: നേരത്തെയുള്ള വിത കൂടുതൽ കവരകൾക്കും ധാന്യത്തിന്റെ തൂക്കം കൂട്ടാനും സഹായിക്കും.",
        'win_short': "കുറഞ്ഞ കാലാവധിയുള്ളവ (120–125 ദിവസം)",
        'date_short': "ഡിസംബർ 15 വരെ",
        'desc_short':
            "വൈകിയുള്ള വിത: ഡിസംബർ പകുതിക്ക് ശേഷം വിളവ് ഗണ്യമായി കുറയും.",
        'warning':
            "ഡിസംബർ 15-ന് ശേഷം വിതച്ചാൽ ചൂട് കാരണം ധാന്യങ്ങൾ ചുരുങ്ങിപ്പോകാൻ സാധ്യതയുണ്ട്.",
        'sec_prep': "നിലം ഒരുക്കൽ",
        'prep1_t': "മണ്ണിന്റെ ഗുണമേന്മ",
        'prep1_d': "മണ്ണ് നന്നായി ഉഴുതു നിരപ്പാക്കുക. കട്ടകൾ ഇല്ലാതെ നോക്കണം.",
        'prep1_p1': "വിത്ത് കൃത്യമായ ആഴത്തിൽ വിതയ്ക്കാം",
        'prep1_p2': "മികച്ച മുളയ്ക്കൽ നിരക്ക്",
        'prep2_t': "സീറോ ടില്ലേജ് (Zero Tillage)",
        'prep2_d':
            "ഉഴാതെ വിതയ്ക്കുന്ന രീതി, നെല്ല് കൊയ്ത്തിന് ശേഷം ഇത് ഗുണകരമാണ്.",
        'prep2_p1': "സമയം, ഇന്ധനം, ചിലവ് എന്നിവ ലാഭിക്കാം",
        'prep2_p2': "മണ്ണിലെ ഈർപ്പം നിലനിർത്തുന്നു",
        'prep2_p3': "നേരത്തെ വിതയ്ക്കാൻ സഹായിക്കുന്നു",
        'prep3_t': "ഡിബ്ലിംഗ് (Dibbling)",
        'prep3_d': "കൈകൊണ്ട് വരികളിൽ വിത്തിടുന്നത്.",
        'prep3_p1': "കുറഞ്ഞ അളവ് വിത്ത് മതിയാകും",
        'prep3_p2': "കൃത്യമായ ആഴവും അകലവും ലഭിക്കുന്നു",
        'prep3_p3': "ചെടികൾ നന്നായി വളരാൻ സഹായിക്കുന്നു",
        'sec_method': "വിതയ്ക്കൽ രീതി തിരഞ്ഞെടുക്കാം",
        'm1_t': "ബ്രോഡ്കാസ്റ്റിംഗ്",
        'm1_d': "കൈകൊണ്ട് വിതറുന്നത്. എളുപ്പമുള്ള രീതി.",
        'm2_t': "നാഗലിന് പിന്നാലെ",
        'm2_d': "നാഗൽ കൊണ്ട് ഉണ്ടാക്കുന്ന ചാലുകളിൽ വിത്തിടുക.",
        'm3_t': "ഡ്രില്ലിംഗ് (Drilling)",
        'm3_d': "സീഡ് ഡ്രില്ലർ ഉപയോഗിച്ച് വിതയ്ക്കുന്നത്.",
        'm4_t': "FIRB രീതി",
        'm4_d': "തടങ്ങൾ ഉണ്ടാക്കി വിതയ്ക്കുന്നത്. വെള്ളം ലാഭിക്കാം.",
      },
    };

    String t(String key) => _texts[locale]?[key] ?? _texts['en']![key]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/step4.png',
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          t('title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          t('subtitle'),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 25),

        _buildSectionHeader(
          t('sec_window'),
          Icons.calendar_month,
          primaryPurple,
        ),
        const SizedBox(height: 12),
        _buildWindowCard(
          t('win_long'),
          t('date_long'),
          t('desc_long'),
          Colors.green,
        ),
        const SizedBox(height: 10),
        _buildWindowCard(
          t('win_short'),
          t('date_short'),
          t('desc_short'),
          Colors.orange,
        ),
        const SizedBox(height: 10),
        _buildWarningBox(t('warning')),

        const SizedBox(height: 30),

        _buildSectionHeader(t('sec_prep'), Icons.landscape, Colors.brown),
        const SizedBox(height: 12),
        _buildDetailedPrepCard(
          title: t('prep1_t'),
          icon: Icons.architecture,
          color: Colors.brown,
          description: t('prep1_d'),
          points: [t('prep1_p1'), t('prep1_p2')],
        ),
        _buildDetailedPrepCard(
          title: t('prep2_t'),
          icon: Icons.eco,
          color: Colors.teal,
          description: t('prep2_d'),
          points: [t('prep2_p1'), t('prep2_p2'), t('prep2_p3')],
        ),
        _buildDetailedPrepCard(
          title: t('prep3_t'),
          icon: Icons.straighten,
          color: Colors.blueGrey,
          description: t('prep3_d'),
          points: [t('prep3_p1'), t('prep3_p2'), t('prep3_p3')],
        ),

        const SizedBox(height: 30),

        _buildSectionHeader(
          t('sec_method'),
          Icons.settings_suggest,
          primaryPurple,
        ),
        const SizedBox(height: 15),
        _buildMethodCard(
          t('m1_t'),
          t('m1_d'),
          Icons.pan_tool_alt,
          primaryPurple,
        ),
        _buildMethodCard(t('m2_t'), t('m2_d'), Icons.hardware, primaryPurple),
        _buildMethodCard(
          t('m3_t'),
          t('m3_d'),
          Icons.line_weight,
          primaryPurple,
        ),
        _buildMethodCard(t('m4_t'), t('m4_d'), Icons.water_drop, primaryPurple),

        const SizedBox(height: 100),
      ],
    );
  }

  // --- REFINED HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWindowCard(String type, String date, String desc, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPrepCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> points,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: color.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    String title,
    String desc,
    IconData icon,
    Color themeColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: themeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
