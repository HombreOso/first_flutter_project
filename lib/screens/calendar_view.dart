import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/meeting_class.dart';
import '../models/scheduled_task.dart';

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
  // colors to choose from for appointemnts, meetings
  List<Color> colors_list = [
    Color(0xFFEF9A9A),
    Color(0xFFE57373),
    Color(0xFFEF5350),
    Color(0xFFF48FB1),
  ];

  void _startAddNewTask(BuildContext ctx) {
    Navigator.pushNamed(context, '/new_task');
  }

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
          onTap: calendarTapped,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          focusColor: Theme.of(context).canvasColor,
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () => _startAddNewTask(context)

          // time_picker_func(
          //       TimeOfDay.now(),
          //       TimePickerEntryMode.dial,
          //       Orientation.portrait,
          //       MaterialTapTargetSize.padded,
          //       context,
          //     )

          ),
    );
  }

  List<ScheduledTask> _userScheduledTasks = [];

  static final CollectionReference tasksCollectionRef =
      FirebaseFirestore.instance.collection('tasks');

  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  // initial values for CalendarTapDetails
  String? _subjectText = '',
      _startTimeText = '',
      _endTimeText = '',
      _dateText = '',
      _timeDetails = '';

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Meeting appointmentDetails = details.appointments![0];
      _subjectText = appointmentDetails.eventName;
      _dateText = 'lala';
      _startTimeText = 'lala';
      _endTimeText = 'lala';
      _timeDetails = '$_startTimeText - $_endTimeText';
    } else if (details.targetElement == CalendarElement.calendarCell) {
      _subjectText = "You have tapped cell";
      _dateText = 'lala';
      _timeDetails = '';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(child: new Text('$_subjectText')),
            content: Container(
              height: 80,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '$_dateText',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    child: Row(
                      children: <Widget>[
                        Text(_timeDetails!,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'))
            ],
          );
        });
  }

  // -------------------------------------

  Future<void> _addNewScheduledTask(
    String tskName,
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
    final newTsk = ScheduledTask(
      name: tskName,
      start_datetime_planned: tskStartDatetimePlanned,
      end_datetime_planned: tskEndDatetimePlanned,
      start_datetime_as_is: tskStartDatetimeAsIs,
      end_datetime_as_is: tskEndDatetimeAsIs,
      is_canceled: tskIsCanceled,
      priority: tskPriority,
      decription: tskDescription,
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
      'priority': tskPriority,
      'decription': tskDescription,
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
