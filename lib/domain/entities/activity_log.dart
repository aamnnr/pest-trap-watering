import 'package:equatable/equatable.dart';

class ActivityLog extends Equatable {
  final int? id;
  final String deviceId;
  final String action;
  final String source;
  final String? details;
  final String status;
  final DateTime timestamp;

  const ActivityLog({
    this.id,
    required this.deviceId,
    required this.action,
    required this.source,
    this.details,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        deviceId,
        action,
        source,
        details,
        status,
        timestamp,
      ];
}
