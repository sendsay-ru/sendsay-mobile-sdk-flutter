import '../model/configuration_change.dart';
import '../util/object.dart';
import 'project.dart';

abstract class SendsayConfigurationChangeEncoder {
  static SendsayConfigurationChange decode(Map<String, dynamic> data) {
    return SendsayConfigurationChange(
      project: data
          .getOptional<Map<String, dynamic>>('project')
          ?.let(SendsayProjectEncoder.decode),
      mapping: data
          .getOptional<Map<String, dynamic>>('mapping')
          ?.let(SendsayProjectMappingEncoder.decode),
    );
  }

  static Map<String, dynamic> encode(SendsayConfigurationChange config) {
    return {
      'project': config.project?.let(SendsayProjectEncoder.encode),
      'mapping': config.mapping?.let(SendsayProjectMappingEncoder.encode),
    }..removeWhere((key, value) => value == null);
  }
}
