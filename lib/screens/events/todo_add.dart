// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:momento/screens/events/todo_bloc/todo_bloc.dart';
// import 'package:momento/screens/events/todo_bloc/todo_event.dart';
// import 'package:momento/screens/events/todo_bloc/todo_state.dart';
// import 'package:momento/screens/events/todo_bloc/todo_api_service.dart';
// import 'package:momento/screens/events/todo_bloc/todo_model.dart';

// void showTodoModal(BuildContext context, int eventId, String currentUserId,
//     VoidCallback onTodoAdded) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext context) {
//       return BlocProvider(
//         create: (context) => TodoBloc(TodoApiService()),
//         child: Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.8,
//             child: TodoModal(
//                 eventId: eventId,
//                 currentUserId: currentUserId,
//                 onTodoAdded: onTodoAdded),
//           ),
//         ),
//       );
//     },
//   );
// }

// class TodoModal extends StatefulWidget {
//   final int eventId;
//   final String currentUserId;
//   final VoidCallback onTodoAdded;

//   const TodoModal({
//     super.key,
//     required this.eventId,
//     required this.currentUserId,
//     required this.onTodoAdded,
//   });

//   @override
//   State<TodoModal> createState() => _TodoModalState();
// }

// class _TodoModalState extends State<TodoModal> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _nameController = TextEditingController();
//   DateTime? _selectedDate;

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _handleSubmit(BuildContext context) {
//     if (_formKey.currentState!.validate() && _selectedDate != null) {
//       final bloc = context.read<TodoBloc>();
//       final todo = Todo(
//         id: 0, // This will be set by the backend
//         eventId: widget.eventId,
//         title: _titleController.text,
//         description: _descriptionController.text,
//         name: _nameController.text,
//         dueDate: _selectedDate!,
//         isDone: false,
//         createdBy: widget.currentUserId,
//       );
//       bloc.add(AddTodo(todo));
//     } else if (_selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a due date'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<TodoBloc, TodoState>(
//       listener: (context, state) {
//         if (state.error != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.error!),
//               backgroundColor: Colors.red,
//             ),
//           );
//         } else if (state.remainingTasks.isNotEmpty ||
//             state.finishedTasks.isNotEmpty) {
//           widget.onTodoAdded(); // Notify to refresh the list
//           Navigator.of(context).pop();
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Todo added successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Text(
//                 'Add Todo',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF003675),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const ClampingScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.all(16.w),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         _buildLabel('Task Title'),
//                         TextFormField(
//                           controller: _titleController,
//                           decoration: _inputDecoration('Enter task title'),
//                           validator: (value) {
//                             return value == null || value.isEmpty
//                                 ? 'Please enter a task title'
//                                 : null;
//                           },
//                         ),
//                         SizedBox(height: 16.h),
//                         _buildLabel('Description'),
//                         TextFormField(
//                           controller: _descriptionController,
//                           decoration:
//                               _inputDecoration('Enter task description'),
//                           validator: (value) {
//                             return value == null || value.isEmpty
//                                 ? 'Please enter a description'
//                                 : null;
//                           },
//                         ),
//                         SizedBox(height: 16.h),
//                         _buildLabel('Assigned To'),
//                         TextFormField(
//                           controller: _nameController,
//                           decoration:
//                               _inputDecoration('Enter assigned person\'s name'),
//                           validator: (value) {
//                             return value == null || value.isEmpty
//                                 ? 'Please enter a name'
//                                 : null;
//                           },
//                         ),
//                         SizedBox(height: 16.h),
//                         _buildLabel('Due Date'),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 _selectedDate == null
//                                     ? 'No date selected'
//                                     : 'Due Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.calendar_today),
//                               onPressed: () async {
//                                 final pickedDate = await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2100),
//                                 );
//                                 if (pickedDate != null) {
//                                   setState(() {
//                                     _selectedDate = pickedDate;
//                                   });
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 24.h),
//                         FilledButton(
//                           onPressed: state.isLoading
//                               ? null
//                               : () => _handleSubmit(context),
//                           style: FilledButton.styleFrom(
//                             backgroundColor: state.isLoading
//                                 ? const Color(0xFF003675).withOpacity(0.7)
//                                 : const Color(0xFF003675),
//                             foregroundColor: Colors.white,
//                             disabledBackgroundColor:
//                                 const Color(0xFF003675).withOpacity(0.7),
//                             minimumSize: const Size(double.infinity, 56),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           child: state.isLoading
//                               ? SizedBox(
//                                   height: 20.h,
//                                   width: 20.h,
//                                   child: const CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : Text(
//                                   'Add Todo',
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 5.h),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey.shade700,
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hintText) {
//     return InputDecoration(
//       border: const OutlineInputBorder(
//         borderRadius: BorderRadius.all(Radius.circular(15)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: const BorderRadius.all(Radius.circular(15)),
//         borderSide: BorderSide(
//           color: const Color(0xFF003675),
//           width: 2.w,
//         ),
//       ),
//       hintText: hintText,
//       hintStyle: TextStyle(
//         fontSize: 16.sp,
//         fontWeight: FontWeight.normal,
//       ),
//     );
//   }
// }
