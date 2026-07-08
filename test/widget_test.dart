import 'package:flutter_test/flutter_test.dart';
import 'package:pgold_app/app.dart';

void main() {
  testWidgets('App renders without error', (tester) async {
    await tester.pumpWidget(const PGoldApp());
    expect(find.text('PGold Wallet'), findsOneWidget);
  });
}
