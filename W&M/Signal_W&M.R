# Librerías ----

library(tidyverse)
library(janitor)
library(data.table)
library(readxl)
library(utils)
library(DBI)
library(RSQLite)
library(here)

# Parametros globales ----
source(here("Global.R"))

# Parametros: Archivos W&M, Master files & temp files

carpeta_wm <- global_config$directorio_archivos_WM
archivos_wm <- list.files(path = carpeta_wm, pattern = ".xlsx", full.names = TRUE)

# Construcción tabla: información relevante ----

peso.materiales <- data.table(style_code = as.character(),
                              style_group_name = as.character(),
                              class_name = as.character(),
                              country_origin = as.character(),
                              body = as.character(),
                              trim = as.character(),
                              lining = as.character(),
                              wt_kg = as.double(),
                              net_wt_kg = as.double(),
                              dimensiones.largo = as.character(),
                              dimensiones.ancho = as.character(),
                              dimensiones.alto = as.character(),
                              fuente = as.character())

# Leer archivos, seleccionar y concatenar ----

for (files in archivos_wm) {
  wm <- read_xlsx(files) %>% as.data.table() %>% clean_names() %>% select(
    c("style",
      contains("group_name"),
      contains("merch_class_name"),
      contains("country"),
      contains("body")[1],
      contains("trim")[1],
      contains("lining")[1],
      starts_with("wt_kg")[1],
      starts_with("net_wt_kg")[1],
      contains("Dimensiones_") | contains("Dimensions_")
    ))
  # Generar tipos adecuados para con concatenación
  
  wm$wt_kg_incl_pkg <- as.double(wm$wt_kg_incl_pkg)
  wm$net_wt_kg_excl_pkg <- as.double(wm$net_wt_kg_excl_pkg)
  
  #Fuente/origen de información
  wm$fuente <- substr(basename(files),1,3)
  
  # Concatenar información
  peso.materiales <- rbind(peso.materiales, wm, use.names=FALSE)

  message(paste0("Archivo concatenado : ", basename(files)))
}

# Limpieza de columnas Dimensiones: 
    #tipos incorrectos

# Leer W&M: style_code: llenado manual y concatenar ----

#Circular references
#wm_file <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/W&M.xlsx"
#
#wm_info.faltante <- read_xlsx(wm_file, sheet = "styles_no_info")
#

# Exportar CSV para archivo W&M ----

archivo.wm.resumido <- here("Output/CSV","W&M_limpio.csv")

write.csv(peso.materiales, file = archivo.wm.resumido, row.names = FALSE, na = "")

# Leer: Lista de precios ----
lista.precios <- dbConnect(SQLite(), here("db","guess_hb.sqlite")) %>% dbReadTable("Lista.Precios.Full")
#dbDisconnect()

# Filtrar HB
materiales.HB <- filter(lista.precios, Departamento %in% global_config$departamento_bolsas) %>% 
  mutate(style_code = str_sub(Material, start = 1, end = str_locate(Material, "-")[1]-1)) %>% 
  select(c("Material",
           "style_code",
           "Descripción.breve.de.estilo",
           "Departamento",
           "Año",
           "Temporada",
           "Clase",
           "Sub.Clase"
           )) %>% mutate(prefix = str_extract(style_code, "^[A-Za-z]+")) %>% 
  mutate(silh.number = str_sub(style_code, start = str_length(style_code)-1, end = str_length(style_code))) %>% 
  mutate(group.number = str_remove(style_code, prefix)) %>% 
  mutate(group.number = str_sub(group.number, start = 1, end = -3))

# Join Precios y W&M
wm.hb <- left_join(materiales.HB, peso.materiales, by = "style_code", keep = NULL, multiple = "last", relationship = "many-to-one") %>% 
  as.data.table()

# Change Column types, NA introducidos por coercion 
wm.hb[,dimensiones.largo := as.numeric(dimensiones.largo)]
wm.hb[,dimensiones.ancho := as.numeric(dimensiones.ancho)]
wm.hb[,dimensiones.alto := as.numeric(dimensiones.alto)]

  # filtrar estilos sin información para 2025 (mejorar información para temporadas en curso)
    # exportar csv para leer en W&M

# Checar información de temporada en proceso, a travez del año en proceso
año.curso <- year(Sys.Date())

# Exportar información
csv.styles.no.info <- here("Output/CSV","styles_no_info.csv")

# Obtener tabla de codigo de estilo con información faltante
season <- materiales.HB %>% filter(Año == año.curso) %>%
  rename(Descripcion = "Descripción.breve.de.estilo") %>% 
  unique(by = "style_code") %>% 
  left_join(peso.materiales, by = "style_code", keep = NULL, multiple = "last", relationship = "many-to-one") %>% 
  filter(is.na(fuente)) %>% 
  select(c("style_code",
           "Temporada",
           "Descripcion",
           "Departamento")) %>% 
  write.csv(file = csv.styles.no.info, row.names = FALSE)

# Exportar a csv para W&M --- # To do ---
  # 2 tablas, 
    # uno con columanas valores categórico #solo analisis interno
    # uno con columnas valores numéricos
      # Desglosado por material
      # Desglosado por style
