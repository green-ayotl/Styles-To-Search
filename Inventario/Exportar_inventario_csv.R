# Inicio ----
  #Exportación de información, para flujos de trabajo excel y en demás formatos

# Librerias ----
library(tidyverse)
library(data.table)
library(DBI)
library(RSQLite)

# Parametros
fecha_reporte <- format(as.Date(Sys.Date(), format = "%Y-%m-%d"), "%d.%m.%y")

# Importación de información
SQLite.Guess_Materiales <- dbConnect(SQLite(), "db/guess_hb_materiales.sqlite") #Solo para lista de materiales disponibles
Signal <- dbReadTable(SQLite.Guess_Materiales, "Signal.Materiales")
ncommerce <- dbReadTable(SQLite.Guess_Materiales, "nCommerce.Materiales")
dbDisconnect(SQLite.Guess_Materiales)

#Cargar informacion para UPC
Informacion_HB_guess <- dbConnect(SQLite(), "db/guess_hb.sqlite") # Fuentes informacion Guess
Materiales.UPC <- dbReadTable(Informacion_HB_guess, "Materiales.UPC") %>% distinct() #distinct para quitar repetidos desde Latest:Base.Maeriales y UPC_Extras
dbDisconnect(Informacion_HB_guess)

#Juntar inventario e información UPC

Inventario_General <- rbind(Signal, ncommerce)
Inventario_General <- left_join(Inventario_General, Materiales.UPC, by = "Material", keep = FALSE, relationship = "many-to-one") %>% 
  mutate(Fecha.Reporte = NA)
Inventario_General$Fecha.Reporte[1] <- fecha_reporte

#Exportar CSV para importar en flujos excel

csv_archivo_db <- "C:/Users/ecastellanos.ext/Styles-To-Search/db/Inventario_General.csv"

csv_archivo_share <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Inventario/Inventario_General.csv"

write.csv(Inventario_General, file = csv_archivo_db , row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(Inventario_General, file = csv_archivo_share , row.names = FALSE, na = "", fileEncoding = "UTF-8")

# SQLite.write. Reportes Finales 

