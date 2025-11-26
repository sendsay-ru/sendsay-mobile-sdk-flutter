import 'package:flutter/material.dart';

class DefaultPropsBlock extends StatelessWidget {
  final Function(BuildContext) getDefPropsCall;
  final Function(BuildContext) setDefPropsCall;

  const DefaultPropsBlock({
    super.key,
    required this.getDefPropsCall,
    required this.setDefPropsCall,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Default Properties'),
      subtitle: Row(
        children: [
          ElevatedButton(
            onPressed: () => getDefPropsCall(context),
            child: const Text('Get'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => setDefPropsCall(context),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
