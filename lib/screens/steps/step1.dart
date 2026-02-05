import 'package:flutter/material.dart';

class Step1Content extends StatelessWidget {
  final String locale; // Added locale parameter

  const Step1Content({super.key, this.locale = 'en'});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);

    // --- LOCALIZATION DATA ---
    final Map<String, Map<String, String>> _texts = {
      'en': {
        'main_title': "Common Wheat",
        'chip1': "Bread Wheat",
        'chip2': "Pan-India",
        'desc':
            "This is the most commonly cultivated wheat in India. It is primarily used for making chapatis, bread, and various bakery products.",
        'list_title': "Types of Common Wheat",
        't1': "Hard Red Winter",
        's1': "Commercial favorite. Best for bread making.",
        't2': "Hard Red Spring",
        's2': "Grows in harsh climates. High protein content.",
        't3': "Soft Red Winter",
        's3': "Low protein. Best for cakes and biscuits.",
        't4': "White Wheat",
        's4': "The preferred choice for pasta and noodles.",
      },
      'hi': {
        'main_title': "सामान्य गेहूं",
        'chip1': "ब्रेड गेहूं",
        'chip2': "अखिल भारतीय",
        'desc':
            "यह भारत में सबसे अधिक उगाया जाने वाला गेहूं है। इसका उपयोग मुख्य रूप से चपाती, ब्रेड और विभिन्न बेकरी उत्पाद बनाने के लिए किया जाता है।",
        'list_title': "सामान्य गेहूं के प्रकार",
        't1': "हार्ड रेड विंटर",
        's1': "व्यावसायिक पसंदीदा। ब्रेड बनाने के लिए सबसे अच्छा।",
        't2': "हार्ड रेड स्प्रिंग",
        's2': "कठोर जलवायु में उगता है। उच्च प्रोटीन सामग्री।",
        't3': "सॉफ्ट रेड विंटर",
        's3': "कम प्रोटीन। केक और बिस्कुट के लिए सबसे अच्छा।",
        't4': "सफेद गेहूं",
        's4': "पास्ता और नूडल्स के लिए पसंदीदा विकल्प।",
      },
      'ta': {
        'main_title': "சாதாரண கோதுமை",
        'chip1': "ரொட்டி கோதுமை",
        'chip2': "அகில இந்தியா",
        'desc':
            "இது இந்தியாவில் பொதுவாக பயிரிடப்படும் கோதுமை ஆகும். இது முக்கியமாக சப்பாத்தி, ரொட்டி மற்றும் பல்வேறு பேக்கரி பொருட்கள் தயாரிக்க பயன்படுத்தப்படுகிறது.",
        'list_title': "சாதாரண கோதுமை வகைகள்",
        't1': "ஹார்ட் ரெட் விண்டர்",
        's1': "வணிக ரீதியாக சிறந்தது. ரொட்டி தயாரிக்க ஏற்றது.",
        't2': "ஹார்ட் ரெட் ஸ்பிரிங்",
        's2': "கடுமையான காலநிலையிலும் வளரும். அதிக புரதச்சத்து கொண்டது.",
        't3': "சாஃப்ட் ரெட் விண்டர்",
        's3': "குறைந்த புரதம். கேக் மற்றும் பிஸ்கட்டுகளுக்கு சிறந்தது.",
        't4': "வெள்ளை கோதுமை",
        's4': "பாஸ்தா மற்றும் நூடுல்ஸ் செய்ய விருப்பமான தேர்வு.",
      },
      'te': {
        'main_title': "సాధారణ గోధుమ",
        'chip1': "బ్రెడ్ గోధుమ",
        'chip2': "పాన్-ఇండియా",
        'desc':
            "ఇది భారతదేశంలో సర్వసాధారణంగా సాగు చేయబడే గోధుమ. దీనిని ప్రధానంగా చపాతీలు, రొట్టెలు మరియు వివిధ బేకరీ ఉత్పత్తుల తయారీకి ఉపయోగిస్తారు.",
        'list_title': "సాధారణ గోధుమ రకాలు",
        't1': "హార్డ్ రెడ్ వింటర్",
        's1': "వాణిజ్యపరంగా ఇష్టమైనది. బ్రెడ్ తయారీకి ఉత్తమం.",
        't2': "హార్డ్ రెడ్ స్ప్రింగ్",
        's2': "కఠినమైన వాతావరణంలో పెరుగుతుంది. అధిక ప్రోటీన్ కంటెంట్.",
        't3': "సాఫ్ట్ రెడ్ వింటర్",
        's3': "తక్కువ ప్రోటీన్. కేకులు మరియు బిస్కెట్లకు ఉత్తమం.",
        't4': "తెల్ల గోధుమ",
        's4': "పాస్తా మరియు నూడుల్స్ కోసం ఇష్టపడే ఎంపిక.",
      },
      'kn': {
        'main_title': "ಸಾಮಾನ್ಯ ಗೋಧಿ",
        'chip1': "ಬ್ರೆಡ್ ಗೋಧಿ",
        'chip2': "ಪ್ಯಾನ್-ಇಂಡಿಯಾ",
        'desc':
            "ಇದು ಭಾರತದಲ್ಲಿ ಸಾಮಾನ್ಯವಾಗಿ ಬೆಳೆಯುವ ಗೋಧಿಯಾಗಿದೆ. ಇದನ್ನು ಮುಖ್ಯವಾಗಿ ಚಪಾತಿ, ಬ್ರೆಡ್ ಮತ್ತು ವಿವಿಧ ಬೇಕರಿ ಉತ್ಪನ್ನಗಳನ್ನು ತಯಾರಿಸಲು ಬಳಸಲಾಗುತ್ತದೆ.",
        'list_title': "ಸಾಮಾನ್ಯ ಗೋಧಿಯ ವಿಧಗಳು",
        't1': "ಹಾರ್ಡ್ ರೆಡ್ ವಿಂಟರ್",
        's1': "ವಾಣಿಜ್ಯಿಕವಾಗಿ ಜನಪ್ರಿಯ. ಬ್ರೆಡ್ ತಯಾರಿಕೆಗೆ ಉತ್ತಮ.",
        't2': "ಹಾರ್ಡ್ ರೆಡ್ ಸ್ಪ್ರಿಂಗ್",
        's2': "ಕಠಿಣ ಹವಾಮಾನದಲ್ಲಿ ಬೆಳೆಯುತ್ತದೆ. ಹೆಚ್ಚಿನ ಪ್ರೋಟೀನ್ ಅಂಶ.",
        't3': "ಸಾಫ್ಟ್ ರೆಡ್ ವಿಂಟರ್",
        's3': "ಕಡಿಮೆ ಪ್ರೋಟೀನ್. ಕೇಕ್ ಮತ್ತು ಬಿಸ್ಕತ್ತುಗಳಿಗೆ ಉತ್ತಮ.",
        't4': "ಬಿಳಿ ಗೋಧಿ",
        's4': "ಪಾಸ್ತಾ ಮತ್ತು ನೂಡಲ್ಸ್‌ಗೆ ಆದ್ಯತೆಯ ಆಯ್ಕೆ.",
      },
      'mr': {
        'main_title': "सामान्य गहू",
        'chip1': "ब्रेड गहू",
        'chip2': "अखिल भारतीय",
        'desc':
            "हे भारतातील सर्वात जास्त पिकवले जाणारे गहू आहे. याचा उपयोग प्रामुख्याने चपाती, ब्रेड आणि विविध बेकरी उत्पादने बनवण्यासाठी केला जातो.",
        'list_title': "सामान्य गव्हाचे प्रकार",
        't1': "हार्ड रेड विंटर",
        's1': "व्यावसायिक पसंती. ब्रेड बनवण्यासाठी सर्वोत्तम.",
        't2': "हार्ड रेड स्प्रिंग",
        's2': "कठोर हवामानात वाढते. उच्च प्रथिने सामग्री.",
        't3': "सॉफ्ट रेड विंटर",
        's3': "कमी प्रथिने. केक आणि बिस्किटांसाठी सर्वोत्तम.",
        't4': "पांढरा गहू",
        's4': "पास्ता आणि नूडल्ससाठी पसंतीचा पर्याय.",
      },
      'pa': {
        'main_title': "ਆਮ ਕਣਕ",
        'chip1': "ਬ੍ਰੈੱਡ ਕਣਕ",
        'chip2': "ਆਲ-ਇੰਡੀਆ",
        'desc':
            "ਇਹ ਭਾਰਤ ਵਿੱਚ ਸਭ ਤੋਂ ਵੱਧ ਉਗਾਈ ਜਾਣ ਵਾਲੀ ਕਣਕ ਹੈ। ਇਹ ਮੁੱਖ ਤੌਰ 'ਤੇ ਚਪਾਤੀ, ਬ੍ਰੈੱਡ ਅਤੇ ਬੇਕਰੀ ਉਤਪਾਦਾਂ ਲਈ ਵਰਤੀ ਜਾਂਦੀ ਹੈ।",
        'list_title': "ਆਮ ਕਣਕ ਦੀਆਂ ਕਿਸਮਾਂ",
        't1': "ਹਾਰਡ ਰੈੱਡ ਵਿੰਟਰ",
        's1': "ਵਪਾਰਕ ਪਸੰਦ। ਬ੍ਰੈੱਡ ਬਣਾਉਣ ਲਈ ਸਭ ਤੋਂ ਵਧੀਆ।",
        't2': "ਹਾਰਡ ਰੈੱਡ ਸਪਰਿੰਗ",
        's2': "ਸਖ਼ਤ ਜਲਵਾਯੂ ਵਿੱਚ ਉੱਗਦਾ ਹੈ। ਉੱਚ ਪ੍ਰੋਟੀਨ।",
        't3': "ਸਾਫਟ ਰੈੱਡ ਵਿੰਟਰ",
        's3': "ਘੱਟ ਪ੍ਰੋਟੀਨ। ਕੇਕ ਅਤੇ ਬਿਸਕੁਟਾਂ ਲਈ ਵਧੀਆ।",
        't4': "ਚਿੱਟੀ ਕਣਕ",
        's4': "ਪਾਸਤਾ ਅਤੇ ਨੂਡਲਜ਼ ਲਈ ਪਸੰਦੀਦਾ ਵਿਕਲਪ।",
      },
      'ur': {
        'main_title': "عام گندم",
        'chip1': "بریڈ گندم",
        'chip2': "آل انڈیا",
        'desc':
            "یہ ہندوستان میں سب سے زیادہ کاشت کی جانے والی گندم ہے۔ یہ بنیادی طور پر چپاتی، روٹی اور مختلف بیکری مصنوعات بنانے کے لیے استعمال ہوتی ہے۔",
        'list_title': "عام گندم کی اقسام",
        't1': "ہارڈ ریڈ ونٹر",
        's1': "تجارتی پسندیدہ۔ روٹی بنانے کے لیے بہترین۔",
        't2': "ہارڈ ریڈ اسپرنگ",
        's2': "سخت آب و ہوا میں اگتی ہے۔ اعلی پروٹین۔",
        't3': "سافٹ ریڈ ونٹر",
        's3': "کم پروٹین۔ کیک اور بسکٹ کے لیے بہترین۔",
        't4': "سفید گندم",
        's4': "پاستا اور نوڈلز کے لیے ترجیحی انتخاب۔",
      },
      'gu': {
        'main_title': "સામાન્ય ઘઉં",
        'chip1': "બ્રેડ ઘઉં",
        'chip2': "અખિલ ભારતીય",
        'desc':
            "ભારતમાં આ સૌથી વધુ ખેતી કરવામાં આવતા ઘઉં છે. તેનો ઉપયોગ મુખ્યત્વે ચપાતી, બ્રેડ અને વિવિધ બેકરી ઉત્પાદનો બનાવવા માટે થાય છે.",
        'list_title': "સામાન્ય ઘઉંના પ્રકારો",
        't1': "હાર્ડ રેડ વિન્ટર",
        's1': "વ્યાવસાયિક મનપસંદ. બ્રેડ બનાવવા માટે શ્રેષ્ઠ.",
        't2': "હાર્ડ રેડ સ્પ્રિંગ",
        's2': "કઠોર આબોહવામાં ઉગે છે. ઉચ્ચ પ્રોટીન તત્વ.",
        't3': "સોફ્ટ રેડ વિન્ટર",
        's3': "ઓછું પ્રોટીન. કેક અને બિસ્કિટ માટે શ્રેષ્ઠ.",
        't4': "સફેદ ઘઉં",
        's4': "પાસ્તા અને નૂડલ્સ માટે પસંદગીનો વિકલ્પ.",
      },
      'bn': {
        'main_title': "সাধারণ গম",
        'chip1': "ব্রেড গম",
        'chip2': "সর্বভারতীয়",
        'desc':
            "এটি ভারতে সবচেয়ে বেশি চাষ করা গম। এটি মূলত চপাটি, রুটি এবং বিভিন্ন বেকারি পণ্য তৈরির জন্য ব্যবহৃত হয়।",
        'list_title': "সাধারণ গমের প্রকারভেদ",
        't1': "হার্ড রেড উইন্টার",
        's1': "বাণিজ্যিক পছন্দ। রুটি তৈরির জন্য সেরা।",
        't2': "হার্ড রেড স্প্রিং",
        's2': "কঠিন জলবায়ুতে জন্মে। উচ্চ প্রোটিন সমৃদ্ধ।",
        't3': "সফট রেড উইন্টার",
        's3': "কম প্রোটিন। কেক এবং বিস্কুটের জন্য সেরা।",
        't4': "সাদা গম",
        's4': "পাস্তা এবং নুডলসের জন্য পছন্দের পছন্দ।",
      },
      'ml': {
        'main_title': "സാധാരണ ഗോതമ്പ്",
        'chip1': "ബ്രെഡ് ഗോതമ്പ്",
        'chip2': "പാൻ-ഇന്ത്യ",
        'desc':
            "ഇന്ത്യയിൽ ഏറ്റവും കൂടുതൽ കൃഷി ചെയ്യപ്പെടുന്ന ഗോതമ്പാണിത്. പ്രധാനമായും ചപ്പാത്തി, ബ്രെഡ്, വിവിധ ബേക്കറി ഉൽപ്പന്നങ്ങൾ എന്നിവയുണ്ടാക്കാൻ ഉപയോഗിക്കുന്നു.",
        'list_title': "സാധാരണ ഗോതമ്പ് തരങ്ങൾ",
        't1': "ഹാർഡ് റെഡ് വിന്റർ",
        's1': "വാണിജ്യപരമായ പ്രിയങ്കരം. ബ്രെഡ് ഉണ്ടാക്കാൻ മികച്ചത്.",
        't2': "ഹാർഡ് റെഡ് സ്പ്രിംഗ്",
        's2': "കഠിനമായ കാലാവസ്ഥയിൽ വളരുന്നു. ഉയർന്ന പ്രോട്ടീൻ.",
        't3': "സോഫ്റ്റ് റെഡ് വിന്റർ",
        's3': "കുറഞ്ഞ പ്രോട്ടീൻ. കേക്കുകൾക്കും ബിസ്ക്കറ്റുകൾക്കും മികച്ചത്.",
        't4': "വെള്ള ഗോതമ്പ്",
        's4': "പാസ്തയ്ക്കും നൂഡിൽസിനും അനുയോജ്യം.",
      },
    };

    String t(String key) => _texts[locale]?[key] ?? _texts['en']![key]!;

    final double imageHeight = MediaQuery.of(context).size.height / 4;
    final double minContentHeight = MediaQuery.of(context).size.height - 200;

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
                  'assets/images/step1.png',
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
            Center(
              child: Column(
                children: [
                  Text(
                    t('main_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "(Triticum vulgare / Triticum aestivum)",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: t('chip1'), icon: Icons.grass),
                _InfoChip(label: t('chip2'), icon: Icons.public),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              t('desc'),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              t('list_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildTypeCard(
              title: t('t1'),
              subtitle: t('s1'),
              icon: Icons.agriculture,
              color: Colors.brown,
            ),
            _buildTypeCard(
              title: t('t2'),
              subtitle: t('s2'),
              icon: Icons.fitness_center,
              color: Colors.amber,
            ),
            _buildTypeCard(
              title: t('t3'),
              subtitle: t('s3'),
              icon: Icons.cookie,
              color: Colors.deepOrangeAccent,
            ),
            _buildTypeCard(
              title: t('t4'),
              subtitle: t('s4'),
              icon: Icons.ramen_dining,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 24),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.3,
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

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7F3DFF)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7F3DFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
