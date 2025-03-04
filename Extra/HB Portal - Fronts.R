# ---- Inicio, descripcción
# Script para transferir imagenes frontales del departamento de bolsas para el portal de tiendas

#Información necesaria
  # Lista de Precios


# ---- Activar librerias 
library(dplyr)
library(DBI)
library(RSQLite)

# ---- Parametros Generales ----
#año_busqueda <- 2025 # Legacy # It's over
años_exportacion <- c(2023, 2024, 2025) # This change everything
departamento_handbags <- c("Handbags","Handbags Factory")

#Carpeta compartida
imagenes_signal <- "C:/Users/ecastellanos.ext/OneDrive - Axo/IMAGENES SIGNAL/"

# ---- Cargar información: Lista de Precios ----

SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
lista_precios <- dbReadTable(SQLite.Guess_HB, "Lista.Precios") # AXO_pc
dbDisconnect(SQLite.Guess_HB)

# ---- Cargar información: Inventario Signal ----
SQLite.Guess_HB <- dbConnect(SQLite(), "db/guess_hb.sqlite")
Inventario.Signal.Materiales <- dbReadTable(SQLite.Guess_HB, "Materiales.Signal") %>% 
  filter(Cara == "F" | Cara == "RZ") %>% 
  select(c(Material,
           Full_Path))
dbDisconnect(SQLite.Guess_HB)

# Filtro Lista de Precios ----

precios <- lista_precios %>% 
  select(c(Material, Temporada, Departamento, Año)) %>% 
  filter(Año %in% años_exportacion) %>% 
  filter(Departamento %in% departamento_handbags)

# Unir Lista Precios (año procesar) con Inventario Materiales ----

materiales <- inner_join(precios, Inventario.Signal.Materiales, by = "Material", keep = FALSE) %>% 
  distinct(Material, .keep_all = TRUE) %>% 
  mutate(Extension = tools::file_ext(Full_Path)) %>% 
  mutate(Rename = paste0(Material,".",Extension))

# Legacy code ----
# Contadores
#copiado <- 1
#skipped <- 0
#procesado <- 1
#carpeta_destino <- paste0(imagenes_signal,año_busqueda,"/") # Cambiar de acuerdo a cada año
#lista_carpeta <- list.files(path = carpeta_destino, full.names = FALSE) %>% str_extract("^[^.]+")
#total <- nrow(materiales)


# Legacy ----
# Copiar en carpeta compartida ---
#for (i in 1:nrow(materiales)) {
#  if (any(lista_carpeta == materiales$Material[i])) {
#    #Material ya se encuentra en la carpeta destino
#    print(paste0(
#      "Material: ",materiales$Material[i]," -omitido-; [",procesado,"/",total,"]"
#    ))
#    skipped <- skipped + 1
#  } else {
#  # Copiar material, no se encuentra en la carpeta destino
#  file.copy(
#    from = materiales$Full_Path[i],
#    to =  paste0(carpeta_destino, materiales$Rename[i]),
#    overwrite = FALSE,
#    copy.date = FALSE)
#    
#    copiado <- copiado + 1
#    
#    print(paste0(
#      "Material: ",materiales$Material[i]," -copiado-; [",procesado,"/",total,"]"
#    ))
#    Sys.sleep(1)
#  }
#  procesado <- procesado +1
#}

# Copiar en carpeta compartida ----

for (i in 1:length(años_exportacion)) {
  
  # Obtener lista de cada año
  temp_year <- años_exportacion[i]
  carpeta_destino <- paste0(imagenes_signal,temp_year,"/")
  
  materiales_anuales <- materiales %>% filter(Año == temp_year) %>% mutate(Destino = paste0(carpeta_destino, Rename))
  totales <- nrow(materiales_anuales)
  contador <- 1
  
    # Copiar a carpeta destino
  for (h in 1:nrow(materiales_anuales)) {
    #Lista de ya en carpeta
    lista_carpeta <- tools::file_path_sans_ext(list.files(path = carpeta_destino, full.names = FALSE))
        
    if (any(lista_carpeta == materiales_anuales$Material[h])) {
      print(paste0(
        "Material: ", materiales_anuales$Material[h], " -Omitido- [",contador,"/",totales,"]"
      ))
    } else {
      
      file.copy(from = materiales_anuales$Full_Path[h],
                to = materiales_anuales$Destino[h])
      print(paste0(
        "Material: ", materiales_anuales$Material[h], " -Copiado- [",contador,"/",totales,"]"        
      ))
      Sys.sleep(0.1)
    }
    contador <- contador + 1

  }
}

# End of script
