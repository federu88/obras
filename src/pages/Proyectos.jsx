import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import {
  listProjects,
  createProject,
  updateProject,
  listProjectCapital,
} from '../lib/queries'
import { usd, date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge } from '../components/ui'
import ProyectoForm, { PROJECT_STATUS } from '../components/ProyectoForm'

const TONO = {
  aprobado: 'warn',
  en_construccion: 'warn',
  terminado: 'ok',
  vendido: 'ok',
}

const ACTIVOS = ['aprobado', 'en_construccion']
const TERMINADOS = ['terminado', 'vendido', 'cerrado']

export default function Proyectos({ filter }) {
  const { canManage } = useAuth()
  /* null = cerrado · 'nuevo' = alta · un objeto = edición de ese proyecto */
  const [editando, setEditando] = useState(null)

  const projects = useAsync(listProjects)
  const capital = useAsync(listProjectCapital)

  function recargar() {
    projects.reload()
    capital.reload()
  }

  const title =
    filter === 'activos' ? 'Proyectos activos'
    : filter === 'terminados' ? 'Proyectos terminados'
    : 'Proyectos'

  let rows = projects.data ?? []
  if (filter === 'activos') rows = rows.filter((p) => ACTIVOS.includes(p.status))
  if (filter === 'terminados') rows = rows.filter((p) => TERMINADOS.includes(p.status))

  const capitalByProject = Object.fromEntries(
    (capital.data ?? []).map((c) => [c.project_id, c])
  )

  const columns = [
    { key: 'code', label: 'Código' },
    { key: 'name', label: 'Proyecto' },
    { key: 'status', label: 'Estado' },
    { key: 'budget', label: 'Presupuesto', num: true },
    { key: 'capital', label: 'Capital aportado', num: true },
    { key: 'sale', label: 'Venta estimada', num: true },
    { key: 'finish', label: 'Fin previsto' },
    { key: 'act', label: '' },
  ]

  return (
    <div>
      <PageHead
        title={title}
        subtitle="Cada casa es un proyecto. Importes en USD."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => setEditando('nuevo')}>
              + Nuevo proyecto
            </button>
          )
        }
      />

      {projects.error && <ErrorBox message={projects.error} />}

      {projects.loading ? (
        <Loading />
      ) : (
        <Table
          columns={columns}
          rows={rows}
          empty={
            filter
              ? 'Ningún proyecto en este estado.'
              : 'Todavía no hay proyectos. Creá el primero con “Nuevo proyecto”.'
          }
          renderRow={(p) => (
            <tr key={p.id}>
              <td style={{ fontWeight: 500 }}>
                <Link to={`/proyectos/${p.id}`} style={{ color: 'var(--accent)' }}>
                  {p.code}
                </Link>
              </td>
              <td>
                {p.name}
                {p.is_demo && <> <span className="tag-demo">demo</span></>}
              </td>
              <td>
                <Badge tone={TONO[p.status]}>
                  {PROJECT_STATUS[p.status] ?? p.status}
                </Badge>
              </td>
              <td className="num">{usd(p.budget_usd)}</td>
              <td className="num">{usd(capitalByProject[p.id]?.capital_aportado_usd)}</td>
              <td className="num">{usd(p.target_sale_usd)}</td>
              <td>{date(p.planned_finish)}</td>
              <td>
                {canManage && (
                  <button className="icon-btn" onClick={() => setEditando(p)}>
                    Editar
                  </button>
                )}
              </td>
            </tr>
          )}
        />
      )}

      {editando && (
        <ProyectoForm
          project={editando === 'nuevo' ? null : editando}
          onClose={() => setEditando(null)}
          onSave={async (payload) => {
            if (editando === 'nuevo') await createProject(payload)
            else await updateProject(editando.id, payload)
            recargar()
          }}
        />
      )}
    </div>
  )
}
