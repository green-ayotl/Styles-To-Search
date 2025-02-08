# Preface ----

#Listado de archivos de la colección desde signal en todos los departamentos
  #Guarda en su correspondiente SQLite, la lista ampliada de archivos
    #Para su utilización en flujos consecutivos de trabajo
  #Al final: Limpia los elementos del ambiente global
#Aislamiento de procesos: acId

# Origen Carpeta Signal en ShareFile ----
sharefile_drive = "S:/Carpetas/" # Carpeta default para programa escritorio de sharefile

# Listado de departamentos
departamentos_guess_signal <- data.frame(Departamento = c(
  "Mainline", "Factory", "Mens"),
  Directorio = c("GUESS MAINLINE ECOM IMAGES", "SPECIAL MARKETS ECOM", "GUESS MENS ECOM"))

# Tabla vacia para agregar la lista de archivos
files_signal_guess <- data.frame(Full_Path = as.character(),
                                 Departamento_Signal = as.character())

# Escaneo de archivos ----
# Mejorar Scaneo de archivos por año, para scaneo rapido (temporada/año actual)
for(i in departamentos_guess_signal$Directorio){
  comienzo = Sys.time()
  files_signal_guess <- rbind(files_signal_guess, data.frame(Full_Path = list.files(path = paste0(sharefile_drive,i,"/"), full.names = TRUE, recursive = TRUE),
                                                             Departamento_Signal = i))
  print(paste0("Departamento: ",i," inventariado"))
  print("Tiempo procesado: ")
  print(Sys.time() - comienzo)
}

#Agregar Columna: File_Name y File_Ext
files_signal_guess <- mutate(files_signal_guess, File_Name = file_path_sans_ext(str_extract(files_signal_guess$Full_Path, "[^/]*$"))) %>% 
  mutate(File_Ext = file_ext(str_extract(files_signal_guess$Full_Path, "[^/]*$")))

# SQLite ----
Files.HB_Guess <- dbConnect(SQLite(), "db/file_list.sqlite") # db para lista de archivos
dbWriteTable(Files.HB_Guess, "Signal", files_signal_guess, overwrite = TRUE)
dbDisconnect(Files.HB_Guess)

# Limpiar ambiente
rm(departamentos_guess_signal,
   files_signal_guess,
   Files.HB_Guess,
   comienzo,
   i,
   sharefile_drive)
