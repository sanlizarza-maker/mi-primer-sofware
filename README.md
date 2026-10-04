# MiniCraft

Un juego de bloques tipo Minecraft que corre en el navegador, en computadora o celular. Usa [Three.js](https://threejs.org/) y todo está en un solo archivo: `index.html`.

## Cómo jugar

1. Abre `index.html` con doble clic en Chrome, Edge o Firefox, o en el navegador del celular. Necesitas internet porque Three.js se descarga de un CDN.
2. Haz clic o toca **Jugar**.

### En celular o tablet

**Para construir, toca el bloque en la pantalla** donde quieras poner el nuevo; se coloca pegado a la cara que tocaste. **Para romper, mantén el dedo sobre un bloque.** Usa el joystick de la izquierda para caminar; si lo empujas hasta el borde, corres. Desliza el dedo por la pantalla para mirar. Los botones de la derecha también sirven para romper o poner (apuntando con la cruz del centro), saltar o nadar, volar y guardar. Toca un bloque de la barra de arriba para elegirlo. El personaje salta solo cuando chocas con un escalón. Se juega mejor con la pantalla en horizontal.

### En computadora

| Tecla | Acción |
|---|---|
| W A S D o flechas | Moverse |
| Espacio | Saltar o nadar hacia arriba |
| Shift | Correr |
| F | Activar o desactivar el vuelo (Espacio sube, C baja) |
| Clic izquierdo (mantener) | Romper bloques |
| Clic derecho (mantener) | Poner bloques |
| 1–9 / rueda del ratón | Elegir bloque |
| G | Guardar el mundo en el navegador |
| Esc | Pausa |

Si tu navegador no deja capturar el ratón, el juego cambia solo a otro modo: arrastra para mirar y haz clic directamente sobre el bloque (izquierdo rompe, derecho pone). Si apuntas a algo demasiado lejos, un aviso te lo dice.

## Qué tiene

- Texturas pixeladas de 16×16 generadas por código
- Una isla de 128×128 bloques rodeada de océano, con playas, colinas, montañas nevadas, árboles, hierba alta, flores, carbón y hierro
- Agua transparente en la que puedes nadar
- Ciclo de día y noche de 10 minutos, con sol, luna, estrellas, atardecer y nubes
- Oclusión ambiental en las esquinas de los bloques
- Movimiento con aceleración suave, balanceo de cámara y zoom al correr
- Bloque en la mano con animación y partículas al romper
- Controles táctiles
- Guardado en `localStorage`

## Qué no tiene (todavía)

Mundo infinito, cuevas, agua que fluye, mobs, inventario, crafteo, sonido y multijugador.

Para empezar de nuevo con un mundo recién generado, borra los datos del sitio en tu navegador.
