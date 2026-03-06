## Student Grade Calculator (Dart)

This CLI app helps you:

1. Export a fillable Excel template.
2. Import your filled student sheet.
3. Generate a new Excel file with calculated grade number (out of 100) and
grade letter.

### Required Columns

The input Excel sheet must contain these fields in the first row:

- Name
- Course
- Matricule
- Email
- CA Marks
- Attendance Marks
- Assignment Marks
- Exam Marks

Header matching is flexible. Common variations and typos are accepted, for
example:

- `Matricle` (for `Matricule`)
- `Attendance marks`
- `Asignment marks`
- `Exam /70`, `CA /30`, `Assignment /10`

### Commands

Create a template:

```bash
dart run bin/calculate.dart template ./student_template.xlsx
```

You can also create template with default name in current folder:

```bash
dart run bin/calculate.dart template
```

Process a filled sheet and auto-create output next to it:

```bash
dart run bin/calculate.dart "C:/path/from/your/computer/students.xlsx"
```

Process with explicit output path:

```bash
dart run bin/calculate.dart ./students.xlsx ./graded_students.xlsx
```

### Terminal Output

When you process a file, the app prints:

- `INPUT EXCEL FILE` absolute path
- `INPUT EXCEL DATA` (rows from the imported workbook)
- `OUTPUT EXCEL FILE` absolute path
- `OUTPUT EXCEL DATA` (rows with computed coursework, grade number, grade letter)
- a final completion line: `Process complete. You can close this terminal now.`

### Grade Logic

- Coursework Raw = `CA Marks + Attendance Marks + Assignment Marks` (out of `50`)
- Coursework Scaled = `(Coursework Raw / 50) * 30` (out of `30`)
- Grade Number = `Coursework Scaled + Exam Marks` (out of `100`)
- Letter grade:
- `A` for `>= 80`
  - `B+` for `>= 70`
  - `B` for `>= 60`
  - `C+` for `>= 55`
  - `C` for `>= 50`
  - `D+` for `>= 45`
  - `D` for `>= 40`
  - `F` for `< 40`

### Null Safety / Edge Cases

- Missing marks are treated as `0` using null-safe defaults.
- Negative marks are clamped to `0`.
- Marks above allowed limits are clamped:
  - `CA` max `30`
  - `Attendance` max `10`
  - `Assignment` max `10`
  - `Exam` max `70`
- Empty text fields fall back to safe values (`Unknown Student` / `N/A`).
- Some malformed Excel style metadata is auto-repaired during import (for
  files that trigger `custom numFmtId starts at 164...`).

### Troubleshooting

- If you see `Missing required column(s)`, check the first row headers.
  The error message also prints all detected headers.
- If PowerShell shows `>>`, your quote is not closed. Re-run with balanced
  quotes:

```powershell
dart run bin/calculate.dart "C:\Users\YourName\Desktop\Book1.xlsx"
```
