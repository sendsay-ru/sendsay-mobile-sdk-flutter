import 'package:flutter/material.dart';
import 'package:sendsay/sendsay.dart';

import '../colors.dart';

class FlushModeBlock extends StatefulWidget {
  final ValueNotifier<FlushMode?> flushModeController;
  final Function(BuildContext) getFlushModeCall;
  final Function(BuildContext) setFlushModeCall;
  final Function(BuildContext) flushCall;

  const FlushModeBlock({
    super.key,
    required this.flushModeController,
    required this.getFlushModeCall,
    required this.setFlushModeCall,
    required this.flushCall,
  });

  @override
  State<FlushModeBlock> createState() => _FlushModeBlockState();
}

class _FlushModeBlockState extends State<FlushModeBlock> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: const Text('Flush Mode'),
        subtitle: Row(
          children: [
            ElevatedButton(
              onPressed: () => widget.getFlushModeCall(context),
              child: const Text('Get'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => widget.setFlushModeCall(context),
              child: const Text('Set'),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown, // Or other fit options
                child: RepaintBoundary(
                  child: ValueListenableBuilder<FlushMode?>(
                    valueListenable: widget.flushModeController,
                    builder: (context, selectedMode, _) =>
                        //   InkWell(
                        // onTap: () {
                        //   showDialog(
                        //       context: context,
                        //       builder: (_) {
                        //         return DropDownListAlert(selectedItem: selectTap);
                        //       });
                        // },
                        // child: DecoratedBox(
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(8.0),
                        //       border: BoxBorder.all(color: Colors.white)
                        //       // color: Colors.white,
                        //       ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Row(children: [
                        //       Text(selectedMode!.name),
                        //       const Icon(Icons.arrow_drop_down)
                        //     ]),
                        //   ),
                        // ),

                        DropdownButton<FlushMode>(
                      value: selectedMode,
                      onChanged: (value) =>
                          widget.flushModeController.value = value,
                      items: FlushMode.values
                          .map(
                            (mode) => DropdownMenuItem<FlushMode>(
                              value: mode,
                              child: Text(mode.toString()),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            // ),
          ],
        ),
      ),
      ListTile(
        title: ElevatedButton(
          onPressed: () => widget.flushCall(context),
          child: const Text('Flush'),
        ),
      ),
    ]);
  }

  void selectTap(FlushMode mode) => widget.flushModeController.value = mode;
}

class DropDownListAlert extends StatefulWidget {
  final Function(FlushMode) selectedItem;

  const DropDownListAlert({super.key, required this.selectedItem});

  @override
  State<DropDownListAlert> createState() => _DropDownListAlertState();
}

class _DropDownListAlertState extends State<DropDownListAlert> {
  List<FlushMode> _searchVendor = [];

  @override
  void initState() {
    super.initState();
    _searchVendor = List.from(FlushMode.values);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _searchVendor.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                color: AppColors.primary,
                child: InkWell(
                  onTap: () {
                    widget.selectedItem(_searchVendor[index]);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_searchVendor[index].toString()),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
