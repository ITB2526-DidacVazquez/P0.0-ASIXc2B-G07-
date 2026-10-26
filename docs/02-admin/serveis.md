# ⚙️ Guia de serveis

> Configuració de cada servei de la infraestructura.
> Fitxers de configuració: carpeta [`src/`](../../src/) ([com es despleguen](#01-desplegament-amb-docker-compose)).
> Prerequisit: xarxa i Docker configurats segons [MVP_sprint1_infraestructura-config.md](MVP_sprint1_infraestructura-config.md).
> On va cada servei i per què: [arquitectura.md](arquitectura.md).

## Índex

0. [Estat dels serveis i desplegament](#0-estat-dels-serveis)
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

### 0.1 Desplegament amb Docker Compose

Tots els fitxers de configuració són a la carpeta [`src/`](../../src/) del repositori. Hi ha **un sol `docker-compose.yml`**, i cada servei té un **perfil** segons el servidor on s'executa:

| Perfil | Servidor | Serveis |
| :--- | :--- | :--- |
| `dmz` | `Dockers-DMZ` | `W-NCC` (Web), `F-NCC` (FTP) |
| `bbdd` | `Docker-B-NCC` | `B-NCC` (MySQL) |
| `intranet` | `Dockers-Intranet` | `D-NCC` (DNS), `M-NCC` (Monitor) |

Així el mateix fitxer serveix per al **MVP** (tots els perfils a la mateixa VM) i per a l'**arquitectura final** (cada servidor arrenca només el seu perfil).

```bash
git clone git@github.com:ITB2526-DidacVazquez/P0.0-ASIXc2B-G07-.git
cd P0.0-ASIXc2B-G07-/src

cp .env.example .env          # i editar-lo: contrasenyes i COMPOSE_PROFILES
nano .env

sudo docker compose up -d     # arrenca només els perfils indicats a COMPOSE_PROFILES
sudo docker compose ps
```

Valors del `.env` per a cada cas:

| Variable | MVP (una sola VM) | `Dockers-DMZ` | `Docker-B-NCC` | `Dockers-Intranet` |
| :--- | :--- | :--- | :--- | :--- |
| `COMPOSE_PROFILES` | `dmz,bbdd,intranet` | `dmz` | `bbdd` | `intranet` |
| `WEBAPP_HOST` | `%` | — | `172.29.89.1` | — |
| `DB_BIND_IP` | `127.0.0.1` | — | `172.29.89.10` | — |
| `FTP_ADDRESS` | `172.29.88.10` | `172.29.88.10` | — | — |

> ℹ️ Docker Compose llegeix tot el fitxer encara que un servei no s'arrenqui. Per això, als servidors sense BBDD apareix un avís (*"The MYSQL_ROOT_PASSWORD variable is not set"*). No és cap error.

> 🔐 El fitxer `.env` i `app/config.php` contenen contrasenyes i **no es pugen a GitHub** (estan al `src/.gitignore`). Al repositori només hi ha les plantilles `.env.example` i `app/config.example.php`.

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
| MySQL (`B-NCC`) | script `02-usuaris.sh` ([secció 4.3](#43-usuaris-de-mysql)) |
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

Servei `web` del perfil `dmz`. Fa servir la imatge `richarvey/nginx-php-fpm` i serveix la carpeta [`src/app/`](../../src/app/), que es munta a `/var/www/html`. Així, qualsevol canvi a l'aplicació que arriba amb `git pull` es veu a l'instant.

Comprovació:

```bash
curl -I http://172.29.88.10
curl -I http://w-ncc.asix.local
```

---

## 4. Base de dades (`B-NCC`)

Servei `db` del perfil `bbdd` (imatge `mysql:8.0`).

### 4.1 Dades d'origen

**Llistat d'equipaments d'educació de la ciutat de Barcelona** (Open Data BCN):

- Fitxa: <https://opendata-ajuntament.barcelona.cat/data/es/dataset/equipament-educacio/resource/29d9ff10-6892-4f16-9012-d5c4997857e7>
- Descàrrega directa (CSV): <https://opendata-ajuntament.barcelona.cat/data/dataset/f36b60f2-9541-4d08-b0f9-b0a9313fab3d/resource/29d9ff10-6892-4f16-9012-d5c4997857e7/download>

L'script [`src/scripts/descarregar_csv.sh`](../../src/scripts/descarregar_csv.sh) el descarrega a `src/bbdd/csv/`, el passa a UTF-8 si cal, treu els finals de línia de Windows i mostra la capçalera:

```bash
bash src/scripts/descarregar_csv.sh
```

> ⚠️ Comprova que la capçalera que mostra l'script coincideix amb les columnes de [`01-esquema.sql`](../../src/bbdd/init/01-esquema.sql). Si no, cal ajustar la taula i la llista de columnes de `03-carrega.sh`.

### 4.2 Creació automàtica de la BBDD

La primera vegada que arrenca, MySQL executa per ordre els scripts de [`src/bbdd/init/`](../../src/bbdd/init/):

| Fitxer | Què fa |
| :--- | :--- |
| `01-esquema.sql` | Crea la BBDD `equipaments` i la taula `educacio` |
| `02-usuaris.sh` | Crea els usuaris `bchecker` i `webapp` (llegeix les contrasenyes del `.env`) |
| `03-carrega.sh` | Carrega el CSV. Si no hi és, avisa però deixa arrencar MySQL |

El CSV es munta a `/var/lib/mysql-files/`, que és l'única carpeta des d'on MySQL 8 permet importar fitxers (`secure_file_priv`).

> ⚠️ **Aquests scripts només s'executen si `src/bbdd/data/` està buida.** Si MySQL ja s'havia arrencat abans, cal esborrar les dades per tornar-los a executar:
>
> ```bash
> sudo docker compose down
> sudo rm -rf bbdd/data
> sudo docker compose up -d
> sudo docker logs B-NCC | grep -i "csv"     # ha de dir: CSV carregat: N files.
> ```

**Carregar el CSV més tard** (si MySQL ja estava en marxa sense CSV):

```bash
bash src/scripts/descarregar_csv.sh
sudo docker exec B-NCC bash /docker-entrypoint-initdb.d/03-carrega.sh
```

> Si la taula ja tenia dades, abans buida-la per no duplicar files: `TRUNCATE TABLE equipaments.educacio;`

### 4.3 Usuaris de MySQL

| Usuari | Contrasenya | Des d'on | Permisos | Per a què |
| :--- | :--- | :--- | :--- | :--- |
| `bchecker` | `bchecker121` | Qualsevol | Tots sobre `equipaments` | Exigit per l'enunciat (administració i correcció) |
| `webapp` | `WEBAPP_PASSWORD` del `.env` | `WEBAPP_HOST` (`172.29.89.1` a l'arquitectura final) | Només `SELECT` | L'aplicació web |

L'usuari `webapp` només pot llegir: si algú ataqués la web, no podria esborrar ni modificar dades. Vegeu la [justificació a l'arquitectura](arquitectura.md#74-la-base-de-dades-en-una-xarxa-a-part).

### 4.4 Comprovació

```bash
sudo docker exec -it B-NCC mysql -ubchecker -pbchecker121 --default-character-set=utf8mb4 -e \
  "SELECT COUNT(*) FROM equipaments.educacio;
   SELECT name, addresses_district_name FROM equipaments.educacio LIMIT 5;"
```

> Sense `--default-character-set=utf8mb4`, la terminal pot mostrar els accents malament (`Gr�cia`), encara que a la BBDD estiguin bé.

### 4.5 Persistència i port

- Les dades es guarden a `src/bbdd/data/` (ignorada per Git), així que no es perden si es recrea el contenidor.
- El port 3306 només s'obre a la IP de `DB_BIND_IP`: `127.0.0.1` al MVP (només la mateixa VM) i `172.29.89.10` a l'arquitectura final (només la xarxa aïllada).

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

Servei `dns` del perfil `intranet` (imatge `internetsystemsconsortium/bind9:9.18`). BIND9 és **autoritatiu** de la zona `asix.local` i **reenvia** la resta de consultes a DNS públics. L'enunciat exigeix que resolgui `R-NCC` i `R` (el router).

| Fitxer | Es munta a | Contingut |
| :--- | :--- | :--- |
| [`src/dns/config/named.conf`](../../src/dns/config/named.conf) | `/etc/bind/named.conf` | Opcions, *forwarders* i declaració de la zona |
| [`src/dns/zones/db.asix.local`](../../src/dns/zones/db.asix.local) | `/var/lib/bind/db.asix.local` | Registres de la zona (`r`, `r-ncc`, `w-ncc`...) |

> ⚠️ La carpeta `src/dns/config` substitueix **tota** la carpeta `/etc/bind` de la imatge. Per això `named.conf` no inclou cap altre fitxer: ha de funcionar sol. Si la carpeta estigués buida, BIND9 no arrencaria.

> 🔁 Cada vegada que es modifica la zona cal **incrementar el serial** i reiniciar: `sudo docker compose restart dns`.

Validar la configuració abans d'arrencar:

```bash
sudo docker run --rm -v $PWD/dns/config:/etc/bind:ro -v $PWD/dns/zones:/var/lib/bind:ro \
  --entrypoint sh internetsystemsconsortium/bind9:9.18 \
  -c 'named-checkconf /etc/bind/named.conf && named-checkzone asix.local /var/lib/bind/db.asix.local'
```

Comprovació:

```bash
dig @172.29.99.10 r.asix.local +short       # 172.29.99.1
dig @172.29.99.10 r-ncc.asix.local +short   # 172.29.99.1
nslookup r-ncc.asix.local 172.29.99.10      # també funciona a Windows
```

> Si el contenidor no arrenca per *"address already in use"*, és `systemd-resolved` ocupant el port 53. Vegeu la solució a la [guia del MVP](MVP_sprint1_infraestructura-config.md#46-port-53-ocupat-a-ubuntu).

---

## 7. FTP (`F-NCC`)

Servei `ftp` del perfil `dmz` (imatge `delfer/alpine-ftp-server`, basada en vsftpd).

- **Usuari:** `bchecker` / `bchecker121` (variable `USERS`).
- **Mode passiu:** ports `21000-21010`. La variable `ADDRESS` (`FTP_ADDRESS` al `.env`) indica la IP que s'anuncia als clients. Sense ella, el mode passiu falla.
- **Carpeta:** `src/ftp/`, **separada de la web**. Així, qui entri per FTP no pot modificar ni esborrar l'aplicació.

Comprovació (prova real, no només el port):

```bash
curl -u bchecker:bchecker121 ftp://172.29.88.10/                     # llistar
echo prova > prova.txt
curl -T prova.txt -u bchecker:bchecker121 ftp://172.29.88.10/        # pujar
curl -u bchecker:bchecker121 ftp://172.29.88.10/prova.txt            # baixar
```

---

## 8. Aplicació web de consulta

Aplicació PHP a [`src/app/index.php`](../../src/app/index.php) que mostra els equipaments d'educació, amb cerca per nom i filtre per districte. Fa servir **consultes preparades** (PDO) per evitar la injecció SQL.

Es connecta amb l'usuari `webapp` (només lectura). Les dades de connexió són a `src/app/config.php`, que no es puja a GitHub:

```bash
cd src/app
cp config.example.php config.php
nano config.php
```

| Camp | MVP | Arquitectura final |
| :--- | :--- | :--- |
| `host` | `db` (nom del servei a Docker Compose) | `172.29.89.10` (B-NCC per la xarxa aïllada) |
| `password` | El mateix valor que `WEBAPP_PASSWORD` del `.env` | El mateix |

Accés: <http://w-ncc.asix.local> o <http://172.29.88.10>.

---

## 9. Monitor de xarxa

**Uptime Kuma** (servei `monitor` del perfil `intranet`) vigila l'estat de tots els serveis (ping, HTTP, DNS, ports TCP) des d'una interfície web. Les seves dades es guarden a `src/monitor/data/`.

El monitor s'executa a `Dockers-Intranet`, perquè des de la Intranet pot vigilar totes les xarxes.

1. Obre <http://172.29.99.10:3001>.
2. Crea l'usuari administrador **`bchecker` / `bchecker121`**.
3. Afegeix els monitors:

| Monitor | Tipus | Destí |
| :--- | :--- | :--- |
| Router | Ping | `172.29.99.1` |
| Web | HTTP(s) | `http://172.29.88.10` |
| DNS | DNS | `r-ncc.asix.local` @ `172.29.99.10` |
| BBDD (indirecte) | HTTP(s) – paraula clau | `http://172.29.88.10`, paraula `equipaments a la base de dades` (si la web mostra dades, la BBDD respon) |
| FTP | TCP Port | `172.29.88.10:21` |
| SSH | TCP Port | `172.29.88.10:22` |

> La BBDD no es pot vigilar directament: està en una xarxa aïllada i des de la Intranet no hi ha cap ruta.

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
