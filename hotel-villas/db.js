// Base de datos SQLite (módulo integrado de Node.js >= 22)
import { DatabaseSync } from 'node:sqlite';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_PATH = path.join(__dirname, 'hotel.db');

export const db = new DatabaseSync(DB_PATH);

// --- Esquema ---
db.exec(`
  CREATE TABLE IF NOT EXISTS villas (
    id            INTEGER PRIMARY KEY,
    nombre        TEXT NOT NULL,
    tipo          TEXT NOT NULL,
    capacidad     INTEGER NOT NULL,
    precio_noche  REAL NOT NULL,
    descripcion   TEXT
  );

  CREATE TABLE IF NOT EXISTS reservas (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    villa_id       INTEGER NOT NULL REFERENCES villas(id),
    huesped        TEXT NOT NULL,
    email          TEXT,
    telefono       TEXT,
    num_huespedes  INTEGER NOT NULL DEFAULT 1,
    fecha_entrada  TEXT NOT NULL,
    fecha_salida   TEXT NOT NULL,
    estado         TEXT NOT NULL DEFAULT 'confirmada',
    notas          TEXT,
    creada_en      TEXT NOT NULL DEFAULT (datetime('now'))
  );
`);

// --- Datos iniciales: 12 villas de lujo en Santa Catalina ---
const VILLAS_INICIALES = [
  { nombre: 'Villa Coral',      tipo: 'Frente al mar',   capacidad: 2, precio: 480, desc: 'Villa íntima con vista directa al océano y piscina privada.' },
  { nombre: 'Villa Arrecife',   tipo: 'Frente al mar',   capacidad: 2, precio: 460, desc: 'Terraza panorámica perfecta para ver el atardecer.' },
  { nombre: 'Villa Manta',      tipo: 'Frente al mar',   capacidad: 4, precio: 620, desc: 'Amplia villa familiar a pasos de la playa.' },
  { nombre: 'Villa Tortuga',    tipo: 'Jardín',          capacidad: 4, precio: 390, desc: 'Rodeada de vegetación tropical y aves locales.' },
  { nombre: 'Villa Palmera',    tipo: 'Jardín',          capacidad: 2, precio: 350, desc: 'Refugio romántico entre palmeras.' },
  { nombre: 'Villa Orquídea',   tipo: 'Jardín',          capacidad: 3, precio: 410, desc: 'Decoración elegante con jardín privado.' },
  { nombre: 'Villa Cascada',    tipo: 'Jungla',          capacidad: 4, precio: 440, desc: 'Junto a un arroyo natural, ideal para desconectar.' },
  { nombre: 'Villa Ceiba',      tipo: 'Jungla',          capacidad: 6, precio: 720, desc: 'Gran villa para grupos bajo árboles centenarios.' },
  { nombre: 'Villa Iguana',     tipo: 'Jungla',          capacidad: 2, precio: 360, desc: 'Cabaña de lujo elevada con vistas al dosel.' },
  { nombre: 'Villa Marea',      tipo: 'Premium',         capacidad: 4, precio: 850, desc: 'Suite premium con jacuzzi, chef privado y mayordomo.' },
  { nombre: 'Villa Horizonte',  tipo: 'Premium',         capacidad: 6, precio: 980, desc: 'La villa insignia: infinity pool y servicio 24h.' },
  { nombre: 'Villa Estrella',   tipo: 'Premium',         capacidad: 8, precio: 1200, desc: 'Villa más exclusiva, perfecta para celebraciones privadas.' },
];

export function seed() {
  const count = db.prepare('SELECT COUNT(*) AS n FROM villas').get().n;
  if (count > 0) {
    console.log(`Las villas ya existen (${count}). No se vuelve a sembrar.`);
    return;
  }
  const insert = db.prepare(
    'INSERT INTO villas (nombre, tipo, capacidad, precio_noche, descripcion) VALUES (?, ?, ?, ?, ?)'
  );
  for (const v of VILLAS_INICIALES) {
    insert.run(v.nombre, v.tipo, v.capacidad, v.precio, v.desc);
  }
  console.log(`Sembradas ${VILLAS_INICIALES.length} villas de lujo.`);
}

// Sembrar automáticamente al importar (si está vacío)
seed();

// Permite ejecutar `node db.js --seed` manualmente
if (process.argv.includes('--seed')) {
  console.log('Base de datos lista en:', DB_PATH);
}
