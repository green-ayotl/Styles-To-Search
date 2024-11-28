# Transformar imagenes para utilizar como siluetas, para uso en reportes de excel
  ## A partir de un documento de excel
  ## Primera Columna: Codigo de material, así sera renombrado el archivo
    ## Nombre de la columna: Material
        ## Solo nombre de archivo, sin extension
    ## Segunda columna: Full Path de los archivos que se transformaran
      ## Nombre de la columna: Archivo
        ## Dirección local de donde se encuentran los archivos

  ## IMPORTANTE
      ### La lista de excel, solo debe contener la pestaña con la información que se menciona
      ### No debe tener valores repetidos
        ### Si necesitas la cara de varios materiales, agrega un sufijo para identificarlos
        ### Si se repite la ruta de los archivos, se reescribira y se perdera imagenes anteriores
      ### Por el momento solo se aceptan archivos [.jpg]

### Util: Cuando los archivos se encuentran en distintas carpetas
### Se se intemrrumpe el codigo, al seleccionar la misma lista de excel y carpeta destino, se continuara el proceso desde los archivos ya existentes
### Informa del proceso terminado en terminal

library(magick)
library(readxl)
library(dplyr)
library(writexl)

#Comentado: Archivo fijo

lista_excel <- "C:/Users/ecastellanos.ext/OneDrive - Axo/HandBags/Signal/Materiales Signal.xlsx"

#excel_sheet(lista_excel)

Signal_Handbags <- read_xlsx( path = lista_excel, sheet = "Signal HandBags")

resumen_año <- Signal_Handbags %>%  group_by(Signal_Handbags$Year) %>% summarise(conteo = n())
print(resumen_año) # Total de archivos

#resumen_frontales <- Signal_Handbags %>% filter(Cara == "F" | Cara == "RZ" | Cara == "F-") %>%  group_by(resumen_frontales$Year) %>% summarise((conteo = n()))
#print(resumen_frontales)


# Filtros para obtener frontales ----
año <- "2024" #Seleccionar año para crear caratulas

MN_signal_hb <- Signal_Handbags %>% filter(Departamento == "Mainline" & Year == año) %>% filter(Cara == "F")
print(paste0(
  "Hay un total de ", nrow(MN_signal_hb), " materiales en Mainline, con imagenes frontales, para el filtro general: ", año
))

SM_signal_hb <- Signal_Handbags %>% filter(Departamento == "Special Market (Factory)" & Year == año) %>% filter(Cara == "RZ" | Cara == "F-" | Cara == "F")
print(paste0(
  "Hay un total de ", nrow(SM_signal_hb), " materiales en Factory, con imagenes frontales, para el filtro general: ", año
))

#Anexar ambos departamentos
front_hb <- rbind(MN_signal_hb, SM_signal_hb)
#Quitar filas donde no hay código de color
front_hb <- front_hb %>% filter(!is.na(front_hb$Material))

# Legacy
#readline(
#  prompt = "Selecciona la carpeta donde se guardaran las imagenes, presiona [Enter]"
#)

# Parámetros Carpetas ----
#Carpetas objetivo, temp in order to copy to better path
dir_minis_year <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Minis/"

carpeta_destino <- paste0(dir_minis_year,año)

#Better Path for alt text in cell
dir_better_path <- "C:/HandBags/"

mini_better_path <- paste0(dir_better_path,año)


# Transformar archivo IMG ------
# Obtener archivos de carpeta destino para continuar donde proceso fue detenido

total <- nrow(front_hb)
minis <- tools::file_path_sans_ext(list.files( path = carpeta_destino, full.names = FALSE))

readline(
  prompt = "Presiona [Enter], para comenzar a procesar los materiales"
)

# Counters
skipped <- 0
procesado <- 0
counting <- 0

for (i in 1:nrow(front_hb)) {
#Test to find already processed
  if (any(front_hb$Material[i] == minis)) {
    print(paste0(
      "Ya se encuentra el archivo: ", front_hb$Material[i], "; ", counting, " de ", total, "; -Omitido-"
    ))
    skipped <- skipped + 1
  } else {
  IMG <- image_read( path = front_hb$`Full Name`[i])
  IMG <- image_trim(IMG) |> image_scale(200) |> image_write(path = paste0(carpeta_destino,"/",front_hb$Material[i],".jpg"))
  rm(IMG)
  Sys.sleep(2) #Disco almacenamiento se ocupa: descargar la imagen, escribirla y subirla, permite trabajar la cola de procesos
  print(paste0(front_hb$Material[i],"; ",counting," de ",total, "; -Procesado-"))
  procesado <- procesado + 1
  }
  counting <- counting + 1
  append(minis, front_hb$Material[i])
}

#Imprimir Resumen final del proceso

print(paste0(
  "Se procesaron ", procesado, " materiales. Se saltaron ", skipped, " materiales. Total en carpeta: ", counting
))

if (procesado == 0) {
  print("Nada nuevo procesado, bye")
  break
} else {
  next
}

readline(prompt = "Copiar a Better Path for Alt Text [Enter] para proceder")

# Replicar en better path ----
file.copy(carpeta_destino, dir_better_path, overwrite = TRUE, recursive = TRUE, copy.mode = FALSE, copy.date = TRUE)

# Lista de Materiales con full path para macro en excel
readline(prompt = "Archivo excel con lista de materiales y full path para macro [Enter]")

minis_path <- data.frame(Material =  tools::file_path_sans_ext(list.files(path = mini_better_path, full.names = FALSE)),
                         Archivo = list.files(path = mini_better_path, full.names = TRUE))

write_xlsx(minis_path, path = paste0(dir_better_path,año,".xlsx"), col_names = TRUE, format_headers = TRUE)

shell.exec(paste0(dir_better_path,año,".xlsx"))
