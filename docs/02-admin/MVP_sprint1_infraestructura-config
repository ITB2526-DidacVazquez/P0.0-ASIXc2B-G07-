# 🛠️ Guia de Desplegament de la Infraestructura i MVP (Sprint 1)

> **Mòdul:** MP14 – Projecte Intermodular ASIX
> **Repositori:** `P0.0-ASIXc2B-G07`
> **Responsable:** Dídac Vázquez (Coordinador Git i Administrador de Xarxa)

Aquest document detalla, pas a pas, la creació de les màquines virtuals a **IsardVDI**, la configuració de les interfícies de xarxa, l'enrutament i la posada en marxa dels serveis en contenidors Docker del **MVP del Sprint 1**.

## Índex

1. [Visió general i topologia](#1-visió-general-i-topologia)
2. [Creació de màquines virtuals (IsardVDI)](#2-creació-de-màquines-virtuals-isardvdi)
3. [Configuració de xarxa i enrutament](#3-configuració-de-xarxa-i-enrutament)
4. [Desplegament de serveis (Docker)](#4-desplegament-de-serveis-en-contenidors-docker)
5. [Proves de validació](#5-proves-de-validació)
6. [Resolució d'incidències](#6-resolució-dincidències)
7. [Publicació al repositori Git](#7-publicació-al-repositori-git)
8. [Pendents i millores](#8-pendents-i-millores)

---

## 1. Visió general i topologia

En aquesta fase MVP, la **VM Router / Servidor (`R-NCC` / `S-NCC`)** fa de router entre xarxes i allotja directament la pila de serveis en contenidors.

| Xarxa | Subxarxa | Rol |
| :--- | :--- | :--- |
| **DMZ** | `172.29.88.0/24` | Serveis |
| **Intranet** | `172.29.99.0/24` | Clients |

### Taula d'adreçament IP

| Equip / Rol | Interfície | Xarxa | Adreça IP | Gateway | DNS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **VM Router / Servidor** | `enp1s0` | WAN (Default) | DHCP | — | — |
| | `enp2s0` | DMZ | `172.29.88.10/24` | — | `127.0.0.1` |
| | `enp3s0` | Intranet | `172.29.99.233/24` | — | `127.0.0.1` |
| **Client-Lin** (Linux) | `enp2s0` | Intranet | `172.29.99.11/24` | `172.29.99.233` | `172.29.88.10` |
| **Client-Win** (Windows) | `Ethernet` | Intranet | `172.29.99.12/24` | `172.29.99.233` | `172.29.88.10` |

```text
                 Internet
                    │
               (enp1s0, DHCP)
        ┌───────────┴────────────┐
        │  VM Router / Servidor  │
        │   R-NCC / S-NCC        │
        │   Docker: D/W/B/F-NCC  │
        └──────┬──────────┬──────┘
         enp2s0│          │enp3s0
     172.29.88.10/24   172.29.99.233/24
          (DMZ)            (Intranet)
                         ┌────┴─────┐
                  Client-Lin     Client-Win
                  172.29.99.11   172.29.99.12
```

---

## 2. Creació de màquines virtuals (IsardVDI)

Es defineix una estructura de tres màquines virtuals per simular l'entorn de xarxa enrutat.

### 2.1 VM Router / Servidor (`R-NCC` / `S-NCC`)

- **Imatge base:** Ubuntu 24.04 Server
- **Recursos:** 3 vCPUs, 6 GB RAM
- **Targetes de xarxa:**
  - `Default` → WAN / Internet (DHCP)
  - `ASIXc2-ITB2` → DMZ (`172.29.88.0/24`)
  - `ASIXc2-ITB3` → Intranet (`172.29.99.0/24`)

### 2.2 Client Linux (`Client-Lin`)

- **Imatge base:** Ubuntu 24.04 Desktop
- **Recursos:** 1 vCPU, 4 GB RAM
- **Targeta de xarxa:** únicament `ASIXc2-ITB3` (Intranet).

> ⚠️ **Important:** cal eliminar la xarxa `Default` des del panell d'IsardVDI per evitar conflictes de ruta per defecte.

### 2.3 Client Windows (`Client-Win`)

- **Imatge base:** Windows 10/11 Desktop
- **Recursos:** 1 vCPU, 4 GB RAM
- **Targeta de xarxa:** únicament `ASIXc2-ITB3` (Intranet).

---

## 3. Configuració de xarxa i enrutament

### 3.1 VM Router / Servidor

Edita el fitxer de Netplan:

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: true
    enp2s0:
      addresses:
        - 172.29.88.10/24
    enp3s0:
      addresses:
        - 172.29.99.233/24
```

Aplica els canvis i activa el reenviament de paquets (*IP forwarding*):

```bash
sudo netplan apply
sudo sysctl -w net.ipv4.ip_forward=1
```

> 💡 `sysctl -w` **no és persistent**: es perd en reiniciar. Per fer-ho permanent:
>
> ```bash
> echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
> sudo sysctl --system
> ```

### 3.2 Client Linux (`Client-Lin`)

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    enp2s0:
      addresses:
        - 172.29.99.11/24
      routes:
        - to: default
          via: 172.29.99.233
      nameservers:
        addresses:
          - 172.29.88.10
```

```bash
sudo netplan apply
```

### 3.3 Client Windows (`Client-Win`)

Executa PowerShell **com a Administrador**:

```powershell
# Assignar IP estàtica i gateway (la VM Router a la Intranet)
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.29.99.12 -PrefixLength 24 -DefaultGateway 172.29.99.233

# Assignar el servidor DNS (servei BIND9 a la VM Router)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("172.29.88.10")
```

---

## 4. Desplegament de serveis en contenidors (Docker)

A la VM Router / Servidor, dins del directori del projecte (`/home/isard/proyecto-p00/src/`), es desplega la pila amb Docker Compose.

| Servei | Contenidor | Imatge | Ports |
| :--- | :--- | :--- | :--- |
| DNS (BIND9) | `D-NCC` | `internetsystemsconsortium/bind9:9.18` | `53/tcp`, `53/udp` |
| Web (Nginx + PHP-FPM) | `W-NCC` | `richarvey/nginx-php-fpm:latest` | `80`, `443` |
| Base de dades (MySQL 8.0) | `B-NCC` | `mysql:8.0` | `3306` |
| FTP (Alpine FTP) | `F-NCC` | `delfer/alpine-ftp-server:latest` | `21`, `21000-21010` (passiu) |

### Fitxer `src/docker-compose.yml`

```yaml
services:
  dns:
    image: internetsystemsconsortium/bind9:9.18
    container_name: D-NCC
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    restart: always

  web:
    image: richarvey/nginx-php-fpm:latest
    container_name: W-NCC
    ports:
      - "80:80/tcp"
      - "443:443/tcp"
    restart: always

  db:
    image: mysql:8.0
    container_name: B-NCC
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "3306:3306/tcp"
    restart: always

  ftp:
    image: delfer/alpine-ftp-server:latest
    container_name: F-NCC
    ports:
      - "21:21/tcp"
      - "21000-21010:21000-21010/tcp"
    restart: always
```

> 🔐 **Credencials:** la contrasenya de MySQL no s'ha de guardar al repositori. Crea un fitxer `src/.env` (afegeix-lo al `.gitignore`):
>
> ```bash
> echo "MYSQL_ROOT_PASSWORD=canvia_aquesta_clau" > src/.env
> echo ".env" >> .gitignore
> ```
>
> Opcionalment, afegeix un `.env.example` sense valors reals perquè l'equip sàpiga quines variables calen.

> ℹ️ L'atribut `version:` ja és obsolet a Docker Compose v2 i s'ha eliminat.

### Posada en marxa

```bash
cd /home/isard/proyecto-p00/src
sudo docker compose up -d
sudo docker compose ps
```

### Port 53 ocupat a Ubuntu

Ubuntu 24.04 executa `systemd-resolved`, que pot ocupar el port 53 i impedir que `D-NCC` arrenqui (*address already in use*). Comprova-ho i, si cal, desactiva el *stub listener*:

```bash
sudo ss -tulpn | grep ':53 '

sudo mkdir -p /etc/systemd/resolved.conf.d
printf "[Resolve]\nDNSStubListener=no\n" | sudo tee /etc/systemd/resolved.conf.d/nostub.conf
sudo systemctl restart systemd-resolved
```

---

## 5. Proves de validació

| # | Capa | Prova | Ordre | Resultat esperat |
| :-: | :--- | :--- | :--- | :--- |
| 1 | L3 | Client → Servidor | `ping -c 3 172.29.88.10` | 0 % pèrdua |
| 2 | L3 | Client → Router (gateway) | `ping -c 3 172.29.99.233` | 0 % pèrdua |
| 3 | L7 | HTTP per IP | `curl -I http://172.29.88.10` | `HTTP/1.1 200 OK` |
| 4 | L7 | HTTP per nom | `curl -I http://s-ncc.asix.local` | `HTTP/1.1 200 OK` |
| 5 | DNS | Resolució | `dig @172.29.88.10 s-ncc.asix.local +short` | IP del servidor |
| 6 | Docker | Estat dels contenidors | `sudo docker compose ps` | 4 serveis `Up` |

Comprovació de ruta al client Linux:

```bash
ip route          # ha de mostrar només: default via 172.29.99.233
```

---

## 6. Resolució d'incidències

| # | Incidència | Causa | Solució |
| :-: | :--- | :--- | :--- |
| 1 | **Conflicte d'IPs** | `enp3s0` del Router tenia la `.10`, igual que el client | Router → `172.29.99.233`; Client-Lin → `172.29.99.11` |
| 2 | **Rutes incorrectes al client Linux** | La interfície `Default` d'IsardVDI creava una segona ruta per defecte | Eliminada la xarxa `Default` de `Client-Lin` des d'IsardVDI |
| 3 | **Error Git/SSH:** `No user exists for uid ...` / `Permission denied` | Conflicte amb la sessió LDAP/Active Directory de l'entorn virtual de l'escola | Usar remot **HTTPS** amb un *Personal Access Token* (PAT) de GitHub |

---

## 7. Publicació al repositori Git

Per evitar el conflicte amb SSH/LDAP, es treballa amb el remot HTTPS:

```bash
git remote set-url origin https://github.com/ITB2526-DidacVazquez/P0.0-ASIXc2B-G07.git
git add .
git commit -m "docs: afegir guia MVP Sprint 1"
git push origin main
```

Quan Git demani credencials:

- **Username:** `ITB2526-DidacVazquez`
- **Password:** el **PAT** de GitHub (no la contrasenya del compte).

> ⚠️ No guardis mai el PAT dins del repositori, d'un script ni d'una URL remota (`https://token@github.com/...`). Si cal, usa `git config --global credential.helper cache`.

---

## 8. Pendents i millores

- [ ] Documentar la **zona DNS** de BIND9 (`asix.local`) i el volum amb `named.conf` / fitxer de zona.
- [ ] Afegir **volums** per a persistència (MySQL, web `src/app`, FTP).
- [ ] Decidir si els clients necessiten sortida a Internet: caldria **NAT** (`MASQUERADE` per `enp1s0`) al router.
- [ ] Restringir el port `3306` (no exposar MySQL a tota la xarxa) amb `ufw` / `iptables`.
- [ ] Fixar versions d'imatge (evitar `:latest`) per assegurar reproducibilitat.
- [ ] Automatitzar el desplegament amb un script a `src/scripts/`.
- [ ] Completar `docs/05-proves/test_plan.md` amb les proves de la secció 5.
