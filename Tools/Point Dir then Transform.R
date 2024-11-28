# Point Dir then Transform

#Librerias
library(magick)

# Parametros

tamaño <- "940x1215"
alto <- "940" # Canvas size
ancho <- "1215" #Canvas size
dpi <- 72
extension <- ".jpg"
modo <- "RGB"
patron_origen <- ".webp"
fuzz = 20
calidad <- 75

carpeta_origen <- gsub("\\\\","/",
                      choose.dir(caption = "Carpeta origen: "))

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Carpeta destino: "))

lista_archivos <- data.frame("Full_name" = list.files( path = carpeta_origen, pattern = patron_origen, full.names = TRUE),
                     "File_name" = tools::file_path_sans_ext(list.files( path = carpeta_origen, pattern = patron_origen, full.names = FALSE)))

total_imgs <- nrow(lista_archivos)
print(paste0(
  "Se transformaran ", total_imgs, " archivos."
))
readline( prompt = "Presione [Enter] para continuar")

canvas <- image_blank(width = alto, height = ancho, color = "white")
counting <- 1
indice_iniciar <- 1

for (i in indice_iniciar:nrow(lista_archivos)) {
  full_name <- lista_archivos$Full_name[i]
  IMG <- image_read( path = lista_archivos$Full_name[i]) 
  IMG <- image_trim(IMG, fuzz = fuzz) #Quitar fondo blanco extra
  IMG <- image_scale(IMG, tamaño) #Cambiar tamaño
  IMG <- image_composite(canvas, IMG, gravity = "Center") #Colocar en canvas
#  IMG <- image_fill(IMG, "white", point = "+1+1", fuzz = fuzz) #Cambiar fondo a blanco
  image_write(IMG, path = paste0(carpeta_final,"/",lista_archivos$File_name[i],extension), density = dpi)
  print(paste0(lista_archivos$File_name[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}
