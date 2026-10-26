-- Estructura de la BBDD "equipaments"
-- MySQL executa els fitxers d'aquesta carpeta per ordre alfabètic,
-- NOMÉS la primera vegada (quan bbdd/data/ està buida).

CREATE DATABASE IF NOT EXISTS equipaments
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE equipaments;

-- Una columna per cada camp del CSV d'equipaments d'educació, en el mateix ordre.
-- Si la capçalera del CSV (head -1) no coincideix, cal ajustar aquesta llista
-- i també la de 03-carrega.sh.
CREATE TABLE IF NOT EXISTS educacio (
  id                             INT AUTO_INCREMENT PRIMARY KEY,
  register_id                    VARCHAR(50),
  name                           VARCHAR(255),
  institution_id                 VARCHAR(50),
  institution_name               VARCHAR(255),
  created                        VARCHAR(50),
  modified                       VARCHAR(50),
  addresses_roadtype_id          VARCHAR(50),
  addresses_roadtype_name        VARCHAR(100),
  addresses_road_id              VARCHAR(50),
  addresses_road_name            VARCHAR(255),
  addresses_start_street_number  VARCHAR(20),
  addresses_end_street_number    VARCHAR(20),
  addresses_neighborhood_id      VARCHAR(20),
  addresses_neighborhood_name    VARCHAR(100),
  addresses_district_id          VARCHAR(20),
  addresses_district_name        VARCHAR(100),
  addresses_zip_code             VARCHAR(10),
  addresses_town                 VARCHAR(100),
  addresses_main_address         VARCHAR(10),
  addresses_type                 VARCHAR(100),
  values_id                      VARCHAR(50),
  values_attribute_id            VARCHAR(50),
  values_category                VARCHAR(100),
  values_attribute_name          VARCHAR(255),
  values_value                   VARCHAR(255),
  values_outstanding             VARCHAR(10),
  values_description             TEXT,
  secondary_filters_id           VARCHAR(50),
  secondary_filters_name         VARCHAR(255),
  secondary_filters_fullpath     VARCHAR(500),
  secondary_filters_tree         VARCHAR(50),
  secondary_filters_asia_id      VARCHAR(50),
  geo_epgs_25831_x               VARCHAR(30),
  geo_epgs_25831_y               VARCHAR(30),
  geo_epgs_4326_lat              VARCHAR(30),
  geo_epgs_4326_lon              VARCHAR(30)
);
