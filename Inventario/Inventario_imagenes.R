# Inventario imagenes

library(tidyverse)
library(data.table)
library(tools)
library(stringr)
library(DBI)
library(RSQLite)
library(readxl)

# Parámetros ----

# Extensión de archivos a listar

extensiones_imagenes <- c("jpg","JPG","tif","tiff","png","jpeg")


#Important To Do: Identificador de Variante
# how?? 
    # Nueva columna con cadena de texto de acuerdo al tipo de variante que demuestra
        # Plano, ISO, VALIDAR, ALT#
        # SI se encuentra tal cadena, se crea el nombre de variantes <else> se queda en NA
        # Al final se hace una coalence de todas las columnas con busqueda de variantes, omitiendo aquellas busquedas con NA
        # Dejando solo una columna con el nombre de la variante a tal imagen-material


# Guardar lista en SQLite y concatenar con Colección Alternativa para escribir en csv


# Signal Materiales simple con UPC
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
Materiales.UPCs <- dbReadTable(SQLite.Guess_HB, "Materiales.UPC") %>% distinct()
dbDisconnect(SQLite.Guess_HB)

Signal.Materiales.UPC <- left_join(Signal.Materiales, Materiales.UPCs, by = Material, keep = FALSE)
  

# To-Do: Crear lista de Colores Huérfanos

# Imprimir conteo del inventario
# To do: comparar con el inventario anterior


# Exportar CSV ----
write.csv(Signal.Materiales, file = "db/Inventario_Signal_Materiales.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(files_guess_alt, file = "db/Inventario_ALT_Materiales.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")


# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Archivos.Signal", files_signal_guess, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Signal.Bolsas", Signal_Bolsas, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Colores", colores, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Materiales.Signal", Signal.Materiales, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Ecom.Guess", ecom_guess_materiales, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Materiales.nComerce", files_guess_alt, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)

#Concatenar lista de materiales y exportar