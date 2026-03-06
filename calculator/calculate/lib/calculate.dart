import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

/// Output columns for generated files.
const List<String> gradedOutputHeaders = <String>[
  'Name',
  'Course',
  'Matricule',
  'Email',
  'CA Marks',
  'Attendance Marks',
  'Assignment Marks',
  'Exam Marks',
  'Coursework (Out of 30)',
  'Grade Number (Out of 100)',
  'Grade Letter',
];

enum ExportFileType { excel, csv, html, pdf }

extension ExportFileTypeExtension on ExportFileType {
  String get extension => switch (this) {
    ExportFileType.excel => 'xlsx',
    ExportFileType.csv => 'csv',
    ExportFileType.html => 'html',
    ExportFileType.pdf => 'pdf',
  };

  String get label => switch (this) {
    ExportFileType.excel => 'Excel (.xlsx)',
    ExportFileType.csv => 'CSV (.csv)',
    ExportFileType.html => 'HTML (.html)',
    ExportFileType.pdf => 'PDF (.pdf)',
  };
}

typedef StudentAccumulator<T> = T Function(T current, StudentRecord student);

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

  bool get _hasAssignmentComponent => assignmentMarks != null;

  // Keep legacy getter for callers that inspect raw marks when assignment exists.
  double get courseworkRawOutOf50 =>
      safeCaMarks + safeAttendanceMarks + safeAssignmentMarks;

  // If assignment is missing, scale CA + attendance out of 40 to 30.
  double get courseworkScoreOutOf30 {
    final rawCoursework =
        safeCaMarks +
        safeAttendanceMarks +
        (_hasAssignmentComponent ? safeAssignmentMarks : 0);
    final courseworkDenominator = _hasAssignmentComponent ? 50 : 40;
    return (rawCoursework / courseworkDenominator) * 30;
  }

  double get totalScore {
    final total = courseworkScoreOutOf30 + safeExamMarks;
    return total.clamp(0, 100).toDouble();
  }

  String get letterGrade => calculateGradeLetter(totalScore);

  static double _safeMark(double? mark, {required double max}) =>
      (mark?.clamp(0, max).toDouble()) ?? 0.0;
}

/// Custom higher-order function over [StudentRecord] values.
T reduceStudentRecords<T>(
  List<StudentRecord> students,
  T initialValue,
  StudentAccumulator<T> accumulator,
) {
  var current = initialValue;
  for (final student in students) {
    current = accumulator(current, student);
  }
  return current;
}

/// Collection operation: filter list of students by minimum grade number.
List<StudentRecord> filterStudentsByMinimumScore(
  List<StudentRecord> students, {
  double minimumScore = 50,
}) {
  return students
      .where((student) => student.totalScore >= minimumScore)
      .toList(growable: false);
}

/// Uses a lambda passed to [reduceStudentRecords] to compute average score.
double calculateAverageTotalScore(List<StudentRecord> students) {
  if (students.isEmpty) {
    return 0;
  }

  final total = reduceStudentRecords<double>(
    students,
    0,
    (sum, student) => sum + student.totalScore,
  );
  return total / students.length;
}

/// Another data-class operation: summarize grades by letter.
Map<String, int> buildLetterGradeDistribution(List<StudentRecord> students) {
  return reduceStudentRecords<Map<String, int>>(students, <String, int>{}, (
    distribution,
    student,
  ) {
    distribution.update(
      student.letterGrade,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    return distribution;
  });
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
  final outputBytes = buildStudentTemplateBytes();
  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(outputBytes);
}

List<int> buildStudentTemplateBytes() {
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
  return outputBytes;
}

Future<int> processStudentGrades({
  required String inputPath,
  required String outputPath,
}) async {
  // Pipeline entry point used by the CLI: read -> grade -> write output.
  final students = readStudentRecords(inputPath);
  await exportGradedFile(outputPath: outputPath, students: students);
  return students.length;
}

List<StudentRecord> readStudentRecords(String inputPath) {
  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    throw ArgumentError('Input file not found: $inputPath');
  }

  final bytes = inputFile.readAsBytesSync();
  return readStudentRecordsFromBytes(bytes, fileName: p.basename(inputPath));
}

List<StudentRecord> readStudentRecordsFromBytes(
  List<int> bytes, {
  required String fileName,
}) {
  // Route parsing by extension so UI/CLI can pass any supported format.
  final extension = p.extension(fileName).toLowerCase();
  if (extension == '.xlsx' || extension == '.xls') {
    return _readStudentsFromExcelBytes(bytes, sourceName: fileName);
  }
  if (extension == '.csv') {
    return _readStudentsFromCsvBytes(bytes, sourceName: fileName);
  }
  if (extension == '.html' || extension == '.htm') {
    return _readStudentsFromHtmlBytes(bytes, sourceName: fileName);
  }
  if (extension == '.pdf') {
    return _readStudentsFromPdfBytes(bytes, sourceName: fileName);
  }

  throw ArgumentError(
    'Unsupported input format for "$fileName". '
    'Accepted formats: .xlsx, .csv, .html, .pdf',
  );
}

Future<void> exportGradedWorkbook({
  required String outputPath,
  required List<StudentRecord> students,
}) async {
  await exportGradedFile(
    outputPath: outputPath,
    students: students,
    type: ExportFileType.excel,
  );
}

Future<void> exportGradedFile({
  required String outputPath,
  required List<StudentRecord> students,
  ExportFileType? type,
}) async {
  final fileType = type ?? inferExportFileTypeFromPath(outputPath);
  final bytes = await buildGradedFileBytes(type: fileType, students: students);

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
}

Future<List<int>> buildGradedFileBytes({
  required ExportFileType type,
  required List<StudentRecord> students,
}) async {
  // Keep all output-generation branches in one place.
  return switch (type) {
    ExportFileType.excel => _buildExcelBytes(students),
    ExportFileType.csv => _buildCsvBytes(students),
    ExportFileType.html => _buildHtmlBytes(students),
    ExportFileType.pdf => await _buildPdfBytes(students),
  };
}

ExportFileType inferExportFileTypeFromPath(
  String outputPath, {
  ExportFileType fallback = ExportFileType.excel,
}) {
  return switch (p.extension(outputPath).toLowerCase()) {
    '.xlsx' || '.xls' => ExportFileType.excel,
    '.csv' => ExportFileType.csv,
    '.html' || '.htm' => ExportFileType.html,
    '.pdf' => ExportFileType.pdf,
    _ => fallback,
  };
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

List<StudentRecord> _readStudentsFromExcelBytes(
  List<int> bytes, {
  required String sourceName,
}) {
  final excel = _decodeExcelWorkbookBytes(bytes, sourceName: sourceName);
  if (excel.tables.isEmpty) {
    throw StateError('No sheets found in $sourceName');
  }

  final sheet = excel.tables.values.first;
  final rows = sheet.rows
      .map<List<Object?>>(
        (row) =>
            row.map<Object?>((cell) => cell?.value).toList(growable: false),
      )
      .toList(growable: false);
  return _parseStudentRows(rows, sourceName: sourceName);
}

List<StudentRecord> _readStudentsFromCsvBytes(
  List<int> bytes, {
  required String sourceName,
}) {
  final csvText = utf8.decode(bytes, allowMalformed: true);
  final delimiter = _detectCsvDelimiter(csvText);
  final rows = CsvToListConverter(
    shouldParseNumbers: false,
    fieldDelimiter: delimiter,
    eol: '\n',
  ).convert(csvText);

  final normalizedRows = rows
      .map<List<Object?>>(
        (row) => row.map<Object?>((value) => value).toList(growable: false),
      )
      .toList(growable: false);
  return _parseStudentRows(normalizedRows, sourceName: sourceName);
}

List<StudentRecord> _readStudentsFromHtmlBytes(
  List<int> bytes, {
  required String sourceName,
}) {
  final htmlText = utf8.decode(bytes, allowMalformed: true);
  final rows = _extractRowsFromHtml(htmlText);
  return _parseStudentRows(rows, sourceName: sourceName);
}

List<StudentRecord> _readStudentsFromPdfBytes(
  List<int> bytes, {
  required String sourceName,
}) {
  final text = _extractPdfText(bytes);
  if (text.trim().isEmpty) {
    throw StateError(
      'Unable to extract readable table text from PDF "$sourceName". '
      'Export the source as CSV or Excel for best results.',
    );
  }

  final rows = _extractRowsFromPlainText(text);
  return _parseStudentRows(rows, sourceName: sourceName);
}

List<StudentRecord> _parseStudentRows(
  List<List<Object?>> rows, {
  required String sourceName,
}) {
  if (rows.isEmpty) {
    throw StateError('The first sheet/table is empty in $sourceName.');
  }

  final headerRow = rows.first;
  final detectedHeaders = headerRow
      .map((value) => _valueAsText(value)?.trim())
      .whereType<String>()
      .where((header) => header.isNotEmpty)
      .toList(growable: false);

  // Normalize + alias-match headers so minor naming differences still work.
  final headers = _buildHeaderIndex(headerRow);
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

  // Assignment is intentionally optional; all other fields are required.
  final missing = <String>[
    if (nameIndex == null) 'Name',
    if (courseIndex == null) 'Course',
    if (matriculeIndex == null) 'Matricule',
    if (emailIndex == null) 'Email',
    if (caIndex == null) 'CA Marks',
    if (attendanceIndex == null) 'Attendance Marks',
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

List<int> _buildExcelBytes(List<StudentRecord> students) {
  final outputExcel = Excel.createExcel();
  final sheetName = outputExcel.getDefaultSheet() ?? 'Sheet1';
  final outputSheet = outputExcel[sheetName];

  outputSheet.appendRow(
    gradedOutputHeaders.map((header) => TextCellValue(header)).toList(),
  );

  for (final row in _buildOutputRows(students)) {
    outputSheet.appendRow(<CellValue>[
      TextCellValue(row[0] as String),
      TextCellValue(row[1] as String),
      TextCellValue(row[2] as String),
      TextCellValue(row[3] as String),
      DoubleCellValue(row[4] as double),
      DoubleCellValue(row[5] as double),
      DoubleCellValue(row[6] as double),
      DoubleCellValue(row[7] as double),
      DoubleCellValue(row[8] as double),
      DoubleCellValue(row[9] as double),
      TextCellValue(row[10] as String),
    ]);
  }

  final bytes = outputExcel.save();
  if (bytes == null) {
    throw StateError('Unable to encode output workbook.');
  }

  return bytes;
}

List<int> _buildCsvBytes(List<StudentRecord> students) {
  final rows = <List<Object?>>[
    gradedOutputHeaders,
    ..._buildOutputRows(students),
  ];
  final csvText = const ListToCsvConverter().convert(rows);
  return utf8.encode(csvText);
}

List<int> _buildHtmlBytes(List<StudentRecord> students) {
  final html = _buildHtmlDocument(students);
  return utf8.encode(html);
}

Future<List<int>> _buildPdfBytes(List<StudentRecord> students) async {
  final rows = _buildOutputRows(students);
  final tableData = <List<String>>[
    gradedOutputHeaders,
    ...rows.map(
      (row) => row
          .map((value) {
            if (value is double) {
              return _formatNumberForText(value);
            }
            return value.toString();
          })
          .toList(growable: false),
    ),
  ];

  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) {
        return <pw.Widget>[
          pw.Text(
            'Student Grade Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: tableData.first,
            data: tableData.skip(1).toList(growable: false),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
        ];
      },
    ),
  );
  return document.save();
}

List<List<Object?>> _buildOutputRows(List<StudentRecord> students) {
  // Canonical output projection shared by Excel/CSV/HTML/PDF exporters.
  return students
      .map<List<Object?>>(
        (student) => <Object?>[
          student.safeName,
          student.safeCourse,
          student.safeMatricule,
          student.safeEmail,
          student.safeCaMarks,
          student.safeAttendanceMarks,
          student.safeAssignmentMarks,
          student.safeExamMarks,
          student.courseworkScoreOutOf30,
          student.totalScore,
          student.letterGrade,
        ],
      )
      .toList(growable: false);
}

String _buildHtmlDocument(List<StudentRecord> students) {
  final rowBuffer = StringBuffer();
  for (final row in _buildOutputRows(students)) {
    rowBuffer.writeln('<tr>');
    for (final value in row) {
      final text = value is double ? _formatNumberForText(value) : '$value';
      rowBuffer.writeln('  <td>${_escapeHtml(text)}</td>');
    }
    rowBuffer.writeln('</tr>');
  }

  final headerCells = gradedOutputHeaders
      .map((header) => '<th>${_escapeHtml(header)}</th>')
      .join();

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Student Grade Report</title>
  <style>
    body { font-family: "Segoe UI", Arial, sans-serif; margin: 24px; background: #f7f7f7; color: #1f2937; }
    h1 { margin-bottom: 16px; }
    table { width: 100%; border-collapse: collapse; background: white; }
    th, td { border: 1px solid #d1d5db; padding: 8px; text-align: left; font-size: 13px; }
    th { background: #1f3b4d; color: #ffffff; }
    tr:nth-child(even) td { background: #f9fafb; }
  </style>
</head>
<body>
  <h1>Student Grade Report</h1>
  <table>
    <thead>
      <tr>$headerCells</tr>
    </thead>
    <tbody>
${rowBuffer.toString()}
    </tbody>
  </table>
</body>
</html>
''';
}

String _escapeHtml(String input) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(input);

List<List<Object?>> _extractRowsFromHtml(String htmlText) {
  final document = html_parser.parse(htmlText);
  final table = document.querySelector('table');
  if (table == null) {
    throw StateError(
      'No <table> found in uploaded HTML file. '
      'Please upload an HTML table with header columns.',
    );
  }

  final rows = <List<Object?>>[];
  for (final row in table.querySelectorAll('tr')) {
    final cells = row.querySelectorAll('th, td');
    if (cells.isEmpty) {
      continue;
    }
    rows.add(
      cells
          .map<Object?>((cell) => cell.text.replaceAll('\n', ' ').trim())
          .toList(growable: false),
    );
  }

  return rows;
}

List<List<Object?>> _extractRowsFromPlainText(String text) {
  final lines = const LineSplitter()
      .convert(text)
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
  if (lines.isEmpty) {
    return const <List<Object?>>[];
  }

  final rows = <List<Object?>>[];
  for (final line in lines) {
    final segments = _splitStructuredLine(line);
    if (segments.length < 2) {
      continue;
    }
    rows.add(
      segments
          .map<Object?>((segment) => segment.trim())
          .toList(growable: false),
    );
  }
  return rows;
}

List<String> _splitStructuredLine(String line) {
  if (line.contains('\t')) {
    return line.split('\t');
  }
  if (line.contains(',')) {
    return line.split(',');
  }
  if (line.contains(';')) {
    return line.split(';');
  }
  if (line.contains('|')) {
    return line.split('|');
  }
  return line.split(RegExp(r'\s{2,}'));
}

String _detectCsvDelimiter(String csvText) {
  final firstDataLine = const LineSplitter()
      .convert(csvText)
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');
  if (firstDataLine.isEmpty) {
    return ',';
  }

  final commaCount = ','.allMatches(firstDataLine).length;
  final semicolonCount = ';'.allMatches(firstDataLine).length;
  final tabCount = '\t'.allMatches(firstDataLine).length;
  if (tabCount > commaCount && tabCount > semicolonCount) {
    return '\t';
  }
  if (semicolonCount > commaCount) {
    return ';';
  }
  return ',';
}

Map<String, int> _buildHeaderIndex(List<Object?> headerRow) {
  final map = <String, int>{};
  for (var i = 0; i < headerRow.length; i++) {
    final normalized = _normalizeHeader(_valueAsText(headerRow[i]));
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

bool _rowIsEmpty(List<Object?> row) {
  for (final value in row) {
    final text = _valueAsText(value);
    if ((text?.trim().isNotEmpty ?? false)) {
      return false;
    }
  }
  return true;
}

String? _readText(List<Object?> row, int? index) {
  if (index == null || index < 0 || index >= row.length) {
    return null;
  }
  return _valueAsText(row[index]);
}

double? _readNumber(List<Object?> row, int? index) {
  if (index == null || index < 0 || index >= row.length) {
    return null;
  }
  return _valueAsNumber(row[index]);
}

String? _valueAsText(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is CellValue) {
    return _cellValueAsText(value);
  }

  if (value is DateTime) {
    return value.toIso8601String();
  }

  return value.toString();
}

double? _valueAsNumber(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is CellValue) {
    return _cellValueAsNumber(value);
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString().trim());
}

String _formatNumberForText(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
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

Excel _decodeExcelWorkbookBytes(
  List<int> inputBytes, {
  required String sourceName,
}) {
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
        'Workbook style issue detected in $sourceName. '
        'Please re-save this file as .xlsx in Excel and run again.',
      );
    }
  }
}

bool _isInvalidCustomNumFmtIdError(Object error) => error
    .toString()
    .toLowerCase()
    .contains('custom numfmtid starts at 164 but found a value of');

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
  final repairedStylesFile =
      ArchiveFile(stylesFile.name, repairedContent.length, repairedContent)
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
      openTag = openTag.replaceFirst('>', ' count="$remainingNumFmtCount">');
    }

    return block.replaceRange(openTagMatch.start, openTagMatch.end, openTag);
  });
}

String _extractPdfText(List<int> pdfBytes) {
  // Lightweight text extraction from PDF streams (best-effort only).
  final rawPdf = latin1.decode(pdfBytes, allowInvalid: true);
  final streamRegex = RegExp(
    r'stream[\r\n]+([\s\S]*?)endstream',
    caseSensitive: false,
  );

  final extracted = StringBuffer();
  for (final match in streamRegex.allMatches(rawPdf)) {
    final streamContent = match.group(1);
    if (streamContent == null || streamContent.isEmpty) {
      continue;
    }

    extracted.write(_extractPdfStreamText(streamContent));
    extracted.write('\n');
  }

  return extracted.toString();
}

String _extractPdfStreamText(String streamContent) {
  final streamBytes = latin1.encode(streamContent);
  List<int> decodedBytes;

  try {
    decodedBytes = zlib.decode(streamBytes);
  } on Object {
    decodedBytes = streamBytes;
  }

  final decodedText = latin1.decode(decodedBytes, allowInvalid: true);
  return _extractTextFromPdfOperators(decodedText);
}

String _extractTextFromPdfOperators(String content) {
  final buffer = StringBuffer();
  final singleTextRegex = RegExp(r'\((.*?)\)\s*Tj', dotAll: true);
  final arrayTextRegex = RegExp(r'\[(.*?)\]\s*TJ', dotAll: true);
  final tokenRegex = RegExp(r'\((.*?)\)', dotAll: true);

  // `Tj` writes a single text token.
  for (final match in singleTextRegex.allMatches(content)) {
    final token = match.group(1);
    if (token == null) {
      continue;
    }
    buffer.write(_decodePdfEscapedText(token));
    buffer.write('\n');
  }

  // `TJ` writes an array of text tokens (often used for table-like rows).
  for (final match in arrayTextRegex.allMatches(content)) {
    final arrayContent = match.group(1);
    if (arrayContent == null) {
      continue;
    }

    final rowBuffer = StringBuffer();
    for (final tokenMatch in tokenRegex.allMatches(arrayContent)) {
      final token = tokenMatch.group(1);
      if (token == null) {
        continue;
      }
      rowBuffer.write(_decodePdfEscapedText(token));
      rowBuffer.write(' ');
    }

    final row = rowBuffer.toString().trim();
    if (row.isNotEmpty) {
      buffer.writeln(row);
    }
  }

  return buffer.toString();
}

String _decodePdfEscapedText(String raw) {
  return raw
      .replaceAll(r'\(', '(')
      .replaceAll(r'\)', ')')
      .replaceAll(r'\n', ' ')
      .replaceAll(r'\r', ' ')
      .replaceAll(r'\t', ' ')
      .replaceAll(r'\\', r'\')
      .trim();
}
