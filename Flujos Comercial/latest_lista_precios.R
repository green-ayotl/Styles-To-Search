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

# Cargar archivo Excel ----

lista.precios.archivo <- 

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
  filter(Departamento %in% c("Handbags", "Handbags Factory")) #Lista de precios, solo departamento de Bolsas

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

Informacion_HB_guess <- dbConnect(SQLite(), "db/guess_hb.sqlite") # Fuentes informacion Guess
Materiales.UPC <- dbReadTable(Informacion_HB_guess, "Materiales.UPC") %>% distinct() #distinct para quitar repetidos desde Latest:Base.Maeriales y UPC_Extras
dbDisconnect(Informacion_HB_guess)

#Unir información UPC ----

lista.precios.upc <- left_join(lista.precios, Materiales.UPC, by = "Material", keep = FALSE, relationship = "one-to-one")

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Lista.Precios.UPC", lista.precios.upc, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Lista.Precios.Full", lista.precios.full, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Li")

dbDisconnect(SQLite.Guess_HB)

write.csv(lista.precios.upc, file = "db/Lista_Precios.csv", row.names = FALSE, na = "")
