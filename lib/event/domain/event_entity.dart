import 'package:cloud_firestore/cloud_firestore.dart';

class EventEntity {
  final String eventId;
  final String title;
  final String destinationName;
  final String location;
  final String password;
  final DateTime? arrivalTime;
  final String status;

  EventEntity({
    required this.eventId,
    required this.title,
    required this.destinationName,
    required this.location,
    required this.password,
    required this.arrivalTime,
    required this.status,
  });

  factory EventEntity.fromMap(Map<String, dynamic> data) {
    final arrival = data['arrival_time'];
    DateTime? arrivalTime;

    if (arrival is Timestamp) {
      arrivalTime = arrival.toDate();
    } else if (arrival is DateTime) {
      arrivalTime = arrival;
    } else if (arrival is String) {
      arrivalTime = DateTime.tryParse(arrival);
    }

    return EventEntity(
      eventId: data['event_id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'No named yet',
      destinationName: data['destination_name']?.toString() ?? 'No decided yet',
      location: data['location']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
      arrivalTime: arrivalTime,
      status: data['status']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'EventEntity(eventId: $eventId, title: $title, destinationName: $destinationName)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntity &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          title == other.title &&
          destinationName == other.destinationName &&
          location == other.location &&
          password == other.password &&
          arrivalTime == other.arrivalTime &&
          status == other.status;

  @override
  int get hashCode =>
      eventId.hashCode ^
      title.hashCode ^
      destinationName.hashCode ^
      location.hashCode ^
      password.hashCode ^
      arrivalTime.hashCode ^
      status.hashCode;
}

abstract class EventRepository {
  Future<List<EventEntity>> getEvents(String groupId);
}
