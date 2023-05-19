import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';

class NewCategory extends StatefulWidget {
  final Function addCt;
  final String nameCt;
  final String amountCt;
  final String nameCurrentCt;

  NewCategory(this.addCt, this.nameCt, this.amountCt, this.nameCurrentCt);

  @override
  _NewCategoryState createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  var _amountController;
  var _titleController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.nameCt);
    _amountController = TextEditingController(text: widget.amountCt);
  }

  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  Future<List<String>> get namesOfCategories async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<Category> loadedCategories = snapshot.docs
        .map((doc) => Category.fromMap(doc.data()))
        .toList()
        .where((cat) => cat.uid == uid)
        .toList();
    return await loadedCategories.map((e) => e.name as String).toList();
  }

  bool _usedDefaultDate = true;

  Future<void> _submitData() async {
    if (_amountController.text.isEmpty) {
      return;
    }
    var enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }
    if ((await namesOfCategories).contains(enteredTitle)) {
      enteredTitle += "_";
    }
    widget.addCt(enteredTitle, enteredAmount, "");

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[400],
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                labelText: 'Title',
                focusColor: Colors.amber,
                labelStyle: TextStyle(color: Colors.black),
              ),
              controller: _titleController,
              onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
              cursorColor: Colors.amber,
              // onChanged: (val) {
              //   titleInput = val;
              // },
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                  labelText: 'Weekly Time',
                  focusColor: Colors.amber,
                  labelStyle: TextStyle(color: Colors.black)),
              controller: _amountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
              cursorColor: Colors.amber,
              // onChanged: (val) => amountInput = val,
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: Text(
                'Add Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.black54),
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  textStyle: MaterialStateProperty.all(Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.white)),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  alignment: Alignment.center),
              onPressed: _submitData,
            ),
          ],
        ),
      ),
    );
  }
}
