# 🧭 Guia per tancar el Sprint 1

> Llista de comprovació per tenir el **Sprint 1 al 100 %** segons el que demana el professor.
> Prioritat: **l'ús de les eines i la dinàmica de treball en grup**, més que l'execució.

## Índex

1. [Què demana el professor](#1-què-demana-el-professor)
2. [ProofHub](#2-proofhub)
3. [GitHub: documentació](#3-github-documentació)
4. [GitHub: mapa de l'arquitectura i justificació](#4-github-mapa-de-larquitectura-i-justificació)
5. [Com pujar els canvis](#5-com-pujar-els-canvis)
6. [Repartiment de la feina pendent](#6-repartiment-de-la-feina-pendent)
7. [Revisió final abans del lliurament](#7-revisió-final-abans-del-lliurament)

---

## 1. Què demana el professor

| Eina | Requisit | On es veu | Estat |
| :--- | :--- | :--- | :-: |
| ProofHub | Assignació de tasques | Tauler del ProofHub + [proofhub.md](proofhub.md#4-sprint-1) | ⚠️ Falta posar els responsables al Markdown |
| ProofHub | Foto de tasques a l'inici i al final del sprint | [proofhub.md](proofhub.md#fotos-del-tauler) | ✅ Inici, seguiment i final |
| ProofHub | *(...)* Seguiment, reunions i retrospectiva | [proofhub.md](proofhub.md#reunions) | ⚠️ Falta la retrospectiva i la data de la reunió |
| GitHub | Documentació: preparació de l'entorn | [Guia del MVP §2–3](../02-admin/MVP_sprint1_infraestructura-config.md#2-creació-de-màquines-virtuals-isardvdi) | ✅ |
| GitHub | Documentació: instal·lacions | [Guia del MVP §4](../02-admin/MVP_sprint1_infraestructura-config.md#40-installació-de-docker) · [serveis.md](../02-admin/serveis.md) | ✅ |
| GitHub | Mapa de l'arquitectura | [arquitectura.md §1](../02-admin/arquitectura.md#1-mapa-de-xarxa) | ✅ |
| GitHub | Justificació de decisions | [arquitectura.md §7](../02-admin/arquitectura.md#7-justificació-de-les-decisions) | ✅ |

✅ fet · ⚠️ falta alguna cosa

---

## 2. ProofHub

### 2.1 Assignació de tasques

El professor vol veure que **cada tasca té un responsable** i que la feina està **repartida entre tots**.

Al ProofHub, per a **cada tasca del Sprint 1**:

- [ ] **Responsable** (*Cesionarios*): una persona. Si la fan dues, se n'assignen dues.
- [ ] **Data de venciment** dins del sprint.
- [ ] **Temps estimat** en hores.
- [ ] **Descripció** amb el criteri **"FET QUAN"** (ja el teniu a la majoria).
- [ ] **Etiqueta**: *Xarxa*, *Servidor*, *Documentació*, *Gestió*...

Comproveu que el repartiment és equilibrat. Un sprint són **10 h per persona**: si algú en té 2 i un altre 15, el professor ho veurà.

Després, copieu els responsables a la taula del Sprint 1 de [proofhub.md](proofhub.md#4-sprint-1), a la columna **Responsable**:

| Tasca | Responsable |
| :--- | :--- |
| Crear repositori GitHub i arbre Markdown | |
| Descarregar i analitzar el CSV | |
| Definir pla d'adreçament IP | |
| Diagrama d'arquitectura | |
| Crear les 3 xarxes virtuals a l'hipervisor | |
| Crear plantilla VM Linux base amb usuari `bchecker` | |

> 💡 Si una tasca no s'ha acabat (com la plantilla de VM), no la marqueu com a feta. Moveu-la al Sprint 2 i expliqueu-ho a la retrospectiva. És normal i el professor ho valora més que un tauler "perfecte".

### 2.2 Fotos del tauler

Ja teniu les tres fotos del Sprint 1 a [`img/`](img/). Per als pròxims sprints, feu-les així:

1. Obriu el projecte → **Tareas** → **Vista de tablón**.
2. Allunyeu el navegador (`Ctrl` + `-`) fins que es vegin **totes les columnes**, del *Product Backlog* a *Sprint Done*.
3. Feu la captura (`Win` + `Shift` + `S` a Windows).
4. Deseu-la amb aquest nom:

| Moment | Nom del fitxer |
| :--- | :--- |
| Primer dia del sprint, després de repartir les tasques | `sprintN-inici.png` |
| A meitat de sprint (opcional) | `sprintN-seguiment.png` |
| Últim dia del sprint | `sprintN-final.png` |

5. Pugeu-la a `docs/00-gestio/img/` ([com pujar-la](#5-com-pujar-els-canvis)).

> ⚠️ Si el Sprint 1 encara no s'ha tancat quan llegiu això, torneu a fer la foto final l'últim dia i substituïu `sprint1-final.png`.

### 2.3 Seguiment durant el sprint

És el que vol dir el *"...."* del professor: que el ProofHub es fa servir **cada dia**, no només al principi i al final.

- [ ] Moure les targetes de columna quan canvia l'estat (*Doing* → *Test* → *Sprint Done*).
- [ ] Escriure **comentaris** a les tasques amb problemes o decisions ("el port 53 estava ocupat, ho hem resolt així...").
- [ ] Registrar les **hores** fetes a la pestanya **Tiempo**.
- [ ] Revisar el **Gantt** per veure si anem endarrerits.

### 2.4 Retrospectiva

L'últim dia del sprint, 10 minuts entre tots. Responeu aquestes tres preguntes i escriviu-les a [proofhub.md](proofhub.md#4-sprint-1):

| Pregunta | Exemple |
| :--- | :--- |
| ✅ Què ha anat bé? | "Tenir el diagrama abans de muntar res ens ha evitat errors." |
| ⚠️ Què millorarem? | "Repartir millor les tasques: una persona ha fet gairebé tota la part de xarxa." |
| 🔧 Quines incidències hem tingut? | Ja n'hi ha tres de posades: conflicte d'IPs, ruta duplicada i error SSH/LDAP. |

---

## 3. GitHub: documentació

### 3.1 Preparació de l'entorn

Ja està documentat a la [guia del MVP](../02-admin/MVP_sprint1_infraestructura-config.md):

| Pas | Secció |
| :--- | :--- |
| Creació de les VMs a IsardVDI (recursos, xarxes) | §2 |
| Configuració de xarxa amb Netplan i *IP forwarding* | §3.1 |
| Configuració dels clients Linux i Windows | §3.2 i §3.3 |
| Incidències i com es van resoldre | §6 |

### 3.2 Instal·lacions

| Instal·lació | On està documentada |
| :--- | :--- |
| Docker i Docker Compose | [Guia del MVP §4.0](../02-admin/MVP_sprint1_infraestructura-config.md#40-installació-de-docker) |
| Git i clau SSH per a GitHub | [Guia del MVP §4.0](../02-admin/MVP_sprint1_infraestructura-config.md#40-installació-de-docker) · [git_workflow.md §2](../02-admin/git_workflow.md#2-autenticació-amb-clau-ssh) |
| Serveis (Web, BBDD, DNS, FTP, monitor) | [serveis.md](../02-admin/serveis.md) i carpeta [`src/`](../../src/) |
| Servidor SSH | [serveis.md §2](../02-admin/serveis.md#2-ssh) |

### 3.3 Què falta

- [x] **Captures de les proves** del MVP a la [guia del MVP §5](../02-admin/MVP_sprint1_infraestructura-config.md#5-proves-realitzades): `docker ps`, `dig`, `ping` i web des dels dos clients.
- [ ] Falten les captures de l'**FTP** (login amb `bchecker`) i del **DNS des d'un client** (`dig @172.29.88.10 s-ncc.asix.local`).
- [ ] Revisar que el que diu la guia del MVP coincideix amb el que es va fer. Si algun pas es va fer diferent, corregiu-lo.

---

## 4. GitHub: mapa de l'arquitectura i justificació

### 4.1 Mapa

- [x] Diagrama de Packet Tracer a [arquitectura.md](../02-admin/arquitectura.md#1-mapa-de-xarxa) i al README.
- [x] Taula d'adreçament IP, inventari d'equips i noms DNS.
- [x] Imatge en gran del mapa de xarxa.
- [ ] Afegir al Packet Tracer les IPs de la xarxa de la BBDD (proposta: `172.29.89.0/24`, servidor DMZ `.1`, MySQL `.10`).
- [ ] *(Opcional)* Pujar també el fitxer de Packet Tracer (`.pkt`) a `docs/img/`, perquè el professor el pugui obrir.

### 4.2 Justificació de decisions

Està a [arquitectura.md §7](../02-admin/arquitectura.md#7-justificació-de-les-decisions). **Tots els membres l'heu de llegir i entendre**: el professor pot preguntar a qualsevol.

Preguntes que us poden fer i on teniu la resposta:

| Pregunta | Resposta curta | Secció |
| :--- | :--- | :--- |
| Per què tres xarxes? | La DMZ separa els serveis exposats de la Intranet; si ataquen la web, no poden saltar a dins. | §7.1 |
| Per què la BBDD en una xarxa a part? | Si fos a la Intranet, la web (DMZ) hauria de poder entrar a la Intranet, i això és el que vol evitar la DMZ. | §7.4 |
| Per què el DNS a la Intranet? | És un servei intern. Només obrim el port 53 de la DMZ cap al DNS. | §7.3 |
| Per què Docker? | La configuració queda en fitxers a GitHub i es pot refer en minuts. | §7.6 |
| Per què IP fixa als servidors i DHCP als clients? | Els servidors s'han de trobar sempre a la mateixa IP; els clients es configuren sols. | §7.5 |

---

## 5. Com pujar els canvis

### Opció A: des de la web de GitHub (imatges i canvis petits)

1. Entreu al repositori i aneu a la carpeta (per exemple `docs/00-gestio/img/`).
2. **Add file** → **Upload files** → arrossegueu la imatge.
3. Escriviu un missatge com `docs: afegir foto final del Sprint 1`.
4. **Commit changes**.

Per editar un Markdown: obriu el fitxer → icona del llapis ✏️ → editeu → **Commit changes**.

### Opció B: des de la terminal

```bash
git pull origin main                                  # 1. Baixar l'última versió
cp ~/Baixades/sprint1-final.png docs/00-gestio/img/   # 2. Copiar el fitxer
git add docs/00-gestio/img/sprint1-final.png          # 3. Preparar-lo
git commit -m "docs: afegir foto final del Sprint 1"  # 4. Desar-lo
git push origin main                                  # 5. Pujar-lo
```

> ⚠️ Feu sempre `git pull` abans de començar. Així evitareu conflictes amb els canvis dels companys.

---

## 6. Repartiment de la feina pendent

Proposta. Ajusteu-la segons qui ha fet cada tasca al ProofHub:

| Tasca | Qui | Temps |
| :--- | :--- | :-: |
| Posar responsables, dates i hores a totes les tasques del ProofHub | Gerard | 20 min |
| Copiar els responsables a [proofhub.md](proofhub.md#4-sprint-1) | Gerard | 10 min |
| Pujar el fitxer `.pkt` i afegir les IPs de la xarxa BBDD | Dídac | 10 min |
| Captures de l'FTP i del DNS des d'un client | Dídac | 10 min |
| Posar data i acords de la reunió a [proofhub.md](proofhub.md#reunions) | Gerard | 5 min |
| Foto final del tauler l'últim dia del sprint | Liam | 5 min |
| Retrospectiva (entre tots) i escriure-la a [proofhub.md](proofhub.md#4-sprint-1) | Tots | 15 min |
| Llegir la justificació de l'arquitectura i assajar les preguntes | Tots | 15 min |

---

## 7. Revisió final abans del lliurament

Obriu el repositori a GitHub, **des del README**, i comproveu:

- [ ] El README mostra el **mapa de xarxa** en gran i es llegeix bé.
- [ ] Els **noms reals** dels tres membres són al README.
- [ ] Tots els enllaços de l'índex del README obren el document correcte.
- [ ] [proofhub.md](proofhub.md): responsables omplerts, **3 fotos** visibles i retrospectiva escrita.
- [ ] [arquitectura.md](../02-admin/arquitectura.md): imatge, taula d'IPs i justificació.
- [ ] Guia del MVP: VMs, xarxa, instal·lació de Docker, serveis i proves.
- [ ] Al ProofHub, el tauler coincideix amb el que diu [proofhub.md](proofhub.md).
- [ ] **No hi ha contrasenyes** al repositori (excepte `bchecker121`, que és la de l'enunciat). Comproveu-ho amb la cerca de GitHub: `password`, `clau`, `token`.
- [ ] No hi ha fitxers de prova ni brossa a l'arrel del repositori.
