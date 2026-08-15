import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.6, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(left: -40, top: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
              Positioned(right: -50, bottom: -70, child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.35), width: 2)),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 80),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(opacity: _fade, child: const Text('حساباتي', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800))),
                    const SizedBox(height: 8),
                    FadeTransition(opacity: _fade, child: Text('دفتر النقدية والديون والمحفظة', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15))),
                    const SizedBox(height: 40),
                    const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: FadeTransition(opacity: _fade, child: Center(child: Text('تطوير م. إسلام حمدي — تصميم م. اسلام حمدي', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
