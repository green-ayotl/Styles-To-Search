#WholeSale Factory

#Cliente: 

# Paraemtros imagenes ----
extension <- ".jpg"
formato_color <- "RGB"
tamaño <- "1200x1200"
  canvas_alto <- "1200"
  canvas_ancho <- "1200"
dpi <- 72
fondo <- "white"
margen_interior <- 40
peso_archivo <- 300000 #kb

# Librerias ----
library(magick)

# Input parameters ----
# Dir input
readline(prompt = "Seleccione carpeta a editar [Enter]")

carpeta_inicial <- gsub("\\\\","/",
                      choose.dir(caption = "Selecionar Carpeta"))
# Dir Output
readline(prompt = "Seleccione carpeta final donde se guardara los archivos [Enter]")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

# Lista Archivos: Preparación ----

lista_archivos <- data.frame( ruta_completa = list.files( path = carpeta_inicial, full.names = TRUE, recursive = FALSE),
                          nombre_archivo_ext = list.files( path = carpeta_inicial, full.names = FALSE, recursive = FALSE),
                          "File_name" = tools::file_path_sans_ext(list.files( path = carpeta_inicial, full.names = FALSE)))
# Canvas & pre-loop ----
canvas <- image_blank(width = canvas_ancho, height = canvas_alto, color = fondo)
counting <- 1
#1200px - 40px = 1160px 
marco_interior <- "1160x1160"

# Edición ----
for (i in counting:nrow(lista_archivos)){
  full_name <- lista_archivos$ruta_completa[i]
  IMG <- image_read(path = full_name) |> image_scale("1160x1160")
  IMG <- image_composite(canvas, IMG, gravity = "Center") |>image_convert(colorspace = formato_color)
  image_write(IMG, path = paste0(carpeta_final,"/",lista_archivos$File_name[i], extension),
              format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
  print(paste0(
    "Archivo procesado: ", counting, " de ", nrow(lista_archivos),"."
  ))
  Sys.sleep(2)
  counting <- counting + 1
#  if (counting == 16){break}
}

# Post-Edicion: Check File size ----

editados <- list.files(path = carpeta_final, pattern = extension, full.names = TRUE, recursive = TRUE)

archivos_editados <- data.frame(
  ruta_completa <- editados,
  archivos = basename(editados),
  tamaño_bytes = file.size(editados)
)

# Agregar columna en tamaño KB
archivos_editados$tamaño_KB <- round(archivos_editados$tamaño_bytes / 1024,2)

# Columna binaria: Check file.size
archivos_editados$oversize <- archivos_editados$tamaño_KB < peso_archivo
#If "TRUE", todo chido, todo bien

# Print: Si pasaron todos los archivos