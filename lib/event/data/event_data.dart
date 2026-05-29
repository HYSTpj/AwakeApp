import '../../data/event_repository.dart' as event_firestore;
import '../domain/event_entity.dart';

class EventRepositoryImpl implements EventRepository {
  final event_firestore.EventRepository _firestoreRepository;

  EventRepositoryImpl([event_firestore.EventRepository? firestoreRepository])
      : _firestoreRepository = firestoreRepository ?? event_firestore.EventRepository();

  @override
  Future<List<EventEntity>> getEvents(String groupId) async {
    final rawEvents = await _firestoreRepository.getEvents(groupId);
    return rawEvents.map(EventEntity.fromMap).toList();
  }

  // グループの全員を取得
  @override
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    return await _firestoreRepository.getGroupMembers(groupId);
  }

  // 一括更新
  @override
  Future<void> updateEventDetails({
    required String eventId,
    required String title,
    required String destinationName,
    required String arrivalTime,
    required List<String> participants,
  }) async {
    await _firestoreRepository.updateEventDetails(
      eventId: eventId,
      title: title,
      destinationName: destinationName,
      arrivalTime: arrivalTime,
      participants: participants,
    );
  }

  @override
  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    return await _firestoreRepository.getEventById(eventId);
  }
}
