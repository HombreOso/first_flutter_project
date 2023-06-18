import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/category.dart';
import 'package:flutter_complete_guide/models/priority_enum.dart';
import 'package:flutter_complete_guide/widgets/new_scheduled_task.dart';

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
    int tskDisplayedColor,
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
      displayedColor: tskDisplayedColor,
    );
    setState(() {
      _userScheduledTasks.add(newTsk);
    });
    // Write the transaction to Firebase
    await tasksCollectionRef.add({
      'name': tskName,
      'start_datetime_planned': tskStartDatetimePlanned.millisecondsSinceEpoch,
      'end_datetime_planned': tskEndDatetimePlanned.millisecondsSinceEpoch,
      'start_datetime_planned_clear': tskStartDatetimePlanned,
      'end_datetime_planned_clear': tskEndDatetimePlanned,
      'start_datetime_as_is': tskStartDatetimeAsIs.millisecondsSinceEpoch,
      'end_datetime_as_is': tskEndDatetimeAsIs.millisecondsSinceEpoch,
      'is_canceled': tskIsCanceled,
      'priority': tskPriorityName,
      'description': tskDescription,
      'uid': uid,
      'id': tskId,
      'displayed_color': tskDisplayedColor,
    });
  }

  @override
  Widget build(BuildContext context) {
    return NewScheduledTask(
        _addNewScheduledTask,
        "",
        "",
        DateTime.now().toString(),
        DateTime.now(),
        Priority_Enum.Normal,
        Category(
            amount: 1,
            id: DateTime.now().toString(),
            name: "Mock",
            uid: "Mock"),
        DateTime.now(),
        DateTime.now(),
        256);
  }
}
