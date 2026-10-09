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

/* --- Categorías de costo -------------------------------------------------- */

export const listCostCategories = () =>
  supabase
    .from('cost_category_paths')
    .select('*')
    .order('path')
    .then(unwrap)

/* --- Presupuesto ---------------------------------------------------------- */

export const listBudgetLines = (projectId) =>
  supabase
    .from('budget_variance')
    .select('*')
    .eq('project_id', projectId)
    .order('categoria')
    .then(unwrap)

export const createBudgetLine = (payload) =>
  supabase.from('budget_lines').insert(payload).select().single().then(unwrap)

export const updateBudgetLine = (id, patch) =>
  supabase.from('budget_lines').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteBudgetLine = (id) =>
  supabase.from('budget_lines').delete().eq('id', id).then(unwrap)

/* --- Gastos --------------------------------------------------------------- */

export const listExpenses = (projectId) =>
  supabase
    .from('expenses')
    .select('*, category:cost_categories ( id, name )')
    .eq('project_id', projectId)
    .order('expense_date', { ascending: false })
    .then(unwrap)

export const createExpense = (payload) =>
  supabase.from('expenses').insert(payload).select().single().then(unwrap)

export const updateExpense = (id, patch) =>
  supabase.from('expenses').update(patch).eq('id', id).select().single().then(unwrap)

/* --- Ingresos ------------------------------------------------------------- */

export const listRevenues = (projectId) =>
  supabase
    .from('revenues')
    .select('*')
    .eq('project_id', projectId)
    .order('revenue_date', { ascending: false })
    .then(unwrap)

export const createRevenue = (payload) =>
  supabase.from('revenues').insert(payload).select().single().then(unwrap)

/* --- P&L ------------------------------------------------------------------ */

export const listPnl = () =>
  supabase.from('project_pnl').select('*').order('code').then(unwrap)

export const getProject = (id) =>
  supabase.from('projects').select('*').eq('id', id).single().then(unwrap)

export const getProjectPnl = (id) =>
  supabase.from('project_pnl').select('*').eq('project_id', id).single().then(unwrap)

/* --- Caja ----------------------------------------------------------------- */

export const listCashBalances = () =>
  supabase.from('cash_balances').select('*').order('name').then(unwrap)

export const listCashAccounts = () =>
  supabase.from('cash_accounts').select('*').order('name').then(unwrap)

export const createCashAccount = (payload) =>
  supabase.from('cash_accounts').insert(payload).select().single().then(unwrap)

export const listCashMovements = ({ limit = 200 } = {}) =>
  supabase
    .from('cash_movements')
    .select('*, account:cash_accounts ( id, name, currency ), project:projects ( id, code )')
    .order('movement_date', { ascending: false })
    .limit(limit)
    .then(unwrap)

export const createCashMovement = (payload) =>
  supabase.from('cash_movements').insert(payload).select().single().then(unwrap)

export const listFxOperations = () =>
  supabase
    .from('fx_operations')
    .select('*')
    .order('operation_date', { ascending: false })
    .limit(100)
    .then(unwrap)

export const createFxOperation = (payload) =>
  supabase.from('fx_operations').insert(payload).select().single().then(unwrap)

/* --- Billetera de obra ---------------------------------------------------- */

/** Entradas, cambios y gastos de la billetera de una obra (vista wallet_ledger). */
export const listWalletLedger = (projectId) =>
  supabase
    .from('wallet_ledger')
    .select('*')
    .eq('project_id', projectId)
    .order('fecha', { ascending: false })
    .then(unwrap)

/** La conciliación de la billetera, en USD y en pesos (vista wallet_reconciliation). */
export const getWalletReconciliation = (projectId) =>
  supabase
    .from('wallet_reconciliation')
    .select('*')
    .eq('project_id', projectId)
    .single()
    .then(unwrap)

export const listWalletCounts = (projectId) =>
  supabase
    .from('wallet_counts')
    .select('*')
    .eq('project_id', projectId)
    .order('count_date', { ascending: false })
    .then(unwrap)

export const createWalletCount = (payload) =>
  supabase.from('wallet_counts').insert(payload).select().single().then(unwrap)

/** Cambio de dólares a pesos cargado desde la billetera, sin cuentas de caja. */
export const registrarCambioBilletera = ({ projectId, fecha, usd, cotizacion, nota }) =>
  supabase
    .rpc('registrar_cambio_billetera', {
      p_project_id: projectId,
      p_fecha: fecha,
      p_usd: usd,
      p_cotizacion: cotizacion,
      p_nota: nota || null,
    })
    .then(unwrap)

/* --- Cashflow ------------------------------------------------------------- */

export const listCashflowConsolidado = () =>
  supabase.from('cashflow_consolidado').select('*').order('month').then(unwrap)

export const listProjectCashflow = (projectId) =>
  supabase
    .from('project_cashflow')
    .select('*')
    .eq('project_id', projectId)
    .order('month')
    .then(unwrap)

/** Meses futuros que cierran en negativo: cuánta plata falta y cuándo. */
export const listCashRequirements = () =>
  supabase.from('cash_requirements').select('*').order('month').then(unwrap)

/* --- Proveedores ---------------------------------------------------------- */

export const listSuppliers = () =>
  supabase.from('suppliers').select('*').order('name').then(unwrap)

export const createSupplier = (payload) =>
  supabase.from('suppliers').insert(payload).select().single().then(unwrap)

export const updateSupplier = (id, patch) =>
  supabase.from('suppliers').update(patch).eq('id', id).select().single().then(unwrap)

/* --- Catálogo de items ---------------------------------------------------- */

/** Usa item_prices: trae el item con su historial de precios ya calculado. */
export const listItems = () =>
  supabase.from('item_prices').select('*').order('code').then(unwrap)

export const listItemsPlain = () =>
  supabase
    .from('items')
    .select('id, code, description, unit, kind, category_id')
    .eq('is_active', true)
    .order('code')
    .then(unwrap)

export const createItem = (payload) =>
  supabase.from('items').insert(payload).select().single().then(unwrap)

export const suggestItemCode = (categoryId) =>
  supabase.rpc('suggest_item_code', { p_category: categoryId }).then(unwrap)

/* --- Cotizaciones --------------------------------------------------------- */

export const listQuotes = ({ itemId } = {}) => {
  let q = supabase
    .from('supplier_quotes')
    .select('*, item:items ( id, code, description, unit ), supplier:suppliers ( id, name )')
    .order('quote_date', { ascending: false })
    .limit(300)
  if (itemId) q = q.eq('item_id', itemId)
  return q.then(unwrap)
}

export const createQuote = (payload) =>
  supabase.from('supplier_quotes').insert(payload).select().single().then(unwrap)

/** Comparativa de proveedores para un item. */
export const listSupplierPrices = (itemId) =>
  supabase
    .from('supplier_item_prices')
    .select('*')
    .eq('item_id', itemId)
    .order('mejor_precio_usd')
    .then(unwrap)

/* --- Compras (gastos con item y proveedor) -------------------------------- */

export const listPurchases = () =>
  supabase
    .from('expenses')
    .select(
      `id, description, expense_date, qty, unit_price, currency, fx_usd, amount_usd,
       status, purchase_stage, payment_terms,
       item:items ( id, code, description, unit ),
       supplier:suppliers ( id, name ),
       project:projects ( id, code, name )`
    )
    .not('item_id', 'is', null)
    .order('expense_date', { ascending: false })
    .limit(300)
    .then(unwrap)

export const updatePurchaseStage = (id, stage) =>
  supabase
    .from('expenses')
    .update({ purchase_stage: stage })
    .eq('id', id)
    .select()
    .single()
    .then(unwrap)

/* --- Análisis de desvíos --------------------------------------------------- */

export const listProcurementVariance = (projectId) =>
  supabase
    .from('procurement_variance')
    .select('*')
    .eq('project_id', projectId)
    .order('categoria')
    .then(unwrap)

export const listVarianceByCategory = (projectId) =>
  supabase
    .from('variance_by_category')
    .select('*')
    .eq('project_id', projectId)
    .order('categoria')
    .then(unwrap)

/* --- Cronograma ----------------------------------------------------------- */

export const listTasks = (projectId) =>
  supabase
    .from('task_schedule')
    .select('*')
    .eq('project_id', projectId)
    .order('sort_order')
    .then(unwrap)

export const createTask = (payload) =>
  supabase.from('tasks').insert(payload).select().single().then(unwrap)

export const updateTask = (id, patch) =>
  supabase.from('tasks').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteTask = (id) =>
  supabase.from('tasks').delete().eq('id', id).then(unwrap)

export const getProjectProgress = (projectId) =>
  supabase.from('project_progress').select('*').eq('project_id', projectId).single().then(unwrap)

export const listProjectProgress = () =>
  supabase.from('project_progress').select('*').order('code').then(unwrap)

export const listScheduleAlerts = (projectId) => {
  let q = supabase.from('schedule_alerts').select('*').order('planned_finish')
  if (projectId) q = q.eq('project_id', projectId)
  return q.then(unwrap)
}

export const listDependencyImpact = (projectId) =>
  supabase
    .from('dependency_impact')
    .select('*')
    .eq('project_id', projectId)
    .then(unwrap)

export const listTaskDependencies = (projectId) =>
  supabase
    .from('task_dependencies')
    .select('task_id, depends_on_id, lag_days, task:tasks!task_dependencies_task_id_fkey ( project_id )')
    .then(unwrap)

export const createTaskDependency = (payload) =>
  supabase.from('task_dependencies').insert(payload).select().single().then(unwrap)

/* --- Reporting ------------------------------------------------------------ */

export const getBusinessSummary = () =>
  supabase.from('business_summary').select('*').single().then(unwrap)

export const listProjectHealth = () =>
  supabase.from('project_health').select('*').order('code').then(unwrap)

export const listInvestorReport = (investorId) => {
  let q = supabase.from('investor_report').select('*').order('investor_name')
  if (investorId) q = q.eq('investor_id', investorId)
  return q.then(unwrap)
}

export const getInvestor = (id) =>
  supabase.from('investors').select('*').eq('id', id).single().then(unwrap)

export const listInvestorMovements = (investorId) =>
  supabase
    .from('capital_movements')
    .select(
      `id, type, status, movement_date, amount, currency, amount_usd, concept,
       project:projects!capital_movements_project_id_fkey ( id, code, name ),
       origen:projects!capital_movements_from_project_id_fkey ( id, code )`
    )
    .eq('investor_id', investorId)
    .order('movement_date', { ascending: false })
    .then(unwrap)

/* --- Usuarios ------------------------------------------------------------- */

export const listProfiles = () =>
  supabase
    .from('profiles')
    .select('id, full_name, email, role, is_active, created_at')
    .order('created_at')
    .then(unwrap)

export const updateProfileRole = (id, role) =>
  supabase.from('profiles').update({ role }).eq('id', id).select().single().then(unwrap)

/* --- Día a día de obra ----------------------------------------------------- */

/** Operación de cambio: mueve las dos cajas en una sola transacción. */
export const registrarCambio = ({
  fecha,
  usd,
  cotizacion,
  cuentaUsd,
  cuentaArs,
  projectId,
  nota,
}) =>
  supabase
    .rpc('registrar_operacion_cambio', {
      p_fecha: fecha,
      p_usd: usd,
      p_cotizacion: cotizacion,
      p_cuenta_usd: cuentaUsd,
      p_cuenta_ars: cuentaArs,
      p_project_id: projectId ?? null,
      p_nota: nota ?? null,
    })
    .then(unwrap)

export const getGastoMensual = (projectId) =>
  supabase
    .from('gasto_mensual')
    .select('*')
    .eq('project_id', projectId)
    .order('month', { ascending: false })
    .limit(6)
    .then(unwrap)

/** Últimos gastos de una obra, para la carga del día. */
export const listGastosRecientes = (projectId, limit = 40) =>
  supabase
    .from('expenses')
    .select(
      `id, description, expense_date, qty, unit_price, currency, fx_usd, amount_usd,
       status, supplier_name,
       category:cost_categories ( id, name ),
       supplier:suppliers ( id, name )`
    )
    .eq('project_id', projectId)
    .neq('status', 'anulado')
    .order('expense_date', { ascending: false })
    .order('created_at', { ascending: false })
    .limit(limit)
    .then(unwrap)

/* --- Actualizaciones ------------------------------------------------------- */

export const updateInvestor = (id, patch) =>
  supabase.from('investors').update(patch).eq('id', id).select().single().then(unwrap)

export const updateItem = (id, patch) =>
  supabase.from('items').update(patch).eq('id', id).select().single().then(unwrap)

export const updateCapitalMovement = (id, patch) =>
  supabase
    .from('capital_movements')
    .update(patch)
    .eq('id', id)
    .select()
    .single()
    .then(unwrap)

export const updateRevenue = (id, patch) =>
  supabase.from('revenues').update(patch).eq('id', id).select().single().then(unwrap)

export const updateCashAccount = (id, patch) =>
  supabase.from('cash_accounts').update(patch).eq('id', id).select().single().then(unwrap)

export const updateFxRate = (id, patch) =>
  supabase.from('fx_rates').update(patch).eq('id', id).select().single().then(unwrap)

/** El item crudo. item_prices no trae category_id, y editando desde la vista
 *  se perdería la categoría. */
export const getItem = (id) =>
  supabase.from('items').select('*').eq('id', id).single().then(unwrap)

/** La línea cruda. budget_variance no trae item_id, category_id ni forecast. */
export const getBudgetLine = (id) =>
  supabase.from('budget_lines').select('*').eq('id', id).single().then(unwrap)

export const updateQuote = (id, patch) =>
  supabase.from('supplier_quotes').update(patch).eq('id', id).select().single().then(unwrap)

/* --- Historial de precios --------------------------------------------------- */

/** Las tres fuentes en una línea de tiempo: referencia, cotización y compra. */
export const listItemPriceHistory = (itemId) =>
  supabase
    .from('item_price_history')
    .select('*')
    .eq('item_id', itemId)
    .order('fecha', { ascending: false })
    .then(unwrap)

export const listItemTrends = () =>
  supabase.from('item_price_trend').select('*').then(unwrap)

export const createPricePoint = (payload) =>
  supabase.from('item_price_points').insert(payload).select().single().then(unwrap)

/* --- Plan de obra ----------------------------------------------------------- */

/** El presupuesto visto como plan: item, fecha prevista y actividad. */
export const listPlanDeObra = (projectId) =>
  supabase
    .from('plan_de_obra')
    .select('*')
    .eq('project_id', projectId)
    .order('planned_date', { nullsFirst: false })
    .then(unwrap)

/** Alta masiva: el arquitecto elige muchos items de una vez. */
export const createBudgetLines = (rows) =>
  supabase.from('budget_lines').insert(rows).select().then(unwrap)

/* --- Conciliación ----------------------------------------------------------- */

/** Lo que dicen las planillas contra lo que está cargado, concepto por concepto. */
export const listReconciliation = (projectId) => {
  let q = supabase.from('project_reconciliation').select('*').order('concepto')
  if (projectId) q = q.eq('project_id', projectId)
  return q.then(unwrap)
}

export const listConciliacionResumen = () =>
  supabase.from('conciliacion_resumen').select('*').order('code').then(unwrap)

export const listReferences = (projectId) =>
  supabase
    .from('project_references')
    .select('*')
    .eq('project_id', projectId)
    .order('reference_date', { ascending: false })
    .then(unwrap)

export const createReference = (payload) =>
  supabase.from('project_references').insert(payload).select().single().then(unwrap)

/* ---------------------------------------------------------------------------
 * Plantilla de etapas de obra
 * ------------------------------------------------------------------------- */

/** Los pasos estándar para construir una casa, en orden de ejecución. */
export const listTaskTemplates = () =>
  supabase.from('task_templates').select('*').order('sort_order').then(unwrap)

export const createTaskTemplate = (payload) =>
  supabase.from('task_templates').insert(payload).select().single().then(unwrap)

export const updateTaskTemplate = (id, patch) =>
  supabase.from('task_templates').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteTaskTemplate = (id) =>
  supabase.from('task_templates').delete().eq('id', id).then(unwrap)

/** Genera el cronograma de una obra a partir de la plantilla. Devuelve cuántas creó. */
export const aplicarPlantillaObra = (projectId, inicio) =>
  supabase
    .rpc('aplicar_plantilla_obra', { p_project: projectId, p_inicio: inicio })
    .then(unwrap)

/* ---------------------------------------------------------------------------
 * Baja de inversores
 * ------------------------------------------------------------------------- */

/**
 * Cuántos movimientos de capital tiene un inversor.
 *
 * Un inversor con movimientos no se puede borrar: la FK lo impide, y con razón,
 * porque borrarlo dejaría plata sin dueño. Sirve para decirlo antes de que el
 * usuario apriete el botón, en vez de mostrarle un error de Postgres.
 */
export const countInvestorMovements = (investorId) =>
  supabase
    .from('capital_movements')
    .select('id', { count: 'exact', head: true })
    .eq('investor_id', investorId)
    .then(({ error, count }) => {
      if (error) throw new Error(error.message)
      return count ?? 0
    })

export const deleteInvestor = (id) =>
  supabase.from('investors').delete().eq('id', id).then(unwrap)

/* ---------------------------------------------------------------------------
 * Obra por encargo: clientes, contrato, adicionales, certificados
 * ------------------------------------------------------------------------- */

export const listClients = () =>
  supabase.from('clients').select('*').order('name').then(unwrap)

export const createClient = (payload) =>
  supabase.from('clients').insert(payload).select().single().then(unwrap)

export const updateClient = (id, patch) =>
  supabase.from('clients').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteClient = (id) =>
  supabase.from('clients').delete().eq('id', id).then(unwrap)

/** Cuántas obras tiene un cliente. Con obras no se borra: quedaría un contrato huérfano. */
export const countClientProjects = (clientId) =>
  supabase
    .from('contracts')
    .select('id', { count: 'exact', head: true })
    .eq('client_id', clientId)
    .then(({ error, count }) => {
      if (error) throw new Error(error.message)
      return count ?? 0
    })

/** El contrato de una obra, o null si todavía no se cargó. */
export const getContract = (projectId) =>
  supabase
    .from('contracts')
    .select('*')
    .eq('project_id', projectId)
    .maybeSingle()
    .then(unwrap)

/** Contrato vigente, certificado, cobrado y saldos, ya calculados. */
export const getContractSummary = (projectId) =>
  supabase
    .from('contract_summary')
    .select('*')
    .eq('project_id', projectId)
    .maybeSingle()
    .then(unwrap)

export const createContract = (payload) =>
  supabase.from('contracts').insert(payload).select().single().then(unwrap)

export const updateContract = (id, patch) =>
  supabase.from('contracts').update(patch).eq('id', id).select().single().then(unwrap)

export const listChangeOrders = (contractId) =>
  supabase
    .from('change_orders')
    .select('*')
    .eq('contract_id', contractId)
    .order('order_date')
    .then(unwrap)

export const createChangeOrder = (payload) =>
  supabase.from('change_orders').insert(payload).select().single().then(unwrap)

export const updateChangeOrder = (id, patch) =>
  supabase.from('change_orders').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteChangeOrder = (id) =>
  supabase.from('change_orders').delete().eq('id', id).then(unwrap)

export const listCertificates = (projectId) =>
  supabase
    .from('certificates')
    .select('*')
    .eq('project_id', projectId)
    .order('number')
    .then(unwrap)

export const createCertificate = (payload) =>
  supabase.from('certificates').insert(payload).select().single().then(unwrap)

export const updateCertificate = (id, patch) =>
  supabase.from('certificates').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteCertificate = (id) =>
  supabase.from('certificates').delete().eq('id', id).then(unwrap)

/** Resultado del estudio en la obra: cobrado menos lo que puso de su bolsillo. */
export const getEncargoPnl = (projectId) =>
  supabase
    .from('project_encargo_pnl')
    .select('*')
    .eq('project_id', projectId)
    .maybeSingle()
    .then(unwrap)

/* ---------------------------------------------------------------------------
 * Bitácora
 * ------------------------------------------------------------------------- */

export const listProjectLog = (projectId) =>
  supabase
    .from('project_log')
    .select('*')
    .eq('project_id', projectId)
    .order('log_date', { ascending: false })
    .then(unwrap)

export const createLogEntry = (payload) =>
  supabase.from('project_log').insert(payload).select().single().then(unwrap)

export const updateLogEntry = (id, patch) =>
  supabase.from('project_log').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteLogEntry = (id) =>
  supabase.from('project_log').delete().eq('id', id).then(unwrap)

/* ---------------------------------------------------------------------------
 * Documentos
 *
 * El registro y el archivo van separados: una factura existe aunque el PDF
 * todavía no esté subido.
 * ------------------------------------------------------------------------- */

export const listDocuments = (projectId) =>
  supabase
    .from('documents')
    .select('*')
    .eq('project_id', projectId)
    .order('doc_date', { ascending: false })
    .then(unwrap)

export const createDocument = (payload) =>
  supabase.from('documents').insert(payload).select().single().then(unwrap)

export const updateDocument = (id, patch) =>
  supabase.from('documents').update(patch).eq('id', id).select().single().then(unwrap)

/** Sube el archivo al bucket privado. La carpeta es el proyecto: de ahí sale el permiso. */
export async function uploadDocumentFile(projectId, file) {
  const limpio = file.name.replace(/[^\w.\-]+/g, '_')
  const path = `${projectId}/${crypto.randomUUID()}-${limpio}`
  const { error } = await supabase.storage.from('documentos').upload(path, file)
  if (error) throw new Error(error.message)
  return {
    storage_path: path,
    file_name: file.name,
    mime_type: file.type || null,
    size_bytes: file.size,
  }
}

/** URL temporal para ver o bajar el archivo. El bucket es privado: no hay link fijo. */
export async function getDocumentUrl(path, segundos = 300) {
  const { data, error } = await supabase.storage
    .from('documentos')
    .createSignedUrl(path, segundos)
  if (error) throw new Error(error.message)
  return data.signedUrl
}

export async function deleteDocument(doc) {
  if (doc.storage_path) {
    await supabase.storage.from('documentos').remove([doc.storage_path])
  }
  return supabase.from('documents').delete().eq('id', doc.id).then(unwrap)
}

/** El negocio del estudio en una fila. Para un inversor vuelve todo en cero. */
export const getEncargoSummary = () =>
  supabase.from('encargo_summary').select('*').maybeSingle().then(unwrap)

/** Una fila por obra por encargo, con avance certificado y resultado. */
export const listEncargoHealth = () =>
  supabase.from('encargo_health').select('*').order('code').then(unwrap)

/* ---------------------------------------------------------------------------
 * El catálogo del catálogo: marcas y tipos de item
 *
 * Dos textos que se escriben distinto pero significan lo mismo no pueden ser
 * dos filas. Las funciones resolver_* devuelven el id del que ya existe si el
 * nombre normalizado coincide, y recién si no existe lo crean.
 * ------------------------------------------------------------------------- */

export const listBrands = () =>
  supabase.from('brands').select('*').order('name').then(unwrap)

export const listItemTypes = () =>
  supabase.from('item_types').select('*').order('name').then(unwrap)

/** Uso y rango de precios de cada tipo. Sirve para comparar lo que hace lo mismo. */
export const listItemTypeUsage = () =>
  supabase.from('item_type_usage').select('*').order('tipo').then(unwrap)

export const resolverMarca = (name) =>
  supabase.rpc('resolver_marca', { p_name: name }).then(unwrap)

export const resolverTipoItem = (name) =>
  supabase.rpc('resolver_tipo_item', { p_name: name }).then(unwrap)

export const updateItemType = (id, patch) =>
  supabase.from('item_types').update(patch).eq('id', id).select().single().then(unwrap)

export const updateBrand = (id, patch) =>
  supabase.from('brands').update(patch).eq('id', id).select().single().then(unwrap)

export const deleteItemType = (id) =>
  supabase.from('item_types').delete().eq('id', id).then(unwrap)

export const deleteBrand = (id) =>
  supabase.from('brands').delete().eq('id', id).then(unwrap)

/**
 * ¿Este usuario puede ver el negocio del estudio?
 *
 * Se le pregunta a la base en vez de mirar el rol acá. La regla vive en
 * can_see_encargo() y es la misma que usa la RLS: si se cambia allá, la
 * pantalla la sigue sola. Duplicarla en el front es pedir que se desincronicen.
 */
export const puedeVerEncargo = () =>
  supabase.rpc('can_see_encargo').then(unwrap)
