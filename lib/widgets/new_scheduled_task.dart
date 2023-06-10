import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/category.dart';
import 'package:intl/intl.dart' as intl_package;

import '../models/priority_enum.dart';
import 'dropdownExpenseCategories.dart';
import 'dropdownPriority.dart';

class NewScheduledTask extends StatefulWidget {
  final Function addTsk;
  final String initialTitleText;
  final String initialDescription;
  final String txDateIdAsString;
  final DateTime txDate;

  NewScheduledTask(
    this.addTsk,
    this.initialTitleText,
    this.initialDescription,
    this.txDateIdAsString,
    this.txDate,
  );

  @override
  _NewScheduledTaskState createState() => _NewScheduledTaskState();
}

class _NewScheduledTaskState extends State<NewScheduledTask> {
  var _descriptionController;
  var _tskNameController;
  DateTime tskStartDatetimePlanned = DateTime.timestamp();
  String tskCategory = "Job";
  DateTime tskEndDatetimePlanned = DateTime.timestamp().add(Duration(hours: 3));
  //hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute
  DateTime tskStartDatetimeAsIs = DateTime.timestamp();
  DateTime tskEndDatetimeAsIs = DateTime.timestamp().add(Duration(hours: 3));
  bool? tskIsCanceled;
  String? tskPriorityName;
  String? tskDescription;
  String? tskUid;
  String? tskId;

  @override
  void initState() {
    super.initState();
    _tskNameController = TextEditingController(text: widget.initialTitleText);
    _descriptionController =
        TextEditingController(text: widget.initialTitleText);
  }

  // final _tskNameController = TextEditingController();
  // final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedStartTime = TimeOfDay.now();
  TimeOfDay? _selectedEndTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

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

  void _submitData() {
    final tskDescription = _descriptionController.text;

    if (_descriptionController.text.isEmpty) {
      return;
    }
    final tskName = _tskNameController.text;

    if (tskName.isEmpty) {
      return;
    }

    if (convertTimeOfDayToDoubleFormatHours(_selectedEndTime!) <=
        convertTimeOfDayToDoubleFormatHours(_selectedStartTime!)) {
      return;
    }
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
    );

    Navigator.of(context).pop();
  }

  Future<TimeOfDay?> time_picker_func(
      selectedTime, entryMode, orientation, tapTargetSize, ctx) async {
    TimeOfDay? time = await showTimePicker(
      context: ctx,
      initialTime: selectedTime ?? TimeOfDay.now(),
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

  void _presentStartTimePicker() async {
    _selectedStartTime = await time_picker_func(
      _selectedStartTime,
      TimePickerEntryMode.dial,
      Orientation.portrait,
      MaterialTapTargetSize.padded,
      context,
    );
    tskStartDatetimePlanned =
        convertTimeOfDayToDateTime(_selectedStartTime, _selectedDate);
    print(tskStartDatetimePlanned.toString());
  }

  void _presentEndTimePicker() async {
    _selectedEndTime = await time_picker_func(
      _selectedEndTime,
      TimePickerEntryMode.dial,
      Orientation.portrait,
      MaterialTapTargetSize.padded,
      context,
    );
    tskEndDatetimePlanned =
        convertTimeOfDayToDateTime(_selectedEndTime, _selectedDate);
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(Duration(days: 365)),
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
                    keyboardType: TextInputType.number,
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
                        'Picked Date: ${intl_package.DateFormat.yMd().format(_selectedDate)}',
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
                          _selectedStartTime!.hour,
                          _selectedStartTime!.minute,
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
                          _selectedEndTime!.hour,
                          _selectedEndTime!.minute,
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
