# 🏝️ Santa Catalina Villas — Panel de Administración

Sistema de gestión para un **hotel de lujo de 12 villas** en Santa Catalina.
Permite al personal administrar reservas, controlar la disponibilidad de las
villas y consultar estadísticas de ocupación.

## ✨ Funcionalidades

- **Resumen (dashboard):** ocupación del día, villas libres/ocupadas, llegadas
  y salidas de hoy, e ingresos proyectados.
- **Reservas:** crear, buscar, filtrar por estado, cambiar estado
  (confirmada → check-in → check-out / cancelada) y eliminar.
- **Disponibilidad:** comprueba qué villas están libres en un rango de fechas.
- **Villas:** catálogo de las 12 villas con tipo, capacidad y precio.
- **Validaciones automáticas:** evita reservas solapadas en la misma villa y
  controla que no se supere la capacidad máxima.

## 🛠️ Tecnología

- **Backend:** Node.js + Express
- **Base de datos:** SQLite (módulo `node:sqlite` integrado en Node 22 — sin
  instalaciones adicionales)
- **Frontend:** HTML, CSS y JavaScript (sin frameworks)

## 🚀 Cómo ejecutarlo

Requisito: **Node.js 22.5 o superior**.

```bash
cd hotel-villas
npm install        # instala Express
npm start          # arranca el servidor
```

Luego abre en el navegador: **http://localhost:3000**

La base de datos (`hotel.db`) se crea automáticamente la primera vez y se
siembra con las 12 villas.

## 📡 API REST

| Método | Ruta                         | Descripción                                  |
|--------|------------------------------|----------------------------------------------|
| GET    | `/api/villas`                | Lista las 12 villas                          |
| GET    | `/api/reservas`              | Lista todas las reservas                     |
| POST   | `/api/reservas`              | Crea una reserva (valida fechas y capacidad) |
| PATCH  | `/api/reservas/:id`          | Cambia el estado de una reserva              |
| DELETE | `/api/reservas/:id`          | Elimina una reserva                          |
| GET    | `/api/disponibilidad`        | Villas libres en `?entrada=&salida=`         |
| GET    | `/api/stats`                 | Estadísticas del dashboard                   |

## 🏡 Las 12 villas

Frente al mar, jardín, jungla y premium — desde villas íntimas para 2 personas
hasta la Villa Estrella para 8 huéspedes con servicio exclusivo.
