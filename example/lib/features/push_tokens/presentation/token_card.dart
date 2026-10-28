import 'dart:ffi';

import 'package:example_flutter/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/token_controller.dart';

/// Manual token operations for the configured Android example.
class TokenCard extends ConsumerWidget {
  const TokenCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tokenControllerProvider);
    final controller = ref.read(tokenControllerProvider.notifier);
    final token = state.asData?.value;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Push token · ${appFlavor ?? "unknown"}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.textEditBackground,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsetsGeometry.all(16),
              child: switch (state) {
                _ when state.isLoading => const LinearProgressIndicator(),
                _ when state.hasError => Text(
                  'Token operation failed: ${state.error}',
                  style: const TextStyle(color: AppColors.alertNotificationRed),
                ),
                _ when token != null => SelectableText(token),
                _ => const Text('Get a token from the selected push provider.'),
              },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: state.isLoading ? null : controller.refresh,
                child: const Text('Get token'),
              ),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await controller.refresh(track: true);
                        if (!context.mounted) return;
                        if (ref.read(tokenControllerProvider).hasError) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Token sent to Sendsay'),
                          ),
                        );
                      },
                child: const Text('Send to Sendsay'),
              ),
              IconButton(
                tooltip: 'Copy token',
                onPressed: token == null
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: token));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token copied')),
                        );
                      },
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
