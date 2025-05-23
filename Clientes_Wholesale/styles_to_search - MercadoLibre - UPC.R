# PLANTILLA MERCADO LIBRE

#Esquema de función
  #Pasos -> Información -> Confirmación para continuar hasta terminar

# - PASOS -

# - Importación de Materiales con color y su correspondiente UPC
# - Compilación de imágenes y copia de imágenes
  # Este código permite buscar todos los archivos (imágenes) relacionados con cierto material (4 lados)
  #Copiarlos a una nueva carpeta, la carpeta de nombre: código UPC del material
# TO-DO
  # Important: Buscar archivos de materiales con su codigo de vista
  # - Renombre de archivos
  #User input: archivo, carpeta origen, carpeta destino
  # Tabla con informacion de archivos en directorios, incluyen todas las caras buscadas
# = To consider = - Bulk image converter

library(filesstrings)
library(readxl)
library(tidyr)
library(dplyr)
library(stringr)
library(magick)
library(readr)

# ------
# Requerimientos Meli

especificaciones <- read_excel("Styles To Search - General.xlsx", sheet = "Especificaciones") %>% 
  filter(Cliente == "MercadoLibre") %>% slice(1)

tamaño <- especificaciones$resolución
alto <- especificaciones$alto.imagen # Canvas size
ancho <- especificaciones$ancho.imagen #Canvas size
dpi <- especificaciones$densidad
extension <- especificaciones$extension.final
calidad <- especificaciones$calidad
gravedad <- especificaciones$gravedad

fuzz <- 10

# - Archivo lista de estilos -
  # Encabezados (columnas): [Material] y [Codigo UPC]: Datos únicos, evitar repetición de Materiales y UPC
  #"UN SOLO UPC POR MATERIAL"
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "MeLi - IMG")

#Display info: wait and continue

print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales con correspondiente: ",
  length(unique(styles_to_search$Codigo_UPC)),
  " codigos UPC."
))
if (length(unique(styles_to_search$Material)) == length(unique(styles_to_search$Codigo_UPC))) {
  print("Materiales y codigos UPC con sentido")
} else {
    print("Checar lista de materiales importada, no dan sentido, materiales o codigos UPC repetidos")
    mat_error <- readline( prompt = "Desea continuar [Enter] o cancelar [N]")
      if ( mat_error == "N") {stop()} else {next}
}

readline(prompt = "Presiona [Enter] para continuar")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
UPC_unicos <- unique(styles_to_search$Codigo_UPC)


#Busqueda de materiales, creacion de carpetas UPCs y copiar a los mismos
for (i in 1:length(UPC_unicos)) {

  #Seleccionar Codigo UPC
  upc_single <- as.character(UPC_unicos[i])
  upc_folder <- paste0(carpeta_final,"/", upc_single)
  
  #Crear directorio con el UPC donde quedara las imágenes
  dir.create(upc_folder, showWarnings = FALSE)
  print(paste0("Carpeta creada: ", upc_single))
  
  #Seleccionar materiales de tal UPC
  info_mat <- styles_to_search %>% filter(Codigo_UPC == UPC_unicos[i])
  
  #Editar imagenes
  for (h in 1:nrow(info_mat)){
    IMG <- image_read(path = info_mat$Full_Path[h]) %>%  #Ruta de imagen a editar
      image_trim(fuzz = 5) %>%  image_scale(tamaño)
    IMG <- image_composite(canvas, IMG, gravity = "Center")
    image_write(IMG, path = paste0(upc_folder,"/",as.character(info_mat$Rename[h]),".jpg"), density = dpi, quality = calidad)
    print(paste0(
      "En UPC: ", upc_single, " ; IMG: ", info_mat$Control[h]
    ))
  }
}

#Display info: end
print(paste0(
  "Se crearon ", length(list.dirs(carpeta_final)) -1 , " carpetas de UPC"
))

#Vector de archivos
directorios <- list.dirs(carpeta_final , recursive = FALSE)
carpetas_list <- list.dirs(carpeta_final, full.names = FALSE , recursive = FALSE)
num_archivos <- numeric(length(directorios))
for (i in seq_along(directorios)) {
  num_archivos[i] <- length(list.files(directorios[i]))
}

tabla_archivos <- data.frame(Carpetas = carpetas_list, Archivos = num_archivos)
#readline() Preguntar al usuario si mostrar tabla
print(tabla_archivos)
