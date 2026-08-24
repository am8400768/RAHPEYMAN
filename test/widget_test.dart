import 'package:flutter_test/flutter_test.dart';
import 'package:rahpeyman/main.dart';

void main() {
  testWidgets('RahPeyman app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RahpeymanApp());

    await tester.pumpAndSettle();

    expect(find.byType(RahpeymanApp), findsOneWidget);
  });
}