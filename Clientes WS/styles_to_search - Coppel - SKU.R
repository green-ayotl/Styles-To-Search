# Coppel

#----
#Librerias necesarias
library(readxl)
library(magick)
#library(tidyr)
library(dplyr)

#---- 
#Parametros Cliente
tamaño <- "1600x1280"
ancho <- "1600" # Canvas size
alto <- "1280" #Canvas size
dpi <- 72
extension <- ".jpg"
#tamaño <- 300000 #Sin objetivo de tamaño para este cliente

carpeta_final <-gsub("\\\\","/",
                      choose.dir(caption = "Carpeta destino: "))

styles_to_search <- read_excel(path = "C:/Users/ecastellanos.ext/OneDrive - Axo/Documentos/GitHub/Styles-To-Search/Styles To Search - General.xlsx", sheet = "Coppel - IMG") #%>% arrange(colnames(styles_to_search)[1])

#----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

for (i in counting:nrow(styles_to_search)) {
  full_name <- styles_to_search$`Full Name`[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 0) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension), format = "jpeg" , density = dpi, compression = "JPEG")
  
  Sys.sleep(5) #Evitar cuello de botella en Onedrive
  
  print(paste0("Material: ", styles_to_search$Material[i],"; Archivo: ",styles_to_search$Rename[i] ,"; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}
