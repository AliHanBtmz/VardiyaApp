import 'package:flutter/material.dart';
import '../api_key_dialog.dart';

class ApiKeyBanner extends StatelessWidget {
  const ApiKeyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text('Gemini API anahtarı eksik. Otomatik vardiya analizi çalışmayacaktır.'),
      leading: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      contentTextStyle: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      actions: [
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const ApiKeyDialog(),
            );
          },
          child: const Text('ANAHTAR GİR'),
        ),
      ],
    );
  }
}
