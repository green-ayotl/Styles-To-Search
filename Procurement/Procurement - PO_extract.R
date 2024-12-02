# ----Limpieza previa en la carpeta de documentos WIP
# Nombre normalizado del nombre de la pestaña donde se encuentra la información
  # Se establece en la variable: pestaña_wip
  # Toda la información debe estar en la misma pestaña y no fraccionada
  # Las columnas extra no causan error, las columnas que se calculan son, - no cambiar nombre - :
    # REFERENCIA: Filtra el "PO ORDER"
    # VALOR Y NUMERO DE PIEZAS: VALOR_NETO_PEDIDO, CANTIDAD_PENDIENTE, CANTIDAD_ENTREGADA, CANTIDAD_PEDIDO,
    # FECHAS: FE_ENTREGA_SAL_FABR, FE_ACTUAL_REGISTRO, INICIO_ACTUAL_CARGA, FIN_ACTUAL_CARGA, FIN_ACT_TRANSPORTE, FE_CONTABILIZACION, INDCFORMULA
# Nombre de archivo, debe ser el formato: "WIP GUESS {2 digitos, dia}.{2 digitos, mes}.{4 digitos, año}.xlsx", ejemplo: WIP GUESS 02.01.2024.xlsx

# Paqueterias

# Activar paqueterias
library(readxl)
library(dplyr)
library(lubridate)


# Parametros
archivos_procurement <- "A:/eduar/OneDrive - Axo/Documentos/2024/Mensual"
#archivos_procurement <- choose.dir(caption = "Seleccionar carpeta de archivos de Procurement GUESS")
#archivo_WIP <- "A:/eduar/OneDrive - Axo/Documentos/2024/11.Noviembre/WIP GUESS 25.11.2024.xlsx"

#po_order <- unique(WIP$REFERENCIA)[sample(length(unique(WIP$REFERENCIA)),1)]
po_order <- "2202300875A"

pestaña_wip <- "WIP"

# Carpeta Archivos: Procurement

procurement_files <- data.frame(
  ruta_completa = list.files(path = archivos_procurement, pattern = ".xlsx", full.names = TRUE, recursive = TRUE),
  archivos = basename(list.files(path = archivos_procurement, pattern = ".xlsx", full.names = TRUE, recursive = TRUE)))

#Funcionales

filtro_po <- function(archivo_wip,numero_po){
  WIP_file <- read_xlsx(path = archivo_wip, sheet = pestaña_wip, col_names = TRUE, na = "0", progress = TRUE)
  
  WIP <- WIP_file %>% filter(REFERENCIA == numero_po) # Filtrar columna de no de orden (PO ORDEN)
  if (nrow(WIP) == 0){
    print(paste0("No hay registro de la orden: ",numero_po))
    return(NULL)
  } else {
    WIP <- group_by(WIP, REFERENCIA) %>% summarise(
    Valor_Orden = sum(VALOR_NETO_PEDIDO), #Agrupar valores de Cantidades (Pendientes, entregadas y pedido)
    Piezas_Pendientes = sum(CANTIDAD_PENDIENTE),
    Piezas_Entregadas = sum(CANTIDAD_ENTREGADA),
    Piezas_Pedido = sum(CANTIDAD_PEDIDO),
    Entrega_Fabrica = unique(FE_ENTREGA_SAL_FABR), #Obtener valores únicos de fecha de -Salida fabrica, -Actual registro, -Inicio Carga, - Actual Carga, -Fin transporte, -Fe contabilización, -INDFORMULA
    Real_Fabrica = unique(FE_ACTUAL_REGISTRO),
    Inicio_Carga = unique(INICIO_ACTUAL_CARGA),
    Real_Carga = unique(FIN_ACTUAL_CARGA),
    Fin_Transporte = unique(FIN_ACT_TRANSPORTE),
    Contabilización = unique(FE_CONTABILIZACION),
    INDCFORMULA = unique(INDCFORMULA)
  ) %>%  mutate(Fuente = dmy(gsub(".*?(\\d{2})\\.(\\d{2})\\.(\\d{4})\\..*", "\\1/\\2/\\3",basename(archivo_wip)))) #Agregar Columna con valor fecha de origen del documento WIP
  
  return(WIP)
}}


# Pre-loop
tabla_po_orden <- data.frame(
  REFERENCIA = character(),
  Valor_Orden = numeric(),
  Piezas_Pendientes = numeric(),
  Piezas_Entregadas = numeric(),
  Piezas_Pedido = numeric(),
  Entrega_Fabrica = dmy(),
  Real_Fabrica = dmy(),
  Inicio_Carga = dmy(),
  Real_Carga = dmy(),
  Fin_Transporte = dmy(),
  Contabilización = dmy(),
  INDCFORMULA = dmy(),
  Fuente = dmy()
)

# Recursividad por cada archivo

for (i in 1:nrow(procurement_files)) {
  extraccion <- filtro_po(procurement_files$ruta_completa[i], po_order)
  tabla_po_orden <- rbind(tabla_po_orden, extraccion)
  print(paste0("Procesado archivo: ",procurement_files$archivos[i]," [",i,"/",nrow(procurement_files),"]"))
}

#Ordenar por fecha de primero a ultima por columna de archivo fuente
arrange(tabla_po_orden,desc(Fuente))

print(paste0("Se encontro el numero PO Orden en ",nrow(tabla_po_orden)," archivos WIP de un total de ",nrow(procurement_files)," archivos"))

nuevo_archivo <- paste0("A:/eduar/OneDrive - Axo/Documentos/Procurement/2024/",po_order,".xlsx")

writexl::write_xlsx(tabla_po_orden, path = nuevo_archivo, col_names = TRUE, format_headers = TRUE)

shell.exec(nuevo_archivo)

#ggplot2
#Eje x: Fuente
#Eje y: INDCFORMULA
#Lineas Fechas aprox y real de transportes
