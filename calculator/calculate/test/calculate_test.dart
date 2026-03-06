import 'dart:io';

import 'package:calculate/calculate.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('StudentRecord', () {
    test('defaults nullable values safely', () {
      const student = StudentRecord();

      expect(student.safeName, 'Unknown Student');
      expect(student.safeCourse, 'N/A');
      expect(student.safeMatricule, 'N/A');
      expect(student.safeEmail, 'N/A');
      expect(student.safeCaMarks, 0);
      expect(student.safeAttendanceMarks, 0);
      expect(student.safeAssignmentMarks, 0);
      expect(student.safeExamMarks, 0);
      expect(student.totalScore, 0);
      expect(student.letterGrade, 'F');
    });

    test('calculates weighted coursework and exam total', () {
      const student = StudentRecord(
        caMarks: 30,
        attendanceMarks: 10,
        assignmentMarks: 10,
        examMarks: 70,
      );

      expect(student.courseworkRawOutOf50, 50);
      expect(student.courseworkScoreOutOf30, 30);
      expect(student.totalScore, 100);
      expect(student.letterGrade, 'A');
    });

    test('clamps marks to allowed component limits', () {
      const student = StudentRecord(
        caMarks: 60,
        attendanceMarks: 30,
        assignmentMarks: 15,
        examMarks: 120,
      );

      expect(student.safeCaMarks, 30);
      expect(student.safeAttendanceMarks, 10);
      expect(student.safeAssignmentMarks, 10);
      expect(student.safeExamMarks, 70);
      expect(student.courseworkScoreOutOf30, 30);
      expect(student.totalScore, 100);
      expect(student.letterGrade, 'A');
    });

    test('treats negative marks as zero', () {
      const student = StudentRecord(
        caMarks: -5,
        attendanceMarks: 10,
        assignmentMarks: 10,
        examMarks: 10,
      );

      expect(student.safeCaMarks, 0);
      expect(student.courseworkScoreOutOf30, 12);
      expect(student.totalScore, 22);
      expect(student.letterGrade, 'F');
    });
  });

  group('calculateGradeLetter', () {
    test('returns grade bands', () {
      expect(calculateGradeLetter(92), 'A');
      expect(calculateGradeLetter(64), 'B');
      expect(calculateGradeLetter(55), 'C');
      expect(calculateGradeLetter(47), 'D');
      expect(calculateGradeLetter(43), 'E');
      expect(calculateGradeLetter(12), 'F');
    });
  });

  group('buildDefaultOutputPath', () {
    test('creates graded workbook path next to input file', () {
      final inputPath = p.join('uploads', 'students.xlsx');
      final outputPath = buildDefaultOutputPath(inputPath);

      expect(p.dirname(outputPath), p.dirname(inputPath));
      expect(p.basename(outputPath), 'students_graded.xlsx');
    });

    test('adds xlsx extension when input has none', () {
      final inputPath = p.join('uploads', 'students');
      final outputPath = buildDefaultOutputPath(inputPath);

      expect(p.basename(outputPath), 'students_graded.xlsx');
    });
  });

  group('readStudentRecords', () {
    test('accepts misspelled assignment header alias', () {
      final tempDir = Directory.systemTemp.createTempSync('calculate_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final inputPath = p.join(tempDir.path, 'students.xlsx');

      final excel = Excel.createExcel();
      final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[sheetName];

      sheet.appendRow(<CellValue>[
        TextCellValue('Name'),
        TextCellValue('Course'),
        TextCellValue('Matricle'),
        TextCellValue('Email'),
        TextCellValue('CA Marks'),
        TextCellValue('Attendance marks'),
        TextCellValue('Asignment marks'),
        TextCellValue('Exam'),
      ]);
      sheet.appendRow(<CellValue>[
        TextCellValue('Jane Doe'),
        TextCellValue('Computer Science'),
        TextCellValue('MAT123'),
        TextCellValue('jane@example.com'),
        DoubleCellValue(20),
        DoubleCellValue(8),
        DoubleCellValue(9),
        DoubleCellValue(60),
      ]);

      final bytes = excel.save();
      expect(bytes, isNotNull);
      File(inputPath).writeAsBytesSync(bytes!);

      final students = readStudentRecords(inputPath);

      expect(students, hasLength(1));
      expect(students.first.safeAssignmentMarks, 9);
      expect(students.first.totalScore, closeTo(82.2, 0.0001));
    });
  });
}
