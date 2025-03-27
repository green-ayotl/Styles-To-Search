#Base de materiales

#Lastest and clean

# Librerias ----
library(readxl)
library(tidyverse)
library(DBI)
library(RSQLite)

# Parámetros ----
dir_base.materiales <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Base de Materiales"
extension_base.materiales <- ".xlsx"

files_base.materiales <- list.files(path = dir_base.materiales,
                                    pattern = extension_base.materiales, 
                                    full.names = TRUE)

# Names para Base de Materiales
encabezados_materiales <- c("DESCRIPCION",
                            "ESTILO",
                            "NUMERO_MATERIAL",
                            "MATERIAL-TALLA",
                            "CODIGO",
                            "DESCRIPCION_PRODUCTO_ORIGEN",
                            "DESCRIPCION_PRODUCTO_AXO",
                            "DESCRIPCION_PRODUCTO_TICKET",
                            "CODIGO_COLOR_PROVEEDOR",
                            "DESCRIPCION_COLOR_PROVEEDOR",
                            "CODIGO_COLOR_NRF",
                            "FAMILIA_COLOR",
                            "CODIGO_GRUPO_TALLA",
                            "TALLA",
                            "VENTA_PUBLICO_GENERAL",
                            "JERARQUIA",
                            "TEMPORADA",
                            "TEMPORADA_ANIO",
                            "TEMA",
                            "COMPOSICION",
                            "CODIGO_IMPORTACION",
                            "GENERO",
                            "SKU_LIVERPOOL",
                            "SKU_PALACIO",
                            "SKU_SEARS",
                            "TIPO_MATERIAL",
                            "UNIDAD_MEDIDA_BASE",
                            "SECTOR_MATERIALES",
                            "CENTRO",
                            "ALMACEN",
                            "GRUPO_COMPRAS",
                            "ORG_VENTAS",
                            "CENTRO_BENEFICIO",
                            "GRP_IMP_MATERIAL",
                            "NUM_ALMACEN",
                            "JERARQUIA_AXO",
                            "IND_TIPO_ALMA_ENTRADA",
                            "IND_AREA_ALMA",
                            "CENTRO_SUMINISTRADOR",
                            "SKU_VENDOR",
                            "MERCH_PLAN_ID",
                            "CLAVE_PROD_SERV",
                            "CAT_VALORACION",
                            "CANTIDAD_PAQUETE",    
                            "FECHA_CARGA",
                            "COMPLIANT")

# Latest ----

latest_files_base.materiales <- data.frame(files = files_base.materiales, file_modification = file.mtime(files_base.materiales)) %>% 
  arrange(desc(file_modification)) %>% slice(1)

# Simple Clean
base.materiales.raw <- read_xlsx(path = latest_files_base.materiales[1,1])
colnames(base.materiales.raw) <- encabezados_materiales

base.materiales.completa <- slice(base.materiales.raw, -c(1:3)) %>% # Eliminar primeras filas, informacion de db
  select(-c(1))# Eliminar primeras columnas, información constante, obtenida de otras columnas y repetida

base.materiales.minima <- base.materiales.completa %>% select(c(1:5))

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Base.Materiales", base.materiales.minima, overwrite = TRUE) 

dbDisconnect(SQLite.Guess_HB)
