import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import 'inventory_screen.dart';
import 'staff_screen.dart';

class InventoryStaffHub extends StatelessWidget {
  const InventoryStaffHub({super.key});

  Widget _bigCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required List<IconData> subIcons,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: subIcons.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(i, color: color, size: 18),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.inventoryStaff), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8), const Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.inventory_2, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إدارة عملك', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('المخزون والموظفون في مكان واحد', style: TextStyle(color: Color(0xFFDCE9FF), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _bigCard(context,
            title: l10n.inventory,
            subtitle: '${l10n.products} • ${l10n.stock} • ${l10n.stockMovement}',
            icon: Icons.inventory_2,
            color: const Color(0xFFE5A83B),
            subIcons: const [Icons.add_box, Icons.remove_circle, Icons.bar_chart],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
          ),
          _bigCard(context,
            title: l10n.staff,
            subtitle: '${l10n.employees} • ${l10n.salary} • ${l10n.attendance}',
            icon: Icons.groups,
            color: const Color(0xFF7C4DFF),
            subIcons: const [Icons.person_add, Icons.payments, Icons.calendar_today],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen())),
          ),
        ],
      ),
    );
  }
}
