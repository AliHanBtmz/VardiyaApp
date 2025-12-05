import 'dart:io';
// import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:excel/excel.dart';
// import 'package:pdf_render/pdf_render.dart';
import 'package:flutter/foundation.dart';

class FileHandlerService {
  final ImagePicker _picker = ImagePicker();

  /// Galeriden resim seçer
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Resim seçme hatası: $e');
    }
    return null;
  }

  /// Belirtilen uzantılara göre dosya seçer
  Future<File?> pickFile(List<String> extensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Dosya seçme hatası: $e');
    }
    return null;
  }


  /// Excel dosyasını CSV benzeri string'e çevirir
  Future<String?> convertExcelToCsv(File excelFile) async {
    try {
      var bytes = excelFile.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      
      StringBuffer buffer = StringBuffer();

      for (var table in excel.tables.keys) {
        // Sadece ilk sayfayı alalım veya hepsini birleştirelim
        // Şimdilik tüm sayfaları geziyoruz
        buffer.writeln('--- Sheet: $table ---');
        for (var row in excel.tables[table]!.rows) {
          String rowString = row.map((e) => e?.value?.toString() ?? '').join(',');
          buffer.writeln(rowString);
        }
      }

      debugPrint('Excel CSV uzunluğu: ${buffer.length}');
      return buffer.toString();
    } catch (e) {
      debugPrint('Excel okuma hatası: $e');
    }
    return null;
  }
}
