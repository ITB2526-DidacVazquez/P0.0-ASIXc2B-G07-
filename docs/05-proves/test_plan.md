# ✅ Pla de proves

> Banc de proves per validar cada capa de la infraestructura. Cada prova té l'ordre exacta, el resultat esperat i una columna per anotar el resultat obtingut.

## Índex

1. [Metodologia](#1-metodologia)
2. [Proves de xarxa](#2-proves-de-xarxa)
3. [Proves de serveis](#3-proves-de-serveis)
4. [Proves de l'usuari `bchecker`](#4-proves-de-lusuari-bchecker)
5. [Proves de l'aplicació](#5-proves-de-laplicació)
6. [Proves de Git](#6-proves-de-git)
7. [Registre d'execució](#7-registre-dexecució)

---

## 1. Metodologia

- Les proves s'executen des de **`Client-Lin`** i **`Client-Win`** (Intranet), excepte quan s'indica `R-NCC`.
- Llegenda de resultat: ✅ OK · ❌ KO · ⏳ pendent.
- Quan una prova falla, s'anota la incidència a la secció 7 i a la taula d'incidències del document del MVP.
- Es guarden captures de pantalla com a evidència a `docs/05-proves/img/`.

## 2. Proves de xarxa

| ID | Prova | Origen | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :--- | :-: |
| X01 | Connectivitat amb el gateway | Client-Lin | `ping -c 3 172.29.99.1` | 0 % pèrdua | ⏳ |
| X02 | Connectivitat amb la DMZ | Client-Lin | `ping -c 3 172.29.88.10` | 0 % pèrdua | ⏳ |
| X03 | Connectivitat amb la DMZ | Client-Win | `ping 172.29.88.10` | 0 % pèrdua | ⏳ |
| X04 | Ruta per defecte única | Client-Lin | `ip route` | Només `default via 172.29.99.1` | ⏳ |
| X05 | IP forwarding actiu | R-NCC | `sysctl net.ipv4.ip_forward` | `= 1` | ⏳ |
| X06 | IP forwarding persistent | R-NCC | Reiniciar i repetir X05 | `= 1` | ⏳ |
| X07 | Sortida a Internet (NAT) | Client-Lin | `ping -c 3 8.8.8.8` | Respon | ⏳ |
| X08 | Regla de NAT | R-NCC | `sudo iptables -t nat -L POSTROUTING -n` | Regla `MASQUERADE` a `enp1s0` | ⏳ |
| X09 | La DMZ no entra a la Intranet | Dockers-DMZ | `ping -c 3 -W 2 172.29.99.100` | Sense resposta (bloquejat) | ⏳ |

## 3. Proves de serveis

### 3.1 Docker

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| D01 | Contenidors en marxa | `sudo docker compose ps` | Tots els serveis `Up` | ⏳ |
| D02 | Reinici automàtic | `sudo reboot` i després `docker compose ps` | Tots els serveis `Up` | ⏳ |

### 3.2 DNS

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| N01 | Resol `R` | `dig @172.29.99.10 r.asix.local +short` | `172.29.99.1` | ⏳ |
| N02 | Resol `R-NCC` | `dig @172.29.99.10 r-ncc.asix.local +short` | `172.29.99.1` | ⏳ |
| N03 | Resol el web | `dig @172.29.99.10 w-ncc.asix.local +short` | `172.29.88.10` | ⏳ |
| N04 | Resolució des de Windows | `nslookup r-ncc.asix.local` | `172.29.99.1` | ⏳ |
| N05 | Reenviament a Internet | `dig @172.29.99.10 google.com +short` | IP pública | ⏳ |

### 3.3 DHCP

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| H01 | Servei actiu | `systemctl status kea-dhcp4-server` (R-NCC) | `active (running)` | ⏳ |
| H02 | Client Linux obté IP | `sudo dhclient -v enp2s0` | IP entre `.100` i `.200` | ⏳ |
| H03 | Client Windows obté IP | `ipconfig /renew` | IP, gateway i DNS correctes | ⏳ |
| H04 | Concessió registrada | `cat /var/lib/kea/kea-leases4.csv` (R-NCC) | Apareix la MAC del client | ⏳ |

### 3.4 Web

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| W01 | HTTP per IP | `curl -I http://172.29.88.10` | `HTTP/1.1 200 OK` | ⏳ |
| W02 | HTTP per nom | `curl -I http://w-ncc.asix.local` | `HTTP/1.1 200 OK` | ⏳ |

### 3.5 Base de dades

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| B01 | BBDD aïllada de la Intranet | `nc -zv -w 3 172.29.89.10 3306` (des de Client-Lin) | Falla (no hi ha ruta) | ⏳ |
| B01b | BBDD accessible des de la web | `nc -zv 172.29.89.10 3306` (des de Dockers-DMZ) | `succeeded` | ⏳ |
| B02 | BBDD creada | `mysql -h 172.29.89.10 -ubchecker -p -e "SHOW DATABASES;"` (des de Dockers-DMZ) | Apareix `equipaments` | ⏳ |
| B03 | Dades carregades | `... -e "SELECT COUNT(*) FROM equipaments.educacio;"` | Igual al nº de files del CSV − 1 | ⏳ |
| B04 | Accents correctes | `... -e "SELECT name FROM equipaments.educacio LIMIT 5;"` | Sense caràcters estranys | ⏳ |

> Per comptar les files del CSV: `wc -l equipaments_educacio.csv`.

### 3.6 FTP

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| F01 | Login | `curl -u bchecker:bchecker121 ftp://172.29.88.10/` | Llistat del directori | ⏳ |
| F02 | Pujada de fitxer | `curl -T prova.txt -u bchecker:bchecker121 ftp://172.29.88.10/` | Sense errors | ⏳ |
| F03 | Descàrrega de fitxer | `curl -u bchecker:bchecker121 ftp://172.29.88.10/prova.txt` | Contingut del fitxer | ⏳ |

### 3.7 SSH

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| S01 | SSH amb contrasenya | `ssh bchecker@r-ncc.asix.local` | Sessió oberta | ⏳ |
| S02 | SSH per clau | `ssh -i ~/.ssh/id_ed25519 bchecker@r-ncc.asix.local` | Sessió sense demanar contrasenya | ⏳ |
| S03 | Root bloquejat | `ssh root@r-ncc.asix.local` | `Permission denied` | ⏳ |

### 3.8 Monitor de xarxa

| ID | Prova | Ordre / Acció | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| M01 | Accés web | Obrir `http://172.29.99.10:3001` | Pantalla d'inici de sessió | ⏳ |
| M02 | Monitors actius | Revisar el panell | Tots els serveis en verd | ⏳ |
| M03 | Detecció de caiguda | `sudo docker stop F-NCC` | El monitor FTP passa a vermell | ⏳ |

## 4. Proves de l'usuari `bchecker`

| ID | Sistema | Prova | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| U01 | Dockers-DMZ / Dockers-Intranet / Docker-B-NCC | Login per SSH | Accés correcte | ⏳ |
| U02 | Client-Lin | Login gràfic | Accés correcte | ⏳ |
| U03 | Client-Win | Login gràfic | Accés correcte | ⏳ |
| U04 | MySQL | `mysql -ubchecker -pbchecker121` | Accés correcte | ⏳ |
| U05 | FTP | Login FTP | Accés correcte | ⏳ |
| U06 | Monitor | Login web | Accés correcte | ⏳ |

## 5. Proves de l'aplicació

| ID | Prova | Acció | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| A01 | Càrrega de la pàgina | Obrir `http://w-ncc.asix.local` | Es mostra la taula d'equipaments | ⏳ |
| A02 | Cerca | Cercar `Escola` | Només apareixen resultats que contenen el text | ⏳ |
| A03 | Cerca sense resultats | Cercar `zzzz` | Taula buida, sense errors | ⏳ |
| A04 | Injecció SQL | Cercar `' OR 1=1 --` | No mostra errors ni dades inesperades | ⏳ |
| A05 | Accés des de Windows | Obrir la URL a Edge | Igual que A01 | ⏳ |

## 6. Proves de Git

| ID | Prova | Ordre | Resultat esperat | Resultat |
| :-: | :--- | :--- | :--- | :-: |
| G01 | Autenticació SSH | `ssh -T git@github.com` | `successfully authenticated` | ⏳ |
| G02 | Clone per SSH | `git clone git@github.com:ITB2526-DidacVazquez/P0.0-ASIXc2B-G07-.git` | Repositori descarregat | ⏳ |
| G03 | Push des del servidor | `git commit -m "test" && git push` | Commit visible a GitHub | ⏳ |
| G04 | Pull a producció | `git pull origin main` | `Already up to date` o canvis aplicats | ⏳ |
| G05 | Secrets fora del repo | `git ls-files \| grep .env` | Cap resultat (només `.env.example`) | ⏳ |

## 7. Registre d'execució

| Data | Sprint | Proves executades | OK | KO | Responsable | Observacions |
| :--- | :-: | :--- | :-: | :-: | :--- | :--- |
| | 1 | | | | | |
| | 2 | | | | | |
| | 3 | | | | | |
