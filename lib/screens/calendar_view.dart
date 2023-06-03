import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:flutter_complete_guide/screens/confirm_email_screen.dart';
import 'package:flutter_complete_guide/screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/scheduled_task.dart';
import '../screens/expenses_screen.dart';

import '../screens/add_categories_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../models/priority_enum.dart';

/// The hove page which hosts the calendar
class CalendarScreen extends StatefulWidget {
  /// Creates the home page to display teh calendar widget.
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 15),
      child: SfCalendar(
        view: CalendarView.week,
        dataSource: MeetingDataSource(_getDataSource()),
        // by default the month appointment display mode set as Indicator, we can
        // change the display mode as appointment using the appointment display
        // mode property
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
    ));
  }

  List<ScheduledTask> _userScheduledTasks = [];

  static final CollectionReference tasksCollectionRef =
      FirebaseFirestore.instance.collection('tasks');

  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  Future<void> _addNewScheduledTask(
    String tskName,
    DateTime tskDeadline,
    DateTime tskStartDatetimePlanned,
    DateTime tskEndDatetimePlanned,
    DateTime tskStartDatetimeAsIs,
    DateTime tskEndDatetimeAsIs,
    bool tskIsCanceled,
    Priority tskPriority,
    String tskDescription,
    String tskUid,
    String tskId,
  ) async {
    final String transactionIdAsCurrentDateTime = DateTime.now().toString();
    final newTx = ScheduledTask(
      name: tskName,
      deadline: tskDeadline,
      start_datetime_planned: tskStartDatetimePlanned,
      end_datetime_planned: tskEndDatetimePlanned,
      start_datetime_as_is: tskStartDatetimeAsIs,
      end_datetime_as_is: tskEndDatetimeAsIs,
      is_canceled: tskIsCanceled,
      priority: tskPriority,
      decription: tskDescription,
      tskUid: tskUid,
      id: tskId,
    );
    setState(() {
      _userScheduledTasks.add(newTx);
    });
    // Write the transaction to Firebase
    await tasksCollectionRef.add({
      'name': tskName,
      'deadline': tskDeadline,
      'start_datetime_planned': tskStartDatetimePlanned,
      'end_datetime_planned': tskEndDatetimePlanned,
      'start_datetime_as_is': tskStartDatetimeAsIs,
      'end_datetime_as_is': tskEndDatetimeAsIs,
      'is_canceled': tskIsCanceled,
      'priority': tskPriority,
      'decription': tskDescription,
      'uid': tskUid,
      'id': tskId,
    });
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Conference', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }

  void _addScheduledTask() {}
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}
