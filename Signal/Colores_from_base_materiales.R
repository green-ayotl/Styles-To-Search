#Colores: Busqueda de prooveedores

# Librerias ----
library(tidyverse)
library(DBI)
library(RSQLite)
library(stringr)

# Cargar información ----

# Base de Materiales
rstudioapi::jobRunScript(
  path = "Flujos Comercial/latest_base_materiales.R",
  name = "Actualización de Base de Materiales",
  workingDir = getwd()
)

# Lista de materiales 
rstudioapi::jobRunScript(
  path = "Flujos Comercial/latest_lista_precios.R",
  name = "Actualización de Lista de Precios",
  workingDir = getwd()
)

#Conectar con db
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")

departamento_bolsas <- c("Handbags", "Handbags Factory")

lista.precios <- dbReadTable(SQLite.Guess_HB, "Lista.Precios") %>% 
  filter(Departamento %in% departamento_bolsas) %>% 
  select(c("Material","Año")) %>% 
  filter(Año >= 2016) %>% #Año desde que tenemos materiales desde ShareFile Signal 
  separate(Material, into = c("Style_Code", "Color_Code"), sep = "-", remove = FALSE, extra = "drop", convert = TRUE, fill = "right")

base.materiales <- dbReadTable(SQLite.Guess_HB, "Base.Materiales") %>% 
  select(c("NUMERO_MATERIAL",
           "CODIGO_COLOR_PROVEEDOR",
           "DESCRIPCION_COLOR_PROVEEDOR")) %>%
  mutate(COLOR_NAME = str_to_upper(gsub("[^A-Za-z0-9]", "", DESCRIPCION_COLOR_PROVEEDOR))) %>% 
  rename(Material = NUMERO_MATERIAL)


# Unión de tablas ----
# Unir tablas y obtener: Descripción de color y códigos correspondientes del departamento de Bolsas

Colores_To_Search <- left_join(lista.precios, base.materiales, by = "Material", suffix =  c(".Precios", ".Base"),keep = FALSE) %>% 
  mutate(Igualdad_Codigo.Color = Color_Code == CODIGO_COLOR_PROVEEDOR) %>% 
  filter(Igualdad_Codigo.Color == TRUE)

