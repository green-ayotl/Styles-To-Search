# Chapur

#Librerias
library(magick)
library(readxl)
library(utils)
library(tidyverse)

#Parametros Cliente
especificaciones <- read_excel("Styles To Search - General.xlsx", sheet = "Especificaciones") %>% 
  filter(Cliente == "Chapur") %>% slice(1)

tamaño <- especificaciones$resolución
alto <- especificaciones$alto.canvas # Canvas size
ancho <- especificaciones$ancho.canvas #Canvas size
dpi <- especificaciones$densidad
extension <- especificaciones$extension.final
calidad <- especificaciones$calidad
gravedad <- especificaciones$gravedad

#Lista de archivos
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Chapur - IMG")

readline( prompt = "Seleccionar carpeta donde guardar [Enter]")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales."
))

readline( prompt = "Presiona [Enter] para comenzar la edición en lote")

# ----
# IMG
canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

#To-Do: Agregar anti-duplicante

done <- tools::file_path_sans_ext(list.files( path = carpeta_final, full.names = FALSE))

for (i in 1:nrow(styles_to_search)) {
  if (any(styles_to_search$Rename[i] == done)){
    print(paste0(
      "Ya se encuentra el archivo: ", styles_to_search$Rename[i], "; saltando procesamiento. Archivo: ", counting," de ",total_imgs
    ))
    counting <- counting + 1
  } else {
    #Magick Part
  full_name <- styles_to_search$Full_Path[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = gravedad)
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension), density = dpi, quality = calidad)
    #Message part
  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
    #System rest part
#  Sys.sleep(2)
    #Loop Status
  counting <- counting + 1
  }}
