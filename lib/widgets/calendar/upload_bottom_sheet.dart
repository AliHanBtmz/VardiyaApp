import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shift_provider.dart';
import '../shift_dialog.dart';

class UploadBottomSheet extends StatelessWidget {
  const UploadBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShiftProvider>(context, listen: false);
    final userNameController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.cloud_upload, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              const Text('Vardiya Yükle', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: userNameController,
            decoration: const InputDecoration(
              labelText: 'Personel Adı',
              hintText: 'Vardiyada aranacak isim',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 24),
          _buildUploadOption(
            context,
            icon: Icons.image,
            title: 'Resim Yükle',
            subtitle: 'Galeriden vardiya listesi seçin',
            onTap: () {
              Navigator.pop(context);
              if (userNameController.text.isNotEmpty) {
                provider.processImageUpload(userNameController.text);
              } else {
                _showError(context, 'Lütfen isim girin');
              }
            },
          ),
          const SizedBox(height: 12),
          _buildUploadOption(
            context,
            icon: Icons.table_chart,
            title: 'Excel Yükle',
            subtitle: 'Excel dosyası yükleyin',
            onTap: () {
              Navigator.pop(context);
              if (userNameController.text.isNotEmpty) {
                provider.processExcelUpload(userNameController.text);
              } else {
                _showError(context, 'Lütfen isim girin');
              }
            },
          ),
          const SizedBox(height: 12),
          _buildUploadOption(
            context,
            icon: Icons.edit,
            title: 'Manuel Ekle',
            subtitle: 'Elle tek tek giriş yapın',
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const ShiftDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.7), fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
