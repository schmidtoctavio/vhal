# VHAL — PROJECT MEMORY / ARQUITECTURA / ROADMAP CANÓNICO

**Última actualización:** 23/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama de desarrollo habitual:** `dev`  
**Estado general:** Foundation avanzada, F15-R cerrado, F15-C evaluado/diferido, F16-A/F16-B/F16-BR/F16-C/F16-D cerrados y F17-A validado; próximo checkpoint F17-B para replicación cliente del primer mob.

> Este archivo es la **fuente canónica única de contexto del proyecto VHAL**.
>
> A partir de este checkpoint absorbe arquitectura, decisiones, roadmap, workflow, controles y estado funcional.
>
> Los roadmaps o memorias anteriores pueden conservarse como historial, pero para continuar el desarrollo se debe leer **este archivo primero**.

---

# 1. PROPÓSITO DE VHAL

VHAL es un proyecto de MMORPG desarrollado en Godot.

No se está construyendo solamente:

- una demo visual;
- un laboratorio de UI;
- una colección de escenas;
- un clon pequeño de un juego existente;
- un prototipo descartable.

La meta es construir progresivamente la base de un **MMORPG real**, con una arquitectura que pueda crecer durante años sin transformarse en código inmanejable.

La intención es poder incorporar progresivamente:

```text
cuentas
personajes
clases
mapas
NPCs
mobs
skills
combate
items
inventory
equipment
vault
drops
pickup
EXP
levels
stats
party
chat
PvP
trade
merchant
quests
guild
events
economía
persistencia
múltiples mapas
muchos jugadores concurrentes
más de un Game Server cuando realmente sea necesario
```

sin tener que reescribir el proyecto completo cada vez que aparece un sistema nuevo.

---

# 2. CONTEXTO DE APRENDIZAJE

Este punto es parte oficial del proyecto.

El desarrollo de VHAL también funciona como aprendizaje progresivo de:

```text
Godot
GDScript
escenas
Nodes
signals
Inspector
UI
networking
arquitectura de juegos
backend
persistencia
autoridad de servidor
MMORPG architecture
testing
diagnóstico de errores
```

La regla pedagógica es:

> **Arquitectura profesional, explicación progresiva.**

Cada implementación importante debe explicar:

```text
qué problema resuelve
qué responsabilidad tiene
en qué capa vive
por qué se coloca ahí
qué archivos toca
qué flujo produce
cómo se prueba
```

No simplificar la arquitectura sólo porque el proyecto también se utiliza para aprender.

---

# 3. FORMA DE IMPLEMENTACIÓN PREFERIDA

Las implementaciones nuevas se realizan de forma:

```text
manual
controlada
explicada
por etapas pequeñas
probadas antes de avanzar
```

Flujo preferido:

```text
1. revisar el repositorio real actual;
2. explicar la etapa;
3. indicar exactamente qué archivo crear o modificar;
4. entregar código completo cuando sea más seguro;
5. integrar manualmente;
6. ejecutar;
7. revisar logs;
8. corregir cualquier warning/error;
9. revisar git status;
10. commit;
11. push;
12. esperar "pusheado";
13. recién entonces avanzar.
```

Cuando un cambio visual puede hacerse razonablemente desde Godot se prefiere:

```text
abrir escena
seleccionar nodo
agregar/modificar hijos
usar Inspector
conectar signals
guardar
probar
```

No reemplazar escenas completas automáticamente cuando el cambio manual aporta aprendizaje y tiene bajo riesgo.

Se pueden entregar archivos completos cuando:

- son grandes;
- hay muchas modificaciones relacionadas;
- editar bloques manualmente tiene alto riesgo;
- el usuario lo solicita;
- la etapa es principalmente arquitectónica.

---

# 4. WORKFLOW OBLIGATORIO

VHAL usa este ciclo:

```text
ETAPA
↓
IMPLEMENTACIÓN
↓
TEST
↓
CORRECCIÓN DE WARNINGS / ERRORES
↓
GIT STATUS
↓
COMMIT
↓
PUSH
↓
CONFIRMACIÓN "pusheado"
↓
SIGUIENTE ETAPA
```

Nunca acumular muchas etapas sin checkpoints.

Una etapa NO está terminada si aparece:

```text
Parser Error
warning nuevo
runtime error
ERR_BUSY inesperado
estado inconsistente
regresión
contrato fallido
```

Objetivo habitual:

```text
0 parser errors
0 warnings nuevos
0 runtime errors inesperados
```

Cuando una etapa queda lista para checkpoint:

```bash
git status
git add .
git commit -m "mensaje"
git push
```

Después se espera:

```text
pusheado
```

y se confirma el commit remoto antes de avanzar.

---

# 5. REGLA DE REVISIÓN DEL REPOSITORIO

Antes de indicar una modificación concreta:

> **Revisar el estado real actual del repositorio.**

Repositorios:

```text
Cliente:
schmidtoctavio/vhal

Game Server:
schmidtoctavio/vhal_game_server

Backend:
schmidtoctavio/vhal_backend
```

Rama activa:

```text
dev
```

No responder con:

```text
si ya existe...
si tenés...
quizás...
probablemente...
```

cuando el repositorio está disponible.

Se debe partir del código real.

---

# 6. MANDATO ARQUITECTÓNICO

Prioridad oficial:

> **Escalabilidad, mantenibilidad, consistencia y claridad de responsabilidades antes que velocidad de implementación.**

Antes de consolidar un sistema debemos poder responder:

```text
¿Quién es la autoridad?
¿Dónde vive el estado runtime?
¿Dónde vive la persistencia?
¿Cuál es el ID estable?
¿Quién valida las reglas?
¿Cómo llega la intención desde la UI?
¿Cómo vuelve la confirmación?
¿Cómo se recupera después de reconnect/logout?
¿Cómo se prueba?
¿Cómo se optimizará después sin reescribir todo?
```

Evitar condicionales especiales dispersos por todo el proyecto:

```text
if warehouse...
if merchant...
if special_item...
if this_window...
if this_class...
if this_map...
```

Cuando aparece ese patrón hay que revisar la abstracción.

---

# 7. ARQUITECTURA GENERAL

```text
┌─────────────────────┐
│    GODOT CLIENT     │
│ intención + UI      │
│ representación      │
└──────────┬──────────┘
		   │
		   │ ENet
		   ▼
┌─────────────────────┐
│  GODOT GAME SERVER  │
│ autoridad gameplay  │
│ estado runtime      │
└──────────┬──────────┘
		   │
		   │ HTTP interno
		   ▼
┌─────────────────────┐
│   LARAVEL BACKEND   │
│ identidad + API     │
│ persistencia        │
└──────────┬──────────┘
		   │
		   ▼
┌─────────────────────┐
│        MYSQL        │
│ almacenamiento      │
│ durable             │
└─────────────────────┘
```

Regla:

```text
Cliente     = intención + representación
Game Server = autoridad de gameplay/runtime
Backend     = identidad + API + persistencia durable
MySQL       = almacenamiento durable
```

---

# 8. AUTORIDAD DE DATOS

## Cliente

Puede pedir:

```text
quiero moverme aquí
quiero mover este item
quiero equipar este UID
quiero interactuar con este NPC
quiero castear esta skill
quiero atacar esta entidad
```

No puede decidir definitivamente:

```text
mi posición real es ésta
el item quedó equipado
el mob recibió X daño
gané EXP
me quedan X MP
el cooldown terminó
el drop existe
otro jugador murió
```

## Game Server

Decide progresivamente:

```text
movimiento
presencia
servicios NPC
inventory
equipment
vault
skills
mana
cooldowns
combat
damage
death
drops
pickup
EXP
level
PvP
trade
```

## Backend

Responsable de:

```text
accounts
characters
session tickets
durable persistence
internal API
operaciones atómicas
queries persistentes
protección stale state
```

El cliente nunca habla directamente con MySQL.

---

# 9. PRINCIPIOS DE CÓDIGO

Dirección del proyecto:

```text
Feature-first
+
Shared/Core
+
Server Authority
+
Domain Validation
+
Repository Pattern
+
Runtime State separado de UI
+
Orchestration explícita
+
IDs lógicos estables
```

No se busca una arquitectura académica por nombre.

Se buscan patrones:

- claros;
- repetibles;
- fáciles de encontrar;
- fáciles de probar;
- fáciles de extender.

---

# 10. CAPAS CONCEPTUALES

## Definitions

Describen qué existe:

```text
ItemDefinition
SkillDefinition
CharacterClassDefinition
NpcDefinition
MobDefinition
MapDefinition
QuestDefinition
```

Son datos estáticos/de diseño.

Mientras el volumen sea razonable pueden vivir como Resources/catalogs.

No convertir prematuramente todo el contenido a DB o JSON sólo por “escalabilidad”.

## Runtime State

Describe qué está pasando ahora.

Cliente:

```text
ClientSession
AccountState
PlayerRuntimeState
InventoryData
EquipmentData
WorldState
VitalsState
ExperienceState
SkillBookData
SkillHotbarData
```

Game Server:

```text
PlayerWorldSession
ServerVitalsState
ServerSkillRuntimeState
movimiento autoritativo
servicio NPC activo
snapshots persistentes conocidos
futuro combat state
futuro mob runtime state
```

## UI / View

Debe:

```text
mostrar
capturar input
dar feedback
hacer previews
emitir intención
representar runtime state
```

No debe ser fuente de verdad.

## Networking

Debe:

```text
transport
serialization
parsing
versionado
validación estructural básica
routing de mensajes
```

No convertirse en gameplay.

## Domain Rules / Validators

Aquí viven reglas reutilizables.

Ejemplos:

```text
ServerEquipmentRules
ServerEquipmentSnapshotValidator
ServerEquipmentTransferValidator
ServerCharacterInventorySnapshotValidator
ServerVaultSnapshotValidator
ServerItemContainerTransferValidator
EquipmentRules
ServerSkillCatalog
```

## Repositories

Encapsulan infraestructura HTTP/backend:

```text
BackendTicketValidator
BackendCharacterInventoryRepository
BackendCharacterEquipmentRepository
BackendVaultRepository
BackendItemTransferRepository
```

El dominio no debe conocer rutas Laravel.

## Coordinators / Flows

Coordinan casos de uso concretos.

No son “Managers para todo”.

---

# 11. IDs ESTABLES

Nunca usar como identidad persistente:

```text
NodePath
Resource path
posición visual
índice de array
ordinal de enum
nombre de nodo
```

Ejemplos correctos:

```text
item_id    = bronze_sword
npc_id     = warehouse_keeper
service_id = warehouse
map_id     = test_town
class_id   = warrior
skill_id   = heal
```

---

# 12. ESTRUCTURA CONCEPTUAL DEL CLIENTE

```text
res://
├── app/
│   ├── main.gd
│   ├── main.tscn
│   ├── flows/
│   │   ├── account_flow_coordinator.gd
│   │   └── game_session_flow_coordinator.gd
│   ├── navigation/
│   │   └── screen_router.gd
│   └── session/
│       ├── client_session.gd
│       └── account_state.gd
│
├── features/
│   ├── auth/
│   ├── characters/
│   ├── equipment/
│   ├── gameplay/
│   │   ├── networking/
│   │   │   ├── game_server_client.gd
│   │   │   └── protocols/
│   │   │       ├── game_server_world_protocol.gd
│   │   │       ├── game_server_presence_protocol.gd
│   │   │       ├── game_server_movement_protocol.gd
│   │   │       ├── game_server_npc_protocol.gd
│   │   │       ├── game_server_item_protocol.gd
│   │   │       └── game_server_skill_protocol.gd
│   │   └── ui/
│   ├── inventory/
│   ├── items/
│   ├── player/
│   ├── skills/
│   ├── vault/
│   └── world/
│
├── ui/
│   └── shared/
├── assets/
├── art_source/
├── debug/
├── shared/
└── test/
```

No crear carpetas vacías “por si acaso”.

---

# 13. APPLICATION FLOW DEL CLIENTE

```text
Main
└── composition root / startup

AccountFlowCoordinator
├── login
├── logout
├── character select
├── character create
├── character delete
└── enter-world intention

GameSessionFlowCoordinator
├── session ticket
├── conexión al Game Server
├── loading
├── bootstrap autoritativo
├── GameSession lifecycle
├── Gameplay wiring
├── movement/presence bridge
├── NPC/Warehouse bridge
├── Inventory/Vault/Equipment bridge
└── Skills/Cast bridge
```

`app/main.gd` no debe volver a transformarse en un monolito.

---

# 14. NETWORKING DEL CLIENTE

Existe una sola conexión ENet:

```text
GameServerClient
│
├── ENetMultiplayerPeer único
├── autenticación
├── envelope/versionado
├── packet dispatch
├── send centralizado
│
├── GameServerWorldProtocol
├── GameServerPresenceProtocol
├── GameServerMovementProtocol
├── GameServerNpcProtocol
├── GameServerItemProtocol
└── GameServerSkillProtocol
```

No crear sockets independientes por feature sin necesidad real.

Ejemplos incorrectos:

```text
InventoryConnection
CombatConnection
ChatConnection
NpcConnection
```

## ItemProtocol

Inventory, Vault y Equipment continúan juntos cuando comparten serialización de mutaciones.

## SkillProtocol

Responsabilidad actual:

```text
serializar skill_cast_request
asignar request_id
enviar intención por el transporte central
```

No decide:

```text
mana
cooldown
damage
heal
target válido
resultado
```

---

# 15. ESTRUCTURA CONCEPTUAL DEL GAME SERVER

```text
res://
├── app/
│   ├── main.gd
│   ├── main.tscn
│   └── coordinators/
│       ├── authentication_coordinator.gd
│       ├── character_item_state_coordinator.gd
│       ├── equipment_coordinator.gd
│       ├── inventory_coordinator.gd
│       ├── vault_coordinator.gd
│       ├── item_container_transfer_coordinator.gd
│       ├── npc_service_coordinator.gd
│       ├── movement_coordinator.gd
│       ├── world_presence_coordinator.gd
│       └── skill_cast_coordinator.gd
│
└── core/
	├── networking/
	├── backend/
	├── combat/
	│   ├── server_vitals_state.gd
	│   └── server_character_runtime_bootstrap.gd
	├── skills/
	│   ├── server_skill_definition.gd
	│   ├── server_skill_catalog.gd
	│   └── server_skill_runtime_state.gd
	└── world/
		├── movement/
		├── navigation/
		└── npcs/
```

## ServerMain

Responsabilidad:

```text
composition root
resolver nodos/dependencias
validar configuración
ejecutar contratos/self-tests
inicializar registries
configurar coordinators
arrancar servidor
manejar fallos de startup
```

No debe absorber casos de uso.

---

# 16. COORDINATORS DEL GAME SERVER

## CharacterItemStateCoordinator

```text
Inventory snapshot
Equipment snapshot
initial load
reload
resend
stale recovery
```

## EquipmentCoordinator

```text
Equip
Unequip
validación
persistencia
resync
```

## InventoryCoordinator

```text
movimiento interno Inventory
validación
persistencia
resync
```

## VaultCoordinator

```text
carga Vault
movimiento interno Vault
estado Vault activo
```

Vault es account-wide.

## ItemContainerTransferCoordinator

```text
Inventory → Vault
Vault → Inventory
```

## NpcServiceCoordinator

```text
interaction intent
NPC validation
range
service authorization
service lifecycle
Warehouse trigger
out_of_range invalidation
```

## MovementCoordinator

```text
movement intent
NavMesh resolution
path validation
movement authorization
rejection
replication
NPC range checks durante movimiento
```

El tick físico vive en:

```text
WorldMovementSystem
```

## WorldPresenceCoordinator

```text
same-map roster
initial presence
player joined
player left
```

## AuthenticationCoordinator

```text
ticket flow
connection authentication
WorldSession creation
initial world snapshot
presence bootstrap
persistent item bootstrap
disconnect cleanup
```

## SkillCastCoordinator

Introducido en F16-B.

Responsabilidad actual:

```text
recibir una intención de cast estructuralmente válida
resolver PlayerWorldSession del peer
coordinar el caso de uso de cast
```

En F16-B todavía NO:

```text
consume MP
cura
hace daño
inicia cooldown
replica resultado
```

En F16-C comenzará a coordinar la ejecución autoritativa real.

---

# 17. BACKEND / PERSISTENCIA

Backend Laravel real.

Responsable de:

```text
identidad
cuentas
personajes
tickets
persistencia durable
operaciones atómicas internas
queries persistentes
protección stale
```

No es autoridad de gameplay en tiempo real.

## Item instances

Modelo conceptual:

```text
item_instances
├── account_id
├── character_id nullable
├── uid unique
├── item_id
├── container
├── quantity
├── grid_x nullable
├── grid_y nullable
├── equipment_slot nullable
└── state JSON nullable
```

Containers:

```text
inventory
equipment
vault
```

Ownership:

```text
Inventory / Equipment
→ account_id + character_id

Vault
→ account_id + character_id NULL
```

---

# 18. CONTRATO DE UID DE ITEMS

Cada item concreto tiene un UID estable.

Mover:

```text
Inventory
→ Equipment
→ Inventory
→ Vault
→ Inventory
```

NO debe:

```text
delete row
create another row
generate new UID
```

Debe conservar:

```text
same database row
same UID
same logical item instance
```

Esto prepara:

```text
durability
upgrade level
excellent options
sockets
bind state
serial/history
```

---

# 19. ITEM DEFINITION VS ITEM INSTANCE

```text
ItemDefinition = tipo de item
ItemInstance   = instancia concreta
```

Ejemplo:

```text
bronze_sword
```

es una definición.

Una espada específica tiene:

```text
uid
quantity
container
position
equipment slot
state
```

El campo `state` puede crecer:

```json
{
  "durability": 42,
  "upgrade_level": 7,
  "excellent_options": [],
  "sockets": [],
  "bound": false
}
```

No meter indiscriminadamente todo en JSON.

---

# 20. EQUIPMENT — CONTRATO ESTABLE

Slots:

```text
head
chest
pants
gloves
boots
main_hand
off_hand
wings
pendant
ring_left
ring_right
```

No persistir enums numéricos.

Hand modes:

```text
none
main_hand_only
one_hand
two_hand
off_hand_only
```

## TWO_HAND

```text
item TWO_HAND
→ se almacena una sola vez en main_hand
→ off_hand queda reservado de forma derivada
→ nunca se duplica el UID
```

---

# 21. ITEMS FOUNDATION

## Bronze Sword

```text
item_id: bronze_sword
size: 1x3
max_stack: 1
equipment_type: weapon
hand_mode: one_hand
```

## Health Potion

```text
item_id: health_potion
size: 1x1
max_stack: 50
equipment_type: none
hand_mode: none
```

## Leather Helmet

```text
item_id: leather_helmet
size: 2x2
max_stack: 1
equipment_type: head
hand_mode: none
```

---

# 22. ESTADO FUNCIONAL REAL

Probado de punta a punta:

```text
cuenta real
login
personajes persistentes
selección de personaje
creación de personaje
ticket de sesión
conexión ENet autenticada
world snapshot
mapa test_town
player
movimiento autoritativo
segundo cliente
presencia remota
NPC Warehouse
range validation
Warehouse out_of_range
Inventory persistente
Inventory multicelda
Vault account-wide persistente
Equipment persistente
Inventory ↔ Vault
Inventory ↔ Equipment
logout/login
persistencia
stale-state recovery
UID estable
skill runtime foundation
skill cast intent Client → Game Server
```

VHAL ya no debe describirse como un simple “UI Lab”.

---

# 23. F00 → F14 — FOUNDATION

```text
F00 Estabilización                     ✅
F01 Organización feature-first         ✅/mayormente
F02 ClientSession + ScreenRouter        ✅
F03 Service Layer                      ✅
F04 PlayerRuntimeState                 ✅
F05 Debug fixtures                     ✅/transitorio
F06 UI Core                            ✅
F07 Backend / cuentas reales           ✅
F08 Personajes reales                  ✅
F09 Loading + Game Session             ✅
F10 Primer mapa test_town              ✅
F11 Player Actor 3D                    ✅ base
F12 Cámara + movimiento                ✅
F13 Networking autoritativo            ✅ foundation
F14 NPC Framework                      ✅ foundation
```

Primer NPC/servicio real:

```text
warehouse_keeper
warehouse
```

Merchant real queda para una etapa posterior.

---

# 24. F15-A — INVENTORY ↔ VAULT

**Estado:** ✅ COMPLETADO.

Validado:

```text
Inventory → Vault
Vault → Inventory
Vault internal move
Inventory internal move
persistencia
same UID
multicelda
bounds
collision
logout/login
Warehouse authorization
```

---

# 25. F15-B — EQUIPMENT AUTORITATIVO

**Estado:** ✅ COMPLETADO.

Incluye:

```text
contrato estable de slots
semántica de manos
backend persistente
Game Server domain
snapshot
validation
persistence flow
ENet
client runtime
UI drag & drop
integridad
edge cases
```

Validado:

```text
slot incompatible
slot ocupado
stale Inventory position
stale Equipment slot
Inventory destination ocupado
multicell collision
grid bounds
account mismatch
character mismatch
UID uniqueness
rejected operation recovery
relogin persistence
concurrency protection
same UID
two-hand domain contract
```

Smoke final:

```text
Movement                        OK
NPC interaction                 OK
Warehouse open/close            OK
Inventory move                  OK
Inventory → Equipment           OK
Equipment → Inventory           OK
Inventory → Vault               OK
Vault → Inventory               OK
Vault internal move             OK
Movement after Warehouse        OK
Unexpected ERR_BUSY             NONE
Warnings/errors                 NONE
```

---

# 26. F15-R — REFACTOR ARQUITECTÓNICO

**Estado:** ✅ COMPLETADO Y VALIDADO.

Objetivo:

```text
same behavior
better structure
```

No fue optimización de performance.

Se extrajeron responsabilidades desde archivos centrales hacia coordinators/protocols dedicados.

Resultado conceptual:

```text
main.gd              → composition root
GameServerClient     → transport facade
protocol files       → serialización/parsing por dominio
coordinators         → casos de uso
domain validators    → reglas
repositories         → infraestructura backend
runtime states       → estado
```

Checkpoint cliente previo a F16:

```text
2f68c95a8ae812ba14d2d8fa6b72cb96034fa555
docs: close architectural refactor and update project memory
```

---

# 27. CHECKPOINTS F16

## Game Server — F16-A

```text
53ceffe932b03f200f2e7ee3e7a43f986f9a5463
feat: add authoritative skill runtime foundation
```

## Cliente — F16-B networking/input inicial

```text
c8a7916be8fe3091f394611e09d89da75b398c20
feat: add skill cast intent protocol
```

## Game Server — F16-B recepción

```text
9d32d0e62705a916036afba97e39d21a656d4424
feat: receive authoritative skill cast intents
```

**Importante:** el mapping de mouse introducido inicialmente en F16-B fue corregido y validado en F16-BR. El contrato vigente es LEFT CLICK = MOVE, RIGHT CLICK = SKILL y CTRL + RIGHT CLICK = PvP.

---

# 28. STALE-STATE RECOVERY

Contrato probado:

```text
Client/Game Server creen:
Bronze Sword en posición vieja

MySQL:
posición modificada manualmente

Equip request
→ Game Server valida intención runtime
→ Laravel detecta stale state
→ HTTP 409
→ coordinator solicita reload
→ Inventory snapshot autoritativo
→ Equipment snapshot autoritativo
→ PlayerWorldSession converge
→ Client converge
→ pending se libera
→ siguiente operación válida funciona
```

No esconder stale state.

No aplicar optimistic mutation definitiva en cliente.

---

# 29. PLAYER MODEL A LARGO PLAZO

```text
PlayerRuntimeState
│
├── identity
│   ├── character_id
│   ├── name
│   ├── class_id
│   └── level
│
├── vitals
│   ├── hp
│   ├── max_hp
│   ├── mp
│   └── max_mp
│
├── stats
│   ├── strength
│   ├── agility
│   ├── vitality
│   ├── energy
│   └── available_points
│
├── progression
│   ├── experience
│   └── next_level_experience
│
├── world
│   ├── map_id
│   ├── position
│   └── rotation
│
├── inventory
├── equipment
├── skill_book
├── hotbar
├── currencies
└── combat_state
```

Account-wide:

```text
AccountState
├── vault
└── futuros datos compartidos
```

Game Server:

```text
PlayerWorldSession
├── identity
├── world state
├── authoritative vitals
├── authoritative skill runtime
├── persistent item snapshots
├── movement intent/runtime
├── NPC service state
└── futuro combat state
```

---

# 30. UI — DIRECCIÓN VISUAL

La UI final debe tener identidad propia de VHAL.

Referencia conceptual:

```text
MMORPG clásico
densidad compacta tipo MU Online
sin copiar visualmente MU
```

Objetivo:

```text
VHAL identity
dark/fantasy MMORPG feeling
compact
legible
functional
reusable
consistent
```

## Ventanas

Regla cerrada:

```text
tamaño fijo
draggable
no resize
no salir fuera del viewport
```

Aplica a:

```text
Inventory
Vault
Skills
y futuras ventanas equivalentes
```

## Inventory

```text
compacto
grid multicelda
gaps pequeños
Equipment compacto
drag & drop claro
tooltip consistente
```

## Assets

Organización ideal:

```text
assets/ui/vhal/
├── arrows/
├── bars/
├── buttons/
├── cursors/
├── hud/
├── panels/
├── scrollbars/
├── slots/
└── theme/
```

Estados del mismo control:

```text
mismo canvas
mismo tamaño
misma posición
misma geometría
```

cambiando sólo el feedback visual.

---

# 31. REGLA SOBRE `windows/`

`Window` es un concepto correcto.

Evitar una carpeta global gigante:

```text
windows/
├── inventory
├── trade
├── guild
├── quest
├── crafting
├── merchant
└── ...
```

Preferir:

```text
features/inventory/ui/inventory_window.*
features/vault/ui/vault_window.*
features/skills/ui/skills_window.*
```

Shared sólo para componentes genuinamente reutilizables.

---

# 32. CONTRATO DE INPUT / CONTROLES ESTILO MU

Esta sección es **canónica** y debe respetarse en futuras implementaciones.

La referencia funcional buscada es similar a MU Online.

## Movimiento

```text
CLICK IZQUIERDO
→ movimiento / click-to-move
```

El botón izquierdo **NO se utiliza para lanzar skills**.

## Skills / combate PvE

```text
CLICK DERECHO
→ activar / lanzar la skill actualmente seleccionada
```

El botón derecho es la entrada principal para Skills/Combat.

La hotbar:

```text
1
2
3
...
```

selecciona una skill.

Seleccionar una skill no equivale a ejecutarla.

El cast se ejecuta mediante:

```text
click derecho
```

cuando existe un target/uso válido.

## PvP

Contrato:

```text
CTRL + CLICK DERECHO
→ intención de ataque / skill contra otro jugador
```

No utilizar:

```text
CTRL + CLICK IZQUIERDO
```

como contrato de PvP.

## Regla de futuro

La detección de input debe separar:

```text
click izquierdo        → movement intent
click derecho          → skill/combat intent
Ctrl + click derecho   → PvP combat intent
```

La UI no decide daño, Heal, hit, cooldown ni muerte.

El Game Server mantiene autoridad.

---

# 33. SKILLS — ESTADO CLIENTE PRE-F16

Foundation local existente:

```text
SkillDefinition
SkillBookData
SkillHotbarData
SkillSlot
SelectedSkillSlot
SkillsWindow
SkillTooltip
```

Skills actuales:

```text
fire_ball
poison
heal
```

Recursos actuales:

```text
fire_ball
mana_cost = 30
cooldown = 3.0

poison
mana_cost = 20
cooldown = 5.0

heal
mana_cost = 40
cooldown = 4.0
```

Debug fixture actual:

```text
slot 1 → Fire Ball
slot 2 → Poison
slot 3 → Heal
```

---

# 34. SKILLS / COMBAT — REGLA CRÍTICA

Skills/Combat NO deben copiar el flujo persistente lento de Inventory para cada acción.

Incorrecto:

```text
cast
→ Laravel
→ MySQL
→ esperar
→ daño/heal
```

Correcto:

```text
Client intent
→ Game Server runtime authority
→ validación inmediata
→ mutación runtime
→ resultado gameplay
→ replicación
→ persistencia con política apropiada
```

El Game Server es autoridad inmediata de combate.

Laravel no está en el hot loop de cada cast.

---

# 35. F15-C — OPERACIONES DE ITEMS PENDIENTES

**Estado:** 🟡 EVALUADO / DIFERIDO.

Después de cerrar F15-R se evaluó si F15-C era requisito para iniciar Skills/Combat.

Conclusión:

> **F15-C no bloquea F16.**

Pendientes diferidos:

```text
stack merge autoritativo
stack split
partial quantity transfer
sort autoritativo
consumibles
durability
item state específico
```

Se implementarán cuando el vertical slice los necesite realmente.

Ejemplos:

```text
Drop/Pickup
→ puede justificar stack merge

Consumible
→ debe reutilizar effects/vitals autoritativos

Durability
→ debe aparecer con reglas reales de combat/equipment

Stack split
→ cuando exista caso de uso/UX concreto
```

La infraestructura `ItemInstance.state` ya permite estado específico.

No implementar features sólo para completar una lista.

---

# 36. F16 — SKILLS + CAST REAL

**Estado:** 🟡 EN PROGRESO.

Objetivo:

```text
skill seleccionada/hotbar
→ input correcto
→ cast intent
→ Game Server
→ validación
→ runtime mutation
→ resultado autoritativo
→ cliente representa
```

Game Server deberá validar progresivamente:

```text
skill existente
skill aprendida
mana
cooldown
estado
target
range
map
line-of-sight cuando aplique
```

Cliente representa:

```text
animation
FX
sound
feedback
cooldown visual
```

---

# 37. F16-A — AUTHORITATIVE SKILL RUNTIME FOUNDATION

**Estado:** ✅ COMPLETADO Y VALIDADO.

Game Server incorpora:

```text
ServerSkillDefinition
ServerSkillCatalog
ServerSkillRuntimeState
ServerVitalsState
ServerCharacterRuntimeBootstrap
```

Skill catalog:

```text
fire_ball
poison
heal
```

Valores autoritativos actuales:

```text
fire_ball
mana_cost = 30
cooldown = 3.0

poison
mana_cost = 20
cooldown = 5.0

heal
mana_cost = 40
cooldown = 4.0
```

Vitals temporales de Foundation:

```text
max_hp = 100000
hp     = 100000
max_mp = 350
mp     = 350
```

Estos valores mantienen paridad temporal con el debug del cliente.

No representan balance definitivo.

Todos los personajes de desarrollo reciben temporalmente las tres skills.

Más adelante las skills aprendidas vendrán de progresión/persistencia real.

## Cooldowns

Runtime representado mediante expiración monotónica:

```text
cooldown_until_msec_by_skill
```

No mediante un Timer Node por cada skill/player.

Esto evita timers innecesarios y permite tests deterministas mediante `now_msec`.

## Validación real

Probado:

```text
ServerMain | Skill Catalog Contract validado.
WorldSessionRegistry | ...
HP: 100000/100000
MP: 350/350
Skills: ["fire_ball", "heal", "poison"]
```

Sin warnings/errors.

Checkpoint:

```text
53ceffe932b03f200f2e7ee3e7a43f986f9a5463
feat: add authoritative skill runtime foundation
```

---

# 38. F16-B — SKILL CAST INTENT PROTOCOL

**Estado del protocolo:** ✅ IMPLEMENTADO Y VALIDADO.  
**Estado de la etapa completa:** ✅ CERRADO después de la corrección F16-BR.

Se implementó:

```text
GameServerSkillProtocol
skill_cast_request
request_id incremental
skill_id
target descriptor
GameServer parser estructural
client_skill_cast_requested
SkillCastCoordinator
PlayerWorldSession resolution
```

Contrato de target inicial:

```json
{
  "kind": "self"
}
```

Está pensado para evolucionar a conceptos como:

```text
self
entity
position
```

sin definir prematuramente el modelo de mobs/entidades de F17.

## Validación realizada

Cliente:

```text
Hotbar seleccionada: 3 | Heal
GameServerClient | Intención de cast enviada | Request: 1 | Skill: heal | Target: self
GameServerClient | Intención de cast enviada | Request: 2 | Skill: heal | Target: self
```

Game Server:

```text
SkillCastCoordinator | Intención de cast recibida
Request: 1
Personaje: Atilio
Skill: heal
Target: self
HP: 100000/100000
MP: 350/350

SkillCastCoordinator | Intención de cast recibida
Request: 2
Personaje: Atilio
Skill: heal
Target: self
HP: 100000/100000
MP: 350/350
```

Confirmado:

```text
request Client → Server funciona
PlayerWorldSession correcta
HP no cambia
MP no cambia
cooldown no comienza
Heal todavía no se ejecuta
sin warnings/errors
```

## Corrección realizada en F16-BR

La primera implementación utilizó por error:

```text
Ctrl + click izquierdo
```

para disparar el cast.

Ese mapping NO es el contrato definitivo de VHAL.

Se corrigió a:

```text
click izquierdo
→ movimiento

click derecho
→ skill seleccionada

Ctrl + click derecho
→ PvP / ataque contra otro player
```

Esta corrección fue validada antes de iniciar F16-C.

Checkpoints ya pusheados del protocolo:

Cliente:

```text
c8a7916be8fe3091f394611e09d89da75b398c20
feat: add skill cast intent protocol
```

Game Server:

```text
9d32d0e62705a916036afba97e39d21a656d4424
feat: receive authoritative skill cast intents
```

---

# 39. F16-BR — CORRECCIÓN DE INPUT

**Estado:** ✅ COMPLETADO Y VALIDADO.

Objetivo:

```text
NO tocar networking
NO tocar Game Server
NO tocar backend

corregir únicamente la semántica de input del cliente
```

Contrato a verificar:

```text
click izquierdo
→ mueve

click derecho
→ emite intención de cast de la skill seleccionada

Ctrl + click derecho
→ reservado para PvP y NO debe disparar Heal normal

click derecho
→ NO mueve

click izquierdo
→ NO castea
```

Validado:

```text
click izquierdo → movimiento
click derecho → skill seleccionada
Ctrl + click derecho → reservado para PvP
```

F16-B quedó formalmente cerrado después de esta corrección.

---

# 40. F16-C — PRIMER HEAL AUTORITATIVO

**Estado:** ✅ COMPLETADO Y VALIDADO.

Primer cast real recomendado:

```text
Heal / self
```

Razón:

Permite validar todo el backbone autoritativo sin depender todavía de:

```text
MobRuntimeState
target entity
range contra mob
damage
aggro
death
respawn
```

Flujo objetivo:

```text
Jugador selecciona Heal
↓
click derecho
↓
Client emite intención
↓
GameServerSkillProtocol
↓
Game Server
↓
SkillCastCoordinator
↓
resolver PlayerWorldSession
↓
validar skill existente
↓
validar aprendida
↓
validar target self
↓
validar estado
↓
validar mana
↓
validar cooldown
↓
gastar MP
↓
aplicar Heal
↓
iniciar cooldown
↓
enviar resultado autoritativo
↓
cliente actualiza HP/MP
↓
cliente recibe cooldown autoritativo
```

La representación visual del cooldown queda para F16-D.

No Laravel/MySQL por cada cast.

## Implementación validada

Se incorporó:

```text
ServerHealEffect
skill_cast_result
vitals dentro del world snapshot
request_id autoritativo por sesión
validación de skill existente
validación de skill aprendida
validación de target self
validación de personaje vivo
validación de cooldown
validación de mana
gasto de MP
inicio de cooldown
resultado autoritativo Server → Client
aplicación de HP/MP en PlayerRuntimeState
actualización automática del HUD mediante signals
rechazo de skills todavía no implementadas
```

## Bug detectado durante integración

El Game Server enviaba correctamente `vitals` dentro de `PlayerWorldSession.to_snapshot()`, pero `GameServerWorldProtocol` los validaba y luego los omitía al reconstruir `latest_world_snapshot`.

Eso provocaba:

```text
snapshot válido recibido
→ vitals descartados
→ GameSessionFlowCoordinator no encuentra vitals
→ _apply_authoritative_world_snapshot() = false
→ sesión termina
→ vuelta a selección de personaje
```

Se corrigió manteniendo `vitals` en el snapshot normalizado.

## Test final F16-C

Estado inicial autoritativo:

```text
HP: 100000/100000
MP: 350/350
```

Heal aceptado:

```text
Request: 1
Skill: heal
Accepted: true
Reason: ok
MP: 310/350
Cooldown: 4.0
```

Segundo Heal ejecutado después de expirar el cooldown:

```text
Request: 2
Accepted: true
Reason: ok
MP: 270/350
Cooldown: 4.0
```

Intento inmediato posterior:

```text
Request: 3
Accepted: false
Reason: cooldown_active
Cooldown remaining: 3.527
MP permanece 270/350
```

Fire Ball:

```text
Request: 4
Skill: fire_ball
Accepted: false
Reason: skill_not_implemented
MP permanece 270/350
```

Heal reportó `Heal: 0` porque HP ya estaba en el máximo. Esto es correcto: el cast fue válido, consumió mana e inició cooldown, pero no había HP faltante que restaurar.

Resultado:

> El cliente puede pedir un cast, pero sólo el Game Server decide si ocurre y cuál es el estado final de HP/MP/cooldown.

F16-C no incluye todavía el overlay visual autoritativo del cooldown.

No Laravel/MySQL por cada cast.

---

# 41. F16-D — FEEDBACK VISUAL AUTORITATIVO DE COOLDOWN

**Estado:** ✅ COMPLETADO Y VALIDADO.

Objetivo:

```text
resultado autoritativo de cast
→ cooldown_remaining_seconds
→ runtime cliente por skill_id
→ proyección visual
→ SkillSlot
→ overlay + contador
```

## Decisión arquitectónica

El cooldown visual deja de ser estado autónomo del `SkillSlot`.

Se incorpora:

```text
SkillCooldownState
```

dentro de:

```text
PlayerRuntimeState
```

Responsabilidades:

```text
Game Server
= autoridad real del cooldown

SkillCooldownState
= proyección cliente del tiempo restante

GameplayUI
= proyecta el runtime sobre los slots

SkillSlot
= sólo dibuja el valor recibido
```

El cliente puede interpolar visualmente el tiempo entre respuestas, pero eso no autoriza ni rechaza casts.

## Comportamiento validado

Primer Heal:

```text
Request: 1
Skill: heal
Accepted: true
Reason: ok
MP: 350 → 310
Cooldown: 4.0
```

Intento durante cooldown:

```text
Request: 2
Skill: heal
Accepted: false
Reason: cooldown_active
Cooldown remaining: 3.158
MP permanece 310
```

Después de vencer el cooldown:

```text
Request: 3
Skill: heal
Accepted: true
Reason: ok
MP: 310 → 270
Cooldown: 4.0
```

Nuevo intento prematuro:

```text
Request: 4
Skill: heal
Accepted: false
Reason: cooldown_active
Cooldown remaining: 3.545
MP permanece 270
```

Fire Ball continúa sin ejecución real:

```text
Request: 5
Skill: fire_ball
Accepted: false
Reason: skill_not_implemented
Cooldown: 0.0
MP permanece 270
```

## Test visual confirmado

Se validó manualmente:

```text
1. Heal muestra aproximadamente 4.0 → ... → 0.
2. El overlay y el número disminuyen correctamente.
3. Un rechazo cooldown_active resincroniza el tiempo visual con el valor del servidor.
4. Cambiar de Heal a Fire Ball y volver no reinicia ni elimina el cooldown de Heal.
5. Al llegar a 0 desaparecen CooldownOverlay y CooldownLabel.
6. Tras finalizar el cooldown, Heal vuelve a ser aceptado.
```

## Regresiones comprobadas

```text
click izquierdo → movimiento normal
Inventory → sin regresión observada
Equipment → sin regresión observada
NPC/world session → sin regresión observada
warnings/errors → ninguno observado
```

Resultado:

> El servidor conserva la autoridad absoluta del cooldown. El cliente sólo mantiene una proyección visual por `skill_id`, capaz de resincronizarse con cada respuesta autoritativa.

F16-D no modifica el Game Server.

---

# 42. F17 — PRIMER MOB + COMBATE

Implementar **un mob completo**, no veinte incompletos.

Conceptos previstos:

```text
MobDefinition
MobRuntimeState
MobActor
MobAI / controller
CombatCoordinator / service
```

Vertical slice:

```text
spawn
idle
aggro
move
attack
take damage
die
respawn
```

Fire Ball y Poison podrán reutilizar el backbone de F16.

Target PvE:

```text
click derecho sobre entidad
→ skill seleccionada
→ entity target intent
→ Game Server valida
```

## F17-A — Runtime autoritativo mínimo del primer mob

**Estado:** ✅ COMPLETADO Y VALIDADO.

Se incorporó en `vhal_game_server`:

```text
WorldMobDefinition
WorldMobRuntimeState
WorldMobRegistry
```

Decisión de dominio:

```text
WorldMobDefinition
= describe el tipo de monstruo

WorldMobRuntimeState
= representa una instancia viva concreta del mundo
```

Esto permite reutilizar una misma definición para múltiples entidades con distinto `entity_id`, posición y HP.

Primer tipo temporal:

```text
mob_type_id: training_goblin
display_name: Training Goblin
level: 1
max_hp: 50000
```

Primera instancia autoritativa:

```text
entity_id: mob_test_town_001
map_id: test_town
position: (4.0, 0.0, 4.0)
HP: 50000/50000
MP: 0/0
```

`WorldMobRuntimeState` reutiliza `ServerVitalsState`, por lo que el primer mob ya posee estado vital autoritativo compatible con el backbone de combate existente.

Test validado:

```text
WorldMobRegistry | Inicializado | Definiciones: 1 | Mobs: 1
WorldMobRegistry | Mob preparado | Entity: mob_test_town_001 | Type: training_goblin | Nombre: Training Goblin | Nivel: 1 | Mapa: test_town | Posición: (4.0, 0.0, 4.0) | HP: 50000/50000
```

Además se comprobó:

```text
login → OK
character select → OK
entrada a test_town → OK
Inventory/Equipment snapshots → OK
movimiento autoritativo → OK
warnings/errors → ninguno observado
```

El mensaje final de desconexión del cliente en el test ocurrió porque se detuvo manualmente el proceso de debugging del Game Server; no representa una regresión de red.

F17-A no incluye todavía:

```text
replicación del mob al cliente
MobActor
IA
aggro
movimiento de mobs
target PvE
daño de Fire Ball/Poison
muerte
respawn
drops
EXP
```

**Siguiente checkpoint:** `F17-B — roster/snapshot de mobs + representación cliente mínima`.

---

### F17-B — Authoritative Mob Replication + Client MobActor ✅

Estado: completado, probado manualmente y validado.

Implementado:

- `WorldPresenceCoordinator` incorpora los mobs autoritativos del mapa al roster inicial.
- `world_presence_snapshot` replica:
  - jugadores remotos,
  - mobs autoritativos.
- `GameServerPresenceProtocol` valida y normaliza snapshots de mobs.
- El cliente conserva `remote_mobs` durante el loading.
- `GameServerClient` expone el roster autoritativo de mobs.
- Nuevo `MobActor` cliente para representación visual de entidades mob.
- `GameplayScreen` sincroniza e instancia los mobs recibidos por red.
- El mapa cliente no define qué mobs existen; la existencia de mobs pertenece al Game Server.

Prueba validada en `test_town`:

- `mob_test_town_001`
- tipo `training_goblin`
- `Training Goblin`
- nivel 1
- HP 50000/50000
- posición (4, 0, 4)
- un único actor visual creado.
- movimiento autoritativo del jugador continúa funcionando.

El `MobActor` actual utiliza una representación visual placeholder.
Todavía no existen targeting, ataque, daño, aggro, IA ni muerte de mobs.

Siguiente checkpoint previsto:
F17-C — Entity Targeting Foundation.

# 44. PvP — DIRECCIÓN CANÓNICA

PvP no debe implementarse como excepción improvisada.

Contrato de input:

```text
Ctrl + click derecho
→ intención PvP contra player
```

Game Server deberá decidir:

```text
si el target es jugador
si el mapa permite PvP
estado PvP del atacante
estado PvP del objetivo
safe zone
distancia
line-of-sight
skill
mana
cooldown
damage
kill
criminal state
```

La arquitectura histórica prevista incluye estados tipo:

```text
Inocente
Diablillo
Delincuente
Pecador
```

y “auto defense”.

Estos sistemas se implementarán sobre el combat runtime autoritativo, no como lógica local del cliente.

---

# 44. F18 — DROP + PICKUP + EXP + LEVEL

Objetivo:

```text
mob muere
→ server calcula drop
→ WorldDrop
→ pickup intent
→ server valida
→ Inventory
```

Progression:

```text
kill
→ EXP
→ level
→ stats
→ HUD
→ persistencia
```

Aquí puede aparecer la necesidad real de:

```text
stack merge
consumibles
partial stack behavior
```

y entonces se reevalúa F15-C.

---

# 45. F19 — VERTICAL SLICE COMPLETO

Primer gran objetivo estratégico:

```text
CUENTA
↓
LOGIN
↓
PERSONAJE
↓
TICKET
↓
GAME SERVER
↓
LOADING
↓
MAPA
↓
PLAYER
↓
MOVEMENT
↓
NPC
↓
INVENTORY / VAULT / EQUIPMENT
↓
SKILL
↓
MOB
↓
COMBAT
↓
DROP
↓
PICKUP
↓
EXP / LEVEL
↓
LOGOUT
↓
LOGIN
↓
TODO PERSISTE
```

Hasta F19 estable:

> **No escalar contenido masivamente.**

Primero demostrar el circuito completo.

---

# 46. PERFORMANCE — SEPARADA DEL REFACTOR

Regla:

```text
Refactor ≠ Optimization
```

F15-R resolvió estructura/mantenibilidad.

No fue diseñado para reducir ping.

Algunas mutaciones persistentes todavía pueden ser relativamente lentas porque el flujo conservador es:

```text
Client
→ Game Server
→ domain validation
→ Laravel
→ MySQL
→ response
→ reload snapshot
→ Laravel/MySQL
→ Game Server
→ Client
```

Esto es aceptable durante Foundation para mutaciones persistentes.

No debe copiarse a Combat.

## PERF-0

Mediciones futuras:

```text
Client → GS RTT
GS validation time
GS → Backend RTT
Laravel controller time
DB transaction time
snapshot reload time
serialization time
packet size
packet frequency
```

## PERF-1

Optimización agresiva después de F19 estable salvo blocker real medido.

Posibles herramientas:

```text
container revisions
deltas
menos reloads completos
runtime-first authority
batching
connection reuse
interest management
binary protocol si profiling lo justifica
```

Regla:

```text
measure
→ identify bottleneck
→ change one thing
→ measure again
```

---

# 47. QUÉ NO HACER AHORA

Antes de F19 estable evitar:

```text
mapa final gigante
decenas de mobs
Guild completo
eventos masivos
Chaos Machine completa
cientos de ventanas anticipadas
convertir todo en Autoload
cliente directo a DB
mega-rewrite de Inventory
protocolo binario sin profiling
optimización profunda prematura
contenido masivo antes de Combat/Drop/EXP
```

---

# 48. AUTOLOADS

No convertir cada sistema en Singleton.

Un Autoload sólo debe existir cuando representa una responsabilidad verdaderamente global.

Preferir:

```text
scene composition
explicit dependencies
signals
coordinators
runtime state
```

sobre service locators globales.

---

# 49. SIGNALS Y DEPENDENCIAS

Usar signals cuando existe una relación de eventos real.

No usarlas sólo para ocultar dependencias.

Los sistemas importantes reciben dependencias mediante:

```text
setup(...)
node composition
constructor-like configuration
```

La dependencia debe ser rastreable.

---

# 50. PLAYERWORLDSESSION — REGLA

`PlayerWorldSession` representa el estado runtime autoritativo de una sesión/personaje conectado.

Puede componer:

```text
identity
world
vitals
skills
inventory/equipment snapshots
movement state
NPC service state
combat state futuro
```

Pero no debe convertirse en un “God object” con toda la lógica.

Regla:

```text
Session almacena/compone estado
Coordinators orquestan casos de uso
Domain classes validan reglas
Systems ejecutan lógica runtime especializada
```

---

# 51. VITALS — DIRECCIÓN

Game Server es autoridad de:

```text
HP
MP
max HP
max MP
```

El cliente representa esos valores.

Consumidores futuros:

```text
Heal
damage
potions
regen
mob attacks
PvP
death
respawn
```

Todos deben reutilizar el mismo pipeline autoritativo.

No crear:

```text
PotionHPSystem local
HealHPSystem separado
CombatHPSystem separado
```

con estados incompatibles.

---

# 52. SKILL OWNERSHIP / PROGRESIÓN

Actualmente las tres skills se asignan temporalmente mediante bootstrap de desarrollo.

No es el modelo final.

Futuro:

```text
Backend
→ skills aprendidas persistentes
→ bootstrap de sesión
→ ServerSkillRuntimeState
```

Game Server sigue siendo autoridad de:

```text
cast availability
cooldown
mana
execution
```

aunque ownership/progresión sea durable.

---

# 53. TARGETING — DIRECCIÓN

No definir prematuramente un mega-modelo universal.

Tipos conceptuales previstos:

```text
self
entity
position
```

F16 comienza con:

```text
self
```

F17 incorporará target de entidades reales.

PvP reutilizará target de entidad/player con reglas específicas del servidor.

No enviar coordenadas de pantalla como autoridad gameplay.

El cliente puede usar screen position para hacer picking local, pero el intent final debe referirse a una identidad/posición del mundo validable por servidor.

---

# 54. MOVEMENT VS COMBAT INPUT

Contrato definitivo:

```text
MOUSE LEFT
→ navegar/mover

MOUSE RIGHT
→ skill/combat

CTRL + MOUSE RIGHT
→ PvP
```

No volver a asignar cast a click izquierdo.

No introducir una segunda semántica incompatible en otra escena.

Todos los futuros controladores de input deben respetar este contrato.

---

# 55. DEBUG / FIXTURES

Los fixtures existen para acelerar Foundation.

Regla:

```text
mientras un sistema no sea real
→ fixture permitido

cuando aparece autoridad real
→ retirar gradualmente el fixture correspondiente
```

Ejemplos:

```text
Inventory persistente
→ ya no debe depender de inventario demo

Equipment persistente
→ ya no debe depender de equipment demo

Skills
→ todavía tienen ownership/bootstrap temporal
```

No eliminar fixtures que aún sirven a sistemas no reemplazados sin plan de transición.

---

# 56. MAPAS

Primer mapa:

```text
test_town
```

Utilizado para:

```text
spawn
movimiento
NavMesh
NPC
Warehouse
presencia
skills foundation
```

No construir mapa final gigante antes del vertical slice F19.

---

# 57. NPC FRAMEWORK

Primer NPC:

```text
npc_id = warehouse_keeper
service_id = warehouse
```

Reglas probadas:

```text
click
range
authorization
open service
move away
out_of_range
close/revoke
```

Merchant y otros servicios deben reutilizar el framework, no duplicarlo.

---

# 58. INVENTORY

Características actuales relevantes:

```text
multicelda
posición persistente
collision validation
bounds validation
stack quantity
stable UID
authoritative server/backend
```

Dirección visual:

```text
compacta
MU-like footprint
fixed window
draggable
viewport constrained
```

Operaciones avanzadas de stack siguen diferidas.

---

# 59. EQUIPMENT

Autoritativo y persistente.

Reglas importantes:

```text
slot compatibility
slot occupancy
hand modes
two-hand reservation
stable UID
Inventory ↔ Equipment
stale recovery
```

No duplicar la misma instancia para ocupar dos slots.

---

# 60. VAULT

Account-wide.

Contrato:

```text
Vault item
→ account_id
→ character_id NULL
```

Sólo puede abrirse mediante servicio NPC autorizado.

No mediante botón HUD directo.

---

# 61. WORLD PRESENCE

Foundation real:

```text
same-map roster
remote joined
remote left
movement replication
```

Se deberá extender más adelante con interés espacial si profiling/concurrencia lo requiere.

No optimizar prematuramente.

---

# 62. MOVEMENT

Arquitectura:

```text
Client click izquierdo
→ local prediction
→ move intent
→ Game Server
→ NavMesh resolution
→ authorization
→ WorldMovementSystem
→ authoritative movement state
→ clients
```

El movimiento sigue siendo independiente de Skills/Combat.

Right click no debe iniciar movement.

---

# 63. NETWORK PROTOCOL VERSIONING

Existe envelope versionado.

Agregar nuevos tipos de mensaje compatibles no obliga automáticamente a cambiar la versión.

Cambiar `NETWORK_PROTOCOL_VERSION` cuando exista una incompatibilidad real de contrato.

Mantener límites de paquete y validación estructural.

Un paquete malformado no debe llegar al gameplay como si fuese confiable.

---

# 64. SEGURIDAD / TRUST BOUNDARY

Nunca confiar en:

```text
client HP
client MP
client damage
client cooldown
client item position definitiva
client target permitido
client range
client EXP
client level-up result
```

El cliente solicita.

El servidor valida y decide.

---

# 65. ROADMAP RESUMIDO ACTUAL

```text
F00-F14 Foundation             ✅
F15-A Inventory ↔ Vault       ✅
F15-B Equipment               ✅
F15-R Architectural Refactor  ✅
F15-C Item operations         🟡 evaluado / diferido

F16-A Skill runtime           ✅
F16-B Cast protocol           ✅
F16-BR Input MU correction    ✅
F16-C Authoritative Heal      ✅
F16-D Cooldown visual/UI      ✅

F17-A Mob runtime             ✅
F17-B Mob replication         ⏳ SIGUIENTE
F18 Drop / Pickup / EXP       ⏳
F19 Vertical Slice            ⏳

PERF-1                        ⏳ después de F19 estable
```

---

# 67. PRÓXIMO PASO EXACTO

Antes de comenzar una etapa nueva:

```text
cerrar checkpoint F17-A
→ git status
→ commit
→ push
→ confirmar "pusheado"
```

Después:

```text
F17-B — roster/snapshot de mobs + representación cliente mínima
```

Objetivo del siguiente checkpoint:

```text
WorldMobRegistry
→ snapshot/roster autoritativo por mapa
→ GameServer protocol
→ cliente
→ MobActor mínimo
→ Training Goblin visible en test_town
```

Todavía sin IA ni daño real.

---

# 68. CRITERIO DE ÉXITO DEL PRÓXIMO TEST

El primer checkpoint de F17 deberá definir y validar el runtime autoritativo mínimo de una entidad hostil antes de conectar daño real de Fire Ball o Poison.

No implementar todavía daño de skills sobre un target inexistente o no autoritativo.

---

# 68. DECISIÓN SOBRE HEAL

Heal será la primera ejecución real porque no depende de F17.

Permite validar:

```text
skill lookup
ownership
mana
cooldown
target self
runtime mutation
authoritative result
HUD sync
cooldown feedback
```

Fire Ball y Poison continuarán después sobre el mismo backbone.

---

# 69. DECISIÓN SOBRE FIRE BALL / POISON

No implementar daño real antes de tener entidad/mob autoritativo.

Fire Ball necesitará:

```text
entity target
range
damage
combat state
aggro
death
replication
```

Poison necesitará además:

```text
status effect runtime
duration
tick policy
stack/refresh policy
death interaction
```

No crear implementaciones ficticias sólo para “hacerlas funcionar”.

---

# 70. DECISIÓN SOBRE CONSUMIBLES

Health Potion existe como item foundation, pero su uso se difiere hasta que el pipeline autoritativo de vitals/effects esté listo.

Cuando se implemente:

```text
use item intent
→ Game Server
→ validate item
→ validate quantity
→ apply effect through vitals/effects pipeline
→ consume quantity
→ persist item mutation
→ replicate vitals + inventory result
```

No aplicar HP local desde UI.

---

# 71. DEFINICIÓN DE “REAL” EN VHAL

Un sistema se considera real cuando:

```text
la intención nace en cliente
la autoridad está bien definida
el Game Server valida
el runtime muta correctamente
la persistencia ocurre donde corresponde
el resultado vuelve al cliente
hay recuperación/reconnect cuando aplica
los edge cases principales están probados
no depende de un shortcut de debug para su funcionamiento normal
```

---

# 72. REGLA FINAL DE CONTINUIDAD

Al abrir una nueva conversación o retomar el proyecto:

```text
1. leer PROJECT_MEMORY.md;
2. revisar repositorios reales en dev;
3. confirmar último checkpoint;
4. no confiar en recuerdos viejos por encima del repositorio;
5. identificar la etapa activa;
6. continuar sólo esa etapa;
7. respetar test → commit → push → "pusheado".
```

Referencias históricas de F16 antes del cierre de F16-C:

```text
Cliente F16-B:
c8a7916be8fe3091f394611e09d89da75b398c20
feat: add skill cast intent protocol

Game Server F16-B:
9d32d0e62705a916036afba97e39d21a656d4424
feat: receive authoritative skill cast intents
```

El SHA definitivo de cierre de F16-C debe verificarse en `dev` después del push del checkpoint, porque este mismo archivo forma parte de ese commit.

La etapa funcionalmente validada es:

```text
F17-A — runtime autoritativo mínimo del primer mob
```

Contrato vigente:

```text
LEFT CLICK          = MOVE
RIGHT CLICK         = SKILL
CTRL + RIGHT CLICK  = PvP
```

Próxima etapa después del checkpoint Git:

```text
F17-B — roster/snapshot de mobs + representación cliente mínima
```

**No avanzar a F17-B hasta commitear, pushear y confirmar el cierre de F17-A.**
