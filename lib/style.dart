/*
 * style.dart
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

class ContentViewPalette {
  final Color background;
  final Color border;
  final Color textField;
  final Color text;
  final Color accent;
  final Color muted;

  const ContentViewPalette({
    required this.background,
    required this.border,
    required this.textField,
    required this.text,
    required this.accent,
    required this.muted,
  });

  factory ContentViewPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark ? _dark : _light;
  }

  static const _light = ContentViewPalette(
    background: Colors.black12,
    border: Colors.grey,
    textField: Colors.white,
    text: Colors.black,
    accent: Colors.deepOrangeAccent,
    muted: Colors.grey,
  );

  static const _dark = ContentViewPalette(
    background: Colors.black,
    border: Colors.white24,
    textField: Colors.white12,
    text: Colors.white,
    accent: Colors.deepOrangeAccent,
    muted: Colors.white38,
  );
}
