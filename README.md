# mi-primer-sofware

## Historia de Panamá — presentación / deck

`index.html` es una presentación autónoma (un solo archivo) que recorre cinco
siglos de historia de Panamá en 20 diapositivas bilingües (español · inglés),
desde los pueblos originarios hasta la Panamá actual.

Implementada a partir de un diseño de Claude Design (`Historia de Panamá.dc.html`).
El prototipo dependía de un runtime propietario (`deck-stage.js` / `support.js`);
aquí se reproduce el mismo diseño con un runtime propio en JavaScript, sin
dependencias externas más allá de las tipografías de Google Fonts
(Newsreader + Archivo).

### Uso

Abre `index.html` en cualquier navegador (o sírvelo con un servidor estático).

- **Navegación:** flechas ←/→, AvPág/RePág, barra espaciadora, `Inicio`/`Fin`,
  teclas numéricas `1`–`9`, o clic/toque en los lados izquierdo/derecho.
- **Reiniciar:** tecla `R`.
- **Enlace directo:** el número de diapositiva se guarda en el hash de la URL
  (por ejemplo `index.html#6`).
- **PDF:** Imprimir → Guardar como PDF genera una página por diapositiva.

El lienzo es de 1920×1080 y se escala automáticamente para ajustarse a la
ventana, con letterboxing.
