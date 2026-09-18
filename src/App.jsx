import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import { isSupabaseConfigured } from './lib/supabase'
import Layout from './components/Layout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Proyectos from './pages/Proyectos'
import Inversores from './pages/Inversores'
import Capital from './pages/Capital'
import Placeholder from './pages/Placeholder'

/** Pantalla de arranque cuando todavía no hay proyecto de Supabase conectado. */
function SetupRequired() {
  return (
    <div style={{ minHeight: '100vh', display: 'grid', placeItems: 'center', padding: 16 }}>
      <div className="card" style={{ maxWidth: 460, display: 'grid', gap: 12 }}>
        <h1 style={{ fontSize: '1.25rem' }}>Falta conectar Supabase</h1>
        <p style={{ margin: 0, color: 'var(--text-muted)' }}>
          Copiá <code>.env.example</code> a <code>.env</code> y completá la URL y
          la anon key del proyecto. Después reiniciá el servidor de desarrollo.
        </p>
        <pre
          style={{
            margin: 0,
            padding: 12,
            background: 'var(--surface-2)',
            borderRadius: 'var(--radius-sm)',
            fontSize: '0.8125rem',
            overflowX: 'auto',
          }}
        >
{`VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGci...`}
        </pre>
      </div>
    </div>
  )
}

function Splash() {
  return (
    <div style={{ minHeight: '100vh', display: 'grid', placeItems: 'center' }}>
      <span style={{ color: 'var(--text-muted)' }}>Cargando…</span>
    </div>
  )
}

/** Solo deja pasar con sesión. La RLS del servidor es la que realmente protege. */
function Protected() {
  const { session, loading } = useAuth()
  if (loading) return <Splash />
  if (!session) return <Login />
  return <Layout />
}

const SOON = {
  finanzas: ['Fase 3', 'Cashflow y P&L por proyecto, con budget vs forecast vs actual.'],
  compras: ['Fase 4', 'Catálogo, proveedores, cotizaciones y análisis de desvíos.'],
  cronogramas: ['Fase 5', 'Gantt con plan vs real y desvíos de plazo.'],
  reportes: ['Fase 7', 'Reportes por inversor, por proyecto y consolidado.'],
}

const soon = (title, key) => (
  <Placeholder title={title} phase={SOON[key][0]} detail={SOON[key][1]} />
)

export default function App() {
  if (!isSupabaseConfigured) return <SetupRequired />

  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route element={<Protected />}>
            <Route index element={<Dashboard />} />

            <Route path="proyectos" element={<Proyectos />} />
            <Route path="proyectos/activos" element={<Proyectos filter="activos" />} />
            <Route path="proyectos/terminados" element={<Proyectos filter="terminados" />} />

            <Route path="inversores" element={<Inversores />} />

            <Route path="finanzas" element={<Navigate to="/finanzas/capital" replace />} />
            <Route path="finanzas/cashflow" element={soon('Cashflow', 'finanzas')} />
            <Route path="finanzas/pnl" element={soon('P&L', 'finanzas')} />
            <Route path="finanzas/capital" element={<Capital />} />
            <Route path="finanzas/caja" element={soon('Caja y cambios', 'finanzas')} />

            <Route path="compras" element={<Navigate to="/compras/items" replace />} />
            <Route path="compras/items" element={soon('Items', 'compras')} />
            <Route path="compras/proveedores" element={soon('Proveedores', 'compras')} />
            <Route path="compras/cotizaciones" element={soon('Cotizaciones', 'compras')} />
            <Route path="compras/ordenes" element={soon('Compras', 'compras')} />

            <Route path="cronogramas" element={soon('Cronogramas', 'cronogramas')} />
            <Route path="reportes" element={soon('Reportes', 'reportes')} />
            <Route
              path="configuracion"
              element={
                <Placeholder
                  title="Configuración"
                  phase="Fase 1"
                  detail="Usuarios, roles y cotizaciones de referencia."
                />
              }
            />

            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}
