# PLANTILLA Cliente Privalia

library(magick)
library(readxl)
library(dplyr)

# - Funcionamiento -

#Importar parámetros Cliente ----
especificaciones <- read_excel("Styles To Search - General.xlsx", sheet = "Especificaciones") |> 
  filter(Cliente == "Privalia") |> slice(1)

tamaño <- especificaciones$resolución
alto <- especificaciones$alto.canvas # Canvas size
ancho <- especificaciones$ancho.canvas #Canvas size
dpi <- especificaciones$densidad
extension <- especificaciones$extension.final
calidad <- especificaciones$calidad
gravedad <- especificaciones$gravedad

# Importar lista de Materiales ----
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Privalia - IMG")


#Display general info ----

print(paste0("Se exportara un total de ",
             nrow(styles_to_search),
             " materiales."))

# Parámetros: Carpeta final ----

message("Selecionar carpeta para exportar las imagenes")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: ")) |> paste0("/")

# Guess Printer ----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

done <- tools::file_path_sans_ext(list.files(path = carpeta_final, full.names = FALSE))

for (i in 1:nrow(styles_to_search)) {
  if (any(styles_to_search$Rename[i] == done)){
    print(paste0(
      "Ya se encuentra el archivo: ", styles_to_search$Rename[i], " -Omitido-. [", counting,"/",total_imgs,"]"
    ))
  } else {
  full_name <- styles_to_search$Full_Path[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 5) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "LosslessJPEG")
  print(paste0(styles_to_search$Rename[i], "; procesado [", counting,"/", total_imgs,"]"))
  Sys.sleep(3)
  }
  counting <- counting + 1
  
  }

#Display info: end ----
#not yet necessary
