# PLANTILLA Cliente Sanborns

library(magick)
library(readxl)
# - Funcionamiento -

# - Importación de Materiales con color y su correspondiente UPC
# - Busqueda de imagenes, objeto magick, escritura correspondiente de acuerdo a su UPC
  # Este script permite buscar todos los archivos (imágenes) relacionados con cierto material (4 lados minimo)
  #Bulk Copy & Bulk Rename & Bulk Transform a una nueva carpeta

# Requerimientos Cliente Sanborns
  # 1200 x 1200 px  
  # 72 dpis  
  # Renombradas con su UPC, UPC_2, UPC_3...  
  # UPC : 3/4; UPC_2 : Frontal; UPC_3 : Back ; UPC_4 : Interior/Superior

#Parametros Sanborns
tamaño <- "1200x1200"
dpi <- 72
extension <- ".jpg"
alto <- "1200" # Canvas size
ancho <- "1200" #Canvas size
  #Rename UPC: 
    #UPC : 3/4
    #UPC_2 : Frontal
    #UPC_3 : Back
    #UPC_4 : Interior/Superior

#Excel: Archivos Signal Factory
styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Sanborns - IMG")

# Lista de Materiales -> To-Do: In project with R
#materiales_signal <- read_excel( path = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Materiales Signal.xlsx", 
#                                sheet = "Special Market (Factory)")


#Display info: wait and continue

print(paste0(
  "Se encontro un total de ",
  length(unique(styles_to_search$Material)),
  " materiales con correspondiente: ",
  length(unique(styles_to_search$UPC)),
  " codigos UPC/EAN."
))

if (length(unique(styles_to_search$Material)) == length(unique(styles_to_search$UPC))) {
  print("Materiales y codigos UPC con sentido")
} else {
  print("Checar lista de materiales importada, no dan sentido, materiales o codigos UPC repetidos")
  mat_error <- readline( prompt = "Desea continuar [Enter] o cancelar [N]")
  if ( mat_error == "N") {stop()} else {next}
}
readline(prompt = "Presiona [Enter] para continuar")

#Path debe tener "/", reemplazar "\"
#carpeta_origen <- gsub("\\\\","/",
#                       readline(prompt = "Introduce la ruta de donde se toman los archivos: "))

readline( prompt = "Seleccionar carpeta donde guardar [Enter]")

carpeta_final <- gsub("\\\\","/",
                      choose.dir(caption = "Introduce la ruta donde se guardaran los archivos: "))

# ----
# IMG
canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(styles_to_search)

#Custom Funtion
#material_tranform <- function(fullname, tamaño, dpi, destino, upc_name, consecutivo, extension) {
#  IMG <- image_read( path = fullname) |> image_trim() |> image_scale(tamaño)
#  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
#  print(paste0(destino,"/",upc_name,"_",consecutivo,extension))
#}

for (i in 1:nrow(styles_to_search)) {
  full_name <- styles_to_search$`Full Name`[i]
  IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i], extension), format = "jpeg" , density = dpi, compression = "JPEG", depth = "8")
  print(paste0(styles_to_search$Rename[i], "; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
}

#Busqueda de materiales, transformar, escribir y renombrar de acuerdo a UPC correspondiente
#for (styles in styles_to_search$Material) {
#  #Filtrar Materiales de búsqueda en Materiales Signal
#  info_mat <- materiales_signal %>% filter(materiales_signal$Material %in% styles)
#  caras <- info_mat %>% select(Cara, `Full Name`)
  #Seleccionar Codigo UPC del bucle
#  upc_single <- styles_to_search$UPC[which(styles_to_search$Material == styles)]
#   for (i in 1:nrow(caras)) {
#     fila_actual <- caras[i,]
#     if (caras$Cara == "PZ") {
#       
#     }
#   }
  
  #Legacy #Copiar al nuevo directorio file.copy( from = archivos_seleccionados, to = carpeta_destino)
  
  #Editar imagenes
#  for (i in 1:nrow(info_mat)){
#    path_from <- sub('[1]*','',as.vector(info_mat[i,9])) #Ruta de imagen a editar
#    IMG <- image_read( path = path_from) #Leer imagen
#    IMG <- image_trim(IMG) #Quitar bordes    
#    IMG <- image_scale(IMG, "1200x1200") #Cambiar tamaño
#    mat_renombre <- info_mat[i,"Material Rename ML"] %>% as.character()
#    IMG <- image_write(IMG, path = paste0(carpeta_destino,"/",mat_renombre,".jpg"), density = 72)
#    print(paste0(
#      "En UPC: ", upc_single, " ; IMG: ", mat_renombre
#    ))
#  }
#}

#Display info: end
print(paste0(
  "Se crearon ", length(list.dirs(carpeta_final)) -1 , " carpetas de UPC"
))

#Vector de archivos
directorios <- list.dirs(carpeta_final , recursive = FALSE)
carpetas_list <- list.dirs(carpeta_final, full.names = FALSE , recursive = FALSE)
num_archivos <- numeric(length(directorios))
for (i in seq_along(directorios)) {
  num_archivos[i] <- length(list.files(directorios[i]))
}

tabla_archivos <- data.frame(Carpetas = carpetas_list, Archivos = num_archivos)
#readline() Preguntar al usuario si mostrar tabla
#print(tabla_archivos)
