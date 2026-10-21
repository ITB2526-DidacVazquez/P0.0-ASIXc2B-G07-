# 🚀 Projecte P0.0: Desplegament d’Infraestructura i Serveis

> **Mòdul:** MP14 - Projecte Intermodular d'Administració de Sistemes Informàtics en Xarxa (ASIX)
> **Grup:** `P0.0-ASIXc2B-G07`
> **Curs:** 2025-2026

---

## 👥 Integrants de l'Equip

| Nom i Cognoms | Usuari GitHub | Rol Principal |
| :--- | :--- | :--- |
| **Dídac Vázquez** | [@ITB2526-DidacVazquez](https://github.com/ITB2526-DidacVazquez) | Coordinador Git / Administrador de Xarxa |
| **Nom Integrant 2** | [@usuari2](https://github.com/) | Administrador de Serveis (DMZ / Intranet) |
| **Nom Integrant 3** | [@usuari3](https://github.com/) | Desenvolupador i Documentació / PRL |

---

## 📌 Descripció del Projecte (MVP - Sprint 1)

Aquest projecte té com a objectiu el disseny, configuració i desplegament d'una **infraestructura de xarxa multicapa** per suportar una aplicació web corporativa i serveis de xarxa.

En la fase de **MVP (Sprint 1)**, la **VM Router / Servidor** allotja directament la pila de serveis en contenidors Docker i gestiona l'enrutament directe entre la xarxa Intranet i la DMZ.

---

## 🗺️ Taula d'Adreçament IP (MVP Realitzat)

| Equip / Rol | Interfície | Subxarxa / Rol | Adreça IP | Porta d'Enllaç (*Gateway*) | Servidor DNS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`VM Router / Servidor`** | `enp2s0`<br>`enp3s0` | DMZ (Serveis)<br>Intranet (Clients) | `172.29.88.10/24`<br>`172.29.99.233/24` | N/A<br>N/A | `127.0.0.1`<br>`127.0.0.1` |
| **`Client-Lin` (Linux)** | `enp2s0` | Intranet | `172.29.99.11/24` | `172.29.99.233` | `172.29.88.10` |
| **`Client-Win` (Windows)** | Adaptador | Intranet | `172.29.99.12/24` | `172.29.99.233` | `172.29.88.10` |

### 🐳 Serveis Desplegats en Docker
* **Web (Nginx + PHP-FPM):** `http://172.29.88.10` / `http://s-ncc.asix.local`
* **DNS (BIND9):** `172.29.88.10:53`
* **Base de Dades (MySQL 8.0):** `172.29.88.10:3306`
* **FTP (Alpine FTP):** `172.29.88.10:21`

---

## 📂 Estructura de la Documentació

```text
P0.0-ASIXc2B-G07/
├── README.md                      # Presentació i índex principal del projecte
├── docs/
│   ├── 01-analisi/                # Estudi de mercat i justificació tecnològica (RA1)
│   │   └── estudi_previ.md
│   ├── 02-admin/                  # Manuals de configuració d'administrador (RA3, RA4)
│   │   ├── arquitectura.md        # Diagrames de xarxa i taules d'IPs detallades
│   │   ├── mvp_sprint1.md         # Documentació del MVP i configuració de xarxa/Docker
│   │   ├── serveis.md             # Guia de serveis (DNS, Web, BBDD, FTP)
│   │   └── git_workflow.md        # Procediment i comandes del flux de treball Git
│   ├── 03-client/                 # Manuals d'usuari i instal·lació de clients (RA3, RA4)
│   │   └── manual_usuari.md
│   ├── 04-prl/                    # Pla de Prevenció de Riscos Laborals i Tècnics (RA3)
│   │   └── pla_riscos.md
│   └── 05-proves/                 # Pla de qualitat i banc de proves (RA2)
│       └── test_plan.md
└── src/                           # Codi font del projecte
    ├── docker-compose.yml         # Fitxer de desplegament dels contenidors Docker
    ├── bbdd/                      # Scripts d'estructura i càrrega de dades SQL
    ├── app/                       # Codi de l'aplicació Web
    └── scripts/                   # Scripts d'automatització
