import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'add_staff_screen.dart';

class StaffDetailsScreen extends StatefulWidget {
  final Staff staff;
  final VoidCallback onDone;
  const StaffDetailsScreen({super.key, required this.staff, required this.onDone});
  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  List<StaffPayment> _payments = [];
  List<StaffAttendance> _attendance = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final sid = widget.staff.id.toString();
    final p = realm.all<StaffPayment>().where((x) => x.staffId == sid && x.status != 'deleted').toList();
    p.sort((a, b) => b.date.compareTo(a.date));
    final a = realm.all<StaffAttendance>().where((x) => x.staffId == sid).toList();
    a.sort((x, y) => y.date.compareTo(x.date));
    if (!mounted) return;
    setState(() { _payments = p; _attendance = a; });
  }

  Future<void> _paySalary() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = TextEditingController(text: widget.staff.salary.toString());
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.paySalary),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.salary, border: const OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: note, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save))],
    ));
    if (ok != true) return;
    final a = double.tryParse(amount.text) ?? 0;
    if (a <= 0) return;
    final realm = await RealmService.realm;
    realm.write(() {
      realm.add(StaffPayment(ObjectId(), widget.staff.id.toString(), a, 'salary', DateTime.now(), 'active', note: note.text.trim().isEmpty ? null : note.text.trim()));
    });
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.paySalary} ✓'), backgroundColor: AppTheme.incomeGreen));
    }
  }

  Future<void> _markAttendance() async {
    final l10n = AppLocalizations.of(context)!;
    DateTime date = DateTime.now();
    String status = 'present';
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx2, setS) => AlertDialog(
      title: Text(l10n.attendance),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        InkWell(
          onTap: () async {
            final d = await showDatePicker(context: ctx2, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now());
            if (d != null) setS(() => date = d);
          },
          child: InputDecorator(decoration: InputDecoration(labelText: 'التاريخ', border: const OutlineInputBorder()), child: Text('${date.day}/${date.month}/${date.year}')),
        ),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'present', label: Text(l10n.present), icon: const Icon(Icons.check)),
            ButtonSegment(value: 'absent', label: Text(l10n.absent), icon: const Icon(Icons.close)),
            ButtonSegment(value: 'leave', label: Text(l10n.leave), icon: const Icon(Icons.beach_access)),
          ],
          selected: {status},
          onSelectionChanged: (v) => setS(() => status = v.first),
        ),
        const SizedBox(height: 10),
        TextField(controller: note, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save))],
    )));
    if (ok != true) return;
    final realm = await RealmService.realm;
    realm.write(() {
      realm.add(StaffAttendance(ObjectId(), widget.staff.id.toString(), date, status, note: note.text.trim().isEmpty ? null : note.text.trim()));
    });
    _load();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف'),
      content: const Text('تأكيد إلغاء الموظف؟'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف'))],
    ));
    if (ok != true) return;
    final realm = await RealmService.realm;
    realm.write(() => widget.staff.isActive = false);
    widget.onDone();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.staff;
    final paid = _payments.fold<double>(0.0, (sum, p) => sum + p.amount);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => AddStaffScreen(staff: s)));
            widget.onDone();
            if (mounted) setState(() {});
          }),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(radius: 36, backgroundColor: Colors.white.withOpacity(0.2), child: Text(s.name.isNotEmpty ? s.name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(s.role, style: const TextStyle(color: Color(0xFFE1BEE7))),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _infoChip(l10n.salary, '${s.salary.toStringAsFixed(0)} ${Cur.v}'),
                  const SizedBox(width: 8),
                  _infoChip(s.salaryType == 'monthly' ? l10n.monthly : (s.salaryType == 'weekly' ? l10n.weekly : l10n.daily), ''),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _stat('إجمالي المصروف', '${paid.toStringAsFixed(0)} ${Cur.v}', AppTheme.expenseRed),
            _stat('الحضور', '${_attendance.length}', AppTheme.incomeGreen),
          ]),
          if (s.phone != null) _detailRow(Icons.phone, l10n.phoneNumber, s.phone!),
          if (s.address != null) _detailRow(Icons.location_on, l10n.address, s.address!),
          _detailRow(Icons.calendar_today, l10n.joinDate, '${s.joinDate.day}/${s.joinDate.month}/${s.joinDate.year}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.incomeGreen.withOpacity(0.85), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _paySalary,
                icon: const Icon(Icons.payments),
                label: Text(l10n.paySalary),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _markAttendance,
                icon: const Icon(Icons.event_available),
                label: Text(l10n.attendance),
              )),
            ],
          ),
          const SizedBox(height: 20),
          Text('سجل الرواتب', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_payments.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('لا توجد رواتب بعد', style: TextStyle(color: Colors.grey.shade500))))
          else
            ..._payments.take(5).map((p) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.expenseRed.withOpacity(0.15), child: const Icon(Icons.payments, color: AppTheme.expenseRed)),
                title: Text('${p.amount.toStringAsFixed(2)} ${Cur.v}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${p.date.day}/${p.date.month}/${p.date.year}${p.note != null ? ' • ${p.note}' : ''}', style: const TextStyle(fontSize: 12)),
              ),
            )),
          const SizedBox(height: 20),
          Text(l10n.attendance, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_attendance.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('لا يوجد تسجيل حضور', style: TextStyle(color: Colors.grey.shade500))))
          else
            ..._attendance.take(10).map((a) {
              final c = a.status == 'present' ? AppTheme.incomeGreen : (a.status == 'absent' ? AppTheme.expenseRed : const Color(0xFFFF7043));
              final label = a.status == 'present' ? l10n.present : (a.status == 'absent' ? l10n.absent : l10n.leave);
              final icon = a.status == 'present' ? Icons.check : (a.status == 'absent' ? Icons.close : Icons.beach_access);
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: c.withOpacity(0.15), child: Icon(icon, color: c)),
                  title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: c)),
                  subtitle: Text('${a.date.day}/${a.date.month}/${a.date.year}${a.note != null ? ' • ${a.note}' : ''}', style: const TextStyle(fontSize: 12)),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Text('$label${value.isNotEmpty ? ': $value' : ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
