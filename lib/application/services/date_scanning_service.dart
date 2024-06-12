import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class DateScanningService {
  Future<String> scanTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textDetector = TextRecognizer();
    final RecognizedText recognisedText =
        await textDetector.processImage(inputImage);
    await textDetector.close();
    return recognisedText.text;
  }

  DateTime? extractDateFromText(String text) {
    final datePattern = RegExp(
      r'\b('
      r'(\d{1,2}[./\s-]\d{1,2}[./\s-]\d{2,4})|' // Matches 01/01/27, 01 01 2027, 01-01-2027, etc.
      r'(\d{1,2}\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+\d{2,4})|' // Matches 01 jan 27, 01 jan 2027, etc.
      r'(\d{4}[./\s-]\d{1,2}[./\s-]\d{1,2})|' // Matches 2027/01/01, 2027-01-01, 2027 01 01, etc.
      r'(\d{4}[./\s-]\d{1,2})|' // Matches 2027/01, 2027-01, 2027 01, etc.
      r'(\d{1,2}[./\s-]\d{4})|' // Matches 01/2027, 01-2027, 01 2027, etc.
      r'(\d{1,2}[./\s-]\d{2})' // Matches 01.27, 01/27, 01 27, etc.
      r')\b',
      caseSensitive: false,
    );

    final match = datePattern.firstMatch(text);

    if (match != null) {
      final dateString = match.group(0);
      print(dateString);
      if (dateString != null) {
        final formats = [
          'dd-MM-yy',
          'dd/MM/yy',
          'dd MM yy',
          'dd.MM.yy',
          'MM-dd-yy',
          'MM/dd/yy',
          'MM dd yy',
          'MM.dd.yy',
          'dd-MM-yyyy',
          'dd/MM/yyyy',
          'dd MM yyyy',
          'dd.MM.yyyy',
          'MM-dd-yyyy',
          'MM/dd/yyyy',
          'MM dd yyyy',
          'yyyy-MM-dd',
          'yyyy/MM/dd',
          'yyyy MM dd',
          'yyyy.MM.dd',
          'MM.yy',
          'MM/yy',
          'MM-yy',
          'MM yy',
          'yy-MM',
          'yy/MM',
          'yy MM',
          'yy.MM',
          'MM-yyyy',
          'MM/yyyy',
          'MM yyyy',
          'MM.yyyy',
          'yyyy-MM',
          'yyyy/MM',
          'yyyy MM',
          'yyyy.MM',
        ];

        // Prioritize dd-MM-yyyy format first

        final priorityFormats = [
          'dd-MM-yyyy',
          'dd/MM/yyyy',
          'dd MM yyyy',
          'dd.MM.yyyy',
        ];
        //
        // for (var format in priorityFormats) {
        //   try {
        //     final parsedDate = DateFormat(format)
        //         .parseStrict(dateString.replaceAll(RegExp(r'[./\s-]'), '-'));
        //     return parsedDate;
        //   } catch (e) {}
        // }

        // Try other formats
        for (var format in formats) {
          if (!priorityFormats.contains(format)) {
            try {
              final parsedDate = DateFormat(format)
                  .parseStrict(dateString.replaceAll(RegExp(r'[./\s-]'), '-'));
              return parsedDate;
            } catch (e) {}
          }
        }

        // Special case for formats like MM/yyyy and MM.yyyy
        final partialDatePattern1 = RegExp(r'(\d{1,2})[./\s-](\d{4})');
        final partialMatch1 = partialDatePattern1.firstMatch(dateString);
        if (partialMatch1 != null) {
          try {
            final month = int.parse(partialMatch1.group(1)!);
            final year = int.parse(partialMatch1.group(2)!);
            return DateTime(year, month, 1);
          } catch (e) {}
        }

        // Special case for formats like yyyy/MM and yyyy.MM
        final partialDatePattern2 = RegExp(r'(\d{4})[./\s-](\d{1,2})');
        final partialMatch2 = partialDatePattern2.firstMatch(dateString);
        if (partialMatch2 != null) {
          try {
            final year = int.parse(partialMatch2.group(1)!);
            final month = int.parse(partialMatch2.group(2)!);
            return DateTime(year, month, 1);
          } catch (e) {}
        }
      }
    }
    return null;
  }
}
