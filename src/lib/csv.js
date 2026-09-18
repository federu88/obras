/**
 * Exportación a CSV. No justifica una dependencia: son treinta líneas.
 *
 * Usa punto y coma como separador y BOM UTF-8 porque es lo que Excel en
 * español abre bien sin preguntar nada. Con coma, Excel en configuración
 * regional argentina mete todo en una sola columna.
 */

function cell(value) {
  if (value == null) return ''
  const s = String(value)
  return /[";\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
}

/**
 * @param {string} filename  sin extensión
 * @param {Array<{key: string, label: string}>} columns
 * @param {Array<object>} rows
 */
export function downloadCsv(filename, columns, rows) {
  const head = columns.map((c) => cell(c.label)).join(';')
  const body = rows.map((r) => columns.map((c) => cell(r[c.key])).join(';'))
  const csv = '﻿' + [head, ...body].join('\r\n')

  const url = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8;' }))
  const a = document.createElement('a')
  a.href = url
  a.download = `${filename}-${new Date().toISOString().slice(0, 10)}.csv`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}
