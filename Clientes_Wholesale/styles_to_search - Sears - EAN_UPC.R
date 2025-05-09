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

styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Sears - IMG")

#----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

for (i in 1:nrow(styles_to_search)) {
  full_name <- styles_to_search$Full_Path[i]
  IMG <- image_read(path = full_name) |> image_trim() |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension),
              density = dpi,
              quality = 50,
              depth = 8,
              compression = "JPEG",
              format = "jpeg")
  
  # Reducir peso de archivo 
#  file_size <- file.info(paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension))$size

  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1

}

procesados <- data.frame(Full_Path = list.files(path = carpeta_final, pattern = extension, full.names = TRUE),
                         Archivos = list.files(path = carpeta_final, pattern = extension, full.names = FALSE))
procesados$tamaño.KB <- ceiling(file.info(procesados$Full_Path)$size / 1024)


# To-Do 
# Compress images for target size
# Check final folder for file's sizes
