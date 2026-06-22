// Panel de administración — lógica del frontend

let villas = [];
let reservas = [];

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => document.querySelectorAll(sel);

const fmtMoneda = (n) => '$' + Number(n).toLocaleString('es-PA');
const fmtFecha = (f) => new Date(f + 'T00:00:00').toLocaleDateString('es-PA', { day: '2-digit', month: 'short', year: 'numeric' });
const noches = (e, s) => Math.round((Date.parse(s) - Date.parse(e)) / 86400000);

async function api(url, opciones) {
  const res = await fetch(url, opciones);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || 'Error en el servidor');
  return data;
}

function toast(msg, esError = false) {
  const t = $('#toast');
  t.textContent = msg;
  t.classList.toggle('error', esError);
  t.classList.add('visible');
  setTimeout(() => t.classList.remove('visible'), 3000);
}

// --- Navegación entre pestañas ---
$$('.tab').forEach(tab => {
  tab.addEventListener('click', () => {
    $$('.tab').forEach(t => t.classList.remove('activa'));
    $$('.vista').forEach(v => v.classList.remove('activa'));
    tab.classList.add('activa');
    $('#' + tab.dataset.vista).classList.add('activa');
    if (tab.dataset.vista === 'dashboard') cargarDashboard();
  });
});

// --- Dashboard ---
async function cargarDashboard() {
  try {
    const s = await api('/api/stats');
    $('#tarjetas-stats').innerHTML = `
      ${tarjeta(s.ocupacionPct + '%', 'Ocupación hoy')}
      ${tarjeta(s.ocupadasHoy + ' / ' + s.totalVillas, 'Villas ocupadas')}
      ${tarjeta(s.disponiblesHoy, 'Villas disponibles')}
      ${tarjeta(s.llegadasHoy, 'Llegadas hoy')}
      ${tarjeta(s.salidasHoy, 'Salidas hoy')}
      ${tarjeta(fmtMoneda(s.ingresosProyectados), 'Ingresos proyectados')}
    `;
    const hoy = new Date().toISOString().slice(0, 10);
    const proximas = reservas
      .filter(r => r.estado !== 'cancelada' && r.fecha_entrada >= hoy)
      .sort((a, b) => a.fecha_entrada.localeCompare(b.fecha_entrada))
      .slice(0, 5);
    $('#proximas-llegadas').innerHTML = proximas.length
      ? proximas.map(r => `
          <div class="item-mini">
            <span><strong>${r.huesped}</strong> · ${r.villa_nombre}</span>
            <span>${fmtFecha(r.fecha_entrada)}</span>
          </div>`).join('')
      : '<p class="vacio">No hay llegadas próximas.</p>';
  } catch (e) { toast(e.message, true); }
}
const tarjeta = (num, etq) => `<div class="tarjeta"><div class="num">${num}</div><div class="etq">${etq}</div></div>`;

// --- Reservas ---
function pintarReservas() {
  const texto = $('#buscar-reserva').value.toLowerCase();
  const estado = $('#filtro-estado').value;
  const filtradas = reservas.filter(r =>
    (!estado || r.estado === estado) &&
    (r.huesped.toLowerCase().includes(texto) || r.villa_nombre.toLowerCase().includes(texto))
  );
  const tbody = $('#tabla-reservas tbody');
  if (!filtradas.length) {
    tbody.innerHTML = '<tr><td colspan="8" class="vacio">No hay reservas que coincidan.</td></tr>';
    return;
  }
  tbody.innerHTML = filtradas.map(r => {
    const n = noches(r.fecha_entrada, r.fecha_salida);
    return `
      <tr>
        <td><strong>${r.villa_nombre}</strong></td>
        <td>${r.huesped}</td>
        <td>${fmtFecha(r.fecha_entrada)}</td>
        <td>${fmtFecha(r.fecha_salida)}</td>
        <td>${n}</td>
        <td>${fmtMoneda(n * r.precio_noche)}</td>
        <td><span class="estado ${r.estado}">${r.estado}</span></td>
        <td>
          <div class="acciones-fila">
            <select onchange="cambiarEstado(${r.id}, this.value)">
              ${['confirmada','check-in','check-out','cancelada'].map(e =>
                `<option value="${e}" ${e===r.estado?'selected':''}>${e}</option>`).join('')}
            </select>
            <button class="btn-icono" title="Eliminar" onclick="eliminarReserva(${r.id})">🗑️</button>
          </div>
        </td>
      </tr>`;
  }).join('');
}

window.cambiarEstado = async (id, estado) => {
  try {
    await api(`/api/reservas/${id}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ estado }),
    });
    await recargar();
    toast('Estado actualizado.');
  } catch (e) { toast(e.message, true); }
};

window.eliminarReserva = async (id) => {
  if (!confirm('¿Eliminar esta reserva?')) return;
  try {
    await api(`/api/reservas/${id}`, { method: 'DELETE' });
    await recargar();
    toast('Reserva eliminada.');
  } catch (e) { toast(e.message, true); }
};

$('#buscar-reserva').addEventListener('input', pintarReservas);
$('#filtro-estado').addEventListener('change', pintarReservas);

// --- Modal nueva reserva ---
const modal = $('#modal-fondo');
$('#btn-nueva-reserva').addEventListener('click', () => {
  $('#form-reserva').reset();
  $('#form-error').textContent = '';
  $('#f-villa').innerHTML = villas.map(v =>
    `<option value="${v.id}">${v.nombre} (hasta ${v.capacidad} pers. · ${fmtMoneda(v.precio_noche)}/noche)</option>`).join('');
  modal.classList.add('visible');
});
$('#btn-cancelar').addEventListener('click', () => modal.classList.remove('visible'));
modal.addEventListener('click', (e) => { if (e.target === modal) modal.classList.remove('visible'); });

$('#form-reserva').addEventListener('submit', async (e) => {
  e.preventDefault();
  $('#form-error').textContent = '';
  const body = {
    villa_id: Number($('#f-villa').value),
    huesped: $('#f-huesped').value.trim(),
    num_huespedes: Number($('#f-num').value),
    email: $('#f-email').value.trim(),
    telefono: $('#f-telefono').value.trim(),
    fecha_entrada: $('#f-entrada').value,
    fecha_salida: $('#f-salida').value,
    notas: $('#f-notas').value.trim(),
  };
  try {
    await api('/api/reservas', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    modal.classList.remove('visible');
    await recargar();
    toast('Reserva creada con éxito.');
  } catch (e) { $('#form-error').textContent = e.message; }
});

// --- Disponibilidad ---
$('#btn-comprobar').addEventListener('click', async () => {
  const entrada = $('#disp-entrada').value;
  const salida = $('#disp-salida').value;
  try {
    const data = await api(`/api/disponibilidad?entrada=${entrada}&salida=${salida}`);
    $('#grid-disponibilidad').innerHTML = data.map(v => cardVilla(v, true)).join('');
  } catch (e) { toast(e.message, true); }
});

// --- Villas ---
function pintarVillas() {
  $('#grid-villas').innerHTML = villas.map(v => cardVilla(v, false)).join('');
}
function cardVilla(v, conDisp) {
  const badge = conDisp
    ? `<span class="disp-badge ${v.disponible ? 'si' : 'no'}">${v.disponible ? 'Disponible' : 'Ocupada'}</span>`
    : '';
  return `
    <div class="card-villa">
      ${badge}
      <span class="tipo">${v.tipo}</span>
      <h4>${v.nombre}</h4>
      <p class="desc">${v.descripcion || ''}</p>
      <div class="precio">${fmtMoneda(v.precio_noche)} <span>/ noche</span></div>
      <div class="cap">👥 Hasta ${v.capacidad} huéspedes</div>
    </div>`;
}

// --- Carga inicial ---
async function recargar() {
  [villas, reservas] = await Promise.all([api('/api/villas'), api('/api/reservas')]);
  pintarReservas();
  pintarVillas();
  cargarDashboard();
}

recargar().catch(e => toast(e.message, true));
