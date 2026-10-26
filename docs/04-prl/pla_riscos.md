# 🦺 Pla de prevenció de riscos laborals i tècnics

> Riscos associats al treball amb equips informàtics (PRL) i riscos tècnics del projecte, amb les mesures preventives.

## Índex

1. [Riscos laborals (PRL)](#1-riscos-laborals-prl)
2. [Riscos tècnics del projecte](#2-riscos-tècnics-del-projecte)
3. [Matriu de riscos](#3-matriu-de-riscos)
4. [Pla de contingència i còpies de seguretat](#4-pla-de-contingència-i-còpies-de-seguretat)

---

## 1. Riscos laborals (PRL)

Normativa de referència: **Llei 31/1995** de Prevenció de Riscos Laborals i **RD 488/1997** sobre treball amb pantalles de visualització de dades (PVD).

| Risc | Causa | Mesures preventives |
| :--- | :--- | :--- |
| **Fatiga visual** | Moltes hores davant la pantalla | Regla 20-20-20 (cada 20 min, mirar a 6 m durant 20 s); pantalla a 50–70 cm, a l'alçada dels ulls o lleugerament per sota; evitar reflexos |
| **Trastorns musculoesquelètics** | Postura incorrecta, moviments repetitius | Cadira regulable amb suport lumbar; peus recolzats; colzes a 90°; pauses actives cada hora |
| **Risc elèctric** | Manipulació de cables, regletes sobrecarregades | No manipular equips connectats; no encadenar regletes; avisar el professorat davant qualsevol anomalia |
| **Caigudes i cops** | Cables pel terra, motxilles als passadissos | Mantenir l'espai de treball ordenat; recollir cables |
| **Estrès i fatiga mental** | Terminis ajustats, incidències tècniques | Planificació realista al ProofHub; repartir càrrega de treball; demanar ajuda a temps |
| **Ambient de treball** | Soroll, temperatura, il·luminació | Il·luminació adequada (≈500 lux); ventilació; volum moderat |

## 2. Riscos tècnics del projecte

| # | Risc | Impacte | Mesures preventives |
| :-: | :--- | :--- | :--- |
| T1 | Pèrdua de la configuració d'una VM | Alt | Tota la configuració versionada a Git; documentació pas a pas a `docs/02-admin/` |
| T2 | Pèrdua de les dades de MySQL en recrear el contenidor | Alt | Dades a `src/bbdd/data/` (volum persistent); còpies amb `mysqldump` |
| T3 | Filtració de credencials al repositori | Alt | Fitxer `.env` fora de Git (`.gitignore`); no guardar *tokens* ni claus privades |
| T4 | Conflicte d'adreces IP | Mitjà | Taula d'adreçament única a `arquitectura.md`; rang DHCP separat de les IPs fixes |
| T5 | Servei DNS no arrenca (port 53 ocupat) | Mitjà | Desactivar el *stub listener* de `systemd-resolved` |
| T6 | Accés no autoritzat als serveis | Alt | Exposar MySQL només on calgui; `PermitRootLogin no`; tallafoc (`ufw`/`iptables`) |
| T7 | Caiguda o manteniment d'IsardVDI | Mitjà | Treball documentat i reproduïble; possibilitat de recrear l'entorn des del repositori |
| T8 | Conflictes Git entre membres de l'equip | Baix | Branques per tasca, *Pull Requests* i `git pull` abans de començar |
| T9 | Retards en la planificació | Mitjà | Seguiment al ProofHub; revisió al final de cada sprint |

## 3. Matriu de riscos

Nivell de risc = **Probabilitat × Impacte** (1 = baix, 3 = alt).

| Risc | Probabilitat | Impacte | Nivell | Prioritat |
| :--- | :-: | :-: | :-: | :-: |
| T3 – Filtració de credencials | 2 | 3 | 6 | 🔴 Alta |
| T2 – Pèrdua de dades MySQL | 2 | 3 | 6 | 🔴 Alta |
| T6 – Accés no autoritzat | 2 | 3 | 6 | 🔴 Alta |
| T1 – Pèrdua de configuració | 1 | 3 | 3 | 🟡 Mitjana |
| T4 – Conflicte d'IPs | 2 | 2 | 4 | 🟡 Mitjana |
| T5 – Port 53 ocupat | 2 | 2 | 4 | 🟡 Mitjana |
| T7 – Caiguda d'IsardVDI | 1 | 2 | 2 | 🟢 Baixa |
| T9 – Retards | 2 | 2 | 4 | 🟡 Mitjana |
| T8 – Conflictes Git | 2 | 1 | 2 | 🟢 Baixa |

## 4. Pla de contingència i còpies de seguretat

### Còpia de la base de dades

```bash
sudo docker exec B-NCC mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" equipaments \
  > backup_equipaments_$(date +%F).sql
```

### Restauració

```bash
sudo docker exec -i B-NCC mysql -uroot -p equipaments < backup_equipaments_AAAA-MM-DD.sql
```

### Recuperació completa del servidor

1. Crear una VM nova segons [MVP_sprint1_infraestructura-config.md](../02-admin/MVP_sprint1_infraestructura-config.md).
2. Clonar el repositori ([git_workflow.md](../02-admin/git_workflow.md#6-pujada-a-producció)).
3. Recrear el fitxer `src/.env`.
4. `sudo docker compose up -d`.
5. Restaurar la darrera còpia de la BBDD.
6. Executar el [pla de proves](../05-proves/test_plan.md).
