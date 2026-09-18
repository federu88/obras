import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import { isSupabaseConfigured } from './lib/supabase'
import Layout from './components/Layout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Proyectos from './pages/Proyectos'
import Proyecto from './pages/Proyecto'
import Pnl from './pages/Pnl'
import Cashflow from './pages/Cashflow'
import Items from './pages/compras/Items'
import Proveedores from './pages/compras/Proveedores'
import Cotizaciones from './pages/compras/Cotizaciones'
import Ordenes from './pages/compras/Ordenes'
import Cronogramas from './pages/Cronogramas'
import Reportes from './pages/Reportes'
import Configuracion from './pages/Configuracion'
import Inversor from './pages/Inversor'
import Caja from './pages/Caja'
import Inversores from './pages/Inversores'
import Capital from './pages/Capital'

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
            <Route path="proyectos/:id" element={<Proyecto />} />

            <Route path="inversores" element={<Inversores />} />
            <Route path="inversores/:id" element={<Inversor />} />

            <Route path="finanzas" element={<Navigate to="/finanzas/cashflow" replace />} />
            <Route path="finanzas/cashflow" element={<Cashflow />} />
            <Route path="finanzas/pnl" element={<Pnl />} />
            <Route path="finanzas/capital" element={<Capital />} />
            <Route path="finanzas/caja" element={<Caja />} />

            <Route path="compras" element={<Navigate to="/compras/items" replace />} />
            <Route path="compras/items" element={<Items />} />
            <Route path="compras/proveedores" element={<Proveedores />} />
            <Route path="compras/cotizaciones" element={<Cotizaciones />} />
            <Route path="compras/ordenes" element={<Ordenes />} />

            <Route path="cronogramas" element={<Cronogramas />} />
            <Route path="reportes" element={<Reportes />} />
            <Route path="configuracion" element={<Configuracion />} />

            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}
