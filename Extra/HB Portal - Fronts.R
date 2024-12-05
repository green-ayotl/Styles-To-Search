# ---- Inicio, descripcción
# Script para transferir imagenes frontales del departamento de bolsas para el portal de tiendas

#Información necesaria
  # Lista de Precios


# ---- Activar librerias 
library(readxl)
library(dplyr)
library(stringr)

# ---- Parametros Generales
año_busqueda <- 2024

# ---- Parametros, dirección de archivos

lista_precios <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Lista de Precios/Lista de precios.xlsx" # AXO_pc

# ---- Carga de información

precios <- read_xlsx(path = lista_precios, col_names = TRUE)

# ---- Filtro Lista de Precios
#Valores de departamento que incluyan la cadena "Handbags"

departamento_handbags <- precios %>%
  select(`Etiqueta de grupo de jerarquía[Department]`) %>%
  filter(str_detect(`Etiqueta de grupo de jerarquía[Department]`, "Handbags")) %>% 
  unique() #%>% print()
# Usual output
  #1 Handbags                                    
  #2 Handbags Factory                            
  #3 Handbags GBG                                
  #4 Handbags Luxe                               
  #5 Handbags Marciano  

departamento_hb_main <-"Handbags"
departamento_hb_factory <- "Handbags Factory"

# Filtro por departamentos: Main y Factory con año de parametro,

materiales_HB <- filter(precios, precios$Año == año_busqueda) %>%
  filter(`Etiqueta de grupo de jerarquía[Department]` == departamento_hb_main | `Etiqueta de grupo de jerarquía[Department]` == departamento_hb_factory) %>% 
  select(c("Código de estilo", "Etiqueta de grupo de jerarquía[Department]","Etiqueta de grupo de jerarquía[Class]","Etiqueta de grupo de jerarquía[Sub-Class]")) %>% 
  rename("Material" = "Código de estilo") %>% 
  rename("Departamento" = "Etiqueta de grupo de jerarquía[Department]") %>% 
  rename("Clase" =  "Etiqueta de grupo de jerarquía[Class]") %>% 
  rename("Sub-Clase" =  "Etiqueta de grupo de jerarquía[Sub-Class]")
  
summarise(materiales_HB) 

# Cargar Inventario de materiales
  # Merge a travez de materialcon filtro de caras frontales
