import 'package:flutter/material.dart';
import 'package:list/models/task_model.dart';
import 'package:list/firebase_service.dart';
import 'package:list/notification_service.dart'; // Import the notification service
import 'package:intl/intl.dart'; // Import intl for date formatting

class AddEditTaskScreen extends StatefulWidget {
  final Task? task; // Null when creating a new task, non-null when editing

  AddEditTaskScreen({this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = '';
  DateTime _dueDate = DateTime.now();
  List<DateTime> _reminderTimes = [];
  bool _hasReminder = false;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    NotificationService.initialize(); // Initialize notification service
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _category = widget.task!.category;
      _dueDate = widget.task!.dueDate;
      _reminderTimes = widget.task!.reminderTimes ?? [];
      _hasReminder = _reminderTimes.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Title Field
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  helperText: 'Enter the name of the task',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 16.0),
              
              // Description Field
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  helperText: 'Provide a brief description of the task',
                ),
                maxLines: 4,
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Category Field
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  helperText: 'Specify the category or type of task (e.g., Work, Personal)',
                ),
                onSaved: (value) {
                  _category = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Due Date Picker
              ListTile(
                title: Text('Due Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_dueDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDueDate,
                tileColor: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 16.0),

              // Set Reminder Switch
              SwitchListTile(
                title: Text('Set Reminder'),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() {
                    _hasReminder = value;
                  });
                },
              ),

              // Reminder Times
              if (_hasReminder)
                ..._reminderTimes.map((reminderTime) => Card(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      'Reminder: ${DateFormat('EEEE, MMMM d, yyyy').format(reminderTime)} at ${DateFormat('h:mm a').format(reminderTime)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _reminderTimes.remove(reminderTime);
                          _hasReminder = _reminderTimes.isNotEmpty;
                        });
                      },
                    ),
                  ),
                )),
              SizedBox(height: 16.0),

              // Add Reminder Button
              ElevatedButton(
                onPressed: _addReminder,
                child: Text('Add Reminder Time'),
              ),
              SizedBox(height: 20),
              
              // Save Task Button
              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Save Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Custom color
                ),
              ),
              SizedBox(height: 16.0),

              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Discard changes and go back
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _addReminder() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      DateTime reminderDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {
        _reminderTimes.add(reminderDateTime);
        _hasReminder = _reminderTimes.isNotEmpty;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newTask = Task(
        id: widget.task?.id ?? DateTime.now().toString(),
        title: _title,
        description: _description,
        category: _category,
        dueDate: _dueDate,
        reminderTimes: _reminderTimes,
        hasReminder: _hasReminder,
      );

      try {
        if (widget.task == null) {
          await _firebaseService.addTask(newTask);
        } else {
          await _firebaseService.updateTask(newTask);
        }

        // Schedule notifications for reminders
        if (_hasReminder) {
          for (var reminderTime in _reminderTimes) {
            await NotificationService.scheduleNotification(
              reminderTime,
              'Reminder: ${newTask.title}',
              newTask.description,
              channelId: 'default_channel_id', // Specify the channel ID
            );
          }
        }

        Navigator.of(context).pop(newTask);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
      }
    }
  }
}
