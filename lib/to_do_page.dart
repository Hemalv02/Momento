import 'package:flutter/material.dart';

class ToDoPageBuilder extends StatelessWidget {
  const ToDoPageBuilder({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const ToDoPage(),
    );
  }
}

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});
  @override
  ToDoPageState createState() => ToDoPageState();
}

class ToDoPageState extends State<ToDoPage> {
  final List<Map<String, dynamic>> remainingTasks = [];
  final List<Map<String, dynamic>> finishedTasks = [];

  void _addTask(
      String title, String description, String name, DateTime dueDate) {
    setState(() {
      remainingTasks.add({
        'title': title,
        'description': description,
        'name': name,
        'dueDate': dueDate,
      });
    });
  }

  void _moveToFinished(int index) {
    setState(() {
      finishedTasks.add(remainingTasks[index]);
      remainingTasks.removeAt(index);
    });
  }

  void _moveToRemaining(int index) {
    setState(() {
      remainingTasks.add(finishedTasks[index]);
      finishedTasks.removeAt(index);
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Assigned To'),
                    ),
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
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDate != null) {
                      _addTask(
                        titleController.text,
                        descriptionController.text,
                        nameController.text,
                        selectedDate!,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do'),
      ),
      body: ListView(
        children: [
          _buildTaskSection('Remaining Tasks', remainingTasks, false),
          _buildTaskSection('Finished Tasks', finishedTasks, true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.purple,
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
              backgroundColor: Colors.purple.shade100,
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
          int index = tasks.indexOf(task);
          return ListTile(
            title: Text(task['title'] ?? ''),
            subtitle: Text(
                'Assigned to: ${task['name']}\nDue: ${task['dueDate'].toLocal().toString().split(' ')[0]}'),
            isThreeLine: true,
            trailing: Checkbox(
              value: isFinished,
              onChanged: (_) {
                if (isFinished) {
                  _moveToRemaining(index);
                } else {
                  _moveToFinished(index);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
