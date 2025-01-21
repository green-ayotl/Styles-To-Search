#Return latest file from dir

library(dplyr)
library(stringr)
library(lubridate)

#carpeta_archivos <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Lista de Precios"

#patron_archivos <- ".xlsx"

latest_file <- function(carpeta_archivos, patron_archivos){
  patron_fecha <- "\\d{2}\\.\\d{2}\\.\\d{2}"
  file_list <- data.frame(lista_archivos = list.files(path = carpeta_archivos, full.names = TRUE, pattern = patron_archivos, include.dirs = FALSE)) %>% 
    mutate(archivos = basename(lista_archivos)) %>% mutate(Fecha_Archivo = dmy(str_extract(archivos, patron_fecha))) %>% arrange(desc(Fecha_Archivo))
  return(file_list$lista_archivos[1])
}

#print(latest_file(carpeta_archivos = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Base de Materiales", patron_archivos = ".xlsx"))