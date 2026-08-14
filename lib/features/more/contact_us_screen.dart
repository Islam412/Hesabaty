import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/services/share_service.dart';

// ⚠️ غيّر دول لبيانات الدعم بتاعتك
const String kSupportWhatsApp = '201127782279';
const String kSupportPhone = '+201127782279';
const String kSupportEmail = 'support@hesabaty.app';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    final u = Uri.parse(url);
    try {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cantOpen), backgroundColor: AppTheme.expenseRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactUs)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 12),
                const Text('حساباتي', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${l10n.version} 1.0.0', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(backgroundColor: const Color(0xFF25D366).withOpacity(0.15), child: const Icon(Icons.chat, color: Color(0xFF25D366))),
                  title: Text(l10n.supportWhatsApp, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('+$kSupportWhatsApp', textDirection: TextDirection.ltr),
                  trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                  onTap: () => _launch(context, 'https://wa.me/$kSupportWhatsApp?text=${Uri.encodeComponent('استفسار عن تطبيق حساباتي 🙋‍♂️')}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.15), child: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue)),
                  title: Text(l10n.supportEmail, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(kSupportEmail, textDirection: TextDirection.ltr),
                  trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                  onTap: () => _launch(context, 'mailto:$kSupportEmail?subject=${Uri.encodeComponent('استفسار - تطبيق حساباتي')}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.incomeGreen.withOpacity(0.15), child: const Icon(Icons.phone, color: AppTheme.incomeGreen)),
                  title: Text(l10n.callSupport, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(kSupportPhone, textDirection: TextDirection.ltr),
                  trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                  onTap: () => _launch(context, 'tel:$kSupportPhone'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                  onPressed: () => ShareService.shareText(context, '📒 تطبيق حساباتي — دفتر النقدية والديون والمحفظة في تطبيق واحد!\nحمّله دلوقتي: https://hesabaty.app'),
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
          Center(child: Text(l10n.aboutApp, style: TextStyle(color: Colors.grey.shade400, fontSize: 12))),
        ],
      ),
    );
  }
}
