class MonitoringState {
  final bool isLoading;
  final Map<String, dynamic>? deviceStatus;
  final List<Map<String, dynamic>>? batteryHistory;
  final Map<String, dynamic>? statistics;
  final String? error;

  const MonitoringState({
    this.isLoading = false,
    this.deviceStatus,
    this.batteryHistory,
    this.statistics,
    this.error,
  });

  MonitoringState copyWith({
    bool? isLoading,
    Map<String, dynamic>? deviceStatus,
    List<Map<String, dynamic>>? batteryHistory,
    Map<String, dynamic>? statistics,
    String? error,
  }) {
    return MonitoringState(
      isLoading: isLoading ?? this.isLoading,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      batteryHistory: batteryHistory ?? this.batteryHistory,
      statistics: statistics ?? this.statistics,
      error: error ?? this.error,
    );
  }
}
