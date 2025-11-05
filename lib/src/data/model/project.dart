import 'package:meta/meta.dart';

@immutable
class SendsayProject {
  /// Project token of the Sendsay project
  final String projectToken;

  /// Authorization token of the Sendsay project
  final String authorizationToken;

  /// Base URL of the Sendsay project
  final String? baseUrl;

  const SendsayProject({
    required this.projectToken,
    required this.authorizationToken,
    this.baseUrl,
  });
}
