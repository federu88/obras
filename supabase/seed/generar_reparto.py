# -*- coding: utf-8 -*-
"""Genera el SQL del reparto de utilidades de SR084 y SR583."""
import io, datetime

OUT = (r"C:\Users\feder\AppData\Local\Temp\claude"
       r"\C--Users-feder-CLEAN-SEA-S-A-FILES-Terra-Mare---Documentos-Integra"
       r"\0a9c950f-204b-4a63-87e6-d9dcf23d54a3\scratchpad\carga-reparto.sql")

INVERSORES = ['Ale / Dani', 'Miguel', 'Fede', 'Gonzalo', 'Joaco']

# Aportes con la fecha que consta en la planilla. Donde no consta, se usa la
# fecha de compra del lote o la de la venta, y queda dicho en la nota.
F84 = 'REPARTO UTILIDAD CASAS SR084.xlsx'
F583 = 'REPARTO UTILIDAD CASAS SR583.xlsx'
CIERTA = 'fecha de la planilla'
ESTIM = 'fecha estimada: no consta en la planilla'

APORTES = [
    # (inversor, fecha, monto, nota)
    ('Ale / Dani', '2024-10-07', 41070, 'Compra del lote 84 · ' + CIERTA),
    ('Ale / Dani', '2025-03-20',  6500, CIERTA),
    ('Ale / Dani', '2025-03-28', 30000, CIERTA),
    ('Ale / Dani', '2025-05-26', 15000, CIERTA),
    ('Ale / Dani', '2025-07-05', 20000, CIERTA),
    ('Ale / Dani', '2025-07-16',  7000, 'Entregados a Mariu · ' + CIERTA),
    ('Ale / Dani', '2025-07-30',  2625, 'Aportes adicionales netos del lote San Ramón · ' + ESTIM),
    ('Miguel',     '2024-10-18', 18000, ESTIM),
    ('Fede',       '2024-10-18', 23110, ESTIM),
    ('Fede',       '2025-07-30', 15000, 'Aporte adicional · ' + ESTIM),
    ('Gonzalo',    '2024-10-18', 10000, ESTIM),
    ('Joaco',      '2024-10-18', 11000, ESTIM),
    ('Joaco',      '2025-07-30',  9000, 'Aporte adicional · ' + ESTIM),
]

# Base de reparto por casa, según la planilla de cada una.
SOCIOS_084 = {'Ale / Dani': 122195, 'Miguel': 18000, 'Fede': 38110,
              'Gonzalo': 10000, 'Joaco': 20000}
SOCIOS_583 = {'Ale / Dani': 119570, 'Miguel': 18000, 'Fede': 23110,
              'Gonzalo': 10000, 'Joaco': 11000}

CASAS = {
    'SR084': dict(socios=SOCIOS_084, venta=185000, broker=0.025,
                  costo=149012.39, utilidad=31362.61,
                  fecha_venta='2025-07-30', fuente=F84),
    'SR583': dict(socios=SOCIOS_583, venta=185000, broker=0.04,
                  costo=135070.00, utilidad=42530.00,
                  fecha_venta='2026-01-15', fuente=F583),
}

REINVERSION = dict(monto=28375, fecha='2025-07-30',
                   nota='Recuperado de la venta de SR084 y puesto en SR583 '
                        '(el lote San Ramón del cuadro)')


def q(s):
    return "'" + str(s).replace("'", "''") + "'"


o = []
w = o.append
w('-- ===========================================================================')
w('-- Reparto de utilidades de SR084 y SR583')
w('-- Generado el %s desde las dos planillas de REPARTO UTILIDAD.' % datetime.date.today())
w('-- Correr UNA SOLA VEZ, después de 0020_conciliacion.sql.')
w('--')
w('-- Criterio de reparto: PROPORCIONAL AL APORTE, como se definió.')
w('-- En SR084 la planilla dividía por 236.680 (que incluye el lote) pero solo')
w('-- repartía entre los cinco socios, y por eso quedaban 3.760 sin asignar. Acá')
w('-- se usa la base de socios que la propia planilla declara: 208.305.')
w('-- ===========================================================================')
w('')
w('begin;')
w('')
w('-- 1. Inversores -------------------------------------------------------------')
for nombre in INVERSORES:
    w('insert into public.investors (name, joined_on)')
    w('  select %s, date %s' % (q(nombre), q('2024-10-07')))
    w('  where not exists (select 1 from public.investors where name = %s);' % q(nombre))
w('')

w('-- 2. Aportes de capital, imputados a SR084 (la primera casa del pool) --------')
w('-- Se cargan UNA sola vez: el pool financió las dos casas, y cargarlos otra')
w('-- vez contra SR583 los contaría doble.')
for inv, fecha, monto, nota in APORTES:
    w('insert into public.capital_movements')
    w('       (type, investor_id, project_id, movement_date, amount, currency, concept)')
    w('  select \'aporte\', i.id, p.id, date %s, %s, \'USD\', %s'
      % (q(fecha), monto, q(nota)))
    w('  from public.investors i, public.projects p')
    w('  where i.name = %s and p.code = \'SR084\';' % q(inv))
w('')

w('-- 3. Venta de cada casa -----------------------------------------------------')
for code, c in CASAS.items():
    w('insert into public.revenues (project_id, kind, description, revenue_date, amount, currency)')
    w('  select p.id, \'venta\', %s, date %s, %s, \'USD\''
      % (q('Venta según ' + c['fuente']), q(c['fecha_venta']), c['venta']))
    w('  from public.projects p where p.code = %s;' % q(code))
w('')

w('-- 4. Reinversión de SR084 en SR583 ------------------------------------------')
w('-- Va como transferencia entre proyectos porque es plata del pool, no de un')
w('-- inversor en particular.')
w('insert into public.capital_movements')
w('       (type, from_project_id, project_id, movement_date, amount, currency, concept)')
w('  select \'transferencia\', o.id, d.id, date %s, %s, \'USD\', %s'
  % (q(REINVERSION['fecha']), REINVERSION['monto'], q(REINVERSION['nota'])))
w('  from public.projects o, public.projects d')
w('  where o.code = \'SR084\' and d.code = \'SR583\';')
w('')

w('-- 5. Utilidad asignada a cada inversor --------------------------------------')
for code, c in CASAS.items():
    base = sum(c['socios'].values())
    w('-- %s · base de socios %s · utilidad %s' % (code, f"{base:,}", f"{c['utilidad']:,.2f}"))
    acum = 0
    items = list(c['socios'].items())
    for idx, (inv, ap) in enumerate(items):
        if idx == len(items) - 1:
            monto = round(c['utilidad'] - acum, 2)   # el último absorbe el redondeo
        else:
            monto = round(c['utilidad'] * ap / base, 2)
            acum += monto
        pct = ap / base
        w('insert into public.capital_movements')
        w('       (type, investor_id, project_id, movement_date, amount, currency, concept)')
        w('  select \'profit_asignado\', i.id, p.id, date %s, %s, \'USD\', %s'
          % (q(c['fecha_venta']), monto, q('Participación %.2f%% sobre aporte de %s' % (pct * 100, f"{ap:,}"))))
        w('  from public.investors i, public.projects p')
        w('  where i.name = %s and p.code = %s;' % (q(inv), q(code)))
    w('')

w('-- 6. Valores de referencia de las planillas, para la conciliación -----------')
for code, c in CASAS.items():
    refs = [
        ('capital_aportado', sum(c['socios'].values()), 'Aporte de socios del cuadro'),
        ('costo_total', c['costo'], 'Costo estimado casa terminada'),
        ('venta', c['venta'], 'Venta bruta (comisión %.1f%%)' % (c['broker'] * 100)),
        ('utilidad', c['utilidad'], 'Utilidad total del cuadro'),
    ]
    for concepto, valor, nota in refs:
        w('insert into public.project_references')
        w('       (project_id, concepto, valor_usd, fuente, reference_date, note)')
        w('  select p.id, %s, %s, %s, date %s, %s'
          % (q(concepto), valor, q(c['fuente']), q(c['fecha_venta']), q(nota)))
        w('  from public.projects p where p.code = %s;' % q(code))
    w('')

w('-- 7. Comisión inmobiliaria de cada casa, según su planilla ------------------')
for code, c in CASAS.items():
    w('update public.projects set broker_fee_pct = %s, target_sale_usd = %s'
      % (c['broker'], c['venta']))
    w('  where code = %s;' % q(code))
w('')
w('commit;')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(o))

print('aportes            :', len(APORTES), '·', f"{sum(a[2] for a in APORTES):,}")
print('base socios SR084  :', f"{sum(SOCIOS_084.values()):,}")
print('base socios SR583  :', f"{sum(SOCIOS_583.values()):,}")
print('archivo            :', OUT)
