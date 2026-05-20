import 'package:flutter_test/flutter_test.dart';
import 'package:cross_shop/app.dart';

void main() {
  testWidgets('App should render without error', (WidgetTester tester) async {
    await tester.pumpWidget(const CrossShopApp());
    await tester.pump();
    expect(find.text('热门推荐'), findsOneWidget);
  });
}
