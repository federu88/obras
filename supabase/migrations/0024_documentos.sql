-- =============================================================================
-- 0024_documentos.sql
--
-- Facturas, remitos, planos y aprobaciones, con el archivo adjunto.
--
-- Va en su propia migracion porque toca storage, y crear politicas sobre
-- storage.objects a veces pide permisos que el SQL Editor no tiene segun como
-- este configurado el proyecto. Si esta parte falla, el resto del sistema de
-- obra por encargo ya quedo funcionando: se pierde el adjunto, no el registro.
--
-- El registro y el archivo estan separados a proposito. Una factura existe
-- aunque nadie haya subido el PDF: primero se anota que entro, despues aparece
-- el papel. Al reves nunca pasa.
-- =============================================================================

create type document_kind as enum (
  'factura_emitida',   -- la que el estudio le emite al cliente
  'factura_recibida',  -- la del proveedor
  'remito',
  'presupuesto',
  'contrato',
  'plano',
  'aprobacion',
  'foto',
  'otro'
);

create table public.documents (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete cascade,
  kind            document_kind not null default 'otro',

  doc_date        date not null default current_date,
  number          text,                 -- numero de factura o remito
  description     text not null,

  -- Opcional: un plano no tiene monto, una factura si.
  amount          numeric(18,2) check (amount is null or amount >= 0),
  currency        currency,
  fx_usd          numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd      numeric(18,2) generated always as (
                    case when amount is null        then null
                         when currency = 'USD'      then amount
                         when fx_usd is null        then null
                         else round(amount / fx_usd, 2) end
                  ) stored,

  -- A que se refiere. Todos opcionales: un documento puede colgar solo del
  -- proyecto.
  supplier_id     uuid references public.suppliers(id) on delete set null,
  expense_id      uuid references public.expenses(id) on delete set null,
  certificate_id  uuid references public.certificates(id) on delete set null,
  change_order_id uuid references public.change_orders(id) on delete set null,

  -- El archivo en el bucket "documentos". Nulo mientras no se haya subido.
  storage_path    text unique,
  file_name       text,
  mime_type       text,
  size_bytes      bigint check (size_bytes is null or size_bytes >= 0),

  -- Un documento interno nunca sale en un reporte para el cliente. Misma regla
  -- que el margen y que las notas de la bitacora.
  with_client     boolean not null default false,

  notes           text,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint documents_fx_required
    check (amount is null or currency = 'USD' or fx_usd is not null)
);

create trigger documents_set_updated_at
  before update on public.documents
  for each row execute function public.set_updated_at();

create index documents_project_idx  on public.documents (project_id, doc_date desc);
create index documents_expense_idx  on public.documents (expense_id);
create index documents_cert_idx     on public.documents (certificate_id);

comment on table public.documents is
  'Facturas y papeles de la obra. El archivo vive en el bucket "documentos", bajo <project_id>/.';

-- -----------------------------------------------------------------------------
-- RLS del registro
-- -----------------------------------------------------------------------------
alter table public.documents enable row level security;

create policy documents_select on public.documents
  for select to authenticated using (public.has_project_access(project_id));

create policy documents_write on public.documents
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

grant select on public.documents to authenticated;
grant insert, update, delete on public.documents to authenticated;

-- =============================================================================
-- El archivo
-- =============================================================================

-- Privado: sin esto cualquiera con la URL lee las facturas de la obra.
insert into storage.buckets (id, name, public)
values ('documentos', 'documentos', false)
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- El permiso sale de la carpeta: el archivo va en <project_id>/<archivo>, asi
-- que quien tiene acceso al proyecto tiene acceso a sus papeles.
--
-- La funcion existe para que un nombre mal formado devuelva null en vez de
-- reventar el cast dentro de la politica. Una politica que tira excepcion
-- rompe la consulta entera, y eso es peor que negar el acceso.
-- -----------------------------------------------------------------------------
create or replace function public.doc_project_id(p_name text)
returns uuid
language plpgsql
immutable
as $fn$
begin
  return (storage.foldername(p_name))[1]::uuid;
exception when others then
  return null;
end;
$fn$;

grant execute on function public.doc_project_id(text) to authenticated;

create policy documentos_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'documentos'
    and public.doc_project_id(name) is not null
    and public.has_project_access(public.doc_project_id(name))
  );

create policy documentos_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'documentos'
    and public.doc_project_id(name) is not null
    and public.can_manage()
  );

create policy documentos_update on storage.objects
  for update to authenticated
  using (bucket_id = 'documentos' and public.can_manage())
  with check (bucket_id = 'documentos' and public.can_manage());

create policy documentos_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'documentos' and public.can_manage());
