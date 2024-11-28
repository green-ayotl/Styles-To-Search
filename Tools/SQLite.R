#SQLite Lista de Archivos

library(RSQLite)

# 1. Conexión de base de datos
Lista_materiales <- dbConnect(SQLite(), "db_listfiles_HB")

# 2. Creación de tabla
dbExecute(Lista_materiales, "CREATE TABLE IF NOT EXISTS MATERIALES (
          id INTEGER PRIMARY KEY,
          ruta_completa TEXT,
          nombre_archivo TEXT,
          nombre_corto TEXT,
          estilo TEXT,
          colour TEXT,
          silueta TEXT,
)")