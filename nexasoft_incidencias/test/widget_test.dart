import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
  });

  group('FEAT-001 prioridad en el modelo', () {
    Map<String, dynamic> registro([Object? prioridad]) => {
          'id': 'INC-DEMO',
          'titulo': 'Prueba',
          'descripcion': 'Caso de ejemplo',
          'cliente': 'Cliente ficticio',
          'categoria': 'Redes',
          'estado': 'Pendiente',
          'fecha': '2026-10-12',
          if (prioridad != null) 'prioridad': prioridad,
        };

    test('sin prioridad se toma Media', () {
      expect(Incidencia.desdeJson(registro()).prioridad, 'Media');
    });

    test('conserva las tres prioridades aprobadas', () {
      for (final p in ['Baja', 'Media', 'Alta']) {
        expect(Incidencia.desdeJson(registro(p)).prioridad, p);
      }
    });

    test('normaliza mayusculas y espacios', () {
      expect(Incidencia.desdeJson(registro(' alta ')).prioridad, 'Alta');
    });

    test('un valor no aprobado se toma como Media', () {
      expect(Incidencia.desdeJson(registro('Urgente')).prioridad, 'Media');
      expect(Incidencia.desdeJson(registro(3)).prioridad, 'Media');
      expect(Incidencia.desdeJson(registro('')).prioridad, 'Media');
    });

    test('toJson guarda la prioridad', () {
      expect(
          Incidencia.desdeJson(registro('Baja')).toJson()['prioridad'], 'Baja');
    });
  });
}
