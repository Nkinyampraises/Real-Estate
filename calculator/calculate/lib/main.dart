import 'dart:io';

import 'package:calculate/calculate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const GradeWorkbenchApp());
}

class GradeWorkbenchApp extends StatelessWidget {
  const GradeWorkbenchApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF0E7490);
    return MaterialApp(
      title: 'Grade Workbench',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: baseColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const GradeWorkbenchScreen(),
    );
  }
}

class GradeWorkbenchScreen extends StatefulWidget {
  const GradeWorkbenchScreen({super.key});

  @override
  State<GradeWorkbenchScreen> createState() => _GradeWorkbenchScreenState();
}

class _GradeWorkbenchScreenState extends State<GradeWorkbenchScreen> {
  // `_uploadedStudents` keeps raw parsed rows; `_gradedStudents` drives exports.
  List<StudentRecord> _uploadedStudents = const <StudentRecord>[];
  List<StudentRecord> _gradedStudents = const <StudentRecord>[];
  String? _uploadedFileName;
  String? _statusMessage;
  String? _savedOutputPath;
  bool _isBusy = false;
  ExportFileType _selectedExportType = ExportFileType.excel;

  bool get _isDesktopPlatform => !kIsWeb && Platform.isWindows;

  @override
  Widget build(BuildContext context) {
    // Dashboard metrics are always computed from the current generated result.
    final passedStudents = filterStudentsByMinimumScore(_gradedStudents);
    final averageScore = calculateAverageTotalScore(_gradedStudents);
    final gradeDistribution = buildLetterGradeDistribution(_gradedStudents);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFE8F4F7),
              Color(0xFFF5EFE7),
              Color(0xFFFAFAFA),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1260),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildControlPanel(),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _statusMessage == null
                          ? const SizedBox.shrink()
                          : _StatusBanner(
                              key: ValueKey<String?>(_statusMessage),
                              message: _statusMessage!,
                            ),
                    ),
                    if (_statusMessage != null) const SizedBox(height: 16),
                    _buildMetrics(
                      totalStudents: _gradedStudents.length,
                      passedStudents: passedStudents.length,
                      averageScore: averageScore,
                      gradeDistribution: gradeDistribution,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Uploaded File Preview',
                      subtitle: _uploadedFileName == null
                          ? 'Upload a source file (PDF, Excel, CSV, HTML).'
                          : 'Source: $_uploadedFileName',
                      child: _buildStudentTable(
                        students: _uploadedStudents,
                        includeComputedColumns: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Generated Grade File Preview',
                      subtitle: _gradedStudents.isEmpty
                          ? 'Click "Calculate Grades" to generate a new result.'
                          : 'Generated result preview is ready.',
                      child: _buildStudentTable(
                        students: _gradedStudents,
                        includeComputedColumns: true,
                      ),
                    ),
                    if (_savedOutputPath != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        'Last saved file: $_savedOutputPath',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Student Grade Workbench',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mobile + Desktop UI for upload, grade calculation, preview, and export '
            '(PDF, Excel, CSV, HTML).',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _pickSourceFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload File'),
              ),
              FilledButton.icon(
                onPressed: _isBusy || _uploadedStudents.isEmpty
                    ? null
                    : _calculateGrades,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculate Grades'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<ExportFileType>(
                  initialValue: _selectedExportType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Download Format',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ExportFileType.values
                      .map(
                        (type) => DropdownMenuItem<ExportFileType>(
                          value: type,
                          child: Text(
                            type.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isBusy
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedExportType = value;
                          });
                        },
                ),
              ),
              FilledButton.icon(
                onPressed: _isBusy || _gradedStudents.isEmpty
                    ? null
                    : _downloadResult,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Generated File'),
              ),
              if (_isBusy)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics({
    required int totalStudents,
    required int passedStudents,
    required double averageScore,
    required Map<String, int> gradeDistribution,
  }) {
    final topGrade = gradeDistribution.entries.isEmpty
        ? 'N/A'
        : gradeDistribution.entries
              .reduce((left, right) => left.value >= right.value ? left : right)
              .key;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        _MetricCard(
          title: 'Students',
          value: '$totalStudents',
          subtitle: 'Rows in generated file',
        ),
        _MetricCard(
          title: 'Passed',
          value: '$passedStudents',
          subtitle: 'Score >= 50',
        ),
        _MetricCard(
          title: 'Average',
          value: _formatNumber(averageScore),
          subtitle: 'Mean total score',
        ),
        _MetricCard(
          title: 'Top Letter',
          value: topGrade,
          subtitle: 'Most frequent grade',
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStudentTable({
    required List<StudentRecord> students,
    required bool includeComputedColumns,
  }) {
    if (students.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E5EA)),
        ),
        child: const Text('No rows to display yet.'),
      );
    }

    final columns = <DataColumn>[
      const DataColumn(label: Text('Name')),
      const DataColumn(label: Text('Course')),
      const DataColumn(label: Text('Matricule')),
      const DataColumn(label: Text('Email')),
      const DataColumn(label: Text('CA')),
      const DataColumn(label: Text('Attendance')),
      const DataColumn(label: Text('Assignment')),
      const DataColumn(label: Text('Exam')),
      if (includeComputedColumns) ...<DataColumn>[
        const DataColumn(label: Text('Coursework /30')),
        const DataColumn(label: Text('Total /100')),
        const DataColumn(label: Text('Grade')),
      ],
    ];

    final rows = students
        .map((student) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(student.safeName)),
              DataCell(Text(student.safeCourse)),
              DataCell(Text(student.safeMatricule)),
              DataCell(Text(student.safeEmail)),
              DataCell(Text(_formatNumber(student.safeCaMarks))),
              DataCell(Text(_formatNumber(student.safeAttendanceMarks))),
              DataCell(Text(_formatNumber(student.safeAssignmentMarks))),
              DataCell(Text(_formatNumber(student.safeExamMarks))),
              if (includeComputedColumns) ...<DataCell>[
                DataCell(Text(_formatNumber(student.courseworkScoreOutOf30))),
                DataCell(Text(_formatNumber(student.totalScore))),
                DataCell(Text(student.letterGrade)),
              ],
            ],
          );
        })
        .toList(growable: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.white.withValues(alpha: 0.92),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns,
            rows: rows,
            headingRowColor: WidgetStatePropertyAll(const Color(0xFFE2ECF0)),
            dataRowMinHeight: 42,
            dataRowMaxHeight: 56,
            columnSpacing: 18,
          ),
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFD5E3E8)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Future<void> _pickSourceFile() async {
    setState(() {
      _isBusy = true;
      _statusMessage = 'Opening file picker...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        withData: true,
        allowedExtensions: <String>['xlsx', 'xls', 'csv', 'html', 'htm', 'pdf'],
      );

      if (result == null || result.files.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _statusMessage = 'File selection cancelled.';
        });
        return;
      }

      final file = result.files.single;
      final bytes = await _readPlatformFileBytes(file);
      final records = readStudentRecordsFromBytes(bytes, fileName: file.name);

      if (!mounted) {
        return;
      }
      setState(() {
        _uploadedFileName = file.name;
        _uploadedStudents = records;
        _gradedStudents = const <StudentRecord>[];
        _savedOutputPath = null;
        _statusMessage =
            'Loaded ${records.length} student row(s) from ${file.name}.';
      });
    } on Object catch (error) {
      _showError('Upload failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void _calculateGrades() {
    if (_uploadedStudents.isEmpty) {
      _showError('Upload a file first before calculating grades.');
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = 'Calculating grades...';
    });

    // StudentRecord computes totals/letters via getters, so cloning is enough.
    final generated = List<StudentRecord>.from(
      _uploadedStudents,
      growable: false,
    );
    setState(() {
      _gradedStudents = generated;
      _statusMessage =
          'Generated ${generated.length} graded row(s). Preview updated.';
      _isBusy = false;
    });
  }

  Future<void> _downloadResult() async {
    if (_gradedStudents.isEmpty) {
      _showError('Run "Calculate Grades" before downloading.');
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = 'Preparing ${_selectedExportType.label} download...';
    });

    try {
      final bytes = await buildGradedFileBytes(
        type: _selectedExportType,
        students: _gradedStudents,
      );
      final extension = _selectedExportType.extension;
      final fileName = 'graded_students.$extension';
      final chosenPath = await _pickSavePath(fileName: fileName);
      final savePath = chosenPath ?? await _fallbackSavePath(fileName);
      final resolvedPath = await _saveDownloadWithConflictRecovery(
        bytes: bytes,
        preferredPath: savePath,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _savedOutputPath = resolvedPath;
        _statusMessage = resolvedPath == savePath
            ? 'Saved generated file to $resolvedPath'
            : 'Original file was in use. Saved as: $resolvedPath';
      });
    } on Object catch (error) {
      _showError('Download failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<List<int>> _readPlatformFileBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    }
    if (file.path == null) {
      throw StateError(
        'Unable to access bytes for file "${file.name}". Try another file.',
      );
    }
    return File(file.path!).readAsBytes();
  }

  Future<String?> _pickSavePath({required String fileName}) async {
    if (_isDesktopPlatform) {
      final extension = p.extension(fileName).replaceFirst('.', '');
      return FilePicker.platform.saveFile(
        dialogTitle: 'Choose where to save your generated file',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: <String>[extension],
      );
    }
    return null;
  }

  Future<String> _fallbackSavePath(String fileName) async {
    final directory = await _resolveFallbackDirectory();
    return p.join(directory.path, fileName);
  }

  Future<String> _saveDownloadWithConflictRecovery({
    required List<int> bytes,
    required String preferredPath,
  }) async {
    try {
      await File(preferredPath).writeAsBytes(bytes, flush: true);
      return preferredPath;
    } on FileSystemException catch (error) {
      if (!_isLockedFileError(error)) {
        rethrow;
      }

      // If the chosen filename is open/locked, auto-save using a timestamp.
      final alternativePath = _buildTimestampedPath(preferredPath);
      await File(alternativePath).writeAsBytes(bytes, flush: true);
      return alternativePath;
    }
  }

  bool _isLockedFileError(FileSystemException error) {
    final osCode = error.osError?.errorCode;
    if (osCode == 32) {
      return true;
    }

    final text = '${error.message} ${error.osError?.message ?? ''}'
        .toLowerCase();
    return text.contains('used by another process') ||
        text.contains('cannot access the file');
  }

  String _buildTimestampedPath(String originalPath) {
    final directory = p.dirname(originalPath);
    final baseName = p.basenameWithoutExtension(originalPath);
    final extension = p.extension(originalPath);
    final now = DateTime.now();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    return p.join(directory, '${baseName}_$stamp$extension');
  }

  Future<Directory> _resolveFallbackDirectory() async {
    // Prefer a user-visible location before falling back to app documents dir.
    if (!kIsWeb && Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        return external;
      }
    }

    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return downloads;
    }

    return getApplicationDocumentsDirectory();
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB91C1C),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3E0E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: const Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDD1D9)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF0F172A)),
      ),
    );
  }
}
