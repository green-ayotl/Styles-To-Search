# Inventario imagenes

library(tidyverse)
library(data.table)
library(tools)
library(stringr)
library(DBI)
library(RSQLite)
library(readxl)

# Parámetros ----

# Extensión de archivos a listar

extensiones_imagenes <- c("jpg","JPG","tif","tiff","png","jpeg")

# Ruta Archivos ----
colores_archivo <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Colores_Guess_Signal.xlsx"

# Colecciones Alternativas ----
# Carpetas Colecciones Alternativas
nCommerce_dir <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/nCommerce_Handbags/"

commerce_general_dir <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Commerce_General/"

# Ordenamiento de fuentes
lista_coleccion_alt_guess <- data.frame(Album = c(
  "nCommerce", "commerce_general"),
  Directorio = c(nCommerce_dir, commerce_general_dir))

files_guess_alt <- data.frame(Full_Path = as.character(),
                                 Departamento_Signal = as.character())

# Lista de Archivos y creación de inventario

for(i in 1:nrow(lista_coleccion_alt_guess)){
  comienzo = Sys.time()
  inventario <- data.frame(
    Full_Path = list.files(path = lista_coleccion_alt_guess$Directorio[i],
                                                           full.names = TRUE,
                                                           recursive = TRUE),
    Album = lista_coleccion_alt_guess$Album[i])
  
  files_guess_alt <- rbind(files_guess_alt, inventario)
  rm(inventario)
  print(paste0("Album: ",lista_coleccion_alt_guess$Album," inventariado"))
  print("Tiempo procesado: ")
  print(Sys.time() - comienzo)
}

#Agregar Columna: File_Name y File_Ext
files_guess_alt <- files_guess_alt %>%
  mutate(File_Name = file_path_sans_ext(str_extract(files_guess_alt$Full_Path, "[^/]*$"))) %>% 
  mutate(File_Ext = file_ext(str_extract(files_guess_alt$Full_Path, "[^/]*$")))

#Limpieza: Extensión de archivos solo imágenes
files_guess_alt <- filter(files_guess_alt, File_Ext %in% extensiones_imagenes)

# Escribir a db
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB,"Inventario.Alt.Files", files_guess_alt, overwrite = TRUE)
dbDisconnect(SQLite.Guess_HB)

# Transformar para busqueda de Materiales
guess_alt_materiales <- files_guess_alt %>%  separate(File_Name, into = c("Estilo", "Color_Code","Variante"),
                            sep = "-", remove = FALSE, convert = TRUE, extra = "merge", fill = "right") %>% 
  mutate(Material = paste0(Estilo,"-",Color_Code)) %>% 
  select(c(
    "Material",
    "Variante",
    "Estilo",
    "Color_Code",
    "Full_Path",
    "Album"
  ))

# Sustituir Variantes == NA, como variante de foto frontal
guess_alt_materiales$Variante[is.na(guess_alt_materiales$Variante)] <- "F"

# Escribir en SQLite y csv
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Inventario.Alt.GuessHB", guess_alt_materiales)

write.csv(guess_alt_materiales, file = "db/Inventario_Alt_Materiales.csv", row.names = FALSE ,na = "")

# Busqueda especializada en eCom Guess ----
ecom_guess_dir <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Ecommerce Guess/"
# Crear lista de archivos -> string match desde lista de precios en el nombre del archivo, identificar materiales en la carpeta de ecom guess
ecom_files <- data.frame(Full_Path = list.files(ecom_guess_dir, full.names = TRUE, recursive = TRUE),
                         Album = "Ecom Guess") %>% mutate(File.Name = basename(Full_Path))
# Limpieza de duplicados con referencia: "MXSCHLC"
ecom_guess_materiales <- ecom_guess_materiales[!grepl("MXSCHLC", File.Name), ]

# Cargar Lista de materiales para bolsas
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
materiales_hb <- dbReadTable(SQLite.Guess_HB, "Lista.Precios") %>% 
  filter(Departamento %in% c("Handbags", "Handbags Factory")) %>% select(c("Material", "Año"))
dbDisconnect(SQLite.Guess_HB)

# Busqueda de Materiales en Ecom Guess ----
#Crear tabla para concatenar encontrados
ecom_guess_materiales <- data.table(Full_Path = as.character(),
                              Album = as.character(),
                              File.Name = as.character(),
                              Material = as.character())

#contadores
total_ecom_guess <- nrow(materiales_hb)
procesado_ecom_guess <- 1
# Loop buscador de materiales desde Precios.HB en la carpeta de ecom guess
for (i in 1:nrow(materiales_hb)) {
  if (any(str_detect(ecom_files$File.Name, materiales_hb$Material[i]))) {
    material_match <- ecom_files %>% filter(str_detect(ecom_files$File.Name, materiales_hb$Material[i])) %>% 
      mutate(Material = materiales_hb$Material[i])
    ecom_guess_materiales <- rbind(ecom_guess_materiales,material_match)
    print(paste0(
      "Material: ", materiales_hb$Material[i]," encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]" 
    ))
  } else {
    print(paste0(
      "Material: ",materiales_hb$Material[i]," no encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]"
    ))
  }
  procesado_ecom_guess <- procesado_ecom_guess + 1
}

#Important To Do: Identificador de Variante
# how?? 
    # Nueva columna con cadena de texto de acuerdo al tipo de variante que demuestra
        # Plano, ISO, VALIDAR, ALT#
        # SI se encuentra tal cadena, se crea el nombre de variantes <else> se queda en NA
        # Al final se hace una coalence de todas las columnas con busqueda de variantes, omitiendo aquellas busquedas con NA
        # Dejando solo una columna con el nombre de la variante a tal imagen-material


# Guardar lista en SQLite y concatenar con Colección Alternativa para escribir en csv


# Signal Materiales simple con UPC
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
Materiales.UPCs <- dbReadTable(SQLite.Guess_HB, "Materiales.UPC") %>% distinct()
a
dbDisconnect(SQLite.Guess_HB)

Signal.Materiales.UPC <- left_join(Signal.Materiales, Materiales.UPCs, by = Material, keep = FALSE)
  

# To-Do: Crear lista de Colores Huérfanos

# Imprimir conteo del inventario
# To do: comparar con el inventario anterior


# Exportar CSV ----
write.csv(Signal.Materiales, file = "db/Inventario_Signal_Materiales.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(files_guess_alt, file = "db/Inventario_ALT_Materiales.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")


# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Archivos.Signal", files_signal_guess, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Signal.Bolsas", Signal_Bolsas, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Colores", colores, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Materiales.Signal", Signal.Materiales, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Ecom.Guess", ecom_guess_materiales, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Materiales.nComerce", files_guess_alt, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)
