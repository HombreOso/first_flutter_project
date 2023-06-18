import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/category.dart';
import 'package:flutter_complete_guide/models/priority_enum.dart';
import 'package:flutter_complete_guide/widgets/new_scheduled_task.dart';

import '../models/scheduled_task.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  final String? tskIdtapped;
  // String titleInput;
  // String amountInput;
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();

  AddTaskScreen({required this.tskIdtapped});
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  List<ScheduledTask> _userScheduledTasks = [];

  static final CollectionReference tasksCollectionRef =
      FirebaseFirestore.instance.collection('tasks');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  Future<ScheduledTask> get tappedTask async {
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
    return await snapshot.docs
        .map((doc) => ScheduledTask.fromMap(doc.data()))
        .toList()
        .where((tsk) => tsk.uid == uid && tsk.id == widget.tskIdtapped)
        .first;
  }

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
    if (widget.tskIdtapped != null) {
      tappedTask.then((tTask) {
        DateTime tskStartDatetimePlanned = tTask.start_datetime_planned;
        //tskCategory = tTask.;
        DateTime tskEndDatetimePlanned = tTask.end_datetime_planned;
        //hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute
        DateTime tskStartDatetimeAsIs = tTask.start_datetime_as_is;
        DateTime tskEndDatetimeAsIs = tTask.end_datetime_as_is;
        bool? tskIsCanceled = tTask.is_canceled;
        String tskPriorityName = tTask.priority;
        String tskDescription = tTask.description;
        String tskUid = tTask.uid;
        print("tapped on a task");
        print("task name: ${tTask.name}");
        print("task description: ${tTask.description}");
        return NewScheduledTask(
            _addNewScheduledTask,
            tTask.name,
            tTask.description,
            DateTime.now().toString(),
            DateTime.now(),
            widget.tskIdtapped);
      }).onError((error, stackTrace) {
        return NewScheduledTask(_addNewScheduledTask, "", "",
            DateTime.now().toString(), DateTime.now(), widget.tskIdtapped);
      });
    }

    return NewScheduledTask(_addNewScheduledTask, "", "",
        DateTime.now().toString(), DateTime.now(), widget.tskIdtapped);
  }
}
