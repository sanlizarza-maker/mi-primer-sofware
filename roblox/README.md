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
- El progreso se guarda solo (DataStore).

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

Lo que todavía no tiene y conviene añadir después: modelos 3D más bonitos (ahora son esferas
y cubos con ojos), sonidos, música, gamepasses (x2 monedas, más espacios), códigos de recompensa,
recompensa diaria, y tabla de clasificación global.
