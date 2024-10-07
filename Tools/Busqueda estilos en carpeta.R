# Título: Busqueda estilos en carpeta.R
# Autor: Eduardo Castellanos Cruz
  # Contacto AXO: ecastellanos.ext@proveedoresga.com
# Fecha: 06/10/2024
# Descripción: Herramienta para buscar materiales/estilos en un carpeta desde una lista a travéz de su nombre de archivo
# Versión de R: 4.3.3

#install.packages(c("stringr","readxl","tibble","dplyr","writexl"), quiet = TRUE) #Instalar paqueterias, solo usar la primera vez

library(stringr)
library(readxl)
library(tibble)
library(dplyr)
library(writexl)

#-----
#Parametros
extension_imagenes <- ".jpg" #Archivos con esta extensión se buscara en la carpeta origen
sobre_escribir <- TRUE #Si ya se encuentra el archivo en la carpeta destino, seleccionar si se sobreescribe

# ------
# Importante #
# La lista de materiales, debe ser un archivo de excel, el encabezado de la columna debe ser: "Material" ; (sin comillas)
  # Puede incluir otras columnas, serán ignoradas
# Se lee la primera pestaña del documento, mejor, evitar pestañas extras
# Al finalizar, se agregara una nueva columna: "archivos_copiados": estos serán el numero de archivos copiados en este script
  # No contara los archivos existentes en la carpeta destino


# Input Usuario

readline(
  prompt = "Selecciona la lista en excel, presiona [Enter]"
)
lista_excel <- gsub("\\\\","/", 
                    file.choose())

estilos <- read_xlsx(path = lista_excel)

print(paste0(
  "Se encontro un total de ", nrow(estilos), " materiales"
))

readline( prompt = "Seleccionar carpeta donde buscar materiales/estilos [Enter]")

carpeta_busqueda <- gsub("\\\\","/",choose.dir(default = "", caption = "Carpeta Busqueda de Materiales"))

readline( prompt = "Seleccionar carpeta destino para materiales/estilos encontrados [Enter]")

carpeta_destino <- gsub("\\\\","/",choose.dir(default = "", caption = "Carpeta Destino"))

# Lista de archivos a buscar

lista_archivos <- tibble( ruta_completa = list.files( path = carpeta_busqueda, pattern = extension_imagenes, full.names = TRUE, recursive = TRUE),
                          nombre_archivo = tools::file_path_sans_ext(list.files( path = carpeta_busqueda, pattern = extension_imagenes , full.names = FALSE)))
# Columna para archivos encontrados

estilos <- estilos %>% mutate(archivos_copiados = NA)

# Búsqueda de archivos y copia

counting <- 1

for (i in 1:nrow(estilos)) {
  if (any(str_detect(lista_archivos$nombre_archivo, estilos$Material[i]))) {

    mat_match <- lista_archivos %>% filter(str_detect(lista_archivos$nombre_archivo, estilos$Material[i]))
    
    print(paste0(
      "Se encontro ", nrow(mat_match), " archivos, del material: ", estilos$Material[i]
    ))    
    
    estilos$archivos_copiados[i] <- nrow(mat_match)
    
    for (mat in 1:nrow(mat_match)) {
      file.copy(
        from = mat_match$ruta_completa[mat],
        to = carpeta_destino,
        overwrite = sobre_escribir
      )
      print(mat_match$nombre_archivo[mat])
    }
  } else {
    print(paste0(
      "No se encontro ningun archivo del material: ", estilos$Material[i]
    ))
    
    estilos$archivos_copiados[i] <- 0
  }
  
  counting <- counting + 1
}

#Escribir nueva tabla al archivo excel de origen

write_xlsx(estilos, path = lista_excel, col_names = TRUE, format_headers = TRUE)
