import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:krakflow_flutter/main.dart';
import 'package:krakflow_flutter/models/task.dart';
import 'package:krakflow_flutter/services/task_local_database.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('krakflow_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('tasks');
    await TaskLocalDatabase.addTask(
      Task(
        id: 1,
        title: 'Testowe zadanie',
        deadline: 'dzisiaj',
        priority: 'sredni',
        done: false,
      ),
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('renders task manager home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('KrakFlow'), findsOneWidget);
    expect(find.text('Testowe zadanie'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
