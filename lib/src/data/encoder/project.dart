import '../model/event_type.dart';
import '../model/project.dart';
import '../util/object.dart';
import 'event_type.dart';

abstract class SendsayProjectEncoder {
  static SendsayProject decode(Map<String, dynamic> data) {
    return SendsayProject(
      projectToken: data.getRequired('projectToken'),
      authorizationToken: data.getRequired('authorizationToken'),
      baseUrl: data.getOptional('baseUrl'),
    );
  }

  static Map<String, dynamic> encode(SendsayProject project) {
    return {
      'projectToken': project.projectToken,
      'authorizationToken': project.authorizationToken,
      'baseUrl': project.baseUrl,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class SendsayProjectMappingEncoder {
  static Map<EventType, List<SendsayProject>> decode(
    Map<String, dynamic> data,
  ) {
    return data.map(
      (key, value) => MapEntry(
        EventTypeEncoder.decode(key),
        value
            .map((project) => SendsayProjectEncoder.decode(project))
            .cast<SendsayProject>()
            .toList(),
      ),
    );
  }

  static Map<String, dynamic> encode(
    Map<EventType, List<SendsayProject>> mapping,
  ) {
    return mapping.map(
      (key, value) => MapEntry(
        EventTypeEncoder.encode(key),
        value
            .map((project) => SendsayProjectEncoder.encode(project))
            .cast<Map<String, dynamic>>()
            .toList(),
      ),
    );
  }
}
