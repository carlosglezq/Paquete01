# Paquete01 — Práctica 01: mantenimiento de una aplicación heredada

Repositorio de trabajo de la Práctica 01 (NexaSoft Solutions, mesa de ayuda técnica).
Los datos de la aplicación son ficticios.

## Contenido

| Ruta | Qué es |
|---|---|
| `nexasoft_incidencias/` | Proyecto Flutter recibido (código en `lib/`, datos semilla en `assets/`) |
| `docs/Guia_Practica_01_Estudiantes.pdf` | Guía de la práctica: tickets, sesiones y política de IA |
| `docs/dia01/` | Notas de investigación, mapa de componentes y capturas del día 1 |
| `docs/dia02/` | Notas de las correcciones, salidas de consola y capturas del día 2 |
| `bitacoras/` | Bitácora individual por jornada |

## Ejecutar

```bash
cd nexasoft_incidencias
flutter pub get
flutter run -d chrome
```

## Tickets

| Ticket | Estado | Rama | Commit |
|---|---|---|---|
| BUG-001 El cambio de estado desaparece | Resuelto, pendiente de revisión | `fix/bug-001` | `a833b9e` |
| BUG-002 La búsqueda omite registros existentes | Resuelto, pendiente de revisión | `fix/bug-002` | `5ef23bf` |
| BUG-003 El tablero presenta cantidades incorrectas | Resuelto, pendiente de revisión | `fix/bug-003` | `8bc2faa` |
| FEAT-001 Clasificación por prioridad | Abierto | `feat/prioridades` | — |
| FEAT-002 Filtros combinables | Abierto | `feat/filtros` | — |

Pruebas: `cd nexasoft_incidencias && flutter test` (17 pruebas).

Reproducción: [`docs/dia01/notas_investigacion.md`](docs/dia01/notas_investigacion.md) · Correcciones: [`docs/dia02/notas_correcciones.md`](docs/dia02/notas_correcciones.md).
