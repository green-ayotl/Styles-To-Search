# ---- Inicio, descripcción
# Script para transferir imagenes frontales del departamento de bolsas para el portal de tiendas

#Información necesaria
  # Lista de Precios


# ---- Activar librerias 
library(readxl)
library(dplyr)
library(stringr)
library(DBI)
library(RSQLite)

# ---- Parametros Generales ----
año_busqueda <- 2025 # Cambiar año para copiar a la colección, permite hacer background job con ambiente independiente
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
  rename(Material = Código.de.estilo,
         Temporada = Código.de.Temporada,
         Departamento = Etiqueta.de.grupo.de.jerarquía.Department.,
         ) %>% select(c(Material, Temporada, Departamento, Año)) %>% 
  filter(Año == año_busqueda) %>% 
  filter(Departamento %in% departamento_handbags)

# Unir Lista Precios (año procesar) con Inventario Materiales ----

materiales <- inner_join(precios, Inventario.Signal.Materiales, by = "Material", keep = FALSE) %>% 
  distinct(Material, .keep_all = TRUE) %>% 
  mutate(Extension = tools::file_ext(Full_Path)) %>% 
  mutate(Rename = paste0(Material,".",Extension))

# Contadores
copiado <- 1
skipped <- 0
procesado <- 1
carpeta_destino <- paste0(imagenes_signal,año_busqueda,"/")
lista_carpeta <- list.files(path = carpeta_destino, full.names = FALSE) %>% str_extract("^[^.]+")
total <- nrow(materiales)

# Copiar en carpeta compartida ----
for (i in 1:nrow(materiales)) {
  if (any(lista_carpeta == materiales$Material[i])) {
    #Material ya se encuentra en la carpeta destino
    print(paste0(
      "Material: ",materiales$Material[i]," -omitido-; [",procesado,"/",total,"]"
    ))
    skipped <- skipped + 1
  } else {
  # Copiar material, no se encuentra en la carpeta destino
  file.copy(
    from = materiales$Full_Path[i],
    to =  paste0(carpeta_destino, materiales$Rename[i]),
    overwrite = FALSE,
    copy.date = FALSE)
    
    copiado <- copiado + 1
    
    print(paste0(
      "Material: ",materiales$Material[i]," -copiado-; [",procesado,"/",total,"]"
    ))
    Sys.sleep(1)
  }
  procesado <- procesado +1
}

