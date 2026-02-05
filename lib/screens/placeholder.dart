import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import '../models/planting_data.dart';

import 'steps/step1.dart';
import 'steps/step2.dart';
import 'steps/step3.dart';
import 'steps/step4.dart';
import 'steps/step5.dart';
import 'steps/step6.dart';

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({super.key});

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color unselectedPurple = Color(0xFFFFCE99);
  static const Color inactiveIconColor = Color(0xFF562F00);

  int currentActiveStage = 1;
  final int totalStages = 6;

  // --- LOCALIZATION STATE ---
  String _currentLocale = 'en';

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Potato Farming Guide',
      'step': 'STEP',
      'plant_crop': 'Plant Your Potatoes',
      'f_name': 'Farmer Name',
      'potato': 'Potato',
      'notes': 'Notes (optional)',
      'capture': 'Capture Location',
      'confirm_p': 'Confirm Planting',
      'review': 'Review Details',
      'edit': 'Edit',
      'confirm': 'Confirm',
      'plant': 'Plant',
      'err_loc': 'Could not fetch location',
      'err_fill': 'Please fill all details and capture location',
      'farmer': 'Farmer',
      'crop': 'Crop',
      'date': 'Date',
      'loc': 'Location',
      'exact': 'Exact',
      'approx': 'Approx',
    },
    'hi': {
      'title': 'आलू कृषि मार्गदर्शिका',
      'step': 'चरण',
      'plant_crop': 'अपने आलू लगाएं',
      'f_name': 'किसान का नाम',
      'potato': 'आलू',
      'notes': 'नोट्स (वैकल्पिक)',
      'capture': 'स्थान प्राप्त करें',
      'confirm_p': 'बुवाई की पुष्टि करें',
      'review': 'विवरण की समीक्षा करें',
      'edit': 'संपादन',
      'confirm': 'पुष्टि',
      'plant': 'लगाएं',
      'err_loc': 'स्थान प्राप्त नहीं हो सका',
      'err_fill': 'कृपया सभी विवरण भरें और स्थान प्राप्त करें',
      'farmer': 'किसान',
      'crop': 'फसल',
      'date': 'तारीख',
      'loc': 'स्थान',
      'exact': 'सटीक',
      'approx': 'लगभग',
    },
    'ta': {
      'title': 'உருளைக்கிழங்கு வேளாண் வழிகாட்டி',
      'step': 'படி',
      'plant_crop': 'உருளைக்கிழங்கை நடவும்',
      'f_name': 'விவசாயி பெயர்',
      'potato': 'உருளைக்கிழங்கு',
      'notes': 'குறிப்புகள்',
      'capture': 'இருப்பிடத்தைப் பிடிக்கவும்',
      'confirm_p': 'நடவு உறுதிப்படுத்தவும்',
      'review': 'விவரங்களை மதிப்பாய்வு செய்யவும்',
      'edit': 'திருத்து',
      'confirm': 'உறுதி',
      'plant': 'நடவு',
      'err_loc': 'இருப்பிடத்தைப் பெற முடியவில்லை',
      'err_fill': 'அனைத்து விவரங்களையும் பூர்த்தி செய்து இருப்பிடத்தைப் பிடிக்கவும்',
      'farmer': 'விவசாயி',
      'crop': 'பயிர்',
      'date': 'தேதி',
      'loc': 'இருப்பிடம்',
      'exact': 'சரியான',
      'approx': 'தோராயமான',
    },
    'te': {
      'title': 'బంగాళదుంప వ్యవసాయ మార్గదర్శి',
      'step': 'దశ',
      'plant_crop': 'మీ బంగాళదుంపలను నాటండి',
      'f_name': 'రైతు పేరు',
      'potato': 'బంగాళదుంప',
      'notes': 'గమనికలు',
      'capture': 'స్థానాన్ని గుర్తించండి',
      'confirm_p': 'నాటడాన్ని ధృవీకరించండి',
      'review': 'వివరాలను సమీక్షించండి',
      'edit': 'సవరించు',
      'confirm': 'ధృవీకరించు',
      'plant': 'నాటండి',
      'err_loc': 'స్థానాన్ని పొందలేకపోయాము',
      'err_fill': 'దయచేసి అన్ని వివరాలను నింపి స్థానాన్ని గుర్తించండి',
      'farmer': 'రైతు',
      'crop': 'పంట',
      'date': 'తేదీ',
      'loc': 'స్థానం',
      'exact': 'ఖచ్చితమైన',
      'approx': 'సుమారు',
    },
    'kn': {
      'title': 'ಆಲೂಗಡ್ಡೆ ಕೃಷಿ ಮಾರ್ಗದರ್ಶಿ',
      'step': 'ಹಂತ',
      'plant_crop': 'ನಿಮ್ಮ ಆಲೂಗಡ್ಡೆಯನ್ನು ನೆಡಿ',
      'f_name': 'ರೈತರ ಹೆಸರು',
      'potato': 'ಆಲೂಗಡ್ಡೆ',
      'notes': 'ಟಿಪ್ಪಣಿಗಳು',
      'capture': 'ಸ್ಥಳವನ್ನು ಸೆರೆಹಿಡಿಯಿರಿ',
      'confirm_p': 'ನೆಡುವಿಕೆಯನ್ನು ದೃಢೀಕರಿಸಿ',
      'review': 'ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಿ',
      'edit': 'ತಿದ್ದುಪಡಿ',
      'confirm': 'ದೃಢೀಕರಿಸಿ',
      'plant': 'ನೆಡಿ',
      'err_loc': 'ಸ್ಥಳವನ್ನು ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ',
      'err_fill': 'ದಯವಿಟ್ಟು ಎಲ್ಲಾ ವಿವರಗಳನ್ನು ಭರ್ತಿ ಮಾಡಿ ಮತ್ತು ಸ್ಥಳವನ್ನು ಸೆರೆಹಿಡಿಯಿರಿ',
      'farmer': 'ರೈತ',
      'crop': 'ಬೆಳೆ',
      'date': 'ದಿನಾಂక',
      'loc': 'ಸ್ಥಳ',
      'exact': 'ನಿಖರ',
      'approx': 'ಅಂದಾಜು',
    },
    'mr': {
      'title': 'बटाटा कृषी मार्गदर्शिका',
      'step': 'टप्पा',
      'plant_crop': 'बटाटे लावा',
      'f_name': 'शेतकऱ्याचे नाव',
      'potato': 'बटाटा',
      'notes': 'टिप्पणी',
      'capture': 'स्थान मिळवा',
      'confirm_p': 'लागवडीची पुष्टी करा',
      'review': 'तपशील तपासा',
      'edit': 'संपादन',
      'confirm': 'पुष्टी',
      'plant': 'लावा',
      'err_loc': 'स्थान मिळू शकले नाही',
      'err_fill': 'कृपया सर्व तपशील भरा आणि स्थान मिळवा',
      'farmer': 'शेतकरी',
      'crop': 'पीक',
      'date': 'तारीख',
      'loc': 'स्थान',
      'exact': 'अचूक',
      'approx': 'अंदाजे',
    },
    'pa': {
      'title': 'ਆਲੂ ਖੇਤੀਬਾੜੀ ਗਾਈਡ',
      'step': 'ਕਦਮ',
      'plant_crop': 'ਆਲੂ ਲਗਾਓ',
      'f_name': 'ਕਿਸਾਨ ਦਾ ਨਾਮ',
      'potato': 'ਆਲੂ',
      'notes': 'ਨੋਟਸ',
      'capture': 'ਲੋਕੇਸ਼ਨ ਲਓ',
      'confirm_p': 'ਬਿਜਾਈ ਦੀ ਪੁਸ਼ਟੀ',
      'review': 'ਵੇਰਵਿਆਂ ਦੀ ਸਮੀਖਿਆ',
      'edit': 'ਸੋਧੋ',
      'confirm': 'ਪੁਸ਼ਟੀ',
      'plant': 'ਬੀਜੋ',
      'err_loc': 'ਲੋਕੇਸ਼ਨ ਨਹੀਂ ਮਿਲੀ',
      'err_fill': 'ਕਿਰਪਾ ਕਰਕੇ ਸਾਰੇ ਵੇਰਵੇ ਭਰੋ ਅਤੇ ਲੋਕੇਸ਼ਨ ਲਓ',
      'farmer': 'ਕਿਸਾਨ',
      'crop': 'ਫਸਲ',
      'date': 'ਤਾਰੀਖ',
      'loc': 'ਲੋਕੇਸ਼ਨ',
      'exact': 'ਸਹੀ',
      'approx': 'ਲਗਭਗ',
    },
    'bn': {
      'title': 'আলু কৃষি নির্দেশিকা',
      'step': 'ধাপ',
      'plant_crop': 'আপনার আলু রোপণ করুন',
      'f_name': 'কৃষকের নাম',
      'potato': 'আলু',
      'notes': 'নোট',
      'capture': 'অবস্থান নিন',
      'confirm_p': 'রোপণ নিশ্চিত করুন',
      'review': 'বিবরণ পর্যালোচনা',
      'edit': 'সম্পাদনা',
      'confirm': 'নিশ্চিত',
      'plant': 'রোপণ',
      'err_loc': 'অবস্থান পাওয়া যায়নি',
      'err_fill': 'সব তথ্য পূরণ করুন এবং অবস্থান নিন',
      'farmer': 'কৃষক',
      'crop': 'ফসল',
      'date': 'তারিখ',
      'loc': 'অবস্থান',
      'exact': 'সঠিক',
      'approx': 'আনুমানিক',
    },
    'gu': {
      'title': 'બટાટા કૃષિ માર્ગદર્શિકા',
      'step': 'તબક્કો',
      'plant_crop': 'બટાટા રોપો',
      'f_name': 'ખેડૂતનું નામ',
      'potato': 'બટાટા',
      'notes': 'નોંધ',
      'capture': 'સ્થાન મેળવો',
      'confirm_p': 'વાવેતરની પુષ્ટિ કરો',
      'review': 'વિગતોની સમીક્ષા',
      'edit': 'ફેરફાર',
      'confirm': 'પુષ્ટિ',
      'plant': 'રોપો',
      'err_loc': 'સ્થાન મળ્યું નથી',
      'err_fill': 'બધી વિગતો ભરો અને સ્થાન મેળવો',
      'farmer': 'ખેડૂત',
      'crop': 'પાક',
      'date': 'તારીખ',
      'loc': 'સ્થાન',
      'exact': 'ચોક્કસ',
      'approx': 'આશરે',
    },
    'ml': {
      'title': 'ഉരുളക്കിഴങ്ങ് കാർഷിക ഗൈഡ്',
      'step': 'ഘട്ടം',
      'plant_crop': 'ഉരുളക്കിഴങ്ങ് ഇറക്കുക',
      'f_name': 'കർഷകന്റെ പേര്',
      'potato': 'ഉരുളക്കിഴങ്ങ്',
      'notes': 'കുറിപ്പുകൾ',
      'capture': 'ലൊക്കേഷൻ എടുക്കുക',
      'confirm_p': 'ഉറപ്പാക്കുക',
      'review': 'വിവരങ്ങൾ പരിശോധിക്കുക',
      'edit': 'തിരുത്തുക',
      'confirm': 'സ്ഥിരീകരിക്കുക',
      'plant': 'വിള',
      'err_loc': 'ലൊക്കേഷൻ ലഭ്യമല്ല',
      'err_fill': 'വിവരങ്ങൾ പൂരിപ്പിച്ച് ലൊക്കേഷൻ എടുക്കുക',
      'farmer': 'കർഷകൻ',
      'crop': 'വിള',
      'date': 'തീയതി',
      'loc': 'ലൊക്കേഷൻ',
      'exact': 'കൃത്യമായ',
      'approx': 'ഏകദേശ',
    },
    'ur': {
      'title': 'آلو کی زرعی گائیڈ',
      'step': 'مرحلہ',
      'plant_crop': 'اپنے آلو لگائیں',
      'f_name': 'کسان کا نام',
      'potato': 'آلو',
      'notes': 'نوٹس',
      'capture': 'مقام حاصل کریں',
      'confirm_p': 'کاشت کی تصدیق کریں',
      'review': 'تفصیلات کا جائزہ',
      'edit': 'ترمیم',
      'confirm': 'تصدیق',
      'plant': 'کاشت',
      'err_loc': 'مقام نہیں ملا',
      'err_fill': 'تمام تفصیلات بھریں اور مقام حاصل کریں',
      'farmer': 'کسان',
      'crop': 'فصل',
      'date': 'تاریخ',
      'loc': 'مقام',
      'exact': 'درست',
      'approx': 'تقریباً',
    },
  };

  String _t(String key) => _localizedValues[_currentLocale]?[key] ?? key;
  bool get _isRTL => _currentLocale == 'ur';

  // Form State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String selectedDate = "DD/MM/YYYY";
  String? _currentPosition;
  double? _lat;
  double? _lng;
  bool isExact = true;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('farmerName');
    final savedLang = prefs.getString('appLanguage');
    if (mounted) {
      setState(() {
        if (savedName != null) _nameController.text = savedName;
        if (savedLang != null) _currentLocale = savedLang;
      });
    }
  }

  Widget _getStepContent() {
    switch (currentActiveStage) {
      case 1:
        return Step1Content(locale: _currentLocale);
      case 2:
        return Step2Content(locale: _currentLocale);
      case 3:
        return Step3Content(locale: _currentLocale);
      case 4:
        return Step4Content(locale: _currentLocale);
      case 5:
      // return Step5Content(locale: _currentLocale);
        return Step5Content(locale: _currentLocale);
      case 6:
        debugPrint("Placeholder building Step6 with locale: $_currentLocale");
        return Step6Content(
          key: ValueKey('step6_$_currentLocale'),
          locale: _currentLocale,
        );
      default:
        return Step1Content(locale: _currentLocale);
    }
  }

  Future<void> _determinePosition(StateSetter setSheetState) async {
    setSheetState(() => isCapturing = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setSheetState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _currentPosition =
        "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        isCapturing = false;
      });
    } catch (e) {
      setSheetState(() => isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_t('err_loc'))));
      }
    }
  }

  void _showPlantingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Directionality(
            textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDF1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 35,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _t('plant_crop'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          _buildField(
                            Icons.person_outline,
                            _t('f_name'),
                            _nameController,
                          ),
                          _buildCropField(),
                          _buildField(
                            Icons.calendar_today_outlined,
                            selectedDate,
                            null,
                            isReadOnly: true,
                            onTap: () => _selectDate(setSheetState),
                            isPlaceholder: selectedDate == "DD/MM/YYYY",
                          ),
                          _buildToggleSwitch(setSheetState),
                          _buildField(
                            Icons.notes_outlined,
                            _t('notes'),
                            _notesController,
                          ),
                          _buildLocationButton(setSheetState),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.trim().isNotEmpty &&
                                    selectedDate != "DD/MM/YYYY" &&
                                    _currentPosition != null) {
                                  _showReviewDialog();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(_t('err_fill'))),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _t('confirm_p'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
      IconData icon,
      String hint,
      TextEditingController? controller, {
        bool isReadOnly = false,
        VoidCallback? onTap,
        bool isPlaceholder = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 12,
            color: isPlaceholder ? Colors.grey : Colors.black,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryPurple, size: 16),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildCropField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.grass, color: primaryPurple, size: 16),
            const SizedBox(width: 10),
            Text(_t('potato'), style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 34,
        width: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _toggleItem(_t('exact'), isExact, setSheetState),
            _toggleItem(_t('approx'), !isExact, setSheetState),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool active, StateSetter setSheetState) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setSheetState(() => isExact = (label == _t('exact'))),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: active ? primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton(StateSetter setSheetState) {
    return GestureDetector(
      onTap: () => _determinePosition(setSheetState),
      child: Container(
        height: 38,
        width: 220,
        decoration: BoxDecoration(
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isCapturing
              ? const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryPurple,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.my_location,
                color: primaryPurple,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _currentPosition ?? _t('capture'),
                style: const TextStyle(
                  color: primaryPurple,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              _t('review'),
              style: const TextStyle(
                fontSize: 16,
                color: primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _reviewRow(_t('farmer'), _nameController.text),
              _reviewRow(_t('crop'), _t('wheat')),
              _reviewRow(_t('date'), selectedDate),
              _reviewRow(_t('loc'), _currentPosition ?? ""),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _t('edit'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _handleFinalConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                _t('confirm'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFinalConfirm() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final parts = selectedDate.split('/');
    final parsedDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final plantingData = {
      'id': user.id,
      'name': name,
      'email': user.email,
      'crop': "Wheat",
      'planting_date': parsedDate.toIso8601String(),
      'latitude': _lat ?? 0.0,
      'longitude': _lng ?? 0.0,
      'is_exact': isExact,
      'notes': _notesController.text.trim(),
      'is_crop_planted': true,
    };

    try {
      await supabase.from('profile').update(plantingData).eq('id', user.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isCropPlanted', true);
      await prefs.setString('farmerName', name);
      await prefs.setString('plantingData', jsonEncode(plantingData));

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _selectDate(StateSetter setSheetState) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
    );
    if (picked != null)
      setSheetState(
            () => selectedDate = "${picked.day}/${picked.month}/${picked.year}",
      );
  }

  @override
  Widget build(BuildContext context) {
    bool isLastStep = currentActiveStage == totalStages;
    return Directionality(
      textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF1),
        appBar: AppBar(
          backgroundColor: primaryPurple,
          centerTitle: true,
          title: Text(
            _t('title'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [_buildLanguagePicker()],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            _buildTimeline(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _getStepContent(),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildNavigationButtons(isLastStep),
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white, size: 20),
      onSelected: (String code) async {
        debugPrint("Language selected: $code");
        setState(() => _currentLocale = code);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('appLanguage', code);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text("English")),
        const PopupMenuItem(value: 'hi', child: Text("हिन्दी (Hindi)")),
        const PopupMenuItem(value: 'ta', child: Text("தமிழ் (Tamil)")),
        const PopupMenuItem(value: 'te', child: Text("తెలుగు (Telugu)")),
        const PopupMenuItem(value: 'kn', child: Text("ಕನ್ನಡ (Kannada)")),
        const PopupMenuItem(value: 'mr', child: Text("मराठी (Marathi)")),
        const PopupMenuItem(value: 'pa', child: Text("ਪੰਜਾਬੀ (Punjabi)")),
        const PopupMenuItem(value: 'gu', child: Text("ગુજરાતી (Gujarati)")),
        const PopupMenuItem(value: 'bn', child: Text("বাংলা (Bengali)")),
        const PopupMenuItem(value: 'ml', child: Text("മലയാളം (Malayalam)")),
        const PopupMenuItem(value: 'ur', child: Text("اردو (Urdu)")),
      ],
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalStages, (index) {
          int stageNumber = index + 1;
          bool done = stageNumber <= currentActiveStage;
          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: done ? primaryPurple : unselectedPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stageNumber < currentActiveStage
                        ? Icons.check
                        : _getIconForStage(stageNumber),
                    size: 14,
                    color: done ? Colors.white : inactiveIconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_t('step')} $stageNumber",
                  style: TextStyle(
                    fontSize: 6,
                    color: done ? primaryPurple : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLastStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentActiveStage > 1)
            _navCircleButton(
              icon: Icons.arrow_back,
              onPressed: () => setState(() => currentActiveStage--),
            )
          else
            const SizedBox(width: 45),
          _navCircleButton(
            label: isLastStep ? _t('plant') : null,
            icon: isLastStep ? null : Icons.arrow_forward,
            onPressed: () => isLastStep
                ? _showPlantingForm()
                : setState(() => currentActiveStage++),
            isPrimary: isLastStep,
          ),
        ],
      ),
    );
  }

  Widget _navCircleButton({
    IconData? icon,
    String? label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      height: 45,
      width: label != null ? 80 : 45,
      child: FloatingActionButton(
        elevation: 2,
        heroTag: label ?? icon.toString(),
        onPressed: onPressed,
        backgroundColor: unselectedPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: label != null
            ? Text(
          label,
          style: const TextStyle(
            color: primaryPurple,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        )
            : Icon(icon, color: primaryPurple, size: 20),
      ),
    );
  }

  IconData _getIconForStage(int stage) {
    switch (stage) {
      case 1:
        return Icons.menu_book;
      case 2:
        return Icons.wb_sunny;
      case 3:
        return Icons.settings;
      case 4:
        return Icons.grain;
      case 5:
        return Icons.biotech;
      case 6:
        return Icons.water_drop;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
