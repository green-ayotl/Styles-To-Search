# File List for Handbags

#---- Packages
library(tidyr)
library(dplyr)
library(tibble)
library(stringr)

#----Parámetros

image_dir <- gsub("\\\\","/",
                  choose.dir( caption = "Seleccionar carpeta de imagenes a procesar"))
extension_imagenes <- ".jpg"

#---- 

# Lista de archivos

comienzo = Sys.time()
lista_archivos <- tibble( ruta_completa = list.files( path = image_dir, pattern = extension_imagenes, full.names = TRUE, recursive = TRUE),
                          nombre_archivo = list.files( path = image_dir, pattern = extension_imagenes, full.names = FALSE, recursive = TRUE),
                          "File_name" = tools::file_path_sans_ext(list.files( path = image_dir, pattern = extension_imagenes, full.names = FALSE)))
print(Sys.time() - comienzo)

# Pattern Regex: After "/" and before "." 
# Columna Nombre Corto
lista_archivos <- lista_archivos %>% 
  mutate(nombre_corto = str_extract(nombre_archivo,"\\/([^\\/]+)\\.[^\\.]+$")) %>% 
  mutate(nombre_corto = gsub("/","", nombre_corto)) %>% 
  mutate(nombre_corto = sub(extension_imagenes,"", nombre_corto))

# Dividir columnas por delimitadores
# Estilo
lista_archivos <- lista_archivos %>%
  mutate(estilo = str_extract(nombre_corto, "^[^-]+"))
# Color ingles
lista_archivos <- lista_archivos %>%
  mutate(colour = str_extract(nombre_corto, "(?<=-)[^-]+(?=-)"))
# Familia ->>>>>> # problemas de longitud variable
lista_archivos <- lista_archivos %>%
  mutate(family_group = str_extract(nombre_corto, "(?<=^[^-]+-[^-]+-)[^-]+(?=-)"))
# Cara - Silueta
lista_archivos <- lista_archivos %>%
  mutate(silueta = str_match(nombre_corto, "^[^-]+-[^-]+-[^-]+-([^-]+)-")[,2])
