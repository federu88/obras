# -*- coding: utf-8 -*-
"""Genera el manual de uso de Obras en PDF.

    pip install reportlab
    python docs/generar_manual.py

Ojo con los caracteres: las fuentes estándar de PDF no tienen flechas ni
subíndices, y se imprimen como cuadrados negros. Solo se usan caracteres que
existen en WinAnsi: acentos, comillas angulares, guion largo, ›, ·, ², × y ÷.
"""
import os

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (BaseDocTemplate, Frame, PageBreak, PageTemplate,
                                Paragraph, Spacer, Table, TableStyle)

SALIDA = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Manual-Obras.pdf')

# Paleta de la app
BRONCE = colors.HexColor('#b4703a')
TINTA = colors.HexColor('#16181d')
GRIS = colors.HexColor('#6b7280')
BORDE = colors.HexColor('#e3e0d9')
FONDO = colors.HexColor('#f7f6f3')
AVISO = colors.HexColor('#fdf3d8')
AVISO_B = colors.HexColor('#9a6b00')

ss = getSampleStyleSheet()


def st(name, **kw):
    base = dict(fontName='Helvetica', fontSize=9.5, leading=14, textColor=TINTA,
                alignment=TA_LEFT, spaceAfter=6)
    base.update(kw)
    return ParagraphStyle(name, **base)


H1 = st('H1', fontName='Helvetica-Bold', fontSize=19, leading=23,
        textColor=TINTA, spaceBefore=4, spaceAfter=3)
SUB = st('SUB', fontSize=10.5, leading=15, textColor=GRIS, spaceAfter=14)
H2 = st('H2', fontName='Helvetica-Bold', fontSize=13, leading=17,
        textColor=BRONCE, spaceBefore=16, spaceAfter=7)
H3 = st('H3', fontName='Helvetica-Bold', fontSize=10.5, leading=14,
        spaceBefore=10, spaceAfter=4)
P = st('P')
LI = st('LI', leftIndent=12, bulletIndent=2, spaceAfter=4)
NOTA = st('NOTA', fontSize=9, leading=13, textColor=TINTA)
CEL = st('CEL', fontSize=8.8, leading=12)
CELB = st('CELB', fontSize=8.8, leading=12, fontName='Helvetica-Bold')
PIE = st('PIE', fontSize=8, textColor=GRIS)


def parrafos(texto):
    return Paragraph(texto, P)


def vinetas(items):
    return [Paragraph(f'&bull;&nbsp;&nbsp;{t}', LI) for t in items]


def tabla(filas, anchos, encabezado=True):
    data = []
    for i, fila in enumerate(filas):
        estilo = CELB if (encabezado and i == 0) else CEL
        data.append([Paragraph(str(c), estilo) for c in fila])

    t = Table(data, colWidths=anchos, hAlign='LEFT')
    estilos = [
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LINEBELOW', (0, 0), (-1, -2), 0.4, BORDE),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 7),
        ('RIGHTPADDING', (0, 0), (-1, -1), 7),
    ]
    if encabezado:
        estilos += [('BACKGROUND', (0, 0), (-1, 0), FONDO),
                    ('LINEBELOW', (0, 0), (-1, 0), 0.8, BORDE)]
    t.setStyle(TableStyle(estilos))
    return t


def aviso(texto):
    t = Table([[Paragraph(texto, NOTA)]], colWidths=[165 * mm], hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), AVISO),
        ('LINEBEFORE', (0, 0), (0, -1), 2.5, AVISO_B),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    return t


def paso(n, titulo, cuerpo):
    izq = Table([[Paragraph(f'<font color="white"><b>{n}</b></font>',
                            st('n', fontSize=11, textColor=colors.white))]],
                colWidths=[8 * mm], rowHeights=[8 * mm])
    izq.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BRONCE),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 0),
        ('RIGHTPADDING', (0, 0), (-1, -1), 0),
        ('TOPPADDING', (0, 0), (-1, -1), 2),
    ]))
    der = [Paragraph(f'<b>{titulo}</b>', H3)] + [Paragraph(c, P) for c in cuerpo]
    t = Table([[izq, der]], colWidths=[11 * mm, 154 * mm], hAlign='LEFT')
    t.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 0),
        ('TOPPADDING', (0, 0), (-1, -1), 2),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
    ]))
    return t


# =============================================================================
# Contenido
# =============================================================================
S = []
a = S.append

# --- Portada -----------------------------------------------------------------
a(Spacer(1, 45 * mm))
marca = Table([[Paragraph('<font color="white"><b>OB</b></font>',
                          st('m', fontSize=15, textColor=colors.white))]],
              colWidths=[13 * mm], rowHeights=[13 * mm], hAlign='LEFT')
marca.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, -1), BRONCE),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('LEFTPADDING', (0, 0), (-1, -1), 0), ('RIGHTPADDING', (0, 0), (-1, -1), 0),
    ('TOPPADDING', (0, 0), (-1, -1), 3),
]))
a(marca)
a(Spacer(1, 10 * mm))
a(Paragraph('Obras', st('t', fontName='Helvetica-Bold', fontSize=34, leading=38)))
a(Paragraph('Manual de uso', st('t2', fontSize=15, leading=20, textColor=BRONCE,
                                spaceAfter=18)))
a(Paragraph(
    'Plataforma de gestión para el desarrollo, la construcción y la '
    'comercialización de casas. Reemplaza las planillas de presupuesto, gastos '
    'y reparto de utilidad por un solo lugar donde todo está conectado.',
    st('td', fontSize=11, leading=17, textColor=GRIS)))
a(Spacer(1, 28 * mm))
a(tabla([
    ['Para quién', 'Qué encuentra acá'],
    ['Quien dirige la obra', 'Cómo cargar los gastos del día y planificar los materiales'],
    ['Quien administra', 'Cómo se calculan el costo, el margen y la necesidad de caja'],
    ['Los inversores', 'Cómo se registra el capital y cómo se reparte la utilidad'],
], [42 * mm, 123 * mm]))
a(PageBreak())

# --- 1 -----------------------------------------------------------------------
a(Paragraph('Lo primero', H1))
a(Paragraph('Tres ideas que explican todo lo demás.', SUB))

a(Paragraph('Todo se mide en dólares', H2))
a(parrafos(
    'El peso es moneda de transacción, no unidad de medida: un gasto de hace '
    'seis meses no se puede comparar con uno de hoy si está en pesos. Por eso '
    '<b>cada importe se guarda con su moneda y la cotización de su fecha</b>, y '
    'el valor en dólares se calcula solo. Nunca hay que convertir a mano.'))

a(Paragraph('Cada casa es un proyecto', H2))
a(parrafos(
    'Una casa no es un archivo ni una carpeta: es un registro dentro del '
    'sistema. Todo lo que le pasa —presupuesto, gastos, cronograma, ingresos, '
    'capital— cuelga de ese proyecto. Agregar una casa nueva es cargar un '
    'proyecto, no armar todo de nuevo.'))

a(Paragraph('Nada se borra', H2))
a(parrafos(
    'Los registros financieros no se eliminan: se anulan. Un gasto anulado '
    'queda visible, tachado, con su historia. Lo mismo con los movimientos de '
    'capital y los precios. Es lo que permite reconstruir cómo se llegó a un '
    'número meses después.'))

a(Spacer(1, 6))
a(aviso(
    '<b>Si entendés estas cinco palabras, entendés el sistema.</b> Aparecen en '
    'casi todas las pantallas y significan cosas distintas.'))
a(Spacer(1, 8))
a(tabla([
    ['Palabra', 'Qué significa'],
    ['<b>Budget</b>', 'El presupuesto original, congelado. No se toca nunca: es la referencia contra la que se mide todo.'],
    ['<b>Forecast</b>', 'Lo que hoy se cree que va a costar. Cambia a medida que avanza la obra.'],
    ['<b>Actual</b>', 'Lo que ya se gastó de verdad. Solo cuenta lo recibido o pagado.'],
    ['<b>Comprometido</b>', 'Plata que ya tiene dueño: una compra aprobada que todavía no llegó. No es costo todavía, pero no se puede gastar en otra cosa.'],
    ['<b>Pendiente</b>', 'Lo que queda del presupuesto sin ejecutar. Es lo que proyecta cuánta plata va a hacer falta.'],
], [30 * mm, 135 * mm]))
a(PageBreak())

# --- 2 -----------------------------------------------------------------------
a(Paragraph('Entrar', H1))
a(Paragraph('No hay registro abierto: las cuentas las crea un administrador.', SUB))
a(parrafos(
    'Se entra con correo y contraseña. Si todavía no tenés cuenta, pedísela a '
    'quien administra el sistema; nadie puede crearse una por su cuenta.'))
a(Spacer(1, 4))
a(Paragraph('Qué ve cada uno', H2))
a(parrafos('El acceso no es igual para todos, y eso es a propósito.'))
a(tabla([
    ['Rol', 'Alcance'],
    ['Admin', 'Todo, incluido crear usuarios y cambiar permisos.'],
    ['Manager', 'Proyectos, presupuestos, gastos, compras y cronogramas. No gestiona usuarios.'],
    ['Viewer', 'Solo lectura de todo el negocio.'],
    ['Investor', 'Únicamente las obras donde participa y su propia posición. No ve lo que pusieron los demás, ni los precios de proveedores, ni la caja.'],
], [28 * mm, 137 * mm]))
a(Spacer(1, 8))
a(aviso(
    'El rol <b>Investor</b> es el que protege la información de los demás. Si un '
    'inversor entra con otro rol, va a ver cuánto puso cada uno, el margen del '
    'negocio y la tesorería completa.'))

a(Paragraph('El menú', H2))
a(tabla([
    ['Sección', 'Para qué'],
    ['<b>Dashboard</b>', 'La foto del negocio: capital, resultado, obras con problemas y necesidades de caja.'],
    ['<b>Día a día</b>', 'Cargar los gastos de obra, ver la caja y cambiar dólares. Es la pantalla de uso diario.'],
    ['<b>Proyectos</b>', 'Las casas. Adentro de cada una: resumen, presupuesto, gastos, ingresos, desvíos y cronograma.'],
    ['<b>Inversores</b>', 'Quién puso qué, cuánto le corresponde y su historial de movimientos.'],
    ['<b>Finanzas</b>', 'Cashflow, P&amp;L, movimientos de capital, caja y dólar.'],
    ['<b>Catálogo</b>', 'Qué se compra y a quién: técnicas, gastos del proyecto, honorarios y proveedores.'],
    ['<b>Cronogramas</b>', 'Avance físico de todas las obras y actividades atrasadas.'],
    ['<b>Reportes</b>', 'Exportables a Excel.'],
    ['<b>Configuración</b>', 'Usuarios y permisos.'],
], [32 * mm, 133 * mm]))
a(PageBreak())

# --- 3 -----------------------------------------------------------------------
a(Paragraph('Armar una obra', H1))
a(Paragraph('Cuatro pasos, una sola vez por casa.', SUB))

a(paso(1, 'Crear el proyecto', [
    'En <b>Proyectos</b>, botón <b>+ Nuevo proyecto</b>. Con el código y el '
    'nombre alcanza para empezar; el resto se completa después con <b>Editar</b>.',
    'Conviene cargar desde el principio la <b>venta estimada</b> y la '
    '<b>comisión inmobiliaria</b>: son lo que permite calcular el margen '
    'proyectado antes de gastar un peso.']))

a(paso(2, 'Cargar el cronograma', [
    'Entrá a la obra haciendo clic en su <b>código</b>, y andá a la pestaña '
    '<b>Cronograma</b>.',
    'Cada actividad se carga con su fecha de inicio y la cantidad de <b>días '
    'hábiles</b> que lleva. La fecha de fin la calcula el sistema salteando '
    'fines de semana y feriados argentinos.']))

a(paso(3, 'Planificar los materiales', [
    'Pestaña <b>Presupuesto</b>, botón <b>Planificar desde el catálogo</b>.',
    'Se abre el catálogo completo con buscador. Marcá lo que vas a necesitar y '
    'a cada cosa ponele <b>cantidad</b>, <b>fecha prevista</b> y a qué '
    '<b>actividad</b> pertenece. Se cargan todos de una vez.',
    'El precio sale del historial del item. Si un item nunca se compró ni se '
    'cotizó, entra en cero y hay que ponerlo a mano.']))

a(paso(4, 'Listo: ya hay plan', [
    'Con eso el <b>Resumen</b> muestra budget, forecast y margen, y el '
    '<b>Cashflow</b> proyecta cuándo va a hacer falta plata.',
    'De acá en adelante, cada gasto que se cargue se compara solo contra este '
    'plan.']))

a(Spacer(1, 6))
a(aviso(
    '<b>La fecha prevista es lo más importante del presupuesto.</b> Sin ella el '
    'sistema sabe cuánto va a costar la obra, pero no cuándo va a necesitar la '
    'plata. Con ella puede avisar que en marzo falta dinero, meses antes de que '
    'pase.'))
a(PageBreak())

# --- 4 -----------------------------------------------------------------------
a(Paragraph('El día a día', H1))
a(Paragraph('La pantalla que se usa todos los días en la obra.', SUB))
a(parrafos(
    'Está pensada para cargar veinte gastos seguidos, no para consultar. El '
    'formulario está siempre abierto y al guardar <b>conserva la fecha, el tipo, '
    'la categoría y el proveedor</b>: entre un gasto y el siguiente lo único que '
    'suele cambiar es qué se compró y cuánto salió.'))

a(Paragraph('Cargar un gasto', H2))
a(tabla([
    ['Campo', 'Qué poner'],
    ['Fecha', 'Cuándo se hizo el gasto. Determina qué cotización del dólar se aplica.'],
    ['Tipo', 'Técnica, gasto del proyecto u honorario. Filtra el catálogo.'],
    ['Item', 'Del catálogo. Al elegirlo completa el concepto, la categoría y trae el precio de referencia. Si no está, dejalo vacío y escribí a mano.'],
    ['Concepto', 'El detalle: &laquo;Hierro del 8 &middot; 20 barras&raquo;.'],
    ['Categoría', 'Se completa sola al elegir el item.'],
    ['Proveedor', 'Opcional, pero es lo que después permite comparar precios entre proveedores.'],
    ['Importe y moneda', 'Lo que se pagó. En pesos, la cotización se aplica sola.'],
], [30 * mm, 135 * mm]))

a(Spacer(1, 8))
a(aviso(
    '<b>El importe en amarillo es una sugerencia, no un dato.</b> Cuando elegís '
    'un item del catálogo, el sistema propone el último precio conocido y lo '
    'marca en amarillo. Apenas escribís el importe real la marca desaparece. Si '
    'queda amarillo al guardar, ese número no es lo que se gastó.'))

a(Paragraph('Cambiar dólares', H2))
a(parrafos(
    'El botón <b>Cambiar dólares</b> registra una operación de cambio: salen '
    'dólares de una caja y entran pesos en otra, con la cotización que '
    'efectivamente se pagó. Las dos cajas se mueven juntas, de modo que la '
    'tesorería nunca queda descuadrada.'))
a(parrafos(
    'Requiere tener creada al menos una cuenta en pesos y una en dólares, en '
    '<b>Finanzas &rsaquo; Caja y cambios</b>.'))
a(PageBreak())

# --- 5 -----------------------------------------------------------------------
a(Paragraph('El catálogo', H1))
a(Paragraph('Qué se compra, a qué precio y cómo evoluciona.', SUB))
a(parrafos(
    'El catálogo define <b>qué</b> es cada cosa: código, descripción, categoría '
    'y unidad. <b>El precio no se carga al crear el item</b>: se registra aparte, '
    'con su fecha, y así queda el historial.'))
a(Spacer(1, 4))
a(tabla([
    ['Sección', 'Qué agrupa'],
    ['<b>Técnicas</b>', 'Materiales y mano de obra de la construcción.'],
    ['<b>Gastos del proyecto</b>', 'Expensas, luz, gas, seguros: lo que se repite todos los meses.'],
    ['<b>Honorarios</b>', 'Escribanía, gestoría, arquitectura, comisiones.'],
    ['<b>Proveedores</b>', 'A quién se le compra.'],
], [42 * mm, 123 * mm]))

a(Paragraph('El precio vigente', H2))
a(parrafos(
    'Cada item muestra su <b>precio más nuevo</b> con la fecha en que se '
    'registró, de dónde salió y cuánto varió respecto del anterior. Los items se '
    'actualizan de a uno: el que no se tocó sigue mostrando su último valor '
    'conocido, y la fecha lo delata.'))
a(Spacer(1, 4))
a(tabla([
    ['Origen', 'Qué significa'],
    ['Referencia', 'Un precio cargado a mano: &laquo;el cemento hoy está a tanto&raquo;.'],
    ['Cotización', 'Lo que ofreció un proveedor.'],
    ['Compra', 'Lo que realmente se pagó. Es el que más vale.'],
], [30 * mm, 135 * mm]))
a(Spacer(1, 8))
a(parrafos(
    'El botón <b>Precio</b> de cada fila registra uno nuevo. No reemplaza a los '
    'anteriores: agrega un punto. Haciendo clic en la fila se despliega el '
    'historial completo, con la variación entre un precio y el siguiente.'))
a(Spacer(1, 4))
a(parrafos(
    'La <b>unidad</b> importa más de lo que parece. Si todos los items dicen '
    '&laquo;un&raquo;, no se pueden comparar precios entre proveedores ni '
    'calcular consumos. Conviene poner la real: m&sup2;, kg, bolsa, jornal.'))

a(Paragraph('El dólar', H2))
a(parrafos(
    'En <b>Finanzas &rsaquo; Dólar</b> está la cotización con la que se valúa todo. '
    'Se trae sola al abrir la aplicación, y también se puede cargar a mano '
    '—conviene cuando se hizo un cambio real a un valor distinto del de mercado.'))
a(Spacer(1, 4))
a(aviso(
    '<b>No hace falta cargarla todos los días.</b> Cada importe usa la cotización '
    'más reciente anterior o igual a su fecha, así que un hueco de varios días no '
    'rompe nada: arrastra la última disponible.'))
a(PageBreak())

# --- 6 -----------------------------------------------------------------------
a(Paragraph('Inversores y capital', H1))
a(Paragraph('Un solo libro donde entra y sale toda la plata.', SUB))
a(parrafos(
    'No hay una tabla de aportes, otra de retiros y otra de distribuciones: hay '
    '<b>un único registro de movimientos</b>, y el tipo de cada uno define su '
    'efecto. Por eso «cuánto tiene cada inversor» es una suma y no una '
    'conciliación entre planillas.'))
a(Spacer(1, 4))
a(tabla([
    ['Tipo de movimiento', 'Qué hace'],
    ['Aporte', 'El inversor pone plata en una obra.'],
    ['Retiro', 'Saca plata.'],
    ['Profit asignado', 'Se le reconoce una utilidad. No mueve dinero todavía.'],
    ['Profit distribuido', 'Se le paga esa utilidad. Sale de la caja.'],
    ['Reinversión', 'La utilidad pasa a otra obra sin salir del negocio.'],
    ['Transferencia', 'Capital que rota entre obras, sin inversor de por medio.'],
], [38 * mm, 127 * mm]))

a(Paragraph('Cómo se calcula la participación', H2))
a(parrafos(
    'La participación de cada inversor en una obra es <b>su capital sobre el '
    'capital total de esa obra</b>. La utilidad que le toca es esa participación '
    'aplicada a la utilidad del proyecto.'))
a(Spacer(1, 4))
a(tabla([
    ['Concepto', 'Cálculo'],
    ['Participación', 'capital del inversor &divide; capital total de la obra'],
    ['Utilidad que le toca', 'utilidad de la obra &times; participación'],
    ['ROI realizado', 'profit cobrado &divide; capital invertido'],
], [42 * mm, 123 * mm]))
a(Spacer(1, 8))
a(aviso(
    'El <b>profit proyectado</b> que aparece en la ficha de cada inversor es una '
    'estimación según cómo cierre la obra, no un derecho adquirido. El que ya se '
    'ganó es el <b>profit cobrado</b>.'))
a(PageBreak())

# --- 7 -----------------------------------------------------------------------
a(Paragraph('Qué preguntas responde', H1))
a(Paragraph('Y dónde se mira cada una.', SUB))
a(tabla([
    ['Pregunta', 'Dónde'],
    ['¿Cuánto dinero tiene cada inversor y dónde está invertido?', 'Inversores'],
    ['¿Cuánta plata necesita cada casa en los próximos meses?', 'Finanzas &rsaquo; Cashflow'],
    ['¿Cuál era el presupuesto original de esta casa?', 'Proyecto &rsaquo; Resumen'],
    ['¿Cuánto llevamos gastado y cuánto está comprometido?', 'Proyecto &rsaquo; Resumen'],
    ['¿Cuánto creemos que vamos a terminar gastando?', 'Proyecto &rsaquo; Resumen (forecast)'],
    ['¿Qué items están generando desvíos?', 'Proyecto &rsaquo; Desvíos'],
    ['¿Qué proveedor da mejores precios?', 'Catálogo &rsaquo; abrir un item'],
    ['¿Qué actividades están atrasadas y cuánto impactan?', 'Cronogramas'],
    ['¿Qué obras tienen problemas de costo o de plazo?', 'Dashboard'],
    ['¿Cuál es la posición consolidada del negocio?', 'Dashboard'],
], [110 * mm, 55 * mm]))

a(Paragraph('Cinco reglas', H2))
for t in [
    '<b>El importe amarillo no es un dato.</b> Es una sugerencia del catálogo. Si '
    'queda amarillo, ese gasto tiene un precio que nadie verificó.',
    '<b>Cargá la fecha prevista en el presupuesto.</b> Es lo que convierte una '
    'lista de materiales en una proyección de caja.',
    '<b>Vinculá el gasto a la línea de presupuesto.</b> Sin eso el gasto existe, '
    'pero no se puede medir contra lo planificado.',
    '<b>Poné la unidad real.</b> Si todo dice «un», el catálogo no sirve para '
    'comparar precios.',
    '<b>Anulá, no borres.</b> Un registro anulado conserva la historia; uno '
    'borrado deja un agujero que nadie va a poder explicar después.',
]:
    a(Paragraph(f'&bull;&nbsp;&nbsp;{t}', LI))

a(Spacer(1, 14))
a(aviso(
    '<b>Este sistema no adivina.</b> Los números que muestra son exactamente los '
    'que se cargaron. Si un gasto entra en la moneda equivocada o con una fecha '
    'errada, el margen va a estar mal y nada va a avisar. La calidad de la carga '
    'es la calidad del reporte.'))


# =============================================================================
# Documento
# =============================================================================
def decorar(canvas, doc):
    canvas.saveState()
    if doc.page > 1:
        canvas.setStrokeColor(BORDE)
        canvas.setLineWidth(0.5)
        canvas.line(22 * mm, 16 * mm, 188 * mm, 16 * mm)
        canvas.setFont('Helvetica', 7.5)
        canvas.setFillColor(GRIS)
        canvas.drawString(22 * mm, 11 * mm, 'Obras · Manual de uso')
        canvas.drawRightString(188 * mm, 11 * mm, str(doc.page))
    canvas.restoreState()


doc = BaseDocTemplate(SALIDA, pagesize=A4,
                      leftMargin=22 * mm, rightMargin=22 * mm,
                      topMargin=20 * mm, bottomMargin=22 * mm,
                      title='Obras — Manual de uso',
                      author='Obras',
                      subject='Manual de uso de la plataforma Obras')

frame = Frame(doc.leftMargin, doc.bottomMargin,
              doc.width, doc.height, id='cuerpo')
doc.addPageTemplates([PageTemplate(id='base', frames=[frame], onPage=decorar)])
doc.build(S)

print('PDF generado:', SALIDA)
