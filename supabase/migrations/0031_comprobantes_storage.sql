-- =============================================================================
-- 0031_comprobantes_storage.sql
--
-- Las fotos de los comprobantes, en su propio bucket privado.
--
-- Va en su propia migracion por lo mismo que 0024: crear politicas sobre
-- storage.objects a veces pide permisos que el SQL Editor no tiene. Si esta
-- parte falla, los comprobantes ya funcionan; se pierde la foto, no el gasto.
--
-- La ruta es <project_id>/<receipt_id>/<archivo>. El permiso sale de la
-- primera carpeta con la misma funcion que usan los documentos
-- (doc_project_id), asi que quien ve la obra ve sus comprobantes.
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'comprobantes', 'comprobantes', false,
  10485760,  -- 10 MB: una foto de celular sobra
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'application/pdf']
)
on conflict (id) do nothing;

create policy comprobantes_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'comprobantes'
    and public.doc_project_id(name) is not null
    and public.has_project_access(public.doc_project_id(name))
  );

create policy comprobantes_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'comprobantes'
    and public.can_manage()
    and public.doc_project_id(name) is not null
    and public.has_project_access(public.doc_project_id(name))
  );

create policy comprobantes_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'comprobantes'
    and public.can_manage()
    and public.has_project_access(public.doc_project_id(name))
  )
  with check (
    bucket_id = 'comprobantes'
    and public.can_manage()
    and public.has_project_access(public.doc_project_id(name))
  );

create policy comprobantes_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'comprobantes'
    and public.can_manage()
    and public.has_project_access(public.doc_project_id(name))
  );
