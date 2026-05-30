int getAlarmId(String eventId, String phase) {
  return (eventId + phase).hashCode.abs() % 100000;
}
