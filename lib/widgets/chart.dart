import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import './chart_bar.dart';
import '../models/transaction.dart';

class Chart extends StatelessWidget {
  final List<Transaction_> currentMonthTransactions;

  Chart(this.currentMonthTransactions);

  List<Category> categories = [];
  static final CollectionReference categoriesCollectionRef =
      FirebaseFirestore.instance.collection('categories');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );
      var totalSum = 0.0;

      for (var i = 0; i < currentMonthTransactions.length; i++) {
        if (currentMonthTransactions[i].date.day == weekDay.day &&
            currentMonthTransactions[i].date.month == weekDay.month &&
            currentMonthTransactions[i].date.year == weekDay.year) {
          totalSum += currentMonthTransactions[i].amount;
        }
      }

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'amount': totalSum,
      };
    }).reversed.toList();
  }

  List<Map<String, dynamic>> groupedTransactionValuesByCategory(
    List<Category> allCategories,
  ) {
    return List.generate(allCategories.length, (index) {
      allCategories.sort((a, b) => a.amount.compareTo(b.amount));
      final cat_name = allCategories[index].name;
      var totalSum = 0.0;

      for (var i = 0; i < currentMonthTransactions.length; i++) {
        if (currentMonthTransactions[i].category == cat_name) {
          totalSum += currentMonthTransactions[i].amount;
        }
      }

      return {
        'category': cat_name as String,
        'amount': totalSum,
        'total_amount_available': allCategories[index].amount.toString(),
        'remaining_amount':
            (allCategories[index].amount - totalSum).toStringAsFixed(0),
        'perc_spent':
            (totalSum / allCategories[index].amount * 100).toStringAsFixed(0)
      };
    }).reversed.toList();
  }

  double get totalSpending {
    return groupedTransactionValues.fold(0.0, (sum, item) {
      return sum + (item['amount'] as num);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          //try {
          final List<DocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.data!.docs
                  .cast<DocumentSnapshot<Map<String, dynamic>>>();
          documents.forEach(
            (doc) {
              final category = Category.fromSnapshot(doc);
              loadedCategories.add(category);
            },
          );

          // } catch (e) {
          //   // Handle errors
          //   print('No docs in collection categories: $e');
          // }
          return Card(
            elevation: 6,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: groupedTransactionValuesByCategory(loadedCategories
                        .where((lddcat) => lddcat.uid == uid)
                        .toList())
                    .map((data) {
                  return Flexible(
                    fit: FlexFit.tight,
                    child: ChartBar(
                      data['category'] as String?,
                      data['amount'] as double?,
                      totalSpending == 0.0
                          ? 0.0
                          : (data['amount'] as double) / totalSpending,
                      data['perc_spent'] as String,
                      data['remaining_amount'] as String,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        });
  }
}
