import { supabase } from './supabase'

/**
 * Acceso a datos — un solo lugar.
 *
 * Ninguna pantalla arma su propia consulta. Si dos vistas necesitan el mismo
 * dato, usan la misma función: es lo que evita que el mismo indicador termine
 * calculado de dos maneras distintas, que es exactamente el problema de las
 * planillas de origen.
 */

function unwrap({ data, error }) {
  if (error) throw new Error(error.message)
  return data
}

/* --- Proyectos ----------------------------------------------------------- */

export const listProjects = () =>
  supabase
    .from('projects')
    .select('*')
    .order('created_at', { ascending: false })
    .then(unwrap)

export const createProject = (payload) =>
  supabase.from('projects').insert(payload).select().single().then(unwrap)

export const updateProject = (id, patch) =>
  supabase.from('projects').update(patch).eq('id', id).select().single().then(unwrap)

/** Capital aportado y caja neta por proyecto (vista project_capital). */
export const listProjectCapital = () =>
  supabase.from('project_capital').select('*').then(unwrap)

/* --- Inversores ---------------------------------------------------------- */

export const listInvestors = () =>
  supabase.from('investors').select('*').order('name').then(unwrap)

export const createInvestor = (payload) =>
  supabase.from('investors').insert(payload).select().single().then(unwrap)

/** Consolidado por inversor (vista investor_summary). */
export const listInvestorSummary = () =>
  supabase.from('investor_summary').select('*').order('name').then(unwrap)

/** Posición de cada inversor en cada proyecto (vista investor_positions). */
export const listInvestorPositions = () =>
  supabase.from('investor_positions').select('*').then(unwrap)

/* --- Movimientos de capital ---------------------------------------------- */

export const listCapitalMovements = ({ limit = 200 } = {}) =>
  supabase
    .from('capital_movements')
    .select(
      `id, type, status, movement_date, amount, currency, fx_usd, amount_usd,
       concept,
       investor:investors ( id, name ),
       project:projects!capital_movements_project_id_fkey ( id, code, name ),
       origen:projects!capital_movements_from_project_id_fkey ( id, code, name )`
    )
    .order('movement_date', { ascending: false })
    .limit(limit)
    .then(unwrap)

export const createCapitalMovement = (payload) =>
  supabase.from('capital_movements').insert(payload).select().single().then(unwrap)

/** Los movimientos no se borran: se anulan. */
export const voidCapitalMovement = (id) =>
  supabase
    .from('capital_movements')
    .update({ status: 'anulado' })
    .eq('id', id)
    .select()
    .single()
    .then(unwrap)

/* --- Tipo de cambio ------------------------------------------------------ */

export const listFxRates = () =>
  supabase
    .from('fx_rates')
    .select('*')
    .order('rate_date', { ascending: false })
    .limit(100)
    .then(unwrap)

export const createFxRate = (payload) =>
  supabase.from('fx_rates').insert(payload).select().single().then(unwrap)

/** Cotización vigente a una fecha. Misma regla que la función fx_rate_at(). */
export async function fxRateAt(date, source = 'MEP') {
  const data = await supabase
    .from('fx_rates')
    .select('ars_per_usd, rate_date')
    .eq('source', source)
    .lte('rate_date', date)
    .order('rate_date', { ascending: false })
    .limit(1)
    .then(unwrap)
  return data?.[0]?.ars_per_usd ?? null
}
