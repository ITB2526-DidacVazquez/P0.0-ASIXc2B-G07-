#!/bin/bash
# Descarrega el CSV d'equipaments d'educació de l'Open Data BCN i el deixa
# a src/bbdd/csv/ preparat per a MySQL (UTF-8 i finals de línia Unix).
# Ús (des de l'arrel del repositori o des de src/):  bash src/scripts/descarregar_csv.sh
set -e

URL="https://opendata-ajuntament.barcelona.cat/data/dataset/f36b60f2-9541-4d08-b0f9-b0a9313fab3d/resource/29d9ff10-6892-4f16-9012-d5c4997857e7/download"
DIR="$(cd "$(dirname "$0")/.." && pwd)/bbdd/csv"
CSV="$DIR/equipaments_educacio.csv"

mkdir -p "$DIR"
echo "Descarregant CSV..."
wget -q -O "$CSV.tmp" "$URL"

# Alguns CSV de l'Open Data BCN venen en UTF-16: els passem a UTF-8
if file "$CSV.tmp" | grep -qi "UTF-16"; then
  echo "Convertint de UTF-16 a UTF-8..."
  iconv -f UTF-16 -t UTF-8 "$CSV.tmp" > "$CSV.tmp2" && mv "$CSV.tmp2" "$CSV.tmp"
fi

# Treu els finals de línia de Windows (\r)
sed -i 's/\r$//' "$CSV.tmp"
mv "$CSV.tmp" "$CSV"

echo "Fet: $CSV"
echo "Files (sense capçalera): $(($(wc -l < "$CSV") - 1))"
echo "Capçalera:"
head -1 "$CSV"
