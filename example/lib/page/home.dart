import 'dart:async';
import 'dart:convert';

import 'package:example_flutter/home_blocks/customer_block.dart';
import 'package:example_flutter/home_blocks/default_props_block.dart';
import 'package:example_flutter/home_blocks/fetch_block.dart';
import 'package:example_flutter/home_blocks/flush_period_block.dart';
import 'package:example_flutter/home_blocks/log_level_block.dart';
import 'package:example_flutter/home_blocks/other_buttons_block.dart';
import 'package:example_flutter/home_blocks/push_events_block.dart';
import 'package:example_flutter/home_blocks/ssec_block.dart';
import 'package:example_flutter/home_blocks/flush_mode_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendsay/sendsay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_inbox_list_page.dart';
import 'in_app_cb_carousel_page.dart';
import 'in_app_cb_page.dart';

final _plugin = SendsayPlugin();

class HomePage extends StatefulWidget {
  final SendsayConfiguration config;

  const HomePage({
    super.key,
    required this.config,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _flushPeriodController = ValueNotifier<int>(5);
  final _flushModeController = ValueNotifier<FlushMode?>(FlushMode.manual);
  final _logLevelController = ValueNotifier<LogLevel?>(LogLevel.info);
  final _pushController = ValueNotifier<String>('- none -');
  late final StreamSubscription<OpenedPush> _openedPushSub;
  late final StreamSubscription<ReceivedPush> _receivedPushSub;
  late final StreamSubscription<InAppMessageAction> _inAppMessageActionSub;
  late final StreamSubscription<List<Map<String, dynamic>>>
      _discoverySubscription;
  late final StreamSubscription<List<Map<String, dynamic>>>
      _contentSubscription;
  late final StreamSubscription<List<Map<String, dynamic>>>
      _merchandisingSubscription;

  Future<void> initializeSegmentationDataStreams() async {
    final discoverySegmentationDataStream = await _plugin
        .segmentationDataStream('discovery', includeFirstLoad: true);
    _discoverySubscription = discoverySegmentationDataStream
        .listen((event) => _onSegmentationDataEvent('discovery', event));
    final contentSegmentationDataStream =
        await _plugin.segmentationDataStream('content', includeFirstLoad: true);
    _contentSubscription = contentSegmentationDataStream
        .listen((event) => _onSegmentationDataEvent('content', event));
    final merchandisingSegmentationDataStream = await _plugin
        .segmentationDataStream('merchandising', includeFirstLoad: true);
    _merchandisingSubscription = merchandisingSegmentationDataStream
        .listen((event) => _onSegmentationDataEvent('merchandising', event));
  }

  @override
  void initState() {
    _openedPushSub = _plugin.openedPushStream.listen(_onPushEvent);
    _receivedPushSub = _plugin.receivedPushStream.listen(_onPushEvent);
    _inAppMessageActionSub =
        _plugin.inAppMessageActionStream().listen(_onInAppMessageActionEvent);
    initializeSegmentationDataStreams();
    super.initState();
  }

  @override
  void dispose() {
    _openedPushSub.cancel();
    _receivedPushSub.cancel();
    _inAppMessageActionSub.cancel();
    _discoverySubscription.cancel();
    _contentSubscription.cancel();
    _merchandisingSubscription.cancel();
    _flushPeriodController.dispose();
    _flushModeController.dispose();
    _pushController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          PushEventsBlock(
              key: UniqueKey(),
              pushController: _pushController,
              requestPushCallback: _requestPushAuthorization,
              isConfiguredCallback: _checkIsConfigured),
          CustomerBlock(
              key: UniqueKey(),
              cookieCall: _getCustomerCookie,
              identifyCall: _identifyCustomer,
              anonymizeCall: _anonymize),
          DefaultPropsBlock(
              key: UniqueKey(),
              getDefPropsCall: _getDefaultProps,
              setDefPropsCall: _setDefaultProps),
          FetchBlock(
            key: UniqueKey(),
            consentsCall: _fetchConsents,
            recommendCall: _fetchRecommendations,
          ),
          FlushModeBlock(
            key: UniqueKey(),
            flushModeController: _flushModeController,
            getFlushModeCall: _getFlushMode,
            setFlushModeCall: (ctx) {
              setState(() {});
              _setFlushMode(ctx);
            },
            flushCall: _flush,
          ),
          if (_flushModeController.value == FlushMode.period)
            FlushPeriodBlock(
              flushPeriodController: _flushPeriodController,
              flushPeriodCall: _setFlushPeriod,
            ),
          ListTile(
            title: const Text('Track'),
            subtitle: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _trackEvent(context),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Event'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (widget.config.automaticSessionTracking ?? true)
                      ? null
                      : () => _trackSessionStart(context),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Session Start'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (widget.config.automaticSessionTracking ?? true)
                      ? null
                      : () => _trackSessionEnd(context),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Session End'),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Trigger in-app message by event:'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _triggerInAppMessage(context, 'test_msg_modal'),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Modal'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _triggerInAppMessage(context, 'test_msg_fullscreen'),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Fullscreen'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _triggerInAppMessage(context, 'test_msg_slide'),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Slide-in'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _triggerInAppMessage(context, 'test_msg_alert'),
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16)),
                  ),
                  child: const Text('Alert'),
                ),
              ],
            ),
          ),
          LogLevelBlock(
            logLevelCall: _getLogLevel,
            logLevelController: _logLevelController,
          ),
          SsecBlock(
            key: UniqueKey(),
            callback: (ssec) => _trackSSEC(context, ssec),
          ),
          // ListTile(
          //     title: const Text('App Inbox'),
          //     subtitle: Row(children: const [
          //       SizedBox(width: 150, height: 50, child: AppInboxProvider()),
          //     ])),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Divider(color: Colors.white),
          ),
          OtherButtonsBlock(
            key: UniqueKey(),
            appInboxFetchAllCall: _fetchAppInbox,
            appInboxFetchItemCall: _fetchAppInboxItem,
            appInboxMarkItemAsReadCall: _markFirstAppInboxItemAsRead,
            appInboxTrackItemAsOpenedCall: _trackFirstAppInboxItemAsOpened,
            appInboxTrackItemAsClickedCall: _trackFirstAppInboxItemAsClicked,
            trackPaymentEventCall: _trackPaymentEvent,
            pluginSegmentsCallback: (ctx) async {
              final data = await _plugin.getSegments('discovery');
              debugPrint(
                  'Segments: received segments for category discovery with IDs: $data');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _trackSSEC(BuildContext context, SSECEvent ssec) =>
      _runAndShowResult(context, () async {
        final event = Event(
          name: 'trackSSECEvent',
          properties: ssec.toSsecMap(),
        );
        return await _plugin.trackEvent(event);
      });

  Future<void> _fetchAppInbox(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.fetchAppInbox();
      });

  Future<void> _fetchAppInboxItem(BuildContext context) =>
      _runAndShowResult(context, () async {
        var messages = await _plugin.fetchAppInbox();
        if (messages.isEmpty) return "EMPTY APPINBOX";
        return messages[0];
      });

  Future<void> _markFirstAppInboxItemAsRead(BuildContext context) =>
      _runAndShowResult(context, () async {
        var messages = await _plugin.fetchAppInbox();
        if (messages.isEmpty) return "EMPTY APPINBOX";
        return await _plugin.markAppInboxAsRead(messages.first);
      });

  Future<void> _trackFirstAppInboxItemAsOpened(BuildContext context) async {
    var messages = await _plugin.fetchAppInbox();
    if (messages.isEmpty) return;
    return await _plugin.trackAppInboxOpened(messages.first);
  }

  Future<void> _trackFirstAppInboxItemAsClicked(BuildContext context) async {
    var messages = await _plugin.fetchAppInbox();
    if (messages.isEmpty) return;
    return await _plugin.trackAppInboxClick(
        const AppInboxAction(
            title: 'Google', action: 'browser', url: 'https://www.google.com'),
        messages.first);
  }

  Future<void> _trackPaymentEvent(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.trackPaymentEvent(
          const PurchasedItem(
            value: 123.34,
            currency: "RUB",
            paymentSystem: "Virtual",
            productId: "Backpack",
            productTitle: "Awesome product!",
          ),
        );
      });

  Future<void> _checkIsConfigured(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.isConfigured();
      });

  Future<void> _getCustomerCookie(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getCustomerCookie();
      });

  Future<void> _identifyCustomer(BuildContext context) =>
      _runAndShowResult(context, () async {
        const email = 'test-user-1@test.com';
        const customerIds = {'registered': email};
        const customer = Customer(ids: customerIds);
        final sp = await SharedPreferences.getInstance();
        var customerIdsString = json.encode(customerIds);
        await sp.setString("customer_ids", customerIdsString);
        await _plugin.identifyCustomer(customer);
        return email;
      });

  Future<void> _anonymize(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.anonymize();
      });

  Future<void> _getDefaultProps(BuildContext context) =>
      _runAndShowResult(context, () async {
        final props = await _plugin.getDefaultProperties();
        final values = props
            .map((key, value) => MapEntry(key, '$key: $value'))
            .values
            .join(', ');
        return '{ $values }';
      });

  Future<void> _setDefaultProps(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.setDefaultProperties({
          'default_prop_1': 'test',
        });
      });

  Future<void> _fetchConsents(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.fetchConsents();
      });

  Future<void> _fetchRecommendations(BuildContext context) =>
      _runAndShowResult(context, () async {
        const options = RecommendationOptions(
          id: '60db38da9887668875998c49',
          fillWithRandom: true,
          items: {},
        );
        return await _plugin.fetchRecommendations(options);
      });

  Future<void> _getFlushMode(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getFlushMode();
      });

  Future<void> _setFlushMode(BuildContext context) =>
      _runAndShowResult(context, () async {
        final mode = _flushModeController.value!;
        return await _plugin.setFlushMode(mode);
      });

  Future<void> _flush(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.flushData();
      });

  Future<void> _getFlushPeriod(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getFlushPeriod();
      });

  Future<void> _setFlushPeriod(BuildContext context) =>
      _runAndShowResult(context, () async {
        final period = Duration(minutes: _flushPeriodController.value);
        return await _plugin.setFlushPeriod(period);
      });

  Future<void> _trackEvent(BuildContext context) =>
      _runAndShowResult(context, () async {
        const event = Event(
          name: 'event_name',
          properties: {
            'property': '5s',
            'int': 12,
            'double': 34.56,
            'string': 'test'
          },
        );
        await _plugin.trackEvent(event);
      });

  Future<void> _triggerInAppMessage(BuildContext context, String name) =>
      _runAndShowResult(context, () async {
        await _plugin.trackEvent(Event(name: name));
      });

  Future<void> _trackSessionStart(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.trackSessionStart();
      });

  Future<void> _trackSessionEnd(BuildContext context) =>
      _runAndShowResult(context, () async {
        await _plugin.trackSessionEnd();
      });

  Future<void> _getLogLevel(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.getLogLevel();
      });

  Future<void> _setLogLevel(BuildContext context) =>
      _runAndShowResult(context, () async {
        final level = _logLevelController.value!;
        return await _plugin.setLogLevel(level);
      });

  Future<void> _requestPushAuthorization(BuildContext context) =>
      _runAndShowResult(context, () async {
        return await _plugin.requestPushAuthorization();
      });

  Future<void> _runAndShowResult(
    BuildContext context,
    Future<dynamic> Function() block,
  ) async {
    String msg;
    try {
      final res = await block.call();
      if (res != null) {
        msg = 'Done: $res';
      } else {
        msg = 'Done';
      }
    } on PlatformException catch (err) {
      msg = 'Error: $err';
    }
    final snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onPushEvent(dynamic push) {
    _pushController.value = '$push\nat: ${DateTime.now().toIso8601String()}';
  }

  void _onInAppMessageActionEvent(InAppMessageAction action) {
    print('received in-app action: $action');
  }

  void _onSegmentationDataEvent(
      String exposingCategory, List<Map<String, String>> data) {
    print('Segments: New for category $exposingCategory with IDs: $data');
  }
}
