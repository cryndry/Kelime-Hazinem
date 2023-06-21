import 'package:flutter/material.dart';
import 'package:kelime_hazinem/components/word_card.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';

class AllWordsPageLayout extends StatelessWidget {
  const AllWordsPageLayout({super.key, required this.words, this.FABs});

  final List<Word> words;
  final List<Widget>? FABs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemBuilder: (context, index) => WordCard(word: words[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemCount: words.length,
              ),
            )
          ],
        ),
        if (FABs != null)
          Positioned(
            bottom: 48,
            right: 16,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: FABs!,
              ),
            ),
          ),
      ],
    );
  }
}
