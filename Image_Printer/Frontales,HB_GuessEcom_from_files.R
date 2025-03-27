#Tranformar archivos para margen correcto

# Frontales
library(magick)
library(dplyr)

# Parametros Picture Guess ECOM ----

# imagen final 
canvas_ancho <- "2400" #Imagen retrato a lo alto
canvas_alto <- "3168"
fondo <- "#dedede"
extension <- ".jpg"

# Calculo para alineacion central (horizontal como vertical)
margen_inferior <- 246 # Margen inferior y lateral bolsas

# frame para central de acuerdo a estetica ecom
frame_alto <- "3168"
frame_ancho <- as.character(as.numeric(canvas_ancho) - (margen_inferior*2)) # = 2400 - (246 *2)  margen de cada lado = anchura interna de la imagen

# Archivo Busqueda general, pestaña "Lista"
carpeta_alinear <-  gsub("\\\\","/",
                         choose.dir()) |> paste0("/")

styles_to_search <- list.files(path = carpeta_alinear, full.names = TRUE, recursive = TRUE)

styles_edit <- data.frame(full_path = styles_to_search,
                               file_name = basename(styles_to_search)) %>%
  mutate(ifelse(str_detect(file_name,"ALT", negate = TRUE)), "F","ALT")

# Seleccionar color de acuerdo a silueta de foto

#Imprimir información de archivo
total_archivos <-nrow(styles_edit)

print(paste0(
  "Se encontro un total de ",
  total_archivos,
  " archivos."
))

carpeta_destino <- gsub("\\\\","/",
                        choose.dir()) |> paste0("/")

# Loop para lista de materiales
counting <- 1
total_archivos <-nrow(styles_edit)

canvas <- image_blank(width = canvas_ancho, height = canvas_alto, color = fondo)

frame <- image_blank(frame_ancho, frame_alto, color = fondo)

done <- list.files( path = carpeta_destino, full.names = FALSE)

#Discriminar entre frontales y alternativas para fondo adecuado



for (i in 1:nrow(styles_edit)){
  
  if (any(done == styles_edit$file_name[i])) {
    print(paste0("No se procesara: ", styles_edit$file_name[i]))
    
  } else {
  
  # Seleccionar archivo
  archivo <- styles_edit$full_path[i]
  
  # Transformación de imagen
  img <- image_read(archivo) |> image_trim() |> image_scale(paste0(frame_ancho,"x",frame_alto))
  
  img_alto <- image_info(img) |> pull(height) # Obtener altura de imagen con el ancho determinado
  
  if (img_alto >= as.numeric(frame_alto) - 250) {
    img <- image_scale(img, "80%x80%")
    img_alto <- image_info(img) |> pull(height)
  }
  
  # Componentes altura de archivo:
  # 246: Margen inferior de la imagen
  # img_x: altura del archivo con los margenes laterales
  # Offset o margen superior
  # = 
  # 3168: Altura final del archivo
  
  offset_strip <- abs(as.numeric(canvas_alto) - img_alto - margen_inferior) # Margen superior al colocar la imagen recortada en frame centrado

  frame_fondo <- image_blank(frame_ancho, frame_alto, fondo)
  
  offset_medio <- (image_info(frame_fondo) |> pull(width) - image_info(img) |> pull(width) ) / 2
  
  margen_superior <- geometry_point(offset_medio, offset_strip)
  
  strip <- image_composite(frame_fondo, img, offset = margen_superior) # Componer con offset superior
  
  # Creación de canvas final para imagen
  canvas <- image_blank(canvas_ancho, canvas_alto, fondo)
  
  ecom_final <- image_composite(canvas, strip, gravity = "Center") # Tamaño final del archivo
  
  #Escribir imagen en carpeta destino
  image_write(ecom_final, path = paste0(carpeta_destino, styles_edit$file_name[i]))
  
  #Imprimir archivo completado
  print(
    paste0("Archivo procesado: ", styles_edit$file_name[i], ";  [",counting,"/",total_archivos,"]"
    )
  )
  }
  counting <- counting + 1
}
