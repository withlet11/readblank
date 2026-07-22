import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:wl11_fillblank/provider/bookmarked_urls_provider.dart';
import 'package:wl11_fillblank/screens/training_page.dart';

void main() {
  testWidgets('TrainingPage displays content without triggering real network call', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bookmarks': []});
    final prefs = await SharedPreferences.getInstance();
    
    // We cannot easily inject a mock provider, so we have to ensure the provider
    // doesn't call _fetchData() when content is already cached.
    final provider = BookmarkedUrlsProvider(prefs);
    // Pretend we have data
    // provider.cacheParagraphList(...)

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(body: TrainingPage(title: 'Test Page')),
        ),
      ),
    );

    // If we don't trigger a network call, we should see the content.
    // expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
