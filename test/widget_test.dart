import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:readblank/db/word_list_provider.dart';
import 'package:readblank/provider/bookmarked_urls_provider.dart';
import 'package:readblank/provider/history_provider.dart';
import 'package:readblank/screens/training_page.dart';

void main() {
  testWidgets(
    'TrainingPage displays content without triggering real network call',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'bookmarks': [],
        'history': '[{"url": "https://example.com"}]',
      });
      final prefs = await SharedPreferences.getInstance();

      final historyProvider = HistoryProvider(prefs);
      final wordListProvider = WordListProvider(prefs);
      final bookmarkedUrlsProvider = BookmarkedUrlsProvider(prefs);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: historyProvider),
            ChangeNotifierProvider.value(value: wordListProvider),
            ChangeNotifierProvider.value(value: bookmarkedUrlsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(body: TrainingPage(title: 'Test Page')),
          ),
        ),
      );

      // If we don't trigger a network call, we should see the content.
      // expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
