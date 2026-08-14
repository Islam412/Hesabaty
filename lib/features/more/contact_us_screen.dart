import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/services/share_service.dart';

// ===== بيانات صاحب التطبيق =====
const String kOwnerName = 'إسلام الصولي';
const String kOwnerCompany = 'ابو حمزه المواد التغليف';
const String kOwnerPhoneDisplay = '01155583620';
const String kOwnerWhatsApp = '201155583620';
const String kOwnerAddress = 'شارع صلاح سالم بجوار توكيل بچاچ الحوامدية';

// ===== بيانات الشركة المطورة =====
const String kDevCompany = 'Corvix';
const String kDevPortfolio = ''; // حط لينك بورتفوليو شركة Corvix هنا لما يتوفر

// ===== بيانات المهندس المصمم =====
const String kEngineerName = 'اسلام حمدي';
const String kEngineerPhoneDisplay = '01127782279';
const String kEngineerWhatsApp = '201127782279';
const String kEngineerPortfolio = 'https://islam-portfolio-phi.vercel.app/';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cantOpen), backgroundColor: AppTheme.expenseRed));
      }
    }
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _personCard(BuildContext context, {
    required String title,
    required String name,
    String? subtitle,
    required IconData avatar,
    required Color color,
    required List<Widget> actions,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 24, child: Icon(avatar, color: color, size: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      if (subtitle != null) Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: actions),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(kOwnerAddress)}';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactUs)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== صاحب التطبيق =====
          _personCard(
            context,
            title: l10n.appOwner,
            name: kOwnerName,
            subtitle: kOwnerCompany,
            avatar: Icons.store,
            color: const Color(0xFFE5A83B),
            actions: [
              _actionBtn(context, Icons.chat, l10n.whatsapp, const Color(0xFF25D366), () => _launch(context, 'https://wa.me/$kOwnerWhatsApp?text=${Uri.encodeComponent('السلام عليكم 🌹 استفسار عن تطبيق حساباتي')}')),
              const SizedBox(width: 8),
              _actionBtn(context, Icons.phone, l10n.call, AppTheme.primaryBlue, () => _launch(context, 'tel:+$kOwnerWhatsApp')),
              const SizedBox(width: 8),
              _actionBtn(context, Icons.map, l10n.openMap, const Color(0xFFFF7043), () => _launch(context, mapUrl)),
            ],
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFFF7043), size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(kOwnerAddress, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
                ],
              ),
            ),
          ),

          // ===== الشركة المطورة =====
          _personCard(
            context,
            title: l10n.devCompany,
            name: kDevCompany,
            subtitle: 'Software Solutions',
            avatar: Icons.business,
            color: const Color(0xFF7C4DFF),
            actions: [
              if (kDevPortfolio.isNotEmpty)
                _actionBtn(context, Icons.language, l10n.portfolio, const Color(0xFF7C4DFF), () => _launch(context, kDevPortfolio))
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('corvix © ${DateTime.now().year}', style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 14))),
                  ),
                ),
            ],
          ),

          // ===== المهندس المصمم =====
          _personCard(
            context,
            title: l10n.appEngineer,
            name: kEngineerName,
            subtitle: 'Flutter Developer',
            avatar: Icons.engineering,
            color: AppTheme.primaryBlue,
            actions: [
              _actionBtn(context, Icons.chat, l10n.whatsapp, const Color(0xFF25D366), () => _launch(context, 'https://wa.me/$kEngineerWhatsApp?text=${Uri.encodeComponent('السلام عليكم 🌹 بخصوص تطبيق حساباتي')}')),
              const SizedBox(width: 8),
              _actionBtn(context, Icons.phone, l10n.call, AppTheme.primaryBlue, () => _launch(context, 'tel:+$kEngineerWhatsApp')),
              const SizedBox(width: 8),
              _actionBtn(context, Icons.language, l10n.portfolio, const Color(0xFF00BCD4), () => _launch(context, kEngineerPortfolio)),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => _launch(context, 'market://details?id=com.hesabaty.app'),
                  icon: const Icon(Icons.star, color: Color(0xFFFFC107)),
                  label: Text(l10n.rateApp),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => ShareService.shareText(context, '📒 تطبيق حساباتي — دفتر النقدية والديون والمحفظة في تطبيق واحد!\nصاحب التطبيق: $kOwnerName — $kOwnerCompany\nتطوير: $kDevCompany | تصميم: $kEngineerName'),
                  icon: const Icon(Icons.share, color: AppTheme.primaryBlue),
                  label: Text(l10n.shareApp),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(l10n.faq, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...[
            {'q': 'هل بياناتي آمنة؟', 'a': 'نعم ✅ كل بياناتك متخزنة على جهازك فقط في قاعدة بيانات مشفرة، ومفيش أي حاجة بترفع على الإنترنت غير لما تعمل مشاركة بنفسك.'},
            {'q': 'كيف أعمل نسخة احتياطية؟', 'a': 'من المزيد ← الإعدادات ← النسخ الاحتياطي التلقائي شغال يوميًا، وتقدر تعمل تصدير واستعادة يدوي في أي وقت.'},
            {'q': 'كيف أشارك كشف حساب مع عميل؟', 'a': 'افتح العميل ← زرار المشاركة هيبعت صورة الكشف + لينك فيه كل العمليات وطرق الدفع.'},
            {'q': 'كيف أدفع الفواتير من التطبيق؟', 'a': 'المزيد ← خدمات الدفع الإلكتروني ← دفع الفواتير والشحن ← اختار الخدمة واكتب الرقم والمبلغ.'},
          ].map((f) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Theme(
                  data: ThemeData(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(f['a']!, style: TextStyle(color: Colors.grey.shade600, height: 1.6)))],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Center(child: Text('${l10n.aboutApp} — ${l10n.version} 1.0.0', style: TextStyle(color: Colors.grey.shade400, fontSize: 12))),
        ],
      ),
    );
  }
}
