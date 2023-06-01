import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:todo_kita/model/constants.dart';
import 'package:todo_kita/model/task_model.dart';
import 'package:todo_kita/database/database_helper.dart';
import 'package:todo_kita/ui/categories.dart';
import 'package:todo_kita/widget/task_card.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({
    Key? key,
  }) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late DatabaseHelper _databaseHelper;
  List<Task> _tasks = [];
  bool showDeleteIcon = false;
  String selectedValue = '';
  final List<String> taskTags = ['Work', 'School', 'Other'];
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper.instance;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _databaseHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask(Task task) async {
    await _databaseHelper.insertTask(task);
    await _loadTasks();
  }

  Future<void> _updateTask(Task task) async {
    await _databaseHelper.updateTask(task);
    await _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await _databaseHelper.deleteTask(task.id);
    await _loadTasks();
    _tasks.remove(task);
  }

  @override
  Widget build(BuildContext context) {
    Color taskColor = AppColors.blueShadeColor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Todo List'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          addSemanticIndexes: true,
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            // Color taskColor = AppColors.blueShadeColor;
            // if (task == 'Work') {
            //   taskColor = AppColors.salmonColor;
            // } else if (task == 'School') {
            //   taskColor = AppColors.greenShadeColor;
            // }
            return TaskCard(
              task: task,
              onUpdate: (updatedTask) {
                _updateTask(updatedTask);
              },
              //tidak berfungsi
              onDelete: (deleteTask) {
                _deleteTask(deleteTask);
              },

              // taskColor: taskColor,
              taskColor: () {
                Color taskColor = Colors.blue; // Atur warna default
                if (taskTags.contains('Work')) {
                  taskColor = AppColors.salmonColor;
                } else if (taskTags.contains('School')) {
                  taskColor = AppColors.greenShadeColor;
                } else if (taskTags.contains('Other')) {
                  taskColor = AppColors.blueShadeColor;
                }
                return taskColor;
              }(),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.brown,
            unselectedItemColor: Colors.black,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.article_rounded),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_offer_rounded),
                label: '',
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text(
          'Add Task',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, color: Colors.brown),
        ),
        content: SizedBox(
          height: height * 0.35,
          width: width,
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    hintText: 'Task',
                    hintStyle: const TextStyle(fontSize: 14),
                    icon:
                        const Icon(Icons.article_rounded, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    hintText: 'Description',
                    hintStyle: const TextStyle(fontSize: 14),
                    icon: const Icon(Icons.topic_rounded, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: <Widget>[
                    const Icon(Icons.local_offer_rounded, color: Colors.brown),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: DropdownButtonFormField2(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        hint: const Text('Colors'),
                        buttonStyleData: const ButtonStyleData(
                          height: 60,
                          padding: EdgeInsets.only(left: 20, right: 10),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        items: taskTags
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Color.';
                          }
                          return null;
                        },
                        onChanged: (String? value) => setState(
                          () {
                            if (value != null) selectedValue = value;
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        // content: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     TextField(
        //       controller: titleController,
        //       decoration: const InputDecoration(
        //         labelText: 'Title',
        //       ),
        //     ),
        //     TextField(
        //       controller: descriptionController,
        //       decoration: const InputDecoration(
        //         labelText: 'Description',
        //       ),
        //     ),
        //     SizedBox(height: 10),
        //     Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         mainAxisSize: MainAxisSize.max,
        //         children: [
        //           buildPriorityDropdown(),
        //           SizedBox(width: 10),
        //           buildColorDropdown(),
        //         ]),
        //   ],
        // ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  description: description,
                  time: TimeOfDay.now(),
                  color: Colors.blue,
                  isCompleted: false,
                );

                _addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:todo_kita/database/database_helper.dart';

// class TodoListScreen extends StatefulWidget {
//   const TodoListScreen({Key? key}) : super(key: key);

//   @override
//   _TodoListScreenState createState() => _TodoListScreenState();
// }

// class _TodoListScreenState extends State<TodoListScreen> {
//   late DatabaseHelper _databaseHelper;
//   List<Map<String, dynamic>> _tasks = [];

//   @override
//   void initState() {
//     super.initState();
//     _databaseHelper = DatabaseHelper.instance;
//     _loadTasks();
//   }

//   Future<void> _loadTasks() async {
//     final tasks = await _databaseHelper.getTasks();
//     setState(() {
//       _tasks = tasks;
//     });
//   }

//   Future<void> _addTask(String title) async {
//     final newTask = {
//       'title': title,
//       'isCompleted': 0,
//     };

//     await _databaseHelper.insertTask(newTask);
//     await _loadTasks();
//   }

//   Future<void> _updateTask(int taskId, bool isCompleted) async {
//     final taskToUpdate = {
//       'id': taskId,
//       'isCompleted': isCompleted ? 1 : 0,
//     };

//     await _databaseHelper.updateTask(taskToUpdate);
//     await _loadTasks();
//   }

//   Future<void> _deleteTask(int taskId) async {
//     await _databaseHelper.deleteTask(taskId);
//     await _loadTasks();
//   }

//   Future<void> _editTask(int taskId, String newTitle) async {
//     final taskToUpdate = {
//       'id': taskId,
//       'title': newTitle,
//     };

//     await _databaseHelper.updateTask(taskToUpdate);
//     await _loadTasks();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Todo List'),
//       ),
//       body: ListView.builder(
//         itemCount: _tasks.length,
//         itemBuilder: (context, index) {
//           final task = _tasks[index];
//           return Dismissible(
//             key: Key(task['id'].toString()),
//             direction: DismissDirection.endToStart,
//             background: Container(
//               alignment: Alignment.centerRight,
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               color: Colors.red,
//               child: const Icon(
//                 Icons.delete,
//                 color: Colors.white,
//               ),
//             ),
//             onDismissed: (direction) {
//               _deleteTask(task['id']);
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Card(
//                 elevation: 0.0,
//                 child: ListTile(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     side: BorderSide(color: Colors.grey),
//                   ),
//                   title: Text(task['title']),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () {
//                           _showEditMenu(task);
//                         },
//                       ),
//                       Checkbox(
//                         value: task['isCompleted'] == 1,
//                         onChanged: (value) {
//                           _updateTask(task['id'], value ?? false);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (context) => _buildAddTaskDialog(context),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildAddTaskDialog(BuildContext context) {
//     TextEditingController titleController = TextEditingController();

//     return AlertDialog(
//       title: const Text('Add Task'),
//       content: TextField(
//         controller: titleController,
//         decoration: const InputDecoration(
//           labelText: 'Task Title',
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             final title = titleController.text.trim();
//             if (title.isNotEmpty) {
//               _addTask(title);
//               Navigator.pop(context);
//             }
//           },
//           child: const Text('Add'),
//         ),
//       ],
//     );
//   }

//   void _showEditMenu(Map<String, dynamic> task) {
//     TextEditingController editTitleController =
//         TextEditingController(text: task['title']);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Task'),
//         content: TextField(
//           controller: editTitleController,
//           decoration: const InputDecoration(
//             labelText: 'Task Title',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final newTitle = editTitleController.text.trim();
//               if (newTitle.isNotEmpty) {
//                 _editTask(task['id'], newTitle);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }
