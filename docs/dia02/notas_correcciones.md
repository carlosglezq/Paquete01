# Día 2 — Corrección de BUG-001, BUG-002 y BUG-003

Práctica 01 · NexaSoft Solutions · `nexasoft_incidencias`
Fecha: 13/10/2026 (segunda sesión, 20:06-20:40) · Flutter 3.47.4 / Dart 3.13.3, Chrome 155 (web).

Las tres causas estaban en `lib/services/gestor_incidencias.dart`, como apuntaban las hipótesis del día 1.
No se tocó ninguna pantalla ni `assets/`.

## Orden de trabajo

BUG-001 → BUG-003 → BUG-002, de mayor a menor impacto (pérdida de datos, información incorrecta,
usabilidad). **Este orden lo propuse yo; no se acordó con el líder técnico.**

Para cada ticket: rama propia desde `main`, pruebas automáticas nuevas que fallan, corrección, pruebas en
verde, `flutter analyze`, commit y `merge --no-ff`. La verificación en Chrome se hizo **después de integrar
las tres ramas**, con los mismos escenarios del día 1.

## BUG-001 — El cambio de estado desaparece — RESUELTO

- **Causa:** `cambiarEstado` modificaba el objeto en memoria y terminaba sin llamar a
  `AlmacenLocal.guardar`. El único guardado estaba en `crear`. Por eso el cambio se perdía al reiniciar,
  salvo que después se registrara una incidencia (hallazgo del día 1).
- **Cambio:** una línea, `await datos.guardar(incidencias);`, dentro del `if` que encuentra el registro.
  Si el id no existe no se escribe nada.
- **Rama / commits:** `fix/bug-001` · `a833b9e` · integración `9ac60a7`.

| Prueba | Antes | Después |
|---|---|---|
| Automática: el estado se conserva al reiniciar | Falla (`Expected 'Resuelta'`, `Actual 'Pendiente'`) | Pasa |
| Automática: cambiar un registro no altera los demás | Pasa | Pasa |
| Automática: una incidencia nueva sigue existiendo | Pasa | Pasa |
| Automática: un id inexistente no modifica nada | Pasa | Pasa |
| Chrome: INC-101 → Resuelta, cerrar y abrir | Vuelve a Pendiente (E05) | Sigue Resuelta (E06, E07) |
| Chrome: almacenamiento local tras el cambio | Vacío | Clave `nexasoft_incidencias_v1` presente |

## BUG-003 — El tablero presenta cantidades incorrectas — RESUELTO

- **Causa:** `contar('Pendiente')` devolvía el campo `cantidadPendientes`, una copia que solo se
  recalculaba en `iniciar()` y se incrementaba en `crear()`. `cambiarEstado` no la actualizaba.
- **Cambio:** se elimina `cantidadPendientes`. Los tres estados se cuentan siempre sobre `incidencias`.
- **Criterio de cálculo:** total de un estado = número de elementos de la lista completa en memoria con
  ese estado. No interviene la búsqueda, y la lista en memoria es la misma que se guarda, así que el total
  es igual antes y después de reiniciar.
- **Rama / commits:** `fix/bug-003` · `8bc2faa` · integración `506c82c`.

| Escenario | Conteo manual | Tablero antes | Tablero después |
|---|---|---|---|
| INC-101 Pendiente → Resuelta | 4 / 2 / 4 | 5 / 2 / 4 (E08) | 4 / 2 / 4 (E06) |
| Reinicio | 4 / 2 / 4 | — (el cambio se perdía) | 4 / 2 / 4 (E07) |
| INC-104 Resuelta → Pendiente | 5 / 2 / 3 | no sumaba | 5 / 2 / 3 (E09) |
| Registrar incidencia | 6 / 2 / 3, 11 registros | sumaba sobre un número ya incorrecto | 6 / 2 / 3 (E10) |
| Segundo reinicio | 6 / 2 / 3 | — | 6 / 2 / 3 (E11) |
| Búsqueda "monitor" activa | 6 / 2 / 3 | — | 6 / 2 / 3 con 1 registro en lista (E12) |

Pruebas automáticas: 6 nuevas; antes de corregir fallaban 4.

## BUG-002 — La búsqueda omite registros existentes — RESUELTO

- **Causa:** `buscar` usaba `x.titulo.contains(texto)`: distinguía mayúsculas, no miraba la descripción y
  comparaba con la consulta sin recortar.
- **Cambio:** la consulta se recorta y se pasa a minúsculas una vez; se compara contra título y
  descripción en minúsculas. Con consulta vacía se devuelve la lista completa, igual que antes.
- **Rama / commits:** `fix/bug-002` · `5ef23bf` · integración `4e8638c`.

| Consulta | Antes | Después |
|---|---|---|
| `wifi` | 0 registros (E01) | INC-102 (E02) |
| `WiFi` | INC-102 | INC-102 |
| `túnel` | 0 registros | INC-106 (E03) |
| `  WiFi  ` | 0 registros | INC-102 (E04) |
| (vacío) | 10 | 10 |
| `zzz` | — | 0 registros y mensaje "No se encontraron incidencias" |

Pruebas automáticas: 6 nuevas; antes de corregir fallaban 4.

Límite conocido: la búsqueda no ignora acentos (`tunel` sin acento no encuentra "túnel"). El ticket no lo
pide; queda anotado por si el cliente lo solicita.

## Regresión

- `flutter test`: 17 pruebas, todas pasan (1 original + 16 nuevas). Salida en `consola/`.
- `flutter analyze`: los mismos 3 avisos `info` del día 1, ninguno nuevo.
- Recorrido completo en Chrome con dos reinicios reales: alta de incidencia, cambio de estado en ambos
  sentidos, búsqueda y tablero (E06-E12).
- *Restablecer demostración* se usó una vez, al final, para limpiar los datos de prueba.

## Pendiente

- Revisión por otro integrante antes de dar por cerrados los tickets: **no se hizo**.
- Las ramas `fix/bug-00X` existen solo en local; `main` contiene las tres integraciones.
- Nueva dependencia de desarrollo: `shared_preferences_platform_interface` (ya era transitiva), usada
  solo en pruebas para tener un almacenamiento en memoria.
