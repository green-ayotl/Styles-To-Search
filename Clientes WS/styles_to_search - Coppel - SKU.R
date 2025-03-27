# Coppel

#----
#Librerias necesarias
library(readxl)
library(magick)
library(tidyverse)
library(dplyr)
library(readxl)
#library(DBI) # not yet, integrar W&M en SQLite
#library(RSQLite)

#---- 
#Parametros Cliente
excel <- read_excel("Styles To Search - General.xlsx", sheet = "Especificaciones")

especificaciones <- excel %>% filter(Cliente == "Coppel") %>% slice(1)

tamaño <- especificaciones$resolución
alto <- especificaciones$alto.canvas # Canvas size
ancho <- especificaciones$ancho.canvas #Canvas size
dpi <- especificaciones$densidad
extension <- especificaciones$extension.final
calidad <- especificaciones$calidad
gravedad <- especificaciones$gravedad

# Parametros ISO

especificaciones <- excel %>% filter(Cliente == "Coppel_ISO") %>% slice(1)

tamaño_iso <- especificaciones$resolución
alto_iso <- especificaciones$alto.canvas # Canvas size
ancho_iso <- especificaciones$ancho.canvas #Canvas size

# Parámetros Capeta Proyecto  ----
carpeta_proyecto <-gsub("\\\\","/", choose.dir(caption = "Carpeta destino del proyecto: "))%>% paste0("/")

# Parámetros Capeta Imágenes
carpeta_final <- paste0(carpeta_proyecto,"Imagenes/")
dir.create(path = carpeta_final)

# Parámetros Carpeta Isometrica
carpeta_final_iso <-paste0(carpeta_proyecto,"ISOmetricas/")
dir.create(path = carpeta_final_iso)

# Lista de archivos a procesar ----
styles_to_search <- read_excel(path = "Styles To Search - General.xlsx", sheet = "Coppel - IMG") #%>% arrange(colnames(styles_to_search)[1])

#Imágenes: Ecom Coppel ----

canvas <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
ecom_coppel <- styles_to_search %>% filter(Descripcion != "ISOmetrica")
total_imgs_ecom <- nrow(ecom_coppel)

done_ecom <- tools::file_path_sans_ext(list.files( path = carpeta_final, full.names = FALSE))

for (i in 1:nrow(ecom_coppel)) {
  if (any(ecom_coppel$Rename[i] == done_ecom)){
    print(paste0(
      "Ya se encuentra el archivo: ", ecom_coppel$Rename[i], "; saltando procesamiento. Archivo: ", counting," de ",total_imgs_ecom
    ))
    counting <- counting + 1
  } else {
  full_name <- ecom_coppel$Full_Path[i]
  IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño)
  IMG <- image_composite(canvas, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final,"/",ecom_coppel$Rename[i],extension), format = "jpeg" , density = dpi, compression = "JPEG")
  
  Sys.sleep(2) #Evitar cuello de botella en Onedrive
  
  print(paste0("Material: ", ecom_coppel$Material[i],"; Archivo: ",ecom_coppel$Rename[i] ,"; procesado: ", counting," de ", total_imgs_ecom))
  counting <- counting + 1
}}

# Creación para ISOmetricas ----

isometricas <- styles_to_search %>% filter(Descripcion == "ISOmetrica")
canvas_iso <- image_blank(width = ancho, height = alto, color = "white")
counting <- 1
total_imgs <- nrow(isometricas)

done_iso <- tools::file_path_sans_ext(list.files( path = carpeta_final_iso, full.names = FALSE))

for (h in 1:nrow(isometricas)) {
  if (any(isometricas$Rename[h] == done_iso)){
    print(paste0(
      "Ya se encuentra el archivo: ", isometricas$Rename[h], "; saltando procesamiento. Archivo: ", counting," de ",total_imgs
    ))
    counting <- counting + 1
  } else {
  full_name <- isometricas$Full_Path[h]
  IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño_iso)
  IMG <- image_composite(canvas_iso, IMG, gravity = "Center")
  image_write(IMG, path = paste0(carpeta_final_iso,"/",isometricas$Rename[h],extension), format = "jpeg" , density = dpi, compression = "JPEG")
  
  Sys.sleep(2) #Evitar cuello de botella en Onedrive
  
  print(paste0("Material: ", isometricas$Material[h],"; Archivo: ",isometricas$Rename[h] ,"; procesado: ", counting," de ", total_imgs))
  counting <- counting + 1
  Sys.sleep(1)
}}

# Obtener Lista de Medidas ----

styles <- isometricas %>% select(c("Material", "SKU", "Style_Code", "Rename"))

W.M <- read_xlsx(path = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/W&M.xlsx", sheet = "W&M") %>% 
  select(c("Style",
           "Fuente",
           "Merch Class Name",
           "Body",
           "Net Wt KG (excl pkg)",
           "Dimensions: Largo",
           "Dimensions: Ancho",
           "Dimensions: Alto",
           "Volumen cm3")) %>% rename(Style_Code = "Style", Peso_KG = "Net Wt KG (excl pkg)")

info_iso <- left_join(styles, W.M, by = "Style_Code", keep = FALSE, multiple = "last" , relationship = "many-to-one") %>% rename(Nombre_Archivo = "Rename")
info_iso_imagenes <- info_iso %>% select(c("Nombre_Archivo", "Dimensions: Largo", "Dimensions: Ancho", "Dimensions: Alto"))
volumetria_coppel <- info_iso %>%
  select(
    c("SKU",
      "Dimensions: Largo",
      "Dimensions: Ancho",
      "Dimensions: Alto",
      "Peso_KG",
      "Volumen cm3")) %>% 
  rename(Frente = "Dimensions: Largo", Fondo = "Dimensions: Ancho", Alto = "Dimensions: Alto", CM3 = "Volumen cm3")

lista_tablas <- setNames(
  list(volumetria_coppel, info_iso_imagenes, info_iso),
  c( "Portal Coppel", "ISOmetrica Archivos", "ISO completo")
)

# Exportar información para ISOmetricas ----
writexl::write_xlsx(lista_tablas, path = paste0(carpeta_final,"/Coppel_Volumetria.xlsx"), col_names = TRUE)
writexl::write_xlsx(info_iso_imagenes, path = paste0(carpeta_final_iso,"/archivos_isometria.xlsx"), col_names = TRUE)
