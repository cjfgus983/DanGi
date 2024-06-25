import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'word_entry.dart';

class ContributionPage extends StatelessWidget {
  final List<WordEntry> vocabularyList;

  ContributionPage({required this.vocabularyList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공부 빈도'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              int contributionCount = vocabularyList
                  .where((entry) => isSameDay(entry.date, day))
                  .length;

              Color? cellColor;
              if (contributionCount == 0) {
                cellColor = Colors.grey[200];
              } else if (contributionCount == 1) {
                cellColor = Colors.green[100];
              } else if (contributionCount == 2) {
                cellColor = Colors.green[300];
              } else if (contributionCount == 3) {
                cellColor = Colors.green[500];
              } else if (contributionCount == 4) {
                cellColor = Colors.green[700];
              } else {
                cellColor = Colors.green[900]; // 5개 이상일 때
              }

              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle().copyWith(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
