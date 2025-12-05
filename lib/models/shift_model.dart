import 'package:hive/hive.dart';

part 'shift_model.g.dart';

@HiveType(typeId: 0)
class ShiftModel extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  String shift;

  @HiveField(2)
  String? startTime;

  @HiveField(3)
  String? endTime;

  @HiveField(4)
  DateTime? notificationTime;

  ShiftModel({
    required this.date,
    required this.shift,
    this.startTime,
    this.endTime,
    this.notificationTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    String shiftVal = json['shift'] as String;
    String? start = json['startTime'] as String?;
    String? end = json['endTime'] as String?;

    // If start/end are missing, try to parse from shift string (e.g. "08:00-16:00")
    if (start == null || end == null) {
      final timeRegex = RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})');
      final match = timeRegex.firstMatch(shiftVal);
      if (match != null) {
        start ??= match.group(1);
        end ??= match.group(2);
      }
    }

    return ShiftModel(
      date: json['date'] as String,
      shift: shiftVal,
      startTime: start,
      endTime: end,
      notificationTime: json['notificationTime'] != null 
          ? DateTime.parse(json['notificationTime']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'shift': shift,
      'startTime': startTime,
      'endTime': endTime,
      'notificationTime': notificationTime?.toIso8601String(),
    };
  }
}
