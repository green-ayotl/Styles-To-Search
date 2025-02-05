# Inventario imagenes

library(tidyverse)
library(data.table)
library(tools)
library(stringr)
library(DBI)
library(RSQLite)
library(readxl)

# Parametros ----

# Extensión de archivos a listar

extensiones_imagenes <- c("jpg","JPG","tif","tiff")

# Archivo Colores Signal ----

colores <- data.table(read_excel(
  path = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Colores_Guess_Signal.xlsx",
  sheet = "Colores_Guess_Signal")) %>% 
  rename(Color_Name = "Color Proveedor", Color_Code = "Codigo de color")
  # Limpieza Simple: Archivo Colores
colores[,Color_Name := str_to_upper(Color_Name)]
colores[,Color_Code := str_to_upper(Color_Code)]

# Origen Carpeta Signal en ShareFile ----

sharefile_drive = "S:/Carpetas/" # Carpeta default para programa escritorio de sharefile

departamentos_guess_signal <- data.frame(Departamento = c(
  "Mainline", "Factory", "Mens"),
  Directorio = c("GUESS MAINLINE ECOM IMAGES", "SPECIAL MARKETS ECOM", "GUESS MENS ECOM"))

files_signal_guess <- data.frame(Full_Path = as.character(),
                                 Departamento_Signal = as.character())

# Escaneo de archivos ----
# Mejorar Scaneo de archivos por año, para scaneo rapido (temporada/año actual)
for(i in departamentos_guess_signal$Directorio){
  comienzo = Sys.time()
  files_signal_guess <- rbind(files_signal_guess, data.frame(Full_Path = list.files(path = paste0(sharefile_drive,i,"/"), full.names = TRUE, recursive = TRUE),
                                                             Departamento_Signal = i))
  print(paste0("Departamento: ",i," inventariado"))
  print("Tiempo procesado: ")
  print(Sys.time() - comienzo)
}

#Agregar Columna: File_Name y File_Ext
files_signal_guess <- files_signal_guess %>%
  mutate(File_Name = file_path_sans_ext(str_extract(files_signal_guess$Full_Path, "[^/]*$"))) %>% 
  mutate(File_Ext = file_ext(str_extract(files_signal_guess$Full_Path, "[^/]*$")))

# Transformación para búsqueda de Materiales ----

#Limpieza: Extensión de archivos solo imágenes
Signal_Bolsas <- filter(files_signal_guess, File_Ext %in% extensiones_imagenes)

#Duplicar File_Name para dividir entre delimitador
#files_signal_guess$File_Name_div <- files_signal_guess$File_Name 

#Dividir en columnas por delimitadores
Signal_Bolsas <- Signal_Bolsas%>%
  separate(File_Name, into = c("Style_Code", "Color_Proveedor", "Group_Name", "Silueta", "Info", "Extra"), sep = "-+", remove = FALSE, fill = "right")
Signal_Bolsas$Info[Signal_Bolsas$Info == ""] <- NA #Simple limpieza de columna, para poder crear la columna $Cara

#Concatener $Silueta y $Info para obtener codigo de cara
Signal_Bolsas <- Signal_Bolsas %>% 
  mutate(Cara = ifelse(is.na(Info),Silueta, paste0(Silueta,"-",Info)))

#Limpieza: Colour_Name a Color_Name
Signal_Bolsas <- Signal_Bolsas %>% 
  mutate(Color_Name = str_to_upper(str_extract(Color_Proveedor, "[a-zA-Z0-9]+")))

# Agregar el tamaño del archivo a la tabla en MB #Snippet tardado, aun no información relevante para el proyecto
#files_signal_guess <- files_signal_guess %>% 
#  mutate(File_Size_MB = file.info(Full_Path)$size / (1024^2) )

# Unión Colores ----
# Unir Archivos Signal con Colores
Signal.Materiales <- left_join(Signal_Bolsas, colores, by = "Color_Name", copy = TRUE, keep = FALSE) %>% 
  mutate(Material = ifelse(!is.na(Style_Code) & !is.na(Color_Code), paste0(Style_Code,"-",Color_Code), NA)) %>%  # Nueva Columna: Material
  select(c("Material",
    "Style_Code",
    "Group_Name",
    "Cara",
    "Full_Path",
    "Departamento_Signal")) #Dejar solo columna importantes para exportar

# To-Do: Crear lista de Colores Huérfanos

# Imprimir conteo del inventario
# To do: comparar con el inventario anterior


# Exportar CSV ----
write.csv(Signal.Materiales, file = "db/Inventario_Signal_Materiales.csv", row.names = FALSE, na = "")

# SQLite ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
dbWriteTable(SQLite.Guess_HB, "Archivos.Signal", files_signal_guess, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Signal.Bolsas", Signal_Bolsas, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Colores", colores, overwrite = TRUE)
dbWriteTable(SQLite.Guess_HB, "Materiales.Signal", Signal.Materiales, overwrite = TRUE)

dbDisconnect(SQLite.Guess_HB)
