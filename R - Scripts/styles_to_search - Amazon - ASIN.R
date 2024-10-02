# Amazon

#Librerias
library(magick)
library(readxl)
library(utils)
library(tidyverse)


#Parametros Cliente
tamaño <- "1600x1600"
alto <- "1600" # Canvas size
ancho <- "1600" #Canvas size
dpi <- 72
extension <- ".jpeg"

#Lista de archivos
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Amazon - IMG")

readline( prompt = "Seleccionar carpeta donde guardar [Enter]")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales con correspondiente ",
  length(unique(styles_to_search$ASIN)),
  " ASIN; se guardara en la carpeta: ",
  carpeta_final  
))

# ----
# IMG
canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

for (i in 1:nrow(styles_to_search)) {
  full_name <- styles_to_search$`Full Name`[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension), density = dpi)
  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}

#Archivo ZIP
comprimir <- readline( prompt = "Comprimir imagenes en archivo ZIP [Y]")
if(comprimir == "Y") {
  archivo_zip <- gsub("\\\\","/",
                        choose.dir(caption = "Introduce la ruta donde se guardaran archivo ZIP: "))
  zip(zipfile = paste0(archivo_zip,"/Amazon Lote - ",today()), files = list.files( path = carpeta_final, full.names = TRUE))
} else {
  print("Archivos se quedan sin comprimir")
  next
}
