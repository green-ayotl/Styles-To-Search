#Busqueda, copiar por lista con nombre de archivo, interactivo para seleccionar archivo y carpeta

library(readxl)
library(dplyr)

#------
#Parametros
extension <- ".jpg"

# Archivo Busqueda general, pestaña "Lista"
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Lista - IMG")

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
#readline(prompt = "Presiona [Enter] para continuar") 

carpeta_destino <- gsub("\\\\","/", choose.dir())

# To-Do Error caching on excel file, error on empty/null rows
#---

#readline(prompt = paste0("Presiona [Enter] para continuar para comenzar a copiar archivos")) 

# Pre-loop ----
total <- nrow(styles_to_search)
counting <- 1
done <- basename(list.files(path = carpeta_destino, pattern = extension, full.names = FALSE))

# Loop ----
#Copia de archivos a partir de la lista de búsqueda
for (i in counting:nrow(styles_to_search)) {
  # Skiped if already done
  if(any(paste0(styles_to_search$Material_Rename[i],extension) == done)){
    print(paste0("Ya se encuentra el archivo: ",styles_to_search$Material_Rename[i],extension," -Skipped-", " [",counting,"/",total,"]"))
  } else {
  
  file.copy( from = styles_to_search$`Full Name`[i],
             to = paste0(carpeta_destino,"/",styles_to_search$Material_Rename[i],extension)
             )
  Sys.sleep(1)
  #Copiar a nueva carpeta destino
  print(paste0("Archivo copiado de material: ",styles_to_search$Material_Rename[i], ", archivo ",  " [",counting,"/",total,"]"))
  }
  counting <- counting + 1
}

#Información de los archivos (imagenes) copiados
print(paste0(
  "En la carpeta ahora hay: ",length(list.files( path = carpeta_destino, pattern = ".jpg")), " archivos .jpg"
))

conteo_materiales <- data.frame(
  Materiales = unique(styles_to_search$Material),
  Conteo = sapply(unique(styles_to_search$Material), function(x) sum(styles_to_search$Material == x))
)
