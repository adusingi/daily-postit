import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();

  FirestoreService._init();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User not signed in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasksRef {
    return _db.collection('users').doc(_uid).collection('tasks');
  }

  Future<List<Task>> getTasksForDate(String date) async {
    final snapshot = await _tasksRef
        .where('date', isEqualTo: date)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map(Task.fromFirestore).toList();
  }

  Future<List<String>> getTaskDatesBefore(String date) async {
    final snapshot = await _tasksRef
        .where('date', isLessThan: date)
        .orderBy('date', descending: true)
        .get();

    final dates = <String>{};
    for (final doc in snapshot.docs) {
      final value = doc.data()['date'];
      if (value is String) {
        dates.add(value);
      }
    }

    return dates.toList();
  }

  Future<void> createTask(Task task) async {
    final doc = _tasksRef.doc();
    await doc.set(task.toFirestoreMap(id: doc.id));
  }

  Future<bool> hasAnyTasks() async {
    final snapshot = await _tasksRef.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> importTasks(List<Task> tasks) async {
    if (tasks.isEmpty) return;

    final batch = _db.batch();
    for (final task in tasks) {
      final doc = _tasksRef.doc();
      batch.set(doc, task.toFirestoreMap(id: doc.id));
    }

    await batch.commit();
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) return;
    await _tasksRef.doc(task.id).update(task.toFirestoreMap());
  }

  Future<void> deleteTask(String id) async {
    await _tasksRef.doc(id).delete();
  }

  Future<void> rolloverTasks(String fromDate, String toDate) async {
    final snapshot = await _tasksRef.where('date', isEqualTo: fromDate).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final isDone = data['is_done'] == true;
      if (isDone) continue;

      batch.update(doc.reference, {
        'date': toDate,
        'updated_at': now,
      });
    }

    await batch.commit();
  }
}
