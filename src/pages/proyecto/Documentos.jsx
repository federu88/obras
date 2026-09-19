import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listDocuments,
  createDocument,
  updateDocument,
  deleteDocument,
  uploadDocumentFile,
  getDocumentUrl,
  fxRateAt,
} from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

/**
 * Facturas y papeles de la obra.
 *
 * El registro y el archivo van separados a propósito: una factura existe aunque
 * nadie haya subido el PDF todavía. Primero se anota que entró, después aparece
 * el papel. Al revés no pasa nunca.
 *
 * El bucket es privado y el permiso sale de la carpeta, que es el proyecto. No
 * hay link fijo: cada vez que se abre un archivo se pide una URL que vence.
 */

const KINDS = {
  factura_emitida: 'Factura emitida',
  factura_recibida: 'Factura de proveedor',
  remito: 'Remito',
  presupuesto: 'Presupuesto',
  contrato: 'Contrato',
  plano: 'Plano',
  aprobacion: 'Aprobación',
  foto: 'Foto',
  otro: 'Otro',
}

const VACIO = {
  kind: 'factura_recibida',
  doc_date: new Date().toISOString().slice(0, 10),
  number: '',
  description: '',
  amount: '',
  currency: 'USD',
  with_client: 'false',
  notes: '',
}

export default function Documentos({ projectId }) {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(VACIO)
  const [archivo, setArchivo] = useState(null)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const docs = useAsync(() => listDocuments(projectId), [projectId])
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  function abrir(fila = null) {
    setError(null)
    setArchivo(null)
    setForm(
      fila
        ? {
            kind: fila.kind,
            doc_date: fila.doc_date,
            number: fila.number ?? '',
            description: fila.description,
            amount: fila.amount == null ? '' : String(fila.amount),
            currency: fila.currency ?? 'USD',
            with_client: fila.with_client ? 'true' : 'false',
            notes: fila.notes ?? '',
          }
        : VACIO
    )
    setAbierto(fila ?? 'nuevo')
  }

  async function guardar() {
    setSaving(true)
    setError(null)
    try {
      const monto = form.amount === '' ? null : Number(form.amount)
      let fx = null
      if (monto != null && form.currency !== 'USD') {
        fx = await fxRateAt(form.doc_date)
        if (!fx) {
          throw new Error('No hay cotización para esa fecha. Cargala en Finanzas › Dólar.')
        }
      }

      const payload = {
        kind: form.kind,
        doc_date: form.doc_date,
        number: form.number || null,
        description: form.description,
        amount: monto,
        currency: monto == null ? null : form.currency,
        fx_usd: fx,
        with_client: form.with_client === 'true',
        notes: form.notes || null,
      }

      /* El archivo se sube primero: si falla, no queda un registro que promete
         un adjunto que no existe. */
      if (archivo) Object.assign(payload, await uploadDocumentFile(projectId, archivo))

      if (abierto === 'nuevo') await createDocument({ ...payload, project_id: projectId })
      else await updateDocument(abierto.id, payload)

      setAbierto(null)
      docs.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function borrar() {
    setSaving(true)
    try {
      await deleteDocument(abierto)
      setAbierto(null)
      docs.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function abrirArchivo(d) {
    try {
      window.open(await getDocumentUrl(d.storage_path), '_blank', 'noopener')
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Facturas, remitos, planos y aprobaciones. El archivo es opcional: el registro
          vale igual.
        </p>
        {canManage && (
          <button className="btn btn-primary" onClick={() => abrir()}>+ Documento</button>
        )}
      </div>

      {(docs.error || error) && <ErrorBox message={docs.error || error} />}

      {docs.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'doc_date', label: 'Fecha' },
            { key: 'kind', label: 'Tipo' },
            { key: 'number', label: 'Número' },
            { key: 'description', label: 'Detalle' },
            { key: 'amount_usd', label: 'Monto', num: true },
            { key: 'archivo', label: 'Archivo', sort: false },
            { key: 'act', label: '', sort: false },
          ]}
          rows={docs.data ?? []}
          empty="Todavía no hay documentos cargados."
          renderRow={(d) => (
            <tr key={d.id}>
              <td className="nowrap">{date(d.doc_date)}</td>
              <td style={{ color: 'var(--text-muted)' }}>{KINDS[d.kind] ?? d.kind}</td>
              <td className="nowrap">{d.number ?? '—'}</td>
              <td>{d.description}</td>
              <td className="num">{d.amount_usd == null ? '—' : usd(d.amount_usd)}</td>
              <td className="nowrap">
                {d.storage_path ? (
                  <button className="icon-btn" onClick={() => abrirArchivo(d)}>Ver</button>
                ) : (
                  <Badge tone="off">Sin adjunto</Badge>
                )}
              </td>
              <td className="nowrap">
                {canManage && (
                  <button className="icon-btn" onClick={() => abrir(d)}>Editar</button>
                )}
              </td>
            </tr>
          )}
        />
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nuevo documento' : 'Editar documento'}
          submitLabel={saving && archivo ? 'Subiendo…' : abierto === 'nuevo' ? 'Guardar' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={guardar}
          submitting={saving}
          onDelete={abierto !== 'nuevo' ? borrar : undefined}
          deleteLabel="Eliminar documento"
        >
          {error && <ErrorBox message={error} />}

          <Field label="Tipo">
            <select value={form.kind} onChange={set('kind')}>
              {Object.entries(KINDS).map(([k, v]) => (
                <option key={k} value={k}>{v}</option>
              ))}
            </select>
          </Field>

          <Field label="Fecha">
            <input type="date" required value={form.doc_date} onChange={set('doc_date')} />
          </Field>

          <Field label="Número" hint="De la factura o el remito.">
            <input value={form.number} onChange={set('number')} />
          </Field>

          <Field label="Detalle">
            <input required value={form.description} onChange={set('description')} />
          </Field>

          <Field label="Monto" hint="Dejalo vacío si el documento no tiene monto, como un plano.">
            <input type="number" step="0.01" min="0" value={form.amount} onChange={set('amount')} />
          </Field>

          <Field label="Moneda">
            <select value={form.currency} onChange={set('currency')}>
              <option value="USD">USD</option>
              <option value="ARS">ARS</option>
            </select>
          </Field>

          <Field
            label="Archivo"
            hint={
              abierto !== 'nuevo' && abierto.file_name
                ? `Ahora tiene ${abierto.file_name}. Si elegís otro, lo reemplaza.`
                : 'PDF, foto o lo que sea. Se puede subir después.'
            }
          >
            <input type="file" onChange={(e) => setArchivo(e.target.files?.[0] ?? null)} />
          </Field>

          <Field
            label="Ámbito"
            hint="Un documento interno no se incluye en lo que se le manda al cliente."
          >
            <select value={form.with_client} onChange={set('with_client')}>
              <option value="false">Interno</option>
              <option value="true">Se le comparte al cliente</option>
            </select>
          </Field>

          <Field label="Notas"><input value={form.notes} onChange={set('notes')} /></Field>
        </Drawer>
      )}
    </div>
  )
}
