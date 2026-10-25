# 📅 Gestió del projecte (ProofHub)

> Com organitzem la feina en grup: eines, repartiment de tasques i seguiment de cada sprint.
> Projecte al ProofHub: **`P0.0-ASIXc2B-G07`**

## Índex

1. [Eines i dinàmica de treball](#1-eines-i-dinàmica-de-treball)
2. [Com fem servir el ProofHub](#2-com-fem-servir-el-proofhub)
3. [Rols de l'equip](#3-rols-de-lequip)
4. [Sprint 1](#4-sprint-1--0710--2010)
5. [Sprint 2](#5-sprint-2--2110--0311)
6. [Sprint 3](#6-sprint-3--0411--1811)

---

## 1. Eines i dinàmica de treball

| Eina | Per a què la fem servir |
| :--- | :--- |
| **ProofHub** | Backlog, repartiment de tasques, dates i seguiment de cada sprint |
| **GitHub** | Documentació, fitxers de configuració i historial de canvis |
| **Packet Tracer** | Disseny del mapa de xarxa abans de muntar-lo |
| **IsardVDI** | Màquines virtuals on despleguem la infraestructura real |

**Dinàmica:**

- Sprints **quinzenals** de **10 h** (5 h per setmana).
- **Inici de sprint:** triem les tasques del backlog, les repartim i fem la **foto inicial** del tauler.
- **Cada sessió de classe:** 5 minuts per explicar què ha fet cadascú, què farà i si està bloquejat.
- **Final de sprint:** revisem què s'ha acabat, fem la **foto final** del tauler i les tasques no acabades tornen al backlog.
- Cada tasca acabada ha de tenir la seva documentació pujada a GitHub.

## 2. Com fem servir el ProofHub

1. **Llistes de tasques:** a *Tasks* tenim una llista per sprint (`Sprint 1`, `Sprint 2`, `Sprint 3`) i una llista `Backlog` amb tot el que queda pendent.
2. **Cada tasca té:**
   - un **responsable** (*Assignee*);
   - una **data d'inici i de final** dins del sprint;
   - un **temps estimat** en hores;
   - una **etiqueta** (*Label*): `Xarxa`, `Serveis`, `Documentació`, `Proves` o `Gestió`.
3. **Estats:** a la vista *Board* movem cada tasca per les columnes `Per fer` → `En curs` → `Fet`.
4. **Fotos del sprint:** fem una captura de la vista *Board* el primer i l'últim dia del sprint i la guardem a [`docs/00-gestio/img/`](img/) amb el nom `sprintN-inici.png` i `sprintN-final.png`.

## 3. Rols de l'equip

| Membre | Rol principal | Responsabilitats |
| :--- | :--- | :--- |
| **Dídac Vázquez** | Coordinador Git / Xarxa | Repositori, router, enrutament, NAT, DHCP |
| **Integrant 2** | Serveis | DNS, Web, FTP, BBDD, Docker |
| **Integrant 3** | Documentació / PRL | Markdown, pla de riscos, pla de proves, ProofHub |

> Tots els membres documenten les tasques que fan, no només el responsable de documentació.

---

## 4. Sprint 1 · 07/10 – 20/10

**Objectiu:** MVP amb la xarxa enrutada i els serveis bàsics en Docker.

| Tasca | Responsable | Etiqueta | Hores est. | Estat final |
| :--- | :--- | :--- | :-: | :-: |
| Crear el projecte al ProofHub i el backlog | Integrant 3 | Gestió | 1 | |
| Crear el repositori GitHub i l'arbre de documentació | Dídac | Documentació | 1 | |
| Crear les VMs a IsardVDI | Dídac | Xarxa | 1,5 | |
| Configurar xarxa DMZ / Intranet i *IP forwarding* | Dídac | Xarxa | 2 | |
| Instal·lar Docker i desplegar Web, DNS, MySQL i FTP | Integrant 2 | Serveis | 3 | |
| Documentar la guia del MVP | Integrant 3 | Documentació | 1,5 | |

| Inici del sprint | Final del sprint |
| :-: | :-: |
| ![Sprint 1 inici](img/sprint1-inici.png) | ![Sprint 1 final](img/sprint1-final.png) |

**Retrospectiva:**

- ✅ Ha anat bé:
- ⚠️ A millorar:
- 🔧 Incidències: conflicte d'IPs entre router i client; ruta per defecte duplicada per la xarxa `Default` d'IsardVDI; error SSH/LDAP en fer `git push`.

---

## 5. Sprint 2 · 21/10 – 03/11

**Objectiu:** arquitectura definitiva i tots els serveis funcionant.

| Tasca | Responsable | Etiqueta | Hores est. | Estat final |
| :--- | :--- | :--- | :-: | :-: |
| Dissenyar el mapa de xarxa a Packet Tracer | Dídac | Xarxa | 2 | |
| Documentar l'arquitectura i justificar les decisions | Integrant 3 | Documentació | 2 | |
| Configurar NAT i DHCP al router | Dídac | Xarxa | 2 | |
| Crear la zona DNS `asix.local` (`R`, `R-NCC`...) | Integrant 2 | Serveis | 1,5 | |
| Crear la BBDD i carregar el CSV | Integrant 2 | Serveis | 2 | |
| Crear l'usuari `bchecker` a tots els sistemes | Integrant 2 | Serveis | 1 | |
| Configurar SSH i la clau de GitHub | Dídac | Serveis | 1 | |
| Documentar els serveis | Integrant 3 | Documentació | 2 | |

| Inici del sprint | Final del sprint |
| :-: | :-: |
| ![Sprint 2 inici](img/sprint2-inici.png) | ![Sprint 2 final](img/sprint2-final.png) |

**Retrospectiva:**

- ✅ Ha anat bé:
- ⚠️ A millorar:
- 🔧 Incidències:

---

## 6. Sprint 3 · 04/11 – 18/11

**Objectiu:** aplicació web, monitor, proves i lliurament.

| Tasca | Responsable | Etiqueta | Hores est. | Estat final |
| :--- | :--- | :--- | :-: | :-: |
| Desenvolupar l'aplicació web de consulta | Integrant 2 | Serveis | 3 | |
| Desplegar el monitor de xarxa | Dídac | Serveis | 1,5 | |
| Configurar els clients Windows i Linux | Dídac | Xarxa | 1,5 | |
| Executar el pla de proves | Tots | Proves | 3 | |
| Revisar i tancar la documentació | Integrant 3 | Documentació | 2 | |
| Preparar la presentació | Tots | Gestió | 2 | |

| Inici del sprint | Final del sprint |
| :-: | :-: |
| ![Sprint 3 inici](img/sprint3-inici.png) | ![Sprint 3 final](img/sprint3-final.png) |

**Retrospectiva:**

- ✅ Ha anat bé:
- ⚠️ A millorar:
- 🔧 Incidències:
