import 'package:habit_tracker/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todayHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  // Default Data
  void createDefault() {
    todayHabitList = [
      ['Habit 1', false],
      ['Habit 2', false],
      ['Habit 3', false]
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

    calculateHabitPercentage();
    loadHeatMap();
  }

  void calculateHabitPercentage() {
    int countCompleted = 0;
    for (int i = 0; i < todayHabitList.length; i++) {
      if (todayHabitList[i][1] == true) {
        countCompleted++;
      }
    }
    String percent = todayHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todayHabitList.length).toStringAsFixed(1);

    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }
}
