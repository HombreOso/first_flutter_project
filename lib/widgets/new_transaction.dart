import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/category.dart';
import 'package:intl/intl.dart';

import './dropdownExpenseCategories.dart';

class NewTransaction extends StatefulWidget {
  final Function addTx;
  final String initialAmountText;
  final String initialTitleText;
  final String txDateIdAsString;
  final DateTime txDate;

  NewTransaction(
    this.addTx,
    this.initialAmountText,
    this.initialTitleText,
    this.txDateIdAsString,
    this.txDate,
  );

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  var _amountController;
  var _titleController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitleText);
    _amountController = TextEditingController(text: widget.initialAmountText);
  }

  // final _titleController = TextEditingController();
  // final _amountController = TextEditingController();
  String _selectedCategory = "Food";
  DateTime _selectedDate = DateTime.now();
  bool _usedDefaultDate = true;

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }

    widget.addTx(
      enteredTitle,
      enteredAmount,
      _selectedDate,
      _selectedCategory,
      widget.txDateIdAsString,
      _usedDefaultDate,
      widget.txDate,
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        setState(() {
          print("then: $pickedDate");
          _selectedDate = DateTime.now();
        });
        _usedDefaultDate = true;
      } else {
        setState(() {
          print("else: $pickedDate");
          _selectedDate = pickedDate;
        });
        _usedDefaultDate = false;
      }
    });
    print('...');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
              onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
              // onChanged: (val) {
              //   titleInput = val;
              // },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
              // onChanged: (val) => amountInput = val,
            ),
            SizedBox(
              height: 20,
            ),
            DropdownButtonExample(
              onChangedDDL: (value) {
                _selectedCategory = value;
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
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).secondaryHeaderColor),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
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
            ElevatedButton(
              child: Text(
                'Add Transaction',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).secondaryHeaderColor),
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
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
                  final List<DocumentSnapshot<Map<String, dynamic>>> documents =
                      snapshot.data!.docs
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
                                    Theme.of(context).secondaryHeaderColor),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor),
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
    );
  }
}
