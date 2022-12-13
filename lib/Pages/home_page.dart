import 'package:flutter/material.dart';
import 'package:habit_tracker/Components/habit_tile.dart';
import 'package:habit_tracker/Components/my_fab.dart';
import 'package:habit_tracker/Components/new_habit_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List todayHabitList = [
    ["Jogging", false],
    ["Breakfast", false],
    ["Meeting", false],
  ];

  void checkboxTapped(bool? value, int index) {
    setState(() {
      todayHabitList[index][1] = value;
    });
  }

  final _newHabitNameController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) {
          return EnterNewHabitBox(
            controller: _newHabitNameController,
            onSave: saveNewHabit,
            onCancel: cancelNewHabit,
          );
        });
  }

  void saveNewHabit() {
    setState(() {
      todayHabitList.add([_newHabitNameController.text, false]);
    });

    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  void cancelNewHabit() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(
        onPressed: createNewHabit,
      ),
      body: ListView.builder(
        itemCount: todayHabitList.length,
        itemBuilder: (context, index) {
          return HabitTile(
            habitName: todayHabitList[index][0],
            habitCompleted: todayHabitList[index][1],
            onChanged: (value) => checkboxTapped(value, index),
          );
        },
      ),
    );
  }
}
