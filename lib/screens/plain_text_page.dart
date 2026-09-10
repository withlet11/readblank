// Copyright 2026 WITHLET11 <withlet11@gmail.com>
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_preferences_notifier.dart';
import '../providers/contents_notifier.dart';
import '../services/text_to_speech_service.dart';
import '../style.dart';

class PlainTextPage extends StatefulWidget {
  final String url;
  final String title;
  final String domain;
  final List<String> paragraphs;
  final String? searchWord;
  final bool isExactMatch;
  final Locale locale;
  final double speechVolume;
  final double speechRate;

  const PlainTextPage({
    super.key,
    required this.url,
    required this.title,
    required this.domain,
    this.paragraphs = const [],
    this.searchWord,
    this.isExactMatch = false,
    required this.locale,
    required this.speechVolume,
    required this.speechRate,
  });

  @override
  State<PlainTextPage> createState() => _PlainTextPageState();
}

class _PlainTextPageState extends State<PlainTextPage> {
  late String _title;
  late String _domain;
  late String _url;
  late String? _searchWord;
  late bool _isExactMatch;
  late double _speechVolume;
  late double _speechRate;
  int _readingParagraphIndex = 0;

  final _textEditingController = TextEditingController();

  final TextToSpeechService _ttsService = TextToSpeechService();

  @override
  void initState() {
    super.initState();

    _title = widget.title;
    _domain = widget.domain;
    _url = widget.url;
    _searchWord = widget.searchWord;
    _textEditingController.text = _searchWord ?? '';
    _isExactMatch = widget.isExactMatch;
    _speechVolume = widget.speechVolume;
    _speechRate = widget.speechRate;

    _ttsService.initTts(
      volume: _speechVolume,
      rate: _speechRate,
      language: widget.locale.languageCode,
    );
    print(
      'plaintext ======${widget.locale.toLanguageTag()} =======',
    );

    _ttsService.onStart = () {
      if (mounted) setState(() {});
    };

    _ttsService.onComplete = () {
      if (mounted) setState(() {});
    };

    _ttsService.onError = (msg) {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ContentViewPalette.of(context);
    final highlightColor = palette.accent;
    final l10n = AppLocalizations.of(context)!;
    final contentsNotifier = context.watch<ContentsNotifier>();
    final paragraphs = contentsNotifier.getParagraphList(widget.url);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _domain,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: contentsNotifier.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        labelText: l10n.searchLabel,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: _isExactMatch,
                        onChanged: (value) {
                          setState(() {
                            _isExactMatch = value ?? false;
                          });
                        },
                      ),
                      Text(
                        l10n.exactMatchLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildParagraphs(paragraphs, highlightColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParagraphs(List<String> paragraphs, Color highlightColor) {
    return [
      for (final (index, paragraph) in paragraphs.indexed)
        if (_textEditingController.text.isEmpty ||
            (_isExactMatch
                ? containsWholeWord(paragraph, _textEditingController.text)
                : paragraph.toLowerCase().contains(
                    _textEditingController.text.toLowerCase(),
                  )))
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            child: Card(
              surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('[${index + 1}]'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.article),
                              onPressed: () async {
                                final contentsNotifier = context
                                    .read<ContentsNotifier>();
                                final pref = context
                                    .read<AppPreferencesNotifier>();
                                final navigator = Navigator.of(context);

                                await contentsNotifier.select(_url);
                                await contentsNotifier.setCurrentParagraphIndex(
                                  index,
                                );

                                if (!mounted) return;

                                pref.setMainPageSelectedIndex(0);
                                navigator.pop();
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                SharePlus.instance.share(
                                  ShareParams(text: paragraph),
                                );
                              },
                              icon: const Icon(Icons.share),
                            ),
                            IconButton(
                              icon:
                                  (_ttsService.state == TtsState.playing &&
                                      index == _readingParagraphIndex)
                                  ? Icon(
                                      Icons.stop,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    )
                                  : Icon(
                                      _speechVolume == 0.0
                                          ? Icons.volume_off
                                          : _speechVolume < 0.5
                                          ? Icons.volume_mute
                                          : _speechVolume < 0.75
                                          ? Icons.volume_down
                                          : Icons.volume_up,
                                    ),
                              onPressed: _speechVolume > 0.0
                                  ? () {
                                      if (index == _readingParagraphIndex) {
                                        _toggleSpeak(paragraph);
                                      } else {
                                        _readingParagraphIndex = index;
                                        _switchSpeak(paragraph);
                                      }
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: highlightSearchWord(
                          paragraph,
                          highlightColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    ];
  }

  List<InlineSpan> highlightSearchWord(String text, Color highlightColor) {
    final normalStyle = Theme.of(context).textTheme.bodyLarge;
    final searchWord = _textEditingController.text.toLowerCase();
    if (searchWord.isEmpty) {
      return [TextSpan(style: normalStyle, text: text)];
    }

    final highlightStyle = normalStyle?.copyWith(
      backgroundColor: highlightColor,
    );

    final lowerCaseText = text.toLowerCase();
    List<InlineSpan> spans = [];
    int end = 0;

    while (end < lowerCaseText.length) {
      int begin = lowerCaseText.indexOf(searchWord, end);
      if (begin == -1) {
        spans.add(TextSpan(text: text.substring(end), style: normalStyle));
        break;
      } else {
        spans.add(
          TextSpan(text: text.substring(end, begin), style: normalStyle),
        );
        end = begin + searchWord.length;
        if (!_isExactMatch ||
            ((begin == 0 || !isLatinChar(text[begin - 1])) &&
                (end >= lowerCaseText.length || !isLatinChar(text[end])))) {
          spans.add(
            TextSpan(text: text.substring(begin, end), style: highlightStyle),
          );
        } else {
          spans.add(
            TextSpan(text: text.substring(begin, end), style: normalStyle),
          );
        }
      }
    }

    return spans;
  }

  bool containsWholeWord(String source, String word) {
    if (word.isEmpty) return false;
    final regex = RegExp(
      r'(?<!\p{L})' + RegExp.escape(word) + r'(?!\p{L})',
      caseSensitive: false,
      unicode: true,
    );
    return regex.hasMatch(source);
  }

  bool isLatinChar(String char) {
    return RegExp(r'^\p{Script=Latin}$', unicode: true).hasMatch(char);
  }

  void _toggleSpeak(String paragraph) async {
    if (_ttsService.state == TtsState.playing) {
      await _ttsService.stop();
    } else {
      await _ttsService.speak(paragraph);
    }
  }

  void _switchSpeak(String paragraph) async {
    if (_ttsService.state == TtsState.playing) {
      await _ttsService.stop();
    }

    await _ttsService.speak(paragraph);
  }
}
