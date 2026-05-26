import 'package:flutter_test/flutter_test.dart';

import 'package:homefundi_app/app.dart';

void main() {
  testWidgets('Homefundi app renders the authentication flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HomefundiApp());
    await tester.pumpAndSettle();

    expect(find.text('HOMEFUNDI'), findsWidgets);
    expect(find.text('Log in to book and track repairs'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
  });
}
