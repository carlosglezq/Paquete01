# Paquete01 — Práctica 01: mantenimiento de una aplicación heredada

Repositorio de trabajo de la Práctica 01 (NexaSoft Solutions, mesa de ayuda técnica).
Contiene solo la aplicación; las bitácoras y la documentación de la práctica se entregan por separado.
Los datos de la aplicación son ficticios.

## Contenido

| Ruta | Qué es |
|---|---|
| `nexasoft_incidencias/` | Proyecto Flutter recibido (código en `lib/`, datos semilla en `assets/`) |

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
