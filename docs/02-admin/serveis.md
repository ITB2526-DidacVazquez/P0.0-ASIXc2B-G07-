# ⚙️ Guia de serveis

> Configuració de cada servei de la infraestructura.
> Prerequisit: xarxa i Docker configurats segons [MVP_sprint1_infraestructura-config.md](MVP_sprint1_infraestructura-config.md).
> On va cada servei i per què: [arquitectura.md](arquitectura.md).

## Índex

0. [Estat dels serveis](#0-estat-dels-serveis)
1. [Usuari comú `bchecker`](#1-usuari-comú-bchecker)
2. [SSH](#2-ssh)
3. [Servidor web (`W-NCC`)](#3-servidor-web-w-ncc)
4. [Base de dades (`B-NCC`)](#4-base-de-dades-b-ncc)
5. [DHCP](#5-dhcp)
6. [DNS (`D-NCC`)](#6-dns-d-ncc)
7. [FTP (`F-NCC`)](#7-ftp-f-ncc)
8. [Aplicació web de consulta](#8-aplicació-web-de-consulta)
9. [Monitor de xarxa](#9-monitor-de-xarxa)
10. [NAT (sortida a Internet)](#10-nat-sortida-a-internet)

---

## 0. Estat dels serveis

| Servei | Hostname | Servidor | IP | Port(s) | Estat |
| :--- | :--- | :--- | :--- | :--- | :-: |
| SSH | — | Tots els servidors | — | 22/tcp | ⏳ |
| Web | `W-NCC` | `Dockers-DMZ` | `172.29.88.10` | 80, 443/tcp | ✅ (MVP) |
| FTP | `F-NCC` | `Dockers-DMZ` | `172.29.88.10` | 21, 21000-21010/tcp | ✅ (MVP) |
| BBDD | `B-NCC` | `Docker-B-NCC` | `172.29.89.10` | 3306/tcp | ✅ (MVP, sense dades) |
| DNS | `D-NCC` | `Dockers-Intranet` | `172.29.99.10` | 53/tcp+udp | ✅ (MVP, sense zona) |
| Monitor | — | `Dockers-Intranet` | `172.29.99.10` | 3001/tcp | ⏳ |
| DHCP | `R-NCC` | Router | `172.29.99.1` | 67/udp | ⏳ |
| NAT | `R-NCC` | Router | — | — | ⏳ |

> Al MVP del Sprint 1 tots els contenidors eren a la mateixa VM (`172.29.88.10`). Amb l'arquitectura final es reparteixen en tres servidors.

✅ desplegat · ⏳ pendent

---

## 1. Usuari comú `bchecker`

L'enunciat exigeix que **tots els sistemes i aplicacions** tinguin l'usuari:

| Usuari | Contrasenya |
| :--- | :--- |
| `bchecker` | `bchecker121` |

| Sistema | Com es crea |
| :--- | :--- |
| Servidors Linux i `Client-Lin` | `useradd` (vegeu a sota) |
| `Client-Win` (Windows) | `New-LocalUser` (vegeu a sota) |
| MySQL (`B-NCC`) | [secció 4.3](#43-usuari-bchecker-a-mysql) |
| FTP (`F-NCC`) | variable `USERS` del contenidor ([secció 7](#7-ftp-f-ncc)) |
| Monitor de xarxa | usuari administrador creat al primer accés ([secció 9](#9-monitor-de-xarxa)) |

**Linux:**

```bash
sudo useradd -m -s /bin/bash bchecker
echo 'bchecker:bchecker121' | sudo chpasswd
sudo usermod -aG sudo bchecker
```

**Windows** (PowerShell com a Administrador):

```powershell
$pw = ConvertTo-SecureString "bchecker121" -AsPlainText -Force
New-LocalUser -Name "bchecker" -Password $pw -FullName "bchecker" -PasswordNeverExpires
Add-LocalGroupMember -Group "Administradors" -Member "bchecker"   # "Administrators" si el SO és en anglès
```

> ⚠️ Aquesta contrasenya la fixa l'enunciat per a la correcció. És l'**única** credencial que es pot escriure al repositori; la resta van al fitxer `src/.env`, que no es puja.

---

## 2. SSH

### 2.1 Servidor SSH (a cada servidor Linux)

```bash
sudo apt update && sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

Configuració recomanada a `/etc/ssh/sshd_config.d/10-asix.conf`:

```text
PermitRootLogin no
PasswordAuthentication yes     # necessari perquè bchecker pugui entrar amb contrasenya
PubkeyAuthentication yes
```

```bash
sudo systemctl restart ssh
```

### 2.2 Connexió des dels clients

```bash
ssh bchecker@172.29.88.10         # Dockers-DMZ (Web/FTP)
ssh bchecker@172.29.99.10         # Dockers-Intranet (DNS/Monitor)

# La BBDD no és accessible des de la Intranet: s'hi entra passant pel servidor de la DMZ
ssh -J bchecker@172.29.88.10 bchecker@172.29.89.10
```

Des de Windows 10/11 es pot fer igual des de PowerShell (el client OpenSSH ve instal·lat).

### 2.3 Accés per clau (administradors)

```bash
# Al client
ssh-keygen -t ed25519 -C "admin@asix"
ssh-copy-id bchecker@172.29.88.10
```

> La clau SSH per autenticar el servidor contra **GitHub** es documenta a [git_workflow.md](git_workflow.md#2-autenticació-amb-clau-ssh).

---

## 3. Servidor web (`W-NCC`)

Contenidor `richarvey/nginx-php-fpm` que serveix el contingut de `/var/www/html`. Per poder versionar l'aplicació, es munta el directori `src/app` del repositori:

```yaml
  web:
    image: richarvey/nginx-php-fpm:latest
    container_name: W-NCC
    ports:
      - "80:80/tcp"
      - "443:443/tcp"
    volumes:
      - ./app:/var/www/html
    restart: always
```

Comprovació:

```bash
curl -I http://172.29.88.10
curl -I http://w-ncc.asix.local
```

---

## 4. Base de dades (`B-NCC`)

### 4.1 Dades d'origen

**Llistat d'equipaments d'educació de la ciutat de Barcelona** (Open Data BCN):

- Fitxa: <https://opendata-ajuntament.barcelona.cat/data/es/dataset/equipament-educacio/resource/29d9ff10-6892-4f16-9012-d5c4997857e7>
- Descàrrega directa (CSV): <https://opendata-ajuntament.barcelona.cat/data/dataset/f36b60f2-9541-4d08-b0f9-b0a9313fab3d/resource/29d9ff10-6892-4f16-9012-d5c4997857e7/download>

```bash
mkdir -p src/bbdd && cd src/bbdd
wget -O equipaments_educacio.csv \
  "https://opendata-ajuntament.barcelona.cat/data/dataset/f36b60f2-9541-4d08-b0f9-b0a9313fab3d/resource/29d9ff10-6892-4f16-9012-d5c4997857e7/download"

file equipaments_educacio.csv     # comprova la codificació
head -1 equipaments_educacio.csv  # comprova les columnes
```

> ⚠️ Alguns CSV de l'Open Data BCN venen en **UTF-16**. Si `file` no diu `UTF-8`, converteix-lo:
> `iconv -f UTF-16 -t UTF-8 equipaments_educacio.csv > equipaments_utf8.csv`

### 4.2 Creació de la BBDD i càrrega

Fitxer `src/bbdd/01_schema.sql`:

```sql
CREATE DATABASE IF NOT EXISTS equipaments
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE equipaments;

-- Una columna per cada camp del CSV, en el mateix ordre.
-- Si la capçalera del CSV (head -1) no coincideix, cal ajustar aquesta llista.
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
```

Fitxer `src/bbdd/02_load.sql`:

```sql
USE equipaments;

LOAD DATA INFILE '/var/lib/mysql-files/equipaments_educacio.csv'
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
```

Execució (la imatge `mysql:8.0` només permet `LOAD DATA INFILE` des de `/var/lib/mysql-files/`):

```bash
cd src/bbdd
sudo docker cp equipaments_educacio.csv B-NCC:/var/lib/mysql-files/
sudo docker exec -i B-NCC mysql -uroot -p < 01_schema.sql
sudo docker exec -i B-NCC mysql -uroot -p < 02_load.sql
```

> Si el CSV té finals de línia de Windows, canvia `LINES TERMINATED BY '\n'` per `'\r\n'`.

### 4.3 Usuari `bchecker` a MySQL

Fitxer `src/bbdd/03_users.sql`:

```sql
-- Usuari exigit per l'enunciat (administració)
CREATE USER IF NOT EXISTS 'bchecker'@'%' IDENTIFIED BY 'bchecker121';
GRANT ALL PRIVILEGES ON equipaments.* TO 'bchecker'@'%';

-- Usuari de l'aplicació web: només lectura i només des del servidor de la DMZ
CREATE USER IF NOT EXISTS 'webapp'@'172.29.89.1' IDENTIFIED BY 'canvia_aquesta_clau';
GRANT SELECT ON equipaments.* TO 'webapp'@'172.29.89.1';

FLUSH PRIVILEGES;
```

```bash
sudo docker exec -i B-NCC mysql -uroot -p < 03_users.sql
```

### 4.4 Comprovació

```bash
sudo docker exec -it B-NCC mysql -ubchecker -pbchecker121 -e \
  "SELECT COUNT(*) FROM equipaments.educacio;
   SELECT name, addresses_district_name FROM equipaments.educacio LIMIT 5;"
```

### 4.5 Persistència

Per no perdre les dades si es recrea el contenidor, afegeix un volum al `docker-compose.yml`:

```yaml
  db:
    image: mysql:8.0
    container_name: B-NCC
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "3306:3306/tcp"
    volumes:
      - db_data:/var/lib/mysql
    restart: always

volumes:
  db_data:
```

---

## 5. DHCP

El servidor DHCP s'executa al router `R-NCC` i reparteix adreces a la **Intranet** (`enp3s0`). Els servidors tenen IP fixa per sota de `.100`, fora del rang dinàmic. La configuració equivalent per a Packet Tracer és a [arquitectura.md](arquitectura.md#8-configuració-del-router-a-packet-tracer).

```bash
sudo apt install -y kea-dhcp4-server
```

Fitxer `/etc/kea/kea-dhcp4.conf`:

```json
{
  "Dhcp4": {
    "interfaces-config": { "interfaces": [ "enp3s0" ] },
    "lease-database": { "type": "memfile", "persist": true,
                        "name": "/var/lib/kea/kea-leases4.csv" },
    "valid-lifetime": 86400,
    "subnet4": [
      {
        "id": 1,
        "subnet": "172.29.99.0/24",
        "pools": [ { "pool": "172.29.99.100 - 172.29.99.200" } ],
        "option-data": [
          { "name": "routers",             "data": "172.29.99.1" },
          { "name": "domain-name-servers", "data": "172.29.99.10" },
          { "name": "domain-name",         "data": "asix.local" }
        ]
      }
    ]
  }
}
```

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf     # valida la sintaxi
sudo systemctl enable --now kea-dhcp4-server
sudo systemctl status kea-dhcp4-server
```

Comprovació des d'un client configurat en DHCP:

```bash
sudo dhclient -v enp2s0     # o: ip a  (ha de rebre una IP entre .100 i .200)
```

```powershell
ipconfig /release; ipconfig /renew   # Windows
```

---

## 6. DNS (`D-NCC`)

BIND9 actua com a servidor **autoritatiu** de la zona `asix.local` i **reenvia** la resta de consultes. L'enunciat exigeix que resolgui `R-NCC` i `R` (el router).

Estructura al repositori:

```text
src/dns/
├── named.conf
└── db.asix.local
```

`src/dns/named.conf`:

```text
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 8.8.8.8; 1.1.1.1; };
    listen-on { any; };
};

zone "asix.local" {
    type master;
    file "/etc/bind/db.asix.local";
};
```

`src/dns/db.asix.local`:

```text
$TTL 86400
@       IN  SOA d-ncc.asix.local. admin.asix.local. (
            2025102101 ; serial (AAAAMMDDnn)
            3600       ; refresh
            1800       ; retry
            604800     ; expire
            86400 )    ; minimum
        IN  NS  d-ncc.asix.local.

; Router
r       IN  A   172.29.99.1
r-ncc   IN  A   172.29.99.1

; Serveis (DMZ)
w-ncc   IN  A   172.29.88.10
f-ncc   IN  A   172.29.88.10

; Serveis (Intranet)
d-ncc   IN  A   172.29.99.10
monitor IN  A   172.29.99.10

; Base de dades (xarxa aïllada, només accessible des de la DMZ)
b-ncc   IN  A   172.29.89.10
www     IN  CNAME w-ncc
```

Muntatge al `docker-compose.yml`:

```yaml
  dns:
    image: internetsystemsconsortium/bind9:9.18
    container_name: D-NCC
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - ./dns/named.conf:/etc/bind/named.conf:ro
      - ./dns/db.asix.local:/etc/bind/db.asix.local:ro
    restart: always
```

```bash
sudo docker exec D-NCC named-checkconf /etc/bind/named.conf
sudo docker exec D-NCC named-checkzone asix.local /etc/bind/db.asix.local
sudo docker compose restart dns
```

> 🔁 Cada vegada que es modifica la zona cal **incrementar el serial**.

Comprovació:

```bash
dig @172.29.99.10 r.asix.local +short       # 172.29.99.1
dig @172.29.99.10 r-ncc.asix.local +short   # 172.29.99.1
nslookup r-ncc.asix.local 172.29.99.10      # també funciona a Windows
```

---

## 7. FTP (`F-NCC`)

Contenidor `delfer/alpine-ftp-server` (vsftpd). Els usuaris es defineixen amb la variable `USERS` (`usuari|contrasenya`) i `ADDRESS` indica la IP anunciada en mode passiu.

```yaml
  ftp:
    image: delfer/alpine-ftp-server:latest
    container_name: F-NCC
    environment:
      USERS: "bchecker|bchecker121"
      ADDRESS: "172.29.88.10"
      MIN_PORT: "21000"
      MAX_PORT: "21010"
    ports:
      - "21:21/tcp"
      - "21000-21010:21000-21010/tcp"
    volumes:
      - ftp_data:/ftp
    restart: always
```

Comprovació:

```bash
ftp 172.29.88.10          # usuari: bchecker / bchecker121
# o bé
curl -u bchecker:bchecker121 ftp://172.29.88.10/
```

---

## 8. Aplicació web de consulta

Petita aplicació PHP (a `src/app/`) que mostra el contingut de la taula `educacio`. Es connecta al servidor `B-NCC` (`172.29.89.10`) per la xarxa aïllada de la BBDD, amb l'usuari `webapp`, que només té permís de lectura.

`src/app/index.php`:

```php
<?php
$pdo = new PDO('mysql:host=172.29.89.10;dbname=equipaments;charset=utf8mb4',
               'webapp', getenv('DB_PASSWORD'),
               [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$q = $_GET['q'] ?? '';
$stmt = $pdo->prepare(
  "SELECT name, addresses_road_name, addresses_start_street_number,
          addresses_district_name, values_value
     FROM educacio
    WHERE name LIKE :q
    ORDER BY name
    LIMIT 200");
$stmt->execute([':q' => "%$q%"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!doctype html>
<html lang="ca">
<head><meta charset="utf-8"><title>Equipaments d'educació BCN</title></head>
<body>
  <h1>Equipaments d'educació de Barcelona</h1>
  <form><input name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Cerca per nom">
        <button>Cercar</button></form>
  <table border="1" cellpadding="4">
    <tr><th>Nom</th><th>Adreça</th><th>Districte</th><th>Contacte</th></tr>
    <?php foreach ($rows as $r): ?>
    <tr>
      <td><?= htmlspecialchars($r['name']) ?></td>
      <td><?= htmlspecialchars($r['addresses_road_name'].' '.$r['addresses_start_street_number']) ?></td>
      <td><?= htmlspecialchars($r['addresses_district_name']) ?></td>
      <td><?= htmlspecialchars($r['values_value']) ?></td>
    </tr>
    <?php endforeach; ?>
  </table>
</body>
</html>
```

Accés: <http://w-ncc.asix.local> o <http://172.29.88.10>.

---

## 9. Monitor de xarxa

**Uptime Kuma** permet vigilar l'estat de tots els serveis (ping, HTTP, DNS, ports TCP) des d'una interfície web.

```yaml
  monitor:
    image: louislam/uptime-kuma:1
    container_name: M-NCC
    ports:
      - "3001:3001/tcp"
    volumes:
      - monitor_data:/app/data
    restart: always
```

El monitor s'executa a `Dockers-Intranet`, perquè des de la Intranet pot vigilar totes les xarxes.

1. Obre <http://172.29.99.10:3001>.
2. Crea l'usuari administrador **`bchecker` / `bchecker121`**.
3. Afegeix els monitors:

| Monitor | Tipus | Destí |
| :--- | :--- | :--- |
| Router | Ping | `172.29.99.1` |
| Web | HTTP(s) | `http://172.29.88.10` |
| DNS | DNS | `r-ncc.asix.local` @ `172.29.99.10` |
| MySQL | HTTP(s) – paraula clau | `http://172.29.88.10` (si la web mostra dades, la BBDD respon) |
| FTP | TCP Port | `172.29.88.10:21` |
| SSH | TCP Port | `172.29.88.10:22` |

---

## 10. NAT (sortida a Internet)

Perquè els clients de la Intranet surtin a Internet a través de la xarxa NAT (`enp1s0`):

```bash
# IP forwarding persistent (vegeu també la guia del MVP)
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl --system

# Emmascarament de la Intranet i la DMZ cap a la xarxa NAT
sudo iptables -t nat -A POSTROUTING -s 172.29.99.0/24 -o enp1s0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 172.29.88.0/24 -o enp1s0 -j MASQUERADE

# Guardar les regles perquè sobrevisquin a un reinici
sudo apt install -y iptables-persistent
sudo netfilter-persistent save
```

Comprovació des de `Client-Lin`:

```bash
ping -c 3 8.8.8.8
ping -c 3 google.com
```
