import '../entities/event_report.dart';

abstract class IEventReportRepository {
  Future<EventReport?> getEventReport(String eventId, String userId);
  
  Future<String?> setReport({
    required String eventId,
    required String userId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  });
}
