# Liverpool con divisor de Imágenes ISOmetricas

#Librerias necesarias ----
library(readxl)
library(magick)
library(tidyr)
library(stringr)
library(dplyr)

##Parámetros Cliente ---- 

tamaño <- "940x1215"
alto <- "1215" # Canvas size
ancho <- "940" #Canvas size
dpi <- 72
extension <- ".jpg"
peso <- 500
# Esquema Renombre
  #Ejemplo: la primera debe ser EAN_0, la segunda EAN_1, la tercera EAN_2 y así
  # EAN_0 : 3/4, EAN_1 : Frontal, EAN_2 : Back, EAN_4 : Superior/interna, (...)

carpeta_final <- gsub("\\\\","/", choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: ")) |> paste0("/")

#carpeta_final <- # Para Carpeta persistente

styles_to_search <- read_excel("Clientes_Wholesale/Styles To Search - General.xlsx", sheet = "Liverpool - IMG") %>% 
  filter(str_detect(Descripcion, "ISOmetrica", negate = TRUE)) # Quitar elemento ISO de lista, para trabajar en script separado

#----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

for (i in 1:nrow(styles_to_search)) {
  full_name <- styles_to_search$Full_Path[i]
  IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
  Sys.sleep(2) #Mimir pausa para que no explote la computadora
# Reducir peso de archivo 
#  file_size <- file.info(paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension))$size

  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}
# To-Do 
# Compress images for target size
# Check final folder for file's sizes
# Funcion - Liverpool ----

imagenes_liverpool <- function(carpeta_final,tabla_archivos,tabla_especificaciones){
  #Leer información tablas
  styles_to_search <- 
  
  # Canvas
  canvas <- image_blank(width = ancho, height = alto, color = "white")
  
  #Contador
  counting <- 1
  total_imgs <- nrow(styles_to_search)
  
  #Impresora
  for (i in 1:nrow(styles_to_search)) {
    full_name <- styles_to_search$`Full Name`[i]
    IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño)
    IMG <- image_composite(canvas, IMG, gravity = "Center")
    image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
    Sys.sleep(2) #Mimir pausa para que no explote la computadora
    # Reducir peso de archivo 
    #  file_size <- file.info(paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension))$size
    
    print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
    counting <- counting + 1
  }
  # Check final folder for file's sizes
}