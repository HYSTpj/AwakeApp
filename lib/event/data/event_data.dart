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
}
