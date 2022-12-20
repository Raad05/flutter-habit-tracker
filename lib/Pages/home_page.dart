import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/Components/habit_tile.dart';
import 'package:habit_tracker/Components/monthly_summary.dart';
import 'package:habit_tracker/Components/my_fab.dart';
import 'package:habit_tracker/Components/my_alert_box.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box('Habit_Database');

  @override
  void initState() {
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefault();
    } else {
      db.loadData();
    }
    db.updateDatabase();

    super.initState();
  }

  void checkboxTapped(bool? value, int index) {
    setState(() {
      db.todayHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  final _newHabitNameController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            hintText: 'Enter Habit Name',
            onSave: saveNewHabit,
            onCancel: cancelDialogueBox,
          );
        });
  }

  void saveNewHabit() {
    setState(() {
      db.todayHabitList.add([_newHabitNameController.text, false]);
    });

    _newHabitNameController.clear();
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void deleteHabit(int index) {
    setState(() {
      db.todayHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  void cancelDialogueBox() {
    _newHabitNameController.clear();
    Navigator.of(context).pop();
  }

  void openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            hintText: db.todayHabitList[index][0],
            onSave: () => saveExistingHabit(index),
            onCancel: cancelDialogueBox,
          );
        });
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todayHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Habit Tracker"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.leave_bags_at_home),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(
        onPressed: createNewHabit,
      ),
      body: ListView(
        children: [
          MonthlySummary(
              datasets: db.heatMapDataSet, startDate: _myBox.get("START_DATE")),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: db.todayHabitList.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habitName: db.todayHabitList[index][0],
                habitCompleted: db.todayHabitList[index][1],
                onChanged: (value) => checkboxTapped(value, index),
                settingsTapped: (context) => openHabitSettings(index),
                deleteTapped: (context) => deleteHabit(index),
              );
            },
          )
        ],
      ),
    );
  }
}
