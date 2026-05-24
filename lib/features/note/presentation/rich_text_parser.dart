import 'package:flutter/material.dart';

class RichTextParser extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const RichTextParser({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final List<Widget> children = [];
    final theme = Theme.of(context);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 1. Check for bullet list item
      if (line.trimLeft().startsWith('- ') || line.trimLeft().startsWith('* ')) {
        final content = line.substring(line.indexOf(' ') + 1);
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.merge(style),
                      children: _parseInline(content, theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // 2. Check for numbered list item
      else if (RegExp(r'^\d+\.\s').hasMatch(line.trimLeft())) {
        final match = RegExp(r'^\d+\.\s').firstMatch(line.trimLeft())!;
        final prefix = match.group(0)!;
        final content = line.trimLeft().substring(prefix.length);
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prefix, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.merge(style),
                      children: _parseInline(content, theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // 3. Normal paragraph
      else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.merge(style),
                children: _parseInline(line, theme),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<TextSpan> _parseInline(String text, ThemeData theme) {
    final List<TextSpan> spans = [];

    // Parse:
    // **bold**
    // *italic*
    // <u>underline</u>
    // ==highlight==
    final regExp = RegExp(
      r'(\*\*.*?\*\*)|(\*.*?\*)|(<u>.*?</u>)|(==.*?==)',
      multiLine: true,
    );

    int start = 0;
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      // Add plain text before match
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final matchedStr = match.group(0)!;
      if (matchedStr.startsWith('**') && matchedStr.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(2, matchedStr.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (matchedStr.startsWith('*') && matchedStr.endsWith('*')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(1, matchedStr.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (matchedStr.startsWith('<u>') && matchedStr.endsWith('</u>')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(3, matchedStr.length - 4),
            style: const TextStyle(decoration: TextDecoration.underline),
          ),
        );
      } else if (matchedStr.startsWith('==') && matchedStr.endsWith('==')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(2, matchedStr.length - 2),
            style: TextStyle(
              backgroundColor: Colors.yellowAccent.withValues(alpha: 0.6),
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
