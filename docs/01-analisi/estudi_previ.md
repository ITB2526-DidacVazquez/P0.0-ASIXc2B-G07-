# 📋 Estudi previ i justificació tecnològica

> **Projecte:** P0.0 – Desplegament d'infraestructura
> **Grup:** `P0.0-ASIXc2B-G07`
> **Durada:** 6 setmanes (data de lliurament: **18/11**)

## Índex

1. [Objectiu del projecte](#1-objectiu-del-projecte)
2. [Requisits de l'enunciat](#2-requisits-de-lenunciat)
3. [Planificació (ProofHub i sprints)](#3-planificació-proofhub-i-sprints)
4. [Elecció tecnològica](#4-elecció-tecnològica)
5. [Convencions de noms](#5-convencions-de-noms)

---

## 1. Objectiu del projecte

Preparar la infraestructura per a una aplicació multicapa formada per: **servidor web, monitor de xarxes, SSH, base de dades, DHCP, DNS i FTP**, repartida en tres xarxes (DMZ, Intranet i NAT) i connectades per un router.

## 2. Requisits de l'enunciat

| # | Requisit | On es documenta |
| :-: | :--- | :--- |
| 1 | Router `R-NCC` amb 3 xarxes: DMZ, Intranet i NAT | [arquitectura.md](../02-admin/arquitectura.md) |
| 2 | Web Server `W-NCC` | [serveis.md](../02-admin/serveis.md#3-servidor-web-w-ncc) |
| 3 | Accés SSH a tots els equips | [serveis.md](../02-admin/serveis.md#2-ssh) |
| 4 | BBDD MySQL `B-NCC` amb les dades d'equipaments d'educació de Barcelona | [serveis.md](../02-admin/serveis.md#4-base-de-dades-b-ncc) |
| 5 | DHCP | [serveis.md](../02-admin/serveis.md#5-dhcp) |
| 6 | DNS que resolgui `R-NCC` i `R` (router) | [serveis.md](../02-admin/serveis.md#6-dns-d-ncc) |
| 7 | FTP `F-NCC` | [serveis.md](../02-admin/serveis.md#7-ftp-f-ncc) |
| 8 | 2 clients: 1 Windows i 1 Linux | [manual_usuari.md](../03-client/manual_usuari.md) |
| 9 | Usuari `bchecker` a tots els sistemes i aplicacions | [serveis.md](../02-admin/serveis.md#1-usuari-comú-bchecker) |
| 10 | Aplicació que mostri el contingut de les taules | [serveis.md](../02-admin/serveis.md#8-aplicació-web-de-consulta) |
| 11 | Repositori Git amb autenticació per clau pública/privada | [git_workflow.md](../02-admin/git_workflow.md) |
| 12 | Diagrama d'arquitectura | [arquitectura.md](../02-admin/arquitectura.md#2-diagrama-de-xarxa) |
| 13 | Arbre de documentació Markdown | [README.md](../../README.md#-estructura-de-la-documentació) |
| 14 | Planificació i repartiment de tasques al ProofHub | [proofhub.md](../00-gestio/proofhub.md) |

## 3. Planificació (ProofHub i sprints)

Les tasques es planifiquen al **ProofHub** (detall a [proofhub.md](../00-gestio/proofhub.md)), al projecte `P0.0-ASIXc2B-G07`. Els sprints són **quinzenals** (5 h/setmana → **10 h per sprint**), amb un total de **3 sprints**.

| Sprint | Dates | Objectiu | Entregables principals |
| :-: | :--- | :--- | :--- |
| **1** | 07/10 – 20/10 | MVP: xarxa enrutada i serveis bàsics | VMs a IsardVDI, router DMZ/Intranet, Docker (Web, DNS, MySQL, FTP), repositori Git |
| **2** | 21/10 – 03/11 | Serveis complets | NAT, DHCP, zona DNS (`R`, `R-NCC`...), càrrega del CSV a MySQL, usuari `bchecker`, SSH per clau |
| **3** | 04/11 – 18/11 | Aplicació, proves i documentació | App web de consulta, monitor de xarxa, pla de proves executat, documentació final |

### Backlog (resum)

- [x] Crear repositori GitHub i arbre de documentació
- [x] Crear VMs a IsardVDI (router/servidor + 2 clients)
- [x] Configurar xarxa DMZ i Intranet i *IP forwarding*
- [x] Desplegar contenidors Docker (Web, DNS, MySQL, FTP)
- [ ] Configurar la xarxa NAT (sortida a Internet amb `MASQUERADE`)
- [ ] Configurar el servei DHCP per a la Intranet
- [ ] Crear la zona DNS `asix.local` amb els registres `R` i `R-NCC`
- [ ] Crear la BBDD i carregar el CSV d'equipaments d'educació
- [ ] Crear l'usuari `bchecker` a tots els sistemes i serveis
- [ ] Configurar SSH (accés al servidor i a GitHub per clau)
- [ ] Desenvolupar l'aplicació web de consulta
- [ ] Desplegar el monitor de xarxa
- [ ] Executar el pla de proves i documentar els resultats

## 4. Elecció tecnològica

| Necessitat | Opció escollida | Alternatives valorades | Justificació |
| :--- | :--- | :--- | :--- |
| Virtualització | **IsardVDI** | VirtualBox, Proxmox | Plataforma disponible al centre, accessible des de qualsevol lloc |
| SO servidor | **Ubuntu Server 24.04 LTS** | Debian 12, Rocky Linux | Suport LTS fins al 2029, documentació abundant, l'equip ja el coneix |
| Desplegament de serveis | **Docker + Docker Compose** | Instal·lació directa amb `apt` | Configuració reproduïble i versionable al repositori, aïllament entre serveis |
| Servidor web | **Nginx + PHP-FPM** | Apache + mod_php | Lleuger i ràpid; PHP permet una app senzilla de consulta a MySQL |
| Base de dades | **MySQL 8.0** | MariaDB, PostgreSQL | Exigit per l'enunciat |
| DNS | **BIND9** | dnsmasq, Unbound | Estàndard de facto, permet zones autoritatives completes |
| DHCP | **isc-kea / isc-dhcp-server** | dnsmasq | Servei dedicat i estàndard a Ubuntu |
| FTP | **vsftpd (Alpine FTP)** | ProFTPD | Lleuger i segur, imatge Docker petita |
| Monitor de xarxa | **Zabbix / Uptime Kuma** | Nagios, LibreNMS | Interfície web, alertes, fàcil de desplegar amb Docker |
| Control de versions | **Git + GitHub** | GitLab | Exigit per l'enunciat |

## 5. Convencions de noms

`NCC` és el número d'equip (`N01`, `N02`, ...).

| Prefix | Equip | Exemple |
| :-: | :--- | :--- |
| `R-` | Router | `R-NCC` |
| `W-` | Web Server | `W-NCC` |
| `B-` | Base de dades | `B-NCC` |
| `F-` | FTP | `F-NCC` |
| `D-` | DNS | `D-NCC` |
