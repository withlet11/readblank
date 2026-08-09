/*
 * main.dart
 *
 * Copyright 2026 Yasuhiro Yamakawa <withlet11@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:readblank/screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readblank/screens/activity_page.dart';

import 'drawers/content_selector_drawers.dart';
import 'l10n/app_localizations.dart';
import 'providers/activity_notifier.dart';
import 'providers/app_preferences_notifier.dart';
import 'providers/link_list_notifier.dart';
import 'screens/read_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppPreferencesNotifier()),
        ChangeNotifierProvider(create: (_) => LinkListNotifier(sharedPrefs)),
        ChangeNotifierProvider(create: (_) => ActivityNotifier()),
      ],
      child: ReadBlank(),
    ),
  );
}

class ReadBlank extends StatelessWidget {
  const ReadBlank({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferencesNotifier>();

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lightGreen,
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.lightGreen,
      brightness: Brightness.dark,
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      listTileTheme: ListTileThemeData(
        selectedTileColor: lightColorScheme.primaryContainer,
        selectedColor: lightColorScheme.onPrimaryContainer,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      listTileTheme: ListTileThemeData(
        selectedTileColor: darkColorScheme.secondaryContainer,
        selectedColor: darkColorScheme.onSecondaryContainer,
      ),
    );

    return MaterialApp(
      title: 'ReadBlank',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: prefs.locale,
      supportedLocales: [Locale('en'), Locale('hu'), Locale('ja')],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: prefs.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(prefs.fontSizeFactor)),
          child: child!,
        );
      },
      home: const MainPage(title: 'ReadBlank'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LinkListNotifier>().fetchAllContents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LinkListNotifier, ActivityNotifier>(
      builder: (context, linkListNotifier, activityNotifier, child) {
        if (linkListNotifier.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 5)),
          );
        }

        return Scaffold(
          appBar: _selectedIndex == 0
              ? _buildAppBarForRead(linkListNotifier)
              : _selectedIndex == 1
              ? _buildAppBarForLog(activityNotifier)
              : _buildAppBarForSettings(),
          body: _selectedIndex == 0
              ? const ReadPage(key: Key('ReadPage'), title: 'Read')
              : _selectedIndex == 1
              ? const ActivityPage(key: Key('ActivityPage'), title: 'Activity')
              : const SettingsPage(key: Key('SettingsPage'), title: 'Settings'),
          endDrawer: const ContentSelectorDrawers(),
          endDrawerEnableOpenDragGesture: false,
          bottomNavigationBar: _buildNavigationBar(),
        );
      },
    );
  }

  AppBar _buildAppBarForRead(LinkListNotifier linkListNotifier) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            linkListNotifier.currentTitle ?? linkListNotifier.currentUrl,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            linkListNotifier.currentDomainName,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      automaticallyImplyActions: false,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.add_link_outlined),
            onPressed: _addLink,
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBarForLog(ActivityNotifier activityNotifier) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(l10n.activityNavButton)],
      ),
      automaticallyImplyActions: false,
      actions: [
        IconButton(
          icon: Icon(Icons.looks_one_outlined),
          onPressed: activityNotifier.viewMode == ActivityViewMode.daily
              ? null
              : () => activityNotifier.viewMode = ActivityViewMode.daily,
        ),
        IconButton(
          icon: Icon(Icons.calendar_view_week_outlined),
          onPressed: activityNotifier.viewMode == ActivityViewMode.weekly
              ? null
              : () => activityNotifier.viewMode = ActivityViewMode.weekly,
        ),
        IconButton(
          icon: Icon(Icons.calendar_view_month_outlined),
          onPressed: activityNotifier.viewMode == ActivityViewMode.monthly
              ? null
              : () => activityNotifier.viewMode = ActivityViewMode.monthly,
        ),
      ],
    );
  }

  AppBar _buildAppBarForSettings() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(l10n.settingsNavButton)],
      ),
      automaticallyImplyActions: false,
      actions: [],
    );
  }

  NavigationBar _buildNavigationBar() {
    final l10n = AppLocalizations.of(context)!;

    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      destinations: [
        NavigationDestination(
          label: l10n.readNavButton,
          icon: const Icon(Icons.article_outlined),
        ),
        NavigationDestination(
          label: l10n.activityNavButton,
          icon: const Icon(Icons.bar_chart),
        ),
        NavigationDestination(
          label: l10n.settingsNavButton,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  void _addLink() async {
    final l10n = AppLocalizations.of(context)!;
    final linkListNotifier = context.read<LinkListNotifier>();
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? copiedText = data?.text;
    if (copiedText != null && copiedText.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(copiedText));
        if (response.statusCode == 200) {
          final document = parser.parse(response.body);
          final pElements = document.getElementsByTagName('p');
          if (pElements.any((element) => element.text.trim().isNotEmpty)) {
            if (linkListNotifier.contains(copiedText)) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.alreadyExistsMessage),
                    content: Text(l10n.existingLinkOpenConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.commonCancel),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          linkListNotifier.select(copiedText);
                        },
                        child: Text(l10n.commonOpen),
                      ),
                    ],
                  ),
                );
              }
            } else {
              linkListNotifier.add(copiedText);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.linkAdditionSuccessMessage),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.noTextLabel),
                  content: Text(l10n.notContainsParagraphMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.commonOk),
                    ),
                  ],
                ),
              );
            }
          }
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.invalidUrlLabel),
                content: Text(l10n.urlCopyRequest),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.commonOk),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: colorScheme.errorContainer,
              title: Row(
                children: [
                  Icon(Icons.error, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(
                    l10n.errorLabel,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ],
              ),
              content: Text(e.toString(), maxLines: 5),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonOk),
                ),
              ],
            ),
          );
        }
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.noCopiedUrlLabel),
            content: Text(l10n.urlCopyRequest),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonOk),
              ),
            ],
          ),
        );
      }
    }
  }
}
