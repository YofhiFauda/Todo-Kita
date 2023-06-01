// lib/widget/task_card.dart

import 'package:flutter/material.dart';
import 'package:todo_kita/model/constants.dart';
import 'package:todo_kita/model/task_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final void Function(Task) onUpdate;
  final void Function(Task) onDelete;
  final Color taskColor;

  const TaskCard({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
    required this.taskColor,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String selectedValue = '';
  final List<String> taskTags = ['Work', 'School', 'Other'];
  late TextEditingController editTitleController;
  late TextEditingController editDescriptionController;

  @override
  void initState() {
    super.initState();
    editTitleController = TextEditingController(text: widget.task.title);
    editDescriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    editTitleController.dispose();
    editDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color taskColor = AppColors.blueShadeColor;
    if (taskTags.contains('Work')) {
      taskColor = AppColors.salmonColor;
    } else if (taskTags.contains('School')) {
      taskColor = AppColors.greenShadeColor;
    } else if (taskTags.contains('Other')) {
      taskColor = AppColors.blueShadeColor;
    }
    return Container(
      alignment: Alignment.center,
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 5.0,
            offset: Offset(0, 5), // shadow direction: bottom right
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          widget.task.title,
        ),
        subtitle: Text(
          widget.task.description,
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) {
            return [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text(
                  'Edit',
                  style: TextStyle(fontSize: 13.0),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(fontSize: 13.0),
                ),
              ),
            ];
          },
          onSelected: (String value) {
            if (value == 'edit') {
              _editTask();
            } else if (value == 'delete') {
              _deleteTask();
            }
          },
        ),
        // : Checkbox(
        //     value: widget.task.isCompleted,
        //     onChanged: (value) {
        //       final updateTask =
        //           widget.task.copyWith(isCompleted: value ?? false);
        //       widget.onUpdate(updateTask);
        //     }),

        leading: Container(
          width: 20,
          height: 20,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundColor: taskColor,
          ),
        ),
      ),
    );
  }

  void _showEditMenu(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SizedBox(
          height: height * 0.45,
          width: width,
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: editTitleController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
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
                  controller: editDescriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
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
                        isExpanded: true,
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
                        onChanged: (String? value) => setState(() {
                          if (value != null) selectedValue = value;
                        }),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveTask();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTask() {
    _showEditMenu(context);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final deleteTask = widget.task;
              widget.onDelete(deleteTask);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    final newTitle = editTitleController.text.trim();
    final newDescription = editDescriptionController.text.trim();

    if (newTitle.isNotEmpty) {
      final updatedTask = widget.task.copyWith(
        title: newTitle,
        description: newDescription,
      );

      widget.onUpdate(updatedTask);
      Navigator.pop(context);
    }
  }
}
