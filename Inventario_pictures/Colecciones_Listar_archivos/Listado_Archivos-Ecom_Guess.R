# Inicio ----
  # Búsqueda de activos digitales en el flujo de trabajo de Guess Ecom para el departamento de bolsas mainline

# Librerias ----

library(tidyverse)
library(data.table)
library(DBI)
library(RSQLite)
library(stringr)
library(here)

# Parámetros Globales ----
source(here("Global.R"))

# Parámetros Flujo ----
# Extensión de archivos a listar
extensiones_imagenes <- global_config$archivo_imagen %>% as.vector()

# Búsqueda especializada en eCom Guess ----
ecom_guess_dir <- global_config$sharepoint_guess.ecom

# Crear lista de archivos -> string match desde lista de precios en el nombre del archivo, identificar materiales en la carpeta de ecom guess
ecom_files <- data.table(Full_Path = list.files(ecom_guess_dir, pattern = extensiones_imagenes, full.names = TRUE, recursive = TRUE),
                         Album = "Ecom Guess") |> mutate(File.Name = basename(Full_Path))

# Limpieza de duplicados con referencia: "MXSCHLC"
ecom_files <- ecom_files[!grepl("MXSCHLC", File.Name), ]
ecom_files <- ecom_files[!grepl("MXSCHCL", File.Name), ]

# Limpieza archivos no utiles (En flujos intermedio de ECOM Guess)
ecom_files <- ecom_files[!grepl("MXSCHCL", File.Name), ]

# Busqueda de Materiales en Ecom Guess ----

# Cargar Lista de materiales para bolsas
SQLite.Guess_HB <- dbConnect(SQLite(), here("db","guess_hb.sqlite"))
materiales_hb <- dbReadTable(SQLite.Guess_HB, "Lista.Precios") %>% 
  filter(Departamento == "Handbags") %>% select(c("Material", "Año")) %>% #Solo Mainline, test realizado: no material de HB Factory encontrado
  arrange(Año) %>%  
  filter(Año >= 2021) #Solo contamos con carpetas de ECOM Guess desde 2021
dbDisconnect(SQLite.Guess_HB)


#Crear tabla para concatenar encontrados
ecom_guess_materiales_identificacion <- data.table(Full_Path = as.character(),
                                    Album = as.character(),
                                    File.Name = as.character(),
                                    Material = as.character())

#contadores
total_ecom_guess <- nrow(materiales_hb)
procesado_ecom_guess <- 1


for (i in 1:nrow(materiales_hb)) {
  material_match <- ecom_files %>% filter(str_detect(ecom_files$File.Name, materiales_hb$Material[i])) %>% mutate(Material = materiales_hb$Material[i])
  ecom_guess_materiales_identificacion <- rbind(ecom_guess_materiales,material_match)
  ifelse(nrow(material_match) != 0,
         print(paste0(
           "Material: ", materiales_hb$Material[i]," encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]" 
         )),
         print(paste0(
           "Material: ",materiales_hb$Material[i]," no encontrado [",procesado_ecom_guess,"/",total_ecom_guess,"]"
         )))

  procesado_ecom_guess <- procesado_ecom_guess + 1
}

ecom_guess_materiales <- ecom_guess_materiales_identificacion %>% 
  mutate(ISO = ifelse(str_detect(File.Name, "ISO"), "ISO", "-")) %>% 
  mutate(Principal_ecom = ifelse(str_detect(File.Name, "PLANO"), "Principal", "-")) %>% 
  mutate(ALT1 = ifelse(str_detect(File.Name, "ALT1"), "ALT1", "-")) %>% 
  mutate(ALT2 = ifelse(str_detect(File.Name, "ALT2"), "ALT2", "-")) %>% 
  mutate(ALT3 = ifelse(str_detect(File.Name, "ALT3"), "ALT3", "-")) %>% 
  mutate(ALT4 = ifelse(str_detect(File.Name, "ALT4"), "ALT4", "-"))

# SQLite ----

Files.HB_Guess <- dbConnect(SQLite(), here("db","file_list.sqlite")) # db para lista de archivos
dbWriteTable(Files.HB_Guess, "ECOM.Guess", ecom_files)
dbDisconnect(Files.HB_Guess)

SQLite.Guess_Materiales <- dbConnect(SQLite(), here("db","guess_hb_materiales.sqlite")) #Solo para lista de materiales disponibles
dbWriteTable(SQLite.Guess_Materiales, "ECOM.Guess.Materiales", ecom_guess_materiales)
dbDisconnect(SQLite.Guess_Materiales)

# Limpiar ambiente ----
