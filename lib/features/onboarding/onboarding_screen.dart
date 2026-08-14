import 'package:flutter/material.dart';
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
