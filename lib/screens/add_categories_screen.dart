import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

import '../widgets/new_category.dart';
import '../models/category.dart';
import '../widgets/categories_list.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];
  final double weekTotalDuration = 112;
  final List<Color> colorsList = [
    Colors.redAccent,
    Colors.orange,
    Colors.amberAccent,
    Colors.greenAccent,
    Colors.lightBlueAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.blueGrey,
    Colors.red,
    Colors.orangeAccent,
    Colors.amber,
    Colors.green,
    Colors.lightBlue,
    Colors.blue,
    Colors.purple,
    Colors.blueGrey,
    Colors.deepPurple,
    Colors.brown
  ];
  static final CollectionReference categoriesCollectionRef =
      FirebaseFirestore.instance.collection('categories');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  static Future<List<Category>> _fetchDataFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<Category> loadedCategories =
        snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
    return loadedCategories;
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

  Future<double> get totalCategoriesDuration async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<Category> loadedCategories = snapshot.docs
        .map((doc) => Category.fromMap(doc.data()))
        .toList()
        .where((cat) => cat.uid == uid)
        .toList();
    double totalDuration = 0;
    loadedCategories.forEach((element) {
      totalDuration = totalDuration + element.amount;
    });
    return totalDuration;
  }

  Future<void> _addNewCategory(
      String ctName, double ctAmount, String nameCurrentCt, String id) async {
    final String categoryIdAsCurrentDateTime = DateTime.now().toString();
    final newCt = Category(
      name: ctName,
      amount: ctAmount,
      uid: uid,
      id: categoryIdAsCurrentDateTime,
    );
    print("totalDuration ${await totalCategoriesDuration}");
    if (await (totalCategoriesDuration) + newCt.amount > weekTotalDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Weekly time should not exceed 112 hours"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      setState(() {
        categories.add(newCt);
      });
      // Write the transaction to Firebase
      await categoriesCollectionRef.add({
        'uid': uid,
        'id': categoryIdAsCurrentDateTime,
        'name': newCt.name,
        'amount': newCt.amount,
      });
    }
  }

  void _deleteCategory(String name, String uid) async {
    // Remove the transaction from the local list

    categories.removeWhere((tx) => tx.name == name);

    // Get a reference to the Firestore document using the local transaction ID
    final categoryDoc = await categoriesCollectionRef
        .where('uid', isEqualTo: uid)
        .where('name', isEqualTo: name)
        .get()
        .then((value) => value.docs.first.reference);

    // Delete the document from Firestore
    try {
      await categoryDoc.delete();
    } catch (e) {
      // Handle errors
      print('Failed to delete category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        foregroundColor: Theme.of(context).primaryColor,
        title: Text('Add Categories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
          final List<DocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.data!.docs
                  .cast<DocumentSnapshot<Map<String, dynamic>>>();
          documents.forEach(
            (doc) {
              final category = Category.fromSnapshot(doc);
              loadedCategories.add(category);
            },
          );
          Map<String, double> loadedCategoriesDurationMap = {};
          loadedCategories.where((element) => element.uid == uid).forEach(
              (cat) => loadedCategoriesDurationMap[cat.name] = cat.amount);
          // } catch (e) {
          //   // Handle errors
          //   print('No docs in collection categories: $e');
          // }
          double totalDuration = 0;
          loadedCategories
              .where((element) => element.uid == uid)
              .forEach((cat) => totalDuration += cat.amount);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                !loadedCategories.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                        child: PieChart(
                          dataMap: loadedCategoriesDurationMap,
                          animationDuration: Duration(seconds: 0),
                          chartLegendSpacing: 32,
                          chartRadius: MediaQuery.of(context).size.width / 3.2,
                          initialAngleInDegree: 0,
                          chartType: ChartType.ring,
                          colorList: colorsList,
                          ringStrokeWidth: 16,
                          centerText:
                              "Week \n ${totalDuration.toStringAsFixed(0)}h",
                          legendOptions: LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValueBackground: true,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: true,
                            decimalPlaces: 1,
                          ),
                          //totalValue: weekTotalDuration,
                          baseChartColor: Colors.grey,
                          // gradientList: ---To add gradient colors---
                          // emptyColorGradient: ---Empty Color gradient---
                        ),
                      )
                    : SizedBox(height: 1),
                CategoriesList(
                    loadedCategories
                        .where(
                          (tx) => tx.uid == uid,
                        )
                        .toList(),
                    _deleteCategory,
                    context),
                // TextButton(
                //   onPressed: () {
                //     // Add the new category and close the dialog
                //     categories.length != 0
                //         ? Navigator.of(context).pushNamed('/expenses')
                //         : null;
                //   },
                //   child: Text('Done'),
                // ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).canvasColor,
        foregroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () async => await numberOfCategories >= 14
            ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("14 categories are maximal"),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              )
            : _startAddNewCategory(context),
      ),
    );
  }

  void _startAddNewCategory(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewCategory(_addNewCategory, "", "", "", "", ctx),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }
}
