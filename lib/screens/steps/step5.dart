import 'package:flutter/material.dart';

class Step5Content extends StatelessWidget {
  final String locale;

  const Step5Content({super.key, this.locale = 'en'});

  static const Map<String, Map<String, String>> _texts = {
    'en': {
      'title': 'Seed Rate, Spacing & Nutrition',
      'subtitle':
          'Deciding on the right seed rate and fertilizer balance is the secret to a high-yield harvest.',
      'seed_rate': 'Seed Rate (Quantity)',
      'normal': 'Normal',
      'late_sown': 'Late Sown',
      'broadcasting': 'Broadcasting',
      'dibbling': 'Dibbling',
      'spacing': 'Recommended Spacing',
      'nitrogen': 'Nitrogen (Growth Booster)',
      'nitrogen_warning': 'Is your crop hungry for Nitrogen?',
      'irrigated': 'Irrigated',
      'rainfed': 'Rainfed',
      'phosphorus': 'Phosphorus (P)',
      'potassium': 'Potassium (K)',
      'micronutrients': 'Micronutrients',
      'zinc_mgmt': 'Zinc (Zn) Management',
      'inm': 'Integrated Nutrition (INM)',
      'quick_tips': 'Quick Tips for Success',
      'pro_tip': 'PRO TIP: Healthy soil = Heavy Yield!',
      // Metric card subtitles
      'timely': 'Timely',
      'low_moisture': 'Low moisture',
      'hand_sown': 'Hand-sown',
      'line_sowing': 'Line sowing',
      'full_dose': 'Full dose',
      'standard': 'Standard',
      // Application strategy
      'app_strategy': 'Application Strategy (Split Doses):',
      'phosphorus_desc': 'Apply FULL dose at sowing (Basal).',
      'potassium_desc': 'Only if soil test shows deficiency.',
      // Zinc management
      'soil_app': 'Soil App',
      'spray': 'Spray',
      // INM components
      'inm_title': 'Integrated Nutrient Management',
      'green_manure': 'Green Manure',
      'pulse_rotation': 'Pulse Rotation',
      'bio_fertilizers': 'Bio-fertilizers (Azotobacter/PSB)',
      // Quick tips
      'tip1': 'Adjust seed rate for late sowing.',
      'tip2': 'Maintain row spacing for root aeration.',
      'tip3': 'Split Nitrogen into 3 precise doses.',
      'tip4': 'Basal dose of Phosphorus is mandatory.',
      'tip5': 'Zinc improves grain shine and weight.',
    },
    'hi': {
      'title': 'बीज दर, दूरी और पोषण',
      'subtitle': 'उचित बीज दर और उर्वरक संतुलन अधिक उपज की कुंजी है।',
      'seed_rate': 'बीज दर',
      'normal': 'सामान्य',
      'late_sown': 'देर से बोया गया',
      'broadcasting': 'छिटकाव',
      'dibbling': 'डिब्लिंग',
      'spacing': 'अनुशंसित दूरी',
      'nitrogen': 'नाइट्रोजन (वृद्धि कारक)',
      'nitrogen_warning': 'क्या आपकी फसल को नाइट्रोजन की कमी है?',
      'irrigated': 'सिंचित',
      'rainfed': 'बारानी',
      'phosphorus': 'फास्फोरस (P)',
      'potassium': 'पोटैशियम (K)',
      'micronutrients': 'सूक्ष्म पोषक तत्व',
      'zinc_mgmt': 'जिंक (Zn) प्रबंधन',
      'inm': 'एकीकृत पोषण प्रबंधन',
      'quick_tips': 'त्वरित सुझाव',
      'pro_tip': 'प्रो टिप: स्वस्थ मिट्टी = अधिक उपज!',
      'timely': 'समय पर',
      'low_moisture': 'कम नमी',
      'hand_sown': 'हाथ से बोया',
      'line_sowing': 'लाइन बुवाई',
      'full_dose': 'पूर्ण मात्रा',
      'standard': 'मानक',
      'app_strategy': 'अनुप्रयोग रणनीति (विभाजित खुराक):',
      'phosphorus_desc': 'बुवाई के समय पूर्ण मात्रा डालें (बेसल)।',
      'potassium_desc': 'केवल मृदा परीक्षण में कमी दिखने पर।',
      'soil_app': 'मृदा अनुप्रयोग',
      'spray': 'छिड़काव',
      'inm_title': 'एकीकृत पोषक प्रबंधन',
      'green_manure': 'हरी खाद',
      'pulse_rotation': 'दलहन चक्र',
      'bio_fertilizers': 'जैव-उर्वरक (एजोटोबैक्टर/PSB)',
      'tip1': 'देर से बुवाई के लिए बीज दर समायोजित करें।',
      'tip2': 'जड़ वातन के लिए पंक्ति दूरी बनाए रखें।',
      'tip3': 'नाइट्रोजन को 3 सटीक खुराक में विभाजित करें।',
      'tip4': 'फास्फोरस की बेसल खुराक अनिवार्य है।',
      'tip5': 'जिंक अनाज की चमक और वजन बढ़ाता है।',
    },
    'ta': {
      'title': 'விதை அளவு, இடைவெளி மற்றும் ஊட்டச்சத்து',
      'subtitle': 'சரியான விதை அளவும் உர சமநிலையும் அதிக மகசூலுக்கு முக்கியம்.',
      'seed_rate': 'விதை அளவு',
      'normal': 'சாதாரணம்',
      'late_sown': 'தாமத விதைப்பு',
      'broadcasting': 'தூவுதல்',
      'dibbling': 'டிப்ளிங்',
      'spacing': 'பரிந்துரைக்கப்பட்ட இடைவெளி',
      'nitrogen': 'நைட்ரஜன் (வளர்ச்சி ஊக்கி)',
      'nitrogen_warning': 'உங்கள் பயிருக்கு நைட்ரஜன் குறைபாடா?',
      'irrigated': 'பாசன நிலம்',
      'rainfed': 'மழை சார்ந்த',
      'phosphorus': 'பாஸ்பரஸ் (P)',
      'potassium': 'பொட்டாசியம் (K)',
      'micronutrients': 'சிறு ஊட்டச்சத்துக்கள்',
      'zinc_mgmt': 'சிங்க் (Zn) மேலாண்மை',
      'inm': 'ஒருங்கிணைந்த ஊட்டச்சத்து மேலாண்மை',
      'quick_tips': 'விரைவு குறிப்புகள்',
      'pro_tip': 'ப்ரோ டிப்: ஆரோக்கியமான மண் = அதிக மகசூல்!',
      'timely': 'சரியான நேரத்தில்',
      'low_moisture': 'குறைந்த ஈரப்பதம்',
      'hand_sown': 'கையால் விதைத்தல்',
      'line_sowing': 'வரிசை விதைப்பு',
      'full_dose': 'முழு அளவு',
      'standard': 'நிலையான',
      'app_strategy': 'பயன்பாட்டு உத்தி (பிரிக்கப்பட்ட அளவுகள்):',
      'phosphorus_desc': 'விதைக்கும் போது முழு அளவு இடவும் (அடிப்படை).',
      'potassium_desc': 'மண் பரிசோதனையில் குறைபாடு தெரிந்தால் மட்டும்.',
      'soil_app': 'மண் பயன்பாடு',
      'spray': 'தெளிப்பு',
      'inm_title': 'ஒருங்கிணைந்த ஊட்டச்சத்து மேலாண்மை',
      'green_manure': 'பசுந்தாள் உரம்',
      'pulse_rotation': 'பருப்பு சுழற்சி',
      'bio_fertilizers': 'உயிர் உரங்கள் (அசோடோபாக்டர்/PSB)',
      'tip1': 'தாமத விதைப்புக்கு விதை அளவை சரிசெய்யவும்.',
      'tip2': 'வேர் காற்றோட்டத்திற்கு வரிசை இடைவெளியை பராமரிக்கவும்.',
      'tip3': 'நைட்ரஜனை 3 துல்லியமான அளவுகளாக பிரிக்கவும்.',
      'tip4': 'பாஸ்பரஸின் அடிப்படை அளவு கட்டாயம்.',
      'tip5': 'சிங்க் தானிய பளபளப்பு மற்றும் எடையை மேம்படுத்துகிறது.',
    },
    'te': {
      'title': 'విత్తన మోతాదు, అంతరం & పోషణ',
      'subtitle': 'సరైన విత్తన మోతాదు మరియు ఎరువుల సమతుల్యత అధిక దిగుబడికి కీలకం.',
      'seed_rate': 'విత్తన మోతాదు',
      'normal': 'సాధారణం',
      'late_sown': 'ఆలస్య విత్తనం',
      'broadcasting': 'చల్లడం',
      'dibbling': 'డిబ్లింగ్',
      'spacing': 'సిఫార్సు చేసిన అంతరం',
      'nitrogen': 'నైట్రోజన్ (వృద్ధి పెంపకం)',
      'nitrogen_warning': 'మీ పంటకు నైట్రోజన్ లోపమా?',
      'irrigated': 'నీటిపారుదల',
      'rainfed': 'వర్షాధారిత',
      'phosphorus': 'ఫాస్ఫరస్ (P)',
      'potassium': 'పొటాషియం (K)',
      'micronutrients': 'సూక్ష్మ పోషకాలు',
      'zinc_mgmt': 'జింక్ (Zn) నిర్వహణ',
      'inm': 'ఏకీకృత పోషక నిర్వహణ',
      'quick_tips': 'త్వరిత సూచనలు',
      'pro_tip': 'ప్రో టిప్: ఆరోగ్యమైన నేల = అధిక దిగుబడి!',
      'timely': 'సమయానికి',
      'low_moisture': 'తక్కువ తేమ',
      'hand_sown': 'చేతితో విత్తడం',
      'line_sowing': 'లైన్ విత్తనం',
      'full_dose': 'పూర్తి మోతాదు',
      'standard': 'ప్రమాణం',
      'app_strategy': 'అన్వయ వ్యూహం (విభజిత మోతాదులు):',
      'phosphorus_desc': 'విత్తనం సమయంలో పూర్తి మోతాదు వేయండి (బేసల్).',
      'potassium_desc': 'మట్టి పరీక్షలో లోపం కనిపిస్తేనే.',
      'soil_app': 'మట్టి అన్వయం',
      'spray': 'స్ప్రే',
      'inm_title': 'ఏకీకృత పోషక నిర్వహణ',
      'green_manure': 'పచ్చ ఎరువు',
      'pulse_rotation': 'పప్పుధాన్యాల మార్పిడి',
      'bio_fertilizers': 'జీవ-ఎరువులు (అజోటోబాక్టర్/PSB)',
      'tip1': 'ఆలస్య విత్తనానికి విత్తన మోతాదును సర్దుబాటు చేయండి.',
      'tip2': 'వేరు గాలి ప్రసరణ కోసం వరుస అంతరాన్ని నిర్వహించండి.',
      'tip3': 'నైట్రోజన్‌ను 3 ఖచ్చితమైన మోతాదులుగా విభజించండి.',
      'tip4': 'ఫాస్ఫరస్ బేసల్ మోతాదు తప్పనిసరి.',
      'tip5': 'జింక్ ధాన్యం మెరుపు మరియు బరువును మెరుగుపరుస్తుంది.',
    },
    'kn': {
      'title': 'ಬೀಜ ಪ್ರಮಾಣ, ಅಂತರ ಮತ್ತು ಪೋಷಣೆ',
      'subtitle': 'ಸರಿಯಾದ ಬೀಜ ಪ್ರಮಾಣ ಮತ್ತು ಗೊಬ್ಬರ ಸಮತೋಲನ ಹೆಚ್ಚು ಇಳುವರಿಗಾಗಿ ಅಗತ್ಯ.',
      'seed_rate': 'ಬೀಜ ಪ್ರಮಾಣ',
      'normal': 'ಸಾಮಾನ್ಯ',
      'late_sown': 'ತಡ ಬಿತ್ತನೆ',
      'broadcasting': 'ಚಲ್ಲಣೆ',
      'dibbling': 'ಡಿಬ್ಲಿಂಗ್',
      'spacing': 'ಶಿಫಾರಸು ಮಾಡಿದ ಅಂತರ',
      'nitrogen': 'ನೈಟ್ರೋಜನ್ (ಬೆಳವಣಿಗೆ ಹೆಚ್ಚಿಸುವುದು)',
      'nitrogen_warning': 'ನಿಮ್ಮ ಬೆಳೆಗಳಿಗೆ ನೈಟ್ರೋಜನ್ ಕೊರತೆಯೇ?',
      'irrigated': 'ನೀರಾವರಿ',
      'rainfed': 'ಮಳೆಯಾಶ್ರಿತ',
      'phosphorus': 'ಫಾಸ್ಫರಸ್ (P)',
      'potassium': 'ಪೊಟ್ಯಾಸಿಯಂ (K)',
      'micronutrients': 'ಸೂಕ್ಷ್ಮ ಪೋಷಕಾಂಶಗಳು',
      'zinc_mgmt': 'ಜಿಂಕ್ (Zn) ನಿರ್ವಹಣೆ',
      'inm': 'ಸಂಯುಕ್ತ ಪೋಷಕ ನಿರ್ವಹಣೆ',
      'quick_tips': 'ತ್ವರಿತ ಸಲಹೆಗಳು',
      'pro_tip': 'ಪ್ರೊ ಟಿಪ್: ಆರೋಗ್ಯಕರ ಮಣ್ಣು = ಹೆಚ್ಚು ಇಳುವರಿ!',
      'timely': 'ಸಮಯಕ್ಕೆ',
      'low_moisture': 'ಕಡಿಮೆ ತೇವಾಂಶ',
      'hand_sown': 'ಕೈಯಿಂದ ಬಿತ್ತನೆ',
      'line_sowing': 'ಸಾಲು ಬಿತ್ತನೆ',
      'full_dose': 'ಪೂರ್ಣ ಪ್ರಮಾಣ',
      'standard': 'ಪ್ರಮಾಣಿತ',
      'app_strategy': 'ಅನ್ವಯ ತಂತ್ರ (ವಿಭಜಿತ ಪ್ರಮಾಣಗಳು):',
      'phosphorus_desc': 'ಬಿತ್ತನೆ ಸಮಯದಲ್ಲಿ ಪೂರ್ಣ ಪ್ರಮಾಣ ಹಾಕಿ (ಬೇಸಲ್).',
      'potassium_desc': 'ಮಣ್ಣಿನ ಪರೀಕ್ಷೆಯಲ್ಲಿ ಕೊರತೆ ತೋರಿದರೆ ಮಾತ್ರ.',
      'soil_app': 'ಮಣ್ಣಿನ ಅನ್ವಯ',
      'spray': 'ಸಿಂಪಡಣೆ',
      'inm_title': 'ಸಂಯುಕ್ತ ಪೋಷಕ ನಿರ್ವಹಣೆ',
      'green_manure': 'ಹಸಿರು ಗೊಬ್ಬರ',
      'pulse_rotation': 'ದ್ವಿದಳ ಧಾನ್ಯ ಸುಳಿವು',
      'bio_fertilizers': 'ಜೈವಿಕ-ಗೊಬ್ಬರಗಳು (ಅಜೋಟೋಬ್ಯಾಕ್ಟರ್/PSB)',
      'tip1': 'ತಡವಾದ ಬಿತ್ತನೆಗೆ ಬೀಜ ಪ್ರಮಾಣವನ್ನು ಸರಿಹೊಂದಿಸಿ.',
      'tip2': 'ಬೇರು ವಾಯುಗೊಳಿಸುವಿಕೆಗಾಗಿ ಸಾಲು ಅಂತರವನ್ನು ನಿರ್ವಹಿಸಿ.',
      'tip3': 'ನೈಟ್ರೋಜನ್ ಅನ್ನು 3 ನಿಖರ ಪ್ರಮಾಣಗಳಾಗಿ ವಿಭಜಿಸಿ.',
      'tip4': 'ಫಾಸ್ಫರಸ್ ಬೇಸಲ್ ಪ್ರಮಾಣ ಕಡ್ಡಾಯ.',
      'tip5': 'ಜಿಂಕ್ ಧಾನ್ಯದ ಹೊಳಪು ಮತ್ತು ತೂಕವನ್ನು ಸುಧಾರಿಸುತ್ತದೆ.',
    },
    'mr': {
      'title': 'बियाणे दर, अंतर व पोषण',
      'subtitle': 'योग्य बियाणे दर आणि खत संतुलन अधिक उत्पादनासाठी आवश्यक आहे.',
      'seed_rate': 'बियाणे दर',
      'normal': 'सामान्य',
      'late_sown': 'उशिरा पेरणी',
      'broadcasting': 'उधळणी',
      'dibbling': 'डिब्लिंग',
      'spacing': 'शिफारस केलेले अंतर',
      'nitrogen': 'नायट्रोजन (वाढ वाढवणारे)',
      'nitrogen_warning': 'तुमच्या पिकाला नायट्रोजनची कमतरता आहे का?',
      'irrigated': 'सिंचित',
      'rainfed': 'पावसावर आधारित',
      'phosphorus': 'फॉस्फरस (P)',
      'potassium': 'पोटॅशियम (K)',
      'micronutrients': 'सूक्ष्म अन्नद्रव्ये',
      'zinc_mgmt': 'झिंक (Zn) व्यवस्थापन',
      'inm': 'एकात्मिक पोषण व्यवस्थापन',
      'quick_tips': 'जलद सूचना',
      'pro_tip': 'प्रो टिप: निरोगी माती = जास्त उत्पादन!',
      'timely': 'वेळेवर',
      'low_moisture': 'कमी आर्द्रता',
      'hand_sown': 'हाताने पेरणी',
      'line_sowing': 'ओळ पेरणी',
      'full_dose': 'पूर्ण डोस',
      'standard': 'मानक',
      'app_strategy': 'वापर धोरण (विभाजित डोस):',
      'phosphorus_desc': 'पेरणीच्या वेळी पूर्ण डोस घाला (बेसल).',
      'potassium_desc': 'फक्त माती चाचणीत कमतरता दिसल्यास.',
      'soil_app': 'माती वापर',
      'spray': 'फवारणी',
      'inm_title': 'एकात्मिक पोषण व्यवस्थापन',
      'green_manure': 'हिरवे खत',
      'pulse_rotation': 'डाळी फेरपालट',
      'bio_fertilizers': 'जैव-खते (अॅझोटोबॅक्टर/PSB)',
      'tip1': 'उशिरा पेरणीसाठी बियाणे दर समायोजित करा.',
      'tip2': 'मूळ वायुवीजन साठी ओळ अंतर राखा.',
      'tip3': 'नायट्रोजन 3 अचूक डोसमध्ये विभाजित करा.',
      'tip4': 'फॉस्फरसचा बेसल डोस अनिवार्य आहे.',
      'tip5': 'झिंक धान्याची चमक आणि वजन सुधारते.',
    },
    'pa': {
      'title': 'ਬੀਜ ਦਰ, ਦੂਰੀ ਅਤੇ ਪੋਸ਼ਣ',
      'subtitle': 'ਸਹੀ ਬੀਜ ਦਰ ਅਤੇ ਖਾਦ ਸੰਤੁਲਨ ਵਧੀਆ ਪੈਦਾਵਾਰ ਲਈ ਜ਼ਰੂਰੀ ਹੈ।',
      'seed_rate': 'ਬੀਜ ਦਰ',
      'normal': 'ਸਧਾਰਣ',
      'late_sown': 'ਦੇਰ ਨਾਲ ਬਿਜਾਈ',
      'broadcasting': 'ਛਿਟਕਾਅ',
      'dibbling': 'ਡਿਬਲਿੰਗ',
      'spacing': 'ਸਿਫਾਰਸ਼ੀ ਦੂਰੀ',
      'nitrogen': 'ਨਾਈਟ੍ਰੋਜਨ (ਵਾਧਾ ਵਧਾਉਣ ਵਾਲਾ)',
      'nitrogen_warning': 'ਕੀ ਤੁਹਾਡੀ ਫਸਲ ਨੂੰ ਨਾਈਟ੍ਰੋਜਨ ਦੀ ਘਾਟ ਹੈ?',
      'irrigated': 'ਸਿੰਚਿਤ',
      'rainfed': 'ਬਰਸਾਤੀ',
      'phosphorus': 'ਫਾਸਫੋਰਸ (P)',
      'potassium': 'ਪੋਟਾਸੀਅਮ (K)',
      'micronutrients': 'ਸੂਖਮ ਪੋਸ਼ਕ',
      'zinc_mgmt': 'ਜ਼ਿੰਕ (Zn) ਪ੍ਰਬੰਧਨ',
      'inm': 'ਇਕਿਕ੍ਰਿਤ ਪੋਸ਼ਣ ਪ੍ਰਬੰਧਨ',
      'quick_tips': 'ਤੁਰੰਤ ਸੁਝਾਅ',
      'pro_tip': 'ਪ੍ਰੋ ਟਿਪ: ਸਿਹਤਮੰਦ ਮਿੱਟੀ = ਵਧੀਆ ਪੈਦਾਵਾਰ!',
      'timely': 'ਸਮੇਂ ਸਿਰ',
      'low_moisture': 'ਘੱਟ ਨਮੀ',
      'hand_sown': 'ਹੱਥੀਂ ਬਿਜਾਈ',
      'line_sowing': 'ਲਾਈਨ ਬਿਜਾਈ',
      'full_dose': 'ਪੂਰੀ ਖੁਰਾਕ',
      'standard': 'ਮਿਆਰੀ',
      'app_strategy': 'ਲਾਗੂ ਰਣਨੀਤੀ (ਵੰਡੀਆਂ ਖੁਰਾਕਾਂ):',
      'phosphorus_desc': 'ਬਿਜਾਈ ਵੇਲੇ ਪੂਰੀ ਖੁਰਾਕ ਪਾਓ (ਬੇਸਲ).',
      'potassium_desc': 'ਸਿਰਫ਼ ਮਿੱਟੀ ਟੈਸਟ ਵਿੱਚ ਕਮੀ ਦਿਖਾਈ ਦੇਣ \'ਤੇ.',
      'soil_app': 'ਮਿੱਟੀ ਵਰਤੋਂ',
      'spray': 'ਛਿੜਕਾਅ',
      'inm_title': 'ਇਕਿਕ੍ਰਿਤ ਪੋਸ਼ਣ ਪ੍ਰਬੰਧਨ',
      'green_manure': 'ਹਰੀ ਖਾਦ',
      'pulse_rotation': 'ਦਾਲ ਚੱਕਰ',
      'bio_fertilizers': 'ਜੈਵਿਕ-ਖਾਦ (ਐਜ਼ੋਟੋਬੈਕਟਰ/PSB)',
      'tip1': 'ਦੇਰ ਨਾਲ ਬਿਜਾਈ ਲਈ ਬੀਜ ਦਰ ਸਮਾਯੋਜਿਤ ਕਰੋ.',
      'tip2': 'ਜੜ੍ਹ ਹਵਾਦਾਰੀ ਲਈ ਕਤਾਰ ਦੂਰੀ ਬਣਾਈ ਰੱਖੋ.',
      'tip3': 'ਨਾਈਟ੍ਰੋਜਨ ਨੂੰ 3 ਸਹੀ ਖੁਰਾਕਾਂ ਵਿੱਚ ਵੰਡੋ.',
      'tip4': 'ਫਾਸਫੋਰਸ ਦੀ ਬੇਸਲ ਖੁਰਾਕ ਲਾਜ਼ਮੀ ਹੈ.',
      'tip5': 'ਜ਼ਿੰਕ ਅਨਾਜ ਦੀ ਚਮਕ ਅਤੇ ਭਾਰ ਸੁਧਾਰਦਾ ਹੈ.',
    },
    'ur': {
      'title': 'بیج کی مقدار، فاصلہ اور غذائیت',
      'subtitle': 'درست بیج کی مقدار اور کھاد کا توازن زیادہ پیداوار کے لیے ضروری ہے۔',
      'seed_rate': 'بیج کی مقدار',
      'normal': 'عام',
      'late_sown': 'دیر سے بوائی',
      'broadcasting': 'چھٹائی',
      'dibbling': 'ڈبلنگ',
      'spacing': 'تجویز کردہ فاصلہ',
      'nitrogen': 'نائٹروجن (نشوونما بڑھانے والا)',
      'nitrogen_warning': 'کیا آپ کی فصل کو نائٹروجن کی کمی ہے؟',
      'irrigated': 'آبپاشی شدہ',
      'rainfed': 'بارانی',
      'phosphorus': 'فاسفورس (P)',
      'potassium': 'پوٹاشیم (K)',
      'micronutrients': 'خرد غذائی اجزاء',
      'zinc_mgmt': 'زنک (Zn) انتظام',
      'inm': 'متکامل غذائی انتظام',
      'quick_tips': 'فوری نکات',
      'pro_tip': 'پرو ٹپ: صحت مند مٹی = زیادہ پیداوار!',
      'timely': 'بروقت',
      'low_moisture': 'کم نمی',
      'hand_sown': 'ہاتھ سے بوائی',
      'line_sowing': 'لائن بوائی',
      'full_dose': 'مکمل خوراک',
      'standard': 'معیاری',
      'app_strategy': 'اطلاق کی حکمت عملی (تقسیم شدہ خوراکیں):',
      'phosphorus_desc': 'بوائی کے وقت مکمل خوراک ڈالیں (بیسل).',
      'potassium_desc': 'صرف مٹی کے ٹیسٹ میں کمی ظاہر ہونے پر.',
      'soil_app': 'مٹی کا اطلاق',
      'spray': 'سپرے',
      'inm_title': 'متکامل غذائی انتظام',
      'green_manure': 'سبز کھاد',
      'pulse_rotation': 'دال کی گردش',
      'bio_fertilizers': 'حیاتیاتی کھادیں (ایزوٹوبیکٹر/PSB)',
      'tip1': 'دیر سے بوائی کے لیے بیج کی مقدار ایڈجسٹ کریں.',
      'tip2': 'جڑوں کی ہوا کے لیے قطار کا فاصلہ برقرار رکھیں.',
      'tip3': 'نائٹروجن کو 3 درست خوراکوں میں تقسیم کریں.',
      'tip4': 'فاسفورس کی بیسل خوراک لازمی ہے.',
      'tip5': 'زنک اناج کی چمک اور وزن بہتر بناتا ہے.',
    },
    'gu': {
      'title': 'બીજ દર, અંતર અને પોષણ',
      'subtitle': 'યોગ્ય બીજ દર અને ખાતર સંતુલન વધુ ઉત્પાદન માટે મહત્વપૂર્ણ છે.',
      'seed_rate': 'બીજ દર',
      'normal': 'સામાન્ય',
      'late_sown': 'મોડું વાવેતર',
      'broadcasting': 'છંટકાવ',
      'dibbling': 'ડિબ્લિંગ',
      'spacing': 'ભલામણ કરેલ અંતર',
      'nitrogen': 'નાઇટ્રોજન (વિકાસ વધારનાર)',
      'nitrogen_warning': 'શું તમારા પાકમાં નાઇટ્રોજનની અછત છે?',
      'irrigated': 'સિંચિત',
      'rainfed': 'વરસાદ આધારિત',
      'phosphorus': 'ફોસ્ફરસ (P)',
      'potassium': 'પોટેશિયમ (K)',
      'micronutrients': 'સૂક્ષ્મ પોષક તત્વો',
      'zinc_mgmt': 'ઝિંક (Zn) વ્યવસ્થાપન',
      'inm': 'સમેકૃત પોષણ વ્યવસ્થાપન',
      'quick_tips': 'ઝડપી સૂચનો',
      'pro_tip': 'પ્રો ટીપ: સ્વસ્થ જમીન = વધુ ઉત્પાદન!',
      'timely': 'સમયસર',
      'low_moisture': 'ઓછો ભેજ',
      'hand_sown': 'હાથથી વાવેતર',
      'line_sowing': 'લાઇન વાવેતર',
      'full_dose': 'સંપૂર્ણ માત્રા',
      'standard': 'પ્રમાણભૂત',
      'app_strategy': 'ઉપયોગ વ્યૂહરચના (વિભાજિત માત્રાઓ):',
      'phosphorus_desc': 'વાવણી સમયે સંપૂર્ણ માત્રા નાખો (બેસલ).',
      'potassium_desc': 'ફક્ત માટી પરીક્ષણમાં ઉણપ જોવા મળે તો.',
      'soil_app': 'માટી ઉપયોગ',
      'spray': 'છંટકાવ',
      'inm_title': 'સમેકૃત પોષણ વ્યવસ્થાપન',
      'green_manure': 'લીલું ખાતર',
      'pulse_rotation': 'કઠોળ ચક્ર',
      'bio_fertilizers': 'જૈવિક-ખાતરો (એઝોટોબેક્ટર/PSB)',
      'tip1': 'મોડા વાવેતર માટે બીજ દર ગોઠવો.',
      'tip2': 'મૂળ વાયુમિશ્રણ માટે હરોળ અંતર જાળવો.',
      'tip3': 'નાઇટ્રોજનને 3 ચોક્કસ માત્રામાં વહેંચો.',
      'tip4': 'ફોસ્ફરસની બેસલ માત્રા ફરજિયાત છે.',
      'tip5': 'ઝિંક અનાજની ચમક અને વજન સુધારે છે.',
    },
    'bn': {
      'title': 'বীজের হার, দূরত্ব ও পুষ্টি',
      'subtitle': 'সঠিক বীজের হার ও সার ব্যবস্থাপনা বেশি ফলনের চাবিকাঠি।',
      'seed_rate': 'বীজের হার',
      'normal': 'স্বাভাবিক',
      'late_sown': 'দেরিতে বপন',
      'broadcasting': 'ছিটানো',
      'dibbling': 'ডিবলিং',
      'spacing': 'প্রস্তাবিত দূরত্ব',
      'nitrogen': 'নাইট্রোজেন (বৃদ্ধি সহায়ক)',
      'nitrogen_warning': 'আপনার ফসলে কি নাইট্রোজেনের অভাব?',
      'irrigated': 'সেচযুক্ত',
      'rainfed': 'বর্ষা নির্ভর',
      'phosphorus': 'ফসফরাস (P)',
      'potassium': 'পটাশিয়াম (K)',
      'micronutrients': 'ক্ষুদ্র পুষ্টি উপাদান',
      'zinc_mgmt': 'জিঙ্ক (Zn) ব্যবস্থাপনা',
      'inm': 'সমন্বিত পুষ্টি ব্যবস্থাপনা',
      'quick_tips': 'দ্রুত পরামর্শ',
      'pro_tip': 'প্রো টিপ: সুস্থ মাটি = বেশি ফলন!',
      'timely': 'সময়মত',
      'low_moisture': 'কম আর্দ্রতা',
      'hand_sown': 'হাতে বপন',
      'line_sowing': 'লাইন বপন',
      'full_dose': 'সম্পূর্ণ মাত্রা',
      'standard': 'মানক',
      'app_strategy': 'প্রয়োগ কৌশল (বিভক্ত মাত্রা):',
      'phosphorus_desc': 'বপনের সময় সম্পূর্ণ মাত্রা দিন (বেসাল).',
      'potassium_desc': 'শুধুমাত্র মাটি পরীক্ষায় ঘাটতি দেখা গেলে.',
      'soil_app': 'মাটি প্রয়োগ',
      'spray': 'স্প্রে',
      'inm_title': 'সমন্বিত পুষ্টি ব্যবস্থাপনা',
      'green_manure': 'সবুজ সার',
      'pulse_rotation': 'ডাল ঘূর্ণন',
      'bio_fertilizers': 'জৈব-সার (অ্যাজোটোব্যাক্টর/PSB)',
      'tip1': 'দেরিতে বপনের জন্য বীজের হার সামঞ্জস্য করুন.',
      'tip2': 'মূল বায়ুচলাচলের জন্য সারি দূরত্ব বজায় রাখুন.',
      'tip3': 'নাইট্রোজেনকে 3 সঠিক মাত্রায় ভাগ করুন.',
      'tip4': 'ফসফরাসের বেসাল মাত্রা বাধ্যতামূলক.',
      'tip5': 'জিঙ্ক শস্যের উজ্জ্বলতা এবং ওজন উন্নত করে.',
    },
    'ml': {
      'title': 'വിത്ത് അളവ്, ഇടവേള & പോഷണം',
      'subtitle': 'ശരിയായ വിത്ത് അളവും വളസമതുലിതവും ഉയർന്ന വിളവിന് അനിവാര്യമാണ്.',
      'seed_rate': 'വിത്ത് അളവ്',
      'normal': 'സാധാരണ',
      'late_sown': 'താമസിച്ച് വിതച്ചത്',
      'broadcasting': 'ചിതറിക്കൽ',
      'dibbling': 'ഡിബ്ലിംഗ്',
      'spacing': 'ശുപാർശ ചെയ്ത ഇടവേള',
      'nitrogen': 'നൈട്രജൻ (വളർച്ച വർധിപ്പിക്കുന്നത്)',
      'nitrogen_warning': 'നിങ്ങളുടെ വിളയ്ക്ക് നൈട്രജൻ കുറവുണ്ടോ?',
      'irrigated': 'സേചിത',
      'rainfed': 'മഴ ആശ്രിത',
      'phosphorus': 'ഫോസ്ഫറസ് (P)',
      'potassium': 'പൊട്ടാസ്യം (K)',
      'micronutrients': 'സൂക്ഷ്മ പോഷകങ്ങൾ',
      'zinc_mgmt': 'സിങ്ക് (Zn) നിയന്ത്രണം',
      'inm': 'സംയോജിത പോഷക നിയന്ത്രണം',
      'quick_tips': 'വേഗത്തിലുള്ള നിർദ്ദേശങ്ങൾ',
      'pro_tip': 'പ്രോ ടിപ്പ്: ആരോഗ്യമുള്ള മണ്ണ് = കൂടുതൽ വിളവ്!',
      'timely': 'സമയബന്ധിതമായി',
      'low_moisture': 'കുറഞ്ഞ ഈർപ്പം',
      'hand_sown': 'കൈകൊണ്ട് വിതയ്ക്കൽ',
      'line_sowing': 'വരി വിതയ്ക്കൽ',
      'full_dose': 'പൂർണ്ണ അളവ്',
      'standard': 'സാധാരണ',
      'app_strategy': 'പ്രയോഗ തന്ത്രം (വിഭജിത അളവുകൾ):',
      'phosphorus_desc': 'വിതയ്ക്കുമ്പോൾ പൂർണ്ണ അളവ് ചേർക്കുക (ബേസൽ).',
      'potassium_desc': 'മണ്ണ് പരിശോധനയിൽ കുറവ് കാണിച്ചാൽ മാത്രം.',
      'soil_app': 'മണ്ണ് പ്രയോഗം',
      'spray': 'സ്പ്രേ',
      'inm_title': 'സംയോജിത പോഷക നിയന്ത്രണം',
      'green_manure': 'പച്ച വളം',
      'pulse_rotation': 'പയർ വിള മാറ്റം',
      'bio_fertilizers': 'ജൈവ-വളങ്ങൾ (അസോട്ടോബാക്ടർ/PSB)',
      'tip1': 'വൈകിയ വിതയ്ക്കലിന് വിത്ത് അളവ് ക്രമീകരിക്കുക.',
      'tip2': 'വേരിന്റെ വായു സഞ്ചാരത്തിന് വരി അകലം പാലിക്കുക.',
      'tip3': 'നൈട്രജനെ 3 കൃത്യമായ അളവുകളാക്കി വിഭജിക്കുക.',
      'tip4': 'ഫോസ്ഫറസിന്റെ ബേസൽ അളവ് നിർബന്ധമാണ്.',
      'tip5': 'സിങ്ക് ധാന്യത്തിന്റെ തിളക്കവും ഭാരവും മെച്ചപ്പെടുത്തുന്നു.',
    },
  };

  String _t(String key) => _texts[locale]?[key] ?? _texts['en']![key]!;

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * 0.5;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Header
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/step5.png',
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: imageHeight,
                      width: double.infinity,
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
                _t('title'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _t('subtitle'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),

              // 2. Seed Rate Section
              _buildSectionHeader(
                _t('seed_rate'),
                Icons.grass,
                Colors.green,
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          _t('normal'),
                          "100–125 kg/ha",
                          _t('timely'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          _t('late_sown'),
                          "+25% extra",
                          _t('low_moisture'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          _t('broadcasting'),
                          "150 kg/ha",
                          _t('hand_sown'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          _t('dibbling'),
                          "25–30 kg/ha",
                          _t('line_sowing'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. Spacing Guide
              _buildSectionHeader(
                _t('spacing'),
                Icons.straighten,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildSpacingTable(),
              const SizedBox(height: 30),

              // 4. Nitrogen Management
              _buildSectionHeader(
                _t('nitrogen'),
                Icons.bolt,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildDeficiencyList(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      _t('irrigated'),
                      "120–150 kg/ha",
                      _t('full_dose'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      _t('rainfed'),
                      "40–60 kg/ha",
                      _t('standard'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                _t('app_strategy'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 15),
              _buildSplitTimeline(primaryPurple),

              const SizedBox(height: 30),

              // 5. Phosphorus & Potassium
              _buildNutrientCard(
                _t('phosphorus'),
                "60 kg P₂O₅ /ha",
                _t('phosphorus_desc'),
                Colors.deepPurple,
              ),
              const SizedBox(height: 12),
              _buildNutrientCard(
                _t('potassium'),
                "40–60 kg /ha",
                _t('potassium_desc'),
                Colors.indigo,
              ),

              const SizedBox(height: 30),

              // 6. Micronutrient Grid (Adjusted for Manganese text width)
              _buildSectionHeader(_t('micronutrients'), Icons.biotech, Colors.teal),
              const SizedBox(height: 12),
              _buildMicronutrientGrid(),
              const SizedBox(height: 12),
              _buildZincDetailCard(),

              const SizedBox(height: 30),

              // 7. INM Section
              _buildSectionHeader(
                _t('inm'),
                Icons.eco,
                Colors.green.shade700,
              ),
              const SizedBox(height: 12),
              _buildModernINM(),

              const SizedBox(height: 40),

              // 8. Premium Quick Tips
              _buildPremiumQuickTips(primaryPurple),

              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          _buildTableRow([
            "Condition",
            "Row-Row",
            "Plant-Plant",
          ], isHeader: true),
          _buildTableRow(["Irrigated", "22.5 cm", "8–18 cm"]),
          _buildTableRow(["Rainfed", "25–30 cm", "5–6 cm"]),
          _buildTableRow(["Late Sown", "15–16 cm", "Closely"]),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue.withOpacity(0.05) : Colors.transparent,
      ),
      children: cells
          .map(
            (cell) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                cell,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: isHeader ? Colors.blue : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDeficiencyList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "⚠️ ${_t('nitrogen_warning')}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _defPoint("Fewer tillers (Less branching)"),
          _defPoint("Small ear heads"),
          _defPoint("Weak & pale yellowish look"),
        ],
      ),
    );
  }

  Widget _defPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTimeline(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _timelineStep("Sowing", "1st Part", "Basal", color),
        const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        _timelineStep("1st Water", "2nd Part", "Tillering", color),
        const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        _timelineStep("2nd Water", "3rd Part", "Jointing", color),
      ],
    );
  }

  Widget _timelineStep(String label, String part, String desc, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: const Icon(Icons.water_drop, color: Colors.white, size: 14),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          part,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(desc, style: const TextStyle(fontSize: 8, color: Colors.black45)),
      ],
    );
  }

  Widget _buildNutrientCard(
    String title,
    String dose,
    String note,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dose,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // --- MICRONUTRIENT GRID ---
  Widget _buildMicronutrientGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌱 Essential Elements:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniChip("Zinc (Zn)"),
              _miniChip("Iron (Fe)"),
              _miniChip("Boron (B)"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _miniChip("Copper (Cu)"),
              _miniChip(
                "Manganese (Mn)",
                flex: 2,
              ), // Slightly more space for Mn text
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 2,
        ), // Tight horizontal padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.withOpacity(0.3)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1, // Force one line
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildZincDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🌾 ${_t('zinc_mgmt')}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _subRow(Icons.landscape, _t('soil_app') + ":", "25 kg ZnSO₄/ha"),
          const SizedBox(height: 8),
          _subRow(Icons.wash, _t('spray') + ":", "5kg ZnSO₄ + 2.5kg Lime / 1000L"),
        ],
      ),
    );
  }

  Widget _subRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Text("$title $desc", style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  // --- MODERN INM ---
  Widget _buildModernINM() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Text(
            "♻️ ${_t('inm_title')}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _inmItem(Icons.compost, _t('green_manure')),
              const SizedBox(width: 10),
              _inmItem(Icons.loop, _t('pulse_rotation')),
            ],
          ),
          const SizedBox(height: 10),
          _inmItem(
            Icons.biotech,
            _t('bio_fertilizers'),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _inmItem(IconData icon, String text, {bool fullWidth = false}) {
    Widget content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    return fullWidth
        ? SizedBox(width: double.infinity, child: content)
        : Expanded(child: content);
  }

  // --- PREMIUM QUICK TIPS ---
  Widget _buildPremiumQuickTips(Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  _t('quick_tips'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _tipRow(_t('tip1'), color),
                _tipRow(_t('tip2'), color),
                _tipRow(_t('tip3'), color),
                _tipRow(_t('tip4'), color),
                _tipRow(_t('tip5'), color),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              _t('pro_tip'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
