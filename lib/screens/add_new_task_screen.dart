import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/new_scheduled_task.dart';

import '../models/meeting_class.dart';
import '../models/scheduled_task.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  List<ScheduledTask> _userScheduledTasks = [];

  static final CollectionReference tasksCollectionRef =
      FirebaseFirestore.instance.collection('tasks');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  Future<void> _addNewScheduledTask(
    String tskName,
    String tskCategory,
    DateTime tskStartDatetimePlanned,
    DateTime tskEndDatetimePlanned,
    DateTime tskStartDatetimeAsIs,
    DateTime tskEndDatetimeAsIs,
    bool? tskIsCanceled,
    String? tskPriorityName,
    String? tskDescription,
    String? tskUid,
    String? tskId,
  ) async {
    final newTsk = ScheduledTask(
      name: tskName,
      start_datetime_planned: tskStartDatetimePlanned,
      end_datetime_planned: tskEndDatetimePlanned,
      start_datetime_as_is: tskStartDatetimeAsIs,
      end_datetime_as_is: tskEndDatetimeAsIs,
      is_canceled: tskIsCanceled,
      priority: tskPriorityName,
      description: tskDescription,
      uid: uid,
      id: tskId,
    );
    setState(() {
      _userScheduledTasks.add(newTsk);
    });
    // Write the transaction to Firebase
    await tasksCollectionRef.add({
      'name': tskName,
      'start_datetime_planned': tskStartDatetimePlanned,
      'end_datetime_planned': tskEndDatetimePlanned,
      'start_datetime_as_is': tskStartDatetimeAsIs,
      'end_datetime_as_is': tskEndDatetimeAsIs,
      'is_canceled': tskIsCanceled,
      'priority': tskPriorityName,
      'description': tskDescription,
      'uid': uid,
      'id': tskId,
    });
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Conference', startTime, endTime, const Color(0xFFF48FB1), false));
    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return NewScheduledTask(_addNewScheduledTask, "", "",
        DateTime.now().toString(), DateTime.now());
  }
}
