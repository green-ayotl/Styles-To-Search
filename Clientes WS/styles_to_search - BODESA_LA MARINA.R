# BODESA / LA MARINA

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
dpi <- 300
extension <- ".jpg"
peso <- 100
# Esquema Renombre
#Renombradas con modelo(1), modelo(2)

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Bodesa - IMG")

#----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

for (i in 1:nrow(styles_to_search)) {
  full_name <- styles_to_search$`Full Name`[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
  
  # Reducir peso de archivo 
  #  file_size <- file.info(paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension))$size
  
  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}