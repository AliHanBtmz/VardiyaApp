import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shift_model.dart';
import '../services/file_handler_service.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';

class ShiftProvider extends ChangeNotifier {
  final FileHandlerService _fileHandler = FileHandlerService();
  // TODO: API Key should be managed securely. For now, we'll ask user or use a placeholder.
  // In a real app, this would come from secure storage or env.
  // I will initialize it with a placeholder.
  late GeminiService _geminiService;

  List<ShiftModel> _shifts = [];
  bool _isLoading = false;
  String? _error;

  List<ShiftModel> get shifts => _shifts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String _currentApiKey = 'YOUR_API_KEY_HERE';
  String _currentModelName = 'gemini-2.5-flash';
  
  bool get hasApiKey => _currentApiKey.isNotEmpty && _currentApiKey != 'YOUR_API_KEY_HERE';
  String get currentModelName => _currentModelName;

  ShiftProvider() {
    _init();
  }

  void _init() async {
    // Load saved settings
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('gemini_api_key');
    final savedModel = prefs.getString('gemini_model_name');

    if (savedKey != null && savedKey.isNotEmpty) {
      _currentApiKey = savedKey;
    }
    
    if (savedModel != null && savedModel.isNotEmpty) {
      _currentModelName = savedModel;
    }

    _geminiService = GeminiService(_currentApiKey, modelName: _currentModelName);
    
    await _loadShifts();
  }

  Future<void> _loadShifts() async {
    var box = await Hive.openBox<ShiftModel>('shifts');
    _shifts = box.values.toList();
    notifyListeners();
  }

  Future<void> _saveShifts(List<ShiftModel> newShifts) async {
    // Filter out "OFF" days
    final validShifts = newShifts.where((s) {
      final shiftText = s.shift.toLowerCase().trim();
      return !shiftText.contains('off') && shiftText != 'izin';
    }).toList();

    var box = await Hive.openBox<ShiftModel>('shifts');
    for (var shift in validShifts) {
      await box.add(shift);
    }
    _shifts.addAll(validShifts);
    notifyListeners();
  }

  Future<void> addShift(ShiftModel shift) async {
    var box = await Hive.openBox<ShiftModel>('shifts');
    await box.add(shift);
    _shifts.add(shift);
    
    await _scheduleNotificationForShift(shift);
    
    notifyListeners();
  }

  Future<void> _scheduleNotificationForShift(ShiftModel shift) async {
    // Parse date and time
    try {
      final dateParts = shift.date.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      DateTime shiftStart;
      
      if (shift.startTime != null && shift.startTime!.isNotEmpty) {
        final timeParts = shift.startTime!.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        shiftStart = DateTime(year, month, day, hour, minute);
      } else {
        // Default to 08:00 if no time specified
        shiftStart = DateTime(year, month, day, 8, 0);
      }

      DateTime notificationTime;
      if (shift.notificationTime != null) {
        notificationTime = shift.notificationTime!;
      } else {
        // Default: 12 hours before
        notificationTime = shiftStart.subtract(const Duration(hours: 12));
      }

      if (notificationTime.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          id: shift.key as int? ?? DateTime.now().millisecondsSinceEpoch % 100000, 
          title: 'Vardiya Hatırlatıcı',
          body: 'Yarınki vardiyanız: ${shift.shift} (${shift.date})',
          scheduledDate: notificationTime,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> deleteShift(ShiftModel shift) async {
    var box = await Hive.openBox<ShiftModel>('shifts');
    await shift.delete(); // HiveObject extension method
    _shifts.remove(shift);
    notifyListeners();
  }

  Future<void> deleteShifts(List<ShiftModel> shiftsToDelete) async {
    // Create a copy to iterate safely or use a loop that handles removal
    for (var shift in List.of(shiftsToDelete)) {
      await deleteShift(shift);
    }
  }

  Future<void> updateShift(ShiftModel oldShift, ShiftModel newShift) async {
    // Since ShiftModel extends HiveObject, we can save directly if we modify it.
    // But here we are replacing.
    oldShift.shift = newShift.shift;
    oldShift.date = newShift.date;
    oldShift.startTime = newShift.startTime;
    oldShift.endTime = newShift.endTime;
    await oldShift.save();
    notifyListeners();
  }

  Future<void> processImageUpload(String userName, {bool fromCamera = false}) async {
    _setLoading(true);
    try {
      final file = await _fileHandler.pickImage(); // Camera support can be added to pickImage args
      if (file != null) {
        final bytes = await file.readAsBytes();
        final shifts = await _geminiService.analyzeImage(bytes, userName);
        await _saveShifts(shifts);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }


  Future<void> processExcelUpload(String userName) async {
    _setLoading(true);
    try {
      final file = await _fileHandler.pickFile(['xlsx', 'xls']);
      if (file != null) {
        final csvData = await _fileHandler.convertExcelToCsv(file);
        if (csvData != null) {
          final shifts = await _geminiService.analyzeText(csvData, userName);
          await _saveShifts(shifts);
        } else {
          _setError("Excel okunamadı.");
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }
  
  // Helper to update API Key from UI
  Future<void> updateSettings({String? apiKey, String? modelName}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (apiKey != null) {
      _currentApiKey = apiKey;
      await prefs.setString('gemini_api_key', apiKey);
    }
    
    if (modelName != null) {
      _currentModelName = modelName;
      await prefs.setString('gemini_model_name', modelName);
    }
    
    _geminiService = GeminiService(_currentApiKey, modelName: _currentModelName);
    notifyListeners();
  }
  
  // Deprecated: Use updateSettings instead
  void updateApiKey(String key) {
    updateSettings(apiKey: key);
  }
}
