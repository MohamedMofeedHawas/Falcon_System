import 'dart:io';
import 'dart:typed_data';

import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/evaluation_report.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'date_utils.dart';

class PdfGenerator {
  static Future<pw.Font> _loadAmiriFont() async {
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<pw.Font> _loadAmiriBoldFont() async {
    final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<pw.Font> _loadTajawalFallbackFont() async {
    final fontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  static Future<Uint8List> generateFromEvaluationReport(
    EvaluationReport e,
  ) async {
    final payload = _payloadFromReport(e);
    _enrichPayloadFromHive(payload, e);
    final ref = (payload['reportNumber'] as String?)?.trim() ?? '';
    if (ref.isEmpty) {
      payload['reportNumber'] =
          'تقييم ${DateUtils.formatToStandard(e.safeEvaluationDate)}';
    }
    return generateEvaluationReport(payload);
  }

  static String suggestedExportFileName(EvaluationReport e) {
    final raw = e.aerodromeName.trim();
    final cleaned = raw
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final base = cleaned.isEmpty
        ? 'تقرير_تقييم_مطار'
        : '${cleaned}_تقرير_تقييم';
    return '$base.pdf';
  }

  static Map<String, dynamic> _payloadFromReport(EvaluationReport e) {
    return {
      'airportName': e.aerodromeName,
      'aerodromeName': e.aerodromeName,
      'icaoCode': "",
      'governorate': "",
      'airportType': "",
      'operationalStatus': "",
      'managerName': e.managerName,
      'managerRank': "",
      'managerEmployeeNumber': e.aerodromeId,
      'headName': e.headName,
      'headRank': "",
      'headSpecialization': "",
      'reportNumber': '',
      'evaluationDate': e.safeEvaluationDate,
      'reinspectionDate': e.reinspectionDate,
      'finalScore': e.totalScore,
      'finalDecision': e.operationalDecision,
      'managerSignaturePng': e.managerSignature,
      'headSignaturePng': e.headSignature,
      'teamMembers': [
        for (final n in e.memberNames)
          {'name': n, 'rank': '-', 'specialization': '-'},
      ],
      'runwayEvaluation': e.runwayEvaluation,
      'taxiwayEvaluation': e.taxiwayEvaluation,
      'apronEvaluation': e.apronEvaluation,
      'rffsEvaluation': e.rffsEvaluation,
      'metEvaluation': e.metEvaluation,
      'navaidsEvaluation': e.navaidsEvaluation,
      'operationalEvaluation': e.operationalEvaluation,
      'smsEvaluation': e.smsEvaluation,
      'documentsEvaluation': e.documentsEvaluation,
    };
  }

  static void _enrichPayloadFromHive(
    Map<String, dynamic> payload,
    EvaluationReport e,
  ) {
    if (!HiveService.isInitialized) return;
    try {
      final ad = HiveService.aerodromeBox.get(e.aerodromeId);
      if (ad != null) {
        final parts = <String>[
          if (ad.arabicName.trim().isNotEmpty) ad.arabicName.trim(),
          if (ad.englishName.trim().isNotEmpty) ad.englishName.trim(),
        ];
        if (parts.isNotEmpty) {
          final display = parts.join(' - ');
          payload['airportName'] = display;
          payload['aerodromeName'] = display;
        }
        payload['icaoCode'] = ad.icaoCode;
        payload['governorate'] = ad.governorate;
        payload['airportType'] = ad.airportType;
        payload['operationalStatus'] = ad.operationalStatus;
      }

      final refDate = DateUtils.formatToStandard(e.safeEvaluationDate);
      final icao = (payload['icaoCode'] as String?)?.trim() ?? '';
      payload['reportNumber'] = icao.isEmpty
          ? 'تقييم $refDate'
          : 'تقييم $icao - $refDate';

      final mgr = HiveService.managerBox.get(e.managerId);
      if (mgr != null) {
        payload['managerName'] = mgr.fullName;
        payload['managerEmployeeNumber'] = mgr.employeeNumber;
        if (mgr.signature != null && mgr.signature!.isNotEmpty) {
          payload['managerSignaturePng'] = mgr.signature;
        }
      }

      final head = HiveService.inspectionHeadBox.get(e.headId);
      if (head != null) {
        payload['headName'] = head.fullName;
        payload['headRank'] = head.rank ?? '';
        payload['headSpecialization'] = head.specialization;
        if (head.signature != null && head.signature!.isNotEmpty) {
          payload['headSignaturePng'] = head.signature;
        }
      }

      final team = <Map<String, dynamic>>[];
      final ids = e.memberIds;
      for (var i = 0; i < ids.length; i++) {
        final id = ids[i];
        final member = HiveService.inspectionMemberBox.get(id);
        if (member != null) {
          team.add({
            'name': member.fullName,
            'rank': member.rank ?? '',
            'specialization': member.specialization,
          });
        } else if (i < e.memberNames.length) {
          team.add({
            'name': e.memberNames[i],
            'rank': '',
            'specialization': '',
          });
        }
      }
      if (team.isNotEmpty) {
        payload['teamMembers'] = team;
      }
    } catch (_) {
      // يبقى التصدير ببيانات التقرير المخزنة في السجل نفسه
    }
  }

  static Map<String, dynamic> _safeMap(dynamic v) {
    if (v == null) return {};
    if (v is Map<String, dynamic>) return v;
    try {
      return Map<String, dynamic>.from(v as Map);
    } catch (_) {
      return {};
    }
  }

  static double _sectionPercentage(Map<String, dynamic> map) {
    var sum = 0.0;
    var n = 0;
    for (final v in map.values) {
      if (v is Map && v['score'] != null) {
        sum += (v['score'] as num).toDouble();
        n++;
      }
    }
    if (n == 0) return 0;
    return (sum / n) * 10;
  }

  static Map<String, dynamic> _sectionPayload(
    String titleAr,
    Map<String, dynamic> map,
  ) {
    final elements = <Map<String, dynamic>>[];
    var sum = 0.0;
    var n = 0;
    for (final e in map.entries) {
      final v = e.value;
      if (v is Map<String, dynamic>) {
        final sc = (v['score'] as num?)?.toDouble() ?? 0;
        sum += sc;
        n++;
        final note = (v['note'] as String?) ?? (v['notes'] as String?) ?? '';
        final subRaw = v['subCriteria'];
        final subParts = <String>[];
        if (subRaw is Map) {
          subRaw.forEach((k, val) {
            if (val == true) subParts.add(k.toString());
          });
        }
        elements.add({
          'name': e.key,
          'subElements': subParts.join('، '),
          'score': sc.round(),
          'note': note,
        });
      }
    }
    final maxScore = n * 10;
    return {
      'name': titleAr,
      'elements': elements,
      'score': sum,
      'maxScore': maxScore,
    };
  }

  static List<Map<String, dynamic>> _buildSectionsFromPayload(
    Map<String, dynamic> reportData,
  ) {
    return [
      _sectionPayload(
        'المدرج - Runway',
        _safeMap(reportData['runwayEvaluation']),
      ),
      _sectionPayload(
        'ممرات التاكسي - Taxiways',
        _safeMap(reportData['taxiwayEvaluation']),
      ),
      _sectionPayload(
        'ساحة الوقوف - Apron',
        _safeMap(reportData['apronEvaluation']),
      ),
      _sectionPayload(
        'الإطفاء والإنقاذ - RFFS',
        _safeMap(reportData['rffsEvaluation']),
      ),
      _sectionPayload(
        'الأرصاد الجوية - MET',
        _safeMap(reportData['metEvaluation']),
      ),
      _sectionPayload(
        'المساعدات الملاحية - NAVAIDs',
        _safeMap(reportData['navaidsEvaluation']),
      ),
      _sectionPayload(
        'الإجراءات التشغيلية',
        _safeMap(reportData['operationalEvaluation']),
      ),
      _sectionPayload(
        'نظام إدارة السلامة - SMS',
        _safeMap(reportData['smsEvaluation']),
      ),
      _sectionPayload(
        'الوثائق والتصاريح',
        _safeMap(reportData['documentsEvaluation']),
      ),
    ];
  }

  static Future<Uint8List> generateEvaluationReport(
    Map<String, dynamic> reportData,
  ) async {
    final amiriFont = await _loadAmiriFont();
    final amiriBoldFont = await _loadAmiriBoldFont();
    final fallbackFont = await _loadTajawalFallbackFont();

    final sections =
        (reportData['sections'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        _buildSectionsFromPayload(reportData);

    final rw = _safeMap(reportData['runwayEvaluation']);
    final tw = _safeMap(reportData['taxiwayEvaluation']);
    final ap = _safeMap(reportData['apronEvaluation']);
    final rf = _safeMap(reportData['rffsEvaluation']);
    final mt = _safeMap(reportData['metEvaluation']);
    final nv = _safeMap(reportData['navaidsEvaluation']);
    final op = _safeMap(reportData['operationalEvaluation']);
    final sm = _safeMap(reportData['smsEvaluation']);
    final dc = _safeMap(reportData['documentsEvaluation']);

    final pRunway = _sectionPercentage(rw);
    final pTaxi = _sectionPercentage(tw);
    final pApron = _sectionPercentage(ap);
    final pRffs = _sectionPercentage(rf);
    final pMet = _sectionPercentage(mt);
    final pNav = _sectionPercentage(nv);
    //final pSvc = (pRffs + pMet + pNav) / 3;

    final pOps = _sectionPercentage(op);
    final pSms = _sectionPercentage(sm);
    final pDoc = _sectionPercentage(dc);

    final weightedRows = <Map<String, Object?>>[
      {'name': '1. المدرج Runway', 'pct': pRunway, 'w': 20},
      {'name': '2. ممرات التاكسي Taxiways', 'pct': pTaxi, 'w': 15},
      {'name': '3. ساحة الوقوف Apron', 'pct': pApron, 'w': 15},
      {'name': '4. الإطفاء والإنقاذ RFFS', 'pct': pRffs, 'w': 15},
      {'name': '5. الأرصاد الجوية MET', 'pct': pMet, 'w': 10},
      {'name': '6. المساعدات الملاحية NAVAIDs', 'pct': pNav, 'w': 10},
      {'name': '7. الإجراءات التشغيلية', 'pct': pOps, 'w': 10},
      {'name': '8. نظام إدارة السلامة SMS', 'pct': pSms, 'w': 10},
      {'name': '9. الوثائق والتصاريح', 'pct': pDoc, 'w': 10},
    ];

    var weightedSum = 0.0;
    for (final r in weightedRows) {
      final pct = r['pct'] as double;
      final w = r['w'] as int;
      weightedSum += pct * w / 100.0;
    }

    final mainSectionPcts = [
      pRunway,
      pTaxi,
      pApron,
      pRffs,
      pNav,
      pMet,
      pOps,
      pSms,
    ];
    var compliant = 0;
    var nonCompliant = 0;
    var followUp = 0;
    for (final p in mainSectionPcts) {
      if (p >= 75) {
        compliant++;
      } else if (p < 60) {
        nonCompliant++;
      } else {
        followUp++;
      }
    }

    final lowSections = <String>[];
    if (pMet < 75 && pMet >= 60) lowSections.add('MET');
    if (pDoc < 75 && pWildlifeLow(op)) lowSections.add('إدارة الحياة البرية');
    final followUpText = followUp == 0 && lowSections.isEmpty
        ? 'لا يوجد'
        : '${followUp > 0 ? '$followUp أقسام بين 60-74٪. ' : ''}${lowSections.join('، ')}';

    final airportName =
        (reportData['airportName'] ?? reportData['aerodromeName'] ?? '')
            .toString();
    final finalScore =
        (reportData['finalScore'] as num?)?.toDouble() ?? weightedSum;
    final finalDecision = (reportData['finalDecision'] ?? '').toString();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: amiriFont,
          bold: amiriBoldFont,
          fontFallback: [fallbackFont],
        ),
        build: (ctx) => [
          _buildHeader(amiriBoldFont, airportName),
          pw.SizedBox(height: 16),
          _buildReportInfo(reportData, amiriFont, amiriBoldFont),
          pw.SizedBox(height: 12),
          _buildAerodromeInfo(reportData, amiriFont, amiriBoldFont),
          pw.SizedBox(height: 12),
          _buildManagerInfo(reportData, amiriFont, amiriBoldFont),
          pw.SizedBox(height: 12),
          _buildTeamInfo(reportData, amiriFont, amiriBoldFont),
          pw.SizedBox(height: 16),
          pw.Text(
            'تفاصيل التقييم حسب الأقسام',
            style: pw.TextStyle(
              font: amiriBoldFont,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          ..._buildSectionWidgets(sections, amiriFont, amiriBoldFont),
          pw.SizedBox(height: 16),
          _buildFinalSummaryBlock(
            finalScore,
            finalDecision,
            amiriFont,
            amiriBoldFont,
          ),
          pw.SizedBox(height: 12),
          _buildSignatures(reportData, amiriFont, amiriBoldFont),
        ],
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: amiriFont,
          bold: amiriBoldFont,
          fontFallback: [fallbackFont],
        ),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'الملحق: ملخص الفحص والقرار',
              style: pw.TextStyle(
                font: amiriBoldFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 14),
            _inspectionResultsTable(
              compliant,
              mainSectionPcts.length,
              nonCompliant,
              followUpText,
              amiriFont,
              amiriBoldFont,
            ),
            pw.SizedBox(height: 14),
            _weightedTotalsTable(
              weightedRows,
              weightedSum,
              amiriFont,
              amiriBoldFont,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'الدرجة النهائية للمطار: ${finalScore.toStringAsFixed(1)}٪ - ${finalDecision.isNotEmpty ? finalDecision : _bandText(finalScore)}',
              style: pw.TextStyle(font: amiriFont, fontSize: 10),
            ),
            pw.SizedBox(height: 14),
            _finalDecisionFormTable(
              airportName,
              reportData,
              finalScore,
              finalDecision,
              amiriFont,
              amiriBoldFont,
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static bool pWildlifeLow(Map<String, dynamic> op) {
    final w = op['wildlife_management'];
    if (w is Map && w['score'] != null) {
      final s = (w['score'] as num).toDouble();
      return s < 7;
    }
    return false;
  }

  static String _bandText(double pct) {
    if (pct >= 90) return 'مستوى آمن بشكل عام';
    if (pct >= 75) return 'مستوى آمن مع ملاحظات';
    if (pct >= 60) return 'مستوى آمن مع ملاحظات تصحيحية';
    return 'يتطلب تدخلاً عاجلاً';
  }

  static pw.Widget _inspectionResultsTable(
    int compliant,
    int totalMain,
    int nonCompliant,
    String followUpText,
    pw.Font font,
    pw.Font bold,
  ) {
    pw.Widget cell(String t, {bool header = false, pw.Font? f}) => pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        t,
        style: pw.TextStyle(
          font: f ?? font,
          fontSize: 9,
          fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'القسم السابع: نتائج الفحص (جدول موحد)',
          style: pw.TextStyle(font: bold, fontSize: 11),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.2),
            1: const pw.FlexColumnWidth(2.8),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                cell('البند', header: true, f: bold),
                cell('النتيجة', header: true, f: bold),
              ],
            ),
            pw.TableRow(
              children: [
                cell(
                  'عدد البنود الرئيسية المطابقة (التقييم 75٪ فأكثر)',
                  f: bold,
                ),
                cell('$compliant من أصل $totalMain بنداً رئيسياً (أقسام 1-6)'),
              ],
            ),
            pw.TableRow(
              children: [
                cell('عدد البنود غير المطابقة (أقل من 60٪)', f: bold),
                cell('$nonCompliant'),
              ],
            ),
            pw.TableRow(
              children: [
                cell('عدد البنود التي تحتاج متابعة (تقييم 60-74٪)', f: bold),
                cell(followUpText),
              ],
            ),
            pw.TableRow(
              children: [
                cell('إجراءات التصحيح المطلوبة', f: bold),
                cell(
                  'يُستخرج من ملاحظات العناصر ذات الدرجة المنخفضة في التقرير التفصيلي.',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                cell('التوصيات', f: bold),
                cell(
                  'متابعة تنفيذ البنود غير المطابقة خلال المهلة المحددة وإعادة التقييم.',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                cell('القرار النهائي', f: bold),
                cell(
                  'يُستند إلى الدرجة المرجحة والفئات: صالح (90٪ فأكثر)، يحتاج تصحيح (60٪-89٪)، غير صالح (أقل من 60٪).',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _weightedTotalsTable(
    List<Map<String, Object?>> rows,
    double airportTotal,
    pw.Font font,
    pw.Font bold,
  ) {
    pw.Widget c(String t, {bool h = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        t,
        style: pw.TextStyle(
          font: h ? bold : font,
          fontSize: 9,
          fontWeight: h ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          c('القسم', h: true),
          c('التقييم المئوي', h: true),
          c('الوزن المقترح', h: true),
          c('الدرجة المرجحة', h: true),
        ],
      ),
      ...rows.map((r) {
        final pct = r['pct'] as double;
        final w = r['w'] as int;
        final wt = pct * w / 100.0;
        return pw.TableRow(
          children: [
            c(r['name'] as String),
            c('${pct.toStringAsFixed(1)}٪'),
            c('$w٪'),
            c(wt.toStringAsFixed(2)),
          ],
        );
      }),
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          c('المجموع', h: true),
          c('100٪', h: true),
          c('-', h: true),
          c(airportTotal.toStringAsFixed(2), h: true),
        ],
      ),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'التوتال الإجمالي للمطار (جميع الأقسام السبعة)',
          style: pw.TextStyle(font: bold, fontSize: 11),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.4),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.1),
            3: const pw.FlexColumnWidth(1.1),
          },
          children: tableRows,
        ),
      ],
    );
  }

  static pw.Widget _finalDecisionFormTable(
    String airportName,
    Map<String, dynamic> reportData,
    double finalScorePct,
    String decisionText,
    pw.Font font,
    pw.Font bold,
  ) {
    final evalDate = reportData['evaluationDate'] is DateTime
        ? DateUtils.formatToArabic(reportData['evaluationDate'] as DateTime)
        : '';
    final team =
        (reportData['teamMembers'] as List<dynamic>?)
            ?.map((e) => (e is Map ? e['name'] : e).toString())
            .where((s) => s.isNotEmpty)
            .join('، ') ??
        '';

    pw.TableRow formRow(String label, String value) => pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(font: bold, fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value.isEmpty ? '................' : value,
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
      ],
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'نموذج قرار الفحص النهائي (جاهز للتوقيع)',
          style: pw.TextStyle(font: bold, fontSize: 11),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.4),
            1: const pw.FlexColumnWidth(2.6),
          },
          children: [
            formRow('اسم المطار', airportName),
            formRow('تاريخ الفحص', evalDate),
            formRow('فريق الفحص', team),
            formRow('الدرجة الإجمالية', '${finalScorePct.toStringAsFixed(1)}٪'),
            formRow(
              'البنود الحرجة غير المطابقة (أقل من 60٪)',
              '1. ........   2. ........',
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'القرار النهائي',
                    style: pw.TextStyle(font: bold, fontSize: 9),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    '[ ] صالح (90٪ فأكثر)\n[ ] يحتاج تصحيح (من 60٪ إلى 89٪)\n[ ] غير صالح (أقل من 60٪)\n$decisionText',
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                ),
              ],
            ),
            formRow('مهلة التصحيح', '........ يوم'),
            formRow(
              'تاريخ إعادة الفحص',
              reportData['reinspectionDate'] is DateTime
                  ? DateUtils.formatToArabic(
                      reportData['reinspectionDate'] as DateTime,
                    )
                  : '',
            ),
            formRow(
              'توقيع قائد المطار',
              _str(reportData['managerName']).isEmpty
                  ? '................'
                  : _str(reportData['managerName']),
            ),
            formRow(
              'توقيع رئيس لجنة الفحص',
              _str(reportData['headName']).isEmpty
                  ? '................'
                  : _str(reportData['headName']),
            ),
          ],
        ),
      ],
    );
  }

  static List<pw.Widget> _buildSectionWidgets(
    List<Map<String, dynamic>> sections,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final out = <pw.Widget>[];
    for (final section in sections) {
      out.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                section['name']?.toString() ?? '',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              _buildSectionTable(section, font, boldFont),
              pw.SizedBox(height: 6),
              _buildSectionSummary(section, font, boldFont),
            ],
          ),
        ),
      );
      out.add(pw.SizedBox(height: 10));
    }
    return out;
  }

  static pw.Widget _buildFinalSummaryBlock(
    double finalScore,
    String finalDecision,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
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
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              '${finalScore.toStringAsFixed(1)}٪',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              finalDecision,
              style: pw.TextStyle(font: boldFont, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader(pw.Font font, String airportTitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 1.5, color: PdfColors.grey800),
        ),
      ),
      child: pw.Column(
        children: [
        
          

          if (airportTitle.trim().isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                "تقرير تقييم مطار  ( ${airportTitle.trim()} )",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildReportInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final dt = reportData['evaluationDate'];
    final dateStr = dt is DateTime ? DateUtils.formatToArabic(dt) : '';

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'اسم المطار:',
            _str(reportData['airportName'] ?? reportData['aerodromeName']),
            font,
            boldFont,
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow(
            'رمز ICAO:',
            _str(reportData['icaoCode']),
            font,
            boldFont,
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow('تاريخ الفحص:', dateStr, font, boldFont),
          pw.SizedBox(height: 6),
          _buildInfoRow(
            'مرجع التقرير:',
            _str(reportData['reportNumber']),
            font,
            boldFont,
          ),
        ],
      ),
    );
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  static pw.Widget _buildAerodromeInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات المطار',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'المحافظة:',
            _str(reportData['governorate']),
            font,
            boldFont,
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow(
            'نوع المطار:',
            _str(reportData['airportType']),
            font,
            boldFont,
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow(
            'حالة التشغيل:',
            _str(reportData['operationalStatus']),
            font,
            boldFont,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildManagerInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'قائد المطار',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'الاسم:',
            _str(reportData['managerName']),
            font,
            boldFont,
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow(
            'الرتبة:',
            _str(reportData['managerRank']),
            font,
            boldFont,
          ),
          if (_str(reportData['managerEmployeeNumber']).isNotEmpty) ...[
            pw.SizedBox(height: 6),
            _buildInfoRow(
              'الرقم الوظيفي:',
              _str(reportData['managerEmployeeNumber']),
              font,
              boldFont,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildTeamInfo(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final teamMembers = reportData['teamMembers'] as List<dynamic>? ?? [];

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'لجنة الفحص والتفتيش',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (_str(reportData['headName']).isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'رئيس اللجنة: ${_str(reportData['headName'])}'
              '${_str(reportData['headRank']).isNotEmpty ? ' - ${_str(reportData['headRank'])}' : ''}'
              '${_str(reportData['headSpecialization']).isNotEmpty ? ' - ${_str(reportData['headSpecialization'])}' : ''}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            'أعضاء اللجنة (من السجلات)',
            style: pw.TextStyle(font: boldFont, fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          ...teamMembers.map((member) {
            final m = member is Map ? member : {'name': member.toString()};
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                '- ${_str(m['name'])} - ${_str(m['rank'])} - ${_str(m['specialization'])}',
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTable(
    Map<String, dynamic> section,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final elements = section['elements'] as List<dynamic>? ?? [];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(88),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FixedColumnWidth(44),
        3: const pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('العنصر', boldFont, isHeader: true),
            _buildTableCell('المعايير المنجزة', boldFont, isHeader: true),
            _buildTableCell('الدرجة', boldFont, isHeader: true),
            _buildTableCell('ملاحظات', boldFont, isHeader: true),
          ],
        ),
        ...elements.map((element) {
          final el = element as Map<String, dynamic>;
          return pw.TableRow(
            children: [
              _buildTableCell(_str(el['name']), font),
              _buildTableCell(_str(el['subElements']), font),
              _buildTableCell('${el['score'] ?? 0}/10', font),
              _buildTableCell(_str(el['note']), font),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildSectionSummary(
    Map<String, dynamic> section,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final score = (section['score'] as num?)?.toDouble() ?? 0;
    final maxScore = (section['maxScore'] as num?)?.toDouble() ?? 0;
    final percentage = maxScore > 0 ? (score / maxScore * 100) : 0.0;
    final classification = _getClassification(percentage);

    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            'المجموع: ${score.toStringAsFixed(0)} / ${maxScore.toStringAsFixed(0)}',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            'النسبة: ${percentage.toStringAsFixed(1)}٪',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            'التصنيف: $classification',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static Uint8List? _uint8Signature(dynamic v) {
    if (v is Uint8List && v.isNotEmpty) return v;
    return null;
  }

  static pw.Widget _signatureImageOrLine(
    Uint8List? png,
    double maxH,
    pw.Font font,
  ) {
    if (png != null) {
      return pw.SizedBox(
        height: maxH,
        child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
      );
    }
    return pw.Container(
      height: maxH * 0.65,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      child: pw.Text(
        '........',
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
      ),
    );
  }

  static pw.Widget _signatureCard({
    required String title,
    required String name,
    required String subtitle,
    required Uint8List? png,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey600, width: 0.7),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
            pw.SizedBox(height: 6),
            _signatureImageOrLine(png, 52, font),
            pw.SizedBox(height: 6),
            pw.Container(height: 0.6, color: PdfColors.grey500),
            pw.SizedBox(height: 4),
            pw.Text(
              name,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: boldFont, fontSize: 9),
            ),
            if (subtitle.isNotEmpty)
              pw.Text(
                subtitle,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSignatures(
    Map<String, dynamic> reportData,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final headSubtitle = [
      if (_str(reportData['headRank']).isNotEmpty) _str(reportData['headRank']),
      if (_str(reportData['headSpecialization']).isNotEmpty)
        _str(reportData['headSpecialization']),
    ].join(' | ');

    final teamMembers = reportData['teamMembers'] as List<dynamic>? ?? [];

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'التوقيعات والاعتماد',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'توقيعات الصور من سجلات قائد المطار ورئيس اللجنة في قاعدة البيانات عند التوفر.',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _signatureCard(
                title: 'قائد المطار',
                name: _str(reportData['managerName']),
                subtitle: _str(reportData['managerEmployeeNumber']).isNotEmpty
                    ? 'رقم: ${_str(reportData['managerEmployeeNumber'])}'
                    : '',
                png: _uint8Signature(reportData['managerSignaturePng']),
                font: font,
                boldFont: boldFont,
              ),
              pw.SizedBox(width: 12),
              _signatureCard(
                title: 'رئيس لجنة الفحص',
                name: _str(reportData['headName']),
                subtitle: headSubtitle,
                png: _uint8Signature(reportData['headSignaturePng']),
                font: font,
                boldFont: boldFont,
              ),
            ],
          ),
          if (teamMembers.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              'أعضاء لجنة الفحص (أسماء معتمدة من السجلات)',
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final member in teamMembers)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey500),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(() {
                      final m = member is Map
                          ? member
                          : {'name': member.toString()};
                      final r = _str(m['rank']);
                      final s = _str(m['specialization']);
                      final n = _str(m['name']);
                      final bits = <String>[n];
                      if (r.isNotEmpty) bits.add(r);
                      if (s.isNotEmpty) bits.add(s);
                      return bits.join(' | ');
                    }(), style: pw.TextStyle(font: font, fontSize: 8)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _getClassification(double percentage) {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 75) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'غير آمن';
  }

  static Future<String> savePdfToDesktop(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final directory = await getDesktopPath();
    final file = File('$directory/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

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

  static Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'تقرير_التقييم',
    );
  }
}
