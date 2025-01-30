import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ToDoPage extends StatefulWidget {
  final int eventId;
  const ToDoPage({super.key, required this.eventId});

  @override
  ToDoPageState createState() => ToDoPageState();
}

class ToDoPageState extends State<ToDoPage> {
  final _supabase = Supabase.instance.client;
  late final StreamController<List<Map<String, dynamic>>> _todoStreamController;
  late final Stream<List<Map<String, dynamic>>> _todosStream;
  final List<Map<String, dynamic>> remainingTasks = [];
  final List<Map<String, dynamic>> finishedTasks = [];

  @override
  void initState() {
    super.initState();
    _todoStreamController = StreamController<List<Map<String, dynamic>>>();
    _todosStream = _todoStreamController.stream;
    _initializeTodosStream();
  }

  @override
  void dispose() {
    _todoStreamController.close();
    super.dispose();
  }

  Future<void> _fetchAndUpdateTodos() async {
    try {
      final todos = await _supabase
          .from('todo')
          .select()
          .eq('event_id', widget.eventId)
          .order('created_at');

      if (!_todoStreamController.isClosed) {
        final List<Map<String, dynamic>> newRemainingTasks = [];
        final List<Map<String, dynamic>> newFinishedTasks = [];

        for (final todo in todos) {
          if (todo['is_completed'] == true) {
            newFinishedTasks.add(Map<String, dynamic>.from(todo));
          } else {
            newRemainingTasks.add(Map<String, dynamic>.from(todo));
          }
        }

        setState(() {
          remainingTasks
            ..clear()
            ..addAll(newRemainingTasks);
          finishedTasks
            ..clear()
            ..addAll(newFinishedTasks);
        });

        _todoStreamController.add(todos);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching tasks: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeTodosStream() {
    _supabase
        .from('todo')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .order('created_at')
        .listen(
          (data) => _fetchAndUpdateTodos(),
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Stream error: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );

    // Initial fetch
    _fetchAndUpdateTodos();
  }

  Future<void> _addTask(
      String title, String description, String name, DateTime dueDate) async {
    try {
      await _supabase.from('todo').insert({
        'event_id': widget.eventId,
        'title': title,
        'description': description,
        'assigned_to': name,
        'due_date': dueDate.toIso8601String(),
        'is_completed': false,
        'created_by': _supabase.auth.currentUser?.id,
      });
      await _fetchAndUpdateTodos();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error adding task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(int taskId, bool isCompleted) async {
    try {
      await _supabase
          .from('todo')
          .update({'is_completed': isCompleted}).eq('id', taskId);
      await _fetchAndUpdateTodos();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndDeleteTask(int taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _supabase.from('todo').delete().eq('id', taskId);
        await _fetchAndUpdateTodos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error deleting task'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editTask(int taskId, String title, String description,
      String name, DateTime dueDate) async {
    try {
      await _supabase.from('todo').update({
        'title': title,
        'description': description,
        'assigned_to': name,
        'due_date': dueDate.toIso8601String(),
      }).eq('id', taskId);
      await _fetchAndUpdateTodos();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error editing task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showAddTaskModal() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final nameController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: AddTaskModal(
              titleController: titleController,
              descriptionController: descriptionController,
              nameController: nameController,
              selectedDate: selectedDate,
              onDateSelected: (pickedDate) {
                selectedDate = pickedDate;
              },
              onAddTask: () {
                if (selectedDate != null) {
                  _addTask(
                    titleController.text,
                    descriptionController.text,
                    nameController.text,
                    selectedDate!,
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void showEditTaskModal(Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']);
    final descriptionController =
        TextEditingController(text: task['description']);
    final nameController = TextEditingController(text: task['assigned_to']);
    DateTime selectedDate = DateTime.parse(task['due_date']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: AddTaskModal(
              titleController: titleController,
              descriptionController: descriptionController,
              nameController: nameController,
              selectedDate: selectedDate,
              onDateSelected: (pickedDate) {
                if (pickedDate != null) {
                  selectedDate = pickedDate;
                }
              },
              onAddTask: () {
                _editTask(
                  task['id'],
                  titleController.text,
                  descriptionController.text,
                  nameController.text,
                  selectedDate,
                );
                Navigator.pop(context);
              },
              isEdit: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Todo List'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _todosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              _buildTaskSection('Remaining Tasks', remainingTasks, false),
              _buildTaskSection('Finished Tasks', finishedTasks, true),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskModal,
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskSection(
      String title, List<Map<String, dynamic>> tasks, bool isFinished) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF003675).withAlpha(51),
              foregroundColor: Colors.black,
              child: Text('${tasks.length}'),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        children: tasks.map((task) {
          final isOverdue = !isFinished &&
              DateTime.parse(task['due_date']).isBefore(DateTime.now());

          final textStyle = TextStyle(
            color: isOverdue ? Colors.red : Colors.black,
          );

          return ListTile(
            title: Text(
              task['title'] ?? '',
              style: textStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned to: ${task['assigned_to']}',
                  style: textStyle,
                ),
                Text(
                  'Due: ${DateTime.parse(task['due_date']).toLocal().toString().split(' ')[0]}',
                  style: textStyle,
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => showEditTaskModal(task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmAndDeleteTask(task['id']),
                ),
                Checkbox(
                  value: isFinished,
                  onChanged: (_) {
                    _updateTaskStatus(task['id'], !isFinished);
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AddTaskModal extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController nameController;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final VoidCallback onAddTask;
  final bool isEdit;
  const AddTaskModal({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.nameController,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onAddTask,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              isEdit ? 'Edit Task' : 'Add New Task',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003675),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Task Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide:
                            BorderSide(color: Color(0xFF003675), width: 2),
                      ),
                      hintText: 'Enter task title',
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide:
                            BorderSide(color: Color(0xFF003675), width: 2),
                      ),
                      hintText: 'Enter task description',
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Assigned To',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide:
                            BorderSide(color: Color(0xFF003675), width: 2),
                      ),
                      hintText: 'Enter assigned person\'s name',
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'No date selected'
                              : 'Due Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            onDateSelected(pickedDate);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onAddTask,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF003675),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(isEdit ? 'Edit Task' : 'Add Task'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
