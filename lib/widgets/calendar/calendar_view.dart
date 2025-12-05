import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/shift_model.dart';

class CalendarView extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final bool isCalendarSelectionMode;
  final Set<DateTime> selectedCalendarDays;
  final List<ShiftModel> shifts;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const CalendarView({
    super.key,
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.isCalendarSelectionMode,
    required this.selectedCalendarDays,
    required this.shifts,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TableCalendar<ShiftModel>(
          locale: 'tr_TR',
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: focusedDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: calendarFormat,
          rowHeight: MediaQuery.of(context).orientation == Orientation.landscape ? 40 : 52,
          selectedDayPredicate: (day) {
            if (isCalendarSelectionMode) {
              return selectedCalendarDays.any((d) => isSameDay(d, day));
            }
            return isSameDay(selectedDay, day);
          },
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          eventLoader: (day) {
            return _getShiftsForDay(day, shifts);
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
            rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.background),
            holidayTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            defaultTextStyle: const TextStyle(color: Colors.white),
            defaultDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
            weekendDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
            todayTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final text = DateFormat.E('tr_TR').format(day);
              if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
                return Center(
                  child: Text(
                    text,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return Center(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<ShiftModel> _getShiftsForDay(DateTime day, List<ShiftModel> shifts) {
    String dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return shifts.where((shift) => shift.date == dateStr).toList();
  }
}
