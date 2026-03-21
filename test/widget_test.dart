import 'package:flutter_test/flutter_test.dart';
import 'package:triageflow_mobile/main.dart';

void main() {
  testWidgets('TriageFlow AI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TriageFlowApp());
    expect(find.text('TriageFlow'), findsOneWidget);
  });
}
