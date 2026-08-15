import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _version = '1.0.0';
  static const String _developerName = 'م. إسلام حمدي';
  static const String _company = 'Corvix';
  static const String _whatsapp = '201155583620';
  static const String _telegram = 'corvix_dev';
  static const String _email = 'islam@corvix.dev';
  static const String _github = 'https://github.com/Islam412/Hesabaty';

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8), Color(0xFF5E35B1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(left: -40, top: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                    Positioned(right: -50, bottom: -70, child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 72),
                          ),
                          const SizedBox(height: 16),
                          const Text('حساباتي', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Text('v$_version', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 32),
                        const SizedBox(height: 8),
                        Text(l10n.aboutDesc, style: const TextStyle(fontSize: 15, height: 1.6), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: const [
                            _Chip('دفتر النقدية', Color(0xFF2E7CF6)),
                            _Chip('دفتر الديون', Color(0xFF16A34A)),
                            _Chip('المحفظة', Color(0xFF7C4DFF)),
                            _Chip('المخزون', Color(0xFFE5A83B)),
                            _Chip('الموظفون', Color(0xFFE91E63)),
                            _Chip('النسخ الاحتياطي', Color(0xFF00BCD4)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(l10n.developer, Icons.person_outline),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF5E35B1), Color(0xFF2E7CF6)]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.code, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_developerName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(_company, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(l10n.contactUs, Icons.contact_mail_outlined),
                  const SizedBox(height: 10),
                  _contactTile(
                    icon: Icons.chat_bubble,
                    color: const Color(0xFF25D366),
                    title: l10n.whatsapp,
                    subtitle: '+$_whatsapp',
                    onTap: () => _open('https://wa.me/$_whatsapp'),
                  ),
                  _contactTile(
                    icon: Icons.telegram,
                    color: const Color(0xFF229ED9),
                    title: l10n.telegram,
                    subtitle: '@$_telegram',
                    onTap: () => _open('https://t.me/$_telegram'),
                  ),
                  _contactTile(
                    icon: Icons.mail_outline,
                    color: const Color(0xFFEA4335),
                    title: l10n.email,
                    subtitle: _email,
                    onTap: () => _open('mailto:$_email'),
                  ),
                  _contactTile(
                    icon: Icons.code,
                    color: Colors.black87,
                    title: l10n.github,
                    subtitle: 'Islam412/Hesabaty',
                    onTap: () => _open(_github),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text('${l10n.copyright} © ${DateTime.now().year}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('$_company — All Rights Reserved', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
      ],
    );
  }

  Widget _contactTile({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
