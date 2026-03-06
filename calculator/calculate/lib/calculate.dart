import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;

/// Column layout for exported template workbooks.
const List<String> templateHeaders = <String>[
  'Name',
  'Course',
  'Matricule',
  'Email',
  'CA Marks',
  'Attendance Marks',
  'Assignment Marks',
  'Exam Marks',
];

/// Data-class style model with nullable user inputs.
class StudentRecord {
  const StudentRecord({
    this.name,
    this.course,
    this.matricule,
    this.email,
    this.caMarks,
    this.attendanceMarks,
    this.assignmentMarks,
    this.examMarks,
  });

  final String? name;
  final String? course;
  final String? matricule;
  final String? email;
  final double? caMarks;
  final double? attendanceMarks;
  final double? assignmentMarks;
  final double? examMarks;

  String get safeName {
    final trimmed = name?.trim();
    return (trimmed?.isNotEmpty ?? false) ? trimmed! : 'Unknown Student';
  }

  String get safeMatricule {
    final trimmed = matricule?.trim();
    return (trimmed?.isNotEmpty ?? false) ? trimmed! : 'N/A';
  }

  String get safeCourse {
    final trimmed = course?.trim();
    return (trimmed?.isNotEmpty ?? false) ? trimmed! : 'N/A';
  }

  String get safeEmail {
    final trimmed = email?.trim();
    return (trimmed?.isNotEmpty ?? false) ? trimmed! : 'N/A';
  }

  // Clamp each assessment component to its maximum allowed contribution.
  double get safeCaMarks => _safeMark(caMarks, max: 30);
  double get safeAttendanceMarks => _safeMark(attendanceMarks, max: 10);
  double get safeAssignmentMarks => _safeMark(assignmentMarks, max: 10);
  double get safeExamMarks => _safeMark(examMarks, max: 70);

  // Coursework components are first summed out of 50, then scaled to 30.
  double get courseworkRawOutOf50 =>
      safeCaMarks + safeAttendanceMarks + safeAssignmentMarks;

  double get courseworkScoreOutOf30 => (courseworkRawOutOf50 / 50) * 30;

  double get totalScore {
    final total = courseworkScoreOutOf30 + safeExamMarks;
    return total.clamp(0, 100).toDouble();
  }

  String get letterGrade => calculateGradeLetter(totalScore);

  static double _safeMark(double? mark, {required double max}) =>
      (mark?.clamp(0, max).toDouble()) ?? 0.0;
}

/// Grade bands using a `when`-style switch expression.
String calculateGradeLetter(double numericScore) {
  final score = numericScore.clamp(0, 100).toDouble();
  return switch (score) {
    >= 80 => 'A',
    >= 70 => 'B+',
    >= 60 => 'B',
    >= 55 => 'C+',
    >= 50 => 'C',
    >= 45 => 'D+',
    >= 40 => 'D',
    _ => 'F',
  };
}

void exportStudentTemplate(String outputPath) {
  final excel = Excel.createExcel();
  final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
  final sheet = excel[sheetName];

  sheet.appendRow(
    templateHeaders.map((header) => TextCellValue(header)).toList(),
  );
  sheet.appendRow(<CellValue>[
    TextCellValue('Jane Doe'),
    TextCellValue('Computer Science'),
    TextCellValue('MAT12345'),
    TextCellValue('jane@example.com'),
    DoubleCellValue(18),
    DoubleCellValue(8),
    DoubleCellValue(9),
    DoubleCellValue(55),
  ]);

  final outputBytes = excel.save();
  if (outputBytes == null) {
    throw StateError('Unable to encode template workbook.');
  }

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(outputBytes);
}

int processStudentGrades({
  required String inputPath,
  required String outputPath,
}) {
  final students = readStudentRecords(inputPath);
  exportGradedWorkbook(outputPath: outputPath, students: students);
  return students.length;
}

List<StudentRecord> readStudentRecords(String inputPath) {
  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    throw ArgumentError('Input file not found: $inputPath');
  }

  final excel = _decodeExcelWorkbook(inputFile);
  if (excel.tables.isEmpty) {
    throw StateError('No sheets found in $inputPath');
  }

  final sheet = excel.tables.values.first;
  final rows = sheet.rows;
  if (rows.isEmpty) {
    throw StateError('The first sheet is empty.');
  }

  // Keep original header text for user-facing error diagnostics.
  final detectedHeaders = rows.first
      .map((cell) => _cellValueAsText(cell?.value)?.trim())
      .whereType<String>()
      .where((header) => header.isNotEmpty)
      .toList();

  // Parse headers using normalized aliases to support common variants/typos.
  final headers = _buildHeaderIndex(rows.first);
  final nameIndex = _findColumn(headers, <String>['name', 'studentname']);
  final courseIndex = _findColumn(headers, <String>[
    'course',
    'coursename',
    'coursecode',
    'subject',
  ]);
  final matriculeIndex = _findColumn(headers, <String>[
    'matricule',
    'matricle',
    'matriclenumber',
    'matricnumber',
  ]);
  final emailIndex = _findColumn(headers, <String>['email', 'emailaddress']);
  final caIndex = _findColumn(headers, <String>[
    'ca',
    'camarks',
    'ca30',
    'caoutof30',
    'continuousassessment',
    'continuousassessmentmarks',
    'continuousassessment30',
  ]);
  final attendanceIndex = _findColumn(headers, <String>[
    'attendance',
    'attendancemarks',
    'attendance10',
    'attendanceoutof10',
  ]);
  final assignmentIndex = _findColumn(headers, <String>[
    'assignment',
    'assignments',
    'asignment',
    'asignement',
    'assignmentmark',
    'assignmentmarks',
    'asignmentmark',
    'asignmentmarks',
    'asignementmark',
    'asignementmarks',
    'assignmentsmarks',
    'assignment10',
    'asignment10',
    'assignmentoutof10',
    'asignmentoutof10',
    'assignmentscore',
    'asignmentscore',
  ]);
  final examIndex = _findColumn(headers, <String>[
    'exam',
    'exammarks',
    'exam70',
    'examoutof70',
    'examscore',
  ]);

  final missing = <String>[
    if (nameIndex == null) 'Name',
    if (courseIndex == null) 'Course',
    if (matriculeIndex == null) 'Matricule',
    if (emailIndex == null) 'Email',
    if (caIndex == null) 'CA Marks',
    if (attendanceIndex == null) 'Attendance Marks',
    if (assignmentIndex == null) 'Assignment Marks',
    if (examIndex == null) 'Exam Marks',
  ];

  if (missing.isNotEmpty) {
    final headersText = detectedHeaders.isEmpty
        ? 'None'
        : detectedHeaders.join(', ');
    throw StateError(
      'Missing required column(s): ${missing.join(', ')}. '
      'Detected headers (first row): $headersText',
    );
  }

  final students = <StudentRecord>[];
  for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex];
    if (_rowIsEmpty(row)) {
      continue;
    }

    students.add(
      StudentRecord(
        name: _readText(row, nameIndex),
        course: _readText(row, courseIndex),
        matricule: _readText(row, matriculeIndex),
        email: _readText(row, emailIndex),
        caMarks: _readNumber(row, caIndex),
        attendanceMarks: _readNumber(row, attendanceIndex),
        assignmentMarks: _readNumber(row, assignmentIndex),
        examMarks: _readNumber(row, examIndex),
      ),
    );
  }

  return students;
}

void exportGradedWorkbook({
  required String outputPath,
  required List<StudentRecord> students,
}) {
  _writeOutputWorkbook(outputPath, students);
}

String buildDefaultOutputPath(String inputPath, {String suffix = '_graded'}) {
  final resolvedSuffix = suffix.trim().isEmpty ? '_graded' : suffix.trim();
  final directory = p.dirname(inputPath);
  final baseName = p.basenameWithoutExtension(inputPath);
  final extension = p.extension(inputPath).isEmpty
      ? '.xlsx'
      : p.extension(inputPath);
  return p.join(directory, '$baseName$resolvedSuffix$extension');
}

void _writeOutputWorkbook(String outputPath, List<StudentRecord> students) {
  final outputExcel = Excel.createExcel();
  final sheetName = outputExcel.getDefaultSheet() ?? 'Sheet1';
  final outputSheet = outputExcel[sheetName];

  outputSheet.appendRow(<CellValue>[
    TextCellValue('Name'),
    TextCellValue('Course'),
    TextCellValue('Matricule'),
    TextCellValue('Email'),
    TextCellValue('CA Marks'),
    TextCellValue('Attendance Marks'),
    TextCellValue('Assignment Marks'),
    TextCellValue('Exam Marks'),
    TextCellValue('Grade Number (Out of 100)'),
    TextCellValue('Grade Letter'),
  ]);

  for (final student in students) {
    outputSheet.appendRow(<CellValue>[
      TextCellValue(student.safeName),
      TextCellValue(student.safeCourse),
      TextCellValue(student.safeMatricule),
      TextCellValue(student.safeEmail),
      DoubleCellValue(student.safeCaMarks),
      DoubleCellValue(student.safeAttendanceMarks),
      DoubleCellValue(student.safeAssignmentMarks),
      DoubleCellValue(student.safeExamMarks),
      DoubleCellValue(student.totalScore),
      TextCellValue(student.letterGrade),
    ]);
  }

  final bytes = outputExcel.save();
  if (bytes == null) {
    throw StateError('Unable to encode output workbook.');
  }

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
}

Map<String, int> _buildHeaderIndex(List<Data?> headerRow) {
  final map = <String, int>{};

  for (var i = 0; i < headerRow.length; i++) {
    final normalized = _normalizeHeader(_cellValueAsText(headerRow[i]?.value));
    if (normalized.isNotEmpty) {
      map[normalized] = i;
    }
  }

  return map;
}

int? _findColumn(Map<String, int> headers, List<String> aliases) {
  for (final alias in aliases) {
    final index = headers[_normalizeHeader(alias)];
    if (index != null) {
      return index;
    }
  }
  return null;
}

String _normalizeHeader(String? input) =>
    (input ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

bool _rowIsEmpty(List<Data?> row) {
  for (final cell in row) {
    final text = _cellValueAsText(cell?.value);
    if ((text?.trim().isNotEmpty ?? false)) {
      return false;
    }
  }
  return true;
}

String? _readText(List<Data?> row, int? index) {
  if (index == null || index < 0 || index >= row.length) {
    return null;
  }
  return _cellValueAsText(row[index]?.value);
}

double? _readNumber(List<Data?> row, int? index) {
  if (index == null || index < 0 || index >= row.length) {
    return null;
  }
  return _cellValueAsNumber(row[index]?.value);
}

String? _cellValueAsText(CellValue? cellValue) {
  if (cellValue == null) {
    return null;
  }

  return switch (cellValue) {
    TextCellValue(:final value) => value.toString(),
    IntCellValue(:final value) => value.toString(),
    DoubleCellValue(:final value) => value.toString(),
    BoolCellValue(:final value) => value.toString(),
    FormulaCellValue(:final formula) => formula,
    DateCellValue() => cellValue.asDateTimeLocal().toIso8601String(),
    TimeCellValue() => cellValue.asDuration().toString(),
    DateTimeCellValue() => cellValue.asDateTimeLocal().toIso8601String(),
  };
}

double? _cellValueAsNumber(CellValue? cellValue) {
  if (cellValue == null) {
    return null;
  }

  return switch (cellValue) {
    IntCellValue(:final value) => value.toDouble(),
    DoubleCellValue(:final value) => value,
    BoolCellValue(:final value) => value ? 1.0 : 0.0,
    TextCellValue(:final value) => double.tryParse(value.toString().trim()),
    FormulaCellValue(:final formula) => double.tryParse(formula.trim()),
    DateCellValue() => null,
    TimeCellValue() => null,
    DateTimeCellValue() => null,
  };
}

Excel _decodeExcelWorkbook(File inputFile) {
  final inputBytes = inputFile.readAsBytesSync();

  try {
    return Excel.decodeBytes(inputBytes);
  } on Object catch (error) {
    if (!_isInvalidCustomNumFmtIdError(error)) {
      rethrow;
    }

    final repairedBytes = _repairInvalidCustomNumFmtIds(inputBytes);
    try {
      return Excel.decodeBytes(repairedBytes);
    } on Object catch (_) {
      throw StateError(
        'Workbook style issue detected in ${inputFile.path}. '
        'Please re-save this file as .xlsx in Excel and run again.',
      );
    }
  }
}

bool _isInvalidCustomNumFmtIdError(Object error) =>
    error.toString().toLowerCase().contains(
      'custom numfmtid starts at 164 but found a value of',
    );

List<int> _repairInvalidCustomNumFmtIds(List<int> xlsxBytes) {
  // Some third-party exports place invalid custom numFmtId values (<164).
  // Remove those definitions from styles.xml so the workbook can be parsed.
  final archive = ZipDecoder().decodeBytes(xlsxBytes);
  final stylesFile = archive.findFile('xl/styles.xml');
  if (stylesFile == null) {
    return xlsxBytes;
  }

  final content = stylesFile.content;
  if (content is! List<int>) {
    return xlsxBytes;
  }

  final originalXml = utf8.decode(content, allowMalformed: true);
  final repairedXml = _repairStylesXmlNumFmtSection(originalXml);
  if (repairedXml == originalXml) {
    return xlsxBytes;
  }

  final repairedContent = utf8.encode(repairedXml);
  final repairedStylesFile = ArchiveFile(
    stylesFile.name,
    repairedContent.length,
    repairedContent,
  )
    ..mode = stylesFile.mode
    ..lastModTime = stylesFile.lastModTime
    ..isFile = stylesFile.isFile
    ..isSymbolicLink = stylesFile.isSymbolicLink
    ..nameOfLinkedFile = stylesFile.nameOfLinkedFile
    ..comment = stylesFile.comment
    ..compress = stylesFile.compress;

  archive.addFile(repairedStylesFile);
  final rebuiltBytes = ZipEncoder().encode(archive);
  if (rebuiltBytes == null) {
    throw StateError('Unable to repair workbook styles.xml.');
  }
  return rebuiltBytes;
}

String _repairStylesXmlNumFmtSection(String stylesXml) {
  // Target only the <numFmts> block and strip invalid <numFmt .../> entries.
  final numFmtsBlockRegex = RegExp(
    r'<numFmts\b[^>]*>[\s\S]*?</numFmts>',
    multiLine: true,
  );
  final numFmtRegex = RegExp(r'<numFmt\b[^>]*\bnumFmtId="(\d+)"[^>]*/>');

  return stylesXml.replaceAllMapped(numFmtsBlockRegex, (blockMatch) {
    var block = blockMatch.group(0)!;
    block = block.replaceAllMapped(numFmtRegex, (numFmtMatch) {
      final id = int.tryParse(numFmtMatch.group(1) ?? '');
      if (id != null && id < 164) {
        return '';
      }
      return numFmtMatch.group(0)!;
    });

    final remainingNumFmtCount = RegExp(r'<numFmt\b').allMatches(block).length;
    if (remainingNumFmtCount == 0) {
      return '';
    }

    final openTagMatch = RegExp(r'<numFmts\b[^>]*>').firstMatch(block);
    if (openTagMatch == null) {
      return block;
    }

    var openTag = openTagMatch.group(0)!;
    if (RegExp(r'\bcount="\d+"').hasMatch(openTag)) {
      openTag = openTag.replaceAll(
        RegExp(r'\bcount="\d+"'),
        'count="$remainingNumFmtCount"',
      );
    } else {
      openTag = openTag.replaceFirst(
        '>',
        ' count="$remainingNumFmtCount">',
      );
    }

    return block.replaceRange(openTagMatch.start, openTagMatch.end, openTag);
  });
}
