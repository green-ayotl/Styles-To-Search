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

# Latest ----

latest_files_base.materiales <- data.frame(files = files_base.materiales, file_modification = file.mtime(files_base.materiales)) %>% 
  arrange(desc(file_modification)) %>% slice(1)

# Simple Clean
base.materiales <- read_xlsx(path = latest_files_base.materiales[1,1]) %>% 
  slice(-c(1:3)) %>% select(-c(1:4)) # Eliminar primeras columnas, información constante, obtenida de otras columnas y repetida

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Base.Materiales", base.materiales, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)
