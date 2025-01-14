import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Todo List'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildTaskSection('Remaining Tasks', remainingTasks, false),
          _buildTaskSection('Finished Tasks', finishedTasks, true),
        ],
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

class AddTaskModal extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController nameController;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final VoidCallback onAddTask;

  const AddTaskModal({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.nameController,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onAddTask,
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
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Add New Task',
              style: TextStyle(
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
                  // Task Title Field
                  Container(
                    margin:const EdgeInsets.only(bottom: 5),
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
                      border:  OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                             BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color:  Color(0xFF003675), width: 2),
                      ),
                      hintText: 'Enter task title',
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Description Field
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
                      border:  OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                             BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color:  Color(0xFF003675), width: 2),
                      ),
                      hintText: 'Enter task description',
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Assigned To Field
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
                      border:  OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                             BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color:  Color(0xFF003675), width: 2),
                      ),
                      hintText: 'Enter assigned person\'s name',
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Due Date Picker
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
                            onDateSelected(pickedDate);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
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
                    child: const Text('Add Task'),
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
