import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_complete_guide/models/category.dart';
import 'package:flutter_complete_guide/models/scheduled_task.dart';
import 'package:intl/intl.dart' as intl_package;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/priority_enum.dart';
import 'dropdownExpenseCategories.dart';
import 'dropdownPriority.dart';
import '../screens/calendar_view.dart';

class NewScheduledTask extends ConsumerStatefulWidget {
  final Function addTsk;
  final Function updateTsk;
  final String initialTitleText;
  final String initialDescription;
  final DateTime tskInitialStartDateTime;
  final DateTime tskInitialEndDateTime;
  final String? tskId;

  NewScheduledTask(
    this.addTsk,
    this.updateTsk,
    this.initialTitleText,
    this.initialDescription,
    this.tskInitialStartDateTime,
    this.tskInitialEndDateTime,
    this.tskId,
  );

  @override
  _NewScheduledTaskState createState() => _NewScheduledTaskState();
}

class _NewScheduledTaskState extends ConsumerState<NewScheduledTask> {
  var _descriptionController;
  var _tskNameController;
  var tskStartDatetimePlanned;
  String tskCategory = "Job";
  var tskEndDatetimePlanned;
  //hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute
  DateTime tskStartDatetimeAsIs = DateTime.now();
  DateTime tskEndDatetimeAsIs = DateTime.now().add(Duration(hours: 3));
  bool? tskIsCanceled;
  String? tskPriorityName;
  String? tskDescription;
  String? tskUid;
  String? tskId;

  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  Future<ScheduledTask> get tappedTask async {
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
    return await snapshot.docs
        .map((doc) => ScheduledTask.fromMap(doc.data()))
        .toList()
        .where((tsk) => tsk.uid == uid && tsk.id == widget.tskId)
        .first;
  }

  @override
  void initState() {
    super.initState();
    print("widget.initialTitleText: ${widget.initialTitleText}");
    _tskNameController = TextEditingController(text: widget.initialTitleText);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  // final _tskNameController = TextEditingController();
  // final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedStartTime = TimeOfDay.now();
  TimeOfDay? _selectedEndTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  bool _usedDefaultDate = true;

  double convertTimeOfDayToDoubleFormatHours(TimeOfDay timeToConvert) {
    return timeToConvert.hour + timeToConvert.minute / 60.0;
  }

  DateTime convertTimeOfDayToDateTime(
      TimeOfDay? timeOfDayToConvert, DateTime selectedDate) {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      timeOfDayToConvert!.hour,
      timeOfDayToConvert.minute,
    );
  }

  Future<TimeOfDay?> time_picker_func(selectedTime, entryMode, orientation,
      tapTargetSize, ctx, initialTime) async {
    TimeOfDay? time = await showTimePicker(
      context: ctx,
      initialTime: initialTime,
      initialEntryMode: entryMode,
      orientation: orientation,
      builder: (BuildContext context, Widget? child) {
        // We just wrap these environmental changes around the
        // child in this builder so that we can apply the
        // options selected above. In regular usage, this is
        // rarely necessary, because the default values are
        // usually used as-is.
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: tapTargetSize,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
    setState(() {
      selectedTime = time;
    });
    return time;
  }

  Future<void> presentColorPicker(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

// raise the [showDialog] widget

  void _presentStartTimePicker() async {
    _selectedStartTime = await time_picker_func(
      _selectedStartTime,
      TimePickerEntryMode.dial,
      Orientation.portrait,
      MaterialTapTargetSize.padded,
      context,
      TimeOfDay(
          hour: widget.tskInitialStartDateTime.hour,
          minute: widget.tskInitialStartDateTime.minute),
    );

    tskStartDatetimePlanned = convertTimeOfDayToDateTime(
        _selectedStartTime ??
            TimeOfDay(
                hour: widget.tskInitialStartDateTime.hour,
                minute: widget.tskInitialStartDateTime.minute),
        _selectedDate);
    print(tskStartDatetimePlanned.toString());
  }

  void _presentEndTimePicker() async {
    _selectedEndTime = await time_picker_func(
      _selectedEndTime,
      TimePickerEntryMode.dial,
      Orientation.portrait,
      MaterialTapTargetSize.padded,
      context,
      TimeOfDay(
          hour: widget.tskInitialEndDateTime.hour,
          minute: widget.tskInitialEndDateTime.minute),
    );
    tskEndDatetimePlanned = convertTimeOfDayToDateTime(
        _selectedEndTime ??
            TimeOfDay(
                hour: widget.tskInitialEndDateTime.hour,
                minute: widget.tskInitialEndDateTime.minute),
        _selectedDate);
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: widget.tskInitialStartDateTime,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year).add(Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate == null) {
        setState(() {
          print("then: $pickedDate");
          _selectedDate = DateTime.now();
          tskStartDatetimePlanned =
              convertTimeOfDayToDateTime(_selectedStartTime, _selectedDate);
          tskEndDatetimePlanned =
              convertTimeOfDayToDateTime(_selectedEndTime, _selectedDate);
        });
        _usedDefaultDate = true;
      } else {
        setState(() {
          print("else: $pickedDate");
          _selectedDate = pickedDate;
          tskStartDatetimePlanned =
              convertTimeOfDayToDateTime(_selectedStartTime, _selectedDate);
          tskEndDatetimePlanned =
              convertTimeOfDayToDateTime(_selectedEndTime, _selectedDate);
        });
        _usedDefaultDate = false;
      }
    });
    print('...');
  }

  VoidCallback? _submitData() {
    final tskDescription = _descriptionController.text;

    final tskId = DateTime.now().toString();

    final tskName = _tskNameController.text;

    final isToBeUpdated = ref.watch(isToUpdateProvider);

    print("isToBeUpdated $isToBeUpdated");

    if (tskName.isEmpty) {
      return null;
    }

    if (convertTimeOfDayToDoubleFormatHours(_selectedEndTime!) <=
        convertTimeOfDayToDoubleFormatHours(_selectedStartTime!)) {
      return null;
    }

    print("Current color value: ${currentColor.value}");
    if (isToBeUpdated) {
      widget.updateTsk(
        tskName,
        tskCategory,
        tskStartDatetimePlanned ?? widget.tskInitialStartDateTime,
        tskEndDatetimePlanned ?? widget.tskInitialEndDateTime,
        tskStartDatetimeAsIs,
        tskEndDatetimeAsIs,
        tskIsCanceled,
        tskPriorityName,
        tskDescription,
        tskUid,
        tskId,
        currentColor.value,
      );
    } else {
      widget.addTsk(
        tskName,
        tskCategory,
        tskStartDatetimePlanned,
        tskEndDatetimePlanned,
        tskStartDatetimeAsIs,
        tskEndDatetimeAsIs,
        tskIsCanceled,
        tskPriorityName,
        tskDescription,
        tskUid,
        tskId,
        currentColor.value,
      );
      return null;
    }

    Navigator.of(context).pop();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        foregroundColor: Theme.of(context).primaryColor,
        title: Text('Add Task'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                onTapOutside: ((event) {
                  FocusScope.of(context).unfocus();
                }),
                decoration: InputDecoration(
                  hintText: 'Name',
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                ),
                controller: _tskNameController,
                onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
                // onChanged: (val) {
                //   titleInput = val;
                // },
              ),
              SizedBox(
                height: 20,
              ),
              LayoutBuilder(builder: ((context, constraints) {
                return SizedBox(
                  height: 150,
                  child: TextField(
                    onTapOutside: ((event) {
                      FocusScope.of(context).unfocus();
                    }),
                    textAlignVertical: TextAlignVertical.top,
                    textAlign: TextAlign.start,
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      hintText: 'Description',
                      focusColor: Theme.of(context).secondaryHeaderColor,
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                    ),
                    controller: _descriptionController,
                    onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
                    // onChanged: (val) => amountInput = val,
                  ),
                );
              })),
              SizedBox(
                height: 10,
              ),
              DropdownButtonExample(
                onChangedDDL: (value) {
                  tskCategory = value;
                },
                ctx: context,
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonPriority(
                onChangedDDL: (value) {
                  tskPriorityName = priorityMap[value];
                },
                ctx: context,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Picked Date: ${intl_package.DateFormat.yMd().format(widget.tskInitialStartDateTime)}',
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).canvasColor),
                      ),
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _presentDatePicker,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Picked Start Time: ${intl_package.DateFormat.jm().format(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          widget.tskInitialStartDateTime.hour,
                          widget.tskInitialStartDateTime.minute,
                        ))}',
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).canvasColor),
                      ),
                      child: Text(
                        'Choose Start Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _presentStartTimePicker,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Picked End Time: ${intl_package.DateFormat.jm().format(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          widget.tskInitialEndDateTime.hour,
                          widget.tskInitialEndDateTime.minute,
                        ))}',
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).canvasColor),
                      ),
                      child: Text(
                        'Choose End Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _presentEndTimePicker,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.color_lens,
                  color: currentColor,
                ),
                label: Text(
                  'Pick a Color',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).secondaryHeaderColor),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).canvasColor),
                    textStyle: MaterialStateProperty.all(Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.white)),
                    // padding: MaterialStateProperty.all(
                    //   EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    // ),
                    alignment: Alignment.center),
                onPressed: () => presentColorPicker(context),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: Text(
                  'Add Task',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).secondaryHeaderColor),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).canvasColor),
                    textStyle: MaterialStateProperty.all(Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.white)),
                    // padding: MaterialStateProperty.all(
                    //   EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    // ),
                    alignment: Alignment.center),
                onPressed: _submitData,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .orderBy('amount', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final List<String> loadedCategoryNames = [];
                    final List<DocumentSnapshot<Map<String, dynamic>>>
                        documents = snapshot.data!.docs
                            .cast<DocumentSnapshot<Map<String, dynamic>>>()
                            .cast<DocumentSnapshot<Map<String, dynamic>>>();
                    documents.forEach((doc) {
                      final category = Category.fromSnapshot(doc);
                      loadedCategoryNames.add(category.name);
                    });

                    return Container(
                      //padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          // SizedBox(
                          //   height: 10,
                          // ),
                          if (!loadedCategoryNames.isEmpty)
                            ElevatedButton(
                              child: Text(
                                'New Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).canvasColor),
                                  textStyle: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: Colors.white)),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                  ),
                                  alignment: Alignment.center),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/categories'),
                            ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
