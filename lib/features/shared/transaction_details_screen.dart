import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/receipt_card.dart';
import '../more/image_export_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            tooltip: 'حفظ / مشاركة كصورة 🖼️',
            onPressed: () => _openExport(context),
          ),
          if (onEdit != null) IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          if (onDelete != null)
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // الإيصال كصورة أنيقة دايمًا
          ReceiptCard(
            title: title,
            amount: amount,
            currency: Cur.v,
            date: date,
            note: note,
            color: color,
          ),
          // لو فيه صورة مرفقة من العملية نفسها نعرضها كمان
          if (imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync()) ...[
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openExport(context),
                child: Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.incomeGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _openExport(context),
            icon: const Icon(Icons.share),
            label: const Text('حفظ / مشاركة الإيصال كصورة', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _openExport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageExportScreen(
          child: ReceiptCard(
            title: title,
            amount: amount,
            currency: Cur.v,
            date: date,
            note: note,
            color: color,
          ),
          fileName: 'receipt',
        ),
      ),
    );
  }
}
