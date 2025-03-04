# Liverpool

#Librerias ----
#Librerias necesarias
library(readxl)
library(magick)
library(dplyr)
library(stringr)
library(writexl)

#Parametros Cliente ---- 
#Parametros Cliente
tamaño <- "1000x800"
alto <- "1600" # Canvas size
ancho <- "1280" #Canvas size
dpi <- 72
extension <- ".jpg"
peso <- 500
# Esquema Renombre
  #Ejemplo: la primera debe ser EAN_0, la segunda EAN_1, la tercera EAN_2 y así
  # EAN_0 : 3/4, EAN_1 : Frontal, EAN_2 : Back, EAN_4 : Superior/interna, (...)

# Ingesta de información ----
carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

cara_isometricas <- c("F","Q","RZ","PZ")

styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Coppel - IMG") %>%  
  filter(Cara %in% cara_isometricas) |> mutate(Rename = sub("[SKU]", SKU, Coppel)) |> mutate(Rename = sub("^.*\\d$"), "4", Rename)

styles_to_ISO <- tibble(Material = unique(styles_to_search$Material),
                        to_ISO = NA) %>% mutate(Rename = paste0(Material," (ISO)")) %>% mutate(Style_Code = str_extract(Material,"^[^-]+"))

for (i in styles_to_ISO$Material) {
  if (any(styles_to_search$Material == i & styles_to_search$Cara == "Q")) { #Si hay Cara Q, dejar el archivo Q
    #Asignar archivo con cara Q al material
    styles_to_ISO$to_ISO[which(styles_to_ISO$Material == i)] <- filter(styles_to_search, Material == i & Cara == "Q")$Full_Path
  } else { #Si no hay Cara Q del material, asignar archivo Cara F
    #Asignar archivo con cara F al material
    styles_to_ISO$to_ISO[which(styles_to_ISO$Material == i)] <- filter(styles_to_search, Material == i & Cara == "F")$Full_Path
  }
}

# Para obtener medidas desde W&M
styles_from_search <- unique(styles_to_search$Style_Code)

Weights.Materials <- read_excel(path = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/W&M.xlsx") %>% 
  filter(Style %in% styles_from_search) %>%  select(c(
    "Fuente",
    "Style",
    "Style Group Name",
    "Style Name",
    "Dimensions: Largo",
    "Dimensions: Ancho",
    "Dimensions: Alto"
  ))

#Procesandor de imagnes Isometricas ----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_ISO)

for (i in 1:nrow(styles_to_ISO)) {
  full_name <- styles_to_ISO$to_ISO[i]
  IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño)

  #Agregar valores ISOmetricos
    #Filtar Weights.Materials por el estilo, ordenar Fuente de mayor a menos y slice(1)
    #Tomar los valores e image_composite, a la derecha el alto, arriba el largo y abajo-izquierda el ancho
  
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_ISO$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
  Sys.sleep(2)
}

#Escribir archivos medidas
write_xlsx(Weights.Materials, path = paste0(carpeta_final,"/Medidas.xlsx"))

# To-Do 
# Compress images for target size
# Check final folder for file's sizes
# Funcion - Liverpool ----

imagenes_liverpool <- function(carpeta_final,tabla_archivos,tabla_especificaciones){
  #Leer información tablas
  styles_to_search <- 
  
  # Canvas
  canvas <- image_blank(width = ancho, height = alto, color = "white")
  
  #Contador
  counting <- 1
  total_imgs <- nrow(styles_to_search)
  
  #Impresora
  for (i in 1:nrow(styles_to_search)) {
    full_name <- styles_to_search$`Full Name`[i]
    IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
    IMG <- image_composite(canvas, IMG, gravity = "Center")
    image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
    Sys.sleep(2) #Mimir pausa para que no explote la computadora
    # Reducir peso de archivo 
    #  file_size <- file.info(paste0(carpeta_final,"/",styles_to_search$Renombre[i],extension))$size
    
    print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
    counting <- counting + 1
  }
  
  # Check final folder for file's sizes
  
}