import 'package:flutter/material.dart';

class PushEventsBlock extends StatefulWidget {
  final ValueNotifier<String> pushController;
  final Function(BuildContext) requestPushCallback;
  final Function(BuildContext) isConfiguredCallback;

  const PushEventsBlock(
      {super.key,
      required this.pushController,
      required this.requestPushCallback,
      required this.isConfiguredCallback});

  @override
  State<PushEventsBlock> createState() => _PushEventsBlockState();
}

class _PushEventsBlockState extends State<PushEventsBlock> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          ListTile(
            title: const Text('Push events'),
            subtitle: ValueListenableBuilder<String>(
              valueListenable: widget.pushController,
              builder: (context, value, _) => Text(value),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => widget.requestPushCallback(context),
              child: const Text('Request Push Authorization'),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: () => widget.isConfiguredCallback(context),
              child: const Text('Configured?'),
            ),
          ),
        ]);
  }
}
