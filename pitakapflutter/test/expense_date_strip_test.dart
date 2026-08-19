import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/feature/expense/presentation/widgets/expense_date_strip.dart';

import 'helpers.dart';

void main() {
  group('dateStripDays', () {
    test('returns dayCount consecutive days', () {
      final days = dateStripDays(
        selectedDay: DateTime(2026, 8, 19),
        today: DateTime(2026, 8, 19),
      );

      expect(days, hasLength(dateStripDayCount));

      for (var i = 1; i < days.length; i++) {
        expect(days[i].difference(days[i - 1]).inDays, 1);
      }
    });

    test('ends at today when today is selected', () {
      final days = dateStripDays(
        selectedDay: DateTime(2026, 8, 19),
        today: DateTime(2026, 8, 19),
      );

      expect(days.last, DateTime(2026, 8, 19));
      expect(days.first, DateTime(2026, 8, 13));
    });

    test('keeps today at the end while the selection sits inside the window', () {
      final days = dateStripDays(
        selectedDay: DateTime(2026, 8, 14),
        today: DateTime(2026, 8, 19),
      );

      expect(days.last, DateTime(2026, 8, 19));
      expect(days, contains(DateTime(2026, 8, 14)));
    });

    test('slides the window when the selection is older than it', () {
      final days = dateStripDays(
        selectedDay: DateTime(2026, 3, 2),
        today: DateTime(2026, 8, 19),
      );

      expect(days.last, DateTime(2026, 3, 2));
      expect(days.first, DateTime(2026, 2, 24));
    });

    test('always contains the selected day', () {
      final selections = [
        DateTime(2026, 8, 19),
        DateTime(2026, 8, 13),
        DateTime(2026, 8, 12),
        DateTime(2025, 1, 1),
      ];

      for (final selected in selections) {
        final days = dateStripDays(
          selectedDay: selected,
          today: DateTime(2026, 8, 19),
        );

        expect(days, contains(selected), reason: 'missing $selected');
      }
    });

    test('normalises time components on both arguments', () {
      final days = dateStripDays(
        selectedDay: DateTime(2026, 8, 19, 23, 59, 59),
        today: DateTime(2026, 8, 19, 7, 30),
      );

      expect(days.last, DateTime(2026, 8, 19));
      expect(days.every((day) => day.hour == 0), isTrue);
      expect(days.every((day) => day.isUtc), isFalse);
    });

    test('crosses a month boundary without gaps', () {
      final days = dateStripDays(
        selectedDay: DateTime(2026, 9, 2),
        today: DateTime(2026, 9, 2),
      );

      expect(days.first, DateTime(2026, 8, 27));
      expect(days.last, DateTime(2026, 9, 2));
    });

    test('crosses a leap day without gaps', () {
      final days = dateStripDays(
        selectedDay: DateTime(2028, 3, 1),
        today: DateTime(2028, 3, 1),
      );

      expect(days, contains(DateTime(2028, 2, 29)));
      expect(days.first, DateTime(2028, 2, 24));
    });
  });

  group('weekdayInitial', () {
    test('is the first letter of the weekday', () {
      expect(ExpenseDateStrip.weekdayInitial(DateTime(2026, 8, 19)), 'W');
      expect(ExpenseDateStrip.weekdayInitial(DateTime(2026, 8, 17)), 'M');
      expect(ExpenseDateStrip.weekdayInitial(DateTime(2026, 8, 16)), 'S');
    });
  });

  group('ExpenseDateStrip', () {
    Future<List<DateTime>> pumpStrip(
      WidgetTester tester, {
      required DateTime selectedDay,
      required DateTime today,
    }) async {
      final taps = <DateTime>[];

      await pumpPage(
        tester,
        Scaffold(
          body: ExpenseDateStrip(
            selectedDay: selectedDay,
            today: today,
            onSelected: taps.add,
          ),
        ),
      );

      return taps;
    }

    testWidgets('renders every day without scrolling', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpStrip(
        tester,
        selectedDay: DateTime(2026, 8, 19),
        today: DateTime(2026, 8, 19),
      );

      for (var day = 13; day <= 19; day++) {
        expect(
          find.text('$day'),
          findsOneWidget,
          reason: 'day $day should be on screen without scrolling',
        );
      }
    });

    testWidgets('tapping a day reports that day', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final taps = await pumpStrip(
        tester,
        selectedDay: DateTime(2026, 8, 19),
        today: DateTime(2026, 8, 19),
      );

      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();

      expect(taps, [DateTime(2026, 8, 16)]);
    });

    testWidgets('marks only the selected day', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpStrip(
        tester,
        selectedDay: DateTime(2026, 8, 16),
        today: DateTime(2026, 8, 19),
      );

      Color chipColor(String day) {
        final material = tester.widget<Material>(
          find
              .ancestor(of: find.text(day), matching: find.byType(Material))
              .first,
        );
        return material.color!;
      }

      final selected = chipColor('16');

      for (final day in ['13', '14', '15', '17', '18', '19']) {
        expect(chipColor(day), isNot(selected), reason: 'day $day');
      }
    });
  });
}
