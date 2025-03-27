# Colecciones Alternativas ----
library(tidyverse)
library(data.table)
library(DBI)
library(tools)
library(RSQLite)
library(stringr)


# Parametros globales ----
extensiones_imagenes <- c("jpg","JPG","tif","tiff","png","jpeg")

# Dirección carpetas ----

nCommerce_dir <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/nCommerce_Handbags/"

commerce_general_dir <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Commerce_General/"

# Ordenamiento de fuentes
lista_coleccion_alt_guess <- data.frame(Album = c(
  "nCommerce", "commerce_general"),
  Directorio = c(nCommerce_dir, commerce_general_dir))

files_guess_alt <- data.frame(Full_Path = as.character(),
                              Departamento_Signal = as.character())

# Lista de Archivos y creación de inventario

for(i in 1:nrow(lista_coleccion_alt_guess)){
  comienzo = Sys.time()
  inventario <- data.frame(
    Full_Path = list.files(path = lista_coleccion_alt_guess$Directorio[i],
                           full.names = TRUE,
                           recursive = TRUE),
    Album = lista_coleccion_alt_guess$Album[i])
  
  files_guess_alt <- rbind(files_guess_alt, inventario)
  rm(inventario)
  print(paste0("Album: ",lista_coleccion_alt_guess$Album," inventariado"))
  print("Tiempo procesado: ")
  print(Sys.time() - comienzo)
}

#Agregar Columna: File_Name y File_Ext
files_guess_alt <- files_guess_alt %>%
  mutate(File_Name = file_path_sans_ext(str_extract(files_guess_alt$Full_Path, "[^/]*$"))) %>% 
  mutate(File_Ext = file_ext(str_extract(files_guess_alt$Full_Path, "[^/]*$")))

#Limpieza: Extensión de archivos solo imágenes
files_guess_alt <- filter(files_guess_alt, File_Ext %in% extensiones_imagenes)

# Transformar para busqueda de Materiales
guess_alt_materiales <- files_guess_alt %>%  separate(File_Name, into = c("Estilo", "Color_Code","Variante"),
                                                      sep = "-", remove = FALSE, convert = TRUE, extra = "merge", fill = "right")

# Sustituir Variantes == NA, como variante de foto frontal
guess_alt_materiales$Variante[is.na(guess_alt_materiales$Variante)] <- "F"

#Elegir fotos siguientes como variantes del material



# Seleccionar informacion para guardar en db

guess_alt_materiales <- guess_alt_materiales %>% 
  mutate(Material = paste0(Estilo,"-",Color_Code)) %>% 
  select(c(
    "Material",
    "Estilo",    
    "Variante",
    "Full_Path",
    "Album")) %>%
  rename(Style_Code = "Estilo",
         Cara = "Variante",
         Coleccion = "Album") # Ordenado para concatenar con otros tablas listas de materiales


# SQLite ----
Files.HB_Guess <- dbConnect(SQLite(), "db/file_list.sqlite") # db para lista de archivos
dbWriteTable(Files.HB_Guess, "Inventario.Alt.Files", files_guess_alt, overwrite = TRUE)
dbDisconnect(Files.HB_Guess)

SQLite.Guess_Materiales <- dbConnect(SQLite(), "db/guess_hb_materiales.sqlite") #Solo para lista de materiales disponibles
dbWriteTable(SQLite.Guess_Materiales,"nCommerce.Materiales", guess_alt_materiales, overwrite = TRUE)
dbDisconnect(SQLite.Guess_Materiales)

# Limpiar ambiente ----
#rm(comienzo,
#   commerce_general_dir,
#   extensiones_imagenes,
#   files_guess_alt,
#   guess_alt_materiales,
#   i,
#   lista_coleccion_alt_guess,
#   nCommerce_dir,
#   SQLite.Guess_Materiales,
#   Files.HB_Guess)