import 'package:flutter/material.dart';

class FlushPeriodBlock extends StatefulWidget {
  final Function(BuildContext) flushPeriodCall;
  final ValueNotifier<int> flushPeriodController;

  const FlushPeriodBlock({
    super.key,
    required this.flushPeriodController,
    required this.flushPeriodCall,
  });

  @override
  State<FlushPeriodBlock> createState() => _FlushPeriodBlockState();
}

class _FlushPeriodBlockState extends State<FlushPeriodBlock> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Flush Period'),
      subtitle: Row(
        children: [
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => widget.flushPeriodCall(context),
            child: const Text('Set'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: widget.flushPeriodController,
              builder: (context, period, _) => Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('$period min'),
                  ),
                  Expanded(
                    child: Slider(
                      value: period.toDouble(),
                      min: 1,
                      max: 60,
                      onChanged: (value) =>
                          widget.flushPeriodController.value = value.toInt(),
                    ),
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
