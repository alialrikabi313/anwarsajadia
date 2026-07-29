// مدقّقات إدخال خفيفة تحاكي الصيغ اللي يفرضها الباك إند، حتى نرفض المدخل الغلط
// بالجهاز قبل ما يوصل imamzain.org ويرجع 400 برسالة إنجليزية ما تنفع للمستخدم.

// بريد اعتيادي، ورقم بصيغة E.164 مثل ‎+9647801234567، ودولة ISO 3166-1 alpha-2
// بحرفين كبار مثل IQ — هذي بالضبط اللي يتوقعها الخادم.
final RegExp _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
final RegExp _e164Re = RegExp(r'^\+[1-9]\d{6,14}$');
final RegExp _iso2Re = RegExp(r'^[A-Z]{2}$');

bool isEmail(String s) => _emailRe.hasMatch(s.trim());
bool isE164Phone(String s) => _e164Re.hasMatch(s.trim());
bool isIso2Country(String s) => _iso2Re.hasMatch(s.trim());
