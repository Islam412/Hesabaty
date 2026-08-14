import 'dart:io';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final double amount;
  final DateTime date;
  final String? note;
  final String? imagePath;
  final Color color;
  final String title;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionDetailsScreen({
    super.key,
    required this.amount,
    required this.date,
    this.note,
    this.imagePath,
    required this.color,
    required this.title,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat('yyyy-MM-dd  HH:mm', locale);
    final hasImage = imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onEdit != null) IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              '${amount.toStringAsFixed(2)} ج.م',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        dateFmt.format(date),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  if (note != null && note!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(note!, style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: Row(
                      children: [
                        const Icon(Icons.image, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.note, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(),
                          backgroundColor: Colors.black,
                          body: Center(
                            child: InteractiveViewer(
                              child: Image.file(File(imagePath!)),
                            ),
                          ),
                        ),
                      ));
                    },
                    child: Image.file(File(imagePath!), fit: BoxFit.cover, height: 280),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: Text(l10n.share),
            onPressed: () async {
              final text = '$title\n${amount.toStringAsFixed(2)} ج.م\n${dateFmt.format(date)}\n${note ?? ''}';
              if (hasImage) {
                await Share.shareXFiles([XFile(imagePath!)], text: text);
              } else {
                await Share.share(text);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
