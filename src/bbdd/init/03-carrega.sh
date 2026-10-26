#!/bin/bash
# Carrega el CSV d'equipaments d'educació a la taula "educacio".
# Si el CSV no hi és, avisa però no atura MySQL (es pot carregar després).
set -e

CSV=/var/lib/mysql-files/equipaments_educacio.csv

if [ ! -f "$CSV" ]; then
  echo "AVÍS: no s'ha trobat $CSV. Executa scripts/descarregar_csv.sh i carrega'l després."
  return 0 2>/dev/null || exit 0
fi

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" equipaments <<SQL
LOAD DATA INFILE '$CSV'
INTO TABLE educacio
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(register_id, name, institution_id, institution_name, created, modified,
 addresses_roadtype_id, addresses_roadtype_name, addresses_road_id, addresses_road_name,
 addresses_start_street_number, addresses_end_street_number,
 addresses_neighborhood_id, addresses_neighborhood_name,
 addresses_district_id, addresses_district_name, addresses_zip_code, addresses_town,
 addresses_main_address, addresses_type,
 values_id, values_attribute_id, values_category, values_attribute_name,
 values_value, values_outstanding, values_description,
 secondary_filters_id, secondary_filters_name, secondary_filters_fullpath,
 secondary_filters_tree, secondary_filters_asia_id,
 geo_epgs_25831_x, geo_epgs_25831_y, geo_epgs_4326_lat, geo_epgs_4326_lon);
SQL

echo "CSV carregat: $(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -N -e 'SELECT COUNT(*) FROM equipaments.educacio') files."
