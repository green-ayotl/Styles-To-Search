# Simple Point, Transform, Rename

library(readxl)

styles_to_search <- read_excel("Styles To Search - General.xlsx", sheet = "Amazon (2)")

tamaño <- "1600x1600"
dpi <- 72
extension <- ".jpg"

carpeta_final <- gsub("\\\\","/",
                      readline(prompt = "Introduce la ruta donde se guardaran los archivos: "))
counting <- 1
for (i in 1:nrow(styles_to_search)) {
    full_name <- styles_to_search$`Full Name`[i]
    IMG <- image_read( path = full_name) |> image_trim() |> image_scale(tamaño)
    image_write(IMG, path = paste0(carpeta_final,"/",styles_to_search$Rename[i],extension), density = dpi)
    print(paste0(styles_to_search$Rename[i], "; conteo: ", counting))
    counting <- counting + 1
}
