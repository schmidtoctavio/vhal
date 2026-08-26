# VHAL — PROJECT MEMORY 2 / CONTINUIDAD CANÓNICA

**Volumen:** 2  
**Última actualización:** 26/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  
**Estado general:** F19 Vertical Slice ✅, F20 Durable Character Runtime ✅, F21-A Durable Skill Ownership ✅.  
**Siguiente bloque recomendado:** F21-B — Durable Skill Learning Foundation (Scroll/Book + requisitos + Trainer + persistencia autoritativa).

---

# 0. REGLA DE MEMORIA CANÓNICA POR VOLÚMENES

VHAL usa memoria canónica por volúmenes.

Archivos actuales:

```text
PROJECT_MEMORY.md
→ Volumen 1
→ historia y decisiones F00 → F19

PROJECT_MEMORY_2.md
→ Volumen 2
→ continuidad desde F20
→ estado canónico actual
```

Orden obligatorio al retomar el proyecto:

```text
1. leer PROJECT_MEMORY.md
2. leer PROJECT_MEMORY_2.md
3. si existe, leer PROJECT_MEMORY_3.md
4. continuar en orden creciente
5. revisar los repositorios reales en branch dev
```

Regla de precedencia:

> El volumen más nuevo prevalece para el estado operativo actual si existe una contradicción con uno anterior.

Los volúmenes anteriores conservan historia; el más reciente conserva la verdad operativa actual.

## Política de tamaño

Los `.md` canónicos se entregan siempre completos para reemplazar.

Cuando un volumen se acerque aproximadamente a:

```text
~5000 líneas
```

no se sigue inflando indefinidamente.

Se crea:

```text
PROJECT_MEMORY_3.md
```

y luego, si hiciera falta:

```text
PROJECT_MEMORY_4.md
...
```

No reescribir miles de líneas históricas en cada volumen nuevo.

---

# 1. WORKFLOW OBLIGATORIO

VHAL continúa usando estrictamente:

```text
ETAPA
↓
IMPLEMENTACIÓN MANUAL Y EXPLICADA
↓
TEST
↓
CORREGIR WARNINGS / ERRORES
↓
GIT STATUS
↓
REVISAR SCOPE
↓
COMMIT
↓
PUSH
↓
ESPERAR "pusheado"
↓
VERIFICAR REMOTO
↓
SIGUIENTE ETAPA
```

Reglas:

- no avanzar de etapa antes de `pusheado`;
- preferir etapas pequeñas;
- probar antes de commit;
- corregir warnings/errors antes de cerrar;
- revisar `git status` antes del commit;
- no mezclar scope ajeno;
- GitHub actual prevalece sobre recuerdos anteriores;
- revisar siempre el código real antes de indicar cambios concretos;
- cuando una escena/nodo/Inspector sea razonablemente manual, el usuario lo hace en Godot;
- no convertir cada etapa en un refactor general si no lo necesita.

Objetivo habitual:

```text
0 warnings
0 errors
```

---

# 2. REPOSITORIOS

Branch habitual:

```text
dev
```

Repositorios:

```text
Cliente / memoria canónica:
schmidtoctavio/vhal

Game Server:
schmidtoctavio/vhal_game_server

Backend:
schmidtoctavio/vhal_backend
```

---

# 3. BASELINES CANÓNICOS ACTUALES

## Cliente / memoria

Baseline previo al próximo commit documental:

```text
cc9d528add6976cb53d6108a67ac9ff313d68298
Project memory 2
```

Padre relevante:

```text
557bee80258d09cfbc9084e42213d14caefd9b85
docs: close F19 vertical slice and record future systems
```

F20 y F21-A no requirieron cambios de gameplay en el cliente para ownership durable porque el contrato de skills autoritativas y `PlayerRuntimeState.apply_skill_snapshot()` ya soportaban listas vacías y ownership parcial.

## Game Server

Baseline actual:

```text
598d993eeff80aaf5fd84ca7413a04772ee4faab
feat: bootstrap skills from durable ownership
```

Cadena reciente:

```text
f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime

fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect

2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave

598d993eeff80aaf5fd84ca7413a04772ee4faab
feat: bootstrap skills from durable ownership
```

## Backend

Baseline actual:

```text
29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership
```

Cadena reciente relevante:

```text
1ae3036031bd8d2e8fb6289c94df4d2869c6e23
fix: include experience in game session ticket

55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence

29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership
```

---

# 4. ARQUITECTURA CANÓNICA

```text
┌─────────────────────┐
│    GODOT CLIENT     │
│ intención + UI      │
│ representación      │
└──────────┬──────────┘
		   │ ENet
		   ▼
┌─────────────────────┐
│  GODOT GAME SERVER  │
│ autoridad gameplay  │
│ estado runtime      │
└──────────┬──────────┘
		   │ HTTP interno
		   ▼
┌─────────────────────┐
│   LARAVEL BACKEND   │
│ identidad + API     │
│ persistencia        │
└──────────┬──────────┘
		   ▼
┌─────────────────────┐
│        MYSQL        │
│ durable storage     │
└─────────────────────┘
```

Responsabilidades:

```text
Cliente
= intención + representación

Game Server
= autoridad inmediata de gameplay/runtime

Backend
= identidad + API + operaciones durables

MySQL
= almacenamiento durable
```

El cliente nunca decide como verdad final:

```text
HP
MP
damage
cooldown
posición autoritativa
item placement definitivo
EXP
level
loot
pickup success
skill ownership
skill learning success
estado PvP
```

---

# 5. BACKEND FUERA DEL HOT LOOP

Regla crítica:

```text
Client intent
→ Game Server validation/mutation
→ authoritative result/events
→ clients
```

Incorrecto:

```text
cada frame / attack / cast
→ Laravel
→ MySQL
→ esperar
→ gameplay
```

Laravel participa cuando debe existir durabilidad o una operación transaccional durable.

Ejemplos:

```text
movement runtime
→ Game Server

HP/MP runtime
→ Game Server

autosave runtime
→ Backend

inventory durable mutation
→ Backend

learned skill durable mutation
→ Backend
```

---

# 6. INPUT CANÓNICO ESTILO MU

```text
LEFT CLICK drop
→ PICKUP

LEFT CLICK mob hostil
→ BASIC ATTACK PvE

LEFT CLICK NPC interactuable
→ INTERACT

LEFT CLICK terreno
→ MOVE

RIGHT CLICK
→ SELECTED SKILL según target_kind

CTRL + LEFT CLICK player
→ BASIC ATTACK PvP futuro

CTRL + RIGHT CLICK player
→ SELECTED SKILL PvP futuro
```

Basic Attack weapon-aware:

```text
sin arma
→ unarmed

sword / axe / etc.
→ melee

bow futuro
→ ranged
```

No renombrar protocolo:

```text
unarmed
```

`bronze_sword`:

```text
mode = melee
```

El cliente sólo solicita acción/entidad.

El Game Server resuelve:

```text
arma
modalidad
rango
damage
cooldown
```

Auto-chase permanece diferido a un checkpoint dedicado.

---

# 7. F19 — VERTICAL SLICE HEREDADO

**Estado:** ✅ CERRADO.

F19 dejó funcionalmente probado:

```text
Login
→ Character Select
→ Game Session Ticket
→ Game Server
→ World
→ Movement
→ Warehouse
→ Inventory / Vault / Equipment
→ Skill
→ Mob
→ Combat
→ Death
├── Drop → Pickup → MySQL
└── EXP → Level → MySQL / HUD
→ Respawn
→ Logout / Reconnect
```

Durable al cierre F19:

```text
Inventory
Equipment
Vault
Level
Experience
```

Runtime autoritativo ya existente:

```text
Skills
Vitals
Combat
Mobs
Drops mientras vive el GS
```

Pendientes que F19 dejó para después:

```text
Character Runtime durable
Skill Ownership durable
Skill Learning real
Economy
PvP/PK
WorldDrop durability tras restart GS
Merchant
Stats completos
más mapas/contenido
```

---

# 8. F20 — DURABLE CHARACTER RUNTIME

**Estado:** ✅ COMPLETADO, PROBADO Y PUSHEADO.

F20 hizo durable:

```text
map_id
position x/y/z
rotation_y
hp
mp
```

No duplicó:

```text
level
experience
```

porque pertenecen a Character Progression.

No persiste:

```text
max_hp
max_mp
```

porque el Game Server los rederiva de sus reglas actuales.

Sub-etapas:

```text
F20-A  Durable Runtime Backend        ✅
F20-B1 Runtime Restore                ✅
F20-B2 Disconnect Checkpoint          ✅
F20-C  Periodic Autosave / Crash      ✅
```

---

# 9. F20-A — BACKEND RUNTIME DURABLE

Relación:

```text
characters
	1
	│
	1
character_runtime_states
```

Campos:

```text
character_id PK/FK
map_id
position_x
position_y
position_z
rotation_y
hp
mp
revision
timestamps
```

Endpoint:

```text
PUT /api/internal/accounts/{accountId}/characters/{characterId}/runtime-state
```

Revisionado:

```text
no existe runtime
expected_revision = 0
→ create revision 1

existe revision N
expected_revision = N
→ update revision N+1

expected_revision stale
→ 409
```

Idempotencia:

```text
mismo estado / replay válido
→ idempotent = true
→ no bump artificial
```

Concurrencia:

```text
DB transaction
Character lock
Runtime lock cuando existe
```

Ticket incluye:

```text
character.runtime
├── revision
├── world
│   ├── map_id
│   ├── position
│   └── rotation_y
└── vitals
	├── hp
	└── mp
```

Personaje sin checkpoint:

```text
runtime = null
```

Tests:

```text
InternalCharacterRuntimeStateTest
5 passed / 63 assertions

InternalCharacterProgressionTest
5 passed / 23 assertions
```

Commit:

```text
55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence
```

---

# 10. F20-B1 — RESTORE

`PlayerWorldSession` construye foundation y después aplica override durable.

```text
foundation
→ durable override
```

Restaura:

```text
map_id
position
rotation_y
hp
mp
runtime_revision
```

HP/MP se aplican con primitives de `ServerVitalsState`, por lo que quedan clampados contra máximos actuales.

Diferencia crítica:

```text
runtime = null
→ válido
→ usar foundation

runtime presente pero malformado
→ bootstrap inválido
```

Prueba real:

```text
revision 1
position (1,0,1)
rotation_y 1.25
hp 87654
mp 222
```

restauró exactamente en GS y cliente.

Commit:

```text
f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime
```

---

# 11. F20-B2 — DISCONNECT CHECKPOINT

Flujo:

```text
peer disconnect
→ capturar snapshot durable inmediatamente
→ iniciar persistencia async
→ notify_presence_left
→ remove_session
→ Backend confirma copia capturada
```

No dejar PlayerWorldSession fantasma esperando HTTP.

Componentes principales:

```text
core/backend/backend_character_runtime_state_repository.gd
app/coordinators/character_runtime_state_coordinator.gd
```

Snapshot persistente:

```text
world
├── map_id
├── position
└── rotation_y

vitals
├── hp
└── mp
```

No incluye:

```text
max_hp
max_mp
level
experience
```

Prueba real B2:

```text
revision 1
↓
movement (-2.420902,0,1.101203)
Heal
HP 100000
MP 182
↓
disconnect
↓
revision 2
↓
reconnect exacto
```

Commit:

```text
fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect
```

---

# 12. F20-C — PERIODIC AUTOSAVE + CRASH RECOVERY

Política:

```text
AUTOSAVE_INTERVAL_MSEC = 30000
AUTOSAVE_JITTER_MSEC = 5000
AUTOSAVE_SCAN_INTERVAL_SECONDS = 1.0
AUTOSAVE_RETRY_DELAY_MSEC = 5000
```

Conceptualmente:

```text
cada ~30–35 segundos por sesión
→ considerar autosave
```

No escribe sin cambios.

Compara:

```text
map_id
position
rotation_y
hp
mp
```

Sin cambio:

```text
NO HTTP
NO MySQL write
```

Con cambio:

```text
autosave
→ persist
→ revision N → N+1
→ actualizar baseline
```

Race autosave + disconnect:

```text
autosave pendiente
+
disconnect
→ capturar snapshot final
→ encolar final checkpoint
→ quitar sesión/presencia normalmente
→ confirmar autosave
→ usar nueva revision
→ persistir snapshot final encolado
```

Prueba explícita de hard crash:

```text
autosave revision 5 → 6
position guardada (-0.363776,0,1.591599)
↓
movimiento posterior (-5.691637,0,-1.650471)
↓
Game Server hard-stop
↓
restart
↓
revision 6
position (-0.363776,0,1.591599)
```

Resultado correcto:

```text
último autosave confirmado
→ durable

cambios posteriores
→ pueden perderse ante crash abrupto
```

Commit:

```text
2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

---

# 13. DURABILIDAD ACTUAL DESPUÉS DE F20 + F21-A

Durable real por personaje/cuenta según dominio:

```text
Inventory
Equipment
Vault
Level
Experience
Map ID
Position
Rotation Y
HP
MP
Learned Skill Ownership
```

Separación de dominios:

```text
Inventory / Equipment / Vault
→ persistent item/container domain

Level / EXP
→ Character Progression domain

Map / Position / Rotation / HP / MP
→ Character Runtime State domain

Learned Skills
→ Character Skill Ownership domain
```

No fusionar dominios sólo porque pertenecen al mismo Character.

---

# 14. ESTADO DELIBERADAMENTE RUNTIME-ONLY

Todavía NO sobrevive a un restart completo del Game Server:

```text
WorldDrops no recogidos
mob runtime actual
mob HP actual
cooldowns activos
combat temporal
NPC service runtime
movement path activo
runtime request IDs
```

WorldDrop actual:

```text
reconnect mientras GS vive
→ persiste en runtime

restart GS
→ desaparece
```

Limitación aceptada por diseño actual.

---

# 15. F21-A — DURABLE SKILL OWNERSHIP

**Estado:** ✅ COMPLETADO, PROBADO Y PUSHEADO.

Objetivo cumplido:

> retirar el bootstrap temporal que concedía todas las foundation skills a todos los personajes y reemplazarlo por ownership durable real por Character.

Sub-etapas:

```text
F21-A1 Backend durable ownership           ✅
F21-A2 Game Server bootstrap ownership     ✅
F21-A3 Reconnect/per-character audit       ✅
```

---

# 16. F21-A1 — BACKEND DURABLE SKILL OWNERSHIP

## Modelo

No se usan columnas por skill:

```text
fire_ball = true
heal = false
...
```

Tampoco JSON de ownership dentro de `characters`.

Modelo normalizado:

```text
characters
	1
	│
	N
character_skills
```

Tabla:

```text
id
character_id FK → characters.id
skill_id varchar(64)
timestamps
UNIQUE(character_id, skill_id)
```

Un row significa:

```text
este Character posee/aprendió este skill_id
```

Delete Character:

```text
ON DELETE CASCADE
→ elimina ownerships
```

## Autoridades

Laravel persiste:

```text
stable skill_id ownership
```

Laravel NO duplica el catálogo semántico del Game Server.

El Game Server sigue siendo autoridad de:

```text
si skill_id existe
qué target_kind tiene
MP cost
cooldown
efecto
requisitos de gameplay futuros
```

## Endpoint interno

```text
POST /api/internal/accounts/{accountId}/characters/{characterId}/skills
```

Payload:

```json
{
  "skill_id": "heal"
}
```

Primer grant:

```text
201
idempotent = false
```

Retry exacto:

```text
200
idempotent = true
```

La unique constraint es defensa final contra duplicados.

## Componentes Backend

```text
app/Models/CharacterSkill.php
app/Application/Skills/CharacterSkillOwnershipPersistence.php
app/Http/Controllers/Api/InternalCharacterSkillController.php
database/migrations/2026_08_26_165645_create_character_skills_table.php
tests/Feature/InternalCharacterSkillTest.php
```

`Character.php` agrega:

```text
hasMany CharacterSkill
```

## Ticket de sesión

El ticket incluye ahora:

```json
"skills": {
  "learned_skill_ids": ["heal", "poison"]
}
```

Ordenado/canónico.

Forma conceptual actual:

```text
character
├── id
├── slot_index
├── name
├── class_id
├── level
├── experience
├── skills
│   └── learned_skill_ids
└── runtime
```

## Tests F21-A1

```text
InternalCharacterSkillTest
6 passed / 23 assertions
```

Casos validados:

```text
persist learned skill
retry idempotente
mismo skill en Characters distintos
auth/account-character boundary
ticket contiene ownership durable
cascade delete ownership
```

Regresiones:

```text
InternalCharacterRuntimeStateTest
5 passed / 63 assertions

InternalCharacterProgressionTest
5 passed / 23 assertions
```

Migración real aplicada:

```text
2026_08_26_165645_create_character_skills_table
DONE
```

Commit Backend:

```text
29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership
```

---

# 17. F21-A2 — GAME SERVER BOOTSTRAP FROM OWNERSHIP

**Estado:** ✅ COMPLETADO.

Antes:

```text
ServerCharacterRuntimeBootstrap
→ ServerSkillCatalog.get_all_skill_ids()
→ aprende todas las skills
→ todos los personajes reciben todo
```

Eso fue eliminado.

Ahora:

```text
MySQL character_skills
↓
Laravel ticket
↓
character.skills.learned_skill_ids
↓
PlayerWorldSession
↓
ServerCharacterRuntimeBootstrap
↓
ServerSkillRuntimeState.learn_skill(skill_id)
↓
world_snapshot
↓
cliente
```

Archivos modificados:

```text
core/combat/server_character_runtime_bootstrap.gd
core/world/player_world_session.gd
```

## Validación

`PlayerWorldSession` requiere estructura válida:

```text
skills
└── learned_skill_ids Array
```

Cada ID se:

```text
trim
lowercase
reject empty
reject duplicate
```

Luego:

```text
ServerSkillRuntimeState.learn_skill()
→ valida contra ServerSkillCatalog
```

Un skill desconocido no se convierte silenciosamente en autoridad válida.

## Estado con cero skills

Es válido:

```text
learned_skill_ids = []
```

Produce:

```text
ServerSkillRuntimeState vacío
world_snapshot Skills: []
cliente SkillBook vacío
Hotbar vacía
```

No es error.

## Cliente

No se necesitó cambio.

`PlayerRuntimeState.apply_skill_snapshot()` ya soportaba:

```text
[]
["heal"]
subsets del catálogo
```

Reconstruye únicamente definitions conocidas por `ClientSkillCatalog`.

Hotbar default sólo coloca skills realmente aprendidas.

## Primer test A2 — ownership vacío

DB:

```text
character_skills count = 0
```

Game Server:

```text
Atilio
Skills: []
```

Cliente:

```text
Skills: []
Learned: 0
Hotbar slots: 0
Hotbar seleccionada: VACÍA
```

Y continuaron correctos:

```text
Runtime revision 6
HP 100000/100000
MP 142/350
Level 123
EXP 50/100
Inventory 5
Equipment 1
```

## Segundo test A2 — ownership Heal

Se persistió manualmente por la capa durable:

```text
Character 1
→ heal
```

DB:

```text
character_id = 1
skill_id = heal
```

Nuevo login:

```text
Game Server
Skills: ["heal"]

Cliente
Learned: 1
Hotbar slots: 1
Hotbar: Heal
```

## Cast real de Heal

Antes:

```text
MP 142/350
```

Cast:

```text
Skill: heal
Target: self
Accepted: true
Reason: ok
Cooldown: 4.0
```

Después:

```text
MP 102/350
```

HP ya estaba full:

```text
Heal amount = 0
```

Correcto.

F20 autosave capturó la mutación:

```text
Reason: autosave
Revision 6 → 7
MP 102
```

Commit Game Server:

```text
598d993eeff80aaf5fd84ca7413a04772ee4faab
feat: bootstrap skills from durable ownership
```

---

# 18. F21-A3 — RECONNECT + OWNERSHIP PER CHARACTER

**Estado:** ✅ COMPLETADO.

No requirió código nuevo.

Fue una auditoría funcional integrada.

## Character 1 — Atilio

```text
id: 1
class: warrior
level: 123
experience: 50
skills: ["heal"]
```

Reconnect después del commit A2:

```text
WorldSessionRegistry
Skills: ["heal"]
Runtime revision: 7

Client
Skills: ["heal"]
Learned: 1
Hotbar slots: 1
Hotbar: Heal
```

Esto demostró que Heal no vivía accidentalmente sólo en memoria del GS.

## Character 2 — Lyra

Personaje existente de la misma cuenta:

```text
id: 2
class: archer
level: 85
experience: 0
```

Inicialmente:

```text
skills: []
```

Login:

```text
Game Server
Skills: []

Client
Learned: 0
Hotbar slots: 0
Hotbar: VACÍA
```

Esto demostró:

```text
ownership por Character
≠ ownership por Account
```

## Ownership distinto para Lyra

Se persistió:

```text
Character 2
→ poison
```

DB final del audit:

```text
Character 1 → heal
Character 2 → poison
```

Login Lyra:

```text
Game Server
Skills: ["poison"]

Client
Learned: 1
Hotbar slots: 1
Hotbar: Poison
```

## Poison cast audit

Primer intento sin target:

```text
Cast omitido
Reason: entity_target_required
```

Correcto según target_kind.

Con Training Goblin seleccionado:

```text
Skill: poison
Target: entity
```

Game Server:

```text
Target autoritativo validado
Entity: mob_test_town_001
Type: mob
HP: 5000/5000
```

Resultado:

```text
Accepted: false
Reason: skill_not_implemented
Cooldown: 0
```

Esto es CORRECTO para la etapa.

Significa:

```text
ownership pasó validación
entity target pasó validación
↓
el efecto todavía no está implementado
```

No devolvió:

```text
skill_not_learned
```

porque Lyra sí posee Poison durablemente.

MP permaneció:

```text
350/350
```

El audit final Atilio volvió a confirmar sólo:

```text
["heal"]
```

sin contaminación desde Lyra.

---

# 19. RESULTADO CANÓNICO DE F21-A

F21-A queda cerrado con este comportamiento:

```text
Character A
DB ownership A
→ Ticket A
→ GS Runtime A
→ Client SkillBook A

Character B
DB ownership B
→ Ticket B
→ GS Runtime B
→ Client SkillBook B
```

Misma cuenta puede contener personajes con ownership completamente distinto.

Ejemplo auditado:

```text
Account 1
├── Atilio / Character 1
│   └── heal
└── Lyra / Character 2
	└── poison
```

No existen auto-grants de todas las foundation skills en flujo normal.

Estado:

```text
Skill Runtime authority           ✅
Skill IDs enviados por GS         ✅
Client no auto-concede            ✅
Skill Ownership durable real      ✅
Per-character isolation           ✅
Reconnect ownership               ✅
Skill Learning real               ❌ siguiente bloque
```

---

# 20. SKILLS FOUNDATION ACTUALES

Definitions foundation:

```text
fire_ball
poison
heal
```

Estado funcional:

```text
Heal
→ implementado autoritativamente
→ self target
→ consume MP
→ cooldown autoritativo
→ replica vitals

Fire Ball
→ definition/runtime/protocol foundation
→ efecto todavía skill_not_implemented

Poison
→ definition/runtime/protocol foundation
→ entity target validado
→ efecto todavía skill_not_implemented
```

No expandir Fire Ball/Poison por inercia mientras se trabaja F21-B.

---

# 21. F21-B — SIGUIENTE BLOQUE RECOMENDADO

Nombre:

```text
F21-B — Durable Skill Learning Foundation
```

Objetivo:

> permitir que un personaje aprenda realmente una skill mediante una acción de gameplay validada por el Game Server y persistida de forma durable, reutilizando el ownership de F21-A.

Dirección canónica:

```text
Skill Scroll / Book
+
compatible Trainer NPC
+
class requirement
+
minimum level
+
minimum stats
+
skill not already learned
↓
Game Server validation
↓
durable learned skill
↓
ServerSkillRuntimeState
↓
Client SkillBook / Hotbar
```

No permitir:

```text
Client
→ "ya aprendí esta skill"
```

como verdad consumada.

## División recomendada de F21-B

No implementar todo de golpe.

Propuesta:

```text
F21-B1 — Skill learning definitions / requirements contract
F21-B2 — Scroll/Book item foundation
F21-B3 — Trainer compatibility + learn request protocol
F21-B4 — Durable learn transaction
F21-B5 — Runtime replication after learn
F21-B6 — Integrated reconnect audit
```

La división exacta debe confirmarse revisando repositorios antes de programar.

---

# 22. REQUISITOS CANÓNICOS DE SKILL LEARNING

Una skill futura puede requerir:

```text
skill_id
required_scroll_item_id
allowed_classes
minimum_level
minimum_stats
compatible_trainer_service / trainer tags
```

No duplicar requisitos en UI.

Fuente deseada:

```text
ServerSkillCatalog / server-side definitions
```

o un catálogo autoritativo equivalente.

Cliente puede tener metadata visual, pero no autoridad final.

## Stats

El sistema de stats completos todavía no está implementado.

Por eso F21-B debe diseñarse para soportar requisitos futuros sin obligarnos a construir todo Stats ahora.

Se puede empezar con foundation como:

```text
class
level
scroll
trainer
```

y reservar estructura para stats si corresponde.

No inventar un sistema de stats paralelo sólo para aprender skills.

---

# 23. SCROLL / BOOK — DIRECCIÓN CANÓNICA

Un Skill Scroll/Book debe ser un ItemDefinition / ItemInstance real.

Flujo deseado:

```text
Drop/content
→ Skill Scroll ItemInstance
→ Inventory durable
→ Trainer interaction
→ Learn Skill request
```

No crear una lista de scrolls separada del sistema de items.

Debe convivir con:

```text
InventoryData
ItemDefinition
ItemInstance
persistent UID
```

Decisión pendiente a resolver durante F21-B:

```text
¿el scroll se consume siempre?
¿se consume sólo si learn durable confirma?
¿hay scrolls reusables?
```

Regla transaccional recomendada si es consumible:

```text
VALIDAR
→ PERSISTIR OWNERSHIP + CONSUMIR ITEM de forma segura
→ recién después confirmar aprendizaje
```

Nunca:

```text
consumir scroll
→ falla persistencia ownership
→ jugador pierde item sin aprender
```

---

# 24. TRAINER — DIRECCIÓN CANÓNICA

Trainer puede servir:

```text
una clase
varias clases
```

No obligar un NPC por clase.

Un Trainer debería poder informar:

```text
skills compatibles
scroll requerido
level requerido
stats requeridos
si el personaje cumple
mapas donde obtener scroll
mobs/content que pueden dropearlo
```

La información debe derivarse de catálogos/definitions/drop content.

No hardcodear textos divergentes en UI.

## Importante

F21-A NO construyó Trainer.

Trainer comienza recién en F21-B cuando el contrato de learning esté definido.

---

# 25. ECONOMÍA — DIRECCIÓN CANÓNICA

No usar como nombre final:

```text
Zen
```

`CurrencyState` sigue siendo placeholder técnico genérico.

Nombre/iconografía/lore final pendiente.

Economía futura:

```text
saldo durable
recompensas
merchant
buy/sell
servicios pagos
trainer fees si aplica
Priest confession
trade futuro
fees/taxes futuros
```

Autoridad:

```text
Client
→ intención

Game Server
→ contexto/reglas

Backend
→ operación durable/atómica
```

No mezclar Economy automáticamente dentro de F21-B si no es necesaria para el primer learning slice.

---

# 26. PvP / PK / SIN — DIRECCIÓN CANÓNICA

Estados previstos:

```text
Inocente
→ Diablillo
→ Delincuente
→ Pecador / Sinner
```

Thresholds definitivos pendientes.

Auto-defense:

```text
A agrede primero a B
→ GS registra aggression context
→ B puede defenderse según reglas
```

Auto-defense:

```text
runtime Game Server
```

Estado criminal:

```text
durable Backend
```

Sinner futuro:

```text
tint rojo autoritativo
body/armor/weapon/wings/main appearance
```

Redención:

```text
Priest confession
→ costo currency
```

y alternativa más lenta:

```text
PvE válido
→ reduce pecado progresivamente
```

PvP debe construirse sobre Combat como dominio propio.

No meter toda la lógica dentro de `BasicAttackCoordinator`.

---

# 27. WORLD DROPS

Actual:

```text
runtime autoritativo GS
persistent server-only item UID
same-map replication
pickup durable
```

Training Goblin foundation:

```text
Health Potion x1
100% drop para testing
```

Pickup durable mantiene regla:

```text
PERSIST INVENTORY
→ confirmación
→ CONSUME WORLD DROP
```

No invertir ese orden.

Tras restart GS:

```text
world drops runtime desaparecen
```

Aceptado por ahora.

---

# 28. COMBAT FOUNDATION

Basic Attack:

```text
unarmed
→ damage 500 foundation
→ range 1.5
→ cooldown 1.0

bronze_sword melee
→ damage 1000 foundation
→ range 2.0
→ cooldown 0.9
```

Training Goblin:

```text
HP 5000
EXP reward 50
Health Potion x1
respawn 3 s
```

Rango:

```text
XZ center-to-center
```

Cliente nunca decide:

```text
weapon mode
range
damage
cooldown
```

Future chase/out-of-range click:

```text
checkpoint dedicado
```

---

# 29. PROGRESSION FOUNDATION

Regla foundation actual:

```text
100 EXP por level
```

Training Goblin:

```text
+50 EXP
```

F18 validó level-up durable.

Ejemplo histórico:

```text
Level 122 / EXP 50
+50
→ Level 123 / EXP 0
```

F21-A regression mantuvo Progression intacta.

No mezclar skill ownership con level/EXP persistence.

---

# 30. INVENTORY / EQUIPMENT / VAULT

Foundation durable:

```text
Inventory ✅
Equipment ✅
Vault ✅
```

F15-C sigue diferido para:

```text
stack merge autoritativo
stack split
partial quantity transfer
sort autoritativo
consumables
durability
item-specific state avanzado
```

No construirlos sin necesidad funcional concreta.

Health Potion existe pero todavía debe obtener un pipeline real de `use item` apoyado en Vitals autoritativos.

Flujo futuro correcto:

```text
use item intent
→ GS validate item/quantity
→ shared vitals/effects pipeline
→ durable quantity mutation
→ replicate inventory + vitals
```

---

# 31. UI — REGLAS VIGENTES

Ventanas principales:

```text
tamaño fijo
draggable
no resize
no salir del viewport
```

No volver al plan antiguo de resize/expand/contract.

Inventario:

```text
compacto
MU-like footprint
celdas/gaps pequeños
Equipment compacto
```

Inspiración funcional MU no significa copiar identidad visual.

VHAL debe mantener identidad propia.

---

# 32. PERFORMANCE

Regla:

```text
Refactor ≠ Optimization
```

No optimizar sin medir.

F20 ya evitó una mala práctica crítica:

```text
NO persistir position por frame
```

Usa:

```text
runtime in-memory
+
checkpoint periódico
```

PERF-1 futuro:

```text
measure
→ bottleneck
→ change one thing
→ measure again
```

Métricas posibles:

```text
Client → GS RTT
GS validation time
GS → Backend RTT
Laravel time
DB transaction time
serialization
packet size
checkpoint rate
concurrent autosave distribution
```

---

# 33. ARQUITECTURA DE COMPONENTES — GAME SERVER

Estructura conceptual vigente:

```text
PlayerWorldSession
→ almacena/compone estado de la sesión

Coordinators
→ orquestan flujos

Domain/runtime state classes
→ invariantes/estado especializado

Repositories
→ HTTP Backend

Registries
→ entidades/runtime de mundo
```

No convertir:

```text
PlayerWorldSession
main.gd
BasicAttackCoordinator
```

en God Objects.

F20 agregó/reafirmó:

```text
CharacterRuntimeStateCoordinator
BackendCharacterRuntimeStateRepository
```

F21-A reutilizó la composición existente sin crear un SkillOwnershipManager gigante.

---

# 34. CRITERIO DE SISTEMA “REAL”

Un sistema se considera real cuando:

```text
la intención nace donde corresponde
la autoridad está definida
GS valida gameplay
runtime muta correctamente
persistencia ocurre donde corresponde
resultado vuelve al cliente
reconnect/recovery funciona cuando aplica
edge cases principales están probados
no depende de shortcut debug en flujo normal
```

F20 cumple este criterio para Character Runtime durable.

F21-A cumple este criterio para Skill Ownership durable.

F21-B deberá cumplirlo para Skill Learning.

---

# 35. ROADMAP CANÓNICO ACTUAL

```text
F00-F14 Foundation               ✅
F15-A Inventory ↔ Vault         ✅
F15-B Equipment                 ✅
F15-R Architectural Refactor    ✅
F15-C Item operations           🟡 evaluado / diferido

F16-A Skill runtime             ✅
F16-B Cast protocol             ✅
F16-BR Input MU correction      ✅
F16-C Authoritative Heal        ✅
F16-D Cooldown visual/UI        ✅

F17-A Mob runtime               ✅
F17-B Mob replication           ✅
F17-C Entity targeting          ✅
F17-D Basic Attack PvE          ✅
F17-E Basic Attack execution    ✅
F17-F Mob death transition      ✅
F17-G Mob respawn foundation    ✅

F18-A1 World Drop runtime       ✅
F18-A2 Drop replication/UI      ✅
F18-B1 Durable Inventory grant  ✅
F18-B2 Authoritative Pickup     ✅
F18-C1 Durable Progression      ✅
F18-C2A EXP runtime             ✅
F18-C2B Progression HUD         ✅

F19-A Real gameplay bootstrap   ✅
F19-B Integrated slice audit    ✅
F19 Vertical Slice              ✅

F20-A Durable Runtime Backend   ✅
F20-B1 Runtime restore          ✅
F20-B2 Disconnect checkpoint    ✅
F20-C Periodic autosave         ✅
F20 Durable Character Runtime   ✅

F21-A1 Backend Skill Ownership  ✅
F21-A2 GS Ownership Bootstrap   ✅
F21-A3 Per-character Audit      ✅
F21-A Durable Skill Ownership   ✅

F21-B Durable Skill Learning    ⏳ SIGUIENTE

Skill Scroll content            ⏳ dentro/evolución F21-B
Trainer learning flow           ⏳ dentro/evolución F21-B
Economy / VHAL currency         ⏳ futuro
PvP / PK / Sin                  ⏳ futuro
World/content expansion         ⏳ futuro
Merchant                        ⏳ futuro
Stats completos                 ⏳ futuro
WorldDrop durability            ⏳ futuro si se necesita

PERF-1                          ⏳ después de base estable
```

No abrir simultáneamente varios bloques grandes post-F21-A.

---

# 36. CHECKPOINTS IMPORTANTES

## F19 docs / vertical slice

```text
557bee80258d09cfbc9084e42213d14caefd9b85
docs: close F19 vertical slice and record future systems
```

## F20 Backend

```text
55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence
```

## F20 Game Server restore

```text
f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime
```

## F20 Game Server disconnect

```text
fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect
```

## F20 Game Server autosave

```text
2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

## PROJECT MEMORY 2 inicial

```text
cc9d528add6976cb53d6108a67ac9ff313d68298
Project memory 2
```

## F21-A Backend ownership

```text
29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership
```

## F21-A Game Server bootstrap

```text
598d993eeff80aaf5fd84ca7413a04772ee4faab
feat: bootstrap skills from durable ownership
```

F21-A3 fue auditoría sin código adicional.

---

# 37. PRUEBAS CLAVE ACTUALES

## Backend F21-A

```text
InternalCharacterSkillTest
6 passed / 23 assertions

InternalCharacterRuntimeStateTest
5 passed / 63 assertions

InternalCharacterProgressionTest
5 passed / 23 assertions
```

## Ownership vacío

```text
DB []
→ GS Skills []
→ Client Learned 0
→ Hotbar 0
```

## Ownership Atilio

```text
DB Character 1 → heal
→ GS ["heal"]
→ Client Learned 1
→ Heal cast Accepted true
→ MP 142 → 102
→ Runtime autosave revision 6 → 7
```

## Ownership Lyra

```text
DB Character 2 → poison
→ GS ["poison"]
→ Client Learned 1
→ target mob validado
→ skill_not_implemented
```

Correcto porque Poison todavía no implementa efecto.

## Isolation audit

```text
Atilio → heal
Lyra   → poison
```

Cambiar entre Characters no mezcló SkillBook/Hotbar/ownership.

---

# 38. ESTADO FUNCIONAL CANÓNICO ACTUAL

Vertical slice actual:

```text
Login
→ Character Select
→ Game Session Ticket
→ Durable Skill Ownership bootstrap
→ Durable Character Runtime Restore
→ Game Server World
→ Movement
→ Warehouse
→ Inventory / Vault / Equipment
→ Skill Runtime
→ Mob
→ Combat
→ Death
├── Drop
│   → Pickup
│   → ItemInstance MySQL
│   → Inventory
└── EXP
	→ Level
	→ MySQL
	→ HUD
→ Respawn
→ Periodic Runtime Autosave
→ Disconnect
→ Final Runtime Checkpoint
→ Reconnect
→ Durable Reconstruction
```

Durable hoy:

```text
Inventory
Equipment
Vault
Level
Experience
Map
Position
Rotation
HP
MP
Skill Ownership
```

Runtime pero no durable tras GS restart:

```text
WorldDrops
mob runtime
cooldowns activos
combat temporal
NPC service runtime
```

No implementado todavía:

```text
real Skill Learning
Fire Ball effect
Poison effect
consumable use
Economy
PvP/PK
Merchant real
full Stats
multi-map content real
```

---

# 39. DECISIONES QUE NO DEBEN REGRESIONAR

No volver a:

```text
auto-conceder todas las skills
```

No mover ownership al cliente.

No almacenar ownership como columnas booleanas por skill.

No duplicar ServerSkillCatalog en Laravel.

No meter Backend en cada cast/attack.

No persistir movement por frame.

No guardar max_hp/max_mp como verdad durable actual.

No mezclar Character Progression con Runtime State.

No mezclar Skill Ownership con Skill Runtime.

No convertir `PlayerWorldSession` en monolito.

No usar `Zen` como moneda final.

No reactivar resize de ventanas.

No hacer auto-chase dentro de otro scope accidentalmente.

No convertir WorldDrops a DB sin necesidad concreta.

---

# 40. SIGUIENTE PASO EXACTO

F21-A quedó funcionalmente cerrado.

Antes de abrir F21-B:

```text
reemplazar PROJECT_MEMORY_2.md completo
↓
git status en cliente vhal
↓
confirmar que sólo cambió PROJECT_MEMORY_2.md
↓
commit documental
↓
push dev
↓
esperar "pusheado"
↓
verificar remoto
↓
recién entonces abrir F21-B
```

Commit documental sugerido:

```text
docs: close F21 durable skill ownership
```

No abrir código de F21-B antes del checkpoint documental pusheado.

---

# 41. ESTADO FINAL DEL VOLUMEN 2 EN ESTE CHECKPOINT

Últimas etapas cerradas:

```text
F19 — Vertical Slice                    ✅
F20 — Durable Character Runtime         ✅
F21-A — Durable Skill Ownership         ✅
├── F21-A1 Backend ownership            ✅
├── F21-A2 Game Server bootstrap        ✅
└── F21-A3 Reconnect/per-character      ✅
```

Siguiente etapa:

```text
F21-B — Durable Skill Learning          ⏳
```

Regla operativa:

> Primero cerrar y pushear este documento canónico. Después revisar repositorios reales y diseñar F21-B en etapas pequeñas antes de modificar código.

---
