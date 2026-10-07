cat << 'EOF' > README.md
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

## 📌 Descripció del Projecte

Aquest projecte té com a objectiu el disseny, configuració i desplegament des de zero d'una **infraestructura de xarxa multicapa segura** i completa per suportar una aplicació web corporativa.

### 🏢 Arquitectura de Xarxa
La topologia s'estructura al voltant d'un **Router central (`R-NCC`)** que segmenta la xarxa en 3 zones diferenciades:
* **NAT (Exterior):** Accés directe a Internet per a descàrregues i actualitzacions.
* **DMZ (Zona Desmilitaritzada - `10.0.1.0/24`):** Conté els serveis accessibles des de l'exterior:
  * Servidor Web (`W-NCC`)
  * Servidor FTP (`F-NCC`)
* **Intranet (Xarxa Privada - `10.0.2.0/24`):** Zona d'alta seguretat per a la gestió interna:
  * Servidor de Base de Dades MySQL (`B-NCC`)
  * Servidors d'Infraestructura DNS i DHCP (`S-NCC`)
  * Equips Clients (Windows i Linux)

---

## 🗺️ Taula d'Adreçament IP

| Equip | Hostname | Zona / Subxarxa | Interfície | Adreça IP |
| :--- | :--- | :--- | :--- | :--- |
| **Router** | `R-NCC` | NAT / WAN | `eth0` | Assignada per DHCP |
| **Router** | `R-NCC` | DMZ | `eth1` | `10.0.1.1 /24` |
| **Router** | `R-NCC` | Intranet | `eth2` | `10.0.2.1 /24` |
| **Servidor Web** | `W-NCC` | DMZ | `eth0` | `10.0.1.10 /24` |
| **Servidor FTP** | `F-NCC` | DMZ | `eth0` | `10.0.1.20 /24` |
| **Servidor BBDD** | `B-NCC` | Intranet | `eth0` | `10.0.2.10 /24` |
| **DNS / DHCP** | `S-NCC` | Intranet | `eth0` | `10.0.2.20 /24` |
| **Clients** | `PC-WIN` / `PC-LNX` | Intranet | `eth0` | Dinàmica (DHCP) |

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
│   │   ├── serveis.md             # Guia de serveis (DNS, Web, BBDD, FTP)
│   │   └── git_workflow.md        # Procediment i comandes del flux de treball Git
│   ├── 03-client/                 # Manuals d'usuari i instal·lació de clients (RA3, RA4)
│   │   └── manual_usuari.md
│   ├── 04-prl/                    # Pla de Prevenció de Riscos Laborals i Tècnics (RA3)
│   │   └── pla_riscos.md
│   └── 05-proves/                 # Pla de qualitat i banc de proves (RA2)
│       └── test_plan.md
└── src/                           # Codi font del projecte
    ├── bbdd/                      # Scripts d'estructura i càrrega de dades SQL
    ├── app/                       # Codi de l'aplicació Web
    └── scripts/                   # Scripts d'automatització
