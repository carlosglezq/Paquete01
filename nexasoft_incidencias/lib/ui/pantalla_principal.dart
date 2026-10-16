import 'package:flutter/material.dart';
import '../model/incidencia.dart';
import '../services/gestor_incidencias.dart';
import 'pantalla_detalle.dart';
import 'pantalla_nueva.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final GestorIncidencias g = GestorIncidencias();
  bool cargando = true;
  String? error;
  String busqueda = '';
  String? filtroEstado;
  String? filtroPrioridad;
  final buscador = TextEditingController();

  bool get hayFiltros =>
      busqueda.trim().isNotEmpty || filtroEstado != null || filtroPrioridad != null;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    buscador.dispose();
    super.dispose();
  }

  void limpiarFiltros() {
    buscador.clear();
    setState(() {
      busqueda = '';
      filtroEstado = null;
      filtroPrioridad = null;
    });
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      await g.iniciar();
    } catch (e) {
      error = 'No se pudieron cargar las incidencias: $e';
    }
    if (mounted) setState(() => cargando = false);
  }

  Color colorEstado(String estado) {
    if (estado == 'Resuelta') return const Color(0xFF147D64);
    if (estado == 'En proceso') return const Color(0xFFB56B13);
    return const Color(0xFFAC4052);
  }

  Color colorPrioridad(String prioridad) {
    if (prioridad == 'Alta') return const Color(0xFF9B1C1C);
    if (prioridad == 'Baja') return const Color(0xFF5F6B7A);
    return const Color(0xFF174C83);
  }

  Widget resumen(String etiqueta, String valor, IconData icono) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icono, size: 19, color: const Color(0xFF174C83)),
              const SizedBox(height: 4),
              Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(etiqueta, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget filtro(String etiqueta, String todos, List<String> opciones,
      String? actual, ValueChanged<String?> alCambiar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 3),
      child: Row(children: [
        SizedBox(width: 76, child: Text(etiqueta, style: const TextStyle(color: Colors.black54))),
        Expanded(
          child: Wrap(spacing: 8, runSpacing: 4, children: [
            for (final opcion in [null, ...opciones])
              ChoiceChip(
                label: Text(opcion ?? todos),
                selected: actual == opcion,
                onSelected: (_) => alCambiar(opcion),
              ),
          ]),
        ),
      ]),
    );
  }

  Future<void> abrirDetalle(Incidencia item) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => PantallaDetalle(gestor: g, id: item.id)),
    );
    if (mounted) setState(() {});
  }

  Future<void> abrirFormulario() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaNueva(gestor: g)),
    );
    if (guardado == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incidencia registrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = g.filtrar(busqueda, estado: filtroEstado, prioridad: filtroPrioridad);
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexaSoft | Incidencias'),
        actions: [
          IconButton(
            tooltip: 'Restablecer datos de demostración',
            onPressed: () async {
              final aceptar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restablecer demostración'),
                  content: const Text('Se descartarán los cambios locales y se cargarán las incidencias iniciales.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restablecer')),
                  ],
                ),
              );
              if (aceptar != true) return;
              try {
                await g.reiniciarDemo();
                if (mounted) setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al reiniciar: $e')));
                }
              }
            },
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      floatingActionButton: cargando || error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: abrirFormulario,
              label: const Text('Nueva incidencia'),
              icon: const Icon(Icons.add),
            ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: cargar, child: const Text('Reintentar')),
                  ]),
                ))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                          child: Row(children: [
                            resumen('Pendientes', '${g.contar('Pendiente')}', Icons.pending_actions),
                            resumen('En proceso', '${g.contar('En proceso')}', Icons.build_outlined),
                            resumen('Resueltas', '${g.contar('Resuelta')}', Icons.check_circle_outline),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                          child: TextField(
                            controller: buscador,
                            decoration: const InputDecoration(
                              labelText: 'Buscar incidencias',
                              hintText: 'Ejemplo: WiFi, correo, pantalla',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (texto) => setState(() => busqueda = texto),
                          ),
                        ),
                        filtro('Estado', 'Todos', Incidencia.estados, filtroEstado,
                            (v) => setState(() => filtroEstado = v)),
                        filtro('Prioridad', 'Todas', Incidencia.prioridades, filtroPrioridad,
                            (v) => setState(() => filtroPrioridad = v)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 12, 2),
                          child: Row(children: [
                            Text('${items.length} de ${g.incidencias.length} registros',
                                style: const TextStyle(color: Colors.black54)),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: hayFiltros ? limpiarFiltros : null,
                              icon: const Icon(Icons.filter_alt_off_outlined),
                              label: const Text('Limpiar búsqueda y filtros'),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: items.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      const Icon(Icons.search_off, size: 40, color: Colors.black38),
                                      const SizedBox(height: 8),
                                      Text(
                                        hayFiltros
                                            ? 'Ninguna incidencia cumple la búsqueda y los filtros activos.'
                                            : 'No hay incidencias registradas.',
                                        textAlign: TextAlign.center,
                                      ),
                                      if (hayFiltros)
                                        TextButton(
                                          onPressed: limpiarFiltros,
                                          child: const Text('Mostrar todas las incidencias'),
                                        ),
                                    ]),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100),
                                  itemCount: items.length,
                                  itemBuilder: (context, i) {
                                    final item = items[i];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        title: Text(item.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${item.id}  ·  ${item.cliente}'),
                                              const SizedBox(height: 6),
                                              Row(children: [
                                                Text(item.estado, style: TextStyle(
                                                  color: colorEstado(item.estado), fontWeight: FontWeight.bold,
                                                )),
                                                const SizedBox(width: 16),
                                                Icon(Icons.flag_outlined, size: 16, color: colorPrioridad(item.prioridad)),
                                                const SizedBox(width: 4),
                                                Text('Prioridad ${item.prioridad}', style: TextStyle(
                                                  color: colorPrioridad(item.prioridad), fontWeight: FontWeight.w600,
                                                )),
                                              ]),
                                            ],
                                          ),
                                        ),
                                        trailing: const Icon(Icons.chevron_right),
                                        onTap: () => abrirDetalle(item),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
