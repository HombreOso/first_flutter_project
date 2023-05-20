import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  var name;
  var amount;
  var uid;
  var id;

  Category(
      {required this.name,
      required this.amount,
      required this.uid,
      required this.id});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      amount: map['amount'],
      uid: map['uid'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'uid': uid,
      'id': id,
    };
  }

  static Category fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Category(
      name: data!['name'] as String,
      amount: data['amount'] as double?,
      uid: data['uid'] as String,
      id: data['id'] as String,
    );
  }
}
