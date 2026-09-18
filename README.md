# Obras

Plataforma de gestión para desarrollo, construcción y comercialización de casas:
proyectos, presupuesto, compras, cronograma, cashflow, resultado e inversores.

Todo el negocio se mide en **USD**. El peso es moneda transaccional, no unidad de
medida.

## Stack

| Capa | Herramienta |
|---|---|
| Frontend | React + Vite (JavaScript) |
| Base de datos, auth y API | Supabase (Postgres + RLS) |
| Hosting | Vercel |

Dependencias de aplicación: `@supabase/supabase-js` y `react-router-dom`. Nada más.

## Puesta en marcha

```bash
npm install
cp .env.example .env    # completar con los datos del proyecto de Supabase
npm run dev
```

Las migraciones están en `supabase/migrations/`, en orden. Se aplican desde el SQL
Editor de Supabase o con la CLI (`npx supabase db push`).

## Roles

Hay dos niveles, y es a propósito.

**Rol global** (`profiles.role`) — qué puede hacer en el negocio:

| Rol | Alcance |
|---|---|
| `admin` | Todo, incluido gestionar usuarios y roles |
| `manager` | Proyectos, presupuestos, compras, proveedores, cronogramas |
| `viewer` | Solo lectura sobre todo el negocio |
| `investor` | Únicamente los proyectos donde es miembro |

**Rol por proyecto** (`project_members.role`) — `manager`, `arquitecto`,
`inversor`, `viewer`. Permite que alguien sea arquitecto en una casa e inversor en
otra sin darle acceso global.

Ninguna tabla lleva `using (true)`. Cada policy nombra quién ve qué, y las tablas
nuevas no heredan permisos: cada migración los otorga explícitamente.

## Definiciones financieras

Una sola definición por indicador. Si una pantalla necesita otra cosa, se discute
acá antes de escribir una fórmula nueva.

| Concepto | Definición |
|---|---|
| **Budget** | Presupuesto original, congelado al aprobar el proyecto |
| **Forecast** | Mejor estimación de hoy: actual + pendiente revalorizado |
| **Actual** | Compras en estado `recibida` o `pagada` |
| **Committed** | Compras `aprobada` o `comprada`, aún no recibidas |
| **Available Cash** | Saldo de caja − committed |
| **Invested Capital** | Aportes − retiros, por inversor y por proyecto |
| **Profit** | Revenue − total cost del proyecto |
| **Distributed Profit** | Profit efectivamente pagado al inversor |
| **Reinvested Profit** | Profit que pasó a otro proyecto sin salir de caja |
| **Avance físico** | Ponderado por días hábiles planificados |
| **Avance económico** | Actual / forecast |

Conversión a dólares: cada movimiento guarda `monto`, `moneda` y `fx_usd` aplicado,
con su fecha. Nunca se convierte con una constante global.

## Fases

| Fase | Alcance | Estado |
|---|---|---|
| 1 · Foundation | Repo, Vite, Supabase, auth, roles, RLS, layout, design system, FX | **Hecha** |
| 2 · Core | Inversores, proyectos, movimientos de capital, dashboard | **Hecha** |
| 3 · Project finance | Presupuesto, gastos, ingresos, P&L, forecast, caja | **Hecha**, salvo el cashflow mensual |
| 4 · Procurement | Items, proveedores, cotizaciones, compras, desvíos | Pendiente |
| 5 · Execution | Tareas, Gantt, plan vs real, desvíos de plazo | Pendiente |
| 6 · Capital network | Distribución, transferencias entre proyectos, reinversión | Pendiente |
| 7 · Reporting | Dashboards de inversor, proyecto y consolidado | Pendiente |

## Origen funcional

El modelo replica y corrige la lógica de tres planillas en uso. El diagnóstico
completo, con los bugs detectados y qué se conserva, está en
[`docs/01-diagnostico-excel.md`](docs/01-diagnostico-excel.md).

## Decisiones abiertas

Registradas en [`docs/02-decisiones-abiertas.md`](docs/02-decisiones-abiertas.md).
Ninguna bloquea la Fase 1, pero varias afectan el esquema de las fases siguientes.
