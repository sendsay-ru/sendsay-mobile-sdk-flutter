import 'package:meta/meta.dart';

import 'event_type.dart';
import 'project.dart';

@immutable
class SendsayConfigurationChange {
  final SendsayProject? project;
  final Map<EventType, List<SendsayProject>>? mapping;

  const SendsayConfigurationChange({
    this.project,
    this.mapping,
  });
}
