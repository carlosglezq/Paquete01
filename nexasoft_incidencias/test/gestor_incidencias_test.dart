import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
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
      await g.crear('Monitor sin señal', 'Registro ficticio', 'Cliente Demo',
          'Hardware');

      final reabierta = await abrirApp();
      expect(reabierta.incidencias.length, 11);
      expect(reabierta.incidencias.first.titulo, 'Monitor sin señal');
    });

    test('un id inexistente no modifica nada', () async {
      final g = await abrirApp();
      await g.cambiarEstado('INC-999', 'Resuelta');

      final reabierta = await abrirApp();
      expect(reabierta.incidencias.where((x) => x.estado == 'Resuelta').length,
          3);
    });
  });
}
