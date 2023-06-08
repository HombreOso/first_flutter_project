import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_complete_guide/models/priority_enum.dart';

class DropdownButtonPriority extends StatefulWidget {
  final Function(Priority_Enum) onChangedDDL;
  final BuildContext ctx;

  DropdownButtonPriority({
    required this.onChangedDDL,
    required this.ctx,
  });

  @override
  State<DropdownButtonPriority> createState() =>
      _DropdownButtonPriorityState(onChangedDDL: onChangedDDL);
}

class _DropdownButtonPriorityState extends State<DropdownButtonPriority> {
  Priority_Enum dropdownValue = Priority_Enum.Normal;
  // ignore: todo
  // TODO screen where this categories can be specified by user
  Function(Priority_Enum) onChangedDDL;

  _DropdownButtonPriorityState({
    required this.onChangedDDL,
  });

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();
    print("uid dropdown $uid");
    return Theme(
        data: Theme.of(context),
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Text('$dropdownValue'),
              ),
              Container(
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: Theme.of(widget.ctx).canvasColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: PopupMenuButton<String>(
                  tooltip: "category",
                  icon: Icon(
                    Icons.label_important,
                  ),
                  initialValue: dropdownValue.name,
                  itemBuilder: (BuildContext context) {
                    return Priority_Enum.values.map((Priority_Enum value) {
                      return PopupMenuItem<String>(
                        value: value.name,
                        child: Text(
                          value.name,
                          style: TextStyle(
                            color: Theme.of(context).canvasColor,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (String? value) {
                    if (value != null) {
                      setState(() {
                        dropdownValue = Priority_Enum.values.firstWhere(
                            (element) =>
                                element.toString() == "Priority_Enum." + value);
                      });
                      onChangedDDL(dropdownValue);
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
