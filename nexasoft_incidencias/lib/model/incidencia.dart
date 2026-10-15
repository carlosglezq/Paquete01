class Incidencia {
  static const prioridades = ['Baja', 'Media', 'Alta'];
  static const prioridadInicial = 'Media';

  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String prioridad;

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    this.prioridad = prioridadInicial,
  });

  /// Devuelve una de las prioridades aprobadas. Un registro guardado antes de
  /// existir la prioridad, o con un valor no reconocido, se toma como Media.
  static String normalizarPrioridad(Object? valor) {
    final texto = valor?.toString().trim().toLowerCase() ?? '';
    for (final p in prioridades) {
      if (p.toLowerCase() == texto) return p;
    }
    return prioridadInicial;
  }

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      prioridad: normalizarPrioridad(m['prioridad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad,
    };
  }
}
