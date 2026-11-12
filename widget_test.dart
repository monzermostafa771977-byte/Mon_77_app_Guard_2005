import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:hares/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  testWidgets('HARES shell renders Arabic navigation', (tester) async {
    await tester.pumpWidget(const HaresApp());
    await tester.pumpAndSettle();
    expect(find.text('حارس'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الانضباط'), findsOneWidget);
  });
}
