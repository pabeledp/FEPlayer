import 'package:flutter_test/flutter_test.dart';
import 'package:fe_player/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FEPlayerApp());
  });
}
