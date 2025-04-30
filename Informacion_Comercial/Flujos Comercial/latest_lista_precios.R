#Lista de Precios

#Lastest and clean price's list

# Librerias ----
library(readxl)
library(tidyverse)
library(DBI)
library(RSQLite)
library(here)

# Parámetros Globales ----
source(here("Global.R"))

dir_lista.precios <- global_config$directorio_lista_precios

departamento_bolsas <- global_config$departamento_bolsas

extension_lista.precios <- ".xlsx"

# File List ----

files_lista.precios <- list.files(path = dir_lista.precios,
                                    pattern = extension_lista.precios, 
                                    full.names = TRUE)

# Latest ----

latest_files_lista.precios <- data.frame(files = files_lista.precios, file_modification = file.mtime(files_lista.precios)) %>% 
  arrange(desc(file_modification)) %>% slice(1)

# Cargar archivo Excel - Query & Format ----

# Solo Materiales Bolsas
lista.precios.HB <- read_xlsx(path = latest_files_lista.precios[1,1]) %>%
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
  rename("Sub-Clase" = "Etiqueta de grupo de jerarquía[Sub-Class]") %>% 
  filter(Departamento %in% departamento_bolsas) #Lista de precios, solo departamento de Bolsas

# Lista completa de materiales
lista.precios.full <- read_xlsx(path = latest_files_lista.precios[1,1]) %>%
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

# Carga información UPC ----

Informacion_HB_guess <- dbConnect(SQLite(), here("db","guess_hb.sqlite")) # Fuentes información Guess
Materiales.UPC <- dbReadTable(Informacion_HB_guess, "Materiales.UPC") %>% distinct() %>% rename(Material = numero_material) #distinct para quitar repetidos desde Latest:Base.Materiales y UPC_Extras
dbDisconnect(Informacion_HB_guess)

#Unir información UPC ----

lista.precios.upc <- left_join(lista.precios.HB, Materiales.UPC, by = "Material", keep = FALSE, relationship = "one-to-one")

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), here("db","guess_hb.sqlite"))
dbWriteTable(SQLite.Guess_HB, "Lista.Precios.UPC", lista.precios.upc, overwrite = TRUE) # Material <-> UPC
dbWriteTable(SQLite.Guess_HB, "Lista.Precios.Full", lista.precios.full, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Lista.Precios.HB", lista.precios.HB, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)

write.csv(lista.precios.upc, file = here("Output","CSV","Lista_Precios.csv"), row.names = FALSE, na = "")
