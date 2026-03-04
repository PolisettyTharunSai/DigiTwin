import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'step_detail_screen.dart';

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(size.width * 0.05, size.height, size.width * 0.15, size.height);
    path.lineTo(size.width * 0.85, size.height);
    path.quadraticBezierTo(size.width * 0.95, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  String _currentLocale = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _currentLocale = prefs.getString('appLanguage') ?? 'en');
  }

  String _getTranslatedTitle(int index) {
    final Map<String, List<String>> translations = {
      'en': ['Introduction', 'Climate & Soil', 'Seed & Sowing', 'Nutrient Management', 'Field Care', 'Harvest & Storage'],
      'hi': ['परिचय', 'जलवायु और मिट्टी', 'बीज और बुवाई', 'पोषक तत्व प्रबंधन', 'खेत की देखभाल', 'कटाई और भंडारण'],
      'pa': ['ਜਾਣ-ਪਛਾਣ', 'ਜਲਵਾਯੂ ਅਤੇ ਮਿੱਟੀ', 'ਬੀਜ ਅਤੇ ਬਿਜਾਈ', 'ਪੌਸ਼ਟਿਕ ਤੱਤ ਪ੍ਰਬੰਧਨ', 'ਖੇਤ ਦੀ ਦੇਖਭਾਲ', 'ਕਟਾਈ ਅਤੇ ਭੰਡਾਰਨ'],
      'ta': ['அறிமுகம்', 'காலநிலை மற்றும் மண்', 'விதை மற்றும் விதைப்பு', 'ஊட்டச்சத்து மேலாண்மை', 'வயல் பராமரிப்பு', 'அறுவடை மற்றும் சேமிப்பு'],
      'te': ['పరిచయం', 'వాతావరణం & నేల', 'విత్తనాలు & నాటడం', 'పోషక నిర్వహణ', 'క్షేత్ర సంరక్షణ', 'కోత & నిల్వ'],
      'kn': ['ಪರಿಚಯ', 'ಹವಾಮಾನ ಮತ್ತು ಮಣ್ಣು', 'ಬೀಜ ಮತ್ತು ಬಿತ್ತನೆ', 'ಪೋಷಕಾಂಶ ನಿರ್ವಹಣೆ', 'ಕ್ಷೇತ್ರದ ಆರೈಕೆ', 'ಕೊಯ್ಲು ಮತ್ತು ಸಂಗ್ರಹಣೆ'],
      'mr': ['ओळख', 'हवामान आणि माती', 'बियाणे आणि पेरणी', 'पोषक तत्व व्यवस्थापन', 'शेत देखभाल', 'काढणी आणि साठवणूक'],
      'gu': ['પરિચય', 'આબોહવા અને જમીન', 'બીજ અને વાવણી', 'પોષક તત્વોનું સંચાલન', 'ખેતરની સંભાળ', 'કાપણી અને સંગ્રહ'],
      'bn': ['ভূমিকা', 'জলবায়ু ও মাটি', 'বীজ ও বপন', 'পুষ্টি ব্যবস্থাপনা', 'মাঠের যত্ন', 'সংগ্রহ ও সংরক্ষণ'],
      'ml': ['ആമുഖം', 'കാലാവസ്ഥയും മണ്ണും', 'വിത്തും വിതയ്ക്കലും', 'പോഷക മാനേജ്‌മെന്റ്', 'വയൽ പരിപالനം', 'വിളവെടുപ്പും സംഭരണവും'],
      'ur': ['تعارف', 'آب و ہوا اور مٹی', 'بیج اور بوائی', 'غذائی اجزاء کا انتظام', 'کھیت کی دیکھ بھال', 'کٹائی اور ذخیرہ'],
    };
    final list = translations[_currentLocale] ?? translations['en']!;
    return (index >= 0 && index < list.length) ? list[index] : list[0];
  }

  String _getTranslatedDescription(int index) {
    final Map<String, List<String>> translations = {
      'en': ['Get to know about Potato', 'Optimal Conditions', 'Prep & Planting', 'Best Fertilization', 'Protection & Irrigation', 'End of Cycle'],
      'hi': ['आलू के बारे में जानें', 'इष्टतम स्थितियाँ', 'तैयारी और बुवाई', 'सर्वोत्तम उर्वरक', 'सुरक्षा और सिंचाई', 'चक्र का अंत'],
      'pa': ['ਆਲੂ ਬਾਰੇ ਜਾਣੋ', 'ਅਨੁਕੂਲ ਹਾਲਾਤ', 'ਤਿਆਰੀ ਅਤੇ ਬਿਜਾਈ', 'ਸਭ ਤੋਂ ਵਧੀਆ ਖਾਦ', 'ਸੁਰੱਖਿਆ ਅਤੇ ਸਿੰਚਾਈ', 'ਚੱਕਰ ਦਾ ਅੰਤ'],
      'ta': ['உருளைக்கிழங்கு பற்றி தெரிந்து கொள்ளுங்கள்', 'சிறந்த நிலைமைகள்', 'தயாரிப்பு மற்றும் நடவு', 'சிறந்த உரமிடுதல்', 'பாதுகாப்பு மற்றும் பாசனம்', 'சுழற்சியின் முடிவு'],
      'te': ['బంగాళదుంప గురించి తెలుసుకోండి', 'అనుకూల పరిస్థితులు', 'తయారీ & నాటడం', 'ఉత్తమ ఎరువులు', 'రక్షణ & నీటి పారుదల', 'పంట ముగింపు'],
      'kn': ['ಆಲೂಗಡ್ಡೆ ಬಗ್ಗೆ ತಿಳಿಯಿರಿ', 'ಸೂಕ್ತ ಪರಿಸ್ಥಿತಿಗಳು', 'ತಯಾರಿ ಮತ್ತು ಬಿತ್ತನೆ', 'ಅತ್ಯುತ್ತಮ ಗೊಬ್ಬರ', 'ರಕ್ಷಣೆ ಮತ್ತು ನೀರಾವರಿ', 'ಚಕ್ರದ ಅಂತ್ಯ'],
      'mr': ['बटाट्याबद्दल जाणून घ्या', 'इष्टतम परिस्थिती', 'तयारी आणि लागवड', 'सर्वोत्तम खत', 'संरक्षण आणि सिंचन', 'चक्राचा शेवट'],
      'gu': ['બટાટા વિશે જાણો', 'અનુકૂળ પરિસ્થિતિઓ', 'તૈયારી અને વાવણી', 'શ્રેષ્ઠ ખાતર', 'રક્ષણ અને સિંચાઈ', 'ચક્રનો અંત'],
      'bn': ['আলু সম্পর্কে জানুন', 'অনুকূল পরিস্থিতি', 'প্রস্তুতি ও বপন', 'সেরা সার প্রয়োগ', 'সুরক্ষা ও সেচ', 'চক্রের শেষ'],
      'ml': ['ഉരുളക്കിഴങ്ങിനെക്കുറിച്ച് അറിയുക', 'അഭികാമ്യമായ സാഹചര്യങ്ങൾ', 'തയ്യാറെടുപ്പും വിതയ്ക്കലും', 'മികച്ച വളപ്രയോഗം', 'സംരക്ഷണവും ജലസേചനവും', 'ചക്രത്തിന്റെ അവസാനം'],
      'ur': ['آلو کے بارے میں جانیں', 'بہترین حالات', 'تیاری اور بوائی', 'بہترین فرٹلائزیشن', 'تحفظ اور آب پاشی', 'سائیکل کا اختتام'],
    };
    final list = translations[_currentLocale] ?? translations['en']!;
    return (index >= 0 && index < list.length) ? list[index] : list[0];
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF9644);
    final double topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              padding: EdgeInsets.only(top: topInset + 12, left: 12, right: 12, bottom: 12),
              width: double.infinity,
              color: primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Instructions',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  _buildLanguagePicker(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFFFFDF1),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: 6,
                itemBuilder: (context, i) {
                  final sectionTitle = _getTranslatedTitle(i);
                  final sectionDesc = _getTranslatedDescription(i);
                  final thumb = 'assets/images/step${i + 1}.png';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StepDetailScreen(
                                stepIndex: i + 1,
                                title: sectionTitle,
                                locale: _currentLocale,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: primaryColor.withValues(alpha: 0.1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    thumb,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: primaryColor, size: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 6),
                                    Text(sectionDesc, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.3)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text('View Guide', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor.withValues(alpha: 0.8))),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded, size: 14, color: primaryColor.withValues(alpha: 0.8)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.translate, color: Colors.white, size: 26),
        tooltip: 'Change Language',
        onSelected: (String code) async {
          setState(() => _currentLocale = code);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('appLanguage', code);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'en', child: Text('English')),
          const PopupMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
          const PopupMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
          const PopupMenuItem(value: 'te', child: Text('తెలుగు (Telugu)')),
          const PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ (Kannada)')),
          const PopupMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
          const PopupMenuItem(value: 'pa', child: Text('ਪੰਜਾਬੀ (Punjabi)')),
          const PopupMenuItem(value: 'gu', child: Text('ગુજરાતી (Gujarati)')),
          const PopupMenuItem(value: 'bn', child: Text('বাংলা (Bengali)')),
          const PopupMenuItem(value: 'ml', child: Text('മലയാളം (Malayalam)')),
          const PopupMenuItem(value: 'ur', child: Text('اردو (Urdu)')),
        ],
      ),
    );
  }
}
