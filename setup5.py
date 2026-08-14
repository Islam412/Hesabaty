import os, json

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

en = {"@@locale":"en","appName":"Capital & Debt Ledger","more":"More","cashBook":"Cash Book","debtBook":"Debt Book","income":"Income","expense":"Expense","balance":"Balance","customers":"Customers","suppliers":"Suppliers","emptyCashBook":"Here you can record all your daily expenses and income.","emptyDebtBook":"Here you can record all customer and supplier debts.","shareApp":"Share the app with merchants","myBusinessWallet":"My Business Wallet","walletDesc":"Receive your money instantly, securely, from anywhere","paymentServices":"Electronic Payment Services","paymentDesc":"Offer bill payments and top-ups for your customers and earn commissions","businessCard":"Business Card","inventoryStaff":"Inventory & Staff","settings":"Settings","autoBackup":"Auto Backup","contactUs":"Contact Us","aboutApp":"About the App","addCustomer":"Add Customer","addSupplier":"Add Supplier","importContacts":"Import customer numbers","importContactsDesc":"Sharing phone numbers with the app lets you add new customers quickly.","contactsDenied":"You have disabled access permission to contacts","name":"Name","phoneNumber":"Phone number","address":"Address","tags":"Tags","addTags":"Add tags","tagsDesc":"Use custom tags (e.g. VIP, wholesale, region) to group and filter your contacts quickly","confirm":"Confirm","cancel":"Cancel","owedToMe":"Owed to me","owedByMe":"Owed by me","given":"Given","taken":"Taken","save":"Save","amount":"Amount","note":"Note","search":"Search","version":"Version","language":"Language","appearance":"Appearance","light":"Light","dark":"Dark","system":"System default","edit":"Edit","voidTx":"Void transaction","share":"Share","welcomeTitle":"Welcome to Hesabaty","onb1Body":"A ledger that makes it easy to record and manage debts for customers and suppliers. From any phone, anywhere.","onb2":"All customer debts and payments in your hand at any time, without a paper ledger.","onb3":"A detailed statement for every customer.","onb4":"Automatic, free payment reminders via WhatsApp.","onb5":"Add a note and a photo of the goods or invoice to every transaction.","start":"Start","comingSoon":"Coming soon"}

ar = {"@@locale":"ar","appName":"دفتر رأس المال والديون","more":"المزيد","cashBook":"دفتر النقدية","debtBook":"دفتر الديون","income":"دخل","expense":"مصروف","balance":"الرصيد","customers":"العملاء","suppliers":"الموردون","emptyCashBook":"هنا يمكنك تسجيل جميع المصروفات والمداخيل اليومية","emptyDebtBook":"هنا يمكنك تسجيل جميع ديون العملاء والموردين.","shareApp":"شارك التطبيق مع التجار","myBusinessWallet":"محفظتي التجارية","walletDesc":"توصل بفلوسك على الفور بكل أمان ومن أي مكان","paymentServices":"خدمات الدفع الالكتروني","paymentDesc":"قدم خدمات دفع الفواتير وشحن الرصيد لعملائك واربح عمولات","businessCard":"بطاقة العمل","inventoryStaff":"المخزون والموظفون","settings":"إعدادات","autoBackup":"نسخ تلقائي","contactUs":"إتصل بنا","aboutApp":"حول التطبيق","addCustomer":"إضافة عميل","addSupplier":"إضافة مورد","importContacts":"استيراد ارقام العملاء","importContactsDesc":"مشاركة أرقام الهاتف مع التطبيق تمكنك من إضافة عملاء جدد بسرعة.","contactsDenied":"لقد قمت بتعطيل إذن الدخول لجهات الاتصال","name":"الاسم","phoneNumber":"رقم الهاتف","address":"العنوان","tags":"التصنيفات","addTags":"إضافة تصنيفات","tagsDesc":"استخدم تصنيفات مخصصة (مثل VIP، جملة، المنطقة) لتصنيف جهات الاتصال الخاصة بك للتجميع والتصفية بسرعة","confirm":"تأكيد","cancel":"إلغاء","owedToMe":"مستحق لي","owedByMe":"مستحق عليّ","given":"مدفوع","taken":"مقبوض","save":"حفظ","amount":"المبلغ","note":"ملاحظة","search":"بحث","version":"الإصدار","language":"اللغة","appearance":"المظهر","light":"فاتح","dark":"داكن","system":"حسب النظام","edit":"تعديل","voidTx":"إلغاء العملية","share":"مشاركة","welcomeTitle":"مرحبا بك في حساباتي","onb1Body":"دفتر لتسهيل تسجيل وتسيير الديون الممنوحة للعملاء والموردين. من أي هاتف وفي أي مكان.","onb2":"كل ديون ومدفوعات العملاء بين يديك في أي وقت بدون الحاجة لسجل الديون.","onb3":"حساب مفصل لجميع العملاء.","onb4":"تذكير بالدفع تلقائي ومجاني عبر الواتساب.","onb5":"إمكانية إضافة ملاحظة وصورة البضاعة أو الفاتورة لكل معاملة.","start":"إبدأ","comingSoon":"قريبًا"}

w('lib/l10n/app_en.arb', json.dumps(en, ensure_ascii=False, indent=2))
w('lib/l10n/app_ar.arb', json.dumps(ar, ensure_ascii=False, indent=2))

w('lib/core/services/settings_service.dart', """import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _localeKey = 'locale';
  static const _themeKey = 'themeMode';
  static const _onboardKey = 'onboarded';

  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  static Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardKey) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardKey, true);
  }
}
""")

w('lib/features/onboarding/language_select_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class LanguageSelectScreen extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const LanguageSelectScreen({super.key, required this.onSelected});

  Widget _langButton(BuildContext context, String label, {String? code}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (code == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
          } else {
            onSelected(code);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _langButton(context, 'Turkish'),
              _langButton(context, 'English', code: 'en'),
              _langButton(context, 'Français'),
              _langButton(context, 'العربية', code: 'ar'),
              _langButton(context, 'مصري'),
            ],
          ),
        ),
      ),
    );
  }
}
""")

w('lib/features/onboarding/onboarding_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingScreen({super.key, required this.onFinished});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _Page(icon: Icons.storefront, title: l10n.welcomeTitle, body: l10n.onb1Body),
      _Page(icon: Icons.account_balance_wallet, title: '', body: l10n.onb2),
      _Page(icon: Icons.receipt_long, title: '', body: l10n.onb3),
      _Page(icon: Icons.notifications_active, title: '', body: l10n.onb4),
      _Page(icon: Icons.camera_alt, title: '', body: l10n.onb5),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: i == _page ? 14 : 12,
                  height: i == _page ? 14 : 12,
                  decoration: BoxDecoration(
                    color: i == _page ? AppTheme.primaryBlue : AppTheme.primaryBlue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                onPressed: widget.onFinished,
                child: Text(l10n.start, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Page({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 110, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 48),
          if (title.isNotEmpty) ...[
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 16),
          ],
          Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.grey.shade500, height: 1.8)),
        ],
      ),
    );
  }
}
""")

w('lib/features/root_screen.dart', """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app.dart';
import '../core/services/settings_service.dart';
import 'main_shell.dart';
import 'onboarding/language_select_screen.dart';
import 'onboarding/onboarding_screen.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});
  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  String? _stage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final locale = await SettingsService.getLocale();
    final onboarded = await SettingsService.isOnboarded();
    if (!mounted) return;
    setState(() {
      if (locale == null) {
        _stage = 'language';
      } else if (!onboarded) {
        _stage = 'onboarding';
      } else {
        _stage = 'main';
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_stage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_stage == 'language') {
      return LanguageSelectScreen(
        onSelected: (code) {
          ref.read(localeProvider.notifier).state = Locale(code);
          SettingsService.saveLocale(code);
          setState(() => _stage = 'onboarding');
        },
      );
    }
    if (_stage == 'onboarding') {
      return OnboardingScreen(
        onFinished: () {
          SettingsService.setOnboarded();
          setState(() => _stage = 'main');
        },
      );
    }
    return const MainShell();
  }
}
""")

w('lib/app/app.dart', """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../features/root_screen.dart';
import 'theme.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

class DebtCashApp extends ConsumerWidget {
  const DebtCashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Debt & Cash App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootScreen(),
    );
  }
}
""")

print("✅ Onboarding & language selection ready!")
