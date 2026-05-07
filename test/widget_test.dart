import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/app.dart';
import 'package:telerehab_app/main.dart';

void main() {
  testWidgets('shows login route', (WidgetTester tester) async {
    await tester.pumpWidget(const AppProviders(child: TelerehabApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
