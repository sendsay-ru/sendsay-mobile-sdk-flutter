import 'package:example_flutter/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendsay/sendsay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/confirm_app_dialog.dart';

final _plugin = SendsayPlugin();

typedef ConfigCallback = void Function(SendsayConfiguration configuration);

class ConfigPage extends StatefulWidget {
  final ConfigCallback doneCallback;

  const ConfigPage({
    super.key,
    required this.doneCallback,
  });

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  static const _platform = MethodChannel("com.sendsay/utils");

  static const _spKeyProject = 'project_token';
  static const _spKeyAuth = 'auth_token';

  // static const _spKeyAdvancedAuth = 'advanced_auth_token';
  static const _spKeyBaseUrl = 'base_url';
  static const _spKeySessionTracking = 'session_tracking';

  static const baseUrl = "https://mobi.sendsay.ru/xnpe/v100";

  final _loading = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _projectIdController;
  late final TextEditingController _authTokenController;

  // late final TextEditingController _advancedAuthTokenController;
  late final TextEditingController _baseUrlController;
  late final ValueNotifier<bool> _sessionTrackingController;

  Future<int?> getAndroidPushIcon() async {
    try {
      return await _platform.invokeMethod<int?>('getAndroidPushIcon');
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    _projectIdController = TextEditingController(text: '');
    _authTokenController = TextEditingController(text: '');
    // _advancedAuthTokenController = TextEditingController(text: '');
    _baseUrlController = TextEditingController(text: baseUrl);

    _sessionTrackingController = ValueNotifier(true);
    SharedPreferences.getInstance().then((sp) async {
      _projectIdController.text =
          sp.getString(_spKeyProject) ?? _projectIdController.text;
      _authTokenController.text =
          sp.getString(_spKeyAuth) ?? _authTokenController.text;
      // _advancedAuthTokenController.text =
      //     sp.getString(_spKeyAdvancedAuth) ?? _advancedAuthTokenController.text;
      _baseUrlController.text =
          sp.getString(_spKeyBaseUrl) ?? _baseUrlController.text;
      _sessionTrackingController.value =
          sp.getBool(_spKeySessionTracking) ?? true;
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(32),
                          child: Image.asset(
                              'assets/images/white_logo_sendsay.webp')),
                      ListTile(
                        title: TextFormField(
                          controller: _projectIdController,
                          maxLines: 1,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Project Id / Account Id',
                            labelStyle: TextStyle(color: AppColors.white),
                            errorStyle: TextStyle(
                                color: AppColors.alertNotificationText),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Заполните поле!';
                            }
                            return null; // Return null if the input is valid
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          controller: _authTokenController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Authentication Token (optional)',
                            labelStyle: TextStyle(color: AppColors.white),
                            errorStyle: TextStyle(
                                color: AppColors.alertNotificationText),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Заполните поле!';
                            }
                            return null; // Return null if the input is valid
                          },
                        ),
                      ),
                      // ListTile(
                      //   title: TextField(
                      //     controller: _advancedAuthTokenController,
                      //     decoration:
                      //         const InputDecoration(labelText: 'Advanced Auth Token'),
                      //   ),
                      // ),
                      ListTile(
                        title: TextFormField(
                          controller: _baseUrlController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'Base URL',
                            errorStyle: const TextStyle(
                                color: AppColors.alertNotificationText),
                            suffixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () => confirmCustomDialog(
                                      context,
                                      "точно стереть",
                                      () => _baseUrlController.clear()),
                                  icon: const Icon(
                                    Icons.close,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                ),
                                IconButton(
                                  onPressed: () => confirmCustomDialog(
                                      context,
                                      "вернуть по умолчанию",
                                      () => _baseUrlController.text = baseUrl),
                                  icon: const Icon(
                                    Icons.refresh,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                ),
                              ],
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Заполните поле!';
                            }
                            return null; // Return null if the input is valid
                          },
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _sessionTrackingController,
                        builder: (context, enabled, _) => SwitchListTile(
                          title: const Text('Automatic Session Tracking'),
                          value: enabled,
                          onChanged: (value) =>
                              _sessionTrackingController.value = value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: _loading,
                builder: (context, loading, _) => loading
                    ? const CircularProgressIndicator(
                        year2023: false,
                      )
                    : ElevatedButton(
                        onPressed: () => _formKey.currentState!.validate()
                            ? _configure(context)
                            : null,
                        style: const ButtonStyle(
                            surfaceTintColor:
                                WidgetStatePropertyAll(AppColors.primary)),
                        child: const Text(
                          'Configure',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _configure(BuildContext context) async {
    final pushIcon = await getAndroidPushIcon();

    _loading.value = true;
    final projectToken = _projectIdController.text.trim();
    final authToken = _authTokenController.text.trim().split(' ').last;
    // final advancedAuthToken = _advancedAuthTokenController.text.trim();
    final rawBaseUrl = _baseUrlController.text.trim();
    final baseUrl = rawBaseUrl.isNotEmpty ? rawBaseUrl : null;
    final sessionTracking = _sessionTrackingController.value;

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKeyProject, projectToken);
    await sp.setString(_spKeyAuth, authToken);
    // await sp.setString(_spKeyAdvancedAuth, advancedAuthToken);
    await sp.setString(_spKeyBaseUrl, rawBaseUrl);
    await sp.setBool(_spKeySessionTracking, sessionTracking);

    final config = SendsayConfiguration(
        projectToken: projectToken,
        authorizationToken: authToken,
        baseUrl: baseUrl,
        pushTokenTrackingFrequency: TokenFrequency.everyLaunch,
        requirePushAuthorization: true,
        flushMaxRetries: 10,
        automaticSessionTracking: sessionTracking,
        sessionTimeout: 22.5,
        defaultProperties: const {
          'string': 'string',
          'double': 1.2,
          'int': 10,
          'bool': true,
          'fontWeight': "normal"
        },
        allowDefaultCustomerProperties: false,
        // projectMapping: {
        //   EventType.banner: [
        //     SendsayProject(projectToken: '1', authorizationToken: '11'),
        //   ],
        //   EventType.campaignClick: [
        //     SendsayProject(projectToken: '2', authorizationToken: '22'),
        //   ],
        // },
        // TODO: check this
        advancedAuthEnabled: false,
        android: AndroidSendsayConfiguration(
          automaticPushNotifications: true,
          httpLoggingLevel: HttpLoggingLevel.body,
          pushChannelDescription: 'test-channel-desc',
          pushChannelId: 'test-channel-id',
          pushChannelName: 'test-channel-name',
          pushNotificationImportance: PushNotificationImportance.normal,
          pushAccentColor: 0xFFFFD500,
          pushIcon: pushIcon,
        ),
        ios: const IOSSendsayConfiguration(
          appGroup: 'group.ru.sendsay.SendsaySDK',
        ),
        inAppContentBlockPlaceholdersAutoLoad: const [
          'example_top',
          'example_list'
        ]);
    try {
      _plugin.setAppInboxProvider(AppInboxStyle(
          appInboxButton: SimpleButtonStyle(
            backgroundColor: 'rgb(245, 195, 68)',
            borderRadius: '10dp',
            showIcon: true,
            enabled: true,
            textSize: '12dp',
            textOverride: 'App Inbox',
            textWeight: 'normal',
            textColor: 'white',
          ),
          detailView: DetailViewStyle(
              button: SimpleButtonStyle(backgroundColor: 'red'),
              title: TextViewStyle(
                  textSize: '20sp',
                  textOverride: 'TEST',
                  textWeight: 'bold',
                  textColor: 'rgba(100, 100, 100, 1.0)')),
          listView: ListScreenStyle(
              errorTitle: TextViewStyle(textColor: 'red'),
              errorMessage: TextViewStyle(textColor: 'red'),
              list: AppInboxListViewStyle(
                  backgroundColor: 'blue',
                  item: AppInboxListItemStyle(
                      backgroundColor: 'yellow',
                      content: TextViewStyle(
                          textColor: '#FFF', textWeight: '700'))))));
      final configured = await _plugin.configure(config);
      if (!configured) {
        const snackBar = SnackBar(
          content: Text('SDK was already configured'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      _plugin.setLogLevel(LogLevel.verbose);
      widget.doneCallback.call(config);
    } on PlatformException catch (err) {
      final snackBar = SnackBar(
        content: Text('Configuration failed: $err'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _loading.value = false;
    }
    _loading.value = false;
  }
}
