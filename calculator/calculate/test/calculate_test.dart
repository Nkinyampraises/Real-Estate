import 'dart:io';
import 'dart:convert';

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

    test('uses CA and attendance only when assignment mark is missing', () {
      const student = StudentRecord(
        caMarks: 20,
        attendanceMarks: 8,
        examMarks: 60,
      );

      expect(student.courseworkScoreOutOf30, 21);
      expect(student.totalScore, 81);
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
      expect(calculateGradeLetter(74), 'B+');
      expect(calculateGradeLetter(64), 'B');
      expect(calculateGradeLetter(55), 'C+');
      expect(calculateGradeLetter(50), 'C');
      expect(calculateGradeLetter(47), 'D+');
      expect(calculateGradeLetter(43), 'D');
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

  group('higher-order functions and collection operations', () {
    const sampleStudents = <StudentRecord>[
      StudentRecord(
        name: 'Ada',
        caMarks: 24,
        attendanceMarks: 8,
        assignmentMarks: 8,
        examMarks: 50,
      ),
      StudentRecord(
        name: 'Ben',
        caMarks: 14,
        attendanceMarks: 7,
        assignmentMarks: 4,
        examMarks: 32,
      ),
      StudentRecord(
        name: 'Chi',
        caMarks: 28,
        attendanceMarks: 9,
        assignmentMarks: 9,
        examMarks: 60,
      ),
    ];

    test('reduces with lambda passed to custom HOF', () {
      final total = reduceStudentRecords<double>(
        sampleStudents,
        0,
        (sum, student) => sum + student.totalScore,
      );

      expect(total, closeTo(208.6, 0.01));
    });

    test('filters students by minimum score', () {
      final passing = filterStudentsByMinimumScore(sampleStudents);

      expect(passing, hasLength(2));
      expect(
        passing.map((student) => student.safeName),
        containsAll(<String>['Ada', 'Chi']),
      );
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

    test('accepts missing assignment column and uses /40 scaling', () {
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
        TextCellValue('Exam'),
      ]);
      sheet.appendRow(<CellValue>[
        TextCellValue('Jane Doe'),
        TextCellValue('Computer Science'),
        TextCellValue('MAT123'),
        TextCellValue('jane@example.com'),
        DoubleCellValue(20),
        DoubleCellValue(8),
        DoubleCellValue(60),
      ]);

      final bytes = excel.save();
      expect(bytes, isNotNull);
      File(inputPath).writeAsBytesSync(bytes!);

      final students = readStudentRecords(inputPath);

      expect(students, hasLength(1));
      expect(students.first.assignmentMarks, isNull);
      expect(students.first.totalScore, closeTo(81, 0.0001));
    });

    test('reads CSV input bytes', () {
      const csvSource = '''
Name,Course,Matricule,Email,CA Marks,Attendance Marks,Assignment Marks,Exam Marks
Jane Doe,Computer Science,MAT123,jane@example.com,20,8,9,60
''';

      final students = readStudentRecordsFromBytes(
        utf8.encode(csvSource),
        fileName: 'students.csv',
      );

      expect(students, hasLength(1));
      expect(students.first.safeName, 'Jane Doe');
      expect(students.first.totalScore, closeTo(82.2, 0.0001));
    });

    test('reads HTML table input bytes', () {
      const htmlSource = '''
<!DOCTYPE html>
<html>
  <body>
    <table>
      <tr>
        <th>Name</th>
        <th>Course</th>
        <th>Matricule</th>
        <th>Email</th>
        <th>CA Marks</th>
        <th>Attendance Marks</th>
        <th>Assignment Marks</th>
        <th>Exam Marks</th>
      </tr>
      <tr>
        <td>Jane Doe</td>
        <td>Computer Science</td>
        <td>MAT123</td>
        <td>jane@example.com</td>
        <td>20</td>
        <td>8</td>
        <td>9</td>
        <td>60</td>
      </tr>
    </table>
  </body>
</html>
''';

      final students = readStudentRecordsFromBytes(
        utf8.encode(htmlSource),
        fileName: 'students.html',
      );

      expect(students, hasLength(1));
      expect(students.first.safeName, 'Jane Doe');
      expect(students.first.totalScore, closeTo(82.2, 0.0001));
    });
  });

  group('export format inference', () {
    test('infers output type from extension', () {
      expect(inferExportFileTypeFromPath('report.xlsx'), ExportFileType.excel);
      expect(inferExportFileTypeFromPath('report.csv'), ExportFileType.csv);
      expect(inferExportFileTypeFromPath('report.html'), ExportFileType.html);
      expect(inferExportFileTypeFromPath('report.pdf'), ExportFileType.pdf);
    });
  });
}
