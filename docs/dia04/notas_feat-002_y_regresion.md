# Día 4 — FEAT-002 Filtros combinables y versión revisada

Práctica 01 · NexaSoft Solutions · `nexasoft_incidencias`
Fecha: 15/10/2026 (21:10-21:45) · Flutter 3.47.4 / Dart 3.13.3, Chrome 155 (web).
Rama `feat/filtros` · commit `7f28102` · integración `bba75ec` · versión `1.1.0` (`be06ada`, etiqueta `v1.1.0`).

## Condición previa

La pantalla principal solo tenía la búsqueda de texto: no se podía filtrar por estado ni por prioridad,
no había forma de restablecer la consulta y, sin resultados, se mostraba "No se encontraron incidencias".

## Diseño

| Pieza | Cambio |
|---|---|
| `lib/services/gestor_incidencias.dart` | `filtrar(texto, {estado, prioridad})` encadena `buscar` (BUG-002) con los dos filtros. `null` equivale a *Todos* / *Todas*. |
| `lib/ui/pantalla_principal.dart` | Chips de **Estado** (Todos, Pendiente, En proceso, Resuelta) y **Prioridad** (Todas, Baja, Media, Alta). Contador "X de Y registros". Botón **Limpiar búsqueda y filtros**, visible siempre y activo solo si hay algo aplicado. Con cero resultados, mensaje e indicación "Mostrar todas las incidencias". |
| `lib/model/incidencia.dart` | `Incidencia.estados`, la misma lista para los filtros y el detalle. |

Decisiones:

- **Chips en lugar de listas desplegables.** Se ven todas las opciones a la vez y el estado de cada filtro
  queda a la vista, lo que hace evidente qué condiciones están activas. Además, al limpiar, los chips
  vuelven a *Todos* / *Todas* sin estado interno que reiniciar.
- **El tablero no usa `filtrar`.** Sigue contando sobre la lista completa (criterio de BUG-003).
- **Los filtros no se guardan.** Al reiniciar la app vuelven a *Todos* / *Todas*. El ticket no pide
  conservarlos; queda anotado por si el cliente lo quiere.

## Pruebas automáticas

10 nuevas: 7 del servicio (cada filtro solo, combinaciones, cero resultados, tablero intacto) y 3 de
pantalla con datos ficticios (`test/pantalla_principal_test.dart`). Las de pantalla pulsan los chips reales
y comprueban el contador, el mensaje, el botón de limpiar y que el campo de texto queda vacío.

`flutter test --concurrency=1`: **39 de 39** (BUG-001: 4, BUG-002: 6, BUG-003: 6, FEAT-001: 12,
FEAT-002: 10, original: 1). `flutter analyze`: los mismos 3 avisos `info` del día 1.

## Verificación en Chrome (prueba sugerida por el ticket y regresión)

Perfil limpio. Prioridades asignadas desde el detalle: INC-101, 102 y 103 *Alta*; INC-108 *Baja*.

| # | Escenario | Esperado | Obtenido | Evidencia |
|---|---|---|---|---|
| 1 | Pantalla inicial | Filtros en *Todos* / *Todas*, 10 de 10 | Igual | E01 |
| 2 | Texto "pantalla" | INC-103 e INC-110 | Igual (2 de 10) | E02 |
| 3 | + Estado *Pendiente* | INC-103 e INC-110 (ambas pendientes) | Igual | E03 |
| 4 | + Prioridad *Alta* | Solo INC-103 | Igual (1 de 10) | E04 |
| 5 | Cambiar a *En proceso* | 0 resultados con mensaje claro | "Ninguna incidencia cumple la búsqueda y los filtros activos." | E05 |
| 6 | Limpiar búsqueda y filtros | Campo vacío, *Todos* / *Todas*, 10 de 10, botón desactivado | Igual | E06 |
| 7 | Solo *Resuelta* | INC-104, 107, 109 | Igual | E07 |
| 8 | Solo *Alta* | INC-101, 102, 103 | Igual | E08 |
| 9 | Regresión BUG-002: "wifi" / "túnel" | INC-102 / INC-106 | Igual | — |
| 10 | Regresión BUG-001/003: INC-101 → *Resuelta* | Tablero 4 / 2 / 4 | Igual | E09 |
| 11 | Regresión FEAT-001: alta "Pantalla rota en mostrador" con *Alta* | Aparece con "pantalla" + *Pendiente* + *Alta* | Igual (2 de 11); tablero 5 / 2 / 4 sin cambiar por los filtros | E10 |
| 12 | Reiniciar | INC-101 sigue *Resuelta*; la nueva y las prioridades se conservan; 5 / 2 / 4 | Igual (11 de 11) | E11 |
| 13 | *Restablecer demostración* con filtros *Pendiente* + *Alta* activos | Semilla (todas *Media*): 0 resultados con mensaje; al limpiar, 10 de 10 | Igual | extra |

*Restablecer demostración* se usó una vez, al final.

Nota: tras limpiar, el `<input>` oculto que Flutter web usa para el teclado seguía reportando "pantalla"
al leerlo desde el navegador. El campo visible estaba vacío (E06) y la prueba de pantalla confirma que
el controlador queda vacío. Es un detalle interno de Flutter web, sin efecto para el usuario.

## Pendiente

- Revisión por otro integrante: no se hizo en ningún ticket.
- Revisar la pantalla principal en un teléfono real: los chips ocupan dos renglones más.
