import 'package:falcon_system/core/utils/pdf_generator.dart';
import 'package:falcon_system/data/models/evaluation_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generateFromEvaluationReport completes', (tester) async {
    await tester.runAsync(() async {
      final e = EvaluationReport(
        id: 'test-id',
        aerodromeId: 'a1',
        aerodromeName: 'مطار تجريبي',
        managerId: 'm1',
        managerName: 'مدير',
        headId: 'h1',
        headName: 'رئيس',
        totalScore: 85,
        operationalDecision: 'صالح',
      );
      final bytes = await PdfGenerator.generateFromEvaluationReport(e);
      expect(bytes.isNotEmpty, true);
    });
  });
}
