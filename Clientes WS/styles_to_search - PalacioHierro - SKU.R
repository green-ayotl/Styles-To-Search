# Palacio

#Librerias
library(magick)
library(readxl)
library(utils)
library(tidyverse)


#Parametros Cliente
especificaciones <- read_excel("Styles To Search - General.xlsx", sheet = "Especificaciones") %>% 
  filter(Cliente == "Palacio de Hierro") %>% slice(1)

tamaño <- especificaciones$resolución
alto <- especificaciones$alto.imagen # Canvas size
ancho <- especificaciones$ancho.imagen #Canvas size
dpi <- especificaciones$densidad
extension <- especificaciones$extension.final
calidad <- especificaciones$calidad
gravedad <- especificaciones$gravedad

#Lista de archivos
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "PalacioHierro - IMG")

#readline( prompt = "Seleccionar carpeta donde guardar [Enter]")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$MATERIAL)),
  " materiales con correspondiente ",
  length(unique(styles_to_search$SKU)),
  " SKU; se guardara en la carpeta: ",
  carpeta_final  
))
Sys.sleep(1)
#readline( prompt = "Presiona [Enter] para comenzar la edición en lote")

# Canvas parametro ----
# IMG
canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

# No duplicados No duplicados ----
procesados <- tools::file_path_sans_ext(list.files( path = carpeta_final, full.names = FALSE))

# Editor de imagenes ----
for (i in 1:nrow(styles_to_search)) {
  if (any(styles_to_search$Rename[i] == procesados)) {
    print(paste0(
      "Ya se encuentra el archivo: ",styles_to_search$Rename[i]," del material: ",styles_to_search$MATERIAL[i]," -omitido- [",
      counting,"/",total_imgs,"]"
    ))
#    Sys.sleep(0.25)
  } else {
  full_name <- styles_to_search$Full_Path[i]
  IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = gravedad)
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension), density = dpi, quality = calidad)
  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs," [",counting,"/",total_imgs,"]"))
  #Sys.sleep(2)
  }
  counting <- counting + 1
}
