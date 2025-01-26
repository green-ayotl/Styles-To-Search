# Transformar imagenes para utilizar como miniaturas, para uso en reportes proforma en excel
  ## Utiliza 4 fuentes de información
    ## Inventario de Materiales sincronizado de signal
    ## Lista de precios más reciente
    ## Año a procesar, dado por usuario
    ## Dirección Macro excel para pegar miniaturas
# Al teminar el script, abre los archivos para terminar manualmente el formato de reporte
# Archivo Output: .../Imágenes/Minis/ "año seleccionado" 'Bolsas Celdas Proforma' -Fecha actual-.xlsx

# To-Do: Utilizar información de ultimo reporte creado para rellanar información de nuevo reporte a crear

# Parámetros ----

año_procesar <- 2025 #Seleccionar año para background job

# Librerias ----

library(magick)
library(readxl)
library(dplyr)
library(tidyr)
library(writexl)
library(DBI)
library(RSQLite)

# ---- Importación de información ----
# Inventario: Materiales Signal
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
inventario_signal.materiales <- dbReadTable(SQLite.Guess_HB, "Materiales.Signal")
dbDisconnect(SQLite.Guess_HB)

#Signal_Materiales <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Signal Materiales.xlsx"

# Lista de precios
source("Flujos Comercial/latest_lista_precios.R", echo = FALSE)
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
lista_precios <- dbReadTable(SQLite.Guess_HB, "Lista.Precios")
colnames(lista_precios) <- gsub("\\.", " ", colnames(lista_precios))
dbDisconnect(SQLite.Guess_HB)

#año_procesar <- readline( prompt = "Ingresa año a procesar; Formato numerico '20XX': ")

excel_macro <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Espacio/Excel Image in path/Excel_Place_Local_Pictures_In_Cell_Using_Formula_Hack_2607.xlsm"

# ---- Cargar archivo excel - Lista de Precios ----
departamento_hb_main <-"Handbags"
departamento_hb_factory <- "Handbags Factory"

precios <- lista_precios %>%
  select(c("Código de estilo",
           "Descripción breve de estilo",
           "Código de Temporada",
           "Descripción de Temporada",
           "Año",
           "Etiqueta de grupo de jerarquía Department ",
           "Etiqueta de grupo de jerarquía Class ",
           "Etiqueta de grupo de jerarquía Sub Class ",
           "Precio IB minorista")) %>% 
  rename("Material" = "Código de estilo") %>% 
  rename("Temporada" = "Código de Temporada") %>% 
  rename("Departamento" = "Etiqueta de grupo de jerarquía Department ") %>% 
  rename("Clase" = "Etiqueta de grupo de jerarquía Class ") %>% 
  rename("Sub-Clase" = "Etiqueta de grupo de jerarquía Sub Class ")

precios_HB <- filter(precios, Departamento == departamento_hb_main | Departamento == departamento_hb_factory) #Only HB materials


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

lista_minis <- lista_minis_all %>% filter(!is.na(Material.Signal))

faltantes_anual <- sum(is.na(lista_minis_all$Material.Signal))

faltantes_temp <- lista_minis_all %>% group_by(Departamento,Temporada) %>% summarise("Materiales sin imagen" = sum(is.na(Material.Signal)))

presentes_temp <- lista_minis_all %>% group_by(Departamento,Temporada) %>% summarise("Materiales con imagen" = sum(!is.na(Material.Signal)))

# ---- Procesar imagenes de materiales ----

# Filtros para obtener frontales ----
año <- año_procesar #Seleccionar año para crear caratulas

# Parámetros Carpetas ----
#Carpetas objetivo, temp in order to copy to better path
dir_minis_year <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Minis/"

carpeta_destino <- paste0(dir_minis_year,año)

#Better Path for alt text in cell
dir_better_path <- "C:/HandBags/"

mini_better_path <- paste0(dir_better_path,año)


# Transformar archivo IMG ------
# Obtener archivos de carpeta destino para continuar donde proceso fue detenido

total <- nrow(lista_minis)
minis <- tools::file_path_sans_ext(list.files( path = carpeta_destino, full.names = FALSE))

# Counters
skipped <- 0
procesado <- 0
counting <- 0

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
  Sys.sleep(5) #Disco almacenamiento se ocupa: descargar la imagen, escribirla y subirla, permite trabajar la cola de procesos
  print(paste0(lista_minis$Material[i],"; [",counting,"/",total, "] ; -Procesado-"))
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

#Lista Principal
proforma <- lista_minis_all %>% 
  mutate(UPC = NA) %>%
  mutate(IMAGEN = NA) %>% 
  select(c(
    Material,
    UPC,
    IMAGEN,
    Departamento,
    Temporada,
    `Descripción breve de estilo`,
    Clase,
    `Sub-Clase`))

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

proforma_file <- paste0(dir_minis_year, año, " Bolsas Celdas Proforma ", fecha_reporte,".xlsx")

write_xlsx(lista_tablas, path = proforma_file)
print("Reportes Creados")

# Run-em
files <- c(general_list, proforma_file, excel_macro)

if(procesado == 0){
  #Skip: open files
  print("Sin actualización de imagenes, no se abriran archivos")
}else{
  #Open files
  print("Abriendo archivos actualizados")
for(i in files){
  shell.exec(i)
  Sys.sleep(3)
}}
