#!/bin/bash
# Crea els usuaris de MySQL. És un .sh (i no un .sql) per poder llegir
# les contrasenyes de les variables d'entorn, que venen del fitxer .env.
set -e

if [ -z "$WEBAPP_PASSWORD" ]; then
  echo "ERROR: cal definir WEBAPP_PASSWORD al fitxer .env" >&2
  exit 1
fi

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
-- Usuari exigit per l'enunciat (administració)
CREATE USER IF NOT EXISTS 'bchecker'@'%' IDENTIFIED BY 'bchecker121';
GRANT ALL PRIVILEGES ON equipaments.* TO 'bchecker'@'%';

-- Usuari de l'aplicació web: només lectura
CREATE USER IF NOT EXISTS 'webapp'@'${WEBAPP_HOST}' IDENTIFIED BY '${WEBAPP_PASSWORD}';
GRANT SELECT ON equipaments.* TO 'webapp'@'${WEBAPP_HOST}';

FLUSH PRIVILEGES;
SQL
