# Simple Point, Transform, Rename

library(readxl)
library(magick)

styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Liverpool (2)")

tamaño <- "940x1215"
dpi <- 72
extension <- ".jpg"

carpeta_final <- gsub("\\\\","/",
                      readline(prompt = "Introduce la ruta donde se guardaran los archivos: "))

canvas <- image_blank(width = 940, height = 1215, color = "white")
counting <- 1
for (i in 1:nrow(styles_to_search)) {
    full_name <- styles_to_search$`Full Name`[i]
    IMG <- image_read( path = full_name) |> image_trim(fuzz = 20) |> image_scale(tamaño)
    IMG <- image_composite(canvas, IMG, gravity = "Center") #Sanborns Transform
    image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension), density = dpi)
    print(paste0(styles_to_search$Rename[i], "; procesado: ", counting))
    counting <- counting + 1
}
