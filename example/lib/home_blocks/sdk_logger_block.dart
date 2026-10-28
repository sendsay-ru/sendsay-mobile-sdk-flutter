import 'package:example_flutter/colors.dart';
import 'package:flutter/material.dart';

class SdkLoggerBlock extends StatefulWidget {
  const SdkLoggerBlock({
    super.key,
    this.logs = const <String>[],
    required this.lastTokenController,
    this.onShareLog,
    this.onGetToken,
    this.logHeight = 200,
  }) : assert(logHeight > 0 && logHeight < double.infinity);

  /// Log messages in chronological order, oldest first.
  /// Supply a new list when messages change and rebuild this widget.
  final List<String> logs;

  /// Hold and show last [getToken] value
  final ValueNotifier<String> lastTokenController;

  /// Shares the displayed logs using the application's sharing implementation.
  ///
  /// Sharing is disabled when this is null or [logs] is empty.
  final Function(List<String>)? onShareLog;

  /// Calls [getToken] from natively connected push SDK service.
  final VoidCallback? onGetToken;

  /// Bounds the log viewport when this panel is inside another scroll view.
  final double logHeight;

  @override
  State<SdkLoggerBlock> createState() => _SdkLoggerBlockState();
}

class _SdkLoggerBlockState extends State<SdkLoggerBlock> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Push Service Logger'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: widget.logHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: _LogMessages(logs: widget.logs),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 54,
                child: ElevatedButton(
                  onPressed: widget.logs.isEmpty || widget.onShareLog == null
                      ? null
                      : () => widget.onShareLog!(widget.logs),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.accentDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Share Log', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: widget.onGetToken,
            style: const ButtonStyle(
              padding:
                  WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            ),
            child: const Text('Get Token'),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<String>(
            valueListenable: widget.lastTokenController,
            builder: (context, value, _) => Text(value),
          ),
        ],
      ),
    );
  }
}

class _LogMessages extends StatelessWidget {
  const _LogMessages({required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text('No log messages yet'));
    }

    return ListView.builder(
      primary: false,
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SelectableText(
            logs[logs.length - 1 - index],
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}
