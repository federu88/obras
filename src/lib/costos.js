/**
 * Tipos de costo. Son fijos (enum cost_type en la base): no se editan desde la
 * app, porque los reportes cruzan por ellos y un tipo nuevo los descuadraría.
 */
export const COST_TYPES = {
  materiales: 'Materiales',
  mano_de_obra: 'Mano de obra',
  subcontrato: 'Subcontrato',
  equipos_alquileres: 'Equipos y alquileres',
  fletes_logistica: 'Fletes y logística',
  otros: 'Otros',
}

/** Los tipos que admiten detalle de mano de obra (trabajador, avance, adelanto). */
export const TIPOS_CON_MANO_DE_OBRA = ['mano_de_obra', 'subcontrato']

export const LABOR_MODALITY = {
  jornal: 'Jornal',
  por_tarea: 'Por tarea',
  certificado: 'Certificado de avance',
}

export const PAYMENT_METHOD = {
  efectivo: 'Efectivo',
  transferencia: 'Transferencia',
  cheque: 'Cheque',
  tarjeta: 'Tarjeta',
  otro: 'Otro',
}

/* La última combinación rubro/tipo se recuerda por obra: en una jornada se
   cargan varios gastos seguidos del mismo rubro. localStorage puede no estar
   (navegación privada): sin él, simplemente no se recuerda. */
const clave = (projectId) => `ultimo-rubro-tipo:${projectId}`

export function leerUltimaCombinacion(projectId) {
  try {
    return JSON.parse(localStorage.getItem(clave(projectId))) ?? {}
  } catch {
    return {}
  }
}

export function guardarUltimaCombinacion(projectId, combinacion) {
  try {
    localStorage.setItem(clave(projectId), JSON.stringify(combinacion))
  } catch {
    /* sin almacenamiento, no se recuerda */
  }
}
