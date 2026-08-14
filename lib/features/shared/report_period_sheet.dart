import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class ReportPeriodSheet extends StatefulWidget {
  const ReportPeriodSheet({super.key});
  @override
  State<ReportPeriodSheet> createState() => _ReportPeriodSheetState();
}

class _ReportPeriodSheetState extends State<ReportPeriodSheet> {
  DateTime? _from;
  DateTime? _to;

  Future<void> _pick(bool from) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() { if (from) { _from = d; } else { _to = d; } });
  }

  Widget _btn(String label, VoidCallback onTap, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryBlue : null,
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: active ? Colors.white : null))),
        ),
      ),
    );
  }

  DateTimeRange _range(DateTime s, DateTime e) => DateTimeRange(start: s, end: e);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final t0 = DateTime(now.year, now.month, now.day);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.reportPeriod, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _btn('${l10n.startDate}${_from == null ? '' : ': ${_from!.day}/${_from!.month}'}', () => _pick(true))),
                Expanded(child: _btn('${l10n.endDate}${_to == null ? '' : ': ${_to!.day}/${_to!.month}'}', () => _pick(false))),
              ],
            ),
            if (_from != null && _to != null)
              _btn(l10n.apply, () => Navigator.pop(context, _range(_from!, _to!)), active: true),
            _btn(l10n.allDates, () => Navigator.pop(context, 'all')),
            Row(children: [
              Expanded(child: _btn(l10n.today, () => Navigator.pop(context, _range(t0, now)))),
              Expanded(child: _btn(l10n.yesterday, () => Navigator.pop(context, _range(t0.subtract(const Duration(days: 1)), t0)))),
            ]),
            Row(children: [
              Expanded(child: _btn(l10n.thisWeek, () => Navigator.pop(context, _range(t0.subtract(Duration(days: now.weekday - 1)), now)))),
              Expanded(child: _btn(l10n.lastWeek, () => Navigator.pop(context, _range(t0.subtract(Duration(days: now.weekday + 6)), t0.subtract(Duration(days: now.weekday)))))),
            ]),
            Row(children: [
              Expanded(child: _btn(l10n.thisMonth, () => Navigator.pop(context, _range(DateTime(now.year, now.month, 1), now)))),
              Expanded(child: _btn(l10n.lastMonth, () => Navigator.pop(context, _range(DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 0))))),
            ]),
            Row(children: [
              Expanded(child: _btn(l10n.thisYear, () => Navigator.pop(context, _range(DateTime(now.year, 1, 1), now)))),
              Expanded(child: _btn(l10n.lastYear, () => Navigator.pop(context, _range(DateTime(now.year - 1, 1, 1), DateTime(now.year - 1, 12, 31))))),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
