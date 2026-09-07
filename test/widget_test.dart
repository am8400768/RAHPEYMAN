import 'package:flutter_test/flutter_test.dart';
import 'package:rahpeyman/main.dart';

void main() {
  testWidgets('RahPeyman app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RahpeymanApp());

    // The startup screen has an infinite spinner + a 2.6s timer,
    // so pump a fixed duration instead of pumpAndSettle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(RahpeymanApp), findsOneWidget);
  });
}
