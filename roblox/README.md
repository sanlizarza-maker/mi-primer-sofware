# Criaturas Caóticas 🥔🦈🐔 (juego de Roblox)

Un juego de **coleccionar y robar** criaturas absurdas, inspirado en los géneros que más se juegan
ahora mismo en Roblox (tycoon/idle + coleccionables con rarezas + robar a otros jugadores),
pero con mecánicas y personajes propios.

## Cómo se juega
- Por la **cinta amarilla** del centro pasan criaturas al azar. Acércate y pulsa **E** para comprarlas.
- Cada criatura en tu base **genera monedas por segundo**, aunque no hagas nada.
- **Rarezas:** Común → Poco común → Raro → Épico → Legendario → Mítico → **Secreto**.
- **Mutaciones** por pura suerte: Dorado (x2), Diamante (x3), **Arcoíris (x5)**.
- **Robar 😈:** mantén E sobre la criatura de otro jugador y llévala corriendo a tu base.
  Vas más lento, y si su dueño te toca, la recupera.
- **Escudo 🛡️:** el botón rojo de tu base te protege de robos durante 30 s (luego se recarga 60 s).
- **Vender (F):** recuperas el 50% del valor.
- **Renacer 🔁:** reinicia tus monedas y criaturas, pero ganas +50% para siempre.
- **Lluvia de suerte 🍀:** cada 5 minutos, durante 60 s, salen muchas más criaturas raras y mutaciones.
- **📅 Recompensa diaria:** cada 20 h. Racha de 7 días (se pierde si pasas 48 h sin entrar); el día 7 regala una criatura Épica.
- **🎁 Códigos:** `LANZAMIENTO`, `CAPIBARA`, `POLLOESPACIAL` (cámbialos en `Config`).
- **🛒 Tienda de pases:** x2 Monedas, +5 Espacios (pedestales dorados), Escudo VIP.
- El progreso se guarda solo (DataStore).

## Configurar los pases de pago (para ganar Robux)
1. Publica el juego primero (File → Publish to Roblox).
2. Ve a **create.roblox.com → Creaciones → tu juego → Monetización → Pases** y crea 3 pases
   (x2 Monedas, +5 Espacios, Escudo VIP), con imagen y precio.
3. Copia el **ID** de cada pase (el número de su enlace) y pégalo en `Config.Gamepasses` en lugar del `0`.
4. El precio que se muestra en la tienda se lee automáticamente de Roblox.

Mientras un pase tenga `id = 0`, en la tienda pone "Pronto" y no se puede comprar.

## Instalación en Roblox Studio (sin programas extra)
1. Abre Roblox Studio → **New** → **Baseplate**.
2. En el **Explorer**:
   - Clic derecho en **ReplicatedStorage** → Insert Object → **ModuleScript**. Llámalo `Config`
     y pega dentro el contenido de `src/ReplicatedStorage/Config.luau`.
   - Clic derecho en **ServerScriptService** → Insert Object → **Script**. Llámalo `GameServer`
     y pega `src/ServerScriptService/GameServer.server.luau`.
   - Abre **StarterPlayer** → clic derecho en **StarterPlayerScripts** → Insert Object →
     **LocalScript**. Llámalo `GameClient` y pega `src/StarterPlayerScripts/GameClient.client.luau`.
3. **Home → Game Settings → Security →** activa **Enable Studio Access to API Services**
   (si no, el guardado no funciona en Studio; el juego sí funciona).
4. Pulsa **Play**. El mapa se construye solo.
5. Para probar robos: **Test → Clients and Servers → 2 jugadores → Start**.
6. Publica: **File → Publish to Roblox**. En la página del juego pon **Max Players = 6**
   (hay 6 bases por servidor).

Si usas **Rojo**: `rojo serve` dentro de la carpeta `roblox/`.

Todo lo que quieras cambiar (precios, criaturas, tiempos) está en `Config`.

## Siendo sinceros: cómo hacer que se haga famoso
El código es la parte fácil. Lo que de verdad decide si un juego de Roblox despega es:

1. **Miniatura e icono.** Es lo que más influye en si la gente entra. Colores fuertes, una criatura
   gigante y cara de sorpresa. Prueba varias versiones.
2. **Que la gente vuelva al día siguiente.** Roblox recomienda los juegos que retienen jugadores
   (mira *Creator Dashboard → Analytics*: retención D1, tiempo de sesión).
3. **Actualizaciones cada semana.** Nuevas criaturas, eventos nuevos, códigos. Los juegos que suben
   hoy suelen sacar algo nuevo cada semana, y su título dice `[🆕 UPDATE]`.
4. **TikTok / YouTube Shorts.** Graba robos épicos, mutaciones Arcoíris o cuando sale el Secreto.
   Así se viralizan la mayoría de los juegos nuevos.
5. **Anuncios patrocinados** en Roblox (con Robux) para conseguir los primeros jugadores.
6. **Que se pueda jugar en el móvil.** La mayoría juega desde el móvil; prueba con el emulador
   de dispositivos de Studio.

## Sonidos y música
- Los sonidos usan archivos que trae Roblox. Si alguno no suena, cámbialo en `Config.Sounds`
  por uno del **Creator Store** (create.roblox.com → Creator Store → Audio): copia su número y
  ponlo como `"rbxassetid://NUMERO"`.
- Música: elige una canción del Creator Store y pon su id en `Config.Music`. Usa solo audio que
  tengas permiso de usar (las canciones famosas con copyright no se pueden subir a Roblox).

Lo que todavía no tiene y conviene añadir después: modelos 3D hechos a mano en Blender o Studio
(ahora están hechos con piezas simples), packs de monedas de compra única y una tabla de clasificación global.
