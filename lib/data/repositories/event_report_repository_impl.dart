import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event_report.dart';
import '../../domain/repositories/i_event_report_repository.dart';
import '../event_repository.dart';

class EventReportRepositoryImpl implements IEventReportRepository {
  final EventRepository _eventRepository;

  EventReportRepositoryImpl({EventRepository? eventRepository})
      : _eventRepository = eventRepository ?? EventRepository();

  @override
  Future<EventReport?> getEventReport(String eventId, String userId) async {
    final reportData = await _eventRepository.getEventReport(eventId, userId);
    if (reportData == null) return null;

    final rawWakeup =
        reportData['planned_wakeup_time'] ?? reportData['wakeupTime'];
    final rawDeparture =
        reportData['planned_departure_time'] ?? reportData['departureTime'];

    DateTime? wakeupTime;
    DateTime? departureTime;

    if (rawWakeup is Timestamp) {
      wakeupTime = rawWakeup.toDate();
    } else if (rawWakeup is DateTime) {
      wakeupTime = rawWakeup;
    }
    
    if (rawDeparture is Timestamp) {
      departureTime = rawDeparture.toDate();
    } else if (rawDeparture is DateTime) {
      departureTime = rawDeparture;
    }

    return EventReport(
      reportId: reportData['report_id'] as String?,
      eventId: reportData['event_id'] as String? ?? eventId,
      userId: reportData['user_id'] as String? ?? userId,
      plannedWakeupTime: wakeupTime,
      plannedDepartureTime: departureTime,
    );
  }

  @override
  Future<String?> setReport({
    required String eventId,
    required String userId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {
    return await _eventRepository.setReport(
      eventId: eventId,
      userId: userId,
      wakeupTime: wakeupTime,
      departureTime: departureTime,
    );
  }
}
