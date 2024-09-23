#Busqueda, copiar por lista con nombre de archivo, interactivo para seleccionar archivo y carpeta

library(readxl)
library(dplyr)

#Cargar Archivo con material y full path de archivo
styles_to_search <- read_excel(file.choose())

#Imprimir información de archivo
print(paste0(
  "Se encontro un total de ",
  length(styles_to_search$Material),
  " materiales."
))
readline(prompt = "Presiona [Enter] para continuar") 

carpeta_destino <- gsub("\\\\","/",
                        choose.dir())

# To-Do Error caching on excel file, error on empty/null rows
#---

readline(prompt = paste0("Se copiara los archivos a: ",carpeta_destino,"; Presiona [Enter] para continuar")) 

#Copia de archivos a partir de la lista de búsqueda 
for (styles in styles_to_search$Archivo) {
  file.copy( from = styles, to = 
               paste0(carpeta_destino,"/",styles_to_search$Material[which(styles_to_search$Archivo == styles)],".jpg")
             )
  #Copiar a nueva carpeta destino
  print(paste0("Archivo copiado de material: ",styles_to_search$Material[which(styles_to_search$Archivo == styles)]))
}

#Información de los archivos (imagenes) copiados
print(paste0(
  "En la carpeta ahora hay: ",length(list.files( path = carpeta_destino, pattern = ".jpg")), " archivos .jpg"
))
