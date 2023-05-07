import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/category.dart';

class DropdownButtonExample extends StatefulWidget {
  final Function(String) onChangedDDL;
  final BuildContext ctx;

  DropdownButtonExample({
    required this.onChangedDDL,
    required this.ctx,
  });

  @override
  State<DropdownButtonExample> createState() =>
      _DropdownButtonExampleState(onChangedDDL: onChangedDDL);
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = "";
  // ignore: todo
  // TODO screen where this categories can be specified by user
  Function(String) onChangedDDL;

  _DropdownButtonExampleState({
    required this.onChangedDDL,
  });

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();
    print("uid dropdown $uid");
    return StreamBuilder<QuerySnapshot>(
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
          final List<Category> loadedCategories = [];
          final List<DocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.data!.docs
                  .cast<DocumentSnapshot<Map<String, dynamic>>>();
          documents.forEach((doc) {
            final ctry = Category.fromSnapshot(doc);
            loadedCategories.add(ctry);
          });
          List<Category> loadedCategoryCurrentUser = loadedCategories
              .where(
                (element) => element.uid == uid,
              )
              .toList();
          List<String> loadedCategoryNames = [
            for (var x in loadedCategoryCurrentUser) x.name
          ];
          print("loadedCategoryNames: $loadedCategoryNames");

          return loadedCategoryNames.isEmpty
              ? TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).secondaryHeaderColor),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).unselectedWidgetColor),
                  ),
                  child: Text(
                    'No Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/categories'),
                )
              : Theme(
                  data: Theme.of(context),
                  child: !loadedCategoryNames.isEmpty
                      ? Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: dropdownValue == ''
                                    ? Text(loadedCategoryNames[0])
                                    : Text('$dropdownValue'),
                              ),
                              Container(
                                height: 35,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Theme.of(widget.ctx).primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: PopupMenuButton<String>(
                                  tooltip: "category",
                                  icon: Icon(
                                    Icons.category,
                                  ),
                                  initialValue: dropdownValue,
                                  itemBuilder: (BuildContext context) {
                                    return loadedCategoryNames
                                        .map((String value) {
                                      return PopupMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
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
                                        dropdownValue = value;
                                      });
                                      onChangedDDL(dropdownValue);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text('No categories defined'),
                );
        });
  }
}
