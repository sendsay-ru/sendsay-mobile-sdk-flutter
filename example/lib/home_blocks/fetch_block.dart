import 'package:flutter/material.dart';

class FetchBlock extends StatelessWidget {
  final Function(BuildContext) consentsCall;
  final Function(BuildContext) recommendCall;

  const FetchBlock({
    super.key,
    required this.consentsCall,
    required this.recommendCall,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Fetch'),
      subtitle: Row(
        children: [
          ElevatedButton(
            onPressed: () => consentsCall(context),
            child: const Text('Consents'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => recommendCall(context),
            child: const Text('Recommendations'),
          ),
        ],
      ),
    );
  }
}
