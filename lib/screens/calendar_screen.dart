import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/shift_provider.dart';
import '../models/shift_model.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/calendar/calendar_view.dart';
import '../widgets/calendar/shift_list_view.dart';
import '../widgets/calendar/upload_bottom_sheet.dart';
import '../widgets/calendar/api_key_banner.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Multi-select for calendar deletion
  bool _isCalendarSelectionMode = false;
  final Set<DateTime> _selectedCalendarDays = {};

  // Multi-select for list deletion
  bool _isListSelectionMode = false;
  final Set<ShiftModel> _selectedListShifts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Vardiya Asistanı'),
        actions: [
          if (_isCalendarSelectionMode)
            IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
              onPressed: _deleteSelectedCalendarDays,
            ),
          IconButton(
            icon: Icon(
              _isCalendarSelectionMode ? Icons.check_circle : Icons.calendar_today_outlined,
              color: _isCalendarSelectionMode ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: _isCalendarSelectionMode ? 'Seçimi Bitir' : 'Takvimden Sil',
            onPressed: () {
              setState(() {
                _isCalendarSelectionMode = !_isCalendarSelectionMode;
                _selectedCalendarDays.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.vpn_key_outlined,
              color: !Provider.of<ShiftProvider>(context).hasApiKey ? Theme.of(context).colorScheme.error : null,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ApiKeyDialog(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            });
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > 600;
              if (isLandscape) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (!provider.hasApiKey) const ApiKeyBanner(),
                            const SizedBox(height: 16),
                            _buildCalendarView(provider),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: _buildShiftListView(provider),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  if (!provider.hasApiKey) const ApiKeyBanner(),
                  const SizedBox(height: 16),
                  _buildCalendarView(provider),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        child: _buildShiftListView(provider),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const UploadBottomSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Vardiya Ekle'),
      ),
    );
  }

  Widget _buildCalendarView(ShiftProvider provider) {
    return CalendarView(
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      isCalendarSelectionMode: _isCalendarSelectionMode,
      selectedCalendarDays: _selectedCalendarDays,
      shifts: provider.shifts,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          if (_isCalendarSelectionMode) {
            if (_selectedCalendarDays.any((d) => isSameDay(d, selectedDay))) {
              _selectedCalendarDays.removeWhere((d) => isSameDay(d, selectedDay));
            } else {
              _selectedCalendarDays.add(selectedDay);
            }
          } else {
            _selectedDay = selectedDay;
          }
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildShiftListView(ShiftProvider provider) {
    return ShiftListView(
      selectedDay: _selectedDay,
      isCalendarSelectionMode: _isCalendarSelectionMode,
      isListSelectionMode: _isListSelectionMode,
      selectedCalendarDays: _selectedCalendarDays,
      selectedListShifts: _selectedListShifts,
      shifts: provider.shifts,
      onShiftSelected: (shift) {
        setState(() {
          if (_selectedListShifts.contains(shift)) {
            _selectedListShifts.remove(shift);
            if (_selectedListShifts.isEmpty) _isListSelectionMode = false;
          } else {
            _selectedListShifts.add(shift);
          }
        });
      },
      onDeleteSelected: (shifts) {
        provider.deleteShifts(shifts);
        setState(() {
          _selectedListShifts.clear();
          _isListSelectionMode = false;
        });
      },
      onSelectionModeChanged: (isSelectionMode) {
        setState(() {
          _isListSelectionMode = isSelectionMode;
          if (isSelectionMode && _selectedListShifts.isEmpty) {
             // Optionally add the first item if triggered by long press on an item
             // But here we just switch mode
          }
        });
      },
    );
  }

  void _deleteSelectedCalendarDays() {
    final provider = Provider.of<ShiftProvider>(context, listen: false);
    List<ShiftModel> shiftsToDelete = [];
    
    for (var day in _selectedCalendarDays) {
      shiftsToDelete.addAll(_getShiftsForDay(day, provider.shifts));
    }

    if (shiftsToDelete.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Emin misiniz?'),
          content: Text('${_selectedCalendarDays.length} gün için toplam ${shiftsToDelete.length} vardiya silinecek.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            FilledButton(
              onPressed: () {
                provider.deleteShifts(shiftsToDelete);
                setState(() {
                  _selectedCalendarDays.clear();
                  _isCalendarSelectionMode = false;
                });
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seçilen günlerde silinecek vardiya yok.')),
      );
    }
  }

  List<ShiftModel> _getShiftsForDay(DateTime day, List<ShiftModel> shifts) {
    String dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return shifts.where((shift) => shift.date == dateStr).toList();
  }
}
