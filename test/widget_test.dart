import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/theme/app_colors.dart';
import 'package:todo_flutter/widgets/app_button.dart';
import 'package:todo_flutter/widgets/app_checkbox.dart';
import 'package:todo_flutter/widgets/logo_mark.dart';
import 'package:todo_flutter/widgets/segmented_filter.dart';

void main() {
  testWidgets('LogoMark renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LogoMark(size: 40),
        ),
      ),
    );

    expect(find.byType(LogoMark), findsOneWidget);
  });

  testWidgets('AppButton renders and responds to tap', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Test Button',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    await tester.tap(find.text('Test Button'));
    await tester.pump();
    expect(pressed, isTrue);
  });

  testWidgets('AppCheckbox toggles state', (WidgetTester tester) async {
    var checked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return AppCheckbox(
                value: checked,
                onChanged: (val) {
                  setState(() => checked = val);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(AppCheckbox), findsOneWidget);
    await tester.tap(find.byType(AppCheckbox));
    await tester.pumpAndSettle();
    expect(checked, isTrue);
  });

  testWidgets('SegmentedFilter renders labels and counts', (WidgetTester tester) async {
    int selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SegmentedFilter(
                selectedIndex: selected,
                allCount: 5,
                activeCount: 3,
                doneCount: 2,
                onChanged: (idx) {
                  setState(() => selected = idx);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  test('categoryColor returns consistent colors modulo 6', () {
    final c1 = categoryColor(1);
    final c7 = categoryColor(7);
    expect(c1, equals(c7));
  });
}
