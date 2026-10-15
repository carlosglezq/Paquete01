# Día 3 — FEAT-001 Clasificación por prioridad

Práctica 01 · NexaSoft Solutions · `nexasoft_incidencias`
Fecha: 14/10/2026 (20:20-20:50) · Flutter 3.47.4 / Dart 3.13.3, Chrome 155 (web).
Rama `feat/prioridades` · commit `f95dcf0` · integración `a617019`.

## Condición previa

- El formulario de alta pide título, descripción, cliente y categoría; no hay prioridad (E01).
- El detalle solo permite cambiar el estado (E02).
- Los registros guardados no tienen el campo `prioridad`. Antes de cambiar el código se dejaron
  11 registros guardados con la versión anterior en el perfil de pruebas de Chrome: INC-105 cambiado a
  *En proceso* y un alta, "Registro antiguo sin prioridad". Se comprobó en el almacenamiento local
  que ninguno tenía `prioridad`.

## Diseño

| Pieza | Cambio |
|---|---|
| `lib/model/incidencia.dart` | Campo `prioridad`, lista `prioridades = [Baja, Media, Alta]` y `prioridadInicial = Media`. `normalizarPrioridad` acepta las tres opciones sin distinguir mayúsculas ni espacios; cualquier otro valor o la ausencia del campo da *Media*. `desdeJson` la usa y `toJson` guarda la prioridad. |
| `lib/services/gestor_incidencias.dart` | `crear(..., {prioridad = Media})` y nuevo `cambiarPrioridad(id, prioridad)`, que guarda igual que `cambiarEstado`. `validarPrioridad` lanza `ArgumentError` si el valor no es uno de los tres. |
| `lib/ui/pantalla_nueva.dart` | Selector "Prioridad" con *Media* preseleccionada. |
| `lib/ui/pantalla_detalle.dart` | Selector "Prioridad" bajo el de estado. Los dos usan el mismo `guardarCambio` (indicador de progreso y mensaje de error). |
| `lib/ui/pantalla_principal.dart` | Cada tarjeta muestra "Prioridad X" junto al estado, con color propio (Alta rojo oscuro, Media azul, Baja gris). |

Decisiones:

- **Misma clave de almacenamiento** (`nexasoft_incidencias_v1`). Cambiarla habría hecho que los datos
  guardados no se leyeran, que es justo lo que el ticket pide evitar.
- **No se modificó la semilla JSON.** Así la semilla también es un caso de "registro antiguo" y se
  comprueba en cada *Restablecer demostración*.
- **Dos niveles de protección contra valores no aprobados.** La interfaz solo ofrece las tres opciones y el
  servicio rechaza cualquier otra. Los datos que ya estén guardados se normalizan al leerlos, en lugar
  de hacer fallar la app.

## Pruebas automáticas

12 pruebas nuevas (5 de modelo, 7 de servicio); `flutter test` da 29 de 29. `flutter analyze` sigue con
los mismos 3 avisos `info` de días anteriores; los selectores nuevos usan `initialValue` para no sumar
avisos de API obsoleta.

## Verificación en Chrome

Mismo perfil que tenía los datos de la versión anterior; cada reinicio es cerrar Chrome por completo.

| # | Escenario | Esperado | Obtenido | Evidencia |
|---|---|---|---|---|
| 1 | Abrir con 11 registros guardados sin prioridad | Abre sin fallar, todos *Media*, INC-105 conserva *En proceso* | Igual | E03, E04 |
| 2 | Alta "Servidor de correo caído" con prioridad *Alta* | Aparece en la lista con *Alta* | Igual | E05, E06 |
| 3 | INC-103: cambiar prioridad *Media* → *Baja* desde el detalle | Detalle y lista muestran *Baja*; estado sigue *Pendiente* | Igual | E07, E08 |
| 4 | Reiniciar | Nueva sigue *Alta*, INC-103 sigue *Baja*, resto *Media* | Igual | E09, E10 |
| 5 | Cambiar el estado de la nueva a *En proceso* | Conserva *Alta* | Igual | E11 |
| 6 | Escribir en el almacenamiento `"Urgente"` (INC-104), `" alta "` (INC-106) y quitar el campo (INC-108); reiniciar | INC-104 *Media*, INC-106 *Alta*, INC-108 *Media*, sin errores | Igual | E11 |
| 7 | Tablero con 12 registros | 6 / 3 / 3 y luego 5 / 4 / 3, iguales al conteo manual | Igual | E06, E11 |
| 8 | *Restablecer demostración* | 10 registros, todos *Media*, almacenamiento vacío | Igual | extra |

*Restablecer demostración* se usó una vez, al final, para limpiar los datos de prueba.

## Pendiente

- Revisión por otro integrante: no se hizo.
- FEAT-002 (filtro por prioridad) usará `Incidencia.prioridades` para las opciones del filtro.
