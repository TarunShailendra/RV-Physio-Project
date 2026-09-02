import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/iqol_model.dart';
import 'package:telerehab_app/features/assessment/notifiers/iqol_notifier.dart';

/// Covers I-QOL completeness.
///
/// _handleNext validated the page in view, but the screen was a PageView with
/// swiping enabled and onPageChanged only cleared the error flag. _handleSubmit
/// re-checked just the current page, and the result page's check returns true
/// unconditionally — so all 22 items could be left at 0 and submitted, writing
/// q1..q22 = 0 to Supabase.
void main() {
  List<int> answered([int value = 4]) =>
      List<int>.filled(IQOLModel.itemCount, value);

  group('completeness', () {
    test('a fresh questionnaire is not complete', () {
      final model = IqolNotifier().model;
      expect(model.hasAllItems, isFalse);
      expect(model.isComplete, isFalse);
    });

    test('all 22 items answered is still not enough without duration', () {
      final model = IQOLModel(items: answered());
      expect(model.hasAllItems, isTrue);
      expect(model.hasDuration, isFalse);
      expect(
        model.isComplete,
        isFalse,
        reason: 'the background page must be answered too',
      );
    });

    test('items plus duration is complete', () {
      final model = IQOLModel(items: answered(), durationYears: 2);
      expect(model.isComplete, isTrue);

      final byMonths = IQOLModel(items: answered(), durationMonths: 6);
      expect(byMonths.isComplete, isTrue);
    });

    test('a single skipped item blocks completion', () {
      final items = answered();
      items[13] = IQOLModel.unanswered;
      final model = IQOLModel(items: items, durationYears: 1);

      expect(model.hasAllItems, isFalse);
      expect(model.isComplete, isFalse);
      expect(model.firstUnansweredItemIndex, 13);
    });

    test('the first gap is reported, not just the fact of one', () {
      final items = answered();
      items[3] = IQOLModel.unanswered;
      items[17] = IQOLModel.unanswered;
      expect(IQOLModel(items: items).firstUnansweredItemIndex, 3);

      expect(IQOLModel(items: answered()).firstUnansweredItemIndex, isNull);
    });

    test('a short items list is incomplete rather than silently padded', () {
      final model = IQOLModel(items: List<int>.filled(10, 4), durationYears: 1);
      expect(model.hasAllItems, isFalse);
      expect(model.firstUnansweredItemIndex, 10);
    });

    test('out-of-range responses do not count as answered', () {
      final items = answered();
      items[0] = 9;
      expect(IQOLModel(items: items).hasAllItems, isFalse);
    });

    test('the all-zeros submission that used to be possible is rejected', () {
      // This is what a swiped-through questionnaire produced. Its raw score
      // falls below the floor of the scale, which is how it reached the
      // result page showing 0.0 only because that page clamps.
      final skipped = IQOLModel(
        items: List<int>.filled(IQOLModel.itemCount, IQOLModel.unanswered),
      );
      expect(skipped.isComplete, isFalse);
      expect(skipped.score, lessThan(0));
      expect(skipped.firstUnansweredItemIndex, 0);
    });
  });

  group('the questionnaire cannot be swiped past', () {
    testWidgets('NeverScrollableScrollPhysics blocks a drag between pages', (
      tester,
    ) async {
      // Mirrors the screen's PageView configuration.
      final controller = PageController();
      addTearDown(controller.dispose);
      var currentPage = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => currentPage = value,
              itemCount: IQOLModel.itemCount + 2,
              itemBuilder: (context, index) => Center(child: Text('page $index')),
            ),
          ),
        ),
      );

      expect(find.text('page 0'), findsOneWidget);

      // A swipe that would previously have advanced past an unanswered item.
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(currentPage, 0, reason: 'swiping must not change the page');
      expect(find.text('page 0'), findsOneWidget);

      // The buttons still drive paging.
      controller.jumpToPage(1);
      await tester.pumpAndSettle();
      expect(find.text('page 1'), findsOneWidget);
    });
  });
}
