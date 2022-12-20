import 'package:habit_tracker/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todayHabitList = [];

  // Default Data
  void createDefault() {
    todayHabitList = [
      ['Run', false],
      ['Read', false]
    ];

    _myBox.put("START_DATE", todaysDateFormatted());
  }

  // Load Data if exists
  void loadData() {
    if (_myBox.get(todaysDateFormatted()) == null) {
      todayHabitList = _myBox.get("CURRENT_HABIT_LIST");

      for (int i = 0; i < todayHabitList.length; i++) {
        todayHabitList[i][i] = false;
      }
    } else {
      todayHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  // Update database
  void updateDatabase() {
    _myBox.put(todaysDateFormatted(), todayHabitList);
    _myBox.put("CURRENT_HABIT_LIST", todayHabitList);
  }
}
