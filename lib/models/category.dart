import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  var name;
  var amount;
  var uid;

  Category({required this.name, required this.amount, required this.uid});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      amount: map['amount'],
      uid: map['uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'uid': uid,
    };
  }

  static Category fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Category(
      name: data!['name'] as String,
      amount: data['amount'] as double?,
      uid: data['uid'] as String,
    );
  }
}
