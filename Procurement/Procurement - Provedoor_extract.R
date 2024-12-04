# Paqueterias

# Activar paqueterias
library(readxl)
library(dplyr)
library(lubridate)


# Parametros
#archivos_procurement <- "A:/eduar/OneDrive - Axo/Documentos/2024/Mensual"
archivos_procurement <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Documentos/Procurement/2024" #AXO PC
#archivos_procurement <- choose.dir(caption = "Seleccionar carpeta de archivos de Procurement GUESS")

# ---- Parametros Busqueda
pestaña_wip <- "WIP"
columna_wip <-"NOMBRE1"
proveedor <- "ZHEJIANG XINGJI TECHNOLOGY"
#proveedoor <- readline(prompt = "Ingrese nombre de proovedor")

# Carpeta Archivos: Procurement

procurement_files <- data.frame(
  ruta_completa = list.files(path = archivos_procurement, pattern = ".xlsx", full.names = TRUE, recursive = TRUE),
  archivos = basename(list.files(path = archivos_procurement, pattern = ".xlsx", full.names = TRUE, recursive = TRUE)))

#Funcionales

filtro_proveedor <- function(archivo_wip,nombre_proveedor){
  WIP_file <- read_xlsx(path = archivo_wip, sheet = pestaña_wip, col_names = TRUE, na = "0", progress = TRUE)

  WIP <- WIP_file %>% filter(columna_wip == nombre_proveedor)
  if (nrow(WIP) == 0){
    print(paste0("No hay registro de ",proovedoor," en la columna ", columna_wip))
    return(NULL)
  } else {
    WIP <- group_by(WIP, nombre_proveedor) %>% summarise(
    Conteo_P.O. = length(unique(REFERENCIA)),
    Valor_Orden = sum(VALOR_NETO_PEDIDO),
    Piezas_Pendientes = sum(CANTIDAD_PENDIENTE),
    Piezas_Entregadas = sum(CANTIDAD_ENTREGADA),
    Piezas_Pedido = sum(CANTIDAD_PEDIDO),
    Entrega_Fabrica = unique(FE_ENTREGA_SAL_FABR),
    Real_Fabrica = unique(FE_ACTUAL_REGISTRO),
    Inicio_Carga = unique(INICIO_ACTUAL_CARGA),
    Real_Carga = unique(FIN_ACTUAL_CARGA),
    Fin_Transporte = unique(FIN_ACT_TRANSPORTE),
    Contabilización = unique(FE_CONTABILIZACION),
    INDCFORMULA = unique(INDCFORMULA)
  ) %>%  mutate(Fuente = gsub(".*?(\\d{2}\\.\\d{2}\\.\\d{4}).*", "\\1",basename(archivo_wip)))
  
  return(WIP)
}}

# Pre-loop
tabla_po_orden <- data.frame(
  Conteo_P.O. = numeric(),
  Valor_Orden = numeric(),
  Piezas_Pendientes = numeric(),
  Piezas_Entregadas = numeric(),
  Piezas_Pedido = numeric(),
  Entrega_Fabrica = as.Date(character()),
  Real_Fabrica = as.Date(character()),
  Inicio_Carga = as.Date(character()),
  Real_Carga = as.Date(character()),
  Fin_Transporte = as.Date(character()),
  Contabilización = as.Date(character()),
  INDCFORMULA = as.Date(character()),
  Fuente = as.Date(character())
)

# Recursividad por cada archivo

for (i in 1:nrow(procurement_files)) {
  extraccion <- filtro_po(procurement_files$ruta_completa[i], po_order)
  tabla_po_orden <- rbind(tabla_po_orden, extraccion)
  print(paste0("Procesado archivo: ",procurement_files$archivos[i]," [",i,"/",nrow(procurement_files),"]"))
}

# Filtrar columna de no de orden (PO ORDEN)


# Sample WIP Referencia






#Obtener valores únicos de fecha de -Salida fabrica, -Actual registro, -Inicio Carga, - Actual Carga, -Fin transporte, -Fe contabilización, -INDFORMULA
#Agrupar valores de Cantidades (Pendientes, entregadas y pedido)
#Agregar Columna con valor fecha de origen del documento WIP

WIP1 <- filter(WIP, NOMBRE1 == proveedor) %>% summarise(
  Conteo_Referencia = length(unique(REFERENCIA)),
  Valor_Orden = sum(VALOR_NETO_PEDIDO),
  Piezas_Pendientes = sum(CANTIDAD_PENDIENTE),
  Piezas_Entregadas = sum(CANTIDAD_ENTREGADA),
  Piezas_Pedido = sum(CANTIDAD_PEDIDO),
  Entrega_Fabrica = unique(FE_ENTREGA_SAL_FABR),
  Real_Fabrica = unique(FE_ACTUAL_REGISTRO),
  Inicio_Carga = unique(INICIO_ACTUAL_CARGA),
  Real_Carga = unique(FIN_ACTUAL_CARGA),
  Fin_Transporte = unique(FIN_ACT_TRANSPORTE),
  Contabilización = unique(FE_CONTABILIZACION),
  INDCFORMULA = unique(INDCFORMULA)
)

