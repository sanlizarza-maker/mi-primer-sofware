// Calculadora web — lógica principal

const resultadoEl = document.getElementById("resultado");
const historialEl = document.getElementById("historial");

let expresion = "";   // expresión que el usuario va escribiendo
let resultadoFinal = false; // indica si la pantalla muestra un resultado calculado

// Símbolos bonitos para mostrar vs operadores reales
const simbolos = { "/": "÷", "*": "×", "-": "−", "+": "+" };

function actualizarPantalla() {
    if (expresion === "") {
        resultadoEl.textContent = "0";
        return;
    }
    // Mostramos la expresión con símbolos amigables
    let visible = expresion.replace(/[\/\*\-\+]/g, (op) => ` ${simbolos[op]} `);
    resultadoEl.textContent = visible;
}

function agregarValor(valor) {
    // Si veníamos de un resultado y se pulsa un número, empezamos de cero
    if (resultadoFinal && !"+-*/".includes(valor)) {
        expresion = "";
    }
    resultadoFinal = false;

    const ultimo = expresion.slice(-1);

    // Evitar dos operadores seguidos: reemplazamos el anterior
    if ("+-*/".includes(valor) && "+-*/".includes(ultimo)) {
        expresion = expresion.slice(0, -1) + valor;
    } else if (valor === "." && /\.\d*$/.test(expresion.split(/[\+\-\*\/]/).pop())) {
        // Evitar dos puntos en el mismo número
        return;
    } else {
        expresion += valor;
    }

    actualizarPantalla();
}

function limpiar() {
    expresion = "";
    resultadoFinal = false;
    historialEl.textContent = "";
    actualizarPantalla();
}

function borrar() {
    if (resultadoFinal) {
        limpiar();
        return;
    }
    expresion = expresion.slice(0, -1);
    actualizarPantalla();
}

function porcentaje() {
    if (expresion === "") return;
    try {
        const valor = evaluar(expresion);
        expresion = String(valor / 100);
        resultadoFinal = true;
        actualizarPantalla();
    } catch {
        mostrarError();
    }
}

function calcular() {
    if (expresion === "") return;
    try {
        const valor = evaluar(expresion);
        historialEl.textContent = resultadoEl.textContent + " =";
        expresion = String(valor);
        resultadoFinal = true;
        actualizarPantalla();
    } catch {
        mostrarError();
    }
}

// Evaluación segura: solo permitimos números y operadores básicos
function evaluar(expr) {
    if (!/^[\d+\-*/.\s()]+$/.test(expr)) {
        throw new Error("Expresión no válida");
    }
    const valor = Function('"use strict"; return (' + expr + ")")();
    if (!isFinite(valor)) throw new Error("División por cero");
    // Redondeamos para evitar errores de coma flotante feos
    return Math.round((valor + Number.EPSILON) * 1e10) / 1e10;
}

function mostrarError() {
    resultadoEl.textContent = "Error";
    expresion = "";
    resultadoFinal = false;
}

// Conexión de los botones
document.querySelectorAll(".tecla").forEach((boton) => {
    boton.addEventListener("click", () => {
        const valor = boton.dataset.valor;
        const accion = boton.dataset.accion;

        if (valor !== undefined) {
            agregarValor(valor);
        } else if (accion === "limpiar") {
            limpiar();
        } else if (accion === "borrar") {
            borrar();
        } else if (accion === "porcentaje") {
            porcentaje();
        } else if (accion === "igual") {
            calcular();
        }
    });
});

// Soporte de teclado
document.addEventListener("keydown", (e) => {
    const tecla = e.key;
    if (/[\d]/.test(tecla) || "+-*/.".includes(tecla)) {
        agregarValor(tecla);
    } else if (tecla === "Enter" || tecla === "=") {
        e.preventDefault();
        calcular();
    } else if (tecla === "Backspace") {
        borrar();
    } else if (tecla === "Escape") {
        limpiar();
    } else if (tecla === "%") {
        porcentaje();
    }
});

// --- Cambio de tema claro/oscuro ---
const botonTema = document.getElementById("boton-tema");

function aplicarTema(tema) {
    if (tema === "claro") {
        document.body.classList.add("tema-claro");
        botonTema.textContent = "☀️";
    } else {
        document.body.classList.remove("tema-claro");
        botonTema.textContent = "🌙";
    }
}

// Cargar la preferencia guardada (si existe)
const temaGuardado = localStorage.getItem("tema") || "oscuro";
aplicarTema(temaGuardado);

botonTema.addEventListener("click", () => {
    const nuevoTema = document.body.classList.contains("tema-claro") ? "oscuro" : "claro";
    aplicarTema(nuevoTema);
    localStorage.setItem("tema", nuevoTema);
});

actualizarPantalla();
