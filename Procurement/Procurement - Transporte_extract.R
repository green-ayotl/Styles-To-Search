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
#archivos_procurement <- "A:/eduar/OneDrive - Axo/Documentos/Procurement/2024"
archivos_procurement <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Documentos/Procurement/2024"
#archivos_procurement <- choose.dir(caption = "Seleccionar carpeta de archivos de Procurement GUESS")

#po_order <- unique(WIP$REFERENCIA)[sample(length(unique(WIP$REFERENCIA)),1)]
#transporte <- readline(prompt = "Ingresa numero de transporte: ")
transporte <- "4048290"


# Nombre pestaña en archivos Procurement
pestaña_wip <- "WIP"

# Carpeta Archivos: Procurement

procurement_files <- data.frame(
  ruta_completa = list.files(path = archivos_procurement, pattern = ".xlsx", full.names = TRUE, recursive = TRUE),
  archivos = basename(list.files(path = archivos_procurement, pattern = ".xlsx", full.names = TRUE, recursive = TRUE)))

#Funcionales

filtro_transporte <- function(archivo_wip,registro){
  WIP_file <- read_xlsx(path = archivo_wip, sheet = pestaña_wip, col_names = TRUE, na = "0", progress = TRUE)
  
  WIP <- WIP_file %>% filter(NO_DE_TRANSPORTE == registro) # Filtrar columna por numero de transporte
  if (nrow(WIP) == 0){
    print(paste0("No hay registro del transporte: ",registro))
    return(NULL)
  } else {
    WIP <- group_by(WIP, NO_DE_TRANSPORTE) %>% summarise(
    Denominacion_Conteo = n_distinct(DENOMINACION_GRPCOMP), #Conteo Agrupar denominaciones
    PO_Conteo = n_distinct(REFERENCIA),
    Materiales_Conteo = n_distinct(MATERIAL),
    Tallas_Conteo = n_distinct(VALOR_MATRIZ),
    Pais = n_distinct(PAIS),
    Moneda = n_distinct(MONEDA),
    Valor_Orden = sum(VALOR_NETO_PEDIDO), #Agrupar valores de Cantidades (Pendientes, entregadas y pedido)
    Piezas_Pendientes = sum(CANTIDAD_PENDIENTE),
    Piezas_Entregadas = sum(CANTIDAD_ENTREGADA),
    Piezas_Pedido = sum(CANTIDAD_PEDIDO),
#    Entrega_Fabrica = unique(FE_ENTREGA_SAL_FABR), #Obtener valores únicos de fecha de -Salida fabrica, -Actual registro, -Inicio Carga, - Actual Carga, -Fin transporte, -Fe contabilización, -INDFORMULA
    Real_Fabrica = unique(FE_ACTUAL_REGISTRO),
    Inicio_Carga = unique(INICIO_ACTUAL_CARGA),
    Real_Carga = unique(FIN_ACTUAL_CARGA),
    Fin_Transporte = unique(FIN_ACT_TRANSPORTE),
    Contabilización = unique(FE_CONTABILIZACION),
    INDCFORMULA = unique(INDCFORMULA),
    OTA = unique(OTA),
    Estatus_Comercial = unique(STATUSCOMERCIAL),
    Tipo_Transporte = unique(SHIPMODE)
  ) %>%  mutate(Fuente = dmy(gsub(".*?(\\d{2})\\.(\\d{2})\\.(\\d{4})\\..*", "\\1/\\2/\\3",basename(archivo_wip)))) #Agregar Columna con valor fecha de origen del documento WIP
  
  return(WIP)
}}


# Pre-loop
tabla_transporte <- data.frame(
  Conteo_denominacion = numeric(),
  Ordenes_PO = numeric(),
  Materiales_Conteo = numeric(),
  Tallas = numeric(),
  Pais = character(),
  Moneda = character(),
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
  OTA = character(),
  Estatus_Comercial = character(),
  Tipo_Transporte = character(),
  Fuente = dmy()
)

# Recursividad por cada archivo

for (i in 1:nrow(procurement_files)) {
  extraccion <- filtro_transporte(procurement_files$ruta_completa[i], transporte)
  tabla_transporte <- rbind(tabla_transporte, extraccion)
  print(paste0("Procesado archivo: ",procurement_files$archivos[i]," [",i,"/",nrow(procurement_files),"]"))
}

#Ordenar por fecha de primero a ultima por columna de archivo fuente
arrange(tabla_transporte,desc(Fuente))

print(paste0("Se encontro el numero de transporte en ",nrow(tabla_transporte)," archivos WIP de un total de ",nrow(procurement_files)," archivos"))

nuevo_archivo <- paste0(dirname(archivos_procurement),"/","Numero de Transporte ",transporte,".xlsx")

writexl::write_xlsx(tabla_transporte, path = nuevo_archivo, col_names = TRUE, format_headers = TRUE)

shell.exec(nuevo_archivo)

#ggplot2
#Eje x: Fuente
#Eje y: Rango de fechas entre entrega minimo de entrega de fabrica y  maximo de INDCFORMULA
#Lineas por cada columna de "Entrega_Fabrica" "Real_Fabrica"      "Inicio_Carga"      "Real_Carga"        "Fin_Transporte"    "Contabilización"   "INDCFORMULA" 
