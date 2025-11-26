import 'package:flutter/material.dart';
import 'package:sendsay/sendsay.dart';

class LogLevelBlock extends StatefulWidget {
  final Function(BuildContext) logLevelCall;
  final ValueNotifier<LogLevel?> logLevelController;

  const LogLevelBlock({super.key, required this.logLevelController, required this.logLevelCall});

  @override
  State<LogLevelBlock> createState() => _LogLevelBlockState();
}

class _LogLevelBlockState extends State<LogLevelBlock> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Log Level'),
      subtitle: Row(
        children: [
          ElevatedButton(
            onPressed: () => widget.logLevelCall(context),
            child: const Text('Get'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<LogLevel?>(
              valueListenable: widget.logLevelController,
              builder: (context, selected, _) => Row(
                children: [
                  DropdownButton<LogLevel>(
                    value: selected,
                    onChanged: (value) =>
                    widget.logLevelController.value = value,
                    items: LogLevel.values
                        .map(
                          (level) => DropdownMenuItem<LogLevel>(
                        value: level,
                        child: Text(level.toString()),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
