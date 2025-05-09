# PREFACE ----
# Transformar imagenes para utilizar como miniaturas, para uso en reportes proforma en excel
  ## Utiliza 4 fuentes de información
    ## Inventario de Materiales sincronizado de signal
    ## Lista de precios más reciente
    ## Año a procesar, primer parametro del script
    ## Dirección Macro excel para pegar miniaturas
# Al teminar el script, abre los archivos para terminar manualmente el formato de reporte
# Archivo Output: .../Imágenes/Minis/ "año seleccionado" 'Bolsas Celdas Proforma' -Fecha actual-.xlsx

# To-Do:1: Utilizar información de ultimo reporte creado para rellanar información de nuevo reporte a crear
  #2 : Creación y selección de carpetas para miniaturas para la proforma, tanto temporal como carpeta con ruta minima
      # Utilizar la ruta mínima, en una sola carpeta, no separar por año
  #3 : Calida de vida: Cambiar a tablas previamente limpias/procesadas, no manipular en este script

# Parámetros ----

año_procesar <- 2025 #Seleccionar año para background job

# Librerias ----

library(magick)
library(readxl)
library(dplyr)
library(tidyverse)
library(writexl)
library(DBI)
library(RSQLite)
library(here)

# Global Config ----
source(here("Global.R"))

# ---- Importación de información ----
# Inventario Generales para Proforma
SQLite.Guess_Materiales <- dbConnect(SQLite(), here("db","guess_hb_materiales.sqlite")) #Solo para lista de materiales disponibles
Inventario.General <- dbReadTable(SQLite.Guess_Materiales, "Inventario.General")
dbDisconnect(SQLite.Guess_Materiales)

inventario_signal.materiales <- Inventario.General # Agregar a nombre utilizado anteriormente

# Lista de precios
SQLite.Guess_HB <- dbConnect(SQLite(), here("db","guess_hb.sqlite"))
lista_precios <- dbReadTable(SQLite.Guess_HB, "Lista.Precios")
dbDisconnect(SQLite.Guess_HB)

# Base de materiales para obtener UPC
SQLite.Guess_HB <- dbConnect(SQLite(), here("db","guess_hb.sqlite"))
Base_Materiales_UPC <- dbReadTable(SQLite.Guess_HB, "Materiales.UPC") %>% 
  rename(Material = "numero_material", UPC = "codigo_upc")
dbDisconnect(SQLite.Guess_HB)

#Lista extra de UPC
UPCs <- read_xlsx(path = global_config$upc_faltantes_excel)
Base_Materiales_UPC <- Base_Materiales_UPC %>% bind_rows(UPCs) #No necesita distinct, en bolsas existe 1 material = 1 UPC

# Excel archivo Macro ----
excel_macro <- global_config$excel_picture.in.cel

# Filtros para  Lista de Precios ----

# Departamento HB en Lista de precios
# ___________________ # Cambiar por Global Config
departamento_hb_main <-"Handbags"
departamento_hb_factory <- "Handbags Factory"
# __________________________

precios <- lista_precios %>%
  select(c("Material",
           "Descripción.breve.de.estilo",
           "Temporada",
           "Descripción.de.Temporada",
           "Año",
           "Departamento",
           "Clase",
           "Sub.Clase",
           "Precio.IB.minorista"))
# ________________ # Cambiar por lista de precios previamente seleccionada de solo HB
precios_HB <- filter(precios, Departamento %in% global_config$departamento_bolsas) #Only HB materials
# ________________

# ---- Cargar archivo excel - Signal Materiales ----
Signal_Handbags <- inventario_signal.materiales

# Silueta frontales imágenes
  #"F" y "RZ"

Frontales_Signal_Materiales <- Signal_Handbags %>% 
  filter(Cara == "F" | Cara == "RZ") %>% 
  select(c(Material, Full_Path)) %>% 
  distinct(Material, .keep_all = TRUE) %>% 
  select(c("Material", "Full_Path"))

# ---- Procesar Lista por año seleccionado -----

lista_minis <- precios_HB %>% filter(Año == año_procesar)

lista_minis_all <- left_join(x = lista_minis, y = Frontales_Signal_Materiales, by = "Material", suffix = c("", ".Signal"), keep = TRUE)

# Unir UPC
lista_minis_all <- left_join(lista_minis_all, Base_Materiales_UPC, by = "Material", keep = FALSE)

# Conteo de materiales faltantes
lista_minis <- lista_minis_all %>% filter(!is.na(Material.Signal))

faltantes_anual <- sum(is.na(lista_minis_all$Material.Signal))

faltantes_temp <- lista_minis_all %>% group_by(Departamento,Temporada) %>% summarise("Materiales sin imagen" = sum(is.na(Material.Signal)))

presentes_temp <- lista_minis_all %>% group_by(Departamento,Temporada) %>% summarise("Materiales con imagen" = sum(!is.na(Material.Signal)))

# ---- Procesar imagenes de materiales ----

# Filtros para obtener frontales ----
año <- año_procesar #Seleccionar año para crear caratulas

# Parámetros Carpetas ----
#To-Do 2:
#Carpetas objetivo, para guardar en onedrive _in order to copy to better path_
dir_minis_year <- global_config$directorio_minis

carpeta_destino <- paste0(dir_minis_year,año)

#Better Path for alt text in cell
dir_better_path <- global_config$directorio_minis_minimo

mini_better_path <- paste0(dir_better_path,año)

# Transformar archivo IMG ------
# Obtener archivos de carpeta destino para continuar donde proceso fue detenido

total <- nrow(lista_minis)
minis <- tools::file_path_sans_ext(list.files( path = carpeta_destino, full.names = FALSE))

# Counters
skipped <- 0
procesado <- 0
counting <- 1

for (i in 1:nrow(lista_minis)) {
#Test to find already processed
  if (any(lista_minis$Material[i] == minis)) {
    print(paste0(
      "Ya se encuentra el material: ", lista_minis$Material[i], "; [", counting, "/", total, "] ; -Omitido-"
    ))
    skipped <- skipped + 1
  } else {
  IMG <- image_read(path = lista_minis$Full_Path[i]) %>%  
  image_trim() %>% 
  image_scale(200) %>% 
  image_write(path = paste0(carpeta_destino,"/",lista_minis$Material[i],".jpg"))
  print(paste0(lista_minis$Material[i],"; [",counting,"/",total, "] ; -Procesado-"))
  Sys.sleep(10) #Disco almacenamiento se ocupa: descargar la imagen, escribirla y subirla, permite trabajar la cola de procesos
  procesado <- procesado + 1
  }
  counting <- counting + 1
  append(minis, lista_minis$Material[i])
}

#Imprimir Resumen final del proceso

print(paste0(
  "Se procesaron ", procesado, " materiales. Se saltaron ", skipped, " materiales. Total en carpeta: ", counting
))

if (procesado == 0) {
  print("Sin materiales nuevos a procesar, pasando a crear formatos")
#  stop("Script terminado")
}

#readline(prompt = "Copiar a Better Path for Alt Text [Enter] para proceder")

# Replicar en better path ----
file.copy(carpeta_destino, dir_better_path, overwrite = TRUE, recursive = TRUE, copy.mode = FALSE, copy.date = TRUE)

# Lista de archivos para macro ----

#readline(prompt = "Archivo excel con lista de materiales y full path para macro [Enter]")

# Una sola lista de minis, actualizar un solo archivo

minis_path <- data.frame(Archivo = list.files(path = dir_better_path, full.names = TRUE, pattern = ".jpg", recursive = TRUE)) %>% 
  mutate(Material = tools::file_path_sans_ext(basename(Archivo))) %>% select(Material, Archivo)

general_list <- paste0(dir_better_path,"Lista Minis - General.xlsx")

write_xlsx(minis_path, path = general_list, col_names = TRUE, format_headers = TRUE)

#View(faltantes_temp) #Mostrar agrupacion faltantes

# Formato Anual de Proforma ----

# Lista Principal ----
proforma <- lista_minis_all %>%
  mutate(IMAGEN = NA) %>% 
  select(c(
    Material,
    UPC,
    IMAGEN,
    Departamento,
    Temporada,
    `Descripción breve de estilo`,
    Clase,
    `Sub Clase`))

proforma$Departamento <- replace(proforma$Departamento, 
                                 lista_minis_all$Departamento == departamento_hb_main,
                                 "Mainline")
proforma$Departamento <- replace(proforma$Departamento,
                                 lista_minis_all$Departamento == departamento_hb_factory,
                                 "Special Market")
# Lista de Materiales sin imagen
Materiales_no_picture <- lista_minis_all %>% filter(is.na(Material.Signal)) %>% 
  select(c(Material,
           Departamento,
           Temporada))

#Tabla status de materiales
# ReShape faltantes_temp y presentes_temp para presentar
temporadas <- unique(lista_minis_all$Temporada)

Status_materiales <-rbind(
  pivot_wider(faltantes_temp, names_from = "Temporada", values_from = "Materiales sin imagen") %>% mutate(Status = "Materiales sin imagen"),
  pivot_wider(presentes_temp, names_from = "Temporada", values_from = "Materiales con imagen") %>% mutate(Status = "Materiales con imagen"))

# Agregar temporadas columnas faltantes, aun no se encuentran en la lista de precios
for(columna in temporadas) {
  if(!(columna %in% names(Status_materiales))) {
    mutate(Status_materiales, "Columna" = NA) # o cualquier valor por defecto
  } else {next}
}
#  select(c(
#    Departamento,
#    SP,
#    SM,
#    FA,
#    HO,
#    Status
#  ))

# Tablas para proformas

lista_tablas <- setNames(
  list(proforma, Status_materiales, Materiales_no_picture),
  c(año, "Tabla status", "Materiales sin imagen")
)

# Escribir formato proforma
fecha_reporte <- format(as.Date(Sys.Date(), format = "%Y-%m-%d"), "%d.%m.%y")

carpeta_proforma <- paste0(global_config$directorio_proformas, año,"/")

proforma_file <- paste0(año, " Bolsas Celdas Proforma ", fecha_reporte,".xlsx")

write_xlsx(lista_tablas, path = paste0(carpeta_proforma,proforma_file))
print("Reportes Creados")

# Run-em
files <- c(general_list, proforma_file, excel_macro)

#if(procesado == 0){
#  #Skip: open files
#  print("Sin actualización de imagenes, no se abriran archivos")
#}else{
  #Open files
#  print("Abriendo archivos actualizados")
#for(i in files){
#  shell.exec(i)
#  Sys.sleep(3)
#}}

# Escribir SQLite ----
tabla <- paste0("Proforma_",año_procesar)
tabla_faltantes <- paste0("Materiales.Faltantes_",año_procesar)
SQLite.Proformas <- dbConnect(SQLite(), here("db","proforma_anuales.sqlite"))
dbWriteTable(SQLite.Proformas, tabla, proforma, overwrite = TRUE) # Formato proforma
dbWriteTable(SQLite.Proformas, tabla_faltantes, Materiales_no_picture, overwrite = TRUE) # Lista Materiales Faltantes

# Escribir tabla de UPC en SQLite guess_hb
SQLite.Guess_HB <- dbConnect(SQLite(), here("db","guess_hb.sqlite"))

dbWriteTable(SQLite.Guess_HB, paste0("Materiales.UPC.",año), Base_Materiales_UPC, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, paste0("Materiales.Faltantes.",año), Materiales_no_picture, overwrite = TRUE)

dbDisconnect(SQLite.Proformas)
dbDisconnect(SQLite.Guess_HB)
