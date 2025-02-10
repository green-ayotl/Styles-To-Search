## Styles To Search
- Proyecto para mejorar los procesos de información en el área comercial de AXO GUESS.
## Flujos de trabajo para el área comercial
### Inventario de Materiales
- Identificación de Materiales en distintas fuentes de información multimedia, para cubrir en menor tiempo posible la alimentación multimedia de los clientes WholeSale.
- Desde distintas fuentes.
	- ShareFile: Signalbrands
		- Identificación de materiales a partir del nombre de archivo
			- \[Style]-\[Color Proveedor (ingles)]-\[Grupo estilo]-\[Clave de ángulo de foto]-\[Opcional: Consecutivo numérico, variante]-.\[extensión de archivo]
		- Unión entre Color Proveedor con Código de color correspondientes, concatenado con el estilo para obtener el código de material.
	- nCommerce: Plataforma de información multimedia, Guess USA.
	- Ecommerce Guess: Flujos de trabajo del departamento de ecom.
	- Ecom en línea: Búsqueda de materiales manual en la red.
### Formato para Proforma
- A partir de distintas fuentes de información, obtener un documento curado para alimentar distintos formatos en el área comercial Wholesale.
	- Proformas
	- Altas
	- Informes
	- Reportes de ventas
	- Materiales sin imagen para buscar en fuentes de información alternativas (internas o externas)
- El informe creado es un filtro anual e incluye fecha de reporte. Para estar al tanto de cada actualización.

### Clientes Wholesale
- A partir de la lista de materiales de compra para algún cliente Wholesale, se busca en el **Inventario de Materiales** y se transforma los activos multimedia de acuerdo a la especificaciones técnicas del cliente, reemplazando el flujo de trabajo tradicional con una agencia externa de 2 semanas a 15 minutos.
- Cada cliente wholesale distintas especificaciones de formato de imagen, renombre y forma de alta multimedia. Por lo que cada cliente tiene su propio script con sus transformaciones necesarias.
- Clientes atendidos
	- Amazon
	- Bodesa
	- Chapur
	- Cimaco
	- Coppel
	- Ecom Guess (busqueda de materiales para su flujos de trabajo)
	- Liverpool
		- Liverpool creación de ISOmetrica
	- MercadoLibre
	- Palacio de Hierro
	- Sanborns
	- Sears

## Procurement
### Herramientas de análisis de documentos WIP
- Extracción de PO_ORDER de todos los documentos WIP, concatenando la fecha del documento para verificar la variabilidad del INDCFORMULA a través del tiempo.
- Misma herramienta con numero de transporte.
- Misma herramienta a partir de nombre de proveedor.
## Tools
- Herramientas variadas e independientes para realizar distintas tareas.
### Macro: Miniaturas en Celda
- Herramienta para importar imágenes en celda de Excel
- Permite tener una guía visual de modelo/material/producto con el que se trabaja
- La referencia que permite unir la imagen con sus filas correspondiente , es que el nombre del archivo a exportar a Excel es el mismo que su identificador.
- Requisitos
	- Activar contenido para utilizar macro en el documento de Excel
	- Preferible tener la imágenes en baja calidad para importar a Excel, ya que al momento de importar, se copian al archivo de Excel, aumentando el peso archivo de acuerdo a las imágenes importadas.
		- Imágenes de alrededor de 100pp (pixeles)
		- Excel no tiene herramientas para comprimir las imágenes importadas de manera eficiente o siempre correcta.
#### Tutorial
- En la tabla \[Dirección] pegar la ruta completa donde se encuentre las imágenes. Se listaran todas las imágenes incluso si se encuentran dentro de otras carpetas.
![[Tutorial - Miniatura Celda (1).png]]
- Colocar en la segunda tabla el filtro de archivos (archivos de imagen) para importar a la celda. Puedes agregar más extensión de archivos escribiendo debajo (la tabla aumentara de tamaño automáticamente) y eliminando extensiones seleccionando las celdas que se quieran borrar y usando **Ctrl** *+* **-** (guion ó menos)
- Ve a la pestaña: "Lista_Archivos"
	- ![[Segunda Pestaña.png]]
	- Click derecho en cualquier parte de la tabla y dale a la opción actualizar
		- ![[Actualizar tabla.png]]
	- Los archivos en tal formato y en tal carpeta dada se mostraran en la tabla, incluyendo los archivos en subcarpetas.
- Utiliza la función BUSCARX en tu nuevo documento con la lista de archivos.
	- Sintaxis: **=BUSCARX(valor_buscado; matriz_buscada; matriz_devuelta; [si_no_se_encuentra]; [modo_de_coincidencia]; [modo_de_búsqueda])**
	- Valor buscado: Código, llave o identificador de tu documento con el nombre de archivo.
	- Matriz_buscada: Columna A del archivo o columna: ***Nombre Archivo*** de la tabla
	- Matriz_devuelta: Columna B del archivo o columna: ***Ubicación Archivo*** de la tabla
	- \[si_no_se_encuentra]: colocar el parametro **"-"** 
	- Otros parámetros son opcionales
- Seleccionar solo los archivos encontrados con **Alt** *+* **','** (coma)
- Activar macro desde la pestaña de **programador** en excel
	- ![[Pestaña_programador.png]]
	- ![[Boton Macros.png]]
	- ![[Activar Macro.png]]
- Se exportara la imagen a la celda en tu documento. La imagen es la información de la celda, lo puedes referenciar u copiar en otros documentos.
### Extra
- Scripts variados para otros temas o departamentos
#### HB Portal - Fronts
- Identificación de materiales por año y copia de cara frontal para una carpeta compartida.

## db: SQLite 
- Lista de Archivos: **"db/guess_hb_materiales.sqlite"**
	- Colección Signal
		- Mainline
		- Special Market
		- Men HB
	- Álbum Alternativo
		- nCommerce
		- Guess Ecom
		- Web scrapping 
- Lista de Materiales desde lista de archivos
	- (Transformación desde Lista de Archivos)
	- Dimensiones mínimas
		- Material
		- Código Estilo
		- Código Color
		- Variante
		- Full Path
		- Nombre Colección (solo para Colección Signal)
- Fuentes de información
	- Lista de Materiales \[Lastest]
	- Base de materiales \[Lastest]
	- Base estética \[Próximamente]
	- Weight & Materials \[Limpieza y concatenado a partir de Signal]
- Formato Proformas por año
	- Lista de Materiales por año con UPC y descriptores.
- ***Se duplica en archivos csv para importación más rápida a Excel.***
