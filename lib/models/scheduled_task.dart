import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledTask {
  var name;
  var start_datetime_planned;
  var end_datetime_planned;
  var start_datetime_as_is;
  var end_datetime_as_is;
  var is_canceled;
  var priority;
  var description;
  var uid;
  var id;

  ScheduledTask(
      {required this.name,
      required this.start_datetime_planned,
      required this.end_datetime_planned,
      required this.start_datetime_as_is,
      required this.end_datetime_as_is,
      required this.is_canceled,
      required this.priority,
      required this.description,
      required this.uid,
      required this.id});

  factory ScheduledTask.fromMap(Map<String, dynamic> map) {
    return ScheduledTask(
      name: map['name'],
      start_datetime_planned: map['start_datetime_planned'],
      end_datetime_planned: map['end_datetime_planned'],
      start_datetime_as_is: map['start_datetime_as_is'],
      end_datetime_as_is: map['end_datetime_as_is'],
      is_canceled: map['is_canceled'],
      priority: map['priority'],
      description: map['description'],
      uid: map['uid'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_datetime_planned': start_datetime_planned,
      'end_datetime_planned': end_datetime_planned,
      'start_datetime_as_is': start_datetime_as_is,
      'end_datetime_as_is': end_datetime_as_is,
      'is_canceled': is_canceled,
      'priority': priority,
      'description': description,
      'uid': uid,
      'id': id,
    };
  }

  static ScheduledTask fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return ScheduledTask(
      name: data!['name'] as String,
      start_datetime_planned: data['start_datetime_planned'] as DateTime,
      end_datetime_planned: data['end_datetime_planned'] as DateTime,
      start_datetime_as_is: data['start_datetime_as_is'] as DateTime,
      end_datetime_as_is: data['end_datetime_as_is'] as DateTime,
      is_canceled: data['is_canceled'] as bool,
      priority: data['priority'] as String,
      description: data['description'] as String,
      uid: data['uid'] as String,
      id: data['id'] as String,
    );
  }
}
