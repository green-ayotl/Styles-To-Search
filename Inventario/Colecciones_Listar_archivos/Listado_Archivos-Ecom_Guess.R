library(tidyverse)
library(data.table)
library(DBI)
library(RSQLite)

# Extensión de archivos a listar

extensiones_imagenes <- c("jpg","JPG","tif","tiff","png","jpeg")

# Busqueda especializada en eCom Guess ----
ecom_guess_dir <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Ecommerce Guess/"

# Crear lista de archivos -> string match desde lista de precios en el nombre del archivo, identificar materiales en la carpeta de ecom guess
ecom_files <- data.table(Full_Path = list.files(ecom_guess_dir, pattern = extensiones_imagenes, full.names = TRUE, recursive = TRUE),
                         Album = "Ecom Guess") |> mutate(File.Name = basename(Full_Path))

# Limpieza de duplicados con referencia: "MXSCHLC"
ecom_files <- ecom_files[!grepl("MXSCHLC", File.Name), ]

# Busqueda de Materiales en Ecom Guess ----

# Cargar Lista de materiales para bolsas
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
materiales_hb <- dbReadTable(SQLite.Guess_HB, "Lista.Precios") %>% 
  filter(Departamento == "Handbags") %>% select(c("Material", "Año")) %>% #Solo Mainline, test realizado: no material de HB Factory encontrado
  arrange(Año) %>%  
  filter(Año >= 2021) #Solo contamos con carpetas de ECOM Guess desde 2021
dbDisconnect(SQLite.Guess_HB)


#Crear tabla para concatenar encontrados
ecom_guess_materiales <- data.table(Full_Path = as.character(),
                                    Album = as.character(),
                                    File.Name = as.character(),
                                    Material = as.character())

#contadores
total_ecom_guess <- nrow(materiales_hb)
procesado_ecom_guess <- 1
#Legacy
# Loop buscador de materiales desde Precios.HB en la carpeta de ecom guess
#for (i in 1:nrow(materiales_hb)) {
#  if (any(str_detect(ecom_files$File.Name, materiales_hb$Material[i]))) {
#    material_match <- ecom_files %>% filter(str_detect(ecom_files$File.Name, materiales_hb$Material[i])) %>% 
#      mutate(Material = materiales_hb$Material[i])
#    ecom_guess_materiales <- rbind(ecom_guess_materiales,material_match)
#    print(paste0(
#      "Material: ", materiales_hb$Material[i]," encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]" 
#    ))
#  } else {
#    print(paste0(
#      "Material: ",materiales_hb$Material[i]," no encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]"
#    ))
#  }
#  procesado_ecom_guess <- procesado_ecom_guess + 1
#}

# Better loop para busqueda de materiales en ecom_files
for (i in 1:nrow(materiales_hb)) {
  material_match <- ecom_files %>% filter(str_detect(ecom_files$File.Name, materiales_hb$Material[i])) %>% mutate(Material = materiales_hb$Material[i])
  ecom_guess_materiales <- rbind(ecom_guess_materiales,material_match)
  ifelse(nrow(material_match) != 0,
         print(paste0(
           "Material: ", materiales_hb$Material[i]," encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]" 
         )),
         print(paste0(
           "Material: ",materiales_hb$Material[i]," no encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]"
         )))

  procesado_ecom_guess <- procesado_ecom_guess + 1
}

# SQLite ----

Files.HB_Guess <- dbConnect(SQLite(), "db/file_list.sqlite") # db para lista de archivos
dbWriteTable(Files.HB_Guess, "ECOM.Guess", ecom_files)
dbDisconnect(Files.HB_Guess)

SQLite.Guess_Materiales <- dbConnect(SQLite(), "db/guess_hb_materiales.sqlite") #Solo para lista de materiales disponibles
dbWriteTable(SQLite.Guess_Materiales, "ECOM.Guess.Materiales", ecom_guess_materiales)
dbDisconnect(SQLite.Guess_Materiales)

# Limpiar ambiente ----

