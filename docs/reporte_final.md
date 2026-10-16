# Reporte final — Práctica 01, mantenimiento de `nexasoft_incidencias`

Versión entregada: **1.1.0** (etiqueta `v1.1.0`, commit `be06ada`) · Repositorio privado `carlosglezq/Paquete01`.
Periodo: 13/10/2026 al 15/10/2026, cuatro sesiones.

## 1. Registro de tickets

| Ticket | Estado | Causa / alcance | Rama · commit | Prueba que respalda el estado |
|---|---|---|---|---|
| BUG-001 El cambio de estado desaparece | **Resuelto** (sin revisión de otro integrante) | `cambiarEstado` no guardaba; solo `crear` escribía en el almacenamiento | `fix/bug-001` · `a833b9e` | 4 pruebas automáticas; en Chrome, INC-101 conserva *Resuelta* tras reiniciar (día 2 E7, día 4 E11) |
| BUG-002 La búsqueda omite registros existentes | **Resuelto** (sin revisión) | Comparación literal, solo en el título y sin recortar | `fix/bug-002` · `5ef23bf` | 6 pruebas; "wifi", "túnel" y "  WiFi  " encuentran su registro (día 2 E2-E4) |
| BUG-003 El tablero presenta cantidades incorrectas | **Resuelto** (sin revisión) | Pendientes salía de un contador en caché que no se actualizaba | `fix/bug-003` · `8bc2faa` | 6 pruebas; tablero igual al conteo manual en 7 escenarios (día 2 E6, E9-E11) |
| FEAT-001 Clasificación por prioridad | **Resuelto** (sin revisión) | Campo con Baja/Media/Alta; *Media* para registros sin prioridad o con valor no aprobado | `feat/prioridades` · `f95dcf0` | 12 pruebas; datos de la versión anterior abren con *Media*, alta con *Alta*, cambio y persistencia (día 3 E3-E11) |
| FEAT-002 Filtros combinables | **Resuelto** (sin revisión) | Chips de estado y prioridad combinados con la búsqueda, botón de limpiar y mensaje sin resultados | `feat/filtros` · `7f28102` | 10 pruebas (3 de pantalla); "pantalla" + *Pendiente* + *Alta* da solo INC-103 y limpiar regresa a 10 (día 4 E2-E6) |

Ningún ticket quedó bloqueado. Todos dicen "sin revisión" porque la guía pide que otro integrante revise
al menos una prueba antes de integrar, y eso no se hizo.

## 2. Pruebas de regresión de la versión 1.1.0

- `flutter test --concurrency=1`: 39 de 39 (`docs/dia04/consola/C1_flutter_test.txt`).
- `flutter analyze`: 3 avisos `info` que ya existían en la versión recibida; ninguno nuevo.
- Recorrido en Chrome sobre `main` con reinicio real: búsqueda (BUG-002), cambio de estado y
  persistencia (BUG-001), tablero (BUG-003), alta con prioridad (FEAT-001) y filtros combinados (FEAT-002).
  Ver `docs/dia04/notas_feat-002_y_regresion.md`.

## 3. Resumen final

**Qué funcionó**

- Reproducir los tres fallos con capturas antes de tocar el código. Las tres hipótesis del día 1
  resultaron ser las causas reales, y cada corrección fue de pocas líneas en un solo archivo.
- Escribir primero una prueba que fallara y después corregir: cada ticket tiene evidencia automática
  del antes y el después, además de las capturas.
- Una rama por ticket con `merge --no-ff`: el historial muestra qué entró con cada ticket.
- Probar FEAT-001 con datos guardados por la versión anterior, no solo con la semilla.

**Qué sigue pendiente**

- Revisión por otro integrante de al menos una prueba por ticket.
- Confirmar con el líder técnico el orden de prioridad de los bugs (se eligió por impacto) y la
  autorización del uso de IA declarado en las bitácoras.
- Probar en un teléfono Android real; toda la verificación se hizo en Chrome (web).

**Riesgos conocidos**

- La búsqueda no ignora acentos: "tunel" no encuentra "túnel". El ticket no lo pedía.
- Los filtros no se conservan al reiniciar la app (vuelven a *Todos* / *Todas*). Tampoco lo pedía.
- `pub get` avisa que Windows necesita el Modo de desarrollador para compilar la versión de escritorio
  con plugins; no afecta a web ni a Android.
- Toda la lista se guarda completa en cada cambio. Con pocos registros no importa; con miles habría que
  revisar el almacenamiento.
- Siguen los 3 avisos de `flutter analyze` heredados (API obsoleta y `BuildContext` tras `await`).
