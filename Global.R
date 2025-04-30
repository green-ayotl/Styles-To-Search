
# Librerías ----
library(here)

# Cargar archivo de configuración ----
config_yaml <- here("config.yaml")

global_config <- yaml::read_yaml(config_yaml)

rm(config_yaml) # Limitar objetos en ambiente para otros flujos que cargan la configuración desde este archivo