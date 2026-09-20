import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/features/daily_tasks/daily_tasks_screen.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness() {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const DailyTasksScreen(ownerId: 'ana@flowly.com'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra las columnas por defecto en orden', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);
    expect(find.text('Doing'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('permite añadir una tarea a una columna', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsOneWidget);
  });

  testWidgets('permite editar una tarea desde su menú', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear la tarea.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar café'), findsOneWidget);

    // Editar desde el menú de la tarjeta.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Preparar café con leche');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café con leche'), findsOneWidget);
    expect(find.text('Preparar café'), findsNothing);
  });

  testWidgets('permite eliminar una tarea desde su menú', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear la tarea.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar café'), findsOneWidget);

    // Eliminar desde el menú de la tarjeta.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    // Confirmar el borrado.
    expect(find.text('Eliminar tarea'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsNothing);
  });

  testWidgets('no elimina la tarea si se cancela el diálogo', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear la tarea.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Abrir el diálogo de borrado y cancelar.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsOneWidget);
  });

  testWidgets('permite reordenar columnas arrastrando por la cabecera',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Orden inicial: Search, TODO, Doing, Done.
    expect(
      tester.getTopLeft(find.text('Doing')).dx,
      greaterThan(tester.getTopLeft(find.text('Search')).dx),
    );

    // Long-press sobre la cabecera de Search y soltar sobre Doing.
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Search')));
    await tester.pump(const Duration(milliseconds: 160));
    await gesture.moveTo(tester.getCenter(find.text('Doing')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    // Orden esperado: TODO, Doing, Search, Done.
    final todoX = tester.getTopLeft(find.text('TODO')).dx;
    final doingX = tester.getTopLeft(find.text('Doing')).dx;
    final searchX = tester.getTopLeft(find.text('Search')).dx;
    final doneX = tester.getTopLeft(find.text('Done')).dx;
    expect(todoX, lessThan(doingX));
    expect(doingX, lessThan(searchX));
    expect(searchX, lessThan(doneX));
  });

  testWidgets('el drag de tareas sigue funcionando tras reordenar columnas',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Mover Search al final para comprobar que todo sigue en su sitio.
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Search')));
    await tester.pump(const Duration(milliseconds: 160));
    await gesture.moveTo(tester.getCenter(find.text('Done')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    // Crear una tarea en la primera columna (ahora TODO).
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Arrastrar la tarjeta hasta la columna Doing.
    final drag = await tester.startGesture(
      tester.getCenter(find.text('Preparar café')),
    );
    await tester.pump(const Duration(milliseconds: 160));
    await drag.moveTo(tester.getCenter(find.text('Doing')));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();

    // La tarea debe verse ahora dentro de la columna Doing (entre sus vecinos).
    final doingCenterX = tester.getCenter(find.text('Doing')).dx;
    final doneCenterX = tester.getCenter(find.text('Done')).dx;
    final taskCenterX = tester.getCenter(find.text('Preparar café')).dx;
    expect(taskCenterX, greaterThan(doingCenterX));
    expect(taskCenterX, lessThan(doneCenterX));
  });

  testWidgets('el selector muestra ambas vistas y por defecto está Por estado',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Por estado'), findsOneWidget);
    expect(find.text('Todas las tareas'), findsOneWidget);
    // Vista por defecto: el kanban.
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('+ Añadir tarea'), findsNWidgets(4));
  });

  testWidgets('tocar la opción ya activa del selector es un no-op',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // «Por estado» está activa por defecto; tocarla no cambia la vista.
    await tester.tap(find.text('Por estado'));
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('+ Añadir tarea'), findsNWidgets(4));
  });

  testWidgets('la vista todas las tareas muestra nombre, burbuja del estado y '
      'menú', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear una tarea en la columna TODO.
    await tester.tap(find.text('+ Añadir tarea').at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Cambiar a «Todas las tareas».
    await tester.tap(find.text('Todas las tareas'));
    await tester.pumpAndSettle();

    // La fila muestra el nombre, la burbuja con el estado y el menú.
    expect(find.text('Preparar café'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    // El kanban ya no está visible.
    expect(find.text('+ Añadir tarea'), findsNothing);
  });

  testWidgets('permite editar una tarea desde la vista de lista', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear una tarea en la columna TODO.
    await tester.tap(find.text('+ Añadir tarea').at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Cambiar a «Todas las tareas» y editar.
    await tester.tap(find.text('Todas las tareas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café con leche');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café con leche'), findsOneWidget);
    expect(find.text('Preparar café'), findsNothing);
  });

  testWidgets('permite eliminar una tarea desde la vista de lista',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear una tarea en la columna TODO.
    await tester.tap(find.text('+ Añadir tarea').at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Cambiar a «Todas las tareas» y eliminar.
    await tester.tap(find.text('Todas las tareas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsNothing);
    expect(find.text('Sin tareas todavía'), findsOneWidget);
  });

  testWidgets('volver a Por estado restaura el kanban', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear una tarea y cambiar a la vista de lista.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas las tareas'));
    await tester.pumpAndSettle();

    // Volver a «Por estado»: el kanban vuelve a verse con la tarea.
    await tester.tap(find.text('Por estado'));
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('+ Añadir tarea'), findsNWidgets(4));
    expect(find.text('Preparar café'), findsOneWidget);
  });
}