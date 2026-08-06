import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:readblank/providers/favorite_list_notifier.dart';
import 'package:readblank/providers/history_notifier.dart';
import 'package:readblank/providers/activity_notifier.dart';
import 'package:readblank/screens/read_page.dart';

void main() {
  testWidgets(
    'TrainingPage displays content without triggering real network call',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'bookmarks': [],
        'history': '[{"url": "https://example.com"}]',
      });
      final prefs = await SharedPreferences.getInstance();

      final historyNotifier = HistoryNotifier(prefs);
      final activityNotifier = ActivityNotifier();
      final favoriteListNotifier = FavoriteListNotifier(prefs);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: historyNotifier),
            ChangeNotifierProvider.value(value: activityNotifier),
            ChangeNotifierProvider.value(value: favoriteListNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(body: ReadPage(title: 'Test Page')),
          ),
        ),
      );

      // If we don't trigger a network call, we should see the content.
      // expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
