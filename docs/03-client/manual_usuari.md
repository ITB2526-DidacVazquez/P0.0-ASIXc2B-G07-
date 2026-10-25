# 💻 Manual d'usuari i configuració de clients

> Configuració dels dos clients de la Intranet (Linux i Windows) i com accedir a cada servei.

## Índex

1. [Clients](#1-clients)
2. [Configuració de xarxa](#2-configuració-de-xarxa)
3. [Accés als serveis](#3-accés-als-serveis)
4. [Comprovacions ràpides](#4-comprovacions-ràpides)
5. [Problemes freqüents](#5-problemes-freqüents)

---

## 1. Clients

| Equip | SO | Xarxa | IP | Usuari |
| :--- | :--- | :--- | :--- | :--- |
| `Client-Lin` | Ubuntu 24.04 Desktop | Intranet | `172.29.99.11` (fixa) o DHCP | `bchecker` / `bchecker121` |
| `Client-Win` | Windows 10/11 | Intranet | `172.29.99.12` (fixa) o DHCP | `bchecker` / `bchecker121` |

> ⚠️ Els clients només han de tenir la targeta `ASIXc2-ITB3` (Intranet). Cal treure la xarxa `Default` a IsardVDI.

## 2. Configuració de xarxa

### 2.1 Opció A – IP fixa

**Linux** (`/etc/netplan/50-cloud-init.yaml`):

```yaml
network:
  version: 2
  ethernets:
    enp2s0:
      addresses: [172.29.99.11/24]
      routes:
        - to: default
          via: 172.29.99.233
      nameservers:
        addresses: [172.29.88.10]
        search: [asix.local]
```

```bash
sudo netplan apply
```

**Windows** (PowerShell com a Administrador):

```powershell
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 172.29.99.12 -PrefixLength 24 -DefaultGateway 172.29.99.233
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("172.29.88.10")
```

### 2.2 Opció B – DHCP

**Linux:**

```yaml
network:
  version: 2
  ethernets:
    enp2s0:
      dhcp4: true
```

**Windows:**

```powershell
Set-NetIPInterface -InterfaceAlias "Ethernet" -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
ipconfig /renew
```

El client rebrà una IP entre `172.29.99.100` i `172.29.99.200`, gateway `172.29.99.233` i DNS `172.29.88.10`.

## 3. Accés als serveis

Usuari per a tots els serveis: **`bchecker`** / **`bchecker121`**.

| Servei | Adreça | Linux | Windows |
| :--- | :--- | :--- | :--- |
| Aplicació web | `http://w-ncc.asix.local` | Firefox | Edge / Chrome |
| SSH al router | `r-ncc.asix.local` | `ssh bchecker@r-ncc.asix.local` | `ssh bchecker@r-ncc.asix.local` (PowerShell) o PuTTY |
| FTP | `ftp://f-ncc.asix.local` | `ftp f-ncc.asix.local` o FileZilla | FileZilla / Explorador de fitxers |
| Base de dades | `b-ncc.asix.local:3306` | `mysql -h b-ncc.asix.local -u bchecker -p` | MySQL Workbench / DBeaver |
| Monitor de xarxa | `http://172.29.88.10:3001` | Navegador | Navegador |

### Ús de l'aplicació web

1. Obre `http://w-ncc.asix.local`.
2. Es mostra el llistat d'**equipaments d'educació de Barcelona** (nom, adreça, districte i contacte).
3. Escriu part del nom al camp de cerca i prem **Cercar** per filtrar.

### Ús de l'FTP amb FileZilla

| Camp | Valor |
| :--- | :--- |
| Servidor | `f-ncc.asix.local` |
| Usuari | `bchecker` |
| Contrasenya | `bchecker121` |
| Port | `21` |
| Mode | Passiu |

## 4. Comprovacions ràpides

| Comprovació | Linux | Windows | Resultat esperat |
| :--- | :--- | :--- | :--- |
| IP rebuda | `ip a show enp2s0` | `ipconfig` | IP de la Intranet |
| Gateway | `ip route` | `route print` | `default via 172.29.99.233` |
| Router | `ping -c 3 r` | `ping r` | Respon `172.29.99.233` |
| DNS | `dig r-ncc.asix.local +short` | `nslookup r-ncc.asix.local` | `172.29.99.233` |
| Web | `curl -I http://w-ncc.asix.local` | Obrir al navegador | `200 OK` |
| Internet | `ping -c 3 8.8.8.8` | `ping 8.8.8.8` | Respon (via NAT) |

## 5. Problemes freqüents

| Símptoma | Causa probable | Solució |
| :--- | :--- | :--- |
| Hi ha Internet però no es veuen els serveis | El client té la xarxa `Default` d'IsardVDI i surt per una altra ruta | Treure la targeta `Default` a IsardVDI |
| `ping` per IP funciona però per nom no | DNS mal configurat | Comprovar que el DNS és `172.29.88.10` |
| No s'obté IP per DHCP | Servei DHCP aturat a `R-NCC` | `sudo systemctl status kea-dhcp4-server` al router |
| L'FTP connecta però no llista fitxers | Mode actiu bloquejat | Activar el mode **passiu** al client |
| Windows no respon al `ping` | El tallafoc de Windows bloqueja ICMP | Permetre "Eco ICMPv4" al Windows Defender Firewall |
