import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/theme_map.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class VsCodeCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String codeContent = element.textContent.trimRight();

    String language = 'bash';
    if (element.children != null && element.children!.isNotEmpty) {
      final firstChild = element.children!.first;
      if (firstChild is md.Element &&
          firstChild.attributes.containsKey('class')) {
        final classAttr = firstChild.attributes['class'] ?? '';
        if (classAttr.startsWith('language-')) {
          language = classAttr.replaceFirst('language-', '');
        }
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF282C34), // Warna dasar atom-one-dark
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER TERMINAL
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF21252B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5F56),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFBD2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27C93F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    language.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF858585),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Copy Button
                  Builder(
                    builder: (context) {
                      return InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: codeContent));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard!'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              color: Color(0xFF858585),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                color: Color(0xFF858585),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // CODE BODY
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: HighlightView(
                      codeContent,
                      language: language,
                      theme: themeMap['night-owl']!,
                      padding: const EdgeInsets.all(14.0),
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
