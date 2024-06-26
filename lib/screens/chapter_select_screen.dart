import "package:flutter/material.dart";
import "package:only_bible_app/models.dart";
import "package:only_bible_app/navigation.dart";
import "package:only_bible_app/utils.dart";
import "package:only_bible_app/widgets/scaffold_menu.dart";
import "package:only_bible_app/widgets/sliver_tile_grid.dart";
import "package:only_bible_app/widgets/sliver_heading.dart";

class ChapterSelectScreen extends StatelessWidget {
  final Bible bible;
  final Book book;
  final int selectedBookIndex;

  const ChapterSelectScreen({super.key, required this.bible, required this.selectedBookIndex, required this.book});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMenu(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverHeading(title: context.bookNames[book.index], showClose: true),
          SliverTileGrid(
            children: List.generate(book.chapters.length, (index) {
              return TextButton(
                child: Text("${index + 1}"),
                onPressed: () => replaceBookChapter(context, bible.name, selectedBookIndex, index),
              );
            }),
          ),
        ],
      ),
    );
  }
}
