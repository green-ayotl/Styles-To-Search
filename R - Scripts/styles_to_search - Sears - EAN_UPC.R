# Sears

#----
#Librerias necesarias
library(readxl)
library(magick)
library(tidyr)

#---- 
#Parametros Cliente
tamaño <- "1200x1200"
alto <- "1200" # Canvas size
ancho <- "1200" #Canvas size
dpi <- 72
extension <- ".jpg"
#tamaño <- 300000
# Esquema Renombre
  #Ejemplo: la primera debe ser EAN_0, la segunda EAN_1, la tercera EAN_2 y así
  # EAN_0 : 3/4, EAN_1 : Frontal, EAN_2 : Back, EAN_4 : Superior/interna, (...)

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Sears - Lista de archivos")

#----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

for (i in 1:nrow(styles_to_search)) {
  full_name <- styles_to_search$`Full Name`[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension), density = dpi)
  
  # Reducir peso de archivo 
#  file_size <- file.info(paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension))$size

  print(paste0(styles_to_search$Renombre[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}

# To-Do 
# Compress images for target size
# Check final folder for file's sizes
