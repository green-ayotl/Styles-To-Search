#Base de materiales

#Lastest and clean

# Librerias ----
library(readxl)
library(tidyverse)
library(DBI)
library(RSQLite)
library(here)
library(janitor)

# Parámetros ----
source(here("Global.R"))

dir_base.materiales <- global_config$directorio_lista_materiales

extension_base.materiales <- ".xlsx"

files_base.materiales <- list.files(path = dir_base.materiales,
                                    pattern = extension_base.materiales, 
                                    full.names = TRUE)

# Names para Base de Materiales
encabezados_faltantes <- c("ESTILO",
                            "material_talla",
                            "codigo_upc")
# Latest ----

latest_files_base.materiales <- data.frame(files = files_base.materiales, file_modification = file.mtime(files_base.materiales)) %>% 
  arrange(desc(file_modification)) %>% slice(1)

# Simple Clean
base.materiales.completa <- read_xlsx(path = latest_files_base.materiales[1,1]) %>% clean_names()
names(base.materiales.completa)[2:4] <- encabezados_faltantes

base.materiales.completa <- base.materiales.completa %>%
  slice(-c(1:3)) %>% # Eliminar primeras filas, informacion de db
  select(-c(1:2))# Eliminar primeras columnas, información constante, obtenida de otras columnas y repetidas

base.materiales.minima <- base.materiales.completa %>% select(c(1:5))

# Material <-> UPC
Materiales.UPC <- base.materiales.minima %>% select(c(2,4))

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), here("db","guess_hb.sqlite"))
dbWriteTable(SQLite.Guess_HB, "Base.Materiales", base.materiales.minima, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Materiales.UPC", Materiales.UPC, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)
