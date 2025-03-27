#Lista de Archivos HB - Ecommerce

library(readxl)
library(dplyr)
library(magick)


# Parametros Picture Guess ECOM ----
tamaño <- "1600x2132" 
tamaño_canvas_ancho <- "2400" #Imagen alargada a lo alto
tamaño_canvas_alto <- "3168"
fondo <- "#dedede"
extension <- ".jpg"

# Archivo Busqueda general, pestaña "Lista"
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Lista - IMG")

#Imprimir información de archivo
print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales."
))

readline(prompt = "Presiona [Enter] para continuar y seleccionar Carpeta Destino") 

carpeta_destino <- gsub("\\\\","/",
                        choose.dir())
#Seleccionar solo frontales

#Seleccionar solo 3/4

#Función edición imágenes

canvas <- image_blank(width = tamaño_canvas_ancho, height = tamaño_canvas_alto, color = "#dedede") #Canvas

edicion_frontal <- function(full_file_path,resize_img,fondo_color){
  IMG <- image_read(full_file_path)
  #Transformación
  IMG <- image_fill(IMG, fondo_color, point = "+1+1", fuzz = 20) #Cambiar imagen original a fondo gris (ejemplo guess.com.mx)
  IMG <- image_trim(IMG, fuzz = 20) #Quitar espacio en blanco extra de imagen original
  IMG <- image_scale(IMG, resize_img) # Cambiar tamaño
  IMG <- image_composite(canvas, IMG, gravity = "Center") # Componer imagen recortada en nuevo tamaño
  return(IMG)
}

# Loop para lista de materiales
counting <- 0
total_archivos <-nrow(styles_to_search)

for (i in nrow(styles_to_search)){
  #Tiempo de procesamiento, comienzo
  start.time <- Sys.time()
  
  #Seleccionar archivo
  archivo <- styles_to_search$`Full Name`[i]
  
  #Función de transformación de imagen
  edicion_frontal(full_file_path = archivo, resize_img = tamaño, fondo_color = fondo)
  
  #Escribir imagen en carpeta destino
  image_write(edicion_frontal(), 
              path = paste0(carpeta_destino,"/",styles_to_search$Material_Rename[i],extension),
              format = extension,
              quality = 100)
  
  #Tiempo de procesamiento, terminado
  end.time <- Sys.time()
  time.taken <- round(end.time - start.time,2)
  
  #Imprimir archivo completado
  print(
    paste0("Se proceso el archivo: ", styles_to_search$Material_Rename[i],"; ", counting, "de ",total_archivos, "; Tiempo de procesamiento: ", time.taken
      
    )
  )
  counting <- counting + 1
}
