#Lista de Precios

#Lastest and clean

# Librerias ----
library(readxl)
library(tidyverse)
library(DBI)
library(RSQLite)

# Parametros ----
dir_lista.precios <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Lista de Precios"
extension_lista.precios <- ".xlsx"

files_lista.precios <- list.files(path = dir_lista.precios,
                                    pattern = extension_lista.precios, 
                                    full.names = TRUE)

# Latest ----

latest_files_lista.precios <- data.frame(files = files_lista.precios, file_modification = file.mtime(files_lista.precios)) %>% 
  arrange(desc(file_modification)) %>% slice(1)

lista.precios <- read_xlsx(path = latest_files_lista.precios[1,1])

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Lista.Precios", lista.precios, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)
