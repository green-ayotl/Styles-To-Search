#Eduardo Castellanos C.
#27 Nov 24
#R version 4.3.3 x86_64-w64-mingw32

# ---- Intro Photoroom integration

# ---- Paqueterias necesarias
#Instalacion
install.packages("httr2")

# Cargar librerías
library(httr2)

# ---- Parametros

api_key <- readline(prompt = "Ingresa API KEY")

carpeta_origen <- -gsub("\\\\","/", choose.dir(caption = "Carpeta origen: "))

carpeta_destino <- -gsub("\\\\","/", choose.dir(caption = "Carpeta destino: "))

# ---- Funcionales

# Función para enviar imagen a la API de segmentación
segment_image <- function(image_path, api_key, output_path) {
  # Crear la solicitud
  request <- request("https://sdk.photoroom.com/v1/segment") |>
    req_method("POST") |>
    req_headers(
      # Agregar el token de autenticación
      "x-api-key" = api_key
    ) |>
    req_body_multipart(
      # Enviar el archivo de imagen
      image_file = curl_file(image_path)
    )
  
  # Ejecutar la solicitud
  response <- req_perform(request)
  
  # Verificar si la solicitud fue exitosa
  if (resp_status(response) == 200) {
    # Guardar la imagen resultante
    writeBin(resp_body_raw(response), output_path)
    message("Imagen segmentada guardada exitosamente")
    return(TRUE)
  } else {
    # Manejar errores
    stop("Error en la solicitud de API: ", resp_status(response))
  }
}

# Ejemplo de uso
api_key <- "sandbox_d18e888f113697bdcd618449b95521c0d533cc56"
input_image <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/estilo.jpg"
output_image <- "C:/Users/ecastellanos.ext/OneDrive - Axo/Imágenes/estilo_result.png"

# Llamar a la función
segment_image(input_image, api_key, output_image)
