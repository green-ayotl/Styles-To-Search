# Descripción tablas
  #Colores: Archivo excel de codigo de color y color proveedor
    # Colores.No_Code: Color proveedor sin codigo de color
    # Colores.no_material: Nombre de color sin utilizar
  #Signal_Bolsas: lectura desde Listado_Archivos-Signal.R y transformación para antes de colores
    #Signal.Whole_list: full join con listado de colores
    #Signal.Materiales: Lista de materiales identificados en Signal


# Librerias ----
library(readxl)
library(tidyverse)
library(data.table)
library(tools)
library(DBI)
library(RSQLite)
library(here)

# Parámetros globales ----
source(here("Global.R"))

# Parámetros generales ----
extensiones_imagenes <- global_config$archivo_imagen %>% as.vector()

colores_archivo <- global_config$colores

# Cargar Lista Archivos - Signal Guess ----

Files.HB_Guess <- dbConnect(SQLite(), here("db", "file_list.sqlite"))
Signal_Bolsas <- dbReadTable(Files.HB_Guess, "Signal") %>% as.data.table()
dbDisconnect(Files.HB_Guess)

#Limpieza: Extensión de archivos solo imágenes ----
Signal_Bolsas <- filter(Signal_Bolsas, File_Ext %in% extensiones_imagenes)

# Archivo Colores Signal ----

colores <- data.table(read_excel(
  path = colores_archivo,
  sheet = "Colores_Guess_Signal")) %>% 
  rename(Color_Name = "Color Proveedor", Color_Code = "Codigo de color")

# Limpieza Simple: Archivo Colores
colores[,Color_Name := str_to_upper(Color_Name)]
colores[,Color_Code := str_to_upper(Color_Code)]

# Transformación para búsqueda de Materiales ----

#Dividir nombre de archivo en columnas por delimitadores
Signal_Bolsas <- separate(Signal_Bolsas, File_Name, 
                          into = c("Style_Code", "Color_Proveedor", "Group_Name", "Silueta", "Info", "Extra"),
                          sep = "-+", remove = FALSE, fill = "right", extra = "drop") %>% 
  mutate(Color_Name = str_to_upper(gsub("[^a-zA-Z0-9]", "", Color_Proveedor))) #Limpieza: Colour_Name a Color_Name

#Limpieza: Colour_Name a Color_Name
Signal_Bolsas$Info[Signal_Bolsas$Info == ""] <- NA

#Concatener $Silueta y $Info para obtener codigo de cara
Signal_Bolsas <- Signal_Bolsas %>% 
  mutate(Cara = ifelse(is.na(Info),Silueta, paste0(Silueta,"-",Info)))

# Unión Colores ----
# Unir Archivos Signal con Colores
Signal.Whole_list <- full_join(Signal_Bolsas, colores, by = "Color_Name", copy = TRUE, keep = FALSE, relationship = "many-to-many") %>% 
  mutate(Material = ifelse(!is.na(Style_Code) & !is.na(Color_Code), paste0(Style_Code,"-",Color_Code), NA)) # Nueva Columna: Material

Signal.Materiales <- Signal.Whole_list %>%
  filter(!is.na(Material) | !is.na(Style_Code)) %>% 
  select(c("Material",
           "Style_Code",
           "Cara",
           "Full_Path",
           "Departamento_Signal")) %>% rename(Coleccion = "Departamento_Signal")#Dejar solo columna importantes para exportar

# Obtener Colores huérfanos ----
Colores.no_material <- Signal.Whole_list %>% 
  filter(is.na(Material)) %>% 
  select(c("Color_Name", "Color_Code")) %>% 
  filter(!is.na(Color_Code))

Colores.No_Code <- Signal.Whole_list %>% 
  filter(is.na(Material)) %>% 
  select(c(Color_Name,Color_Proveedor,Style_Code,Departamento_Signal,File_Name)) %>% 
  filter(!is.na(File_Name)) %>% group_by(Color_Proveedor) %>% summarise(Color_Name = unique(Color_Name))

# SQLite ----

SQLite.Guess_Materiales <- dbConnect(SQLite(), here("db","guess_hb_materiales.sqlite")) #Solo para lista de materiales disponibles
dbWriteTable(SQLite.Guess_Materiales, "Signal.Materiales", Signal.Materiales, overwrite = TRUE)

SQLite.Colores <- dbConnect(SQLite(), here("db","Colores.sqlite")) # Todo lo relacionado a la lista de colores
dbWriteTable(SQLite.Colores, "Lista.Colores.Signal", colores, overwrite = TRUE)
dbWriteTable(SQLite.Colores, "Colores.No.material", Colores.no_material, overwrite = TRUE)
dbWriteTable(SQLite.Colores, "Colores.Names.without.code", Colores.No_Code, overwrite = TRUE)


dbDisconnect(SQLite.Guess_Materiales)
dbDisconnect(SQLite.Colores)

# CSV export ----
# Drop, ya hay script para concatenar/unir/limpiar informacion para exportar
#write.csv(Signal.Materiales, file = "db/Signal_Materiales.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Limpiar ambiente ----
#rm(colores,
#   Colores.No_Code,
#   Colores.no_material,
#   colores_archivo,
#   extensiones_imagenes,
#   Files.HB_Guess,
#   Signal.Materiales,
#   Signal.Whole_list,
#   Signal_Bolsas,
#   SQLite.Colores,
#   SQLite.Guess_Materiales)