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

readline(
  prompt = "Selecciona la lista en excel, presiona [Enter]"
)
lista_excel <- file.choose()

readline(
  prompt = "Selecciona la carpeta donde se guardaran las imagenes, presiona [Enter]"
)
carpeta_destino <- gsub("\\\\","/",choose.dir())

styles_to_search_IMGCharts <- read_xlsx(lista_excel)

# Transformar archivo IMG
# Obtener archivos de carpeta destino para continuar donde proceso fue detenido

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
  IMG <- image_write(IMG, path = paste0(carpeta_destino,"/",material,".jpg"))
  rm(IMG)
  
  print(paste0(material,"; ",counting," de ",total))
  }
  counting <- counting + 1
}
