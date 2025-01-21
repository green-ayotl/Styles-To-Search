# Inventario imagenes

library(tidyverse)
library(data.table)
library(tools)
library(stringr)
library(DBI)
library(RSQLite)
library(readxl)

# Parametros ----
# Archivo Colores Signal

colores <- data.table(read_excel(
  path = "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Colores_Guess_Signal.xlsx")) %>% 
  rename(Color_Name = "Color Proveedor", Color_Code = "Codigo de color")
  # Limpieza Simple: Archivo Colores
colores[,Color_Name := str_to_upper(Color_Name)]
colores[,Color_Code := str_to_upper(Color_Code)]

# Extensión de archivos a listar
extensiones_imagenes <- c("jpg","JPG","tif","tiff")


# Origen Carpeta Signal en ShareFile ----

sharefile_drive = "G:/Carpetas/"

departamentos_guess_signal <- data.frame(Departamento = c(
  "Mainline", "Factory", "Mens"),
  Directorio = c("GUESS MAINLINE ECOM IMAGES", "SPECIAL MARKETS ECOM", "GUESS MENS ECOM"))

files_signal_guess <- data.frame(Full_Path = as.character(),
                                 Departamento_Signal = as.character())

# Mejorar Scaneo de archivos por año, para scaneo rapido (temporada/año actual)
for(i in departamentos_guess_signal$Directorio){
  comienzo = Sys.time()
  files_signal_guess <- rbind(files_signal_guess, data.frame(Full_Path = list.files(path = paste0(sharefile_drive,i,"/"), full.names = TRUE, recursive = TRUE),
                                                             Departamento_Signal = i))
  print(paste0("Departamento: ",i," inventariado"))
  print("Tiempo procesado: ")
  print(Sys.time() - comienzo)
}

#Limpieza: Extensión de archivos solo imagenes
files_signal_guess <- filter(files_signal_guess, File_Ext %in% extensiones_imagenes)

#Agregar Columna: File_Name y File_Ext
files_signal_guess <- files_signal_guess %>%
  mutate(File_Name = file_path_sans_ext(str_extract(files_signal_guess$Full_Path, "[^/]*$"))) %>% 
  mutate(File_Ext = file_ext(str_extract(files_signal_guess$Full_Path, "[^/]*$")))

#Duplicar File_Name para dividir entre delimitador
files_signal_guess$File_Name_div <- files_signal_guess$File_Name 

#Dividir en columnas por delimitadores
files_signal_guess <- files_signal_guess %>% separate(File_Name_div, into = c("Style_Code","Colour_Name", "Group_Name", "Silueta", "Info"), sep = "-+", fill = "right")

#Limpieza: Colour_Name a Color_Name
files_signal_guess <- files_signal_guess %>%
  mutate(Color_Name = str_to_upper(str_extract(files_signal_guess$Colour_Name, "[a-zA-Z0-9]+")))

# Agregar el tamaño del archivo a la tabla en MB #Snippet tardado, aun no información relevante para el proyecto
#files_signal_guess <- files_signal_guess %>% 
#  mutate(File_Size_MB = file.info(Full_Path)$size / (1024^2) )

# Unir Archivos Signal con Colores

Signal.Materiales <- left_join(files_signal_guess, colores, by = "Color_Name", copy = TRUE, keep = FALSE) %>% 
  mutate(Material = ifelse(!is.na(Style_Code) & !is.na(Color_Code), paste0(Style_Code,"-",Color_Code), NA)) # Nueva Columna: Material
#Concatenar: (Style_Code, "-", Color_Code) sin ninguno de las 2 columnas son 'NA'

# To-Do: Crear lista de Colores Huerfanos

# Exportar CSV ----
write.csv(Signal.Materiales, file = "db/Inventario_Signal_Materiales.csv", row.names = FALSE, na = "")

# SQLite ----
#Signal_Materiales <-  dbConnect(SQLite(), "db/sgnl.sqlite")
#dbWriteTable(Signal_Materiales, "Archivos.Signal", files_signal_guess)

#dbDisconnect()