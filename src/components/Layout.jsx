import { useState } from 'react'
import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Layout.css'

/* Iconos inline: 8 trazos no justifican una dependencia. */
const Icon = ({ d }) => (
  <svg
    className="nav-icon"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.8"
    strokeLinecap="round"
    strokeLinejoin="round"
    aria-hidden="true"
  >
    <path d={d} />
  </svg>
)

const ICONS = {
  dashboard: 'M3 13h8V3H3v10Zm10 8h8V11h-8v10ZM3 21h8v-6H3v6ZM13 9h8V3h-8v6Z',
  obra: 'M12 2 2 7l10 5 10-5-10-5ZM2 17l10 5 10-5M2 12l10 5 10-5',
  projects: 'M3 21V9l9-6 9 6v12M9 21v-7h6v7',
  investors: 'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm13 10v-2a4 4 0 0 0-3-3.87',
  finance: 'M3 3v18h18M7 15l4-5 3 3 5-7',
  procurement: 'M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4H6ZM3 6h18M16 10a4 4 0 0 1-8 0',
  schedule: 'M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z',
  reports: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6ZM14 2v6h6M9 15h6M9 11h2',
  settings: 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm7.4-3a7.4 7.4 0 0 0-.1-1.2l2-1.6-2-3.4-2.4 1a7.5 7.5 0 0 0-2-1.2L14.5 2h-4l-.4 2.6a7.5 7.5 0 0 0-2 1.2l-2.4-1-2 3.4 2 1.6a7.4 7.4 0 0 0 0 2.4l-2 1.6 2 3.4 2.4-1c.6.5 1.3.9 2 1.2l.4 2.6h4l.4-2.6c.7-.3 1.4-.7 2-1.2l2.4 1 2-3.4-2-1.6c.1-.4.1-.8.1-1.2Z',
}

/* Una sola definición de la navegación. */
const NAV = [
  { to: '/', label: 'Dashboard', icon: 'dashboard', end: true },
  { to: '/dia-a-dia', label: 'Día a día', icon: 'obra' },
  {
    to: '/proyectos',
    label: 'Proyectos',
    icon: 'projects',
    children: [
      { to: '/proyectos', label: 'Todos', end: true },
      { to: '/proyectos/activos', label: 'Activos' },
      { to: '/proyectos/terminados', label: 'Terminados' },
    ],
  },
  { to: '/inversores', label: 'Inversores', icon: 'investors' },
  { to: '/clientes', label: 'Clientes', icon: 'investors' },
  {
    to: '/finanzas',
    label: 'Finanzas',
    icon: 'finance',
    children: [
      { to: '/finanzas/cashflow', label: 'Cashflow' },
      { to: '/finanzas/pnl', label: 'P&L' },
      { to: '/finanzas/capital', label: 'Movimientos de capital' },
      { to: '/finanzas/caja', label: 'Caja y cambios' },
      { to: '/finanzas/dolar', label: 'Dólar' },
    ],
  },
  {
    to: '/catalogo',
    label: 'Catálogo',
    icon: 'procurement',
    children: [
      { to: '/catalogo/tecnicas', label: 'Técnicas' },
      { to: '/catalogo/gastos', label: 'Gastos del proyecto' },
      { to: '/catalogo/honorarios', label: 'Honorarios' },
      { to: '/catalogo/etapas', label: 'Etapas de obra' },
      { to: '/catalogo/proveedores', label: 'Proveedores' },
    ],
  },
  { to: '/cronogramas', label: 'Cronogramas', icon: 'schedule' },
  { to: '/reportes', label: 'Reportes', icon: 'reports' },
  { to: '/configuracion', label: 'Configuración', icon: 'settings' },
]

function initials(name, email) {
  const base = (name || email || '?').trim()
  const parts = base.split(/[\s@.]+/).filter(Boolean)
  return (parts[0]?.[0] ?? '?').toUpperCase() + (parts[1]?.[0] ?? '').toUpperCase()
}

export default function Layout() {
  const [open, setOpen] = useState(false)
  const { profile, session, signOut } = useAuth()
  const location = useLocation()

  const close = () => setOpen(false)

  return (
    <div className="layout">
      <aside className={`sidebar${open ? ' open' : ''}`}>
        <div className="brand">
          <div className="brand-mark">OB</div>
          <div className="brand-name">Obras</div>
        </div>

        <nav>
          {NAV.map((item) => {
            const showChildren =
              item.children && location.pathname.startsWith(item.to)
            return (
              <div key={item.to}>
                <NavLink
                  to={item.to}
                  end={item.end}
                  className={({ isActive }) =>
                    `nav-item${isActive ? ' active' : ''}`
                  }
                  onClick={close}
                >
                  <Icon d={ICONS[item.icon]} />
                  <span>{item.label}</span>
                </NavLink>

                {showChildren &&
                  item.children.map((child) => (
                    <NavLink
                      key={child.to}
                      to={child.to}
                      end={child.end}
                      className={({ isActive }) =>
                        `nav-item sub${isActive ? ' active' : ''}`
                      }
                      onClick={close}
                    >
                      <span>{child.label}</span>
                    </NavLink>
                  ))}
              </div>
            )
          })}
        </nav>

        <div className="sidebar-footer">
          <div className="user-chip">
            <div className="user-avatar">
              {initials(profile?.full_name, session?.user?.email)}
            </div>
            <div className="user-meta">
              <div className="user-name">
                {profile?.full_name || session?.user?.email || 'Sin perfil'}
              </div>
              <div className="user-role">{profile?.role ?? '—'}</div>
            </div>
          </div>
          <button className="signout" onClick={signOut}>
            Cerrar sesión
          </button>
        </div>
      </aside>

      <div
        className={`scrim${open ? ' show' : ''}`}
        onClick={close}
        aria-hidden="true"
      />

      <div className="main">
        <header className="topbar">
          <button
            className="menu-btn"
            onClick={() => setOpen((v) => !v)}
            aria-label="Abrir menú"
          >
            <Icon d="M3 6h18M3 12h18M3 18h18" />
          </button>
        </header>

        <main className="content">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
