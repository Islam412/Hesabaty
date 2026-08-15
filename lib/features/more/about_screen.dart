import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _version = '1.0.0';

  // ===== بيانات مالك التطبيق =====
  static const String ownerName = 'أ. إسلام الصولي';
  static const String ownerCompany = 'أبو حمزة المواد التغليف';
  static const String ownerPhoneDisplay = '01155583620';
  static const String ownerWhatsapp = '201155583620';
  static const String ownerPhoneRaw = '+201155583620';
  static const String ownerAddress = 'شارع صلاح سالم بجوار توكيل بجاج — الحوامدية، الجيزة';

  // ===== بيانات مطور التطبيق =====
  static const String devName = 'م. إسلام حمدي';
  static const String devTitle = 'مطور التطبيق';
  static const String devPhoneDisplay = '01127782279';
  static const String devWhatsapp = '201127782279';
  static const String devPhoneRaw = '+201127782279';
  static const String devPortfolio = 'https://islam-portfolio-phi.vercel.app/';

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
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.4), width: 2)),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 62),
                          ),
                          const SizedBox(height: 12),
                          const Text('حساباتي', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
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
                  // ===== مميزات التطبيق =====
                  _sectionTitle(l10n.aboutFeatures, Icons.star),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _feature(Icons.account_balance_wallet, const Color(0xFF16A34A), l10n.featCash),
                      _feature(Icons.book, const Color(0xFF2E7CF6), l10n.featDebt),
                      _feature(Icons.account_balance, const Color(0xFF7C4DFF), l10n.featWallet),
                      _feature(Icons.receipt_long, const Color(0xFFFF7043), l10n.featBills),
                      _feature(Icons.inventory_2, const Color(0xFFE5A83B), l10n.featInventory),
                      _feature(Icons.groups, const Color(0xFFE91E63), l10n.featStaff),
                      _feature(Icons.notifications_active, const Color(0xFFDC2626), l10n.featNotif),
                      _feature(Icons.backup, const Color(0xFF00BCD4), l10n.featBackup),
                      _feature(Icons.fingerprint, const Color(0xFF5E35B1), l10n.featLock),
                      _feature(Icons.contact_page, const Color(0xFF009688), l10n.featCard),
                      _feature(Icons.picture_as_pdf, const Color(0xFFD84315), l10n.featPdf),
                      _feature(Icons.people, const Color(0xFF3F51B5), l10n.featAccounts),
                      _feature(Icons.dark_mode, const Color(0xFF607D8B), l10n.featDark),
                      _feature(Icons.language, const Color(0xFF795548), l10n.featLang),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ===== مالك التطبيق =====
                  _sectionTitle(l10n.ownerSection, Icons.workspace_premium),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE5A83B), Color(0xFFC77800)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.25), child: const Text('إ', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold))),
                            Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF16A34A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.verified, color: Colors.white, size: 16))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.ownerName, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(ownerCompany, style: const TextStyle(color: Color(0xFFFFF3E0), fontSize: 14)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionBtn(Icons.chat_bubble, const Color(0xFF25D366), l10n.whatsapp, () => _open('https://wa.me/$ownerWhatsapp')),
                            const SizedBox(width: 12),
                            _actionBtn(Icons.phone, Colors.white, l10n.call, () => _open('tel:$ownerPhoneRaw')),
                            const SizedBox(width: 12),
                            _actionBtn(Icons.map, const Color(0xFFD84315), 'الخريطة', () => _open('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(ownerAddress)}')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _open('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(ownerAddress)}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.location_on, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Flexible(child: Text(ownerAddress, style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== مطور التطبيق =====
                  _sectionTitle(l10n.devSection, Icons.code),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5E35B1), Color(0xFF2E7CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.2), child: const Text('م', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 10),
                        Text(l10n.devName, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(l10n.devSection, style: const TextStyle(color: Color(0xFFE1BEE7), fontSize: 14)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionBtn(Icons.chat_bubble, const Color(0xFF25D366), l10n.whatsapp, () => _open('https://wa.me/$devWhatsapp')),
                            const SizedBox(width: 12),
                            _actionBtn(Icons.phone, Colors.white, l10n.call, () => _open('tel:$devPhoneRaw')),
                            const SizedBox(width: 12),
                            _actionBtn(Icons.work, const Color(0xFFE5A83B), 'البورتفوليو', () => _open(devPortfolio)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _open(devPortfolio),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Text('🌐 islam-portfolio-phi.vercel.app', style: TextStyle(color: Colors.white, fontSize: 12), textDirection: TextDirection.ltr),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== التذييل =====
                  Center(
                    child: Column(
                      children: [
                        Text(l10n.rightsOwner, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(l10n.devLine, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.primaryBlue, size: 20)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
      ],
    );
  }

  Widget _feature(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.15))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: color.withOpacity(0.25), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5))),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
