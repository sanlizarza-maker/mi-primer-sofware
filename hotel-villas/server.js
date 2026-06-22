// Servidor del panel de administración del hotel
import express from 'express';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { db } from './db.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// --- Utilidades ---

// ¿La villa está libre en ese rango? (se excluye una reserva al editar)
function hayConflicto(villaId, entrada, salida, excluirId = null) {
  // Dos rangos [a,b) y [c,d) se solapan si  a < d  y  c < b
  let sql = `
    SELECT COUNT(*) AS n FROM reservas
    WHERE villa_id = ?
      AND estado != 'cancelada'
      AND fecha_entrada < ?
      AND fecha_salida  > ?
  `;
  const params = [villaId, salida, entrada];
  if (excluirId) {
    sql += ' AND id != ?';
    params.push(excluirId);
  }
  return db.prepare(sql).get(...params).n > 0;
}

function validarFechas(entrada, salida) {
  if (!entrada || !salida) return 'Faltan las fechas de entrada o salida.';
  if (isNaN(Date.parse(entrada)) || isNaN(Date.parse(salida))) return 'Fechas inválidas.';
  if (entrada >= salida) return 'La fecha de salida debe ser posterior a la de entrada.';
  return null;
}

function noches(entrada, salida) {
  return Math.round((Date.parse(salida) - Date.parse(entrada)) / 86400000);
}

// === API: VILLAS ===

app.get('/api/villas', (req, res) => {
  const villas = db.prepare('SELECT * FROM villas ORDER BY id').all();
  res.json(villas);
});

// === API: RESERVAS ===

app.get('/api/reservas', (req, res) => {
  const reservas = db.prepare(`
    SELECT r.*, v.nombre AS villa_nombre, v.precio_noche
    FROM reservas r
    JOIN villas v ON v.id = r.villa_id
    ORDER BY r.fecha_entrada
  `).all();
  res.json(reservas);
});

app.post('/api/reservas', (req, res) => {
  const { villa_id, huesped, email, telefono, num_huespedes, fecha_entrada, fecha_salida, notas } = req.body;

  if (!villa_id || !huesped) {
    return res.status(400).json({ error: 'La villa y el nombre del huésped son obligatorios.' });
  }
  const errFecha = validarFechas(fecha_entrada, fecha_salida);
  if (errFecha) return res.status(400).json({ error: errFecha });

  const villa = db.prepare('SELECT * FROM villas WHERE id = ?').get(villa_id);
  if (!villa) return res.status(404).json({ error: 'La villa no existe.' });

  if ((num_huespedes || 1) > villa.capacidad) {
    return res.status(400).json({ error: `${villa.nombre} admite máximo ${villa.capacidad} huéspedes.` });
  }
  if (hayConflicto(villa_id, fecha_entrada, fecha_salida)) {
    return res.status(409).json({ error: `${villa.nombre} no está disponible en esas fechas.` });
  }

  const info = db.prepare(`
    INSERT INTO reservas (villa_id, huesped, email, telefono, num_huespedes, fecha_entrada, fecha_salida, notas)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(villa_id, huesped, email || null, telefono || null, num_huespedes || 1, fecha_entrada, fecha_salida, notas || null);

  const reserva = db.prepare('SELECT * FROM reservas WHERE id = ?').get(info.lastInsertRowid);
  res.status(201).json(reserva);
});

// Cambiar estado: confirmada | check-in | check-out | cancelada
app.patch('/api/reservas/:id', (req, res) => {
  const { estado } = req.body;
  const validos = ['confirmada', 'check-in', 'check-out', 'cancelada'];
  if (!validos.includes(estado)) {
    return res.status(400).json({ error: 'Estado no válido.' });
  }
  const r = db.prepare('SELECT * FROM reservas WHERE id = ?').get(req.params.id);
  if (!r) return res.status(404).json({ error: 'Reserva no encontrada.' });

  db.prepare('UPDATE reservas SET estado = ? WHERE id = ?').run(estado, req.params.id);
  res.json(db.prepare('SELECT * FROM reservas WHERE id = ?').get(req.params.id));
});

app.delete('/api/reservas/:id', (req, res) => {
  const info = db.prepare('DELETE FROM reservas WHERE id = ?').run(req.params.id);
  if (info.changes === 0) return res.status(404).json({ error: 'Reserva no encontrada.' });
  res.json({ ok: true });
});

// Comprobar disponibilidad de villas para un rango de fechas
app.get('/api/disponibilidad', (req, res) => {
  const { entrada, salida } = req.query;
  const err = validarFechas(entrada, salida);
  if (err) return res.status(400).json({ error: err });

  const villas = db.prepare('SELECT * FROM villas ORDER BY id').all();
  const resultado = villas.map(v => ({
    ...v,
    disponible: !hayConflicto(v.id, entrada, salida),
  }));
  res.json(resultado);
});

// === API: ESTADÍSTICAS DEL DASHBOARD ===

app.get('/api/stats', (req, res) => {
  const hoy = new Date().toISOString().slice(0, 10);
  const totalVillas = db.prepare('SELECT COUNT(*) AS n FROM villas').get().n;

  // Villas ocupadas hoy
  const ocupadasHoy = db.prepare(`
    SELECT COUNT(DISTINCT villa_id) AS n FROM reservas
    WHERE estado != 'cancelada' AND fecha_entrada <= ? AND fecha_salida > ?
  `).get(hoy, hoy).n;

  // Llegadas y salidas de hoy
  const llegadasHoy = db.prepare(
    `SELECT COUNT(*) AS n FROM reservas WHERE estado != 'cancelada' AND fecha_entrada = ?`
  ).get(hoy).n;
  const salidasHoy = db.prepare(
    `SELECT COUNT(*) AS n FROM reservas WHERE estado != 'cancelada' AND fecha_salida = ?`
  ).get(hoy).n;

  // Ingresos de reservas activas (futuras y en curso)
  const reservas = db.prepare(
    `SELECT fecha_entrada, fecha_salida, precio_noche
     FROM reservas r JOIN villas v ON v.id = r.villa_id
     WHERE r.estado != 'cancelada' AND r.fecha_salida >= ?`
  ).all(hoy);
  const ingresosProyectados = reservas.reduce(
    (sum, r) => sum + noches(r.fecha_entrada, r.fecha_salida) * r.precio_noche, 0
  );

  res.json({
    totalVillas,
    ocupadasHoy,
    disponiblesHoy: totalVillas - ocupadasHoy,
    ocupacionPct: Math.round((ocupadasHoy / totalVillas) * 100),
    llegadasHoy,
    salidasHoy,
    ingresosProyectados,
  });
});

app.listen(PORT, () => {
  console.log(`\n🏝️  Hotel Villas Santa Catalina`);
  console.log(`✅ Panel de administración en: http://localhost:${PORT}\n`);
});
