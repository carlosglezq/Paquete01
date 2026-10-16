import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/ui/pantalla_principal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Map<String, String> registro(
        String id, String titulo, String estado, String prioridad) =>
    {
      'id': id,
      'titulo': titulo,
      'descripcion': 'Registro ficticio de prueba',
      'cliente': 'Cliente Demo',
      'categoria': 'Redes',
      'estado': estado,
      'fecha': '2026-10-15',
      'prioridad': prioridad,
    };

void main() {
  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await SharedPreferencesAsync().setString(
        'nexasoft_incidencias_v1',
        jsonEncode([
          registro('T-1', 'WiFi caído en caja', 'Pendiente', 'Alta'),
          registro('T-2', 'WiFi lento en bodega', 'Pendiente', 'Baja'),
          registro('T-3', 'WiFi de sala resuelto', 'Resuelta', 'Alta'),
          registro('T-4', 'Impresora atascada', 'Pendiente', 'Alta'),
          registro('T-5', 'Correo sin sincronizar', 'En proceso', 'Media'),
        ]));
  });

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: PantallaPrincipal()));
    await tester.pumpAndSettle();
  }

  Future<void> chip(WidgetTester tester, String texto) async {
    await tester.tap(find.widgetWithText(ChoiceChip, texto));
    await tester.pumpAndSettle();
  }

  testWidgets('texto, estado y prioridad se aplican juntos y se limpian',
      (tester) async {
    await abrir(tester);
    expect(find.text('5 de 5 registros'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wifi');
    await tester.pumpAndSettle();
    expect(find.text('3 de 5 registros'), findsOneWidget);

    await chip(tester, 'Pendiente');
    expect(find.text('2 de 5 registros'), findsOneWidget);

    await chip(tester, 'Alta');
    expect(find.text('1 de 5 registros'), findsOneWidget);
    expect(find.text('WiFi caído en caja'), findsOneWidget);
    expect(find.text('WiFi lento en bodega'), findsNothing);

    await tester.tap(find.text('Limpiar búsqueda y filtros'));
    await tester.pumpAndSettle();
    expect(find.text('5 de 5 registros'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Todos'))
            .selected,
        isTrue);
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Todas'))
            .selected,
        isTrue);
  });

  testWidgets('sin resultados muestra un mensaje y permite volver a todo',
      (tester) async {
    await abrir(tester);
    await chip(tester, 'En proceso');
    await chip(tester, 'Alta');
    expect(find.text('0 de 5 registros'), findsOneWidget);
    expect(
        find.text(
            'Ninguna incidencia cumple la búsqueda y los filtros activos.'),
        findsOneWidget);

    await tester.tap(find.text('Mostrar todas las incidencias'));
    await tester.pumpAndSettle();
    expect(find.text('5 de 5 registros'), findsOneWidget);
  });

  testWidgets('el tablero no depende de los filtros', (tester) async {
    await abrir(tester);
    await chip(tester, 'Resuelta');
    // Tarjetas del tablero: 3 pendientes, 1 en proceso, 1 resuelta.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1 de 5 registros'), findsOneWidget);
  });
}
