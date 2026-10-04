# MiniCraft

Un prototipo de juego de bloques tipo Minecraft que corre en el navegador. Usa [Three.js](https://threejs.org/) y todo está en un solo archivo: `index.html`.

## Cómo jugar

1. Abre `index.html` con doble clic en Chrome, Edge o Firefox (o en el navegador del celular). Necesitas internet porque Three.js se descarga de un CDN.
2. Haz clic o toca la pantalla para empezar.

### En celular o tablet

Usa el joystick de la izquierda para caminar y desliza el dedo por la pantalla para mirar. Los botones de la derecha sirven para romper, poner, saltar, volar y guardar. Toca un bloque de la barra de arriba para elegirlo. Se juega mejor con la pantalla en horizontal.

### En computadora

| Tecla | Acción |
|---|---|
| W A S D | Moverse |
| Espacio | Saltar |
| Shift | Correr |
| F | Activar o desactivar el vuelo (Espacio sube, C baja) |
| Clic izquierdo | Romper un bloque |
| Clic derecho | Poner un bloque |
| 1–8 / rueda del ratón | Elegir bloque |
| G | Guardar el mundo en el navegador |
| Esc | Pausa |

## Qué tiene

- Mundo de 128×128×48 bloques generado con ruido (colinas, playas y árboles)
- Malla por chunks (16×16) que solo dibuja las caras visibles
- Oclusión ambiental simple en las esquinas
- Física con gravedad y colisiones
- Guardado en `localStorage`
- Controles táctiles para celular y tablet

## Qué no tiene (todavía)

Texturas reales, agua, mundo infinito, mobs, inventario, crafteo, ciclo de día y noche, sonido y multijugador.

Para empezar de nuevo con un mundo recién generado, borra los datos del sitio en tu navegador.
