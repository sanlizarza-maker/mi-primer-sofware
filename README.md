# Isla Caos

Battle royale en 3D que se juega en el navegador, hecho con Three.js. El juego está en `index.html` y los modelos y texturas en `assets/`.

Ábrelo con cualquier servidor estático (o con GitHub Pages) y juega con teclado y ratón, o con la pantalla táctil en móvil y tablet.

## Qué tiene

- Isla con 9 zonas: Pueblo Pepino, Torres Tortilla, Castillo Churro, Granja Gallo, Puerto Pato, Barrio Burrito, Mercado Mango, Dunas Doradas y Lago Llama.
- Casas en las que se puede entrar, con escaleras, segundo piso y cofres dentro.
- Río con puentes, lago, desierto con pirámide y oasis, y caminos entre las zonas.
- Noria, molino y faro que se mueven.
- Autobús con globo, caída libre y planeador.
- 5 armas con 6 rarezas, de común a mítica, y 4 armas exóticas con habilidades: Cañón de Plasma (explota), Rifle Relámpago (el rayo salta entre enemigos), Escopeta Dragón (quema) y Francotirador Fantasma (atraviesa paredes).
- Construcción de muros, rampas y suelos.
- Tormenta en 5 fases.
- 50 jugadores por partida en ordenador y 30 en pantallas táctiles, con un Jefe que defiende el castillo y suelta una exótica.
- Coches deportivos y avionetas acrobáticas con aeródromo.
- Cajas de suministros que caen del cielo y llamas piñata llenas de botín.
- Lobby con tu personaje y dos compañeros, Taquilla, Tienda y Desafíos.
- Monedas Caos que se ganan jugando (y un regalo diario) para comprar armas exóticas de salida y trajes en la Tienda.
- Nombre de jugador al entrar (se puede cambiar tocándolo en el lobby).
- Rangos competitivos de Bronce I a Leyenda: se ganan o pierden puntos de rango según el puesto y las bajas. Cada rango importante da monedas y algunos un traje exclusivo (Soldado de Oro, Robo Diamante, Campeón Sombra y Robo Leyenda).
- Experiencia, niveles, desafíos y 16 trajes. El progreso se guarda en el navegador.

## Jugar con amigos (en línea)

1. Abran el juego cada uno en su dispositivo (iPad, tableta o computadora) con internet.
2. Uno va a la pestaña **Amigos** y pulsa **Crear sala**. Sale un código de 4 letras.
3. Los demás escriben ese código en **Unirse**. Caben hasta 8 jugadores.
4. El anfitrión elige el modo (**Equipo vs bots** o **Todos contra todos**) y pulsa **Empezar partida**.

Cómo funciona: los navegadores se conectan directamente entre sí (WebRTC, con PeerJS solo para encontrarse).
El anfitrión mueve los bots y la tormenta, así que debe dejar el juego abierto y en primer plano.
Algunas redes muy cerradas (datos móviles de ciertas compañías, wifi de colegios) pueden bloquear la conexión directa.

## Controles

| Ordenador | Táctil |
| --- | --- |
| WASD moverse, Shift correr, Espacio saltar o abrir el planeador | Joystick a la izquierda |
| Ratón para apuntar, clic izquierdo dispara, clic derecho mirilla | Arrastra a la derecha para mirar, botón FUEGO |
| 1-5 armas, R recargar, F pico | ARMA, RECARGAR, PICO |
| Q construir (1 muro, 2 rampa, 3 suelo) | CONSTRUIR y botón de pieza |
| E abrir o recoger, H botiquín, G poción, B bailar, M mapa | Botón amarillo de acción, CURAR, BAILE |
| C o Ctrl deslizarse al correr · Espacio contra un borde para escalar | DESLIZAR · SALTAR contra un borde |
| Coche: E subir/bajar, W/S acelerar y frenar, A/D girar, Espacio freno de mano, Shift turbo | Botón Conducir, joystick, FRENO, TURBO |
| Avioneta: E subir/saltar, el ratón o las flechas dirigen, W potencia (en el aire el motor va solo), Shift turbo, clic ametralladoras, L aterrizaje automático | Botón Pilotar, cruceta ▲▼◀▶, + y − MOTOR, ATERRIZAR, TURBO, FUEGO |
| — | Disparo automático en táctil (se puede quitar en el lobby) |

## Créditos de los recursos

- Personajes Soldier y Xbot, con sus animaciones: ejemplos de [three.js](https://github.com/mrdoob/three.js) (MIT), creados con Mixamo.
- Personaje Michelle y su baile de samba: ejemplos de three.js, creados con [Mixamo](https://www.mixamo.com) (Adobe). Sus animaciones de andar y correr se adaptan en el juego desde las del soldado.
- Robot "RobotExpressive" con sus animaciones: de Tomás Laulhé ([Quaternius](https://quaternius.com)), incluido en los ejemplos de three.js (CC0).
- Árboles: generados con [ez-tree](https://github.com/dgreenheck/ez-tree) de Daniel Greenheck (MIT). Sus texturas de corteza vienen de Poly Haven y TextureCan.
- Rocas, hierba 3D y texturas de tierra y hierba (`grass.jpg`): repositorio de ez-tree (MIT).
- Cielo HDRI `quarry_01`: [Poly Haven](https://polyhaven.com) (CC0).
- Texturas de hierba con relieve, ladrillo, madera y agua: ejemplos de three.js (MIT).
- Sonidos de interfaz: packs "UI Audio" e "Interface Sounds" de [Kenney](https://kenney.nl) (CC0), incrustados en el juego.
- Coche deportivo: modelo "Ferrari 458 Italia" de vicent091036 en Sketchfab, tal y como se incluye en los ejemplos de three.js ([CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)). Se ha simplificado para que cargue más rápido.
