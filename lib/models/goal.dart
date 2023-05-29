import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  var name;
  var deadline;
  var strategy_type_id;
  var priority;
  var decription;
  var uid;
  var id;

  Goal(
      {required this.name,
      required this.deadline,
      required this.strategy_type_id,
      required this.priority,
      required this.decription,
      required this.uid,
      required this.id});

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      name: map['name'],
      deadline: map['deadline'],
      strategy_type_id: map['strategy_type_id'],
      priority: map['priority'],
      decription: map['decription'],
      uid: map['uid'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'deadline': deadline,
      'strategy_type_id': strategy_type_id,
      'priority': priority,
      'decription': decription,
      'uid': uid,
      'id': id,
    };
  }

  static Goal fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Goal(
      name: data!['name'] as String,
      deadline: data['deadline'] as String,
      strategy_type_id: data['strategy_type_id'] as String,
      priority: data['priority'] as int,
      decription: data['decription'] as String,
      uid: data['uid'] as String,
      id: data['id'] as String,
    );
  }
}
