class EventReport {
  final String? reportId;
  final String eventId;
  final String userId;
  final DateTime? plannedWakeupTime;
  final DateTime? plannedDepartureTime;

  EventReport({
    this.reportId,
    required this.eventId,
    required this.userId,
    this.plannedWakeupTime,
    this.plannedDepartureTime,
  });
}
