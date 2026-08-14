import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class AddStaffScreen extends StatefulWidget {
  final Staff? staff;
  const AddStaffScreen({super.key, this.staff});
  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _salary = TextEditingController();
  String _type = 'monthly';
  DateTime _join = DateTime.now();

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    if (s != null) {
      _name.text = s.name; _role.text = s.role; _phone.text = s.phone ?? '';
      _address.text = s.address ?? ''; _salary.text = s.salary.toString();
      _type = s.salaryType; _join = s.joinDate;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.employeeName} مطلوب'), backgroundColor: AppTheme.expenseRed));
      return;
    }
    final realm = await RealmService.realm;
    realm.write(() {
      if (widget.staff == null) {
        realm.add(Staff(
          ObjectId(), 'business_1',
          _name.text.trim(), _role.text.trim(),
          double.tryParse(_salary.text) ?? 0, _type, _join, true, DateTime.now(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        ));
      } else {
        final s = widget.staff!;
        s.name = _name.text.trim(); s.role = _role.text.trim();
        s.phone = _phone.text.trim().isEmpty ? null : _phone.text.trim();
        s.address = _address.text.trim().isEmpty ? null : _address.text.trim();
        s.salary = double.tryParse(_salary.text) ?? 0; s.salaryType = _type; s.joinDate = _join;
      }
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.save} ✓'), backgroundColor: AppTheme.incomeGreen));
    Navigator.pop(context);
  }

  Widget _field(TextEditingController c, String label, {TextInputType? kb}) {
    return TextField(controller: c, keyboardType: kb, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.staff == null ? l10n.addEmployee : l10n.editEmployee)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, l10n.employeeName),
          const SizedBox(height: 12),
          _field(_role, l10n.role),
          const SizedBox(height: 12),
          _field(_phone, l10n.phoneNumber, kb: TextInputType.phone),
          const SizedBox(height: 12),
          _field(_address, l10n.address),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(_salary, l10n.salary, kb: const TextInputType.numberWithOptions(decimal: true))),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(labelText: l10n.salaryType, border: const OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
              ],
              onChanged: (v) => setState(() => _type = v!),
            )),
          ]),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _join, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => _join = d);
            },
            child: InputDecorator(decoration: InputDecoration(labelText: l10n.joinDate, border: const OutlineInputBorder()), child: Text('${_join.day}/${_join.month}/${_join.year}')),
          ),
          const SizedBox(height: 20),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _save, child: Text(l10n.save, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
