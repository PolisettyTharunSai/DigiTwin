import 'package:flutter/material.dart';

class Step6Content extends StatelessWidget {
  final String locale;

  const Step6Content({super.key, this.locale = 'en'});

  static const Map<String, Map<String, String>> _texts = {
    'en': {
      'title': 'Irrigation & Crop Care',
      'subtitle':
          'Wheat responds strongly to irrigation. 4–6 waterings are usually required for a healthy crop.',
      'critical_stages': 'Critical Watering Stages',
      'tech_guidelines': 'Technical Guidelines',
      'moisture': 'Moisture',
      'soil_type': 'Soil Type',
      'iwcpe': 'IW:CPE',
      'count': 'Count',
      'weed_mgmt': 'Weed Management',
      'mono_weeds': 'Monocot Weeds (Phalaris, Wild Oat, etc.)',
      'harvest': 'Harvesting & Threshing',
      'rotation': 'Rotation & Systems',
      'rotation_desc':
          'Wheat is usually grown after Kharif crops. Common rotations include:',
      'rotation_note':
          "Note: A third 'catch crop' is often grown in specific regions.",
      'maturity': 'Maturity',
      'moisture_harvest': 'Moisture',
      'caution': 'Caution',
      'manual_tip': 'Manual Tip: Dry for 3–4 days before threshing.',
      // Irrigation stages
      'cri_stage': 'CRI Stage (20–25 DAS)',
      'cri_desc': 'Water helps strong roots & more tillers.',
      'jointing_stage': 'Jointing Stage',
      'jointing_desc': 'Helps the plant grow tall and strong.',
      'flowering_stage': 'Flowering Stage',
      'flowering_desc': 'Ensures a higher number of grains.',
      'milk_stage': 'Milk Stage',
      'milk_desc': 'Proper grain filling for heavier grains.',
      // Weed management
      'hand_weeding_1': '1st Hand Weeding',
      'hand_weeding_2': '2nd Hand Weeding',
      'day_20_25': 'Day 20–25',
      'plus_2_weeks': '+2 Weeks',
      'type': 'Type',
      'chemical': 'Chemical',
      'rate_time': 'Rate/Time',
      'dicots': 'Dicots',
      'monocots': 'Monocots',
      'pre_em': 'Pre-Em',
      'isoproturon': 'Isoproturon',
      'pendimethalin': 'Pendimethalin',
      'early': 'Early',
      // Harvest info
      'maturity_desc': 'Yellow/dry straw, hard grains.',
      'moisture_desc': 'Ideal moisture: 20–25%.',
      'caution_desc': 'Over-ripening causes shattering.',
      // Crop rotation
      'rice': 'Rice',
      'maize': 'Maize',
      'sorghum': 'Sorghum',
      'millet': 'Millet',
      'mungbean': 'Mungbean',
      'pigeonpea': 'Pigeonpea',
      'cotton': 'Cotton',
    },
    'hi': {
      'title': 'सिंचाई एवं फसल देखभाल',
      'subtitle':
          'गेहूं सिंचाई पर अच्छी प्रतिक्रिया देता है। स्वस्थ फसल के लिए 4–6 सिंचाइयाँ आवश्यक होती हैं।',
      'critical_stages': 'महत्वपूर्ण सिंचाई अवस्थाएँ',
      'tech_guidelines': 'तकनीकी दिशानिर्देश',
      'moisture': 'नमी',
      'soil_type': 'मृदा प्रकार',
      'iwcpe': 'IW:CPE',
      'count': 'संख्या',
      'weed_mgmt': 'खरपतवार प्रबंधन',
      'mono_weeds': 'एकबीजपत्री खरपतवार (फैलेरिस, जंगली जई आदि)',
      'harvest': 'कटाई एवं मड़ाई',
      'rotation': 'फसल चक्र',
      'rotation_desc':
          'गेहूं सामान्यतः खरीफ फसलों के बाद उगाया जाता है। सामान्य चक्र:',
      'rotation_note': 'नोट: कुछ क्षेत्रों में तीसरी "कैच फसल" भी उगाई जाती है।',
      'maturity': 'परिपक्वता',
      'moisture_harvest': 'नमी',
      'caution': 'सावधानी',
      'manual_tip': 'मैनुअल टिप: मड़ाई से पहले 3–4 दिन सुखाएं।',
      'cri_stage': 'CRI अवस्था (20–25 DAS)',
      'cri_desc': 'पानी मजबूत जड़ें और अधिक कल्ले बनाने में मदद करता है।',
      'jointing_stage': 'गांठ बनने की अवस्था',
      'jointing_desc': 'पौधे को लंबा और मजबूत बनाने में मदद करता है।',
      'flowering_stage': 'फूल आने की अवस्था',
      'flowering_desc': 'अधिक दानों की संख्या सुनिश्चित करता है।',
      'milk_stage': 'दुग्ध अवस्था',
      'milk_desc': 'भारी दानों के लिए उचित भराव।',
      'hand_weeding_1': 'पहली हाथ से निराई',
      'hand_weeding_2': 'दूसरी हाथ से निराई',
      'day_20_25': 'दिन 20–25',
      'plus_2_weeks': '+2 सप्ताह',
      'type': 'प्रकार',
      'chemical': 'रसायन',
      'rate_time': 'दर/समय',
      'dicots': 'द्विबीजपत्री',
      'monocots': 'एकबीजपत्री',
      'pre_em': 'प्री-इम',
      'isoproturon': 'आइसोप्रोट्यूरॉन',
      'pendimethalin': 'पेंडीमेथालिन',
      'early': 'प्रारंभिक',
      'maturity_desc': 'पीला/सूखा भूसा, कठोर दाने।',
      'moisture_desc': 'आदर्श नमी: 20–25%।',
      'caution_desc': 'अधिक पकने से दाने झड़ते हैं।',
      'rice': 'धान',
      'maize': 'मक्का',
      'sorghum': 'ज्वार',
      'millet': 'बाजरा',
      'mungbean': 'मूंग',
      'pigeonpea': 'अरहर',
      'cotton': 'कपास',
    },
    'ta': {
      'title': 'பாசனம் & பயிர் பராமரிப்பு',
      'subtitle':
          'கோதுமை பாசனத்திற்கு சிறந்த முறையில் பதிலளிக்கிறது. ஆரோக்கியமான பயிருக்கு 4–6 முறை பாசனம் தேவை.',
      'critical_stages': 'முக்கிய பாசன நிலைகள்',
      'tech_guidelines': 'தொழில்நுட்ப வழிகாட்டுதல்கள்',
      'moisture': 'ஈரப்பதம்',
      'soil_type': 'மண் வகை',
      'iwcpe': 'IW:CPE',
      'count': 'எண்ணிக்கை',
      'weed_mgmt': 'களைக் கட்டுப்பாடு',
      'mono_weeds': 'ஒருதழை களைகள் (பாலாரிஸ், காட்டு ஓட்ஸ்)',
      'harvest': 'அறுவடை & தட்டுதல்',
      'rotation': 'பயிர் சுழற்சி',
      'rotation_desc': 'கோதுமை பொதுவாக காரிஃப் பயிர்களுக்கு பிறகு பயிரிடப்படுகிறது.',
      'rotation_note': 'குறிப்பு: சில பகுதிகளில் மூன்றாவது "கேட்ச் பயிர்" பயிரிடப்படுகிறது.',
      'maturity': 'முதிர்ச்சி',
      'moisture_harvest': 'ஈரப்பதம்',
      'caution': 'எச்சரிக்கை',
      'manual_tip': 'கையேடு குறிப்பு: தட்டுவதற்கு முன் 3–4 நாட்கள் உலர்த்தவும்.',
      'cri_stage': 'CRI நிலை (20–25 DAS)',
      'cri_desc': 'நீர் வலுவான வேர்கள் & அதிக தளிர்களுக்கு உதவுகிறது.',
      'jointing_stage': 'முட்டு உருவாக்கும் நிலை',
      'jointing_desc': 'செடி உயரமாகவும் வலுவாகவும் வளர உதவுகிறது.',
      'flowering_stage': 'பூக்கும் நிலை',
      'flowering_desc': 'அதிக தானியங்களை உறுதி செய்கிறது.',
      'milk_stage': 'பால் நிலை',
      'milk_desc': 'கனமான தானியங்களுக்கு சரியான நிரப்புதல்.',
      'hand_weeding_1': 'முதல் கை களை எடுத்தல்',
      'hand_weeding_2': 'இரண்டாம் கை களை எடுத்தல்',
      'day_20_25': 'நாள் 20–25',
      'plus_2_weeks': '+2 வாரங்கள்',
      'type': 'வகை',
      'chemical': 'இரசாயனம்',
      'rate_time': 'விகிதம்/நேரம்',
      'dicots': 'இருதழை',
      'monocots': 'ஒருதழை',
      'pre_em': 'முன்-இம்',
      'isoproturon': 'ஐசோப்ரோட்யூரான்',
      'pendimethalin': 'பெண்டிமெத்தாலின்',
      'early': 'ஆரம்பம்',
      'maturity_desc': 'மஞ்சள்/உலர்ந்த வைக்கோல், கடின தானியங்கள்.',
      'moisture_desc': 'சிறந்த ஈரப்பதம்: 20–25%.',
      'caution_desc': 'அதிக பழுத்தல் உதிர்வை ஏற்படுத்துகிறது.',
      'rice': 'நெல்',
      'maize': 'சோளம்',
      'sorghum': 'கம்பு',
      'millet': 'தினை',
      'mungbean': 'பயறு',
      'pigeonpea': 'துவரை',
      'cotton': 'பருத்தி',
    },
    'te': {
      'title': 'నీటిపారుదల & పంట సంరక్షణ',
      'subtitle':
          'గోధుమ నీటిపారుదలకి బాగా స్పందిస్తుంది. ఆరోగ్యకరమైన పంటకు 4–6 సార్లు నీరు అవసరం.',
      'critical_stages': 'ముఖ్య నీటిపారుదల దశలు',
      'tech_guidelines': 'సాంకేతిక మార్గదర్శకాలు',
      'moisture': 'తేమ',
      'soil_type': 'నేల రకం',
      'iwcpe': 'IW:CPE',
      'count': 'సంఖ్య',
      'weed_mgmt': 'కలుపు నిర్వహణ',
      'mono_weeds': 'ఏకబీజ పత్ర కలుపులు (ఫలారిస్, అడవి వోట్)',
      'harvest': 'కోత & నూర్పిడి',
      'rotation': 'పంట మార్పిడి',
      'rotation_desc': 'గోధుమ సాధారణంగా ఖరీఫ్ పంటల తర్వాత పండిస్తారు.',
      'rotation_note': 'గమనిక: కొన్ని ప్రాంతాల్లో మూడవ "క్యాచ్ పంట" కూడా పండిస్తారు.',
      'maturity': 'పరిపక్వత',
      'moisture_harvest': 'తేమ',
      'caution': 'హెచ్చరిక',
      'manual_tip': 'మాన్యువల్ చిట్కా: నూర్పిడికి ముందు 3–4 రోజులు ఎండబెట్టండి.',
      'cri_stage': 'CRI దశ (20–25 DAS)',
      'cri_desc': 'నీరు బలమైన వేర్లు & ఎక్కువ చిగుళ్లకు సహాయపడుతుంది.',
      'jointing_stage': 'కణుపు దశ',
      'jointing_desc': 'మొక్క పొడవుగా మరియు బలంగా పెరగడానికి సహాయపడుతుంది.',
      'flowering_stage': 'పుష్పించే దశ',
      'flowering_desc': 'అధిక ధాన్యాల సంఖ్యను నిర్ధారిస్తుంది.',
      'milk_stage': 'పాల దశ',
      'milk_desc': 'బరువైన ధాన్యాల కోసం సరైన నింపడం.',
      'hand_weeding_1': 'మొదటి చేతి కలుపు తీయడం',
      'hand_weeding_2': 'రెండవ చేతి కలుపు తీయడం',
      'day_20_25': 'రోజు 20–25',
      'plus_2_weeks': '+2 వారాలు',
      'type': 'రకం',
      'chemical': 'రసాయనం',
      'rate_time': 'రేటు/సమయం',
      'dicots': 'ద్విబీజపత్రాలు',
      'monocots': 'ఏకబీజపత్రాలు',
      'pre_em': 'ప్రీ-ఎమ్',
      'isoproturon': 'ఐసోప్రోట్యూరాన్',
      'pendimethalin': 'పెండిమెథాలిన్',
      'early': 'ప్రారంభ',
      'maturity_desc': 'పసుపు/ఎండిన గడ్డి, గట్టి ధాన్యాలు.',
      'moisture_desc': 'ఆదర్శ తేమ: 20–25%.',
      'caution_desc': 'అధిక పక్వత పగిలిపోవడానికి కారణమవుతుంది.',
      'rice': 'వరి',
      'maize': 'మొక్కజొన్న',
      'sorghum': 'జొన్న',
      'millet': 'సజ్జలు',
      'mungbean': 'పెసలు',
      'pigeonpea': 'కందులు',
      'cotton': 'పత్తి',
    },
    'kn': {
      'title': 'ನೀರಾವರಿ ಮತ್ತು ಬೆಳೆ ಸಂರಕ್ಷಣೆ',
      'subtitle':
          'ಗೋಧಿ ನೀರಾವರಿಗೆ ಉತ್ತಮ ಪ್ರತಿಕ್ರಿಯೆ ನೀಡುತ್ತದೆ. ಆರೋಗ್ಯಕರ ಬೆಳೆಗೆ 4–6 ಬಾರಿ ನೀರಾವರಿ ಅಗತ್ಯ.',
      'critical_stages': 'ಮುಖ್ಯ ನೀರಾವರಿ ಹಂತಗಳು',
      'tech_guidelines': 'ತಾಂತ್ರಿಕ ಮಾರ್ಗಸೂಚಿಗಳು',
      'moisture': 'ತೇವಾಂಶ',
      'soil_type': 'ಮಣ್ಣಿನ ಪ್ರಕಾರ',
      'iwcpe': 'IW:CPE',
      'count': 'ಎಣಿಕೆ',
      'weed_mgmt': 'ಕಳೆ ನಿಯಂತ್ರಣ',
      'mono_weeds': 'ಏಕಬೀಜ ಕಳೆಗಳು (ಫ್ಯಾಲರಿಸ್, ಕಾಡು ಓಟ್ಸ್)',
      'harvest': 'ಕಟಾವು ಮತ್ತು ಥ್ರೆಶಿಂಗ್',
      'rotation': 'ಬೆಳೆ ಪರಿವರ್ತನೆ',
      'rotation_desc': 'ಗೋಧಿಯನ್ನು ಸಾಮಾನ್ಯವಾಗಿ ಖರೀಫ್ ಬೆಳೆಗಳ ನಂತರ ಬೆಳೆಯಲಾಗುತ್ತದೆ.',
      'rotation_note': 'ಸೂಚನೆ: ಕೆಲವು ಪ್ರದೇಶಗಳಲ್ಲಿ ಮೂರನೇ "ಕ್ಯಾಚ್ ಬೆಳೆ" ಬೆಳೆಯಲಾಗುತ್ತದೆ.',
      'maturity': 'ಪಕ್ವತೆ',
      'moisture_harvest': 'ತೇವಾಂಶ',
      'caution': 'ಎಚ್ಚರಿಕೆ',
      'manual_tip': 'ಕೈಪಿಡಿ ಸೂಚನೆ: ಥ್ರೆಶಿಂಗ್ ಮೊದಲು 3–4 ದಿನ ಒಣಗಿಸಿ.',
      'cri_stage': 'CRI ಹಂತ (20–25 DAS)',
      'cri_desc': 'ನೀರು ಬಲವಾದ ಬೇರುಗಳು & ಹೆಚ್ಚು ಚಿಗುರುಗಳಿಗೆ ಸಹಾಯ ಮಾಡುತ್ತದೆ.',
      'jointing_stage': 'ಜೋಡಿಸುವ ಹಂತ',
      'jointing_desc': 'ಸಸ್ಯ ಎತ್ತರ ಮತ್ತು ಬಲವಾಗಿ ಬೆಳೆಯಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.',
      'flowering_stage': 'ಹೂಬಿಡುವ ಹಂತ',
      'flowering_desc': 'ಹೆಚ್ಚು ಧಾನ್ಯಗಳನ್ನು ಖಚಿತಪಡಿಸುತ್ತದೆ.',
      'milk_stage': 'ಹಾಲು ಹಂತ',
      'milk_desc': 'ಭಾರವಾದ ಧಾನ್ಯಗಳಿಗೆ ಸರಿಯಾದ ತುಂಬುವಿಕೆ.',
      'hand_weeding_1': 'ಮೊದಲ ಕೈ ಕಳೆ ತೆಗೆಯುವಿಕೆ',
      'hand_weeding_2': 'ಎರಡನೇ ಕೈ ಕಳೆ ತೆಗೆಯುವಿಕೆ',
      'day_20_25': 'ದಿನ 20–25',
      'plus_2_weeks': '+2 ವಾರಗಳು',
      'type': 'ಪ್ರಕಾರ',
      'chemical': 'ರಾಸಾಯನಿಕ',
      'rate_time': 'ದರ/ಸಮಯ',
      'dicots': 'ದ್ವಿಬೀಜಪತ್ರಗಳು',
      'monocots': 'ಏಕಬೀಜಪತ್ರಗಳು',
      'pre_em': 'ಪ್ರಿ-ಎಮ್',
      'isoproturon': 'ಐಸೊಪ್ರೊಟ್ಯೂರಾನ್',
      'pendimethalin': 'ಪೆಂಡಿಮೆಥಾಲಿನ್',
      'early': 'ಆರಂಭಿಕ',
      'maturity_desc': 'ಹಳದಿ/ಒಣ ಹುಲ್ಲು, ಗಟ್ಟಿ ಧಾನ್ಯಗಳು.',
      'moisture_desc': 'ಆದರ್ಶ ತೇವಾಂಶ: 20–25%.',
      'caution_desc': 'ಅತಿಯಾಗಿ ಪಕ್ವವಾಗುವುದು ಚೆಲ್ಲುವಿಕೆಗೆ ಕಾರಣವಾಗುತ್ತದೆ.',
      'rice': 'ಅಕ್ಕಿ',
      'maize': 'ಮೆಕ್ಕೆಜೋಳ',
      'sorghum': 'ಜೋಳ',
      'millet': 'ರಾಗಿ',
      'mungbean': 'ಹೆಸರುಕಾಳು',
      'pigeonpea': 'ತೊಗರಿ',
      'cotton': 'ಹತ್ತಿ',
    },
    'mr': {
      'title': 'सिंचन व पीक व्यवस्थापन',
      'subtitle': 'गहू सिंचनास चांगला प्रतिसाद देतो. निरोगी पिकासाठी 4–6 पाणी आवश्यक.',
      'critical_stages': 'महत्त्वाच्या सिंचन अवस्था',
      'tech_guidelines': 'तांत्रिक मार्गदर्शक',
      'moisture': 'आर्द्रता',
      'soil_type': 'मातीचा प्रकार',
      'iwcpe': 'IW:CPE',
      'count': 'संख्या',
      'weed_mgmt': 'तण व्यवस्थापन',
      'mono_weeds': 'एकबीजपत्री तण (फॅलेरिस, जंगली ओट्स)',
      'harvest': 'कापणी व मळणी',
      'rotation': 'पीक फेरबदल',
      'rotation_desc': 'गहू सामान्यतः खरीप पिकांनंतर घेतला जातो.',
      'rotation_note': 'टीप: काही भागात तिसरे "कॅच पीक" घेतले जाते.',
      'maturity': 'परिपक्वता',
      'moisture_harvest': 'आर्द्रता',
      'caution': 'सावधगिरी',
      'manual_tip': 'मॅन्युअल टीप: मळणीपूर्वी 3–4 दिवस वाळवा.',
      'cri_stage': 'CRI अवस्था (20–25 DAS)',
      'cri_desc': 'पाणी मजबूत मुळे आणि अधिक फांद्यांना मदत करते.',
      'jointing_stage': 'गाठ येण्याची अवस्था',
      'jointing_desc': 'रोप उंच आणि मजबूत होण्यास मदत करते.',
      'flowering_stage': 'फुलोरा येण्याची अवस्था',
      'flowering_desc': 'अधिक दाण्यांची संख्या सुनिश्चित करते.',
      'milk_stage': 'दूध अवस्था',
      'milk_desc': 'जड दाण्यांसाठी योग्य भरण.',
      'hand_weeding_1': 'पहिले हाताने तण काढणे',
      'hand_weeding_2': 'दुसरे हाताने तण काढणे',
      'day_20_25': 'दिवस 20–25',
      'plus_2_weeks': '+2 आठवडे',
      'type': 'प्रकार',
      'chemical': 'रसायन',
      'rate_time': 'दर/वेळ',
      'dicots': 'द्विबीजपत्री',
      'monocots': 'एकबीजपत्री',
      'pre_em': 'प्री-इम',
      'isoproturon': 'आयसोप्रोट्यूरॉन',
      'pendimethalin': 'पेंडिमेथालिन',
      'early': 'लवकर',
      'maturity_desc': 'पिवळा/कोरडा पेंढा, कठीण दाणे.',
      'moisture_desc': 'आदर्श आर्द्रता: 20–25%.',
      'caution_desc': 'जास्त पिकल्याने दाणे गळतात.',
      'rice': 'तांदूळ',
      'maize': 'मका',
      'sorghum': 'ज्वारी',
      'millet': 'बाजरी',
      'mungbean': 'मूग',
      'pigeonpea': 'तूर',
      'cotton': 'कापूस',
    },
    'pa': {
      'title': 'ਸਿੰਚਾਈ ਅਤੇ ਫਸਲ ਸੰਭਾਲ',
      'subtitle':
          'ਕਣਕ ਸਿੰਚਾਈ ਨੂੰ ਚੰਗੀ ਤਰ੍ਹਾਂ ਸਹਾਰਦੀ ਹੈ। ਤੰਦਰੁਸਤ ਫਸਲ ਲਈ 4–6 ਸਿੰਚਾਈਆਂ ਲੋੜੀਂਦੀਆਂ ਹਨ।',
      'critical_stages': 'ਮਹੱਤਵਪੂਰਨ ਸਿੰਚਾਈ ਪੜਾਅ',
      'tech_guidelines': 'ਤਕਨੀਕੀ ਦਿਸ਼ਾ-ਨਿਰਦੇਸ਼',
      'moisture': 'ਨਮੀ',
      'soil_type': 'ਮਿੱਟੀ ਦੀ ਕਿਸਮ',
      'iwcpe': 'IW:CPE',
      'count': 'ਗਿਣਤੀ',
      'weed_mgmt': 'ਖਰਪਤਵਾਰ ਪ੍ਰਬੰਧਨ',
      'mono_weeds': 'ਇੱਕਬੀਜੀ ਖਰਪਤਵਾਰ (ਫੈਲੈਰਿਸ, ਜੰਗਲੀ ਜੌ)',
      'harvest': 'ਕਟਾਈ ਅਤੇ ਮੜਾਈ',
      'rotation': 'ਫਸਲ ਚੱਕਰ',
      'rotation_desc': 'ਕਣਕ ਆਮ ਤੌਰ \'ਤੇ ਖਰੀਫ ਫਸਲਾਂ ਤੋਂ ਬਾਅਦ ਉਗਾਈ ਜਾਂਦੀ ਹੈ।',
      'rotation_note': 'ਨੋਟ: ਕੁਝ ਖੇਤਰਾਂ ਵਿੱਚ ਤੀਜੀ "ਕੈਚ ਫਸਲ" ਵੀ ਲਈ ਜਾਂਦੀ ਹੈ।',
      'maturity': 'ਪਕਾਵਟ',
      'moisture_harvest': 'ਨਮੀ',
      'caution': 'ਸਾਵਧਾਨੀ',
      'manual_tip': 'ਮੈਨੂਅਲ ਟਿਪ: ਮੜਾਈ ਤੋਂ ਪਹਿਲਾਂ 3–4 ਦਿਨ ਸੁਕਾਓ।',
      'cri_stage': 'CRI ਪੜਾਅ (20–25 DAS)',
      'cri_desc': 'ਪਾਣੀ ਮਜਬੂਤ ਜੜ੍ਹਾਂ ਅਤੇ ਵਧੇਰੇ ਕਲ੍ਹਿਆਂ ਵਿੱਚ ਮਦਦ ਕਰਦਾ ਹੈ।',
      'jointing_stage': 'ਗੰਢ ਬਣਨ ਦਾ ਪੜਾਅ',
      'jointing_desc': 'ਪੌਦੇ ਨੂੰ ਉੱਚਾ ਅਤੇ ਮਜਬੂਤ ਬਣਾਉਣ ਵਿੱਚ ਮਦਦ ਕਰਦਾ ਹੈ।',
      'flowering_stage': 'ਫੁੱਲ ਆਉਣ ਦਾ ਪੜਾਅ',
      'flowering_desc': 'ਵਧੇਰੇ ਦਾਣਿਆਂ ਦੀ ਸੰਖਿਆ ਯਕੀਨੀ ਬਣਾਉਂਦਾ ਹੈ।',
      'milk_stage': 'ਦੁੱਧ ਪੜਾਅ',
      'milk_desc': 'ਭਾਰੀ ਦਾਣਿਆਂ ਲਈ ਸਹੀ ਭਰਾਈ।',
      'hand_weeding_1': 'ਪਹਿਲੀ ਹੱਥੀਂ ਨਿਰਾਈ',
      'hand_weeding_2': 'ਦੂਜੀ ਹੱਥੀਂ ਨਿਰਾਈ',
      'day_20_25': 'ਦਿਨ 20–25',
      'plus_2_weeks': '+2 ਹਫ਼ਤੇ',
      'type': 'ਕਿਸਮ',
      'chemical': 'ਰਸਾਇਣ',
      'rate_time': 'ਦਰ/ਸਮਾਂ',
      'dicots': 'ਦੋਬੀਜੀ',
      'monocots': 'ਇੱਕਬੀਜੀ',
      'pre_em': 'ਪ੍ਰੀ-ਇਮ',
      'isoproturon': 'ਆਈਸੋਪ੍ਰੋਟਯੂਰੋਨ',
      'pendimethalin': 'ਪੈਂਡੀਮੈਥਾਲਿਨ',
      'early': 'ਸ਼ੁਰੂਆਤੀ',
      'maturity_desc': 'ਪੀਲਾ/ਸੁੱਕਾ ਤੂੜੀ, ਸਖ਼ਤ ਦਾਣੇ।',
      'moisture_desc': 'ਆਦਰਸ਼ ਨਮੀ: 20–25%।',
      'caution_desc': 'ਜ਼ਿਆਦਾ ਪੱਕਣ ਨਾਲ ਦਾਣੇ ਝੜਦੇ ਹਨ।',
      'rice': 'ਚਾਵਲ',
      'maize': 'ਮੱਕੀ',
      'sorghum': 'ਜੁਆਰ',
      'millet': 'ਬਾਜਰਾ',
      'mungbean': 'ਮੂੰਗ',
      'pigeonpea': 'ਅਰਹਰ',
      'cotton': 'ਕਪਾਹ',
    },
    'ur': {
      'title': 'آبپاشی اور فصل کی دیکھ بھال',
      'subtitle':
          'گندم آبپاشی پر اچھی طرح ردعمل دیتی ہے۔ صحت مند فصل کے لیے 4–6 پانی ضروری ہیں۔',
      'critical_stages': 'اہم آبپاشی مراحل',
      'tech_guidelines': 'تکنیکی رہنما اصول',
      'moisture': 'نمی',
      'soil_type': 'مٹی کی قسم',
      'iwcpe': 'IW:CPE',
      'count': 'تعداد',
      'weed_mgmt': 'جڑی بوٹیوں کا کنٹرول',
      'mono_weeds': 'ایک بیج جڑی بوٹیاں (فالارس، جنگلی جئی)',
      'harvest': 'کٹائی اور گہائی',
      'rotation': 'فصلوں کی گردش',
      'rotation_desc': 'گندم عام طور پر خریف فصلوں کے بعد کاشت کی جاتی ہے۔',
      'rotation_note': 'نوٹ: بعض علاقوں میں تیسری "کیچ فصل" بھی اگائی جاتی ہے۔',
      'maturity': 'پختگی',
      'moisture_harvest': 'نمی',
      'caution': 'احتیاط',
      'manual_tip': 'مینول ٹپ: گہائی سے پہلے 3–4 دن خشک کریں۔',
      'cri_stage': 'CRI مرحلہ (20–25 DAS)',
      'cri_desc': 'پانی مضبوط جڑوں اور زیادہ شاخوں میں مدد کرتا ہے۔',
      'jointing_stage': 'گانٹھ بننے کا مرحلہ',
      'jointing_desc': 'پودے کو لمبا اور مضبوط بنانے میں مدد کرتا ہے۔',
      'flowering_stage': 'پھول آنے کا مرحلہ',
      'flowering_desc': 'زیادہ دانوں کی تعداد یقینی بناتا ہے۔',
      'milk_stage': 'دودھ مرحلہ',
      'milk_desc': 'بھاری دانوں کے لیے مناسب بھرائی۔',
      'hand_weeding_1': 'پہلی ہاتھ سے گوڑائی',
      'hand_weeding_2': 'دوسری ہاتھ سے گوڑائی',
      'day_20_25': 'دن 20–25',
      'plus_2_weeks': '+2 ہفتے',
      'type': 'قسم',
      'chemical': 'کیمیکل',
      'rate_time': 'شرح/وقت',
      'dicots': 'دو بیجی',
      'monocots': 'ایک بیجی',
      'pre_em': 'پری-ایم',
      'isoproturon': 'آئیسوپروٹیورون',
      'pendimethalin': 'پینڈیمیتھالین',
      'early': 'ابتدائی',
      'maturity_desc': 'پیلا/خشک بھوسہ، سخت دانے۔',
      'moisture_desc': 'مثالی نمی: 20–25%۔',
      'caution_desc': 'زیادہ پکنے سے دانے گرتے ہیں۔',
      'rice': 'چاول',
      'maize': 'مکئی',
      'sorghum': 'جوار',
      'millet': 'باجرہ',
      'mungbean': 'مونگ',
      'pigeonpea': 'ارહર',
      'cotton': 'કપاس',
    },
    'gu': {
      'title': 'સિંચાઈ અને પાક સંભાળ',
      'subtitle': 'ઘઉં સિંચાઈને સારો પ્રતિસાદ આપે છે. સ્વસ્થ પાક માટે 4–6 પાણી જરૂરી છે.',
      'critical_stages': 'મહત્વપૂર્ણ સિંચાઈ તબક્કાઓ',
      'tech_guidelines': 'તકનીકી માર્ગદર્શિકા',
      'moisture': 'ભેજ',
      'soil_type': 'માટીનો પ્રકાર',
      'iwcpe': 'IW:CPE',
      'count': 'સંખ્યા',
      'weed_mgmt': 'નીંદણ વ્યવસ્થાપન',
      'mono_weeds': 'એકબીજ નીંદણ (ફલારિસ, જંગલી ઓટ્સ)',
      'harvest': 'કાપણી અને મસણી',
      'rotation': 'પાક ફેરબદલ',
      'rotation_desc': 'ઘઉં સામાન્ય રીતે ખરીફ પાક પછી ઉગાડવામાં આવે છે.',
      'rotation_note': 'નોંધ: કેટલાક વિસ્તારોમાં ત્રીજો "કેચ પાક" પણ ઉગાડવામાં આવે છે.',
      'maturity': 'પરિપક્વતા',
      'moisture_harvest': 'ભેજ',
      'caution': 'સાવધાની',
      'manual_tip': 'મેન્યુઅલ ટિપ: મસણી પહેલાં 3–4 દિવસ સૂકવો.',
      'cri_stage': 'CRI તબક્કો (20–25 DAS)',
      'cri_desc': 'પાણી મજબૂત મૂળ અને વધુ ડાળીઓમાં મદદ કરે છે.',
      'jointing_stage': 'ગાંઠ બનવાનો તબક્કો',
      'jointing_desc': 'છોડને ઊંચો અને મજબૂત બનાવવામાં મદદ કરે છે.',
      'flowering_stage': 'ફૂલોનો તબક્કો',
      'flowering_desc': 'વધુ દાણાની સંખ્યા સુનિશ્ચિત કરે છે.',
      'milk_stage': 'દૂધ તબક્કો',
      'milk_desc': 'ભારે દાણા માટે યોગ્ય ભરણ.',
      'hand_weeding_1': 'પ્રથમ હાથથી નીંદણ',
      'hand_weeding_2': 'બીજું હાથથી નીંદણ',
      'day_20_25': 'દિવસ 20–25',
      'plus_2_weeks': '+2 અઠવાડિયા',
      'type': 'પ્રકાર',
      'chemical': 'રસાયણ',
      'rate_time': 'દર/સમય',
      'dicots': 'દ્વિબીજપત્રી',
      'monocots': 'એકબીજપત્રી',
      'pre_em': 'પ્રી-એમ',
      'isoproturon': 'આઇસોપ્રોટ્યુરોન',
      'pendimethalin': 'પેન્ડિમેથાલિન',
      'early': 'પ્રારંભિક',
      'maturity_desc': 'પીળો/સૂકો પરાળ, કઠણ દાણા.',
      'moisture_desc': 'આદર્શ ભેજ: 20–25%.',
      'caution_desc': 'વધુ પાકવાથી દાણા ખરે છે.',
      'rice': 'ચોખા',
      'maize': 'મકાઈ',
      'sorghum': 'જુવાર',
      'millet': 'બાજરી',
      'mungbean': 'મગ',
      'pigeonpea': 'તુવેર',
      'cotton': 'કપાસ',
    },
    'bn': {
      'title': 'সেচ ও ফসল পরিচর্যা',
      'subtitle': 'গম সেচে ভালো সাড়া দেয়। সুস্থ ফসলের জন্য 4–6 বার সেচ প্রয়োজন।',
      'critical_stages': 'গুরুত্বপূর্ণ সেচের পর্যায়',
      'tech_guidelines': 'প্রযুক্তিগত নির্দেশিকা',
      'moisture': 'আর্দ্রতা',
      'soil_type': 'মাটির ধরন',
      'iwcpe': 'IW:CPE',
      'count': 'সংখ্যা',
      'weed_mgmt': 'আগাছা ব্যবস্থাপনা',
      'mono_weeds': 'এক বীজপত্রী আগাছা (ফালারিস, বন্য ওট)',
      'harvest': 'ফসল কাটা ও মাড়াই',
      'rotation': 'ফসল আবর্তন',
      'rotation_desc': 'গম সাধারণত খরিফ ফসলের পরে চাষ করা হয়।',
      'rotation_note': 'নোট: কিছু অঞ্চলে তৃতীয় "ক্যাচ ফসল" চাষ করা হয়।',
      'maturity': 'পরিপক্বতা',
      'moisture_harvest': 'আর্দ্রতা',
      'caution': 'সতর্কতা',
      'manual_tip': 'ম্যানুয়াল টিপ: মাড়াইয়ের আগে 3–4 দিন শুকান।',
      'cri_stage': 'CRI পর্যায় (20–25 DAS)',
      'cri_desc': 'পানি শক্তিশালী শিকড় ও বেশি কুশি তৈরিতে সাহায্য করে।',
      'jointing_stage': 'গিঁট তৈরির পর্যায়',
      'jointing_desc': 'গাছকে লম্বা ও শক্তিশালী হতে সাহায্য করে।',
      'flowering_stage': 'ফুল আসার পর্যায়',
      'flowering_desc': 'বেশি দানার সংখ্যা নিশ্চিত করে।',
      'milk_stage': 'দুধ পর্যায়',
      'milk_desc': 'ভারী দানার জন্য সঠিক ভরাট।',
      'hand_weeding_1': 'প্রথম হাতে আগাছা তোলা',
      'hand_weeding_2': 'দ্বিতীয় হাতে আগাছা তোলা',
      'day_20_25': 'দিন 20–25',
      'plus_2_weeks': '+2 সপ্তাহ',
      'type': 'ধরন',
      'chemical': 'রাসায়নিক',
      'rate_time': 'হার/সময়',
      'dicots': 'দ্বিবীজপত্রী',
      'monocots': 'এক বীজপত্রী',
      'pre_em': 'প্রি-এম',
      'isoproturon': 'আইসোপ্রোটিউরন',
      'pendimethalin': 'পেন্ডিমেথালিন',
      'early': 'প্রারম্ভিক',
      'maturity_desc': 'হলুদ/শুকনো খড়, শক্ত দানা।',
      'moisture_desc': 'আদর্শ আর্দ্রতা: 20–25%।',
      'caution_desc': 'অতিরিক্ত পাকলে দানা ঝরে যায়।',
      'rice': 'ধান',
      'maize': 'ভুট্টা',
      'sorghum': 'জোয়ার',
      'millet': 'বাজরা',
      'mungbean': 'মুগ',
      'pigeonpea': 'অড়হর',
      'cotton': 'তুলা',
    },
    'ml': {
      'title': 'ജലസേചനവും വിള പരിപാലനവും',
      'subtitle': 'ഗോതമ്പ് ജലസേചനത്തോട് നന്നായി പ്രതികരിക്കുന്നു. ആരോഗ്യമുള്ള വിളയ്ക്ക് 4–6 ജലസേചനം ആവശ്യമാണ്.',
      'critical_stages': 'നിർണായക ജലസേചന ഘട്ടങ്ങൾ',
      'tech_guidelines': 'സാങ്കേതിക മാർഗ്ഗനിർദ്ദേശങ്ങൾ',
      'moisture': 'ഈർപ്പം',
      'soil_type': 'മണ്ണിന്റെ തരം',
      'iwcpe': 'IW:CPE',
      'count': 'എണ്ണം',
      'weed_mgmt': 'കളനിയന്ത്രണം',
      'mono_weeds': 'ഏകബീജപത്ര കളകൾ (ഫാലാരിസ്, കാട്ടു ഓട്സ്)',
      'harvest': 'വിളവെടുപ്പും മെതിയും',
      'rotation': 'വിള മാറ്റം',
      'rotation_desc': 'ഗോതമ്പ് സാധാരണയായി ഖരീഫ് വിളകൾക്ക് ശേഷം കൃഷി ചെയ്യുന്നു.',
      'rotation_note': 'കുറിപ്പ്: ചില പ്രദേശങ്ങളിൽ മൂന്നാമത്തെ "ക്യാച്ച് വിള" കൃഷി ചെയ്യുന്നു.',
      'maturity': 'പാകത',
      'moisture_harvest': 'ഈർപ്പം',
      'caution': 'മുന്നറിയിപ്പ്',
      'manual_tip': 'മാനുവൽ ടിപ്പ്: മെതിക്കുന്നതിന് മുമ്പ് 3–4 ദിവസം ഉണക്കുക.',
      'cri_stage': 'CRI ഘട്ടം (20–25 DAS)',
      'cri_desc': 'വെള്ളം ശക്തമായ വേരുകൾക്കും കൂടുതൽ കൊമ്പുകൾക്കും സഹായിക്കുന്നു.',
      'jointing_stage': 'ഗ്രന്ഥി രൂപീകരണ ഘട്ടം',
      'jointing_desc': 'ചെടി ഉയരത്തിലും ശക്തിയിലും വളരാൻ സഹായിക്കുന്നു.',
      'flowering_stage': 'പൂവിടൽ ഘട്ടം',
      'flowering_desc': 'കൂടുതൽ ധാന്യങ്ങൾ ഉറപ്പാക്കുന്നു.',
      'milk_stage': 'പാൽ ഘട്ടം',
      'milk_desc': 'ഭാരമുള്ള ധാന്യങ്ങൾക്കായി ശരിയായ നിറയ്ക്കൽ.',
      'hand_weeding_1': 'ആദ്യത്തെ കൈകൊണ്ട് കളപറിക്കൽ',
      'hand_weeding_2': 'രണ്ടാമത്തെ കൈകൊണ്ട് കളപറിക്കൽ',
      'day_20_25': 'ദിവസം 20–25',
      'plus_2_weeks': '+2 ആഴ്ചകൾ',
      'type': 'തരം',
      'chemical': 'രാസവസ്തു',
      'rate_time': 'നിരക്ക്/സമയം',
      'dicots': 'ദ്വിബീജപത്രം',
      'monocots': 'ഏകബീജപത്രം',
      'pre_em': 'പ്രീ-എം',
      'isoproturon': 'ഐസോപ്രോട്യൂറോൺ',
      'pendimethalin': 'പെൻഡിമെതാലിൻ',
      'early': 'ആദ്യകാലം',
      'maturity_desc': 'മഞ്ഞ/ഉണങ്ങിയ വൈക്കോൽ, കഠിനമായ ധാന്യങ്ങൾ.',
      'moisture_desc': 'അനുയോജ്യമായ ഈർപ്പം: 20–25%.',
      'caution_desc': 'അമിതമായി പാകമാകുന്നത് ധാന്യങ്ങൾ കൊഴിയുന്നതിന് കാരണമാകുന്നു.',
      'rice': 'നെല്ല്',
      'maize': 'ചോളം',
      'sorghum': 'ചോളം',
      'millet': 'തിന',
      'mungbean': 'ചെറുപയർ',
      'pigeonpea': 'തുവര',
      'cotton': 'പരുത്തി',
    },
  };

  String _t(String key) => _texts[locale]?[key] ?? _texts['en']![key]!;

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    const Color wheatOrange = Color(0xFFFFA000);
    const Color weedGreen = Color(0xFF4CAF50);

    return LayoutBuilder(
      key: const ValueKey('step6_layout_builder'),
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * 0.5;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Image
              Container(
                width: double.infinity,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/step6.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.water_drop,
                        size: 40,
                        color: primaryBlue.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _t('title'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

              // 2. CRITICAL IRRIGATION TIMELINE
              Text(
                _t('critical_stages'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailedTimeline(primaryBlue),

              const SizedBox(height: 12),
              _buildImprovedTechnicalGrid(primaryBlue),

              const SizedBox(height: 35),

              // 3. WEED MANAGEMENT
              _buildSectionHeader(_t('weed_mgmt'), Icons.eco, weedGreen),
              const SizedBox(height: 12),
              _buildWeedControlDashboard(weedGreen),
              const SizedBox(height: 12),
              _buildHerbicideTable(),

              const SizedBox(height: 35),

              // 4. HARVESTING & THRESHING
              _buildSectionHeader(
                _t('harvest'),
                Icons.agriculture,
                wheatOrange,
              ),
              const SizedBox(height: 16),
              _buildImprovedHarvestCard(wheatOrange),

              const SizedBox(height: 35),

              // 5. CROPPING SYSTEMS
              _buildSectionHeader(
                _t('rotation'),
                Icons.sync,
                Colors.teal,
              ),
              const SizedBox(height: 12),
              Text(
                _t('rotation_desc'),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _buildRotationChips(),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _t('rotation_note'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // --- 1. IMPROVED TECHNICAL GRID ---
  Widget _buildImprovedTechnicalGrid(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('tech_guidelines'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: [
              _gridItem(
                _t('moisture'),
                "40-50% Depletion",
                Icons.water_drop,
                color,
              ),
              _gridItem(_t('soil_type'), "Clay Loam (80%)", Icons.landscape, color),
              _gridItem(_t('iwcpe'), "0.7 – 0.9 Ratio", Icons.analytics, color),
              _gridItem(_t('count'), "4–6 Waterings", Icons.repeat, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridItem(String label, String val, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              Text(
                val,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. IMPROVED HARVEST CARD ---
  Widget _buildImprovedHarvestCard(Color color) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _harvestInfoRow(
                  Icons.check_circle,
                  _t('maturity'),
                  _t('maturity_desc'),
                  color,
                ),
                const SizedBox(height: 12),
                _harvestInfoRow(
                  Icons.speed,
                  _t('moisture_harvest'),
                  _t('moisture_desc'),
                  color,
                ),
                const SizedBox(height: 12),
                _harvestInfoRow(
                  Icons.report_problem,
                  _t('caution'),
                  _t('caution_desc'),
                  color,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: color.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.lightbulb, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t('manual_tip'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _harvestInfoRow(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- OTHER COMPONENTS (IRRIGATION, WEEDS, ROTATION) ---

  Widget _buildDetailedTimeline(Color color) {
    final stages = [
      {
        "title": _t('cri_stage'),
        "desc": _t('cri_desc'),
        "icon": Icons.star,
        "isCritical": true,
      },
      {
        "title": _t('jointing_stage'),
        "desc": _t('jointing_desc'),
        "icon": Icons.straighten,
      },
      {
        "title": _t('flowering_stage'),
        "desc": _t('flowering_desc'),
        "icon": Icons.local_florist,
      },
      {
        "title": _t('milk_stage'),
        "desc": _t('milk_desc'),
        "icon": Icons.fitness_center,
      },
    ];

    return Column(
      children: stages.map((s) {
        int index = stages.indexOf(s);
        bool isCrit = s['isCritical'] == true;
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Icon(
                    s['icon'] as IconData,
                    color: isCrit ? Colors.red : color,
                    size: 20,
                  ),
                  if (index != stages.length - 1)
                    Expanded(
                      child: Container(width: 2, color: Colors.grey.shade300),
                    ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCrit ? Colors.red.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['desc'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeedControlDashboard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('mono_weeds'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Divider(height: 20),
          Row(
            children: [
              _metric(_t('hand_weeding_1'), _t('day_20_25')),
              const SizedBox(width: 10),
              _metric(_t('hand_weeding_2'), _t('plus_2_weeks')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHerbicideTable() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.3),
        },
        children: [
          _row([_t('type'), _t('chemical'), _t('rate_time')], isHeader: true),
          _row([_t('dicots'), "2,4-D (EE)", "0.3kg/ha"]),
          _row([_t('monocots'), _t('isoproturon'), "1.0kg/ha"]),
          _row([_t('pre_em'), _t('pendimethalin'), _t('early')]),
        ],
      ),
    );
  }

  Widget _buildRotationChips() {
    final crops = [
      _t('rice'),
      _t('maize'),
      _t('sorghum'),
      _t('millet'),
      _t('mungbean'),
      _t('pigeonpea'),
      _t('cotton'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: crops
          .map(
            (c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 11)),
              backgroundColor: Colors.teal.withOpacity(0.05),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _metric(String title, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            Text(
              val,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _row(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      children: cells
          .map(
            (c) => Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                c,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
