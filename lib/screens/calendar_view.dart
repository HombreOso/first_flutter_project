import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_complete_guide/screens/add_new_task_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/meeting_class.dart';
import '../models/scheduled_task.dart';

final isToUpdateProvider = StateProvider<bool>(
  // We return the default sort type, here name.
  (ref) => true,
);

/// The hove page which hosts the calendar
class CalendarScreen extends ConsumerStatefulWidget {
  /// Creates the home page to display teh calendar widget.
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CalendarScreenState createState() => _CalendarScreenState();
}

final CollectionReference tasksCollectionRef =
    FirebaseFirestore.instance.collection('tasks');

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  void _startAddNewTask(BuildContext ctx, String? tskId) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTaskScreen(
            tskIdtapped: tskId,
          ),
        ));
  }

  Future<List<ScheduledTask>> get listOfTasks async {
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
    return await snapshot.docs
        .map((doc) => ScheduledTask.fromMap(doc.data()))
        .toList()
        .where((tsk) => tsk.uid == uid)
        .toList();
  }

  final CalendarController _controller = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        foregroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Calendar',
        ),
        actions: <Widget>[
          DropdownButton2(
            isExpanded: true,
            alignment: Alignment.centerRight,
            underline: Container(),
            dropdownStyleData: DropdownStyleData(
              width: 200,
            ),
            buttonStyleData: ButtonStyleData(
              width: 80,
            ),
            iconStyleData: IconStyleData(
              //iconSize: 30,
              icon: Icon(
                Icons.view_week,
                color: Theme.of(context).primaryColor,
              ),
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Day'),
                    ],
                  ),
                ),
                value: 'day_view',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.featured_play_list_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Week'),
                    ],
                  ),
                ),
                value: 'week_view',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Month'),
                    ],
                  ),
                ),
                value: 'month_view',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Schedule'),
                    ],
                  ),
                ),
                value: 'schedule_view',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'day_view') {
                _controller.view = CalendarView.day;
              } else if (itemIdentifier == 'week_view') {
                _controller.view = CalendarView.week;
              } else if (itemIdentifier == 'month_view') {
                _controller.view = CalendarView.month;
              } else if (itemIdentifier == 'schedule_view') {
                _controller.view = CalendarView.schedule;
              }
            },
          ),
          DropdownButton2(
            isExpanded: true,
            alignment: Alignment.centerRight,
            underline: Container(),
            dropdownStyleData: DropdownStyleData(
              width: 200,
            ),
            buttonStyleData: ButtonStyleData(
              width: 80,
            ),
            iconStyleData: IconStyleData(
              //iconSize: 30,
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryColor,
              ),
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.featured_play_list_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('My Categories'),
                    ],
                  ),
                ),
                value: 'categories',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text('Calendar'),
                    ],
                  ),
                ),
                value: 'calendar',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              } else if (itemIdentifier == 'categories') {
                Navigator.pushNamed(context, '/categories');
              } else if (itemIdentifier == 'calendar') {
                Navigator.pushNamed(context, '/calendar');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 15),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final List<ScheduledTask> loadedTasks = [];
              //try {
              final List<DocumentSnapshot<Map<String, dynamic>>> documents =
                  snapshot.data!.docs
                      .cast<DocumentSnapshot<Map<String, dynamic>>>();
              documents.forEach((doc) {
                print("before snapshot");
                final task = ScheduledTask.fromSnapshot(doc);
                print("after snapshot");
                loadedTasks.add(task);
              });
              return SfCalendar(
                view: CalendarView.week,
                controller: _controller,
                dataSource: MeetingDataSource(_getDataSource(loadedTasks)),
                // by default the month appointment display mode set as Indicator, we can
                // change the display mode as appointment using the appointment display
                // mode property
                monthViewSettings: const MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),
                onTap: calendarTapped,
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          focusColor: Theme.of(context).canvasColor,
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            ref.read(isToUpdateProvider.notifier).state = false;
            _startAddNewTask(context, null);
          }),
    );
  }

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
      _dateText = appointmentDetails.tskId;
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
                child: Text('Close'),
              ),
              TextButton(
                  onPressed: () {
                    ref.read(isToUpdateProvider.notifier).state = true;
                    print(ref.read(isToUpdateProvider.notifier).state);
                    _startAddNewTask(context, _dateText);
                  },
                  child: Text('Copy'))
            ],
          );
        });
  }

  List<Meeting> _getDataSource(List<ScheduledTask> tasks) {
    final List<Meeting> meetings = <Meeting>[];

    tasks.forEach((element) {
      meetings.add(Meeting(
          element.name,
          element.id,
          element.start_datetime_planned,
          element.end_datetime_planned,
          Color(element.displayedColor),
          false));
    });
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
