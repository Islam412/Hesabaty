import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'add_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<Staff> _staff = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final all = realm.all<Staff>().where((s) => s.isActive).toList();
    if (!mounted) return;
    setState(() => _staff = all);
  }

  List<Staff> get _filtered {
    if (_query.isEmpty) return _staff;
    return _staff.where((s) => s.name.toLowerCase().contains(_query.toLowerCase()) || s.role.toLowerCase().contains(_query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = _staff.fold<double>(0.0, (s, e) => s + (e.salaryType == 'monthly' ? e.salary : (e.salaryType == 'weekly' ? e.salary * 4.3 : e.salary * 30)));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.staff)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffScreen()));
          _load();
        },
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _stat('${_staff.length}', l10n.totalEmployees, const Color(0xFF7C4DFF)),
                _stat('${total.toStringAsFixed(0)} ج.م', l10n.monthlySalaries, const Color(0xFFE5A83B)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(hintText: 'بحث...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('لا يوجد موظفون', style: TextStyle(color: Colors.grey.shade500)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final s = _filtered[i];
                      final initials = s.name.isNotEmpty ? s.name.substring(0, 1) : '?';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffDetailsScreen(staff: s, onDone: _load))),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.15),
                                  child: Text(initials, style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      Text(s.role, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${s.salary.toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(s.salaryType == 'monthly' ? l10n.monthly : (s.salaryType == 'weekly' ? l10n.weekly : l10n.daily), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
