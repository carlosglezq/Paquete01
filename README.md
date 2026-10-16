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
| `docs/dia03/` | Notas de FEAT-001, salidas de consola y capturas del día 3 |
| `docs/dia04/` | Notas de FEAT-002 y de la regresión final, salidas de consola y capturas del día 4 |
| `docs/reporte_final.md` | Registro de tickets, regresión y resumen final |
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
| FEAT-001 Clasificación por prioridad | Resuelto, pendiente de revisión | `feat/prioridades` | `f95dcf0` |
| FEAT-002 Filtros combinables | Resuelto, pendiente de revisión | `feat/filtros` | `7f28102` |

Pruebas: `cd nexasoft_incidencias && flutter test` (39 pruebas). Versión revisada: `1.1.0`, etiqueta `v1.1.0`.

Reproducción: [`docs/dia01/notas_investigacion.md`](docs/dia01/notas_investigacion.md) · Correcciones: [`docs/dia02/notas_correcciones.md`](docs/dia02/notas_correcciones.md) · FEAT-001: [`docs/dia03/notas_feat-001.md`](docs/dia03/notas_feat-001.md). · FEAT-002 y regresión: [`docs/dia04/notas_feat-002_y_regresion.md`](docs/dia04/notas_feat-002_y_regresion.md) · **Reporte final: [`docs/reporte_final.md`](docs/reporte_final.md)**.
