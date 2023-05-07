import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/new_transaction.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction_> transactions;
  final Function deleteTx;

  TransactionList(this.transactions, this.deleteTx);

  static final CollectionReference transactionCollectionRef =
      FirebaseFirestore.instance.collection('transactions');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  void _startUpdateNewTransaction(BuildContext ctx, NewTransaction newTx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: newTx,
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  Future<int> get numberOfCategories async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<Category> loadedCategories = snapshot.docs
        .map((doc) => Category.fromMap(doc.data()))
        .toList()
        .where((cat) => cat.uid == uid)
        .toList();
    return await loadedCategories.length;
  }

  Future<void> _updateNewTransaction(
    String txTitle,
    double txAmount,
    DateTime chosenDate,
    String txCategory,
    String txDateIdAsString,
    bool usedDefaultDate,
    DateTime txDate,
  ) async {
    final String transactionIdAsCurrentDateTime = DateTime.now().toString();
    final newTx = Transaction_(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: transactionIdAsCurrentDateTime,
      category: txCategory,
      uid: uid,
    );
    print("update id $txDateIdAsString");
    // Write the transaction to Firebase
    final uptodatedDoc = await transactionCollectionRef
        .where(
          'uid',
          isEqualTo: uid,
        )
        .where(
          'id',
          isEqualTo: txDateIdAsString,
        )
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) => snapshot.docs[0].reference);
    uptodatedDoc.update({
      'uid': uid,
      'id': txDateIdAsString,
      'title': newTx.title,
      'amount': newTx.amount,
      'date': usedDefaultDate
          ? Timestamp.fromDate(txDate)
          : Timestamp.fromDate(newTx.date),
      'category': newTx.category,
    });
    // add({
    //   'uid': uid,
    //   'id': transactionIdAsCurrentDateTime,
    //   'title': newTx.title,
    //   'amount': newTx.amount,
    //   'date': Timestamp.fromDate(newTx.date),
    //   'category': newTx.category,
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: transactions.isEmpty
          ? Column(
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .orderBy('amount', descending: true)
                        .snapshots(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final List<Category> loadedCategories = [];
                      //try {
                      final List<DocumentSnapshot<Map<String, dynamic>>>
                          documents = snapshot.data!.docs
                              .cast<DocumentSnapshot<Map<String, dynamic>>>();
                      documents.forEach(
                        (doc) {
                          final category = Category.fromSnapshot(doc);
                          loadedCategories.add(category);
                        },
                      );
                      return loadedCategories
                                  .where((categ) => categ.uid == uid)
                                  .length !=
                              0
                          ? Text(
                              'No transactions added yet!',
                              style: Theme.of(context).textTheme.titleLarge,
                            )
                          : ElevatedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/categories'),
                              child: Text(
                                'Please add categories first',
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
                                  // padding: MaterialStateProperty.all(
                                  //   EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  // ),
                                  alignment: Alignment.center),
                            );
                    }),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height: 200,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    )),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: Key(transactions[index].id),
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    print("Dismissed id: ${transactions[index].id}");
                    print("Dismissed uid: ${transactions[index].uid}");
                    deleteTx(
                      transactions,
                      transactions[index].id,
                      transactions[index].uid,
                    );
                  },
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Handle edit transaction here
                        print('Edit transaction ${transactions[index].id}');
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: FittedBox(
                              child: Text('\$${transactions[index].amount}'),
                            ),
                          ),
                        ),
                        title: Text(
                          transactions[index].title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMd()
                                  .format(transactions[index].date),
                            ),
                            Text(
                              transactions[index].category,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.blueAccent,
                          onPressed: () {
                            // Handle edit transaction here
                            print('Edit transaction ${transactions[index].id}');
                            _startUpdateNewTransaction(
                              ctx,
                              NewTransaction(
                                  _updateNewTransaction,
                                  transactions[index].amount.toString(),
                                  transactions[index].title,
                                  transactions[index].id,
                                  transactions[index].date),
                            );
                            //return NewTransaction(addTx, initialAmountText, initialTitleText)
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: transactions.length,
            ),
    );
  }
}
