import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Simula cerrar y abrir la app: un gestor nuevo que lee el mismo almacenamiento.
Future<GestorIncidencias> abrirApp() async {
  final g = GestorIncidencias();
  await g.iniciar();
  return g;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('BUG-001 persistencia del estado', () {
    test('el cambio de estado se conserva al reiniciar', () async {
      final g = await abrirApp();
      expect(g.porId('INC-101')!.estado, 'Pendiente');

      await g.cambiarEstado('INC-101', 'Resuelta');

      final reabierta = await abrirApp();
      expect(reabierta.porId('INC-101')!.estado, 'Resuelta');
    });

    test('cambiar un registro no altera los demas', () async {
      final g = await abrirApp();
      final antes = {for (final x in g.incidencias) x.id: x.estado};

      await g.cambiarEstado('INC-101', 'Resuelta');

      final reabierta = await abrirApp();
      expect(reabierta.incidencias.length, antes.length);
      for (final x in reabierta.incidencias) {
        if (x.id == 'INC-101') continue;
        expect(x.estado, antes[x.id], reason: x.id);
      }
    });

    test('una incidencia nueva sigue existiendo al reiniciar', () async {
      final g = await abrirApp();
      await g.crear(
          'Monitor sin señal', 'Registro ficticio', 'Cliente Demo', 'Hardware');

      final reabierta = await abrirApp();
      expect(reabierta.incidencias.length, 11);
      expect(reabierta.incidencias.first.titulo, 'Monitor sin señal');
    });

    test('un id inexistente no modifica nada', () async {
      final g = await abrirApp();
      await g.cambiarEstado('INC-999', 'Resuelta');

      final reabierta = await abrirApp();
      expect(
          reabierta.incidencias.where((x) => x.estado == 'Resuelta').length, 3);
    });
  });

  group('BUG-003 totales del tablero', () {
    Map<String, int> tablero(GestorIncidencias g) => {
          for (final e in ['Pendiente', 'En proceso', 'Resuelta'])
            e: g.contar(e),
        };

    Map<String, int> conteoManual(GestorIncidencias g) => {
          for (final e in ['Pendiente', 'En proceso', 'Resuelta'])
            e: g.incidencias.where((x) => x.estado == e).length,
        };

    test('totales iniciales 5 / 2 / 3', () async {
      final g = await abrirApp();
      expect(tablero(g), {'Pendiente': 5, 'En proceso': 2, 'Resuelta': 3});
    });

    test('Pendiente a Resuelta resta un pendiente', () async {
      final g = await abrirApp();
      await g.cambiarEstado('INC-101', 'Resuelta');
      expect(tablero(g), {'Pendiente': 4, 'En proceso': 2, 'Resuelta': 4});
    });

    test('Resuelta a Pendiente suma un pendiente', () async {
      final g = await abrirApp();
      await g.cambiarEstado('INC-104', 'Pendiente');
      expect(tablero(g), {'Pendiente': 6, 'En proceso': 2, 'Resuelta': 2});
    });

    test('registrar una incidencia suma un pendiente y cuadra con la lista',
        () async {
      final g = await abrirApp();
      await g.cambiarEstado('INC-103', 'En proceso');
      await g.crear(
          'Monitor sin señal', 'Registro ficticio', 'Cliente Demo', 'Hardware');
      expect(tablero(g), {'Pendiente': 5, 'En proceso': 3, 'Resuelta': 3});
      expect(tablero(g), conteoManual(g));
    });

    test('los totales son iguales antes y despues de reiniciar', () async {
      final g = await abrirApp();
      await g.cambiarEstado('INC-101', 'Resuelta');
      await g.crear(
          'Monitor sin señal', 'Registro ficticio', 'Cliente Demo', 'Hardware');
      final antes = tablero(g);

      final reabierta = await abrirApp();
      expect(tablero(reabierta), antes);
      expect(antes.values.reduce((a, b) => a + b), g.incidencias.length);
    });

    test('la busqueda no cambia los totales', () async {
      final g = await abrirApp();
      final antes = tablero(g);
      g.buscar('WiFi');
      expect(tablero(g), antes);
    });
  });

  group('BUG-002 busqueda', () {
    List<String> ids(GestorIncidencias g, String texto) =>
        g.buscar(texto).map((x) => x.id).toList();

    test('ignora mayusculas y minusculas', () async {
      final g = await abrirApp();
      expect(ids(g, 'wifi'), ['INC-102']);
      expect(ids(g, 'WiFi'), ['INC-102']);
      expect(ids(g, 'WIFI'), ['INC-102']);
    });

    test('busca tambien en la descripcion', () async {
      final g = await abrirApp();
      expect(ids(g, 'túnel'), ['INC-106']);
      expect(ids(g, 'TÚNEL'), ['INC-106']);
    });

    test('ignora espacios al inicio y al final', () async {
      final g = await abrirApp();
      expect(ids(g, '  WiFi  '), ['INC-102']);
    });

    test('sin texto devuelve todos los registros', () async {
      final g = await abrirApp();
      expect(g.buscar('').length, 10);
      expect(g.buscar('   ').length, 10);
    });

    test('una palabra presente en titulo y descripcion no duplica', () async {
      final g = await abrirApp();
      expect(ids(g, 'pantalla'), ['INC-103', 'INC-110']);
    });

    test('sin coincidencias devuelve lista vacia', () async {
      final g = await abrirApp();
      expect(g.buscar('zzz'), isEmpty);
    });
  });

  group('FEAT-001 prioridad', () {
    test('los registros sin prioridad abren como Media', () async {
      final g = await abrirApp();
      expect(g.incidencias.map((x) => x.prioridad).toSet(), {'Media'});
    });

    test('datos guardados por la version anterior abren como Media', () async {
      // Formato que guardaba la app antes de FEAT-001: sin el campo prioridad.
      final antiguos = [
        {
          'id': 'INC-OLD',
          'titulo': 'Registro antiguo',
          'descripcion': 'Guardado sin prioridad',
          'cliente': 'Cliente Demo',
          'categoria': 'Redes',
          'estado': 'En proceso',
          'fecha': '2026-10-13',
        },
      ];
      await SharedPreferencesAsync()
          .setString('nexasoft_incidencias_v1', jsonEncode(antiguos));

      final g = await abrirApp();
      expect(g.incidencias.single.prioridad, 'Media');
      expect(g.incidencias.single.estado, 'En proceso');
    });

    test('una incidencia nueva se crea con la prioridad elegida', () async {
      final g = await abrirApp();
      await g.crear(
          'Servidor caido', 'Registro ficticio', 'Cliente Demo', 'Hardware',
          prioridad: 'Alta');

      final reabierta = await abrirApp();
      expect(reabierta.incidencias.first.titulo, 'Servidor caido');
      expect(reabierta.incidencias.first.prioridad, 'Alta');
    });

    test('sin elegir prioridad se crea como Media', () async {
      final g = await abrirApp();
      await g.crear(
          'Sin prioridad', 'Registro ficticio', 'Cliente Demo', 'Software');
      expect(g.incidencias.first.prioridad, 'Media');
    });

    test('cambiar la prioridad se conserva y no altera el estado', () async {
      final g = await abrirApp();
      await g.cambiarPrioridad('INC-103', 'Baja');

      final reabierta = await abrirApp();
      expect(reabierta.porId('INC-103')!.prioridad, 'Baja');
      expect(reabierta.porId('INC-103')!.estado, 'Pendiente');
      expect(
          reabierta.incidencias
              .where((x) => x.id != 'INC-103')
              .every((x) => x.prioridad == 'Media'),
          isTrue);
    });

    test('cambiar el estado conserva la prioridad', () async {
      final g = await abrirApp();
      await g.cambiarPrioridad('INC-101', 'Alta');
      await g.cambiarEstado('INC-101', 'Resuelta');

      final reabierta = await abrirApp();
      expect(reabierta.porId('INC-101')!.prioridad, 'Alta');
      expect(reabierta.porId('INC-101')!.estado, 'Resuelta');
    });

    test('se rechazan prioridades fuera de Baja, Media y Alta', () async {
      final g = await abrirApp();
      expect(
          () => g.cambiarPrioridad('INC-101', 'Urgente'), throwsArgumentError);
      expect(() => g.crear('X', 'Y', 'Z', 'Software', prioridad: 'alta'),
          throwsArgumentError);
      expect(g.porId('INC-101')!.prioridad, 'Media');
      expect(g.incidencias.length, 10);
    });
  });
}
