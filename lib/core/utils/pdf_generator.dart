import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'date_utils.dart';

class PdfGenerator {
  // Load Amiri font for Arabic text
  static Future<pw.Font> _loadAmiriFont() async {
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<pw.Font> _loadAmiriBoldFont() async {
    final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    return pw.Font.ttf(fontData);
  }

  // Generate evaluation report PDF
  static Future<Uint8List> generateEvaluationReport(
    Map<String, dynamic> reportData,
  ) async {
    final amiriFont = await _loadAmiriFont();
    final amiriBoldFont = await _loadAmiriBoldFont();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(amiriBoldFont),
              pw.SizedBox(height: 20),

              // Report Info
              _buildReportInfo(reportData, amiriFont, amiriBoldFont),
              pw.SizedBox(height: 20),

              // Aerodrome Info
              _buildAerodromeInfo(reportData, amiriFont, amiriBoldFont),
              pw.SizedBox(height: 20),

              // Manager Info
              _buildManagerInfo(reportData, amiriFont, amiriBoldFont),
              pw.SizedBox(height: 20),

              // Team Info
              _buildTeamInfo(reportData, amiriFont, amiriBoldFont),
              pw.SizedBox(height: 20),

              // Evaluation Sections
              ..._buildEvaluationSections(reportData, amiriFont, amiriBoldFont),

              pw.SizedBox(height: 20),

              // Final Summary
              _buildFinalSummary(reportData, amiriFont, amiriBoldFont),

              pw.SizedBox(height: 20),

              // Signatures
              _buildSignatures(reportData, amiriFont, amiriBoldFont),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Build header section
  static pw.Widget _buildHeader(pw.Font font) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'جمهورية مصر العربية',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'القوات الجوية المصرية',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'الكلية الجوية — قسم فحص المطارات',
            style: pw.TextStyle(font: font, fontSize: 14),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'تقرير تقييم المطار',
            style: pw.TextStyle(
              font: font,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Build report info section
  static pw.Widget _buildReportInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'اسم المطار:',
            reportData['airportName'] ?? '',
            font,
            boldFont,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'رمز ICAO:',
            reportData['icaoCode'] ?? '',
            font,
            boldFont,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'تاريخ الفحص:',
            DateUtils.formatToArabic(
              reportData['evaluationDate'] ?? DateTime.now(),
            ),
            font,
            boldFont,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'رقم التقرير:',
            reportData['reportNumber'] ?? '',
            font,
            boldFont,
          ),
        ],
      ),
    );
  }

  // Build aerodrome info section
  static pw.Widget _buildAerodromeInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات المطار',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow(
            'المحافظة:',
            reportData['governorate'] ?? '',
            font,
            boldFont,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'نوع المطار:',
            reportData['airportType'] ?? '',
            font,
            boldFont,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'حالة التشغيل:',
            reportData['operationalStatus'] ?? '',
            font,
            boldFont,
          ),
        ],
      ),
    );
  }

  // Build manager info section
  static pw.Widget _buildManagerInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'قائد المطار',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow(
            'الاسم:',
            reportData['managerName'] ?? '',
            font,
            boldFont,
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'الرتبة:',
            reportData['managerRank'] ?? '',
            font,
            boldFont,
          ),
        ],
      ),
    );
  }

  // Build team info section
  static pw.Widget _buildTeamInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final teamMembers = reportData['teamMembers'] as List<dynamic>? ?? [];

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'فريق الفحص',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...teamMembers.map((member) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                '• ${member['name']} - ${member['rank']} - ${member['specialization']}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Build evaluation sections
  static List<pw.Widget> _buildEvaluationSections(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final sections = reportData['sections'] as List<dynamic>? ?? [];
    final widgets = <pw.Widget>[];

    for (final section in sections) {
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                section['name'] ?? '',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildSectionTable(section, font, boldFont),
              pw.SizedBox(height: 12),
              _buildSectionSummary(section, font, boldFont),
            ],
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 16));
    }

    return widgets;
  }

  // Build section table
  static pw.Widget _buildSectionTable(
    Map<String, dynamic> section,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final elements = section['elements'] as List<dynamic>? ?? [];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(150),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('العنصر', boldFont, isHeader: true),
            _buildTableCell('العناصر الفرعية', boldFont, isHeader: true),
            _buildTableCell('الدرجة', boldFont, isHeader: true),
            _buildTableCell('ملاحظات', boldFont, isHeader: true),
          ],
        ),
        // Rows
        ...elements.map((element) {
          return pw.TableRow(
            children: [
              _buildTableCell(element['name'] ?? '', font),
              _buildTableCell(element['subElements'] ?? '', font),
              _buildTableCell('${element['score'] ?? 0}/10', font),
              _buildTableCell(element['note'] ?? '', font),
            ],
          );
        }),
      ],
    );
  }

  // Build section summary
  static pw.Widget _buildSectionSummary(
    Map<String, dynamic> section,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final score = section['score'] ?? 0;
    final maxScore = section['maxScore'] ?? 0;
    final percentage = maxScore > 0 ? (score / maxScore * 100) : 0;
    final classification = _getClassification(percentage);

    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            'المجموع: $score / $maxScore',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            'النسبة: ${percentage.toStringAsFixed(1)}%',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            'التصنيف: $classification',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Build final summary
  static pw.Widget _buildFinalSummary(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final finalScore = reportData['finalScore'] ?? 0.0;
    final finalDecision = reportData['finalDecision'] ?? '';

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'النتيجة النهائية',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(
              '${finalScore.toStringAsFixed(1)}%',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(
              finalDecision,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build signatures section
  static pw.Widget _buildSignatures(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'التوقيعات',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'توقيع قائد المطار',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.SizedBox(height: 40),
                    pw.Container(height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      reportData['managerName'] ?? '',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'توقيع رئيس لجنة التفتيش',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.SizedBox(height: 40),
                    pw.Container(height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      reportData['headName'] ?? '',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build info row
  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12)),
        ),
      ],
    );
  }

  // Build table cell
  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // Get classification text
  static String _getClassification(double percentage) {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 75) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'غير آمن';
  }

  // Save PDF to desktop
  static Future<String> savePdfToDesktop(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final directory = await getDesktopPath();
    final file = File('$directory/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  // Get desktop path based on platform
  static Future<String> getDesktopPath() async {
    if (Platform.isWindows) {
      return (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isMacOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else if (Platform.isLinux) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  // Print PDF directly
  static Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'تقرير_التقييم',
    );
  }
}
