import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/services/share_service.dart';

// ===== بيانات صاحب التطبيق =====
const String kOwnerName = 'إسلام الصولي';
const String kOwnerCompany = 'ابو حمزه المواد التغليف';
const String kOwnerWhatsApp = '201155583620';
const String kOwnerAddress = 'شارع صلاح سالم بجوار توكيل بچاچ الحوامدية';

// ===== بيانات الشركة المطورة =====
const String kDevCompany = 'Corvix';
const String kDevPortfolio = '';

// ===== بيانات المهندس المصمم =====
const String kEngineerName = 'اسلام حمدي';
const String kEngineerWhatsApp = '201127782279';
const String kEngineerPortfolio = 'https://islam-portfolio-phi.vercel.app/';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cantOpen), backgroundColor: AppTheme.expenseRed));
      }
    }
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: color.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _circleAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.45), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _personCard(BuildContext context, {
    required String role,
    required String name,
    String? subtitle,
    required IconData avatar,
    required Color color,
    required List<Widget> actions,
    List<Widget> extra = const [],
  }) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 74,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.9), color.withOpacity(0.55)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    Positioned(left: -20, top: -30, child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                    Positioned(right: -15, bottom: -35, child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                    Positioned(
                      left: 14,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 44,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: color,
                      child: Icon(avatar, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 38),
          Text(name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: actions),
          ),
          ...extra,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(kOwnerAddress)}';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactUs), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== الهيدر =====
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned(left: -30, top: -50, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                Positioned(right: -25, bottom: -60, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 10),
                    const Text('حساباتي', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('دفتر النقدية والديون والمحفظة في تطبيق واحد', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(14)),
                      child: Text('${l10n.version} 1.0.0', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== صاحب التطبيق =====
          _sectionTitle(context, Icons.store, l10n.appOwner, const Color(0xFFE5A83B)),
          _personCard(
            context,
            role: l10n.appOwner,
            name: kOwnerName,
            subtitle: kOwnerCompany,
            avatar: Icons.storefront,
            color: const Color(0xFFE5A83B),
            actions: [
              _circleAction(context, Icons.chat_bubble, l10n.whatsapp, const Color(0xFF25D366), () => _open(context, 'https://wa.me/$kOwnerWhatsApp?text=${Uri.encodeComponent('السلام عليكم 🌹 استفسار عن تطبيق حساباتي')}')),
              _circleAction(context, Icons.phone_in_talk, l10n.call, AppTheme.primaryBlue, () => _open(context, 'tel:+$kOwnerWhatsApp')),
              _circleAction(context, Icons.map_rounded, l10n.openMap, const Color(0xFFFF7043), () => _open(context, mapUrl)),
            ],
            extra: [
              InkWell(
                onTap: () => _open(context, mapUrl),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043).withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFFFF7043), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(kOwnerAddress, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.5))),
                      const Icon(Icons.open_in_new, color: Color(0xFFFF7043), size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ===== الشركة المطورة =====
          _sectionTitle(context, Icons.business_rounded, l10n.devCompany, const Color(0xFF7C4DFF)),
          _personCard(
            context,
            role: l10n.devCompany,
            name: kDevCompany,
            subtitle: 'Software Solutions',
            avatar: Icons.hub,
            color: const Color(0xFF7C4DFF),
            actions: kDevPortfolio.isNotEmpty
                ? [
                    _circleAction(context, Icons.language, l10n.portfolio, const Color(0xFF7C4DFF), () => _open(context, kDevPortfolio)),
                    _circleAction(context, Icons.mail_outline, l10n.supportEmail, AppTheme.primaryBlue, () => _open(context, 'mailto:info@corvix.dev')),
                  ]
                : [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [const Color(0xFF7C4DFF).withOpacity(0.15), const Color(0xFF7C4DFF).withOpacity(0.05)]),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
                        ),
                        child: Center(child: Text('corvix © ${DateTime.now().year}', style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1))),
                      ),
                    ),
                  ],
          ),

          // ===== المهندس المصمم =====
          _sectionTitle(context, Icons.engineering_rounded, l10n.appEngineer, AppTheme.primaryBlue),
          _personCard(
            context,
            role: l10n.appEngineer,
            name: kEngineerName,
            subtitle: 'Flutter Developer',
            avatar: Icons.code_rounded,
            color: AppTheme.primaryBlue,
            actions: [
              _circleAction(context, Icons.chat_bubble, l10n.whatsapp, const Color(0xFF25D366), () => _open(context, 'https://wa.me/$kEngineerWhatsApp?text=${Uri.encodeComponent('السلام عليكم 🌹 بخصوص تطبيق حساباتي')}')),
              _circleAction(context, Icons.phone_in_talk, l10n.call, AppTheme.primaryBlue, () => _open(context, 'tel:+$kEngineerWhatsApp')),
              _circleAction(context, Icons.language, l10n.portfolio, const Color(0xFF00BCD4), () => _open(context, kEngineerPortfolio)),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => _open(context, 'market://details?id=com.hesabaty.app'),
                  icon: const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
                  label: Text(l10n.rateApp),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => ShareService.shareText(context, '📒 تطبيق حساباتي — دفتر النقدية والديون والمحفظة في تطبيق واحد!\nصاحب التطبيق: $kOwnerName — $kOwnerCompany\nتطوير: $kDevCompany | تصميم: $kEngineerName\nبورتفوليو المهندس: $kEngineerPortfolio'),
                  icon: const Icon(Icons.share_rounded, color: AppTheme.primaryBlue, size: 20),
                  label: Text(l10n.shareApp),
                ),
              ),
            ],
          ),

          // ===== الأسئلة الشائعة =====
          _sectionTitle(context, Icons.quiz_rounded, l10n.faq, AppTheme.incomeGreen),
          ...[
            {'q': 'هل بياناتي آمنة؟', 'a': 'نعم ✅ كل بياناتك متخزنة على جهازك فقط في قاعدة بيانات مشفرة، ومفيش أي حاجة بترفع على الإنترنت غير لما تعمل مشاركة بنفسك.'},
            {'q': 'كيف أعمل نسخة احتياطية؟', 'a': 'من المزيد ← الإعدادات ← النسخ الاحتياطي التلقائي شغال يوميًا، وتقدر تعمل تصدير واستعادة يدوي في أي وقت.'},
            {'q': 'كيف أشارك كشف حساب مع عميل؟', 'a': 'افتح العميل ← زرار المشاركة هيبعت صورة الكشف + لينك فيه كل العمليات وطرق الدفع.'},
            {'q': 'كيف أدفع الفواتير من التطبيق؟', 'a': 'المزيد ← خدمات الدفع الإلكتروني ← دفع الفواتير والشحن ← اختار الخدمة واكتب الرقم والمبلغ.'},
          ].map((f) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Theme(
                  data: ThemeData(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: CircleAvatar(backgroundColor: AppTheme.incomeGreen.withOpacity(0.12), radius: 16, child: Icon(Icons.help_outline, color: AppTheme.incomeGreen, size: 16)),
                    title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(f['a']!, style: TextStyle(color: Colors.grey.shade600, height: 1.7, fontSize: 13)))],
                  ),
                ),
              )),
          const SizedBox(height: 20),

          // ===== الفوتر: تم التطوير بواسطة =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C4DFF).withOpacity(0.08),
                  AppTheme.primaryBlue.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hub, color: Color(0xFF7C4DFF), size: 20),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.code, color: AppTheme.primaryBlue, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.6),
                    children: [
                      const TextSpan(text: 'تم التطوير بواسطة شركة '),
                      TextSpan(text: kDevCompany, style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 15)),
                      const TextSpan(text: '\nبواسطة المهندس '),
                      TextSpan(text: kEngineerName, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _open(context, kEngineerPortfolio),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text('بورتفوليو المهندس', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
