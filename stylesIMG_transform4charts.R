## Obtener imagenes para utilizar como siluetas para uso en reportes de excel
  ## A partir de un documento con

# Materiales para buscar en signal
  # - Imagen frontal, terminación [RZ]
  # -Unir Nombre Color (ingles) con clave Color [Material]
#Transformar para archivo Charts
 # - Trim espacio en blanco
 # - Comprimir 75 ppi para compartir
# Renombrar Archivos
 # - Colocar [Material] como nombre del archivo

library(magick)
library(readxl)
#library(filesstrings)

styles_to_search_IMGCharts <- read_xlsx( path = "C:/Users/ecastellanos.ext/OneDrive - Axo/Documentos/R Proyectos/SearchStyles_CopyFiles/Styles To Search - General.xlsx", sheet = "imgST_f")

#LEGACY #Signal <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Signal/SPECIAL MARKET/2024/FALL 24/ECOM"

#LEGACY #Signal <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/Signal/GUESS MAINLINE ECOM IMAGES/2024/243 - FALL 2024/Front"

carpeta_destino <- gsub("////","/",
                        readline(prompt = "Introduce la ruta donde se guardaran los archivos: "))

#LEGACY #Signal_files <- list.files( path = Signal, full.names = TRUE)


# Transformar archivo IMG
#carpeta_destino_files <- list.files( path = carpeta_destino, full.names = TRUE)
minis <- list.files( path = carpeta_destino, full.names = FALSE)

counting <- 1
total <- length(styles_to_search_IMGCharts$Archivo)

for (archivo in styles_to_search_IMGCharts$Archivo) {
  
  material <- styles_to_search_IMGCharts$Material[which(styles_to_search_IMGCharts$Archivo == archivo)]
  
  if ( any(material == minis) ) {
    print(paste0(
      "Ya se encuentra el archivo: ", material, "; ", counting, " de ", total
    ))
  } else {
  
  IMG <- image_read( path = archivo)
  IMG <- image_trim(IMG)
  IMG <- image_scale(IMG, 200)
  IMG <- image_write(IMG, path = paste0(carpeta_destino,"/",material))
  rm(IMG)
  
  print(paste0(material,"; ",counting," de ",total))
  }
  counting <- counting + 1
}

# For in styles_to_search$Archivo
  # 1 - Buscar Material por nombre de archivo
  # 2 - Cargar como imagen
    # 2.1 - Trim
    # 2.2 - Transformar, cambiar tamaño [image_resize(x, "tamaño")] y calidad [image_write(x, quality)]
    # image_write(image,path = NULL,format = NULL,quality = NULL,depth = NULL,density = NULL,comment = NULL,flatten = FALSE,defines = NULL,compression = NULL)
    # Image_wrte(path = paste0(carpeta_destino,filter(styleIMG_forCharts$Archivo >> MAterial)))