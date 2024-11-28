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
extension <- ".jpg"

#Lista de archivos
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Amazon - IMG")

#Para comprobar si ya existe un valor de carpeta final, se debe asignar vacio, si no existe, solo dara error la funcion exits()
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

readline(
  prompt = "[Enter] para comenzar a procesar"
)

# ----
# IMG
canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
indice_inicio <- 1
total_imgs <- nrow(styles_to_search)

#Lista de ya procesados
done <- tools::file_path_sans_ext(list.files( path = carpeta_final, full.names = FALSE))

for (i in indice_inicio:total_imgs) {
  if (any(styles_to_search$Rename[i] == done)){
    print(paste0(
      "Ya se encuentra el archivo: ", styles_to_search$Rename[i], "; saltando procesamiento. Archivo: ", counting," de ",total_imgs
    ))
    counting <- counting + 1
  } else {
  full_name <- styles_to_search$`Full Name`[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  IMG <- image_convert(IMG, colorspace = "RGB")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
  print(paste0(
    "Material: ",styles_to_search$Material[i],"; archivo procesado: ",styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
  Sys.sleep(2)
}}

#Archivo ZIP - Testing
comprimir <- readline( prompt = "Comprimir imagenes en archivo ZIP [Y]")
if(comprimir == "Y") {
  #archivo_zip <- gsub("\\\\","/",
                        #choose.dir(caption = "Introduce la ruta donde se guardaran archivo ZIP: "))
  zip::zipr(zipfile = paste0(carpeta_final,"/Amazon Lote - ",today(),".zip"), files = list.files( path = carpeta_final, pattern = extension ,full.names = TRUE), compression_level = 9)
} else {
  print("Archivos se quedan sin comprimir")
}
