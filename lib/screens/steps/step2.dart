import 'package:flutter/material.dart';

class Step2Content extends StatelessWidget {
  final String locale; // Added locale parameter

  const Step2Content({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);
    final double imageHeight = MediaQuery.of(context).size.height / 4;
    final double minContentHeight = MediaQuery.of(context).size.height - 200;

    // --- LOCALIZATION DATA ---
    final Map<String, Map<String, String>> _texts = {
      'en': {
        'title': "Climate & Resilience",
        'subtitle':
            "Wheat is a hardy crop, but its yield depends heavily on temperature and light.",
        'section1': "Cold Tolerance",
        't1': "Germination Power",
        's1': "Seeds sprout at 4°C+",
        'd1':
            "Growth properly accelerates once temperatures rise above 5°C with sunlight.",
        't2': "Spring vs Winter Wheat",
        's2': "Survival: -9.4°C to -31.6°C",
        'd2':
            "Winter varieties are exceptionally tough, surviving extreme freezing temperatures.",
        'section2': "The Hardening Process",
        'h_desc':
            "As wheat grows in cool conditions, it builds internal strength to survive freezing:",
        'chip1': "Higher Sugar",
        'chip2': "More Nitrogen",
        'chip3': "Dry Matter",
        'h_footer':
            "This process reduces water in leaves and holds it tightly within cells so ice cannot damage the plant.",
        'section3': "Role of Sunlight",
        'b1':
            "Long-Day Crop: Wheat prefers extended daylight for faster flowering.",
        'b2': "Short Days: Plant focuses more on leaf and tiller growth.",
      },
      'hi': {
        'title': "जलवायु और लचीलापन",
        'subtitle':
            "गेहूं एक मजबूत फसल है, लेकिन इसकी उपज तापमान और प्रकाश पर निर्भर करती है।",
        'section1': "ठंड सहनशीलता",
        't1': "अंकुरण शक्ति",
        's1': "बीज 4°C+ पर अंकुरित होते हैं",
        'd1':
            "सूरज की रोशनी के साथ तापमान 5°C से ऊपर जाने पर विकास तेज होता है।",
        't2': "वसंत बनाम शीतकालीन गेहूं",
        's2': "उत्तरजीविता: -9.4°C से -31.6°C",
        'd2':
            "शीतकालीन किस्में बेहद सख्त होती हैं, जो अत्यधिक ठंड में भी जीवित रहती हैं।",
        'section2': "सख्त होने की प्रक्रिया (Hardening)",
        'h_desc':
            "ठंडी परिस्थितियों में उगते समय, गेहूं जमने से बचने के लिए आंतरिक शक्ति बनाता है:",
        'chip1': "उच्च शर्करा",
        'chip2': "अधिक नाइट्रोजन",
        'chip3': "शुष्क पदार्थ",
        'h_footer':
            "यह प्रक्रिया पत्तियों में पानी कम करती है ताकि बर्फ पौधे को नुकसान न पहुंचा सके।",
        'section3': "सूरज की रोशनी की भूमिका",
        'b1':
            "लंबे दिन की फसल: गेहूं तेजी से फूलने के लिए विस्तारित दिन के उजाले को पसंद करता है।",
        'b2':
            "छोटे दिन: पौधा पत्तियों और टिलर के विकास पर अधिक ध्यान केंद्रित करता है।",
      },
      'ta': {
        'title': "காலநிலை மற்றும் தாங்கும் திறன்",
        'subtitle':
            "கோதுமை ஒரு உறுதியான பயிர், ஆனால் அதன் விளைச்சல் வெப்பநிலை மற்றும் ஒளியைப் பொறுத்தது.",
        'section1': "குளிர் தாங்கும் திறன்",
        't1': "முளைப்புத் திறன்",
        's1': "விதைகள் 4°C+ இல் முளைக்கும்",
        'd1':
            "வெப்பநிலை 5°C க்கு மேல் உயரும்போது வளர்ச்சி துரிதப்படுத்தப்படுகிறது.",
        't2': "வசந்த கால vs குளிர்கால கோதுமை",
        's2': "தாங்குதிறன்: -9.4°C முதல் -31.6°C வரை",
        'd2': "குளிர்கால வகைகள் மிகவும் வலிமையானவை, உறைபனியிலும் உயிர்வாழும்.",
        'section2': "பக்குவப்படுத்தும் முறை",
        'h_desc':
            "குளிர்ந்த நிலையில் வளரும்போது, கோதுமை உறைபனியைத் தாங்க உள் வலிமையை உருவாக்குகிறது:",
        'chip1': "அதிக சர்க்கரை",
        'chip2': "அதிக நைட்ரஜன்",
        'chip3': "உலர் பொருள்",
        'h_footer':
            "இந்த செயல்முறை இலைகளில் உள்ள நீரைக் குறைத்து செடியைப் பாதுகாக்கிறது.",
        'section3': "சூரிய ஒளியின் பங்கு",
        'b1':
            "நீண்ட பகல் பயிர்: கோதுமை வேகமாக பூக்க அதிக பகல் நேரத்தை விரும்புகிறது.",
        'b2':
            "குறுகிய பகல்: செடி இலை மற்றும் தூர் வளர்ச்சியில் அதிக கவனம் செலுத்துகிறது.",
      },
      'te': {
        'title': "వాతావరణం & తట్టుకునే శక్తి",
        'subtitle':
            "గోధుమ గట్టి పంట, కానీ దీని దిగుబడి ఉష్ణోగ్రత మరియు కాంతిపై ఆధారపడి ఉంటుంది.",
        'section1': "చలిని తట్టుకునే శక్తి",
        't1': "మొలకెత్తే శక్తి",
        's1': "విత్తనాలు 4°C+ వద్ద మొలకెత్తుతాయి",
        'd1': "ఉష్ణోగ్రత 5°C కంటే పెరిగినప్పుడు పెరుగుదల వేగవంతం అవుతుంది.",
        't2': "వసంత vs శీతాకాలపు గోధుమ",
        's2': "మనుగడ: -9.4°C నుండి -31.6°C",
        'd2': "శీతాకాలపు రకాలు చాలా గట్టివి, ఇవి విపరీతమైన చలిని తట్టుకోగలవు.",
        'section2': "గట్టిపడే ప్రక్రియ",
        'h_desc':
            "చల్లని పరిస్థితులలో పెరిగేటప్పుడు, గోధుమ అంతర్గత బలాన్ని పెంచుకుంటుంది:",
        'chip1': "ఎక్కువ చక్కెర",
        'chip2': "ఎక్కువ నైట్రోజన్",
        'chip3': "పొడి పదార్థం",
        'h_footer':
            "ఈ ప్రక్రియ ఆకులలో నీటిని తగ్గించి, మంచు వల్ల మొక్క దెబ్బతినకుండా కాపాడుతుంది.",
        'section3': "సూర్యరశ్మి పాత్ర",
        'b1':
            "లాంగ్-డే క్రాప్: వేగంగా పూయడానికి గోధుమ ఎక్కువ పగటి వెలుతురును కోరుకుంటుంది.",
        'b2':
            "షార్ట్ డేస్: మొక్క ఆకులు మరియు పిలకల పెరుగుదలపై దృష్టి పెడుతుంది.",
      },
      'kn': {
        'title': "ಹವಾಮಾನ ಮತ್ತು ಸ್ಥಿತಿಸ್ಥಾಪಕತ್ವ",
        'subtitle':
            "ಗೋಧಿ ಗಟ್ಟಿ ಬೆಳೆ, ಆದರೆ ಇದರ ಇಳುವರಿ ತಾಪಮಾನ ಮತ್ತು ಬೆಳಕಿನ ಮೇಲೆ ಅವಲಂಬಿತವಾಗಿದೆ.",
        'section1': "ಶೀತ ಸಹಿಷ್ಣುತೆ",
        't1': "ಮೊಳಕೆಯೊಡೆಯುವ ಶಕ್ತಿ",
        's1': "ಬೀಜಗಳು 4°C+ ನಲ್ಲಿ ಮೊಳಕೆಯೊಡೆಯುತ್ತವೆ",
        'd1': "ತಾಪಮಾನ 5°C ಕ್ಕಿಂತ ಹೆಚ್ಚಾದಾಗ ಬೆಳವಣಿಗೆ ವೇಗಗೊಳ್ಳುತ್ತದೆ.",
        't2': "ವಸಂತ vs ಚಳಿಗಾಲದ ಗೋಧಿ",
        's2': "ಬದುಕುಳಿಯುವಿಕೆ: -9.4°C ರಿಂದ -31.6°C",
        'd2':
            "ಚಳಿಗಾಲದ ತಳಿಗಳು ಅತ್ಯಂತ ಗಟ್ಟಿಯಾಗಿದ್ದು, ತೀವ್ರ ಚಳಿಯನ್ನು ತಡೆದುಕೊಳ್ಳುತ್ತವೆ.",
        'section2': "ಗಟ್ಟಿಯಾಗುವ ಪ್ರಕ್ರಿಯೆ",
        'h_desc':
            "ತಂಪಾದ ವಾತಾವರಣದಲ್ಲಿ ಬೆಳೆಯುವಾಗ, ಗೋಧಿ ಆಂತರಿಕ ಶಕ್ತಿಯನ್ನು ವೃದ್ಧಿಸಿಕೊಳ್ಳುತ್ತದೆ:",
        'chip1': "ಹೆಚ್ಚಿನ ಸಕ್ಕರೆ",
        'chip2': "ಹೆಚ್ಚಿನ ಸಾರಜನಕ",
        'chip3': "ಒಣ ಪದಾರ್ಥ",
        'h_footer':
            "ಈ ಪ್ರಕ್ರಿಯೆಯು ಎಲೆಗಳಲ್ಲಿನ ನೀರನ್ನು ಕಡಿಮೆ ಮಾಡಿ ಸಸ್ಯವನ್ನು ರಕ್ಷಿಸುತ್ತದೆ.",
        'section3': "ಸೂರ್ಯನ ಬೆಳಕಿನ ಪಾತ್ರ",
        'b1': "ಲಾಂಗ್-ಡೇ ಬೆಳೆ: ವೇಗವಾಗಿ ಹೂಬಿಡಲು ಗೋಧಿಗೆ ಹೆಚ್ಚಿನ ಹಗಲು ಬೆಳಕು ಬೇಕು.",
        'b2':
            "ಶಾರ್ಟ್ ಡೇಸ್: ಸಸ್ಯವು ಎಲೆ ಮತ್ತು ಟಿಲ್ಲರ್ ಬೆಳವಣಿಗೆಯ ಮೇಲೆ ಗಮನ ಹರಿಸುತ್ತದೆ.",
      },
      'mr': {
        'title': "हवामान आणि लवचिकता",
        'subtitle':
            "गहू हे काटक पीक आहे, परंतु त्याचे उत्पादन तापमान आणि प्रकाशावर अवलंबून असते.",
        'section1': "थंडी सहन करण्याची क्षमता",
        't1': "अंकुरण शक्ती",
        's1': "बियाणे 4°C+ वर अंकुरतात",
        'd1': "तापमान 5°C च्या वर गेल्यावर वाढ वेगाने होते.",
        't2': "वसंत ऋतु विरुद्ध हिवाळी गहू",
        's2': "जगण्याची क्षमता: -9.4°C ते -31.6°C",
        'd2': "हिवाळी वाण अत्यंत कठीण असतात, जे गोठवणाऱ्या थंडीतही टिकतात.",
        'section2': "हार्डेनिंग प्रक्रिया",
        'h_desc':
            "थंड परिस्थितीत वाढताना, गहू स्वतःची अंतर्गत ताकद निर्माण करतो:",
        'chip1': "जास्त साखर",
        'chip2': "जास्त नायट्रोजन",
        'chip3': "कोरडे पदार्थ",
        'h_footer':
            "ही प्रक्रिया पानांमधील पाणी कमी करते जेणेकरून बर्फाचा पिकाला त्रास होणार नाही.",
        'section3': "सूर्यप्रकाशाची भूमिका",
        'b1':
            "लाँग-डे क्रॉप: गहू जलद फुलोऱ्यासाठी जास्त सूर्यप्रकाशास प्राधान्य देतो.",
        'b2':
            "शॉर्ट डेज: रोप पाने आणि फुटव्यांच्या वाढीवर जास्त लक्ष केंद्रित करते.",
      },
      'pa': {
        'title': "ਜਲਵਾਯੂ ਅਤੇ ਲਚਕੀਲਾਪਨ",
        'subtitle':
            "ਕਣਕ ਇੱਕ ਸਖ਼ਤ ਫਸਲ ਹੈ, ਪਰ ਇਸਦਾ ਝਾੜ ਤਾਪਮਾਨ ਅਤੇ ਰੌਸ਼ਨੀ 'ਤੇ ਨਿਰਭਰ ਕਰਦਾ ਹੈ।",
        'section1': "ਠੰਢ ਸਹਿਣ ਦੀ ਸ਼ਕਤੀ",
        't1': "ਪੁੰਗਰਨ ਦੀ ਸ਼ਕਤੀ",
        's1': "ਬੀਜ 4°C+ 'ਤੇ ਪੁੰਗਰਦੇ ਹਨ",
        'd1': "ਤਾਪਮਾਨ 5°C ਤੋਂ ਉੱਪਰ ਜਾਣ 'ਤੇ ਵਾਧਾ ਤੇਜ਼ ਹੁੰਦਾ ਹੈ।",
        't2': "ਬਸੰਤ ਬਨਾਮ ਸਰਦੀਆਂ ਵਾਲੀ ਕਣਕ",
        's2': "ਬਚਾਅ: -9.4°C ਤੋਂ -31.6°C",
        'd2':
            "ਸਰਦੀਆਂ ਵਾਲੀਆਂ ਕਿਸਮਾਂ ਬਹੁਤ ਸਖ਼ਤ ਹੁੰਦੀਆਂ ਹਨ, ਜੋ ਬਹੁਤ ਜ਼ਿਆਦਾ ਠੰਢ ਵਿੱਚ ਵੀ ਬਚੀਆਂ ਰਹਿੰਦੀਆਂ ਹਨ।",
        'section2': "ਸਖ਼ਤ ਹੋਣ ਦੀ ਪ੍ਰਕਿਰਿਆ",
        'h_desc': "ਠੰਢੇ ਹਾਲਾਤਾਂ ਵਿੱਚ ਉੱਗਦੇ ਸਮੇਂ, ਕਣਕ ਅੰਦਰੂਨੀ ਤਾਕਤ ਬਣਾਉਂਦੀ ਹੈ:",
        'chip1': "ਵੱਧ ਖੰਡ",
        'chip2': "ਵੱਧ ਨਾਈਟ੍ਰੋਜਨ",
        'chip3': "ਖੁਸ਼ਕ ਪਦਾਰਥ",
        'h_footer':
            "ਇਹ ਪ੍ਰਕਿਰਿਆ ਪੱਤਿਆਂ ਵਿੱਚ ਪਾਣੀ ਨੂੰ ਘਟਾਉਂਦੀ ਹੈ ਤਾਂ ਜੋ ਬਰਫ਼ ਪੌਦੇ ਨੂੰ ਨੁਕਸਾਨ ਨਾ ਪਹੁੰਚਾ ਸਕੇ।",
        'section3': "ਸੂਰਜ ਦੀ ਰੌਸ਼ਨੀ ਦੀ ਭੂਮਿਕਾ",
        'b1':
            "ਲੰਬੇ ਦਿਨ ਦੀ ਫਸਲ: ਕਣਕ ਤੇਜ਼ੀ ਨਾਲ ਫੁੱਲਣ ਲਈ ਜ਼ਿਆਦਾ ਰੌਸ਼ਨੀ ਪਸੰਦ ਕਰਦੀ ਹੈ।",
        'b2': "ਛੋਟੇ ਦਿਨ: ਪੌਦਾ ਪੱਤਿਆਂ ਅਤੇ ਟਿਲਰਾਂ ਦੇ ਵਾਧੇ 'ਤੇ ਧਿਆਨ ਦਿੰਦਾ ਹੈ।",
      },
      'ur': {
        'title': "آب و ہوا اور لچک",
        'subtitle':
            "گندم ایک سخت جان فصل ہے، لیکن اس کی پیداوار کا انحصار درجہ حرارت اور روشنی پر ہوتا ہے۔",
        'section1': "سردی برداشت کرنے کی صلاحیت",
        't1': "اگنے کی طاقت",
        's1': "بیج 4°C+ پر اگتے ہیں",
        'd1': "درجہ حرارت 5°C سے اوپر جانے پر نشوونما تیز ہوتی ہے۔",
        't2': "بہار بمقابلہ سرمائی گندم",
        's2': "بقا: -9.4°C سے -31.6°C",
        'd2':
            "سرمائی اقسام انتہائی سخت ہوتی ہیں، جو شدید سردی میں بھی زندہ رہتی ہیں۔",
        'section2': "سخت ہونے کا عمل",
        'h_desc': "ٹھنڈے حالات میں بڑھتے ہوئے، گندم اندرونی طاقت پیدا کرتی ہے:",
        'chip1': "زیادہ شوگر",
        'chip2': "زیادہ نائٹروجن",
        'chip3': "خشک مادہ",
        'h_footer':
            "یہ عمل پتوں میں پانی کو کم کرتا ہے تاکہ برف پودے کو نقصان نہ پہنچا سکے۔",
        'section3': "سورج کی روشنی کا کردار",
        'b1':
            "لانگ ڈے کراپ: گندم تیزی سے پھولنے کے لیے زیادہ دن کی روشنی کو ترجیح دیتی ہے۔",
        'b2': "شارٹ ڈیز: پودا پتوں اور ٹیلر کی نشوونما پر زیادہ توجہ دیتا ہے۔",
      },
      'gu': {
        'title': "આબોહવા અને સ્થિતિસ્થાપકતા",
        'subtitle':
            "ઘઉં એ સખત પાક છે, પરંતુ તેની ઉપજ તાપમાન અને પ્રકાશ પર આધાર રાખે છે.",
        'section1': "ઠંડી સહન કરવાની શક્તિ",
        't1': "અંકુરણ શક્તિ",
        's1': "બીજ 4°C+ પર અંકુરિત થાય છે",
        'd1': "તાપમાન 5°C થી ઉપર જાય ત્યારે વિકાસ ઝડપી બને છે.",
        't2': "વસંત વિરુદ્ધ શિયાળુ ઘઉં",
        's2': "જીવિત રહેવાની ક્ષમતા: -9.4°C થી -31.6°C",
        'd2': "શિયાળુ જાતો અત્યંત સખત હોય છે, જે અતિશય ઠંડીમાં પણ ટકી રહે છે.",
        'section2': "સખત થવાની પ્રક્રિયા",
        'h_desc': "ઠંડી સ્થિતિમાં ઉગતી વખતે, ઘઉં આંતરિક શક્તિ બનાવે છે:",
        'chip1': "વધુ ખાંડ",
        'chip2': "વધુ નાઇટ્રોજન",
        'chip3': "શુષ્ક પદાર્થ",
        'h_footer':
            "આ પ્રક્રિયા પાંદડામાં પાણી ઘટાડે છે જેથી બરફ છોડને નુકસાન ન કરે.",
        'section3': "સૂર્યપ્રકાશની ભૂમિકા",
        'b1':
            "લાંબા દિવસનો પાક: ઘઉં ઝડપથી ફૂલ આવવા માટે લાંબા દિવસનો પ્રકાશ પસંદ કરે છે.",
        'b2': "ટૂંકા દિવસો: છોડ પાંદડા અને ફણગાના વિકાસ પર વધુ ધ્યાન આપે છે.",
      },
      'bn': {
        'title': "জলবায়ু ও স্থিতিস্থাপকতা",
        'subtitle':
            "গম একটি সহনশীল ফসল, তবে এর ফলন তাপমাত্রা এবং আলোর ওপর অনেকখানি নির্ভর করে।",
        'section1': "শীত সহ্য করার ক্ষমতা",
        't1': "অঙ্কুরোদগম শক্তি",
        's1': "বীজ ৪°C+ তাপমাত্রায় অঙ্কুরিত হয়",
        'd1':
            "সূর্যালোকের সাথে তাপমাত্রা ৫°C-এর উপরে গেলে বৃদ্ধি ত্বরান্বিত হয়।",
        't2': "বসন্ত বনাম শীতকালীন গম",
        's2': "টিকে থাকার ক্ষমতা: -৯.৪°C থেকে -৩১.৬°C",
        'd2': "শীতকালীন জাতগুলো অত্যন্ত শক্ত, যা প্রচণ্ড ঠান্ডাতেও বেঁচে থাকে।",
        'section2': "কঠোর হওয়ার প্রক্রিয়া",
        'h_desc':
            "শীতল অবস্থায় বাড়ার সময়, গম জমে যাওয়া থেকে বাঁচতে অভ্যন্তরীণ শক্তি তৈরি করে:",
        'chip1': "বেশি চিনি",
        'chip2': "বেশি নাইট্রোজেন",
        'chip3': "শুষ্ক পদার্থ",
        'h_footer':
            "এই প্রক্রিয়াটি পাতার জল কমিয়ে দেয় যাতে বরফ গাছের ক্ষতি করতে না পারে।",
        'section3': "সূর্যালোকের ভূমিকা",
        'b1': "লং-ডে ক্রপ: গম দ্রুত ফুল ফোটার জন্য দীর্ঘ দিনের আলো পছন্দ করে।",
        'b2': "শর্ট ডেজ: গাছ পাতা এবং টিলার বৃদ্ধির দিকে বেশি মনোযোগ দেয়।",
      },
      'ml': {
        'title': "കാലാവസ്ഥയും പ്രതിരോധശേഷിയും",
        'subtitle':
            "ഗോതമ്പ് കഠിനമായ ഒരു വിളയാണ്, എന്നാൽ അതിന്റെ വിളവ് താപനിലയെയും പ്രകാശത്തെയും ആശ്രയിച്ചിരിക്കുന്നു.",
        'section1': "ശൈത്യത്തെ അതിജീവിക്കാനുള്ള കഴിവ്",
        't1': "മുളയ്ക്കാനുള്ള ശേഷി",
        's1': "വിത്തുകൾ 4°C+ ൽ മുളയ്ക്കുന്നു",
        'd1': "താപനില 5°C ന് മുകളിൽ ഉയരുമ്പോൾ വളർച്ച വേഗത്തിലാകുന്നു.",
        't2': "വസന്തകാല vs ശൈത്യകാല ഗോതമ്പ്",
        's2': "അതിജീവനം: -9.4°C മുതൽ -31.6°C വരെ",
        'd2': "ശൈത്യകാല ഇനങ്ങൾ അതിശൈത്യത്തെ അതിജീവിക്കാൻ ശേഷിയുള്ളവയാണ്.",
        'section2': "ഹാർഡനിംഗ് പ്രക്രിയ",
        'h_desc':
            "തണുത്ത അവസ്ഥയിൽ വളരുമ്പോൾ, ഗോതമ്പ് ആന്തരിക കരുത്ത് വർദ്ധിപ്പിക്കുന്നു:",
        'chip1': "ഉയർന്ന പഞ്ചസാര",
        'chip2': "കൂടുതൽ നൈട്രജൻ",
        'chip3': "ഡ്രൈ മാറ്റർ",
        'h_footer':
            "ഈ പ്രക്രിയ ഇലകളിലെ ജലാംശം കുറയ്ക്കുകയും ചെടിയെ സംരക്ഷിക്കുകയും ചെയ്യുന്നു.",
        'section3': "സൂര്യപ്രകാശത്തിന്റെ പങ്ക്",
        'b1':
            "ലോംഗ്-ഡേ വിള: വേഗത്തിൽ പൂവിടാൻ ഗോതമ്പിന് കൂടുതൽ പകൽ വെളിച്ചം ആവശ്യമാണ്.",
        'b2':
            "ഷോർട്ട് ഡേയ്‌സ്: ചെടി ഇലകളുടെയും ശാഖകളുടെയും വളർച്ചയിൽ ശ്രദ്ധ കേന്ദ്രീകരിക്കുന്നു.",
      },
    };

    String t(String key) => _texts[locale]?[key] ?? _texts['en']![key]!;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minContentHeight),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/step2.png',
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
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 25),
            Text(
              t('section1'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildConditionCard(
              title: t('t1'),
              subtitle: t('s1'),
              detail: t('d1'),
              icon: Icons.wb_sunny_outlined,
              color: Colors.orange,
            ),
            _buildConditionCard(
              title: t('t2'),
              subtitle: t('s2'),
              detail: t('d2'),
              icon: Icons.ac_unit,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildHardeningSection(primaryPurple, t),
            const SizedBox(height: 30),
            Text(
              t('section3'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _BulletPoint(text: t('b1'), icon: Icons.light_mode),
                  const SizedBox(height: 10),
                  _BulletPoint(text: t('b2'), icon: Icons.eco),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildHardeningSection(Color themeColor, String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('section2'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t('h_desc'),
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HardeningChip(label: t('chip1')),
            _HardeningChip(label: t('chip2')),
            _HardeningChip(label: t('chip3')),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          t('h_footer'),
          style: const TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionCard({
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HardeningChip extends StatelessWidget {
  final String label;
  const _HardeningChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7F3DFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7F3DFF),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final IconData icon;
  const _BulletPoint({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber.shade800),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
