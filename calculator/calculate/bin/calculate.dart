import 'dart:io';

import 'package:calculate/calculate.dart';

void main(List<String> arguments) {
  // Help mode.
  if (arguments.isEmpty ||
      arguments.first == '-h' ||
      arguments.first == '--help') {
    _printUsage();
    return;
  }

  try {
    // Template export mode: `dart run ... template [output.xlsx]`.
    if (arguments.first.toLowerCase() == 'template') {
      final outputPath = arguments.length >= 2
          ? arguments[1]
          : '.\\student_template.xlsx';
      exportStudentTemplate(outputPath);
      stdout.writeln('Template exported: ${File(outputPath).absolute.path}');
      return;
    }

    // Processing mode accepts input path and optional output path.
    if (arguments.length > 2) {
      throw ArgumentError(
        'Process mode expects 1 or 2 paths.\n'
        'Examples:\n'
        '  dart run bin/calculate.dart ./students.xlsx\n'
        '  dart run bin/calculate.dart ./students.xlsx ./graded_students.xlsx',
      );
    }

    final inputPath = arguments[0];
    final outputPath = arguments.length == 2
        ? arguments[1]
        : buildDefaultOutputPath(inputPath);
    final students = readStudentRecords(inputPath);
    final inputAbsolutePath = File(inputPath).absolute.path;
    final outputAbsolutePath = File(outputPath).absolute.path;

    // Show imported rows first, then generate and show graded rows.
    _printInputPreview(inputAbsolutePath, students);
    exportGradedWorkbook(outputPath: outputPath, students: students);
    _printOutputPreview(outputAbsolutePath, students);

    stdout.writeln('Processed students: ${students.length}');
    stdout.writeln(
      'You can now open or download this new Excel file from your computer.',
    );
    stdout.writeln('Process complete. You can close this terminal now.');
  } on Object catch (error) {
    stderr.writeln('Error: $error');
    exitCode = 1;
  }
}

void _printUsage() {
  stdout.writeln('Student Grade Calculator');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln(
    '  dart run bin/calculate.dart template [output_template.xlsx]',
  );
  stdout.writeln(
    '  dart run bin/calculate.dart <input_students.xlsx> [output_graded.xlsx]',
  );
  stdout.writeln('');
  stdout.writeln(
    'If output is not provided, a new file is created next to input:',
  );
  stdout.writeln('  students.xlsx -> students_graded.xlsx');
  stdout.writeln('');
  stdout.writeln('Expected headers in the input sheet:');
  stdout.writeln(
    '  Name, Course, Matricule, Email, CA Marks, Attendance Marks, '
    'Assignment Marks, Exam Marks',
  );
}

void _printInputPreview(String inputPath, List<StudentRecord> students) {
  stdout.writeln('INPUT EXCEL FILE: $inputPath');
  if (students.isEmpty) {
    stdout.writeln('No student data rows were found in the uploaded file.');
    return;
  }

  stdout.writeln('INPUT EXCEL DATA:');
  stdout.writeln(
    '#'.padRight(3) +
        'Name'.padRight(20) +
        'Course'.padRight(15) +
        'Matricule'.padRight(20) +
        'Email'.padRight(45) +
        'CA'.padRight(5) +
        'Attendance'.padRight(12) +
        'Assignment'.padRight(12) +
        'Exam'.padRight(5),
  );

  for (var i = 0; i < students.length; i++) {
    final student = students[i];
    // Input view prints only values read from the source workbook.
    stdout.writeln(
      (i + 1).toString().padRight(3) +
          student.safeName.padRight(20) +
          student.safeCourse.padRight(15) +
          student.safeMatricule.padRight(20) +
          student.safeEmail.padRight(45) +
          _formatNumber(student.safeCaMarks).padRight(5) +
          _formatNumber(student.safeAttendanceMarks).padRight(12) +
          _formatNumber(student.safeAssignmentMarks).padRight(12) +
          _formatNumber(student.safeExamMarks).padRight(5),
    );
  }
}

void _printOutputPreview(String outputPath, List<StudentRecord> students) {
  stdout.writeln('OUTPUT EXCEL FILE: $outputPath');
  if (students.isEmpty) {
    stdout.writeln('No graded rows were generated.');
    return;
  }

  stdout.writeln('OUTPUT EXCEL DATA:');
  stdout.writeln(
    '#'.padRight(3) +
        'Name'.padRight(20) +
        'Course'.padRight(15) +
        'Matricule'.padRight(20) +
        'Email'.padRight(45) +
        'CA'.padRight(5) +
        'Attendance'.padRight(12) +
        'Assignment'.padRight(12) +
        'Exam'.padRight(5) +
        'Coursework'.padRight(12) +
        'Total'.padRight(8) +
        'Grade'.padRight(5),
  );

  for (var i = 0; i < students.length; i++) {
    final student = students[i];
    // Output view includes computed coursework and final grade details.
    stdout.writeln(
      (i + 1).toString().padRight(3) +
          student.safeName.padRight(20) +
          student.safeCourse.padRight(15) +
          student.safeMatricule.padRight(20) +
          student.safeEmail.padRight(45) +
          _formatNumber(student.safeCaMarks).padRight(5) +
          _formatNumber(student.safeAttendanceMarks).padRight(12) +
          _formatNumber(student.safeAssignmentMarks).padRight(12) +
          _formatNumber(student.safeExamMarks).padRight(5) +
          _formatNumber(student.courseworkScoreOutOf30).padRight(12) +
          _formatNumber(student.totalScore).padRight(8) +
          student.letterGrade.padRight(5),
    );
  }
}

String _formatNumber(double value) {
  // Keep whole numbers clean in terminal output (e.g., "23" not "23.00").
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}