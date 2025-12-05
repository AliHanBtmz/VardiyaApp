import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shift_provider.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late TextEditingController _keyController;
  late TextEditingController _modelController;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShiftProvider>(context, listen: false);
    _keyController = TextEditingController(text: provider.hasApiKey ? '********' : '');
    _modelController = TextEditingController(text: provider.currentModelName);
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          const Text('Ayarlar'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _keyController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: const InputDecoration(
              labelText: 'Google Gemini API Key',
              hintText: 'API Key Girin',
              prefixIcon: Icon(Icons.vpn_key),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              setState(() {
                _showAdvanced = !_showAdvanced;
              });
            },
            child: Row(
              children: [
                Text(
                  'Gelişmiş Ayarlar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _showAdvanced ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          if (_showAdvanced) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _modelController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: const InputDecoration(
                labelText: 'Model İsmi',
                hintText: 'örn: gemini-2.5-flash',
                prefixIcon: Icon(Icons.psychology),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Varsayılan: gemini-2.5-flash',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            final provider = Provider.of<ShiftProvider>(context, listen: false);
            String? newKey;
            if (_keyController.text.isNotEmpty && _keyController.text != '********') {
              newKey = _keyController.text;
            }
            
            provider.updateSettings(
              apiKey: newKey,
              modelName: _modelController.text.isNotEmpty ? _modelController.text : null,
            );
            Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
