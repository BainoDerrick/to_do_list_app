import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:list/models/task_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's UID
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    return user.uid;
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .doc(task.id) // Use the task's ID to ensure the document ID is consistent
          .set(task.toMap()); // Use set instead of add for specifying the document ID
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .doc(task.id) // Ensure this document ID is correct
          .update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('tasks')
          .get();

      // Convert the query snapshot to a list of Task objects
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final task = Task.fromMap(data);
        return task.copyWith(id: doc.id); // Ensure the ID is set correctly
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }
}
