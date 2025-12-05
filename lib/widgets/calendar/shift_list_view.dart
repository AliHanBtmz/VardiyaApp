import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/shift_model.dart';
import '../shift_dialog.dart';

class ShiftListView extends StatelessWidget {
  final DateTime? selectedDay;
  final bool isCalendarSelectionMode;
  final bool isListSelectionMode;
  final Set<DateTime> selectedCalendarDays;
  final Set<ShiftModel> selectedListShifts;
  final List<ShiftModel> shifts;
  final Function(ShiftModel) onShiftSelected;
  final Function(List<ShiftModel>) onDeleteSelected;
  final Function(bool) onSelectionModeChanged;

  const ShiftListView({
    super.key,
    required this.selectedDay,
    required this.isCalendarSelectionMode,
    required this.isListSelectionMode,
    required this.selectedCalendarDays,
    required this.selectedListShifts,
    required this.shifts,
    required this.onShiftSelected,
    required this.onDeleteSelected,
    required this.onSelectionModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null && !isCalendarSelectionMode) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Vardiyaları görmek için bir gün seçin',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (isCalendarSelectionMode) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_sweep_outlined, size: 64, color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7)),
              const SizedBox(height: 16),
              Text(
                'Takvimden silinecek günleri seçin',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${selectedCalendarDays.length} gün seçildi',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dailyShifts = _getShiftsForDay(selectedDay!, shifts);

    if (dailyShifts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Bu gün için vardiya bulunamadı',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDay!),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
              if (isListSelectionMode)
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.tertiary),
                  onPressed: () => onDeleteSelected(selectedListShifts.toList()),
                ),
            ],
          ),
        ),
        if (isListSelectionMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${selectedListShifts.length} vardiya seçildi',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: dailyShifts.length,
            itemBuilder: (context, index) {
              final shift = dailyShifts[index];
              final isSelected = selectedListShifts.contains(shift);

              return Card(
                elevation: isSelected ? 4 : 0,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isSelected
                      ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onLongPress: () {
                    if (!isListSelectionMode) {
                      showDialog(
                        context: context,
                        builder: (_) => ShiftDialog(shift: shift),
                      );
                    }
                  },
                  onTap: isListSelectionMode ? () => onShiftSelected(shift) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (isListSelectionMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shift.shift,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    (shift.startTime?.isNotEmpty == true)
                                        ? "${shift.startTime}"
                                        : "Saat belirtilmemiş",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isListSelectionMode)
                          IconButton(
                            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () => onSelectionModeChanged(true),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<ShiftModel> _getShiftsForDay(DateTime day, List<ShiftModel> shifts) {
    String dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return shifts.where((shift) => shift.date == dateStr).toList();
  }
}
