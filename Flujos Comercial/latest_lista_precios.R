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

lista.precios <- read_xlsx(path = latest_files_lista.precios[1,1]) %>%
  select(c("Código de estilo",
           "Descripción breve de estilo",
           "Código de Temporada",
           "Descripción de Temporada",
           "Año",
           "Etiqueta de grupo de jerarquía[Department]",
           "Etiqueta de grupo de jerarquía[Class]",
           "Etiqueta de grupo de jerarquía[Sub-Class]",
           "Precio IB minorista")) %>% 
  rename("Material" = "Código de estilo") %>% 
  rename("Temporada" = "Código de Temporada") %>% 
  rename("Departamento" = "Etiqueta de grupo de jerarquía[Department]") %>% 
  rename("Clase" = "Etiqueta de grupo de jerarquía[Class]") %>% 
  rename("Sub-Clase" = "Etiqueta de grupo de jerarquía[Sub-Class]")

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Lista.Precios", lista.precios, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)
