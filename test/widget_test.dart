import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:h2s_echo/main.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: H2sEchoApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(H2sEchoApp), findsOneWidget);
  });
}
