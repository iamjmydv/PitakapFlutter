import 'package:flutter_test/flutter_test.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/main.dart';

void main() {
  testWidgets('App renders the app name', (WidgetTester tester) async {
    await tester.pumpWidget(const PitakapApp());

    expect(find.text(Strings.appName), findsOneWidget);
  });
}
