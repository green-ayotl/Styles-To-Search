# Renombrador para los Shotting de privalia, integrarlo a nuestro inventario

# Parametros ----

archivos_img <- c(".jpg", "png")

# Carpetas 

carpeta_shotting <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Privalia Shotting Transformar/"
  
carpeta_commerce.general <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Commerce_General/"

# Lista de carpetas de privalia con su nombre de material correspondiente
privalia_materiales <- data.frame(Directorios = list.dirs(carpeta_shotting, recursive = FALSE) |> paste0("/"),
                                  Material = list.dirs(carpeta_shotting, full.names = FALSE, recursive = FALSE))

# Logs, material y numero de archivos por material
logs <- data.frame(material = as.character(),
                   archivos_copiados = as.numeric())

# Loop a travez de carpetas privalia
for (i in 1:nrow(privalia_materiales)) {
  
  # Listado de archivo de tal carpeta/material
  directorio_material <- data.frame(File_Name = tools::file_path_sans_ext(list.files(privalia_materiales$Directorios[i], pattern = archivos_img)),
                                    Full_Path = list.files(privalia_materiales$Directorios[i], pattern = archivos_img, full.names = TRUE))
  directorio_material$File_ext <- tools::file_ext(directorio_material$Full_Path)
  
  # Asegurar orden en nombre de archivo para próximo paso renombre
  directorio_material <- directorio_material[order(directorio_material$File_Name), ]
  
  # Nueva columna de sufijo de variante                                  
  directorio_material$Sufijo.Variante <- NA
  directorio_material$Sufijo.Variante[1] <- "F"
  directorio_material$Sufijo.Variante[2:nrow(directorio_material)] <- paste0("ALT", 1:(nrow(directorio_material)-1))
  
  directorio_material$Renombre <- paste0(privalia_materiales$Material[i], "-", directorio_material$Sufijo.Variante)
  
  directorio_material$New_Full_Path <- paste0(carpeta_commerce.general, directorio_material$Renombre,".", directorio_material$File_ext)
  
  #Copiar archivos de material en especifico
  for (h in 1:nrow(directorio_material)) {
    file.copy(from = directorio_material$Full_Path[h],
              to = directorio_material$New_Full_Path[h])
    #print(paste0("Archivo: ", directorio_material$Renombre[h], " [copiado]")) #verbose
  }
  
  print(paste0("Material: ", privalia_materiales$Material[i], ", archivos copiados: ", nrow(directorio_material)))
  
  logs[i, 1] <- privalia_materiales$Material[i]
  logs[i, 2] <- nrow(directorio_material)
}

#Limpiar carpeta para proximos shottings ----
#unalive_dirs <- readline("Eliminar carpetas en /Privalia Shotting Transformar/ [Y o N]")
#if (unalive_dirs == "Y") {
#  for (w in 1:nrow(privalia_materiales)) {
#    unlink(privalia_materiales$Directorios[w], recursive = TRUE)
#    print(paste0("Carpeta de material: ", privalia_materiales$Material[w], " borrado."))
#  }
#} else if(unalive_dirs == "N"){
#  print("Ninguna carpeta borrada")
#}

View(logs) #Al final de script mostrar los materiales y archivos copíados
sum(logs$archivos_copiados) #Total de imagenes