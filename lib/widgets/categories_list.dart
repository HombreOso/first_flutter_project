import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/new_category.dart';

import '../models/category.dart';

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Total Weekly Hours'),
        content: const Text(
          "Total weekly hours should not exceed 112h",
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final Function deleteCat;
  final BuildContext parentContext;

  final double weekTotalDuration = 112;

  CategoriesList(this.categories, this.deleteCat, this.parentContext);

  final String uid = FirebaseAuth.instance.currentUser!.uid.toString();
  static final CollectionReference categoriesCollectionRef =
      FirebaseFirestore.instance.collection('categories');

  void _startUpdateNewCategory(BuildContext ctx, NewCategory newCt) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: newCt,
          behavior: HitTestBehavior.opaque,
        );
      },
    );
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

  Future<void> _updateNewCategory(
    String ctName,
    double ctAmount,
    String nameCurrentCt,
    String id,
    BuildContext ctx,
  ) async {
    print("Current name ct: $nameCurrentCt");
    final newCat = Category(
      name: ctName,
      amount: ctAmount,
      uid: uid,
      id: id,
    );

    // Write the transaction to Firebase
    final uptodatedDoc = await categoriesCollectionRef
        .where(
          'uid',
          isEqualTo: uid,
        )
        .where(
          'id',
          isEqualTo: id,
        )
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) => snapshot.docs[0].reference);
    if (await (totalCategoriesDuration) + newCat.amount <= weekTotalDuration) {
      uptodatedDoc.update({
        'uid': uid,
        'name': newCat.name,
        'amount': newCat.amount,
      });
    } else {
      _dialogBuilder(ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: categories.isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No categories added yet!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                  key: Key(categories[index].name),
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
                    print("Dismissed name: ${categories[index].name}");
                    print("Dismissed uid: ${categories[index].uid}");
                    deleteCat(
                      categories[index].name,
                      categories[index].uid,
                    );
                  },
                  child: Card(
                    color: Colors.grey[300],
                    elevation: 5,
                    margin: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 33,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightGreen,
                                Colors.lightGreenAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: FittedBox(
                            child: Text(
                                '${categories[index].amount.toStringAsFixed(0)} h'),
                          ),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        categories[index].name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.green,
                        onPressed: () {
                          // Handle edit transaction here
                          print('Edit category ${categories[index].name}');
                          _startUpdateNewCategory(
                            ctx,
                            NewCategory(
                                _updateNewCategory,
                                categories[index].name,
                                categories[index].amount.toString(),
                                categories[index].name,
                                categories[index].id,
                                parentContext),
                          );
                          //return NewTransaction(addTx, initialAmountText, initialTitleText)
                        },
                      ),
                    ),
                  ),
                );
              },
              itemCount: categories.length,
            ),
    );
  }
}
