import 'package:flutter/material.dart';
import 'section_detail_screen.dart';
import 'step_detail_screen.dart';

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
      size.width * 0.05,
      size.height,
      size.width * 0.15,
      size.height,
    );

    path.lineTo(size.width * 0.85, size.height);

    path.quadraticBezierTo(
      size.width * 0.95,
      size.height,
      size.width,
      size.height - 20,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


enum ContentType {
  heading,
  paragraph,
  bullets,
  image,
}

class ContentBlock {
  final ContentType type;
  final String? text;
  final List<String>? bullets;
  final String? assetPath;

  ContentBlock.heading(this.text)
      : type = ContentType.heading,
        bullets = null,
        assetPath = null;

  ContentBlock.paragraph(this.text)
      : type = ContentType.paragraph,
        bullets = null,
        assetPath = null;

  ContentBlock.bullets(this.bullets)
      : type = ContentType.bullets,
        text = null,
        assetPath = null;

  ContentBlock.image(this.assetPath)
      : type = ContentType.image,
        text = null,
        bullets = null;
}

class Section {
  final String title;
  final String description;
  final String thumbnailAsset;
  final List<ContentBlock> content;

  Section({
    required this.title,
    required this.description,
    required this.thumbnailAsset,
    required this.content,
  });
}

final List<Section> sections = [
  Section(
    title: 'Introduction',
    description: 'Get to know about Potato',
    thumbnailAsset: 'assets/images/step1.png',
    content: [],
  ),
  Section(
    title: 'Climate & Soil',
    description: 'Optimal Conditions',
    thumbnailAsset: 'assets/images/step2.png',
    content: [],
  ),
  Section(
    title: 'Seed & Sowing',
    description: 'Prep & Planting',
    thumbnailAsset: 'assets/images/step3.png',
    content: [],
  ),
  Section(
    title: 'Nutrient Management',
    description: 'Best Fertilization',
    thumbnailAsset: 'assets/images/step4.png',
    content: [],
  ),
  Section(
    title: 'Field Care',
    description: 'Protection & Irrigation',
    thumbnailAsset: 'assets/images/step5.png',
    content: [],
  ),
  Section(
    title: 'Harvest & Storage',
    description: 'End of Cycle',
    thumbnailAsset: 'assets/images/step6.png',
    content: [],
  ),
];

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  String _getTranslatedTitle(BuildContext context, int index) {
    final String locale = Localizations.localeOf(context).languageCode;
    final Map<String, List<String>> translations = {
      'en': [
        'Introduction',
        'Climate & Soil',
        'Seed & Sowing',
        'Nutrient Management',
        'Field Care',
        'Harvest & Storage'
      ],
      'hi': [
        'परिचय',
        'जलवायु और मिट्टी',
        'बीज और बुवाई',
        'पोषक तत्व प्रबंधन',
        'खेत की देखभाल',
        'कटाई और भंडारण'
      ],
      'pa': [
        'ਜਾਣ-ਪਛਾਣ',
        'ਜਲਵਾਯੂ ਅਤੇ ਮਿੱਟੀ',
        'ਬੀਜ এবং ਬਿਜਾਈ',
        'ਪੌਸ਼ਟਿਕ ਤੱਤ ਪ੍ਰਬੰਧਨ',
        'ਖੇਤ ਦੀ ਦੇਖਭਾਲ',
        'ਕਟਾਈ ਅਤੇ ਭੰਡਾਰਨ'
      ],
      'ta': [
        'அறிமுகம்',
        'காலநிலை மற்றும் மண்',
        'விதை மற்றும் விதைப்பு',
        'ஊட்டச்சத்து மேலாண்மை',
        'வயல் பராமரிப்பு',
        'அறுவடை மற்றும் சேமிப்பு'
      ],
      'te': [
        'పరిచయం',
        'వాతావరణం & నేల',
        'విత్తనాలు & నాటడం',
        'పోషక నిర్వహణ',
        'క్షేత్ర సంరక్షణ',
        'కోత & నిల్వ'
      ],
      'kn': [
        'ಪರಿಚಯ',
        'ಹವಾಮಾನ ಮತ್ತು ಮಣ್ಣು',
        'ಬೀಜ ಮತ್ತು ಬಿತ್ತನೆ',
        'ಪೋಷಕಾಂಶ ನಿರ್ವಹಣೆ',
        'ಕ್ಷೇತ್ರದ ಆರೈಕೆ',
        'ಕೊಯ್ಲು ಮತ್ತು ಸಂಗ್ರಹಣೆ'
      ],
      'mr': [
        'ओळख',
        'हवामान आणि माती',
        'बियाणे आणि पेरणी',
        'पोषक तत्व व्यवस्थापन',
        'शेत देखभाल',
        'काढणी आणि साठवणूक'
      ],
      'gu': [
        'પરિચય',
        'આબોહવા અને જમીન',
        'બીજ અને વાવણી',
        'પોષક તત્વોનું સંચાલન',
        'ખેતરની સંભાળ',
        'કાપણી અને સંગ્રહ'
      ],
      'bn': [
        'ভূমিকা',
        'জলবায়ু ও মাটি',
        'বীজ ও বপন',
        'পুষ্টি ব্যবস্থাপনা',
        'মাঠের যত্ন',
        'সংগ্রহ ও সংরক্ষণ'
      ],
      'ml': [
        'ആമുഖം',
        'കാലാവസ്ഥയും മണ്ണും',
        'വിത്തും വിതയ്ക്കലും',
        'പോഷക മാനേജ്‌മെന്റ്',
        'വയൽ പരിപാലനം',
        'വിളവെടുപ്പും സംഭരണവും'
      ],
      'ur': [
        'تعارف',
        'آب و ہوا اور مٹی',
        'بیج اور بوائی',
        'غذائی اجزاء کا انتظام',
        'کھیت کی دیکھ بھال',
        'کٹائی اور ذخیرہ'
      ],
    };

    final list = translations[locale] ?? translations['en']!;
    return (index >= 0 && index < list.length) ? list[index] : list[0];
  }

  String _getTranslatedDescription(BuildContext context, int index) {
    final String locale = Localizations.localeOf(context).languageCode;
    final Map<String, List<String>> translations = {
      'en': [
        'Get to know about Potato',
        'Optimal Conditions',
        'Prep & Planting',
        'Best Fertilization',
        'Protection & Irrigation',
        'End of Cycle'
      ],
      'hi': [
        'आलू के बारे में जानें',
        'इष्टतम स्थितियाँ',
        'तैयारी और बुवाई',
        'सर्वोत्तम उर्वरक',
        'सुरक्षा और सिंचाई',
        'चक्र का अंत'
      ],
      'pa': [
        'ਆਲੂ ਬਾਰੇ ਜਾਣੋ',
        'ਅਨੁਕੂਲ ਹਾਲਾਤ',
        'ਤਿਆਰੀ ਅਤੇ ਬਿਜਾਈ',
        'ਸਭ ਤੋਂ ਵਧੀਆ ਖਾਦ',
        'ਸੁਰੱਖਿਆ ਅਤੇ ਸਿੰਚਾਈ',
        'ਚੱਕਰ ਦਾ ਅੰਤ'
      ],
      'ta': [
        'உருளைக்கிழங்கு பற்றி தெரிந்து கொள்ளுங்கள்',
        'சிறந்த நிலைமைகள்',
        'தயாரிப்பு மற்றும் நடவு',
        'சிறந்த உரமிடுதல்',
        'பாதுகாப்பு மற்றும் பாசனம்',
        'சுழற்சியின் முடிவு'
      ],
      'te': [
        'బంగాళదుంప గురించి తెలుసుకోండి',
        'అనుకూల పరిస్థితులు',
        'తయారీ & నాటడం',
        'ఉత్తమ ఎరువులు',
        'రక్షణ & నీటి పారుదల',
        'పంట ముగింపు'
      ],
      'kn': [
        'ಆಲೂಗಡ್ಡೆ ಬಗ್ಗೆ ತಿಳಿಯಿರಿ',
        'ಸೂಕ್ತ ಪರಿಸ್ಥಿತಿಗಳು',
        'ತಯಾರಿ ಮತ್ತು ಬಿತ್ತನೆ',
        'ಅತ್ಯುತ್ತಮ ಗೊಬ್ಬರ',
        'ರಕ್ಷಣೆ ಮತ್ತು ನೀರಾವರಿ',
        'ಚಕ್ರದ ಅಂತ್ಯ'
      ],
      'mr': [
        'बटाट्याबद्दल जाणून घ्या',
        'इष्टतम परिस्थिती',
        'तयारी आणि लागवड',
        'सर्वोत्तम खत',
        'संरक्षण आणि सिंचन',
        'चक्राचा शेवट'
      ],
      'gu': [
        'બટાટા વિશે જાણો',
        'અનુકૂળ પરિસ્થિતિઓ',
        'તૈયારી અને વાવણી',
        'શ્રેષ્ઠ ખાતર',
        'રક્ષણ અને સિંચાઈ',
        'ચક્રનો અંત'
      ],
      'bn': [
        'আলু সম্পর্কে জানুন',
        'অনুকূল পরিস্থিতি',
        'প্রস্তুতি ও বপন',
        'সেরা সার প্রয়োগ',
        'সুরক্ষা ও সেচ',
        'চক্রের শেষ'
      ],
      'ml': [
        'ഉരുളക്കിഴങ്ങിനെക്കുറിച്ച് അറിയുക',
        'അഭികാമ്യമായ സാഹചര്യങ്ങൾ',
        'തയ്യാറെടുപ്പും വിതയ്ക്കലും',
        'മികച്ച വളപ്രയോഗം',
        'സംരക്ഷണവും ജലസേചനവും',
        'ചക്രത്തിന്റെ അവസാനം'
      ],
      'ur': [
        'آلو کے بارے میں جانیں',
        'بہترین حالات',
        'تیاری اور بوائی',
        'بہترین فرٹلائزیشن',
        'تحفظ اور آب پاشی',
        'سائیکل کا اختتام'
      ],
    };

    final list = translations[locale] ?? translations['en']!;
    return (index >= 0 && index < list.length) ? list[index] : list[0];
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF9644);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// ---------- HEADER WITH CURVE ----------
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 10,
                right: 10,
                bottom: 18,
              ),
              width: double.infinity,
              color: primaryColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- STACKED CARDS ----------
          Expanded(
            child: Container(
              color: const Color(0xFFFFFDF1),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  for (int i = 0; i < 6; i++)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SectionCardDelegate(
                        section: Section(
                          title: _getTranslatedTitle(context, i),
                          description: _getTranslatedDescription(context, i),
                          thumbnailAsset: 'assets/images/step${i + 1}.png',
                          content: [],
                        ),
                        index: i,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StepDetailScreen(
                                stepIndex: i + 1,
                                title: _getTranslatedTitle(context, i),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCardDelegate extends SliverPersistentHeaderDelegate {
  final Section section;
  final int index;
  final VoidCallback onTap;

  final double _maxExtent = 145.0;
  final double _minExtent = 0.0;

  _SectionCardDelegate({
    required this.section,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _maxExtent,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        section.thumbnailAsset,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFFFB3B3),
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            section.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _SectionCardDelegate oldDelegate) {
    return oldDelegate.section != section;
  }
}