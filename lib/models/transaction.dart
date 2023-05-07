import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction_ {
  var uid;

  var category;

  var id;

  DateTime date;

  var amount;

  var title;

  Transaction_({
    required this.title,
    required this.amount,
    required this.date,
    required this.id,
    required this.category,
    required this.uid,
  });

  factory Transaction_.fromMap(Map<String, dynamic> map) {
    return Transaction_(
      title: map['title'],
      amount: map['amount'],
      date: map['date'].toDate(),
      id: map['id'],
      category: map['category'],
      uid: map['uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'id': id,
      'category': category,
      'uid': uid,
    };
  }

  static Transaction_ fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Transaction_(
      id: data!['id'] as String,
      title: data['title'] as String?,
      amount: data['amount'] as double?,
      category: data['category'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      uid: data['uid'] as String,
    );
  }
}
