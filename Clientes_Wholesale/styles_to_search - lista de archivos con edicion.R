#Busqueda, copiar por lista con nombre de archivo, interactivo para seleccionar archivo y carpeta

library(readxl)
library(dplyr)
library(magick)

#------
#Parametros
tamaño <- "1500x1500"
alto <- "1500"
ancho <- "1500"
extension <- ".jpg"
trim_fuzz <- 20
dpi <- 72
frontal_mainline <- "F"
frontal_factory <- "RZ"

# Archivo Busqueda general, pestaña "Lista"
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Lista - IMG") # Add filter
#Cargar Archivo con material y full path de archivo
#styles_to_search <- read_excel(file.choose()) # Si se fuera a elegir archivo

#----
#Cargar lista materiales signal

#Imprimir información de archivo
print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales."
))
readline(prompt = "Presiona [Enter] para continuar") 

carpeta_final <- gsub("\\\\","/",
                        choose.dir(caption = "Selecciona carpeta destino"))

# To-Do Error caching on excel file, error on empty/null rows
#---

readline(prompt = paste0("Presiona [Enter] para continuar para comenzar a copiar archivos")) 

total <- nrow(styles_to_search)
counting <- 1
canvas <- image_blank(width = ancho, height = alto, color = "white")

#Transformación de archivos y copia
for (i in counting:nrow(styles_to_search)) {

  IMG <- image_read( path = styles_to_search$`Full Name`[i]) |> image_trim(fuzz = 0) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center") #Canvas
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Material[i],extension), format = "jpeg" , density = dpi, compression = "JPEG")
  
  Sys.sleep(2) #Evitar cuello de botella en Onedrive
  
  print(paste0("Material: ", styles_to_search$Material[i],"; Archivo: ",styles_to_search$Material[i] ,"; procesado: ", counting," de ", total))
  counting <- counting + 1
  
  #Copiar a nueva carpeta destino
  #print(paste0("Archivo copiado de material: ",styles_to_search$Material_Rename[i], ", archivo ", counting, " de ", total))
}

#Información de los archivos (imagenes) copiados
print(paste0(
  "En la carpeta ahora hay: ",length(list.files( path = carpeta_destino, pattern = ".jpg")), " archivos .jpg"
))
