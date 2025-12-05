import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/shift_model.dart';
import '../providers/shift_provider.dart';

class ShiftDialog extends StatefulWidget {
  final ShiftModel? shift;
  final DateTime? selectedDate;

  const ShiftDialog({super.key, this.shift, this.selectedDate});

  @override
  State<ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<ShiftDialog> {
  late TextEditingController _shiftController;
  late TextEditingController _dateController;
  TimeOfDay? _startTime;
  DateTime? _customNotificationTime;
  String _notificationOption = 'default';

  @override
  void initState() {
    super.initState();
    _shiftController = TextEditingController(text: widget.shift?.shift ?? '');
    
    String initialDate = '';
    if (widget.shift != null) {
      initialDate = widget.shift!.date;
    } else if (widget.selectedDate != null) {
      initialDate = "${widget.selectedDate!.year}-${widget.selectedDate!.month.toString().padLeft(2, '0')}-${widget.selectedDate!.day.toString().padLeft(2, '0')}";
    }
    _dateController = TextEditingController(text: initialDate);

    if (widget.shift != null && widget.shift!.startTime?.isNotEmpty == true) {
      final parts = widget.shift!.startTime!.split(':');
      if (parts.length == 2) {
        _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } else {
      // Default start time for new shift
       _startTime = const TimeOfDay(hour: 8, minute: 0);
    }

    if (widget.shift != null) {
      if (widget.shift!.notificationTime != null) {
        if (widget.shift!.notificationTime!.year == 2000) {
          _notificationOption = 'none';
        } else {
          _notificationOption = 'custom';
          _customNotificationTime = widget.shift!.notificationTime;
        }
      } else {
        _notificationOption = 'default';
      }
    }
  }

  @override
  void dispose() {
    _shiftController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shift != null;
    
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.add_circle,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Text(isEditing ? 'Vardiya Düzenle' : 'Manuel Ekle'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _shiftController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: isEditing ? 'Vardiya Bilgisi' : 'Vardiya Adı (Örn: Sabah)',
                prefixIcon: const Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tarih',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                 DateTime? currentDate;
                 if (_dateController.text.isNotEmpty) {
                    try {
                      final parts = _dateController.text.split('-');
                      currentDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                    } catch (_) {}
                 }
                 
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: currentDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  locale: const Locale('tr', 'TR'),
                );
                if (picked != null) {
                  _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
                  confirmText: 'TAMAM',
                  cancelText: 'İPTAL',
                  helpText: 'SAAT SEÇİN',
                  builder: (BuildContext context, Widget? child) {
                    return Localizations.override(
                      context: context,
                      locale: const Locale('en', 'US'),
                      child: child,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _startTime = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Başla',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(_startTime?.format(context) ?? 'Seç'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Bildirim Ayarı', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _notificationOption,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'default', child: Text('Otomatik (12 saat önce)')),
                DropdownMenuItem(value: 'custom', child: Text('Özel Zaman Seç')),
                DropdownMenuItem(value: 'none', child: Text('Bildirim Yok')),
              ],
              onChanged: (val) {
                setState(() {
                  _notificationOption = val!;
                  if (val != 'custom') _customNotificationTime = null;
                });
              },
            ),
            if (_notificationOption == 'custom')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _customNotificationTime ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      if (!context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_customNotificationTime ?? DateTime.now()),
                        confirmText: 'TAMAM',
                        cancelText: 'İPTAL',
                        helpText: 'SAAT SEÇİN',
                        builder: (BuildContext context, Widget? child) {
                          return Localizations.override(
                            context: context,
                            locale: const Locale('en', 'US'),
                            child: child,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() {
                          _customNotificationTime = DateTime(
                            date.year, date.month, date.day, time.hour, time.minute
                          );
                        });
                      }
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Bildirim Zamanı',
                      prefixIcon: Icon(Icons.notifications_active),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _customNotificationTime != null 
                          ? DateFormat('dd/MM/yyyy HH:mm').format(_customNotificationTime!)
                          : 'Zaman Seçin',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        FilledButton(
          onPressed: () async {
            if (_shiftController.text.isNotEmpty && _dateController.text.isNotEmpty) {
               DateTime? finalNotificationTime;
              if (_notificationOption == 'custom') {
                finalNotificationTime = _customNotificationTime;
              } else if (_notificationOption == 'none') {
                finalNotificationTime = DateTime(2000); 
              } else {
                finalNotificationTime = null; // Default
              }

              final newShift = ShiftModel(
                shift: _shiftController.text,
                date: _dateController.text,
                startTime: _startTime != null 
                    ? "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}" 
                    : "",
                endTime: "",
                notificationTime: finalNotificationTime,
              );

              final provider = Provider.of<ShiftProvider>(context, listen: false);
              if (isEditing) {
                await provider.updateShift(widget.shift!, newShift);
              } else {
                await provider.addShift(newShift);
              }
              
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(isEditing ? 'Kaydet' : 'Ekle'),
        ),
      ],
    );
  }
}
