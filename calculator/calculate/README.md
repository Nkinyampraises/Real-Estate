## Student Grade Workbench (Flutter + CLI)

This project now includes:

1. A **mobile + desktop Flutter GUI** (Android + Windows) for uploading student files, calculating grades, previewing results, and downloading generated files.
2. The original **Dart grading library + CLI** logic, which runs on desktop.

### Supported Input Formats

- Excel: `.xlsx`
- CSV: `.csv`
- HTML table: `.html`
- PDF text table: `.pdf`

### Supported Download Formats

- Excel: `.xlsx`
- CSV: `.csv`
- HTML: `.html`
- PDF: `.pdf`

### Required Columns

- Name
- Course
- Matricule
- Email
- CA Marks
- Attendance Marks
- Exam Marks
- Assignment Marks (optional)

Header matching is flexible and supports common variants/typos.

### Run the GUI

```bash
flutter pub get
flutter run
```

### CLI Usage

Create a template:

```bash
dart run bin/calculate.dart template ./student_template.xlsx
```

Process an uploaded file and auto-create output next to input:

```bash
dart run bin/calculate.dart ./students.xlsx
```

Process with explicit output path (format inferred from extension):

```bash
dart run bin/calculate.dart ./students.csv ./graded_students.pdf
```

### Grade Logic

- If assignment is present:
  - Coursework Raw = `CA + Attendance + Assignment` (out of `50`)
  - Coursework Scaled = `(Coursework Raw / 50) * 30`
- If assignment is missing:
  - Coursework Raw = `CA + Attendance` (out of `40`)
  - Coursework Scaled = `(Coursework Raw / 40) * 30`
- Total = `Coursework Scaled + Exam` (out of `100`)
- Grade letters:
  - `A` >= 80
  - `B+` >= 70
  - `B` >= 60
  - `C+` >= 55
  - `C` >= 50
  - `D+` >= 45
  - `D` >= 40
  - `F` < 40

### Programming Requirements Included

- Data-class operations on `StudentRecord`:
  - `filterStudentsByMinimumScore`
  - `calculateAverageTotalScore`
  - `buildLetterGradeDistribution`
- Custom higher-order function:
  - `reduceStudentRecords`
- Lambda passed to custom HOF:
  - In `calculateAverageTotalScore` and tests
- Collection operation:
  - `where` filter in `filterStudentsByMinimumScore`
