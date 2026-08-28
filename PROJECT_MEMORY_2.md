# VHAL — PROJECT MEMORY 2 / CONTINUIDAD CANÓNICA

**Volumen:** 2  
**Última actualización:** 28/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  
**Estado general:** F19 Vertical Slice ✅, F20 Durable Character Runtime ✅, F21-A Durable Skill Ownership ✅, F21-B Durable Skill Learning ✅.  
**Siguiente paso:** gate de planificación F22; elegir un único sistema siguiente después de revisar roadmap y repositorios reales.

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
- no convertir cada etapa en un refactor general si no lo necesita;
- si una etapa revela una deuda real, se corrige antes del commit;
- no aceptar warnings "porque funciona": objetivo habitual `0 warnings / 0 errors`.

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

## Cliente

Head funcional previo a este commit documental:

```text
8eb5cf9da711655994cfbcaaa75f25218629a542
feat: preserve skill trainer position on refresh
```

Cadena reciente relevante:

```text
09b84327f9028b6c8a4cbb213c6aa14ec3792a22
docs: close F21 durable skill ownership

e2808b32156887cbb66f13713b68b3204a42655c
feat: add client skill learning protocol

a274d1a62f59aa7e27c22d1f52491389b9b34c4d
feat: add skill trainer to client world

e414a24b7137e3ff4cfe2fce8be6990fd4b6f853
feat: add skill scroll client definitions

327c3370aad874b236490adb2fbd9e8c727a79af
feat: connect skill scroll learning flow

984d0da6345404cf3adc84e11cc5b525f44b1b48
feat: receive authoritative skill trainer offers

fd67e19e89471e2946da0e8b382ec339c183504d
feat: add authoritative skill trainer window

bfb39eea4751ff6015d0935507704614c9745b3e
feat: route skill learning through trainer

5399334957b852af582cdc047cd64d67d1cf7c2d
feat: apply learned skills to live runtime

8eb5cf9da711655994cfbcaaa75f25218629a542
feat: preserve skill trainer position on refresh
```

Nota:

```text
327c337...
```

creó un camino temporal de aprendizaje desde doble click de Scroll.

Ese camino fue retirado posteriormente en:

```text
bfb39ee...
```

La arquitectura final NO aprende Skills desde Inventory.

## Game Server

Head funcional actual:

```text
968c1a19ea01b04d61b721ee59929fd55c036339
feat: recover skill trainer after learning rejection
```

Cadena F21-B relevante:

```text
25cd9f68bf68212cd6599998ac9424de96967a04
feat: add skill learning contract

2a60147bd2cacccc98c884918f48a97e7f977868
feat: add skill learning backend repository

9535f9e33081728622a0eb668e30a54a364b56e1
feat: add authoritative skill learning validation

df7bcb3a757365a9e2f35cda9bb5b377bd8a3e82
feat: apply durable skill learning to runtime

a953194e26ba8b1fd746314defa2b2b201b017ab
feat: add skill trainer npc

2efc2ceaab8a8150541fe727f1e461187d0ba190
feat: add skill learning network protocol

9b389b7fe7f5e83e892b09533e89dd982279a2d3
feat: build authoritative skill trainer offers

2734b652f10ed30a005b6fd4e329867b07e04405
feat: send authoritative skill trainer offers

ba41cee395573fbfc3a8cbc43ecff1ba357dad88
feat: refresh skill trainer offers after learning

968c1a19ea01b04d61b721ee59929fd55c036339
feat: recover skill trainer after learning rejection
```

## Backend

Head funcional actual:

```text
64be9a85e90ec6a07f1cb1b47d0c21c670f7dc18
feat: add atomic durable skill learning
```

Cadena reciente relevante:

```text
55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence

29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership

64be9a85e90ec6a07f1cb1b47d0c21c670f7dc18
feat: add atomic durable skill learning
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
skill eligibility
trainer eligibility
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

Laravel participa cuando debe existir durabilidad o una operación durable/transaccional.

Ejemplos:

```text
movement runtime
→ Game Server

HP/MP runtime
→ Game Server

basic attack
→ Game Server

skill cast
→ Game Server

autosave runtime
→ Backend

inventory durable mutation
→ Backend

skill ownership durable mutation
→ Backend

skill learning transaction
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

F19 dejó probado:

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

F19 dejó para después:

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

F20 resolvió Character Runtime durable.

F21-A resolvió Skill Ownership durable.

F21-B resolvió Skill Learning real.

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

HP/MP se aplican con primitives de `ServerVitalsState`.

```text
runtime = null
→ válido
→ usar foundation

runtime presente pero malformado
→ bootstrap inválido
```

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

No dejar `PlayerWorldSession` fantasma esperando HTTP.

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

Hard crash:

```text
último autosave confirmado
→ durable

cambios posteriores al último autosave
→ pueden perderse ante crash abrupto
```

Commit:

```text
2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

---

# 13. DURABILIDAD ACTUAL DESPUÉS DE F20

Durable:

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
```

Runtime no durable tras restart GS:

```text
WorldDrops
Mob runtime
cooldowns activos
combat temporal
NPC service runtime
```

---

# 14. F21-A — DURABLE SKILL OWNERSHIP

**Estado:** ✅ COMPLETADO.

Objetivo:

```text
Learned Skills
→ durable por Character
→ no por Account
→ restauradas en login
→ bootstrap autoritativo GS
```

Backend normalizó ownership en:

```text
character_skills
```

Contrato durable:

```text
character_id
skill_id
```

El Backend persiste identidad de ownership.

El Game Server conserva autoridad semántica de las Skills.

Ticket:

```text
skills.learned_skill_ids
```

El cliente NO auto-concede foundation skills.

Commit Backend:

```text
29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership
```

Commit Game Server:

```text
598d993eeff80aaf5fd84ca7413a04772ee4faab
feat: bootstrap skills from durable ownership
```

Docs de cierre:

```text
09b84327f9028b6c8a4cbb213c6aa14ec3792a22
docs: close F21 durable skill ownership
```

---

# 15. F21-A — REGLAS DE BOOTSTRAP

Game Server recibe exclusivamente IDs durables.

```text
["heal"]
["poison"]
[]
```

No existe:

```text
"si no viene nada, dar todas las foundation skills"
```

Unknown durable skill:

```text
fail closed
```

El Game Server no acepta silenciosamente un `skill_id` durable que no conozca.

Aislamiento probado:

```text
Account 1
├── Character 1 / Atilio
└── Character 2 / Lyra
```

El ownership pertenece al Character.

---

# 16. F21-A — AUDITORÍA PER CHARACTER

Atilio:

```text
class = warrior
ownership = heal
```

Lyra:

```text
class = archer
ownership independiente
```

Se probó que cambiar de Character no mezcla:

```text
SkillBook
Hotbar
ownership
```

---

# 17. SKILLS FOUNDATION ACTUALES

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

No expandir Fire Ball/Poison por inercia.

---

# 18. F21-B — DURABLE SKILL LEARNING

**Estado:** ✅ COMPLETADO, PROBADO Y PUSHEADO.

Objetivo alcanzado:

> un personaje puede aprender una Skill real mediante Scroll + Trainer, con validación autoritativa del Game Server y una transacción durable atómica en Backend.

Arquitectura final:

```text
Skill Scroll durable en Inventory
+
Skill Trainer compatible
+
class requirement
+
minimum level
+
skill no aprendida
↓
Game Server valida todo
↓
Backend transacción atómica
├── consume Scroll
└── crea character_skill
↓
Game Server actualiza runtime
↓
Client actualiza SkillBook/Hotbar
↓
Trainer refresca estado
```

El cliente nunca se auto-concede una Skill.

---

# 19. F21-B — DIVISIÓN FINAL REAL

La división que efectivamente se implementó quedó:

```text
F21-B1 Skill Learning Contract/Catalog            ✅
F21-B2 Atomic Learn Persistence Backend           ✅
F21-B3 GS Learn Skill Coordinator                 ✅
F21-B4 Trainer NPC + Protocol/Client UI           ✅
F21-B5 Integrated Durable Skill Learning Audit    ✅
```

Dentro de B4:

```text
B4-A  Skill Trainer NPC                           ✅
B4-B1 Server learning network protocol            ✅
B4-B2 Client learning network protocol            ✅
B4-C1 Trainer visible/interactable                ✅
B4-C2 Scrolls client definitions                  ✅
B4-C3 Temporary scroll learning route             ✅ luego retirado
B4-D1 Authoritative Trainer Offers                ✅
B4-D2 Skill Trainer Window                        ✅
B4-D3 Learn button → authoritative request        ✅
B4-D4 Live learning result → runtime/UI           ✅
B4-D5 Retire temporary route / cleanup            ✅
```

---

# 20. F21-B1 — SKILL LEARNING CONTRACT

Game Server agrega contrato semántico central.

Componentes:

```text
ServerSkillLearningDefinition
ServerSkillLearningCatalog
ServerItemCatalog
```

Servicio:

```text
trainer_service_id = "skill_trainer"
```

Foundation actual:

```text
Fire Ball
skill_id = fire_ball
scroll = skill_scroll_fire_ball
allowed_classes = [mage]
minimum_level = 10

Poison
skill_id = poison
scroll = skill_scroll_poison
allowed_classes = [archer]
minimum_level = 10

Heal
skill_id = heal
scroll = skill_scroll_heal
allowed_classes = [warrior, mage, archer]
minimum_level = 5
```

Stats:

```text
minimum_stats
→ diseño previsto
→ no implementado todavía
→ no inventar Stats paralelo sólo para learning
```

Validación de catálogo al startup:

```text
contrato inconsistente
→ fail closed
```

Commit:

```text
25cd9f68bf68212cd6599998ac9424de96967a04
feat: add skill learning contract
```

---

# 21. F21-B2 — ATOMIC DURABLE LEARNING BACKEND

Backend extendió `character_skills` con trazabilidad del origen:

```text
learned_from_item_uid UUID nullable unique
learned_from_item_id string nullable
```

Endpoint interno:

```text
POST /api/internal/accounts/{accountId}/characters/{characterId}/skills/learn
```

Payload:

```text
skill_id
scroll_uid
scroll_item_id
```

Regla crítica:

```text
CONSUMIR SCROLL
+
CREAR OWNERSHIP
=
MISMA TRANSACCIÓN
```

Nunca:

```text
consume scroll
→ luego intenta grant
→ falla grant
→ jugador pierde item
```

Backend valida identidad durable:

```text
Account
Character
container
ItemInstance UID
item_id
cantidad
ownership existente
scroll ya usado
```

Semántica de clase/nivel/trainer permanece en Game Server.

Idempotencia:

```text
mismo skill + mismo source
→ replay 200
→ idempotent true

mismo skill + distinto scroll
→ skill_already_learned
→ segundo scroll intacto

mismo scroll + otra skill
→ scroll_already_used
```

Commit:

```text
64be9a85e90ec6a07f1cb1b47d0c21c670f7dc18
feat: add atomic durable skill learning
```

---

# 22. F21-B3 — GAME SERVER LEARNING COORDINATOR

Subcomponentes efectivos:

```text
BackendCharacterSkillLearningRepository
SkillLearningCoordinator
ServerSkillLearningCatalog
ServerItemCatalog
ServerSkillRuntimeState
CharacterItemStateCoordinator
NpcServiceCoordinator
```

Commits:

```text
2a60147bd2cacccc98c884918f48a97e7f977868
feat: add skill learning backend repository

9535f9e33081728622a0eb668e30a54a364b56e1
feat: add authoritative skill learning validation

df7bcb3a757365a9e2f35cda9bb5b377bd8a3e82
feat: apply durable skill learning to runtime
```

Validaciones GS:

```text
world session válida
request sequence
learning no busy
skill definition conocida
skill no aprendida
class compatible
level suficiente
Skill Trainer activo y compatible
scroll UID exacto en Inventory runtime
scroll item_id correcto
quantity válida
```

Sólo después:

```text
Backend atomic learn
```

Tras COMMIT:

```text
GS skill runtime update
+
Inventory reload durable
```

La verdad durable gana ante cualquier inconsistencia.

---

# 23. F21-B4-A — SKILL TRAINER NPC

Se creó el servicio NPC autoritativo:

```text
npc_id = skill_trainer
service_id = skill_trainer
interaction_range = 2.5
```

Game Server controla:

```text
iniciar servicio
mantener servicio mientras está en rango
cerrar por X/request
invalidar por out_of_range
```

Commit GS:

```text
a953194e26ba8b1fd746314defa2b2b201b017ab
feat: add skill trainer npc
```

Cliente representa visualmente el Trainer en TestTown.

Commit cliente:

```text
a274d1a62f59aa7e27c22d1f52491389b9b34c4d
feat: add skill trainer to client world
```

La escena cliente NO es la autoridad de interacción.

---

# 24. F21-B4-B — NETWORK PROTOCOL

Mensajes:

```text
skill_learning_request
skill_learning_result
skill_trainer_offers
```

Request learning:

```text
request_id
skill_id
scroll_uid
```

Result learning:

```text
request_id
skill_id
scroll_uid
accepted
reason
learned_skill_ids
idempotent
```

Sequence de learning es independiente de cast sequence.

Correlación estricta:

```text
request_id
+
skill_id
+
scroll_uid
```

Commit GS:

```text
2efc2ceaab8a8150541fe727f1e461187d0ba190
feat: add skill learning network protocol
```

Commit cliente:

```text
e2808b32156887cbb66f13713b68b3204a42655c
feat: add client skill learning protocol
```

---

# 25. F21-B4-C — CLIENT PRESENTATION FOUNDATION

Scrolls client-side son metadata visual del sistema de items:

```text
skill_scroll_fire_ball
skill_scroll_poison
skill_scroll_heal
```

Categoría:

```text
MISC
```

Foundation actual:

```text
grid size = 1x2
max_stack = 1
```

Los iconos son temporales/foundation.

Commit:

```text
e414a24b7137e3ff4cfe2fce8be6990fd4b6f853
feat: add skill scroll client definitions
```

---

# 26. RUTA TEMPORAL DE DOBLE CLICK — HISTORIA Y RETIRO

Durante B4-C3 existió temporalmente:

```text
Inventory double click Scroll
→ client mapping scroll → skill
→ skill_learning_intent
→ Game Server
```

Commit histórico:

```text
327c3370aad874b236490adb2fbd9e8c727a79af
feat: connect skill scroll learning flow
```

Esta ruta fue útil sólo para probar el pipeline antes de tener Trainer UI.

La arquitectura final la RETIRÓ.

Commit:

```text
bfb39eea4751ff6015d0935507704614c9745b3e
feat: route skill learning through trainer
```

Estado final:

```text
double click Skill Scroll
→ NO aprende Skill
```

También se eliminó:

```text
ClientSkillLearningCatalog
```

El mapping semántico:

```text
scroll_item_id ↔ skill_id
```

queda del lado autoritativo del Game Server.

Se conserva el signal genérico de item activation en UI para futuros:

```text
Health Potion
Mana Potion
teleport item
quest item
otros consumibles
```

No eliminarlo sólo porque ya no se usa para Skills.

---

# 27. F21-B4-D1 — AUTHORITATIVE TRAINER OFFERS

El Game Server construye el snapshot de ofertas usando:

```text
authenticated Character
class
level
runtime skill ownership
runtime Inventory
ServerSkillLearningCatalog
ServerItemCatalog
active Skill Trainer service
```

Campos de oferta:

```text
skill_id
scroll_item_id
minimum_level
already_learned
has_scroll
can_learn
reason
scroll_uid cuando corresponde
```

El cliente NO recalcula eligibility.

Commits GS:

```text
9b389b7fe7f5e83e892b09533e89dd982279a2d3
feat: build authoritative skill trainer offers

2734b652f10ed30a005b6fd4e329867b07e04405
feat: send authoritative skill trainer offers
```

Commit cliente:

```text
984d0da6345404cf3adc84e11cc5b525f44b1b48
feat: receive authoritative skill trainer offers
```

Ejemplo archer:

```text
Heal
Poison
```

Fire Ball:

```text
NO aparece para archer
```

---

# 28. F21-B4-D2 — SKILL TRAINER WINDOW

Cliente agregó UI basada en `BaseWindow`.

Archivos principales:

```text
features/skills/ui/skill_trainer_window.gd
features/skills/ui/skill_trainer_window.tscn
features/skills/ui/skill_trainer_offer_row.gd
features/skills/ui/skill_trainer_offer_row.tscn
```

Integración:

```text
GameplayUI
→ WindowsLayer
→ SkillTrainerWindow
```

Reglas UI:

```text
fixed size
draggable
keep_inside_viewport
no resize
server-authorized open/close
```

Oferta row muestra:

```text
Skill icon
Skill name
minimum level
required Scroll
status
APRENDER
```

Status deriva únicamente de `reason` autoritativo recibido.

Ejemplos:

```text
ok
→ Disponible para aprender

skill_already_learned
→ Aprendida

level_requirement_not_met
→ Nivel insuficiente

scroll_required
→ Falta el Scroll requerido
```

Cliente sólo traduce reason a texto visual.

No decide elegibilidad.

Commit:

```text
fd67e19e89471e2946da0e8b382ec339c183504d
feat: add authoritative skill trainer window
```

---

# 29. TRAINER LIFECYCLE

Apertura:

```text
click NPC
→ NpcInteractionController
→ Game Server request
→ GS valida rango/service
→ NPC service authorized
→ offers snapshot
→ SkillTrainerWindow open
```

Cierre manual:

```text
X
→ GameplayUI close
→ npc_service_end_request
→ GS finaliza servicio
```

Cierre autoritativo:

```text
player sale de rango
→ GS detecta out_of_range
→ npc_service_end
→ cliente cierra ventana
```

Cierre programático por GS NO vuelve a emitir manual-close.

Esto evita recursion:

```text
server close
→ client close
→ nuevo service_end request
→ loop
```

---

# 30. F21-B4-D3 — APRENDER DESDE TRAINER

Flujo final:

```text
SkillTrainerOfferRow
→ learn_requested(skill_id, scroll_uid)
→ SkillTrainerWindow
→ GameplayUI
→ GameplayScreen
→ skill_learning_intent_requested
→ GameSessionFlowCoordinator
→ GameServerClient
→ Game Server
```

GameplayScreen exige localmente sólo contexto UX mínimo:

```text
Trainer service activo
trainer NPC id presente
skill_id no vacío
scroll_uid no vacío
```

Eso NO reemplaza validación GS.

El botón se deshabilita inmediatamente:

```text
status = Procesando...
```

para evitar múltiples clicks accidentales.

Commit cliente:

```text
bfb39eea4751ff6015d0935507704614c9745b3e
feat: route skill learning through trainer
```

---

# 31. F21-B4-D4-A — LIVE RUNTIME UPDATE

Problema previo:

```text
GS aprendía Skill
Backend persistía
Scroll desaparecía
pero cliente sólo veía nueva Skill después de reconnect
```

Solución:

```text
skill_learning_result accepted=true
→ learned_skill_ids
→ PlayerRuntimeState.apply_skill_learning_update()
```

No se reutiliza ciegamente bootstrap de login.

Se actualizan los mismos objetos:

```text
SkillBookData
SkillHotbarData
```

Esto conserva bindings/signals UI existentes.

Regla hotbar:

```text
sólo autoasignar Skills NUEVAS
```

No rellenar Skills viejas que el jugador pudiera haber quitado manualmente de la hotbar.

Si hotbar está llena:

```text
Skill se aprende igual
→ queda en SkillBook
→ no se fuerza slot
```

Commit:

```text
5399334957b852af582cdc047cd64d67d1cf7c2d
feat: apply learned skills to live runtime
```

Audit:

```text
Atilio sin Heal
→ aprende Heal
→ sin reconnect:
   SkillBook +1
   Hotbar +1
   selected slot = Heal
```

---

# 32. F21-B4-D4-B — REFRESH TRAINER AFTER SUCCESS

Después del COMMIT, el Inventory durable se recarga async.

No reconstruir ofertas antes de que el Inventory nuevo haya sido aplicado.

Cadena:

```text
Backend learn success
→ GS skill runtime update
→ reload Inventory
→ CharacterItemStateCoordinator aplica Inventory nuevo
→ inventory_snapshot_applied
→ SkillLearningCoordinator rebuild offers
→ send skill_trainer_offers
```

Esto evita:

```text
Skill aprendida
+
Inventory viejo con Scroll todavía presente
→ oferta inconsistente
```

Después de éxito:

```text
Disponible para aprender
→ Procesando...
→ Aprendida
```

sin cerrar ventana.

Game Server commit:

```text
ba41cee395573fbfc3a8cbc43ecff1ba357dad88
feat: refresh skill trainer offers after learning
```

Cliente preserva posición de ventana durante refresh.

Primera apertura:

```text
center_in_viewport()
```

Snapshot posterior:

```text
actualizar contenido
→ NO recentrar
```

Commit:

```text
8eb5cf9da711655994cfbcaaa75f25218629a542
feat: preserve skill trainer position on refresh
```

Audit:

```text
ventana arrastrada
→ APRENDER
→ refresh
→ Aprendida
→ ventana permanece exactamente donde estaba
```

---

# 33. F21-B4-D4-C — REJECTION RECOVERY

Problema:

```text
APRENDER
→ Procesando...
→ Backend/GS rechaza
→ botón podía quedar congelado si no llegaba snapshot nuevo
```

Solución GS:

```text
send skill_learning_result accepted=false
→ rebuild current authoritative offers
→ send skill_trainer_offers
```

Cliente NO decide:

```text
"si backend_unavailable entonces can_learn=true"
```

Cliente simplemente vuelve a renderizar verdad GS.

Cubre:

```text
semantic rejection
stale_request
async Backend persistence failure
```

Commit:

```text
968c1a19ea01b04d61b721ee59929fd55c036339
feat: recover skill trainer after learning rejection
```

---

# 34. BACKEND FAILURE PARSING

Durante audit D4-C se apagó intencionalmente Laravel app.

nginx respondió:

```text
HTTP 502
body no JSON
```

El repository intentaba:

```text
JSON.parse_string(body)
```

y Godot producía error rojo:

```text
Parse JSON failed
Unexpected character
```

Se corrigió dentro del mismo commit D4-C.

Ahora:

```text
JSON.new().parse(body)
→ parse_error controlado
```

Para response `>=500` no JSON:

```text
reason = backend_unavailable
```

Resultado:

```text
NO error rojo del parser
NO crash
NO Skill aprendida
NO Scroll consumido
UI recuperada
```

Luego Backend puede volver y el mismo Character/session puede reintentar.

Audit real:

```text
Request 1
→ Backend apagado
→ Accepted false
→ Scroll intacto
→ Heal no aprendida
→ Trainer vuelve a Disponible para aprender

Backend start

Request 2
→ Accepted true
→ Heal aprendida
→ Scroll consumido
→ Trainer Aprendida
```

Todo sin reconnect.

---

# 35. F21-B5 — INTEGRATED DURABLE SKILL LEARNING AUDIT

**Estado:** ✅ COMPLETADO.

No requirió código adicional.

Se auditó success, durability, reconnect, character isolation, class filtering, Trainer lifecycle y rejection recovery.

---

# 36. AUDIT FINAL — ATILIO

Estado final auditado:

```text
Character ID: 1
Name: Atilio
Class: warrior
Level: 124
EXP: 50/100
Skills: ["heal"]
Inventory Items: 7
Equipment Items: 1
```

Reconnect GS:

```text
WorldSessionRegistry
Skills: ["heal"]
```

Cliente:

```text
Skills: ["heal"]
Learned: 1
Hotbar slots: 1
Hotbar seleccionada: Heal
```

Trainer:

```text
Ofertas: 1

Heal
already_learned = true
has_scroll = false
can_learn = false
reason = skill_already_learned
```

Visual:

```text
Heal
Aprendida
[APRENDER disabled]
```

Warehouse regression:

```text
abre Vault
X cierra
reabre
out_of_range cierra autoritativamente
```

F20 autosave también siguió funcionando durante audit.

---

# 37. AUDIT FINAL — LYRA

Estado final auditado:

```text
Character ID: 2
Name: Lyra
Class: archer
Level: 85
EXP: 0/100
Skills: ["heal", "poison"]
Inventory: 0
Equipment: 0
```

Reconnect cliente:

```text
Skills: ["heal", "poison"]
Learned: 2
Hotbar slots: 2
```

Trainer:

```text
Ofertas: 2

Heal
├── already_learned = true
├── has_scroll = false
├── can_learn = false
└── reason = skill_already_learned

Poison
├── already_learned = true
├── has_scroll = false
├── can_learn = false
└── reason = skill_already_learned
```

Fire Ball:

```text
NO aparece
```

correcto por clase `archer`.

Lifecycle final:

```text
Trainer abierto
→ player se aleja
→ distancia > 2.5
→ GS out_of_range
→ cliente cierra ventana automáticamente
```

Esto confirmó:

```text
ownership durable por Character
+
filter por class
+
lifecycle NPC
```

sin contaminación entre Atilio y Lyra.

---

# 38. RESULTADO CANÓNICO DE F21-B

F21-B se considera un sistema REAL porque cumple:

```text
intención nace desde gameplay correcto
autoridad semántica GS
item durable real
trainer real
class/level validation
atomic persistence
runtime update
client live replication
Trainer UI live refresh
reconnect durability
per-character isolation
error recovery
edge cases principales auditados
no depende de debug shortcut
```

Arquitectura final:

```text
Inventory Scroll
		│
		│ sólo item durable
		▼
Skill Trainer NPC
		│
		▼
Authoritative Offers
		│
		▼
[APRENDER]
		│
		▼
Game Server Validation
		│
		▼
Backend Atomic Transaction
├── consume ItemInstance
└── create CharacterSkill
		│
		▼
GS Runtime Skill Ownership
		│
		├── Client SkillBook
		├── Client Hotbar
		├── Inventory refresh
		└── Trainer Offers refresh
```

---

# 39. QUÉ NO HACE EL CLIENTE EN SKILL LEARNING

No decide:

```text
qué Scroll enseña qué Skill
class compatibility
minimum level real
minimum stats futuros
Trainer compatibility
si tiene realmente el Scroll
si una Skill ya está aprendida durablemente
si puede aprender
si el Scroll se consume
si persistencia fue exitosa
```

Cliente puede:

```text
mostrar display name
mostrar icon
mostrar description
mostrar reason traducido
emitir intención
mostrar Procesando...
```

---

# 40. QUÉ HACE EL GAME SERVER EN SKILL LEARNING

Autoridad:

```text
catálogo semántico
Trainer service
class
level
ownership runtime
Inventory runtime
scroll ↔ skill mapping
request sequence
concurrency/busy state
```

Orquesta:

```text
validate
→ Backend learn
→ runtime mutation
→ Inventory reload
→ result
→ offers refresh
```

---

# 41. QUÉ HACE EL BACKEND EN SKILL LEARNING

Backend garantiza:

```text
Account identity
Character identity
Scroll durable UID
container identity
scroll item id
quantity
CharacterSkill durable
source traceability
atomic mutation
idempotency
```

Backend NO reemplaza reglas gameplay como:

```text
class compatibility
level requirement
active Trainer range
```

esas permanecen GS.

---

# 42. INVENTORY / EQUIPMENT / VAULT

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
general consumable use
durability
item-specific state avanzado
```

No construirlos sin necesidad funcional concreta.

Health Potion existe durablemente, pero todavía no tiene pipeline final de `use item`.

Flujo futuro correcto:

```text
use item intent
→ GS validate item/quantity
→ shared vitals/effects pipeline
→ durable quantity mutation
→ replicate inventory + vitals
```

El signal genérico de Inventory activation se conserva para esto.

---

# 43. WORLD DROPS

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

Pickup durable:

```text
PERSIST INVENTORY
→ confirmación
→ CONSUME WORLD DROP
```

Nunca invertir ese orden.

Tras restart GS:

```text
world drops runtime desaparecen
```

Aceptado por ahora.

---

# 44. PROGRESSION FOUNDATION

Regla foundation:

```text
100 EXP por level
```

Training Goblin:

```text
+50 EXP
```

Progression durable:

```text
Level
Experience
```

Separada de Skill Ownership.

No mezclar:

```text
CharacterSkill
con
CharacterProgression
```

---

# 45. COMBAT FOUNDATION

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

# 46. UI — REGLAS VIGENTES

Ventanas principales:

```text
tamaño fijo
draggable
no resize
no salir del viewport
```

No volver al plan antiguo:

```text
resize
expand
contract
```

Inventario:

```text
compacto
MU-like footprint
celdas/gaps pequeños
Equipment compacto
```

Inspiración funcional MU no significa copiar identidad visual.

VHAL debe mantener identidad propia.

Skill Trainer respeta las mismas reglas.

---

# 47. BASEWINDOW / WINDOW LIFECYCLE

`BaseWindow`:

```text
PanelContainer
fixed minimum size
draggable header
keep_inside_viewport
close_requested
```

Skill Trainer hereda `BaseWindow`.

Importante por `@tool`:

```text
si BaseWindow usa @tool
subclass directa de ventana también debe usar @tool
```

Esto evitó warning:

```text
MISSING_TOOL
```

---

# 48. PERFORMANCE

Regla:

```text
Refactor ≠ Optimization
```

No optimizar sin medir.

F20 ya evitó:

```text
persistir position por frame
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

# 49. ARQUITECTURA DE COMPONENTES — GAME SERVER

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
SkillLearningCoordinator
```

en God Objects.

Skill Learning se construyó mediante composición y coordinators existentes.

---

# 50. CRITERIO DE SISTEMA “REAL”

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

Cumplen actualmente:

```text
F20 Character Runtime durable ✅
F21-A Skill Ownership durable ✅
F21-B Skill Learning durable ✅
```

---

# 51. PERSISTENCIA / RUNTIME ACTUAL

Durable hoy:

```text
Account / Character identity
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
Skill learning provenance
```

Runtime pero no durable tras restart GS:

```text
WorldDrops
Mob runtime
Cooldowns activos
Combat temporal
NPC service runtime
Aggression/PvP future runtime
```

---

# 52. ECONOMÍA — DIRECCIÓN CANÓNICA

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

No agregar fees al Trainer por inercia.

---

# 53. PvP / PK / SIN — DIRECCIÓN CANÓNICA

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

Alternativa lenta:

```text
PvE válido
→ reduce pecado progresivamente
```

PvP debe construirse sobre Combat como dominio propio.

No meter toda la lógica dentro de `BasicAttackCoordinator`.

---

# 54. STATS — DIRECCIÓN CANÓNICA

Stats completos todavía no están implementados.

Skill Learning ya dejó preparado conceptualmente:

```text
minimum_stats
```

pero foundation actual valida:

```text
class
level
scroll
trainer
ownership
```

No inventar Stats sólo para completar una casilla del contrato.

Cuando se abra Stats, debe servir también a:

```text
equipment
combat
skills
requirements
progression
future PvP
```

---

# 55. MAPAS / NPCS / CONTENIDO

Foundation actual:

```text
TestTown
Warehouse Keeper
Skill Trainer
Training Goblin
```

Esta escena es laboratorio/vertical slice.

Expansión futura debe separar:

```text
MapDefinition
spawn/content definitions
NPC definitions
mob definitions
drop content
```

No convertir `test_town.tscn` en repositorio permanente de todo el juego.

---

# 56. SKILL TRAINER — UX FUTURO POSIBLE

La UI foundation ya funciona.

Mejoras visuales futuras posibles:

```text
iconos reales de Skills
iconos reales de Scrolls
mejor tipografía
requirements más compactos
descripciones/tooltip refinados
filtros/categorías si crece el catálogo
source hints de dónde conseguir Scroll
```

Pero no deben introducir autoridad semántica en cliente.

---

# 57. SKILL LEARNING — ERRORES / REASONS IMPORTANTES

Examples:

```text
ok
skill_already_learned
level_requirement_not_met
scroll_required
stale_request
backend_unavailable
invalid_backend_response
```

El set puede crecer.

Regla:

```text
reason
→ Game Server / Backend contract
→ Client presentation
```

No duplicar reglas a partir de strings en UI.

---

# 58. IDEMPOTENCIA — REGLA CANÓNICA

Learning durable:

```text
retry same semantic operation
→ no duplicate CharacterSkill
→ no consume Scroll dos veces
```

Pickup durable:

```text
grant idempotente
→ luego consume WorldDrop
```

Runtime state:

```text
same durable checkpoint replay
→ no revision bump artificial
```

Idempotencia debe diseñarse por operación, no agregarse al final.

---

# 59. FAILURE POLICY

Cuando el cliente recibe una verdad autoritativa que no puede representar:

```text
fail closed
```

Ejemplo D4-A:

```text
Accepted true
+
learned_skill_ids inválidos/desconocidos
→ no seguir jugando con runtime inconsistente
```

Cuando Backend durable falla:

```text
NO mutación durable confirmada
→ no consumir item
→ no conceder ownership
→ recuperar UI desde snapshot autoritativo
```

---

# 60. ROADMAP CANÓNICO ACTUAL

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

F21-B1 Learning contract        ✅
F21-B2 Atomic persistence       ✅
F21-B3 GS learning coordinator  ✅
F21-B4 Trainer/protocol/UI      ✅
F21-B5 Integrated audit         ✅
F21-B Durable Skill Learning    ✅

F22                            ⏳ PLANIFICAR
```

No abrir simultáneamente varios bloques grandes.

---

# 61. POSIBLES CANDIDATOS PARA F22 — NO ELEGIDOS TODAVÍA

Antes de codificar F22, revisar repositorios y elegir UNO.

Candidatos razonables:

```text
Character Stats Foundation
Consumable Use / Health Potion
Economy / Currency foundation
Merchant
PvP / PK / Sin foundation
World/content expansion
Map/spawn content architecture
```

No tratar esta lista como orden obligatorio.

La elección debe basarse en:

```text
qué dependencia desbloquea más sistemas
qué sirve al vertical slice siguiente
qué reduce deuda estructural
qué puede probarse como sistema real
```

---

# 62. DECISIONES FUTURAS QUE SIGUEN VIGENTES

## F15-C

Diferido:

```text
stack merge
stack split
partial transfer
authoritative sort
durability
general consumables
```

## Fire Ball / Poison

```text
Fire Ball effect
Poison effect
```

siguen diferidos.

No implementarlos automáticamente sólo porque el learning ya existe.

## WorldDrop durability

Runtime-only mientras vive GS.

Durabilidad tras restart:

```text
futuro si se necesita
```

## Auto-chase

Diferido.

## Currency name

No usar `Zen` como nombre final.

---

# 63. CHECKPOINTS IMPORTANTES — PRE F21-B

```text
557bee80258d09cfbc9084e42213d14caefd9b85
docs: close F19 vertical slice and record future systems

55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence

f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime

fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect

2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave

29c2426077788225779674652ba6712dcc13231a
feat: add durable character skill ownership

598d993eeff80aaf5fd84ca7413a04772ee4faab
feat: bootstrap skills from durable ownership

09b84327f9028b6c8a4cbb213c6aa14ec3792a22
docs: close F21 durable skill ownership
```

---

# 64. CHECKPOINTS IMPORTANTES — F21-B BACKEND

```text
64be9a85e90ec6a07f1cb1b47d0c21c670f7dc18
feat: add atomic durable skill learning
```

---

# 65. CHECKPOINTS IMPORTANTES — F21-B GAME SERVER

```text
25cd9f68bf68212cd6599998ac9424de96967a04
feat: add skill learning contract

2a60147bd2cacccc98c884918f48a97e7f977868
feat: add skill learning backend repository

9535f9e33081728622a0eb668e30a54a364b56e1
feat: add authoritative skill learning validation

df7bcb3a757365a9e2f35cda9bb5b377bd8a3e82
feat: apply durable skill learning to runtime

a953194e26ba8b1fd746314defa2b2b201b017ab
feat: add skill trainer npc

2efc2ceaab8a8150541fe727f1e461187d0ba190
feat: add skill learning network protocol

9b389b7fe7f5e83e892b09533e89dd982279a2d3
feat: build authoritative skill trainer offers

2734b652f10ed30a005b6fd4e329867b07e04405
feat: send authoritative skill trainer offers

ba41cee395573fbfc3a8cbc43ecff1ba357dad88
feat: refresh skill trainer offers after learning

968c1a19ea01b04d61b721ee59929fd55c036339
feat: recover skill trainer after learning rejection
```

---

# 66. CHECKPOINTS IMPORTANTES — F21-B CLIENT

```text
e2808b32156887cbb66f13713b68b3204a42655c
feat: add client skill learning protocol

a274d1a62f59aa7e27c22d1f52491389b9b34c4d
feat: add skill trainer to client world

e414a24b7137e3ff4cfe2fce8be6990fd4b6f853
feat: add skill scroll client definitions

327c3370aad874b236490adb2fbd9e8c727a79af
feat: connect skill scroll learning flow
TEMPORAL / RETIRADO

984d0da6345404cf3adc84e11cc5b525f44b1b48
feat: receive authoritative skill trainer offers

fd67e19e89471e2946da0e8b382ec339c183504d
feat: add authoritative skill trainer window

bfb39eea4751ff6015d0935507704614c9745b3e
feat: route skill learning through trainer

5399334957b852af582cdc047cd64d67d1cf7c2d
feat: apply learned skills to live runtime

8eb5cf9da711655994cfbcaaa75f25218629a542
feat: preserve skill trainer position on refresh
```

---

# 67. PRUEBAS CLAVE F21-B

## Atomic Backend

Probado:

```text
same source replay
same skill different scroll
same scroll different skill
failure rollback
```

## Trainer Offers

Probado:

```text
class filtering
level
ownership
Inventory scroll
can_learn
reason
scroll_uid
```

## Real Learn Success

Atilio:

```text
warrior
level 124
Heal no aprendida
Heal Scroll durable
↓
Trainer Offer can_learn=true
↓
APRENDER
↓
Accepted=true
↓
Scroll consumido
↓
Heal durable
```

DB:

```text
character_skills.heal
learned_from_item_uid = UID del Scroll consumido
learned_from_item_id = skill_scroll_heal
```

Scroll:

```text
ya no existe
```

Reconnect:

```text
Heal sigue aprendida
```

## Live Client

Sin reconnect:

```text
SkillBook + Heal
Hotbar + Heal
Inventory - Scroll
Trainer → Aprendida
```

## Backend Failure Recovery

```text
Backend app stop
→ request rejected
→ no durable mutation
→ UI recuperada

Backend app start
→ retry
→ success
```

## Per Character

```text
Atilio
→ warrior
→ heal

Lyra
→ archer
→ heal + poison
```

No contaminación.

---

# 68. ESTADO FUNCIONAL CANÓNICO ACTUAL

Vertical slice actual:

```text
Login
→ Character Select
→ Game Session Ticket
→ Durable Skill Ownership bootstrap
→ Durable Character Runtime Restore
→ Game Server World
→ Movement
→ NPC Services
├── Warehouse
└── Skill Trainer
→ Inventory / Vault / Equipment
→ Skill Runtime
→ Durable Skill Learning
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
Skill learning provenance
```

---

# 69. QUÉ SIGUE NO IMPLEMENTADO

```text
Fire Ball effect
Poison effect
general consumable use
Character Stats completos
Economy
Currency final
Merchant real
PvP
PK / Sin
auto-defense
Priest confession
trade
WorldDrop persistence across GS restart
auto-chase
más mapas / content architecture
production-grade NPC/mob content
```

---

# 70. REGLAS DE CONTINUIDAD AL RETOMAR

Antes de programar:

```text
1. leer PROJECT_MEMORY.md
2. leer PROJECT_MEMORY_2.md
3. git status en los 3 repos
4. revisar branch dev remoto
5. identificar último checkpoint real
6. elegir una sola etapa
```

No asumir que una propuesta futura ya fue aprobada.

No avanzar basado sólo en memoria si GitHub dice otra cosa.

---

# 71. NO HACER POR INERCIA

No abrir automáticamente:

```text
Fire Ball damage
Poison DoT
PvP
Economy
Merchant
Stats
consumables
new maps
```

sólo porque F21-B terminó.

Primero elegir F22 conscientemente.

---

# 72. REGLA PARA NUEVOS ITEMS / SYSTEMS

Si un item produce una acción real:

```text
Client
→ use intent

GS
→ validate context + semantic rule

Backend
→ durable mutation si corresponde

GS
→ authoritative runtime mutation/result

Client
→ render
```

No permitir:

```text
Inventory UI
→ cambia durable state por sí sola
```

---

# 73. REGLA PARA NUEVOS NPC SERVICES

Patrón reutilizable de Warehouse / Skill Trainer:

```text
NPC click
→ client interaction intent
→ GS range/service validation
→ session service start
→ service-specific data/result
→ UI open
→ GS maintains validity
→ X or out_of_range
→ service end
→ UI close
```

No crear NPC UI que se abra sin autorización GS para servicios gameplay reales.

---

# 74. REGLA PARA FUTUROS REQUIREMENTS

Requirements de gameplay deben vivir en catálogos/definitions autoritativos.

Ejemplos:

```text
class
level
stats
currency fee
quest state
faction
trainer tags
```

Cliente puede mostrar requirements.

No debe decidir su cumplimiento final.

---

# 75. CIERRE CANÓNICO F21-B

Estado final:

```text
F21-B1 Contract/Catalog                         ✅
F21-B2 Atomic Durable Persistence               ✅
F21-B3 GS Learning Coordinator                  ✅
F21-B4 Trainer NPC + Protocol + UI              ✅
F21-B5 Integrated Audit                         ✅

F21-B DURABLE SKILL LEARNING                    ✅ COMPLETE
```

Resultado:

> VHAL posee ahora un pipeline real de aprendizaje de Skills durable, autoritativo, transaccional, recuperable y aislado por Character.

El próximo trabajo NO debe modificar esta arquitectura sin una razón explícita y probada.

---

# 76. GATE DE PLANIFICACIÓN F22

**Estado:** ⏳ PENDIENTE.

Antes de elegir F22:

```text
revisar estado del proyecto completo
revisar dependencias
revisar qué vertical slice siguiente se quiere lograr
comparar candidatos
elegir uno
dividir en etapas pequeñas
```

No hay un F22 implementado ni aprobado todavía.

Candidatos actuales:

```text
Stats Foundation
Consumables
Economy
Merchant
PvP/PK/Sin
World Content / Maps
```

La selección debe quedar registrada aquí cuando se decida.

---

# 77. ÚLTIMA VERIFICACIÓN REGISTRADA

Fecha:

```text
28/08/2026
```

Atilio:

```text
Skills ["heal"]
Trainer Heal → Aprendida
Warehouse regression OK
repos clean
```

Lyra:

```text
Skills ["heal", "poison"]
Trainer Heal + Poison
Fire Ball ausente
out_of_range cierra Trainer automáticamente
```

Game Server:

```text
0 warnings
0 errors en flujo normal
```

Backend-down audit:

```text
controlled rejection
no parser red error after fix
recovery without reconnect
```

Los repos quedaron limpios antes de este update documental.

---

# 78. RESUMEN EJECUTIVO

```text
F19
→ vertical slice jugable

F20
→ Character runtime durable

F21-A
→ Skill ownership durable

F21-B
→ Skill learning durable real
```

La arquitectura actual ya soporta:

```text
Character identity
durable world position/vitals
durable inventory/equipment/vault
durable progression
authoritative mobs/combat
drops/pickup
skill ownership
trainer-based skill learning
live SkillBook/Hotbar updates
failure recovery
reconnect reconstruction
```

La siguiente prioridad debe elegirse en F22 sin mezclar múltiples sistemas grandes.
