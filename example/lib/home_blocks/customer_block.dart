import 'package:flutter/material.dart';

class CustomerBlock extends StatelessWidget {
  final Function(BuildContext) cookieCall;
  final Function(BuildContext) identifyCall;
  final Function(BuildContext) anonymizeCall;

  const CustomerBlock({
    super.key,
    required this.cookieCall,
    required this.identifyCall,
    required this.anonymizeCall,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Customer'),
      subtitle: Row(
        children: [
          ElevatedButton(
            onPressed: () => cookieCall(context),
            style: const ButtonStyle(
              padding:
                  WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            ),
            child: const Text('Get Cookie'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => identifyCall(context),
            style: const ButtonStyle(
              padding:
                  WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            ),
            child: const Text('Identify'),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ElevatedButton(
              onPressed: () => anonymizeCall(context),
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16)),
              ),
              child: const Text(
                'Anonymize',
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
