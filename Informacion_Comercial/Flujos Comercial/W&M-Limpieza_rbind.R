# Importar columnas
  # Año y temporada en codigo numerico ###
# Descriptivos estilo
  # Style Group Name
  # Merch Class Name
  # Style Name
# Dimensiones
  # Style Code
  # Country of origin
  # Body
  # Trim
  # Lining
  # Wt KG (incl pkg) (3 decimales)
  # Net Wt KG (excl pkg) (3 decimales)
  # Dimensions
    # Dimensions: Largo (redondeado, no decimales)
    # Dimensions: Ancho (redondeado, no decimales)
    # Dimensions: Alto (redondeado, no decimales)
    # Volumen cm3

library(readxl)
library(tidyverse)
library(data.table)


carpeta_wm <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/W&M"

archivos_wm <- list.files(path = carpeta_wm, pattern = ".xlsx", full.names = TRUE)

#import wW&M files

weight_and_materials <- data.table( # Para seleccionar desde la fuente
  Fuente = as.character(), # Año y temporada en codigo numerico
  ### Descriptivos estilo
  Style_Group_Name = as.character(),  # Style Group Name
  Merch_Class_Name = as.character(), # Merch Class Name
  Style_Name = as.character(), # Style Name
  ### Dimensiones
  Style_Code = as.character(), # Style Code
  Pais_Origen = as.character(), # Country of origin
  Body = as.character(), # Body
  Trim = as.character(), # Trim
  Lining = as.character(), # Lining
  Peso_Paquete = as.numeric(), # Wt KG (incl pkg) (3 decimales)
  Peso_Neto = as.numeric(), # Net Wt KG (excl pkg) (3 decimales)
  Dimensiones_raw = as.character(), # Dimensions
)

for (archivo in archivos_wm) {
  
}
