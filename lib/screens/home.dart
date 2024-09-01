import 'package:flutter/material.dart';
import 'package:list/models/task_model.dart';
import 'package:list/screens/add_task.dart';
import 'package:list/screens/settings.dart'; // Import the SettingsScreen
import 'package:list/firebase_service.dart'; // Import the FirebaseService
import 'package:intl/intl.dart'; // Import intl for date formatting

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Task> tasks = []; // List to store tasks
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await _firebaseService.fetchTasks();
      setState(() {
        tasks = fetchedTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
    }
  }

  Future<void> _deleteTask(String taskId, int index) async {
    try {
      await _firebaseService.deleteTask(taskId);
      setState(() {
        tasks.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  Future<void> _confirmDeleteTask(String taskId, int index) async {
    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _deleteTask(taskId, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        backgroundColor: Colors.blueAccent, // Custom color
        elevation: 0, // Remove default shadow
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : tasks.isEmpty
                ? Center(child: Text('No tasks available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // Format the due date
                      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(task.dueDate);
                      final formattedTime = DateFormat('h:mm a').format(task.dueDate);

                      return Card(
                        elevation: 4, // Add shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(task.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${task.category} - Due: $formattedDate at $formattedTime',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  // Navigate to edit task screen
                                  final updatedTask = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddEditTaskScreen(task: task),
                                    ),
                                  );

                                  if (updatedTask != null) {
                                    setState(() {
                                      tasks[index] = updatedTask;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Confirm deletion
                                  _confirmDeleteTask(task.id, index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add task screen
          final newTask = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditTaskScreen(),
            ),
          );

          if (newTask != null) {
            setState(() {
              tasks.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent, // Custom color
      ),
    );
  }
}
