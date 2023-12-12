import "package:atoms_state/atoms_state.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:only_bible_app/models.dart";
import "package:only_bible_app/screens/bible_select_screen.dart";
import "package:only_bible_app/screens/book_select_screen.dart";
import "package:only_bible_app/screens/chapter_view_screen.dart";
import 'package:only_bible_app/widgets/settings_sheet.dart';
import "package:only_bible_app/store/actions.dart";
import "package:only_bible_app/store/state.dart";
import "package:only_bible_app/utils.dart";
import "package:only_bible_app/widgets/note_sheet.dart";
import "package:only_bible_app/widgets/scaffold_markdown.dart";
import "package:share_plus/share_plus.dart";

createNoTransitionPageRoute(Widget page) {
  return PageRouteBuilder(
    opaque: false,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, _, __) => page,
  );
}

createSlideRoute({required BuildContext context, TextDirection? slideDir, required Widget page}) {
  if (context.isWide || slideDir == null) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) {
        return page;
      },
    );
  }
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        textDirection: slideDir,
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

updateStatusBar(bool v) {
  if (v) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF1F1F22),
      statusBarColor: Color(0xFF1F1F22),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      statusBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
}

pushBookChapter(BuildContext context, String bibleName, int book, int chapter, TextDirection? dir) {
  dispatch(UpdateChapter(book, chapter));
  clearEvents(context);
  Navigator.of(context).push(
    createSlideRoute(
      context: context,
      slideDir: dir,
      page: ChapterViewScreen(bibleName: bibleName, bookIndex: book, chapterIndex: chapter),
    ),
  );
}

replaceBookChapter(BuildContext context, String bibleName, int book, int chapter) {
  dispatch(UpdateChapter(book, chapter));
  clearEvents(context);
  Navigator.of(context).pushReplacement(
    createNoTransitionPageRoute(
      ChapterViewScreen(bibleName: bibleName, bookIndex: book, chapterIndex: chapter),
    ),
  );
}

nextChapter(BuildContext context, Bible bible, int book, int chapter) {
  final selectedBook = bible.books[book];
  if (selectedBook.chapters.length > chapter + 1) {
    pushBookChapter(context, bible.name, selectedBook.index, chapter + 1, TextDirection.ltr);
  } else {
    if (selectedBook.index + 1 < bible.books.length) {
      final nextBook = bible.books[selectedBook.index + 1];
      pushBookChapter(context, bible.name, nextBook.index, 0, TextDirection.ltr);
    }
  }
}

previousChapter(BuildContext context, Bible bible, int book, int chapter) {
  final selectedBook = bible.books[book];
  if (chapter - 1 >= 0) {
    // if (Navigator.of(context).canPop()) {
    //   Navigator.of(context).pop();
    // } else {
    pushBookChapter(context, bible.name, selectedBook.index, chapter - 1, TextDirection.rtl);
    // }
  } else {
    if (selectedBook.index - 1 >= 0) {
      final prevBook = bible.books[selectedBook.index - 1];
      pushBookChapter(context, bible.name, prevBook.index, prevBook.chapters.length - 1, TextDirection.rtl);
    }
  }
}

showAboutUs(BuildContext context) {
  Navigator.of(context).push(
    createNoTransitionPageRoute(
      const ScaffoldMarkdown(title: "About Us", file: "about-us.md"),
    ),
  );
}

showPrivacyPolicy(BuildContext context) {
  Navigator.of(context).push(
    createNoTransitionPageRoute(
      const ScaffoldMarkdown(title: "Privacy Policy", file: "privacy-policy.md"),
    ),
  );
}

showTermsAndConditions(BuildContext context) {
  Navigator.of(context).push(
    createNoTransitionPageRoute(
      const ScaffoldMarkdown(title: "Terms and Conditions", file: "terms-and-conditions.md"),
    ),
  );
}

changeBible(BuildContext context) {
  Navigator.of(context).pushReplacement(
    createNoTransitionPageRoute(
      const BibleSelectScreen(),
    ),
  );
}

changeBibleFromHeader(BuildContext context) {
  Navigator.of(context).push(
    createNoTransitionPageRoute(
      const BibleSelectScreen(),
    ),
  );
}

changeBook(BuildContext context, Bible bible) {
  Navigator.of(context).push(
    createNoTransitionPageRoute(
      BookSelectScreen(bible: bible),
    ),
  );
}

updateCurrentBible(BuildContext context, String name, String code, int book, int chapter) async {
  dispatch(UpdateBible(name, code));
  pushBookChapter(context, name, book, chapter, null);
}

shareAppLink(BuildContext context) {
  if (isAndroid()) {
    Share.share(
      subject: "Only Bible App",
      "https://play.google.com/store/apps/details?id=sh.pyros.only_bible_app",
    );
  } else if (isIOS()) {
    Share.share(
      subject: "Only Bible App",
      "https://apps.apple.com/us/app/only-bible-app/id6467606465",
    );
  } else {
    Share.share(
      subject: "Only Bible App",
      "https://onlybible.app",
    );
  }
}

rateApp(BuildContext context) {
  if (isAndroid()) {
    context.openUrl("https://play.google.com/store/apps/details?id=sh.pyros.only_bible_app");
  } else if (isIOS()) {
    context.openUrl("https://apps.apple.com/us/app/only-bible-app/id6467606465");
  } else {
    context.openUrl("https://apps.apple.com/us/app/only-bible-app/id6467606465");
  }
}

shareVerses(BuildContext context, Bible bible, List<Verse> verses) {
  final name = bible.books[verses.first.book].name(context);
  final chapter = verses.first.chapter + 1;
  final title = "$name $chapter: ${verses.map((e) => e.index + 1).join(", ")}";
  final text = verses.map((e) => e.text).join("\n");
  Share.share("$title\n$text", subject: title);
}

showSettings(BuildContext context, Bible bible) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => SettingsSheet(bible: bible),
  );
}

showNoteField(BuildContext context, Bible bible, Verse v) {
  final noteText = box.read("${v.book}:${v.chapter}:${v.index}:note") ?? "";
  noteTextController.text = noteText;
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => NoteSheet(bible: bible, verse: v),
  );
}

hideNoteField(BuildContext context) {
  Navigator.of(context).pop();
}
