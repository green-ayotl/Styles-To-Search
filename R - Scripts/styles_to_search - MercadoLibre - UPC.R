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

# - Archivo lista de estilos -
  # Encabezados (columnas): [Material] y [Codigo UPC]: Datos únicos, evitar repetición de Materiales y UPC
  #"UN SOLO UPC POR MATERIAL"
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "ML")

# Lista de Materiales -> To-Do: In project with R
materiales_signal <- read_excel( path = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Materiales Signal.xlsx", 
                                 sheet = "Special Market (Factory)")

#Display info: wait and continue

print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales con correspondiente: ",
  length(unique(styles_to_search$UPC)),
  " codigos UPC."
))
if (length(unique(styles_to_search$Material)) == length(unique(styles_to_search$UPC))) {
  print("Materiales y codigos UPC con sentido")
  stop()
} else {
    print("Checar lista de materiales importada, no dan sentido, materiales o codigos UPC repetidos")
    mat_error <- readline( prompt = "Desea continuar [Enter] o cancelar [N]")
      if ( mat_error == "N") {stop()} else {next}
}

readline(prompt = "Presiona [Enter] para continuar")

#Path debe tener "/", reemplazar "\"
#carpeta_origen <- gsub("\\\\","/",
#                       readline(prompt = "Introduce la ruta de donde se toman los archivos: "))

carpeta_final <- gsub("\\\\","/",
                      readline(prompt = "Introduce la ruta donde se guardaran los archivos: "))

#carpeta_destino <-paste0(carpeta_final,filtro_estilos)

# Lista de archivos donde buscar las imágenes
#archivos <- list.files( path = carpeta_origen, full.names = TRUE, recursive = TRUE)

#foldertosearch <- str_extract(carpeta_origen,"(?<=/)[^/]+$")
#extensiones <- str_extract(archivos, "\\.[^.]+$")

#Display info: wait and continue
#print(paste0(
#  "En la carpeta: ", foldertosearch,
#  ", se encuentran : ", length(archivos)," archivos."
#))
#print(
#  "Tabla de extensiones:")
#print(table(extensiones))
#readline(prompt = "Presiona [Enter] para continuar")
# Testing: #styles <- styles_to_search$Material[1]

#Busqueda de materiales, creacion de carpetas UPCs y copiar a los mismos
for (styles in styles_to_search$Material) {
  #Filtrar Materiales de búsqueda en Materiales Signal
  info_mat <- materiales_signal %>% filter(materiales_signal$Material %in% styles)
  
  # Legacy #Seleccionar imágenes por nombre de material coincidente#archivos_seleccionados <- archivos[str_detect(archivos, UPC)]
  
  #Seleccionar Codigo UPC del bucle
  upc_single <- styles_to_search$`Codigo UPC`[which(styles_to_search$Material == styles)]
  upc_folder <- paste0(carpeta_final,"/", upc_single)
  
  #Crear directorio con el UPC donde quedara las imágenes
  dir.create(upc_folder, showWarnings = FALSE)
  print(paste0("Carpeta creada: ", upc_single))
  
  #Seleccionar nuevo directorio
  carpeta_destino <- paste0(carpeta_final,"/",upc_single)
  
  #Legacy #Copiar al nuevo directorio file.copy( from = archivos_seleccionados, to = carpeta_destino)
  
  #Editar imagenes
  for (i in 1:nrow(info_mat)){
    path_from <- sub('[1]*','',as.vector(info_mat[i,9])) #Ruta de imagen a editar
    IMG <- image_read( path = path_from) #Leer imagen
    IMG <- image_trim(IMG) #Quitar bordes    
    IMG <- image_scale(IMG, "1600x1600") #Cambiar tamaño
    mat_renombre <- info_mat[i,"Material Rename ML"] %>% as.character()
    IMG <- image_write(IMG, path = paste0(carpeta_destino,"/",mat_renombre,".jpg"), density = 72)
    print(paste0(
      "En UPC: ", upc_single, " ; IMG: ", mat_renombre
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
#print(tabla_archivos)
