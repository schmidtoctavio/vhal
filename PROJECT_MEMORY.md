# VHAL — PROJECT MEMORY / ARQUITECTURA / ROADMAP CANÓNICO

**Última actualización:** 25/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama de desarrollo habitual:** `dev`  
**Estado general:** Foundation avanzada, F15-R cerrado, F15-C evaluado/diferido, F16 completo, F17 completo, F18 completo y F19 Vertical Slice completo, probado de punta a punta y sin blockers funcionales observados. El gameplay normal ya no depende del bootstrap debug. Próxima decisión: elegir el siguiente bloque post-F19; candidato recomendado: persistencia durable del runtime del personaje (posición + HP/MP), antes de escalar contenido.

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
ServerBasicAttackRuntimeState
WorldMobRuntimeState
WorldDropRuntimeState
movimiento autoritativo
servicio NPC activo
snapshots persistentes conocidos
combat runtime autoritativo
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
│   │   │       ├── game_server_skill_protocol.gd
│   │   │       └── game_server_combat_protocol.gd
│   │   └── ui/
│   ├── inventory/
│   ├── items/
│   ├── player/
│   ├── skills/
│   ├── vault/
│   └── world/
│       ├── mobs/
│       ├── npcs/
│       └── drops/
│           ├── world_drop_actor.gd
│           └── world_drop_actor.tscn
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
├── Skills/Cast bridge
├── Combat/Mob-state bridge
├── World Drop / Pickup bridge
└── Character Progression bridge
```

`GameSessionFlowCoordinator` es el puente entre:

```text
GameplayScreen
↔
GameServerClient
```

para intención y resultados de gameplay.

Desde F18-B transporta:

```text
world_drop_pickup_intent_requested
→ GameServerClient.send_world_drop_pickup_request()

world_drop_removed
→ GameplayScreen.apply_world_drop_removed()

character_inventory_snapshot
→ PlayerRuntimeState
→ GameplayUI refresh
```

Desde F18-C también transporta:

```text
world_snapshot.progression
→ PlayerRuntimeState.apply_progression_snapshot()
→ ExperienceState
→ XPBar

character_progression_updated
→ GameplayScreen
→ PlayerRuntimeState
→ CharacterSummary.level + ExperienceState
→ HUD
```

Regla de bootstrap validada:

```text
PlayerRuntimeState
↓
asignar CharacterSummary real
↓
aplicar Progression / Vitals / World autoritativos
↓
reconstruir Inventory / Equipment
↓
abrir Gameplay
```

La identidad del personaje debe existir antes de aplicar Progression.

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
├── GameServerSkillProtocol
├── GameServerCombatProtocol
└── GameServerProgressionProtocol
```

No crear sockets independientes por feature sin necesidad real.

Ejemplos incorrectos:

```text
InventoryConnection
CombatConnection
ChatConnection
NpcConnection
DropConnection
ProgressionConnection
```

## WorldProtocol

Procesa el bootstrap autoritativo inicial.

Desde F18-C el `world_snapshot` exige:

```text
character
vitals
progression
world
```

Progression inicial:

```text
level
experience
experience_required
```

Además valida:

```text
character.level == progression.level
```

Su estado `latest_world_snapshot` se limpia al resetear conexión para evitar identidad stale entre reconnects.

## ProgressionProtocol

Introducido en F18-C2B.

Procesa únicamente actualizaciones live:

```text
character_progression_updated
```

Valida:

```text
character_id
level
experience
experience_required
experience_gained
levels_gained
```

y comprueba que `character_id` corresponda al personaje del snapshot activo.

No calcula:

```text
EXP reward
threshold
level-up
balance
```

Sólo transporta y valida el resultado autoritativo.

## ItemProtocol

Inventory, Vault, Equipment y las mutaciones persistentes relacionadas con items continúan juntos cuando comparten el mismo contrato de serialización.

Responsabilidades actuales adicionales desde F18-B:

```text
serializar world_drop_pickup_request
asignar request_id monotónico
bloquear mutaciones de item mientras el pickup está pendiente
procesar world_drop_pickup_result
liberar el pending cuando llega el Inventory autoritativo
```

Mensajes relevantes:

```text
world_drop_pickup_request
world_drop_pickup_result
```

Un pickup aceptado NO se considera totalmente resincronizado en cliente hasta recibir:

```text
character_inventory_snapshot
```

porque Laravel sigue siendo source of truth durable del Inventory.

## PresenceProtocol

Además de players y mobs mantiene:

```text
remote_drops
```

y procesa:

```text
world_drop_spawned
world_drop_removed
```

Cuando llega `world_drop_removed`:

```text
remote_drops.erase(entity_id)
→ GameSessionFlowCoordinator
→ GameplayScreen
→ WorldDropActor desaparece
```

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

## CombatProtocol

Responsabilidad actual:

```text
serializar basic_attack_request
asignar request_id independiente
validar estructura del basic_attack_result
correlacionar entity_id solicitado
transportar resultado autoritativo
```

No decide:

```text
arma equipada
attack mode
range
cooldown real
damage
HP del mob
muerte
EXP
level
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
│       ├── character_progression_coordinator.gd
│       ├── equipment_coordinator.gd
│       ├── inventory_coordinator.gd
│       ├── vault_coordinator.gd
│       ├── item_container_transfer_coordinator.gd
│       ├── npc_service_coordinator.gd
│       ├── movement_coordinator.gd
│       ├── world_presence_coordinator.gd
│       ├── world_drop_coordinator.gd
│       ├── world_drop_pickup_coordinator.gd
│       ├── skill_cast_coordinator.gd
│       └── basic_attack_coordinator.gd
│
└── core/
	├── networking/
	├── backend/
	│   ├── backend_character_inventory_repository.gd
	│   └── backend_character_progression_repository.gd
	├── progression/
	│   └── server_character_progression_rules.gd
	├── items/
	│   ├── server_item_catalog.gd
	│   ├── server_character_inventory_snapshot_validator.gd
	│   ├── server_persistent_item_uid_generator.gd
	│   └── server_inventory_placement_resolver.gd
	├── combat/
	│   ├── server_vitals_state.gd
	│   ├── server_character_runtime_bootstrap.gd
	│   ├── server_basic_attack_profile_resolver.gd
	│   └── server_basic_attack_runtime_state.gd
	├── skills/
	│   ├── server_skill_definition.gd
	│   ├── server_skill_catalog.gd
	│   └── server_skill_runtime_state.gd
	└── world/
		├── movement/
		├── navigation/
		├── npcs/
		├── mobs/
		└── drops/
			├── world_drop_runtime_state.gd
			├── world_drop_registry.gd
			└── server_mob_drop_catalog.gd
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

Actualmente registra también:

```text
WorldDropPickupCoordinator
CharacterProgressionCoordinator
BackendCharacterProgressionRepository
```

`CharacterProgressionCoordinator` depende de:

```text
GameServer
WorldSessionRegistry
WorldMobRegistry
BackendCharacterProgressionRepository
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

Después de un pickup persistido, el Inventory vuelve a cargarse desde Laravel y este coordinator envía el snapshot definitivo al cliente.

## CharacterProgressionCoordinator

Introducido en F18-C2A.

Escucha:

```text
WorldMobRegistry.mob_died
```

No depende de:

```text
BasicAttackCoordinator
WorldDropCoordinator
```

Responsabilidad:

```text
resolver killer desde source autoritativo
resolver PlayerWorldSession
validar mismo character/map
leer experience_reward desde WorldMobDefinition
encolar EXP por peer
calcular next level/experience con ServerCharacterProgressionRules
persistir expected → next vía BackendCharacterProgressionRepository
actualizar PlayerWorldSession sólo tras confirmación Laravel
replicar character_progression_updated
recuperar stale state cuando Laravel responde 409
conservar reward en cola si una persistencia falla
```

Permite acumular rewards mientras existe una escritura pendiente:

```text
pending_by_peer
queued_experience_by_peer
```

Orden crítico:

```text
mob_died
↓
calcular candidato
↓
persistir Laravel
↓ éxito
actualizar runtime
↓
replicar al cliente
```

No se informa EXP optimista antes de persistencia.

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

Responsabilidad actual:

```text
same-map roster
initial presence
player joined
player left
authoritative mob roster por mapa
authoritative drop roster por mapa
world_drop_spawned replication
world_drop_removed replication
mob respawn replication
bootstrap de entidades de mundo replicadas
```

El roster inicial vigente es:

```text
world_presence_snapshot
├── players
├── mobs
└── drops
```

## WorldDropCoordinator

Escucha:

```text
WorldMobRegistry.mob_died
```

Responsabilidad:

```text
resolver drop table
hacer loot roll autoritativo
crear WorldDropRuntimeState
registrarlo en WorldDropRegistry
```

No conoce BasicAttackCoordinator.

La relación vigente con Progression es por fan-out del mismo evento:

```text
mob_died
├── WorldDropCoordinator
├── CharacterProgressionCoordinator
└── respawn scheduler
```

## WorldDropPickupCoordinator

Introducido en F18-B.

Responsabilidad:

```text
recibir pickup request
resolver PlayerWorldSession
validar request_id monotónico
resolver WorldDrop por entity_id
validar que no esté locked
validar mismo mapa
validar rango autoritativo
resolver primer espacio válido de Inventory
reservar/lockear el drop
persistir ItemInstance vía BackendCharacterInventoryRepository
esperar confirmación Laravel
consumir WorldDrop recién después del éxito
replicar world_drop_removed
enviar pickup result
recargar Inventory desde Laravel
liberar pending/lock
```

Rango foundation actual:

```text
PICKUP_RANGE = 2.0
```

Protecciones:

```text
stale_request
drop_not_found
drop_busy
wrong_map
out_of_range
inventory_unavailable
inventory_full
inventory_busy
persistence_unavailable
persistence_rejected
```

Regla crítica:

```text
PERSIST INVENTORY
↓ éxito
CONSUME WORLD DROP
```

Nunca al revés.

## BasicAttackCoordinator

```text
basic attack intent
request_id monotónico
caster alive
target mob autoritativo
same-map validation
target alive
Equipment autoritativo
attack profile
range
attack cooldown
damage
mutación de HP del mob
replicación del mob actualizado
```

El cliente nunca decide damage, range ni arma real.

BasicAttack tampoco calcula EXP.

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

Desde F18-C el bootstrap incluye:

```text
progression
├── level
├── experience
└── experience_required
```

## SkillCastCoordinator

Introducido en F16-B y llevado a ejecución autoritativa real en F16-C.

Responsabilidad actual:

```text
recibir una intención de cast estructuralmente válida
resolver PlayerWorldSession del peer
validar request_id monotónico
resolver skill autoritativa
validar skill aprendida
validar target soportado
validar estado del personaje
validar mana
validar cooldown
mutar runtime autoritativo
aplicar effects soportados
replicar skill_cast_result
```

Estado actual de ejecución:

```text
Heal / self      → implementado y autoritativo
Fire Ball        → todavía skill_not_implemented
Poison           → todavía skill_not_implemented
```

Targeting de entidades, range y daño real se incorporan progresivamente.

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
idempotencia
```

No es autoridad de gameplay en tiempo real.

## Character progression

Desde F18-C1 `characters` persiste:

```text
level
experience
```

Semántica:

```text
level
= nivel actual

experience
= EXP acumulada dentro del nivel actual
```

Laravel NO decide la curva de experiencia.

No persiste:

```text
experience_required
mob reward
level curve
```

Eso pertenece al Game Server.

Endpoint interno:

```text
PATCH
/api/internal/accounts/{accountId}/characters/{characterId}/progression
```

Payload:

```text
expected:
  level
  experience

next:
  level
  experience
```

Componentes:

```text
CharacterProgressionPersistence
CharacterProgressionPersistenceException
InternalCharacterProgressionController
```

Persistencia:

```text
DB transaction
→ lockForUpdate(character)
→ verificar account/character
→ idempotencia exacta
→ stale protection
→ guardar level + experience
```

Idempotencia:

```text
estado durable actual == next
→ OK
→ idempotent = true
```

Stale:

```text
estado durable actual != expected
y != next
→ HTTP 409
→ devuelve current
```

Protección estructural:

```text
level no puede retroceder
experience no puede retroceder dentro del mismo level
```

Test validado:

```text
Tests\Feature\InternalCharacterProgressionTest
5 passed
23 assertions
```

Checkpoint backend:

```text
fc85ce6a684d8d85ab92a8af75afbd9f1a222bfb
feat: add durable character progression persistence
```

El ticket interno también devuelve:

```text
character.level
character.experience
```

para que el Game Server cree `PlayerWorldSession` desde el estado durable real.

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

## F18-B1 — durable Inventory grant

Se agregó una operación interna para crear un item nuevo dentro del Inventory:

```text
POST
/api/internal/accounts/{accountId}/characters/{characterId}/inventory/items
```

Sólo accesible mediante el middleware interno del Game Server.

Payload foundation:

```text
uid
item_id
quantity
grid_position.x
grid_position.y
```

Laravel NO genera otro UID.

Persiste exactamente el UID decidido por el Game Server.

Componentes:

```text
CharacterInventoryPersistence
InventoryPersistenceException
InternalCharacterInventoryController::storeItem()
```

Regla de idempotencia:

```text
mismo UID
+
mismos account/character/container/item/quantity/position
→ operación idempotente
→ NO duplica
→ devuelve el item existente
```

Conflicto:

```text
mismo UID
+
estado diferente
→ HTTP 409
```

`item_instances.uid` mantiene además `UNIQUE` como defensa final ante requests concurrentes.

Test validado:

```text
Tests\Feature\InternalCharacterInventoryPickupTest
4 passed
20 assertions
```

Casos probados:

```text
grant nuevo → 201
grant idéntico repetido → 200 idempotent
mismo UID con payload diferente → 409
UID inválido → 422
```

Checkpoint backend:

```text
d54dead554ec8e22f770fd9c429164da83dde922
feat: add idempotent inventory item grants
```

---

# 18. CONTRATO DE UID DE ITEMS

Cada item concreto persistente tiene un UID estable.

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

## WorldDrop: dos identidades diferentes

Desde F18-B un drop posee:

```text
entity_id
persistent_item_uid
```

Ejemplo:

```text
entity_id:
world_drop_00000001

persistent_item_uid:
82448968-8c0a-4d8c-a299-91be8dbc12c1
```

Significado:

```text
entity_id
= identidad runtime de la entidad tirada en el mundo

persistent_item_uid
= identidad durable del ItemInstance si el drop es recogido
```

`entity_id` puede reiniciar cuando reinicia el Game Server.

`persistent_item_uid` NO debe derivarse de esa secuencia.

Se genera como UUID v4 server-side mediante:

```text
ServerPersistentItemUidGenerator
```

El UUID persistente no se envía al cliente dentro del snapshot del WorldDrop porque el cliente no necesita decidir ni conocer esa identidad para solicitar pickup.

Flujo:

```text
WorldDropRuntimeState
persistent_item_uid = X
↓
pickup
↓
Laravel grant uid = X
↓
ItemInstance durable uid = X
```

Esto permite idempotencia y evita duplicar objetos ante reintentos.

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
Heal autoritativo
MP autoritativo
cooldown autoritativo + feedback visual
runtime autoritativo de mobs
replicación de mobs por roster de mundo
MobActor cliente originado desde snapshot del Game Server
muerte autoritativa de mob
respawn autoritativo
WorldDrop runtime autoritativo
loot table server-side
replicación de WorldDrops
WorldDropActor cliente
reconexión con drops existentes
pickup click/intention
pickup range validation server-side
UUID persistente por drop
grant durable e idempotente en Laravel
WorldDrop consumido sólo después de persistencia
world_drop_removed replicado
Inventory actualizado después de pickup
reconexión conserva item y no revive drop recogido
EXP reward server-side por mob
EXP/Level autoritativos
persistencia durable level + experience
level-up autoritativo
replicación live de Progression
bootstrap de Progression desde world_snapshot
XPBar conectada a ExperienceState autoritativo
reconnect conserva Level/EXP
```

Loop MMORPG real ya probado:

```text
Mob
→ Damage
→ Death
├── Drop
│   → Pickup
│   → ItemInstance en MySQL
│   → Inventory cliente
└── EXP
	→ persistencia MySQL
	→ Level Up
	→ HUD / XPBar
```

Test integrado F18-C:

```text
Level 121 | EXP 0/100
→ matar Training Goblin
Level 121 | EXP 50/100
→ matar Training Goblin
Level 122 | EXP 0/100
→ reconnect
Level 122 | EXP 0/100
```

Durante el mismo test siguieron funcionando:

```text
movement
basic attack
mob death
drop
pickup
Inventory refresh
respawn
reconnect con WorldDrop no recogido
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

La referencia funcional buscada es similar a MU Online, pero con identidad visual y arquitectura propias de VHAL.

## Contrato resumido definitivo

```text
LEFT CLICK sobre terreno
→ MOVE

LEFT CLICK sobre NPC interactuable
→ NPC INTERACTION

LEFT CLICK sobre mob hostil
→ BASIC ATTACK PvE

RIGHT CLICK
→ SELECTED SKILL PvE / uso según target_kind

CTRL + LEFT CLICK sobre player
→ BASIC ATTACK PvP

CTRL + RIGHT CLICK sobre player
→ SELECTED SKILL PvP
```

El click izquierdo es contextual. Si existe una entidad aplicable bajo el cursor, se resuelve primero esa entidad; si no, el click se interpreta como movimiento.

Basic Attack PvE:

```text
LEFT CLICK sobre mob hostil
→ basic_attack_intent
→ Game Server
→ resolver target autoritativo
→ resolver Equipment/arma autoritativa
→ validar mapa/rango/estado
→ ejecutar ataque básico
```

Modalidades previstas:

```text
sin arma → puños / unarmed melee
arma melee → ataque básico melee
arma ranged → ataque básico ranged
```

El cliente no decide arma real, damage, range, hit ni muerte.

Skills PvE:

```text
RIGHT CLICK
→ ejecutar selected skill
```

Targets actuales:

```text
Heal       → self
Fire Ball  → entity
Poison     → entity
```

PvP futuro:

```text
CTRL + LEFT CLICK sobre player
→ BASIC ATTACK PvP

CTRL + RIGHT CLICK sobre player
→ SELECTED SKILL PvP
```

El Game Server mantiene autoridad sobre target, mapa, safe zone, estado PvP, range, equipment, mana, cooldown, damage, kill y criminal state.

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

**Estado:** ✅ FOUNDATION DE CAST/HEAL/COOLDOWN COMPLETADA Y VALIDADA.

El backbone de cast real quedó cerrado en F16-A/B/BR/C/D. El targeting de entidades y el daño de skills ofensivas continúa en F17.

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

**Checkpoint siguiente realizado:** `F17-B — roster/snapshot de mobs + representación cliente mínima`.

---

## F17-B — REPLICACIÓN AUTORITATIVA DE MOBS + MOB ACTOR

**Estado:** ✅ COMPLETADO, PROBADO Y VALIDADO.

Objetivo:

```text
WorldMobRegistry
→ mobs autoritativos del mapa
→ WorldPresenceCoordinator
→ world_presence_snapshot
→ GameServerPresenceProtocol
→ remote_mobs
→ GameSessionFlowCoordinator
→ GameplayScreen
→ MobActor
```

## Decisión arquitectónica

El mapa cliente NO define qué mobs existen.

La autoridad es:

```text
Game Server
→ determina qué mob existe
→ entity_id
→ mob_type_id
→ mapa
→ posición
→ HP
→ alive
```

El cliente:

```text
valida snapshot
normaliza tipos
conserva remote_mobs durante loading
instancia representación visual
```

No se coloca manualmente el mob dentro de `test_town.tscn` como fuente de verdad.

## Networking

El roster inicial de mundo ahora transporta:

```text
players
mobs
```

`WorldPresenceCoordinator` obtiene los mobs autoritativos mediante:

```text
WorldMobRegistry.get_mobs_in_map(map_id)
```

y los envía en:

```text
world_presence_snapshot
```

El cliente mantiene:

```text
GameServerPresenceProtocol.remote_players
GameServerPresenceProtocol.remote_mobs
```

El patrón de loading se reutiliza:

```text
roster llega antes de GameplayScreen
→ protocolo conserva estado normalizado
→ GameplayScreen se crea
→ GameSessionFlowCoordinator sincroniza players
→ sincroniza mobs
```

## Representación cliente

Se incorporó:

```text
features/world/mobs/mob_actor.gd
features/world/mobs/mob_actor.tscn
```

El `MobActor` actual es una representación técnica placeholder.

Muestra temporalmente:

```text
Training Goblin [Lv. 1]
50000 / 50000 HP
```

No representa el modelado final del mob.

## Test validado

Servidor:

```text
WorldMobRegistry | Inicializado | Definiciones: 1 | Mobs: 1
WorldMobRegistry | Mob preparado | Entity: mob_test_town_001 | Type: training_goblin | Nombre: Training Goblin | Nivel: 1 | Mapa: test_town | Posición: (4.0, 0.0, 4.0) | HP: 50000/50000
WorldPresenceCoordinator | Presencia de mundo preparada | Mapa: test_town | Mobs: 1 | Remotos existentes: 0
```

Cliente:

```text
GameServerClient | Roster de mundo recibido | Remotos: 0 | Mobs: 1
MobActor | Preparado | Entity: mob_test_town_001 | Type: training_goblin | Nombre: Training Goblin | Nivel: 1 | HP: 50000/50000 | Posición: (4.0, 0.0, 4.0)
GameplayScreen | Mobs sincronizados | Cantidad: 1
```

Validación visual:

```text
1. aparece un único Training Goblin;
2. aparece aproximadamente en (4, 0, 4);
3. muestra Training Goblin [Lv. 1];
4. muestra 50000 / 50000 HP;
5. el jugador continúa moviéndose normalmente;
6. no aparecen warnings/errors nuevos.
```

La desconexión observada al final del test ocurrió después de detener manualmente el proceso de debugging del Game Server y no representa una regresión.

F17-B todavía NO incluye:

```text
target selection
entity target intent
click/hitbox de mob
Fire Ball contra mob
damage
aggro
IA
movimiento del mob
muerte
respawn
drops
EXP
```

**Siguiente checkpoint:** `F17-C — Entity Targeting Foundation`.


## F17-C — ENTITY TARGETING FOUNDATION

**Estado:** ✅ COMPLETADO Y VALIDADO.

Flujo validado:

```text
RIGHT CLICK sobre mob
→ raycast cliente
→ MobActor
→ entity_id estable
→ skill_cast_request target=entity
→ Game Server
→ WorldMobRegistry
→ resolver entidad autoritativa
→ validar mismo mapa
→ validar alive
```

`SkillDefinition` y `ServerSkillDefinition` incorporan `target_kind`.

```text
Heal       → self
Fire Ball  → entity
Poison     → entity
```

`MobActor` incorpora `TargetArea` únicamente para picking local.

El intent enviado es:

```json
{
  "kind": "entity",
  "entity_id": "mob_test_town_001"
}
```

El Game Server vuelve a resolver el `entity_id` mediante `WorldMobRegistry.get_mob()` y valida existencia, mismo mapa, estado alive y compatibilidad de target.

Fire Ball todavía no ejecuta daño. En F17-C el resultado correcto después de validar el target sigue siendo:

```text
Accepted: false
Reason: skill_not_implemented
MP permanece 350/350
```

Test validado:

```text
RIGHT CLICK en piso con Fire Ball
→ entity_target_required
→ no se envía request

RIGHT CLICK sobre Training Goblin
→ mob_test_town_001 detectado
→ target entity enviado
→ Game Server valida target autoritativo
→ skill_not_implemented
```

Heal continúa funcionando:

```text
Target: self
Accepted: true
MP: 350 → 310
Cooldown: 4.0
```

No se observaron parser errors, warnings nuevos ni runtime errors inesperados.

Checkpoints:

```text
Cliente:
b8341bb1d226dd933a4532405ca32eabc39c2428
feat: add authoritative entity targeting foundation

Game Server:
0323d39861801caf5cb56bbad30c5b94d9c702c5
feat: validate authoritative skill entity targets
```

F17-C todavía NO incluye:

```text
basic attack
weapon attack
attack range
damage
Fire Ball damage
aggro
IA
muerte
respawn
drops
EXP
```

**Siguiente checkpoint:** `F17-D — Basic Attack PvE Foundation`.


## F17-D — BASIC ATTACK PvE FOUNDATION

**Estado:** ✅ COMPLETADO Y VALIDADO.

Objetivo cerrado:

```text
LEFT CLICK sobre mob hostil
→ resolver entity_id
→ basic_attack_intent
→ Game Server
→ resolver PlayerWorldSession
→ resolver WorldMobRuntimeState
→ validar target autoritativo
→ resolver Equipment autoritativo
→ derivar attack profile
→ responder sin ejecutar todavía damage
```

### Input PvE validado

El click izquierdo es contextual:

```text
LEFT CLICK terreno
→ MOVE

LEFT CLICK NPC
→ INTERACT

LEFT CLICK mob hostil
→ BASIC ATTACK PvE
```

`CTRL + LEFT CLICK` continúa reservado para Basic Attack PvP futuro y no se convierte accidentalmente en movimiento ni ataque PvE.

### Protocolo independiente de Skills

Se incorporó un protocolo específico de combate:

```text
GameServerCombatProtocol
```

Mensajes:

```text
basic_attack_request
basic_attack_result
```

El cliente sólo envía:

```json
{
  "request_id": 1,
  "target": {
	"kind": "entity",
	"entity_id": "mob_test_town_001"
  }
}
```

No envía como autoridad:

```text
weapon
attack mode
damage
range
hit
```

### Game Server

Se incorporó:

```text
BasicAttackCoordinator
```

Responsabilidad del coordinator:

```text
resolver sesión autoritativa
validar request_id
validar caster alive
resolver mob mediante WorldMobRegistry
validar mismo mapa
validar target alive
resolver Equipment autoritativo
derivar attack profile
devolver resultado autoritativo
```

Todavía no ejecuta damage.

### Equipment → attack profile

Se incorporó:

```text
ServerBasicAttackProfileResolver
```

El perfil se deriva desde:

```text
PlayerWorldSession.equipment_snapshot
```

y `ServerItemCatalog`.

Modos foundation:

```text
unarmed
melee
ranged
```

El catálogo autoritativo agrega:

```text
basic_attack_mode_id
```

para definiciones que afectan combate.

### Test 1 — sin arma

Equipment:

```text
Items: 0
```

Resultado autoritativo validado:

```text
BasicAttackCoordinator | Intent autoritativo validado
| Entity: mob_test_town_001
| Mob HP: 50000/50000
| Mode: unarmed
| Weapon:
```

Resultado:

```text
Accepted: false
Reason: basic_attack_not_implemented
Mode: unarmed
```

Cliente:

```text
GameServerClient | Resultado autoritativo de Basic Attack
| Entity: mob_test_town_001
| Accepted: false
| Reason: basic_attack_not_implemented
| Mode: unarmed
| Weapon:
```

### Test 2 — bronze_sword equipada

La espada se equipó mediante el pipeline autoritativo existente:

```text
EquipmentCoordinator
→ main_hand
→ persistencia
→ Inventory snapshot
→ Equipment snapshot
```

Game Server:

```text
BasicAttackCoordinator | Intent autoritativo validado
| Personaje: Atilio
| Entity: mob_test_town_001
| Mob HP: 50000/50000
| Mode: melee
| Weapon: bronze_sword
```

Cliente:

```text
GameServerClient | Resultado autoritativo de Basic Attack
| Entity: mob_test_town_001
| Accepted: false
| Reason: basic_attack_not_implemented
| Mode: melee
| Weapon: bronze_sword
```

Esto prueba que el cliente no elige el arma ni el modo de ataque.

El Game Server los obtiene desde Equipment real.

### Regresiones validadas

Continuaron funcionando:

```text
LEFT CLICK terreno
→ movimiento autoritativo

LEFT CLICK Warehouse Keeper
→ interacción NPC
→ Vault autorizada

RIGHT CLICK Training Goblin
→ Fire Ball
→ entity target
→ skill_not_implemented

Heal
→ self
→ mana
→ cooldown
```

Se corrigió además el warning:

```text
CONFUSABLE_LOCAL_DECLARATION
```

separando semánticamente:

```text
skill_target_entity_id
basic_attack_target_entity_id
```

La ejecución final quedó sin warnings/errors nuevos.

### Checkpoints remotos

Cliente:

```text
4be6c087d209975a38fa6a08328415018bc63669
feat: add basic attack pve intent foundation
```

Game Server:

```text
bbc6f4e378938581db0be31d00b2cbd51f50bac1
feat: validate authoritative basic attack intents
```

### Límite de F17-D

F17-D valida intención, target y perfil de ataque.

Todavía NO incluye:

```text
attack range real
attack speed / cooldown
damage
mutación de HP del mob
orientación al target
animación
auto-chase
aggro
retaliación
muerte
respawn
drops
EXP
```

**Siguiente checkpoint:** `F17-E — Authoritative Basic Attack Execution`.


## F17-E — AUTHORITATIVE BASIC ATTACK EXECUTION

**Estado:** ✅ COMPLETADO, PROBADO Y VALIDADO.

F17-E transforma el Basic Attack de una intención validada en una ejecución real de combate autoritativo.

Flujo cerrado:

```text
LEFT CLICK sobre mob hostil
→ basic_attack_request
→ BasicAttackCoordinator
→ resolver PlayerWorldSession
→ resolver WorldMobRuntimeState
→ resolver Equipment real
→ derivar attack profile
→ validar range
→ validar attack cooldown
→ calcular damage en Game Server
→ mutar HP del mob
→ basic_attack_result
→ mob_state_updated
→ clientes del mismo mapa
→ MobActor actualizado
```

### ServerVitalsState

Se incorporó damage real reutilizable:

```text
apply_damage(amount)
```

La primitive:

```text
clampa HP entre 0 y max_hp
devuelve damage realmente aplicado
```

No existe mutación manual del tipo:

```text
mob.vitals.hp -= X
```

fuera del dominio de vitals/runtime.

### Basic Attack runtime

Se incorporó:

```text
ServerBasicAttackRuntimeState
```

Responsabilidad:

```text
cooldown_until_msec
cooldown remaining
cooldown active
start cooldown
reset
```

La cadence de Basic Attack queda separada del runtime de cooldowns de Skills.

`PlayerWorldSession` posee su runtime autoritativo de Basic Attack.

### Attack profile autoritativo

`ServerBasicAttackProfileResolver` continúa resolviendo Equipment real y ahora además entrega:

```text
mode
weapon_item_id
weapon_uid
base_damage
attack_range
cooldown_duration_seconds
```

Valores temporales de Foundation:

```text
UNARMED
damage:   500
range:    1.5
cooldown: 1.0 s

BRONZE SWORD
mode:     melee
damage:   1000
range:    2.0
cooldown: 0.9 s
```

Estos números NO representan balance definitivo.

La fuente real del arma sigue siendo:

```text
PlayerWorldSession.equipment_snapshot
→ ServerItemCatalog
→ ServerBasicAttackProfileResolver
```

El cliente no declara arma, damage, range ni cooldown.

### Range autoritativo

El Game Server calcula distancia XZ entre:

```text
PlayerWorldSession.position
WorldMobRuntimeState.position
```

Un request fuera de rango:

```text
Accepted: false
Reason: out_of_range
```

y no muta HP.

Test real validado:

```text
Distancia: 5.65685415267944
Rango: 2.0
Accepted: false
Reason: out_of_range
```

Training Goblin permaneció:

```text
50000 / 50000 HP
```

### Damage melee real

Con `bronze_sword` persistida en `main_hand`:

```text
Mode: melee
Weapon: bronze_sword
Damage: 1000
```

Ataques autoritativos validados:

```text
50000 → 49000
49000 → 48000
```

Game Server:

```text
BasicAttackCoordinator | Ataque ejecutado
| Entity: mob_test_town_001
| Mode: melee
| Weapon: bronze_sword
| Damage: 1000
| HP restante: 49000/50000
```

y luego:

```text
HP restante: 48000/50000
```

### Cooldown melee

Un ataque enviado demasiado pronto fue rechazado:

```text
BasicAttackCoordinator | Cooldown activo
| Request: 4
| Restante: 0.324

Accepted: false
Reason: attack_cooldown_active
```

No hubo damage adicional durante ese request.

### Damage unarmed real

Después de Unequip autoritativo:

```text
Equipment persistente cargado
| Items: 0
```

el mismo pipeline cambió automáticamente a:

```text
Mode: unarmed
Weapon:
Damage: 500
```

Resultado:

```text
48000 → 47500
```

Game Server:

```text
BasicAttackCoordinator | Ataque ejecutado
| Mode: unarmed
| Damage: 500
| HP restante: 47500/50000
```

También se validó cooldown unarmed:

```text
Request: 6
Reason: attack_cooldown_active
Restante: 0.4
```

### Replicación autoritativa del HP del mob

Se incorporó:

```text
mob_state_updated
```

como evento:

```text
Game Server
→ todos los PlayerWorldSession del mismo map_id
```

`WorldSessionRegistry.get_sessions_in_map()` se reutiliza como fuente de recipients.

En el test:

```text
BasicAttackCoordinator | Estado de mob replicado
| Entity: mob_test_town_001
| Recipients: 1
| HP: 49000/50000
```

El cliente procesa el snapshot mediante el parser existente de `GameServerPresenceProtocol`, conserva `remote_mobs` actualizado y emite `mob_state_updated`.

`GameplayScreen` reutiliza:

```text
_spawn_or_update_mob()
```

y el mismo `MobActor.setup()`.

Cliente validado:

```text
GameServerClient | Estado de mob actualizado
| Entity: mob_test_town_001
| HP: 49000/50000

MobActor | Preparado
| HP: 49000/50000
```

Luego:

```text
48000/50000
47500/50000
```

Esto confirma que no existe un HP visual paralelo al runtime autoritativo.

### Trust boundary validado

Cliente envía:

```text
request_id
target.kind = entity
target.entity_id
```

Game Server decide:

```text
Equipment real
attack mode
range
cooldown
damage
HP resultante
alive
replicación
```

No aceptar en el futuro `damage`, `range` o `weapon` enviados por cliente como datos confiables.

### Regresiones / estabilidad

Durante las pruebas continuaron operativos:

```text
login
world bootstrap
Inventory
Equipment
movement
mob targeting
Basic Attack intent
mob replication
```

No se observaron:

```text
Parser Errors
warnings nuevos
runtime errors inesperados
```

La desconexión final fue posterior a detener manualmente el proceso de debugging.

### Checkpoints remotos

Cliente:

```text
c6b7dc03b163094dabb19ab6c05378dfe6985148
feat: apply authoritative mob combat updates
```

Game Server:

```text
5be09fadc6d0f58af7a1797c7c5d0224a063c91d
feat: execute authoritative basic attack damage
```

### Límite de F17-E

F17-E implementa damage real de Basic Attack, pero todavía NO formaliza:

```text
transición de muerte del mob
death event
representación visual dead
desactivar picking/collider al morir
respawn
auto-chase
orientación automática
animaciones
hit reaction
damage numbers
defensa
critical/block/miss
stats STR/DEX/etc.
aggro
IA
retaliación
drops
EXP
```

**Siguiente checkpoint:** `F17-F — Authoritative Mob Death Transition`.


## F17-F — AUTHORITATIVE MOB DEATH TRANSITION

**Estado:** ✅ COMPLETADO, PROBADO Y VALIDADO.

F17-F formaliza la transición de vida a muerte de una entidad mob sin introducir todavía drops, EXP ni respawn.

Flujo cerrado:

```text
mob HP > 0
→ damage autoritativo
→ HP llega a 0
→ transición alive → dead
→ evento interno mob_died
→ snapshot HP=0 / alive=false
→ mob_state_updated
→ clientes del mapa
→ MobActor representa muerte
→ targetability/picking desactivado
```

### Fuente única de la transición de muerte

La transición de muerte se centraliza en:

```text
WorldMobRegistry.apply_damage_to_mob()
```

El Registry:

```text
resuelve entity_id
valida amount
valida mob existente
valida mob vivo
aplica damage mediante WorldMobRuntimeState
detecta was_alive && !is_alive()
emite mob_died exactamente al ocurrir la transición
```

Esto evita duplicar lógica de muerte en:

```text
BasicAttackCoordinator
futuro Fire Ball
futuro Poison
otras fuentes de damage
```

El objetivo es que cualquier fuente futura de damage pueda converger en el mismo lifecycle autoritativo.

### Evento autoritativo interno

`WorldMobRegistry` expone:

```text
mob_died(
	entity_id,
	map_id,
	source,
	mob_snapshot
)
```

El `source` conserva metadata suficiente para futuras capas.

En el test real:

```text
kind = player_basic_attack
```

y también se preservan datos del atacante/request/attack profile relevantes.

Este signal es el hook previsto para que F18 pueda reaccionar a una muerte sin acoplar Drop/EXP directamente al BasicAttackCoordinator.

### Kill real validado

Golpe letal:

```text
WorldMobRegistry | Muerte autoritativa confirmada
| Entity: mob_test_town_001
| Type: training_goblin
| Mapa: test_town
| Source: player_basic_attack
| HP: 0/50000
```

Después, el mismo ataque concluyó:

```text
BasicAttackCoordinator | Resultado enviado
| Request: 66
| Accepted: true
| Reason: ok
| Mode: melee
```

El estado final fue replicado:

```text
BasicAttackCoordinator | Estado de mob replicado
| Entity: mob_test_town_001
| Recipients: 1
| HP: 0/50000
```

y el log de ejecución confirmó:

```text
Damage: 1000
HP restante: 0/50000
Killed: true
```

### Exactly-once durante una vida

Durante la prueba existió una sola transición:

```text
WorldMobRegistry | Muerte autoritativa confirmada
```

para `mob_test_town_001`.

Una vez que el mob queda con:

```text
HP = 0
alive = false
```

`WorldMobRuntimeState.is_alive()` impide que el mismo lifecycle vuelva a transicionar a dead.

No confundir esto con persistencia durable exactly-once entre reinicios del proceso; todavía estamos hablando del runtime de una vida concreta del mob.

### Snapshot dead

El snapshot autoritativo derivado queda coherente:

```text
hp = 0
alive = false
```

La presencia cliente ya valida la relación:

```text
alive == (hp > 0)
```

por lo que un snapshot inconsistente no debe aceptarse como representación válida.

### Representación cliente del cadáver

`MobActor` continúa representando el snapshot autoritativo.

Cuando recibe:

```text
HP: 0/50000
alive: false
```

actualiza temporalmente:

```text
NameLabel → [DEAD]
VitalsLabel → 0 / 50000 HP
VisualRoot → placeholder acostado
TargetArea / CollisionShape3D → deshabilitados para targeting
```

La cápsula acostada es únicamente una representación placeholder.

Una futura animación de muerte reemplazará esta presentación sin cambiar el contrato gameplay.

### Targetability después de morir

`MobActor.is_targetable()` exige:

```text
alive
hp > 0
entity_id válido
```

Luego de la muerte el collider/picking de target queda deshabilitado.

Test real con LEFT CLICK sobre el cadáver:

```text
NO:
GameplayScreen | Basic Attack solicitado

NO:
GameServerClient | Intención de Basic Attack enviada
```

El click terminó resolviéndose como terreno y produjo:

```text
move_request
→ movimiento hacia la zona del cadáver
```

Eso es correcto.

### Skills contra cadáver

Con Fire Ball seleccionado y RIGHT CLICK sobre el cadáver:

```text
GameplayScreen | Cast omitido
| Skill: fire_ball
| Reason: entity_target_required
```

El cadáver deja de resolverse como entity target en el cliente.

### Defensa server-side adicional

`BasicAttackCoordinator` conserva la validación:

```text
if not mob.is_alive()
→ target_not_alive
```

Por lo tanto, aunque un cliente modificado fabricara manualmente un request estructuralmente válido contra un entity_id muerto, el Game Server no debería aplicar damage.

Esa rama no fue disparada desde el cliente normal en F17-F porque el picking deja correctamente de producir el intent. Debe cubrirse más adelante con tests específicos de protocolo/servidor, no reactivando targetability del cadáver sólo para probarla.

### No se introdujo un mensaje de red de muerte separado

No existe:

```text
mob_death_message
```

porque no es necesario.

Se reutiliza:

```text
mob_state_updated
```

con:

```text
HP = 0
alive = false
```

La muerte es un cambio de estado autoritativo de la entidad, mientras `mob_died` queda como evento interno de dominio para sistemas server-side futuros.

### Checkpoints remotos

Cliente:

```text
a339b1cb6b3de4eb6fb549e6ee6644aa5a7e6af5
feat: represent authoritative mob death state
```

Game Server:

```text
8373b0583f988e6703a0e5bc8264ddb651161688
feat: emit authoritative mob death transitions
```

### Límite de F17-F

F17-F NO implementa:

```text
drops
EXP
pickup
loot tables
respawn
spawn timers
aggro
IA
retaliación
animación final
damage numbers
auto-chase
```

La muerte autoritativa ya posee el hook que esos sistemas podrán consumir.

### Ajuste posterior del fixture de pruebas

Después del cierre de F17-F se redujo el HP temporal del `Training Goblin`:

```text
50000 → 5000 HP
```

Motivo:

```text
bronze_sword = 1000 damage
→ 5 golpes para matar

unarmed = 500 damage
→ 10 golpes para matar
```

Esto acelera pruebas repetitivas de death/respawn/drop/EXP sin representar balance definitivo.

Checkpoint Game Server:

```text
c5f30da621ca2dc4080496c79884f81cb6a9b8db
chore: reduce training goblin test hp
```

**Siguiente paso:** decision gate de roadmap para decidir entre:

```text
F17-G — Authoritative Mob Respawn Foundation
```

o abrir directamente:

```text
F18 — Drop / Pickup / EXP
```

La decisión debe priorizar un vertical slice repetible y evitar scope creep.

---

# 43. PvP — DIRECCIÓN CANÓNICA

PvP / PK no debe implementarse como excepción improvisada.

Debe construirse sobre el combat runtime autoritativo existente.

## Input canónico

```text
CTRL + LEFT CLICK sobre player
→ ataque básico PvP

CTRL + RIGHT CLICK sobre player
→ selected skill PvP
```

El Game Server deberá decidir:

```text
si el target es jugador
si el mapa permite PvP
safe zone
estado PvP del atacante
estado PvP del objetivo
auto-defense vigente
distancia
line-of-sight
equipment
skill
mana
cooldown
damage
kill
criminal / sin state
```

El cliente nunca decide si una muerte penaliza o no.

## Estados canónicos de pecado / criminalidad

La dirección histórica de VHAL queda confirmada como:

```text
Inocente
↓
Diablillo
↓
Delincuente
↓
Pecador / Sinner
```

Los umbrales exactos de kills/puntos de pecado todavía NO están balanceados.

La progresión entre estados deberá depender de una métrica server-side durable, por ejemplo:

```text
player kills penalizables
sin points / criminal points
estado criminal resultante
```

El nombre técnico final de esa métrica se decidirá al implementar el sistema.

## Auto-defense / legítima defensa

Regla canónica:

```text
Player A ataca primero a Player B
↓
Game Server registra agresión válida
↓
Player B queda autorizado temporalmente a defenderse
↓
B puede atacar/matar a A sin recibir penalización PK por esa defensa
```

Esto debe parecerse conceptualmente al comportamiento clásico de MU, pero implementado con reglas y arquitectura propias de VHAL.

La autorización de defensa:

```text
es temporal
es server-side
debe identificar atacante/defensor
debe expirar
no puede depender de lógica local del cliente
```

Casos futuros a definir:

```text
duración de auto-defense
qué pasa si interviene un tercero
party/guild
duelos
event maps
safe zones
self-defense contra múltiples agresores
```

## Pecador / Sinner — estado máximo

Al alcanzar `Pecador`:

```text
otros jugadores pueden atacarlo sin ser penalizados
```

Presentación visual deseada:

```text
cuerpo
armadura
arma
alas
otros componentes visuales principales
```

deben adquirir una tonalidad roja visible.

El color es representación cliente del estado autoritativo; el cliente NO decide que alguien es Pecador.

Conceptualmente:

```text
Game Server criminal state
↓
presence/combat replication
↓
appearance state
↓
tint rojo del personaje completo
```

## Sacerdote / Confesión — lore y mecánica

VHAL tendrá uno o más NPCs de tipo:

```text
Sacerdote / Priest
```

Su función de lore y gameplay será:

> confesar al personaje y limpiar sus pecados.

Flujo conceptual:

```text
jugador con pecado
→ habla con Sacerdote
→ Game Server calcula deuda/penalización
→ se informa costo
→ jugador acepta
→ se cobra moneda
→ se reduce o limpia el estado de pecado
→ estado durable actualizado
```

El costo deberá escalar según la gravedad de los pecados cometidos, por ejemplo en función de:

```text
kills penalizables
sin points
estado criminal
```

La fórmula exacta queda para balance posterior.

## Redención mediante PvE

Debe existir también una vía gratuita y más lenta:

```text
matar mobs válidos
→ reducir progresivamente pecado
```

Objetivo:

```text
pagar al Sacerdote
→ limpieza rápida / costosa

jugar PvE
→ limpieza lenta / gratuita
```

No todos los mobs necesariamente deberán valer lo mismo.

La reducción futura podrá considerar:

```text
nivel del mob
nivel del jugador
zona
anti-exploit
diminishing returns
```

sin definir todavía la fórmula.

## Persistencia futura PvP

El Backend deberá conservar únicamente el estado durable necesario.

Ejemplo conceptual, NO esquema definitivo:

```text
criminal_state
sin_points
penalizable_player_kills
```

`auto-defense` es principalmente runtime del Game Server y no debe persistirse como si fuera una condena durable.

## Regla arquitectónica

```text
Combat determina hit/damage/kill
↓
PvP/PK Domain determina agresión, defensa y penalización
↓
Persistence guarda estado criminal durable
↓
Presence replica estado necesario
↓
Client representa color/feedback
```

No mezclar todo dentro de `BasicAttackCoordinator`.

No implementar PvP completo hasta abrir formalmente su checkpoint.

---

# 44. F18 — DROP + PICKUP + EXP + LEVEL

Objetivo global:

```text
mob muere
→ server calcula drop
→ WorldDrop autoritativo
→ cliente lo representa
→ pickup intent
→ server valida
→ Inventory
→ EXP / Level
```

F18 se divide en checkpoints pequeños:

```text
F18-A1 — Authoritative World Drop Runtime      ✅
F18-A2 — World Drop Replication & Visual       ✅
F18-B1 — Durable Inventory Grant Foundation   ✅
F18-B2 — Authoritative Pickup Flow             ✅
F18-C1 — Durable Character Progression         ✅
F18-C2A — Authoritative EXP Runtime            ✅
F18-C2B — Progression Replication + HUD        ✅
```

## F18-A1 — AUTHORITATIVE WORLD DROP RUNTIME

**Estado:** ✅ COMPLETADO, PROBADO Y VALIDADO.

F18-A1 crea la entidad runtime de un item tirado en el mundo y conecta el lifecycle de muerte del mob con loot autoritativo.

Arquitectura validada:

```text
BasicAttackCoordinator
		↓
	  damage
		↓
WorldMobRegistry
		↓
	 mob_died
	  ┌─┴──────────────────┐
	  ↓                    ↓
WorldDropCoordinator       Respawn scheduler
	  ↓
ServerMobDropCatalog
	  ↓
WorldDropRegistry
	  ↓
WorldDropRuntimeState
```

Regla fundamental:

```text
BasicAttackCoordinator NO conoce loot.
```

Por lo tanto cualquier futura fuente de muerte que termine en:

```text
WorldMobRegistry
→ mob_died
```

puede reutilizar el mismo sistema de drops.

### WorldDropRuntimeState

Responsabilidad:

```text
representar un item concreto actualmente tirado en el mundo
```

Campos actuales:

```text
entity_id
persistent_item_uid
item_id
quantity
map_id
position
```

Snapshot:

```text
entity_kind = world_drop

item:
  item_id
  quantity

world:
  map_id
  position
```

Importante:

```text
WorldDropRuntimeState
≠
ItemInstance persistente de Inventory
```

La conversión:

```text
World Drop
→ Inventory Item
```

pertenece a F18-B.

### WorldDropRegistry

Mantiene:

```text
drops_by_entity_id
next_drop_sequence
```

IDs runtime actuales:

```text
world_drop_00000001
world_drop_00000002
...
```

Estos IDs son válidos durante la vida del Game Server.

No se exige que sobrevivan a un restart porque los drops de suelo todavía no son persistencia durable.

Responsabilidades actuales:

```text
spawn_drop()
register
get_drop()
get_drops_in_map()
consume_drop()
emit world_drop_spawned
emit world_drop_removed
```

### ServerMobDropCatalog

Foundation inicial:

```text
training_goblin
→ health_potion x1
→ chance 100%
```

El 100% es deliberado para testing.

El contrato valida:

```text
mob_type_id
item_id existente en ServerItemCatalog
chance 0..1
quantity_min
quantity_max
max_stack
```

Dirección futura:

```text
Goblin
├── potion 30%
├── zen 60%
├── sword 0.5%
└── nada
```

sin introducir condicionales especiales en Combat.

### WorldDropCoordinator

Escucha:

```text
WorldMobRegistry.mob_died
```

y:

```text
lee mob_type_id
lee posición autoritativa de muerte
roll_drops()
crea WorldDropRuntimeState mediante WorldDropRegistry
```

También conserva información del source del kill para futuras reglas:

```text
character_id
peer_id
request_id
attack_mode
weapon_item_id
```

sin convertir ownership/party loot en requisito de F18-A.

### Test F18-A1

Primera muerte:

```text
WorldMobRegistry | Muerte autoritativa confirmada
| Entity: mob_test_town_001
| HP: 0/5000

WorldDropRegistry | Drop creado
| Entity: world_drop_00000001
| Item: health_potion
| Quantity: 1
| Mapa: test_town
| Posición: (4.0, 0.0, 4.0)

WorldDropCoordinator | Muerte procesada
| Mob: mob_test_town_001
| Type: training_goblin
| Killer Character: 1
| Drops: 1
```

Segunda muerte después del respawn:

```text
WorldDropRegistry | Drop creado
| Entity: world_drop_00000002
| Item: health_potion
| Quantity: 1
```

Se validó:

```text
dos muertes
→ dos entidades WorldDrop distintas
→ ambas pueden coexistir en WorldDropRegistry
```

El respawn continuó funcionando sin regresión.

### Checkpoint F18-A1

Game Server:

```text
505324ec3f5c2a1b8a231c6787e17464e33b050d
feat: add authoritative world drop runtime foundation
```

Cliente:

```text
sin cambios requeridos en F18-A1
```

---

## F18-A2 — WORLD DROP REPLICATION & VISUAL FOUNDATION

**Estado:** ✅ COMPLETADO, PROBADO Y VALIDADO.

F18-A2 convierte al WorldDrop autoritativo en estado replicado del mundo.

Flujo:

```text
WorldDropRegistry
→ world_drop_spawned
→ WorldPresenceCoordinator
→ GameServer.send_world_drop_spawned
→ GameServerPresenceProtocol
→ GameServerClient
→ GameSessionFlowCoordinator
→ GameplayScreen
→ WorldDropActor
```

### Networking en tiempo real

Mensaje server → client:

```text
world_drop_spawned
```

Payload principal:

```text
drop:
  entity_id
  entity_kind = world_drop
  item:
	item_id
	quantity
  world:
	map_id
	position
```

El transporte es reliable.

No existe todavía:

```text
world_drop_pickup_request
```

porque eso pertenece a F18-B.

### Roster inicial

`world_presence_snapshot` evolucionó de:

```text
players
mobs
```

a:

```text
players
mobs
drops
```

Esto es una decisión crítica.

Un jugador que entra después de la muerte del mob debe observar el mismo estado autoritativo:

```text
drop ya existía
→ jugador entra
→ get_drops_in_map(map_id)
→ world_presence_snapshot
→ WorldDropActor
```

No depender de haber presenciado el evento `world_drop_spawned`.

### GameServerPresenceProtocol

Mantiene:

```text
remote_players
remote_mobs
remote_drops
```

Valida snapshots de drop:

```text
entity_id no vacío
entity_kind == world_drop
item_id no vacío
quantity > 0
map_id no vacío
position válida
```

Procesa:

```text
world_presence_snapshot
world_drop_spawned
```

### WorldDropActor

Cliente:

```text
features/world/drops/world_drop_actor.gd
features/world/drops/world_drop_actor.tscn
```

Responsabilidad:

```text
representar visualmente un WorldDrop autoritativo
```

No decide:

```text
si el item existe
si puede recogerse
quién es dueño
qué entra al Inventory
```

Utiliza:

```text
ItemCatalog.get_definition(item_id)
```

para resolver presentación local:

```text
display_name
icon
```

Por lo tanto el Game Server no necesita enviar recursos visuales ni nombres confiables.

Estructura Foundation:

```text
WorldDropActor
└── VisualRoot
	├── ItemSprite
	└── NameLabel
```

Sin `Area3D`/collider todavía.

### Separación del árbol de Gameplay

`GameplayScreen` posee ahora conceptualmente:

```text
WorldRoot
├── MapRoot
├── ActorsRoot
└── DropsRoot
```

Players/mobs permanecen en `ActorsRoot`.

Items de suelo viven en `DropsRoot`.

`GameplayScreen` mantiene:

```text
world_drop_actors[entity_id]
```

y soporta:

```text
sync_world_drops()
apply_world_drop_spawned()
_spawn_or_update_world_drop()
_clear_world_drops()
```

### Test en tiempo real validado

Ingreso inicial:

```text
WorldPresenceCoordinator | Presencia de mundo preparada
| Mobs: 1
| Drops: 0
```

Cliente:

```text
GameServerClient | Roster de mundo recibido
| Remotos: 0
| Mobs: 1
| Drops: 0

GameplayScreen | Drops sincronizados
| Cantidad: 0
```

Después del kill:

```text
WorldDropRegistry | Drop creado
| Entity: world_drop_00000001
| Item: health_potion
| Quantity: 1

WorldPresenceCoordinator | Drop de mundo replicado
| Entity: world_drop_00000001
| Mapa: test_town
| Recipients: 1
```

Cliente:

```text
GameServerClient | World Drop recibido
| Entity: world_drop_00000001
| Item: health_potion
| Quantity: 1

WorldDropActor | Preparado
| Entity: world_drop_00000001
| Item: health_potion
| Quantity: 1
| Posición: (4.0, 0.0, 4.0)
```

Visualmente se confirmó:

```text
Health Potion x1
```

en el mundo.

### Test de reconexión validado

Condición:

```text
drop existente
Game Server sigue encendido
cliente se desconecta
cliente vuelve a entrar
```

Server:

```text
WorldPresenceCoordinator | Presencia de mundo preparada
| Mobs: 1
| Drops: 1
```

Cliente:

```text
GameServerClient | Roster de mundo recibido
| Remotos: 0
| Mobs: 1
| Drops: 1

WorldDropActor | Preparado
| Entity: world_drop_00000001
| Item: health_potion
| Quantity: 1

GameplayScreen | Drops sincronizados
| Cantidad: 1
```

Esto confirma:

> **WorldDrop es estado runtime autoritativo del mundo y no un efecto visual temporal del kill.**

### Observaciones Foundation no bloqueantes

Actualmente el Training Goblin respawnea exactamente en su spawn y el drop se crea exactamente en la posición de muerte.

En el fixture:

```text
mob spawn = (4,0,4)
drop = (4,0,4)
```

por lo que el mob respawneado puede superponerse visualmente con el texto/icono del drop.

Más adelante puede evolucionar a:

```text
drop scatter
posición offset
varios drops distribuidos alrededor del cadáver
```

pero no bloquear F18-A por presentación temporal.

También se observó que el evento de drop puede llegar visualmente antes que el resultado final del Basic Attack, debido al orden interno:

```text
apply damage
→ mob_died
→ drop
→ retorno de attack result
```

No viola autoridad.

Cuando exista presentación final de muerte/drop se podrá coordinar el timing visual sin mover reglas de loot a Combat.

### Checkpoints F18-A2

Game Server:

```text
c249c737ae4768c56bfc5742f072cd2d338c45bf
feat: replicate authoritative world drops
```

Cliente:

```text
a043ac76478256f36f6a17002629c9c3733c7f46
feat: render authoritative world drops
```

### Resultado total F18-A

```text
✅ loot decidido por Game Server
✅ drop table server-side
✅ WorldDropRuntimeState
✅ WorldDropRegistry
✅ WorldDropCoordinator desacoplado de BasicAttackCoordinator
✅ IDs runtime propios
✅ map_id autoritativo
✅ posición autoritativa
✅ múltiples drops coexistentes
✅ replicación en tiempo real
✅ roster inicial incluye drops existentes
✅ reconexión conserva representación del drop
✅ WorldDropActor visual
✅ icono/nombre resueltos localmente mediante ItemCatalog
✅ respawn del mob sin regresión

❌ pickup
❌ Inventory mutation por pickup
❌ eliminación/despawn del drop
❌ ownership/party loot
❌ lifetime del drop
✅ EXP/Level
```

**Siguiente checkpoint:** `F18-B — Authoritative Pickup`.

La regla será:

```text
cliente pide recoger entity_id
→ Game Server resuelve WorldDrop real
→ valida mapa/rango/estado
→ persiste/muta Inventory de forma autoritativa
→ sólo después consume el WorldDrop
→ replica Inventory + desaparición del drop
```

No diseñar pickup como eliminación cliente-side.

Progression posterior:

```text
F18-C
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

---

## F18-B1 — DURABLE INVENTORY GRANT FOUNDATION

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

Antes de permitir pickup real se detectó una necesidad arquitectónica:

```text
Laravel podía:
GET Inventory
PATCH movimiento de item existente

pero todavía NO podía:
crear de forma durable un ItemInstance nuevo por drop
```

No se implementó un atajo en memoria.

Se agregó un grant persistente e idempotente.

Flujo:

```text
Game Server
→ POST Inventory item grant
→ Laravel transaction
→ ItemInstance
→ MySQL
```

Endpoint:

```text
POST /api/internal/accounts/{accountId}/characters/{characterId}/inventory/items
```

Contrato:

```text
uid UUID
item_id
quantity
grid_position
```

### Idempotencia

El Game Server envía un UID durable ya decidido.

Laravel:

```text
UID no existe
→ crea item
→ 201

UID ya existe
+
payload coincide exactamente
→ devuelve mismo item
→ idempotent = true
→ 200

UID ya existe
+
payload distinto
→ 409
```

La DB mantiene:

```text
UNIQUE(item_instances.uid)
```

como defensa final.

### Test validado

```text
InternalCharacterInventoryPickupTest
4 passed
20 assertions
```

Checkpoint Backend:

```text
d54dead554ec8e22f770fd9c429164da83dde922
feat: add idempotent inventory item grants
```

---

## F18-B2 — AUTHORITATIVE WORLD DROP PICKUP

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

F18-B2 cerró el primer pickup real del proyecto.

Flujo completo:

```text
LEFT CLICK WorldDrop
↓
PlayerInputController
↓
GameplayScreen
↓
GameSessionFlowCoordinator
↓
GameServerItemProtocol
↓
world_drop_pickup_request
↓
Game Server
↓
WorldDropPickupCoordinator
↓
PlayerWorldSession
↓
WorldDropRegistry
↓
same-map validation
↓
range validation
↓
Inventory placement resolver
↓
lock WorldDrop
↓
BackendCharacterInventoryRepository
↓
Laravel idempotent grant
↓
persistencia confirmada
↓
WorldDropRegistry.consume_drop()
↓
world_drop_removed
↓
clientes del mapa
↓
Inventory reload
↓
character_inventory_snapshot
↓
PlayerRuntimeState / UI
```

### Input cliente

`WorldDropActor` incorporó:

```text
PickupArea
└── CollisionShape3D
```

El drop vive en una collision layer separada para poder detectarlo incluso si el mob respawneado se superpone visualmente.

Prioridad contextual actual de LEFT CLICK:

```text
WorldDrop hostil/no hostil → PICKUP
NPC interactuable         → INTERACT
Mob hostil                → BASIC ATTACK PvE
Terreno                   → MOVE
```

El cliente sólo envía:

```text
request_id
entity_id
```

No envía:

```text
item_id confiable
quantity confiable
posición Inventory confiable
UID persistente
range
resultado
```

### Persistent item UID

Cada `WorldDropRuntimeState` genera al nacer:

```text
persistent_item_uid = UUID v4
```

Ejemplo real validado:

```text
82448968-8c0a-4d8c-a299-91be8dbc12c1
```

Este UID:

```text
NO es el runtime entity_id
NO se deriva de world_drop_00000001
NO se envía al cliente
```

Se usa después como UID exacto del `ItemInstance` durable.

### Inventory placement

`ServerInventoryPlacementResolver` prueba posiciones sobre el snapshot autoritativo del Inventory.

No reimplementa reglas de overlap/multicelda.

Usa:

```text
ServerCharacterInventorySnapshotValidator
```

como contrato canónico.

Foundation actual:

```text
buscar primer espacio válido de la grilla 8x8
```

No existe todavía stack merge automático.

Por eso:

```text
Potion x1 existente
+
Drop Potion x1
→ pueden quedar dos stacks Potion x1
```

hasta que una necesidad real justifique reabrir el scope mínimo de F15-C.

### Lock / anti-race

Mientras Laravel procesa un pickup:

```text
locked_drop_entities[entity_id]
pending_by_uid[persistent_item_uid]
```

evitan que el mismo WorldDrop sea recogido paralelamente.

Además `GameServerItemProtocol` mantiene una mutación de item pendiente.

Durante el test, clicks adicionales devolvieron:

```text
ERR_BUSY
```

y no generaron requests simultáneos.

### Orden transaccional

Regla crítica validada:

```text
1. persistir ItemInstance
2. recibir confirmación Laravel
3. recién entonces consume_drop()
```

Nunca:

```text
consume drop
→ después intentar persistir
```

Esto evita perder un item si Laravel falla.

### world_drop_removed

Al consumir correctamente:

```text
WorldDropRegistry
→ world_drop_removed
→ WorldPresenceCoordinator
→ todos los peers del mismo mapa
→ GameServerPresenceProtocol
→ remote_drops.erase(entity_id)
→ GameplayScreen
→ WorldDropActor.queue_free()
```

El drop no desaparece cliente-side por optimismo.

Desaparece sólo por orden autoritativa.

### Pickup result

Mensajes:

```text
world_drop_pickup_request
world_drop_pickup_result
world_drop_removed
```

Reasons foundation:

```text
ok
stale_request
drop_not_found
drop_busy
wrong_map
out_of_range
inventory_unavailable
inventory_full
inventory_busy
persistence_unavailable
persistence_rejected
```

### Test fuera de rango

Se probó:

```text
Player distance: 3.669...
PICKUP_RANGE: 2.0
```

Resultado:

```text
Accepted: false
Reason: out_of_range
```

El WorldDrop permaneció intacto.

### Test pickup válido

Después de acercarse:

```text
WorldDropPickupCoordinator | Pickup persistente iniciado
| Entity: world_drop_00000001
| Item: health_potion
| Posición Inventory: (0, 0)
```

Luego:

```text
WorldDropRegistry | Drop consumido
WorldPresenceCoordinator | Drop removido replicado
WorldDropPickupCoordinator | Pickup confirmado
```

Laravel confirmó:

```text
Idempotent: false
```

y el Inventory pasó:

```text
Items: 1
→
Items: 2
```

El cliente:

```text
GameServerClient | World Drop removido
GameplayScreen | World Drop eliminado
GameServerClient | Resultado autoritativo de Pickup
| Accepted: true
| Reason: ok
GameServerClient | Snapshot de Inventory recibido
| Items: 2
PlayerRuntimeState | Inventory persistente reconstruido
GameplayScreen | Inventory persistente actualizado
```

### Test de reconexión

Después de recoger la poción:

```text
cliente cerrado
Game Server continúa
cliente vuelve a entrar
```

Se confirmó:

```text
drop recogido NO reaparece
ItemInstance sigue en Inventory
```

Por lo tanto:

```text
World state transitorio
+
durable Inventory
```

se reconcilian correctamente.

### Loop real logrado

F18-B completa por primera vez:

```text
Mob
→ Damage
→ Death
→ Drop
→ Pickup
→ Laravel
→ MySQL ItemInstance
→ Inventory
```

### Checkpoints F18-B

Backend B1:

```text
d54dead554ec8e22f770fd9c429164da83dde922
feat: add idempotent inventory item grants
```

Game Server B2:

```text
60ab01625dc9f0014cdeefb1387640712a68f80a
feat: add authoritative world drop pickup
```

Cliente B2:

```text
89dae7d9a5b25f0d668e671bd838740d66290726
feat: add authoritative world drop pickup flow
```

### Resultado total F18-B

```text
✅ click/intención de pickup
✅ request_id monotónico
✅ drop lookup autoritativo
✅ same-map validation
✅ range autoritativo
✅ inventory placement server-side
✅ UUID durable del item
✅ backend grant idempotente
✅ protection contra UID conflict
✅ lock del WorldDrop mientras persiste
✅ cliente bloquea mutaciones concurrentes
✅ WorldDrop se consume sólo tras persistencia
✅ world_drop_removed same-map
✅ actor desaparece autoritativamente
✅ Inventory reload desde Laravel
✅ persistencia confirmada tras reconnect
✅ drop recogido no reaparece
✅ muerte/drop/respawn sin regresiones

❌ stack merge automático
❌ auto-loot
❌ ownership/party loot
❌ lifetime/despawn
❌ EXP/Level
```

**Siguiente checkpoint:** `F19 — Vertical Slice completo`.

---

## F18-C1 — DURABLE CHARACTER PROGRESSION

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

Se agregó persistencia durable de:

```text
characters.level
characters.experience
```

La experiencia almacenada representa:

```text
EXP dentro del nivel actual
```

La curva NO vive en Laravel.

Endpoint:

```text
PATCH
/api/internal/accounts/{accountId}/characters/{characterId}/progression
```

Contrato:

```text
expected:
  level
  experience

next:
  level
  experience
```

Garantías:

```text
DB transaction
lockForUpdate
exact retry idempotency
stale protection
monotonic structural validation
```

Tests:

```text
InternalCharacterProgressionTest
5 passed
23 assertions
```

Casos cubiertos:

```text
persist EXP
retry idéntico
stale reject
level-up persistente
regresión reject
```

Checkpoint:

```text
fc85ce6a684d8d85ab92a8af75afbd9f1a222bfb
feat: add durable character progression persistence
```

---

## F18-C2A — AUTHORITATIVE EXP / LEVEL RUNTIME

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

Componentes principales:

```text
ServerCharacterProgressionRules
BackendCharacterProgressionRepository
CharacterProgressionCoordinator
```

`PlayerWorldSession` ahora posee:

```text
level
experience
```

y los obtiene desde el ticket durable.

### Reglas foundation de testing

Temporalmente:

```text
EXP requerida por nivel: 100
Training Goblin reward: +50 EXP
```

Esto NO es balance final.

`WorldMobDefinition` posee:

```text
experience_reward
```

El Game Server calcula level-up y overflow.

Ejemplo:

```text
Lv120 | 0/100 + 50
→ Lv120 | 50/100

Lv120 | 50/100 + 50
→ Lv121 | 0/100
```

También soporta conceptualmente rewards que crucen más de un nivel.

### Evento desacoplado

Progression escucha:

```text
WorldMobRegistry.mob_died
```

Fan-out actual:

```text
mob_died
├── WorldDropCoordinator
├── CharacterProgressionCoordinator
└── respawn scheduler
```

Por lo tanto:

```text
Combat NO calcula EXP.
Drop NO calcula EXP.
```

El killer se resuelve desde `source` autoritativo:

```text
peer_id
character_id
```

y se valida contra:

```text
PlayerWorldSession
same character
same map
```

### Persistencia

Orden:

```text
reward
→ calculate next
→ Laravel expected→next
→ confirm
→ PlayerWorldSession update
```

Nunca:

```text
actualizar runtime/client
→ después intentar persistir
```

El coordinator maneja:

```text
pending_by_peer
queued_experience_by_peer
```

para no perder rewards si entra otra muerte mientras existe una escritura pendiente.

En stale 409:

```text
Laravel current
→ runtime resync
→ reward reencolada
→ retry
```

En otro error:

```text
reward no se descarta dentro de la sesión
```

### Test real C2A

Estado inicial:

```text
Level 120
EXP 0
```

Kill 1:

```text
+50
→ 120 / 50
```

MySQL confirmado:

```text
level = 120
experience = 50
```

Kill 2:

```text
+50
→ 121 / 0
```

MySQL confirmado:

```text
level = 121
experience = 0
```

Reconnect:

```text
WorldSessionRegistry
→ Nivel: 121
→ EXP: 0/100
```

Además:

```text
0 warnings
0 errors
```

Checkpoint:

```text
05cb339418baa14695f481d742012b7b46b12820
feat: add authoritative character progression runtime
```

---

## F18-C2B — PROGRESSION REPLICATION + HUD

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

Se agregó actualización live:

```text
character_progression_updated
```

El Game Server la envía solamente después de:

```text
Laravel confirmado
→ PlayerWorldSession actualizado
```

Payload:

```text
character_id
level
experience
experience_required
experience_gained
levels_gained
```

No se reenvía un world snapshot completo por cada kill.

### Cliente

Nuevo:

```text
GameServerProgressionProtocol
```

Responsabilidad:

```text
validar update
validar character_id
mantener latest progression snapshot
emitir estado autoritativo
```

Bootstrap inicial continúa viniendo por:

```text
world_snapshot.progression
```

`GameServerWorldProtocol` valida:

```text
level > 0
experience >= 0
experience_required > 0
experience < experience_required
character.level == progression.level
```

### PlayerRuntimeState / HUD

Se reutilizó la foundation existente:

```text
PlayerRuntimeState
└── ExperienceState
	└── experience_changed
		└── GameplayUI
			└── XPBar
```

No se creó una segunda implementación de EXP.

Al aplicar Progression:

```text
CharacterSummary.level = authoritative level
ExperienceState.experience_required = authoritative required
ExperienceState.experience = authoritative experience
```

### Corrección de bootstrap encontrada durante el test

`DebugPlayerStateFactory` crea inicialmente:

```text
PlayerRuntimeState
sin CharacterSummary
```

Progression correctamente exige identidad.

El orden anterior era:

```text
apply world snapshot
→ después asignar CharacterSummary
```

y provocaba cierre de sesión.

Se corrigió a:

```text
crear PlayerRuntimeState
→ asignar CharacterSummary seleccionado
→ aplicar Progression/Vitals/World
→ entrar a Gameplay
```

### Test integrado C2B

Inicio:

```text
Level 121
EXP 0/100
XPBar 0%
```

Kill 1:

```text
Server:
121/0 → 121/50

Client:
Level 121
EXP 50/100
XPBar ~50%
levels_gained = 0
```

Kill 2:

```text
Server:
121/50 → 122/0

Client:
Level 122
EXP 0/100
XPBar 0%
levels_gained = 1
```

Reconnect:

```text
world_snapshot
→ Level 122
→ EXP 0/100
→ HUD Level 122
→ XPBar 0%
```

Durante la misma prueba:

```text
Drop 1 se recogió
Inventory 3 → 4
Drop 2 quedó en suelo
cliente reconectó
Drop 2 seguía en world roster
Inventory persistente siguió en 4
Mob respawn siguió funcionando
```

Sin regresiones observadas.

### Checkpoints C2B

Game Server:

```text
5f67cbcb7988da26007bd787013c65c2e9178eae
feat: replicate authoritative character progression
```

Cliente:

```text
d0c477ebb8a416aed6545b8b61eb7a6f5ef0766e
feat: apply authoritative progression to gameplay hud
```

### Resultado total F18-C

```text
✅ level + experience durable
✅ expected→next persistence
✅ stale protection
✅ idempotent backend retry
✅ reward server-side
✅ progression desacoplada de Combat
✅ progression desacoplada de Drops
✅ PlayerWorldSession Level/EXP
✅ level-up server-side
✅ overflow foundation
✅ pending/queue de rewards
✅ replication reliable
✅ bootstrap world_snapshot.progression
✅ GameServerProgressionProtocol
✅ CharacterSummary.level autoritativo
✅ ExperienceState reutilizado
✅ XPBar autoritativa
✅ reconnect durable
✅ 0 warnings/errors
```

Pendiente deliberadamente:

```text
❌ curva de EXP final
❌ rewards finales
❌ party EXP
❌ quest EXP
❌ PvP EXP
❌ skill points
❌ stat allocation
❌ level-up VFX/SFX final
```

**Siguiente checkpoint:** `F19 — Vertical Slice completo`.


# 45. F19 — VERTICAL SLICE COMPLETO

**Estado:** ✅ COMPLETADO, PROBADO Y VALIDADO.

F19 tuvo como objetivo demostrar que los sistemas construidos hasta F18 forman una sesión MMORPG pequeña pero coherente, repetible y conectada.

Circuito validado:

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
NPC / WAREHOUSE
↓
INVENTORY / VAULT / EQUIPMENT
↓
SKILLS
↓
MOB
↓
COMBAT
↓
DEATH
├── DROP
│   ↓
│   PICKUP
│   ↓
│   ITEMINSTANCE / MYSQL
│
└── EXP
	↓
	LEVEL
	↓
	MYSQL / HUD
↓
RESPAWN
↓
LOGOUT
↓
LOGIN
↓
RECONSTRUCCIÓN DURABLE
```

---

## F19-A — REAL GAMEPLAY BOOTSTRAP

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

El audit inicial encontró un blocker real:

```text
GameSessionFlowCoordinator
→ MockGameSessionService
→ DebugPlayerStateFactory
```

El gameplay normal todavía nacía desde valores fixture.

`DebugPlayerStateFactory` podía inyectar:

```text
HP / MP debug
EXP debug
Fire Ball
Poison
Heal
Hotbar
moneda debug
```

Aunque Vitals, EXP, Inventory y Equipment eran reemplazados después por snapshots autoritativos, Skills/Hotbar y Currency todavía dependían del fixture.

### Solución

Se incorporó:

```text
ClientGameSessionService
```

El runtime normal ahora nace como:

```text
PlayerRuntimeState.new()
```

sin valores demo.

El Game Server incorporó al `world_snapshot`:

```text
skills:
  learned_skill_ids
```

El cliente incorporó:

```text
ClientSkillCatalog
```

Su responsabilidad es solamente:

```text
skill_id autoritativo
→ SkillDefinition local
→ nombre/icono/target visual
```

No decide ownership.

`PlayerRuntimeState.apply_skill_snapshot()`:

```text
recibe IDs autorizados
→ reconstruye SkillBook
→ configura Hotbar foundation
```

### Regla actual

El Game Server todavía asigna temporalmente las tres skills foundation:

```text
fire_ball
heal
poison
```

mediante `ServerCharacterRuntimeBootstrap`.

Eso sigue siendo temporal, pero la diferencia crítica es:

```text
ANTES
cliente inventaba ownership desde debug fixture

AHORA
Game Server informa ownership runtime
cliente solamente lo representa
```

### Heal después de quitar bootstrap debug

Validado:

```text
Heal
→ intent
→ Game Server accepted
→ MP 350 → 310
→ cooldown 4.0 s
→ resultado reliable
→ Vitals autoritativos
→ HUD actualizado
```

Sin depender del fixture.

### Checkpoints F19-A

Game Server:

```text
c8a4a75f9acc656b5610d636e341615cf88327c9
feat: expose authoritative learned skills
```

Cliente:

```text
2d463f6e3687df781f0e39311e14c1515715e839
feat: remove debug gameplay bootstrap
```

`MockGameSessionService` y `DebugPlayerStateFactory` pueden seguir existiendo para pruebas aisladas, pero:

```text
flujo normal de gameplay
→ NO depende de ellos
```

---

## F19-B — INTEGRATED VERTICAL-SLICE AUDIT

**Estado:** ✅ COMPLETADO Y VALIDADO.

F19-B no agregó features.

Se ejecutó una sesión completa para detectar gaps entre sistemas.

### Inventory

Validado:

```text
movimiento interno
→ persistencia
→ reload
→ snapshot
→ PlayerRuntimeState
→ UI
```

### Equipment

Validado:

```text
Bronze Sword equipada
→ Unequip
→ Equipment 1 → 0
→ Inventory 4 → 5
→ persistencia

→ Equip
→ Inventory 5 → 4
→ Equipment 0 → 1
→ persistencia
```

### Warehouse / Vault

Validado:

```text
Warehouse Keeper
→ interacción dentro de rango
→ autorización Game Server
→ Vault persistente
→ movimiento interno Vault
→ Inventory → Vault
→ Vault → Inventory
→ snapshots sincronizados
```

### Skill

Heal validado dentro del slice:

```text
selected skill
→ intent
→ Game Server
→ mana
→ cooldown
→ result
→ HUD
```

### Combat / Death

Con Bronze Sword:

```text
mode = melee
damage = 1000 foundation
Training Goblin
5000 → 0
```

Una sola transición de muerte:

```text
mob_died
```

### Death fan-out

Una sola muerte produjo exactamente:

```text
mob_died
├── WorldDrop x1
└── EXP +50
```

Sin duplicación observada.

### EXP / Level

Baseline del audit:

```text
Level 122
EXP 50/100
```

Después de un kill:

```text
+50
→ Level 123
→ EXP 0/100
```

Persistido y replicado.

### Pickup

Drop:

```text
Health Potion x1
```

Flujo validado:

```text
pickup intent
→ Game Server validation
→ Laravel durable grant
→ WorldDrop consume
→ world_drop_removed
→ Inventory reload
→ Items 4 → 5
```

### Respawn

Después de:

```text
3.0 s
```

Training Goblin:

```text
5000/5000
```

y vuelve a ser interactuable.

### Segundo kill + reconnect sin pickup

Se mató nuevamente al Goblin.

Resultado:

```text
Level 123
EXP 50/100
```

El segundo drop NO se recogió.

Después:

```text
logout
→ character select
→ login/world reconnect
```

se reconstruyó:

```text
Level: 123
EXP: 50/100
Inventory: 5
Equipment: 1
Skills: 3
Drops runtime: 1
```

El WorldDrop no recogido reapareció en roster:

```text
world_drop_00000002
Health Potion x1
```

Demostración:

```text
drop recogido
→ durable ItemInstance
→ NO reaparece

drop no recogido
→ runtime del Game Server
→ SÍ reaparece mientras ese Game Server sigue vivo
```

### Movimiento

Movimiento corto/largo continuó funcionando de manera autoritativa durante el audit.

### Calidad

Confirmado:

```text
Cliente:
0 warnings
0 errors

Game Server:
0 warnings
0 errors

Backend:
sin errores observados
```

### Resultado del audit

No se detectaron blockers funcionales que impidan afirmar:

> VHAL ya posee un primer vertical slice MMORPG pequeño, autoritativo y persistente en sus sistemas principales.

Quedan gaps deliberados que NO bloquean este cierre:

```text
posición durable del personaje
HP/MP durable
skills aprendidas persistentes reales
economía real
PvP/PK
world drops persistentes tras restart del Game Server
merchant completo
múltiples mapas/contenido
AI avanzada
```

Estos deben desarrollarse como checkpoints posteriores, no agregarse por inercia dentro de F19.

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

Game Server es autoridad runtime de:

```text
HP
MP
max HP
max MP
```

El cliente representa esos valores.

Consumidores:

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

## Persistencia durable futura del estado del personaje

Después de F19 queda asentado como prioridad futura guardar y restaurar el estado real del personaje entre sesiones.

Estado durable esperado:

```text
map_id
position x/y/z
rotation_y

hp
mp

level
experience
```

Situación actual:

```text
Level / EXP
→ YA son durables en Laravel/MySQL
→ YA se restauran al iniciar sesión

Position
→ todavía vuelve al spawn foundation

HP / MP
→ todavía nacen desde ServerCharacterRuntimeBootstrap
```

La futura implementación NO debe crear un segundo sistema de EXP.

Debe reutilizar:

```text
Character Progression persistence existente
```

y agregar el estado durable faltante de mundo/vitals de forma coherente.

Objetivo de reconnect:

```text
logout / disconnect seguro
→ persistir checkpoint

login / enter world
→ ticket
→ Game Server
→ restaurar mapa/posición
→ restaurar HP/MP
→ restaurar Level/EXP
→ construir sesión
```

Puntos de guardado a diseñar:

```text
logout normal
disconnect
cambio de mapa
intervalic checkpoint / autosave
eventos críticos
shutdown controlado del Game Server
```

No persistir posición en MySQL en cada frame/tick.

Debe existir batching/checkpointing razonable.

Aspectos a definir al abrir el bloque:

```text
frecuencia de autosave
qué ocurre ante crash del Game Server
posición segura de fallback
HP mínimo/máximo al restaurar
estado al morir/desconectarse
map migrations
versionado del snapshot durable
```

---

# 52. SKILL OWNERSHIP / PROGRESIÓN

Hay que distinguir:

```text
Character Progression
Skill Ownership
Skill Learning
Skill Runtime
```

## Character Progression

Desde F18-C ya existe de forma real:

```text
level
experience
```

Persistencia:

```text
Laravel / MySQL
```

Autoridad de reglas:

```text
Game Server
```

Replicación:

```text
Game Server
→ Client
→ PlayerRuntimeState
→ HUD
```

Foundation actual:

```text
100 EXP por nivel
Training Goblin +50 EXP
```

No es balance final.

## Skill Runtime actual

Desde F19-A:

```text
Game Server
→ learned_skill_ids
→ world_snapshot
→ Client SkillBook / Hotbar
```

El cliente ya no inventa las Skills desde `DebugPlayerStateFactory`.

Sin embargo, ownership real todavía NO es durable.

Temporalmente:

```text
ServerCharacterRuntimeBootstrap
→ fire_ball
→ heal
→ poison
```

para todos los personajes foundation.

## Dirección canónica — aprender una Skill

Una Skill NO se aprenderá solamente por alcanzar nivel.

La idea canónica de VHAL es:

```text
conseguir el libro / scroll de la habilidad
+
cumplir requisitos
+
hablar con un entrenador compatible
=
aprender Skill
```

### Requisito 1 — Scroll / libro

La habilidad tendrá un item de aprendizaje asociado.

Ejemplo conceptual:

```text
Scroll: Fire Ball
```

El scroll podrá obtenerse mediante contenido del mundo, principalmente:

```text
mobs
drop tables
mapas concretos
eventos/quests futuros
```

No hardcodear el origen en UI.

Debe provenir de sistemas de loot/contenido.

El comportamiento final del scroll después de aprender:

```text
consumirse / no consumirse
```

queda por definir al diseñar el sistema.

### Requisito 2 — Clase

Cada skill puede restringir:

```text
una clase
varias clases
todas las clases
```

Ejemplo conceptual:

```text
Fire Ball
→ clases mágicas permitidas
```

No asumir que toda skill pertenece a una sola clase.

### Requisito 3 — Nivel mínimo

Cada skill puede exigir:

```text
required_level
```

Validado server-side.

### Requisito 4 — Stats mínimos

Puede exigir uno o más stats.

Ejemplo conceptual:

```text
Strength
Agility
Vitality
Energy / atributo mágico futuro
```

Los nombres y sistema definitivo de stats se fijarán en su checkpoint.

Regla:

```text
cliente puede mostrar requisitos
Game Server decide si realmente se cumplen
```

### Requisito 5 — Entrenador

Incluso con scroll + requisitos cumplidos:

```text
el jugador deberá hablar con un entrenador compatible
```

para aprender la skill.

El trainer actúa como pieza de:

```text
gameplay
progresión
descubrimiento
lore
```

## NPC Trainer / Entrenador

Debe existir un servicio NPC tipo:

```text
Skill Trainer
Class Trainer
Entrenador
```

Un entrenador podrá soportar:

```text
una sola clase
o
una lista de clases
```

No obligar arquitectónicamente a crear exactamente un NPC por clase.

Ejemplos:

```text
Trainer A
→ Warrior

Trainer B
→ Mage + Summoner

Trainer C
→ varias clases avanzadas
```

según el contenido/lore futuro.

## El entrenador también guía al jugador

No será solamente un botón “Learn”.

Debe poder informar:

```text
qué skills puede aprender tu clase
qué scroll necesitás
nivel requerido
stats requeridos
si cumplís o no los requisitos
en qué mapas puede encontrarse el scroll
qué mobs pueden dropearlo
```

Ejemplo conceptual:

```text
Fire Ball

Requiere:
Mage
Level 20
Energy 80
Scroll of Fire Ball

Podés buscarlo en:
Ashen Valley

Mobs conocidos:
Dark Wizard
Fire Imp
```

Estos datos deberán provenir de definiciones/catalogs del juego, no de texto duplicado hardcodeado en cada UI/NPC.

## Flujo futuro completo

```text
Mob / contenido
↓
Drop table
↓
Skill Scroll ItemInstance
↓
Inventory
↓
Jugador visita Trainer
↓
Trainer consulta skill definition
↓
Game Server valida:
	scroll presente
	clase
	level
	stats
	trainer compatible
	skill no aprendida
↓
operación durable
↓
Backend persiste learned skill
↓
si corresponde, consumir scroll
↓
ServerSkillRuntimeState actualizado
↓
cliente recibe nuevo SkillBook
```

## Persistencia de Skills

Futuro:

```text
Backend
→ learned skills persistentes por personaje
→ bootstrap de sesión
→ ServerSkillRuntimeState
```

El Backend almacena ownership durable.

El Game Server conserva autoridad sobre:

```text
learn request
requisitos
cast availability
mana
cooldown
targeting
execution
```

El cliente nunca puede enviar:

```text
"aprendí esta skill"
```

como hecho consumado.

Sólo:

```text
"quiero aprender esta skill con este trainer/scroll"
```

## Separación obligatoria

No mezclar:

```text
Character EXP/Level
con
Skill Learning
con
Skill Cast Runtime
```

Son dominios relacionados pero diferentes.

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

Los fixtures existen para acelerar desarrollo y pruebas aisladas.

Regla:

```text
mientras un sistema no sea real
→ fixture permitido

cuando aparece autoridad real
→ retirar gradualmente el fixture del flujo normal
```

Después de F19-A:

```text
gameplay normal
→ ClientGameSessionService
→ PlayerRuntimeState vacío
→ snapshots autoritativos
```

Ya NO depende de:

```text
MockGameSessionService
DebugPlayerStateFactory
```

para entrar al mundo.

Esos archivos pueden mantenerse para:

```text
tests visuales
prototipos aislados
debug UI
fixtures controlados
```

pero no deben volver a convertirse en source of truth del gameplay normal.

Ejemplos ya retirados del flujo normal:

```text
Inventory demo
Equipment demo
Vitals demo
EXP demo
Skill ownership demo del cliente
Currency debug
```

Skills todavía tienen bootstrap temporal, pero ahora es:

```text
Game Server temporal
→ learned_skill_ids
→ cliente
```

y no una invención local.

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
presence
skills
mobs
combat
drops
pickup
EXP
```

F19 ya validó este mapa como vertical slice completo.

## Persistencia futura de ubicación

Situación actual:

```text
logout/reconnect
→ personaje vuelve al spawn foundation
```

Dirección requerida:

```text
guardar map_id
guardar posición
guardar rotation_y
restaurar esos valores al iniciar/entrar al mundo
```

No persistir por frame.

Debe usarse un sistema de checkpoint/autosave coherente con la persistencia de Vitals.

Fallbacks futuros:

```text
mapa inexistente
posición inválida
posición fuera de NavMesh
mapa deshabilitado
coordenadas corruptas
```

deben llevar al jugador a un spawn seguro y nunca impedir permanentemente el login.

No construir todavía un mapa final gigante.

El siguiente contenido de mapas deberá crecer sobre:

```text
WorldNavigationRegistry
WorldPresence
mob spots futuros
NPC definitions
drop tables
trainer locations
PvP/safe-zone rules
```

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
grant durable desde WorldDrop
first-valid-position resolver
resync completo después de pickup
```

Dirección visual:

```text
compacta
MU-like footprint
fixed window
draggable
viewport constrained
```

Pickup foundation actual NO hace merge de stacks.

Ejemplo válido actual:

```text
Potion x1
Potion x1
```

en lugar de:

```text
Potion x2
```

La decisión sigue siendo:

> No reabrir F15-C hasta que una necesidad funcional concreta justifique el mínimo requerido.

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
mob replication
mob respawn replication
WorldDrop roster
WorldDrop spawn replication
WorldDrop removal replication
```

Roster inicial:

```text
world_presence_snapshot
├── players
├── mobs
└── drops
```

La eliminación de un drop recogido también es same-map:

```text
world_drop_removed
```

Por lo tanto un segundo cliente observa que el item desaparece sin confiar en el cliente que lo recogió.

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
client world-drop item_id
client world-drop quantity
client persistent item UID
client pickup distance
client pickup success
```

El cliente solicita.

El servidor valida y decide.

Para pickup:

```text
cliente:
entity_id

Game Server:
resuelve WorldDrop
resuelve item_id
resuelve quantity
resuelve persistent_item_uid
resuelve mapa
calcula distancia
resuelve espacio Inventory
ordena persistencia
consume drop después de confirmación
```

Laravel protege además:

```text
UID unique
idempotent exact replay
409 conflict
transaction
```

---

# 65. ECONOMÍA / MONEDA — DIRECCIÓN

VHAL tendrá economía persistente, pero el nombre final de la moneda todavía está pendiente.

Regla explícita:

```text
NO usar "Zen" como nombre canónico final.
```

`Zen` fue únicamente una referencia/debug heredada de la inspiración MU y no debe convertirse en identidad de VHAL.

El modelo genérico actual:

```text
CurrencyState
```

puede mantenerse mientras se define el nombre de lore.

## Objetivo futuro

La economía deberá soportar progresivamente:

```text
saldo durable por personaje o cuenta según diseño
recompensas
drops de moneda si se decide
NPC merchants
compras
ventas
servicios pagos
trainer fees si aplica
Sacerdote / confesión
trade futuro
taxes/fees futuros
```

## Autoridad

```text
Client
→ intención de compra/pago

Game Server
→ valida contexto/reglas

Backend
→ operación durable/atómica
```

Nunca:

```text
client set_currency(999999)
```

como source of truth.

## Nombre pendiente

Antes de implementar economía real hay que definir:

```text
nombre singular
nombre plural
símbolo/icono
lore/origen
si existe una moneda principal o varias
```

El nombre debe pertenecer al universo VHAL y NO copiar `Zen`.

Hasta elegirlo, documentación/código nuevo debe preferir términos genéricos:

```text
currency
gold/currency placeholder sólo si es técnico
balance
amount
```

sin fijar todavía el nombre de interfaz.

---


# 66. ROADMAP RESUMIDO ACTUAL

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

POST-F19
Persistent player runtime       ⏳ candidato recomendado
Skill learning + Trainers       ⏳ futuro
Economy / VHAL currency         ⏳ futuro
PvP / PK / Sin system           ⏳ futuro
World/content expansion         ⏳ futuro

PERF-1                          ⏳ después de base estable
```

El orden post-F19 no queda bloqueado salvo por decisión explícita en un checkpoint posterior.

---

# 67. PRÓXIMO PASO EXACTO

Antes de abrir gameplay nuevo:

```text
cerrar documentación/checkpoint F19
→ reemplazar PROJECT_MEMORY.md
→ git status
→ commit
→ push
→ confirmar "pusheado"
```

F19 ya demostró:

> los sistemas construidos forman una pequeña sesión MMORPG coherente, autoritativa y repetible.

No existe un blocker funcional inmediato que obligue a agregar otra feature para “hacer funcionar” el vertical slice.

## Candidato recomendado siguiente

El gap foundation más natural para resolver después de F19 es:

```text
Persistent Character Runtime
```

principalmente:

```text
map_id
position
rotation_y
HP
MP
```

porque:

```text
Level/EXP ya persisten
Inventory ya persiste
Equipment ya persiste
Vault ya persiste
```

y actualmente posición + Vitals se reinician al bootstrap foundation.

Aun así:

> no abrir ese bloque hasta cerrar/pushear esta memoria y confirmar explícitamente el siguiente checkpoint.

Otros bloques ya asentados:

```text
Skill Scrolls + Trainers
Economy / moneda propia de VHAL
PvP / PK / Pecado / Sacerdote
world content
merchant
stats reales
```

No intentar implementarlos juntos.

---

# 68. CRITERIO DE ÉXITO DEL PRÓXIMO TEST

F19-B ya quedó validado.

El criterio del próximo test dependerá del checkpoint post-F19 que se elija.

Si se abre `Persistent Character Runtime`, el objetivo inicial deberá ser pequeño:

```text
1. guardar posición/mapa de un personaje;
2. guardar HP/MP;
3. salir de forma controlada;
4. volver a entrar;
5. restaurar posición/mapa;
6. restaurar HP/MP;
7. conservar Level/EXP actual;
8. conservar Inventory/Equipment/Vault;
9. no persistir cada frame;
10. 0 warnings/errors.
```

No mezclar en ese primer test:

```text
PvP
Economy
Skill Trainers
Stats completos
más mapas
AI
```

---

# 69. DECISIÓN SOBRE HEAL

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

# 70. DECISIÓN SOBRE BASIC ATTACK / FIRE BALL / POISON

Basic Attack es parte central del combate y no será reemplazado por Skills.

```text
LEFT CLICK sobre mob hostil
→ BASIC ATTACK PvE

CTRL + LEFT CLICK sobre player
→ BASIC ATTACK PvP

CTRL + RIGHT CLICK sobre player
→ SELECTED SKILL PvP
```

El Game Server resolverá el ataque según Equipment autoritativo.

F17-D ya validó:

```text
Equipment vacío
→ unarmed

bronze_sword en main_hand
→ melee
```

F17-E ya reutilizó ese mismo perfil para ejecución real.

Validado:

```text
bronze_sword
→ melee
→ range 2.0
→ cooldown 0.9 s
→ damage 1000

sin arma
→ unarmed
→ range 1.5
→ cooldown 1.0 s
→ damage 500
```

El HP del mob se muta exclusivamente en Game Server y se replica mediante `mob_state_updated`.

F17-F además centraliza la transición fatal en:

```text
WorldMobRegistry.apply_damage_to_mob()
→ mob_died
```

para que futuras fuentes de damage y F18 no dependan de BasicAttackCoordinator.

No crear un segundo modelo de arma ni implementar damage/muerte fuera del pipeline autoritativo de entidad/mob.

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

# 71. DECISIÓN SOBRE CONSUMIBLES

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

# 72. DEFINICIÓN DE “REAL” EN VHAL

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

# 73. REGLA FINAL DE CONTINUIDAD

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

La etapa funcionalmente validada actual es:

```text
F19 — Vertical Slice completo
├── F19-A Real Gameplay Bootstrap   ✅
└── F19-B Integrated Slice Audit    ✅
```

Checkpoint F19-A Game Server:

```text
c8a4a75f9acc656b5610d636e341615cf88327c9
feat: expose authoritative learned skills
```

Checkpoint F19-A Cliente:

```text
2d463f6e3687df781f0e39311e14c1515715e839
feat: remove debug gameplay bootstrap
```

Vertical slice validado:

```text
Login
→ Character Select
→ Ticket
→ Game Server
→ World
→ Movement
→ Warehouse
→ Inventory/Vault/Equipment
→ Skill
→ Mob
→ Combat
→ Death
├── Drop → Pickup → MySQL
└── EXP → Level → MySQL/HUD
→ Respawn
→ Logout
→ Reconnect
```

Estado probado al cierre:

```text
Inventory persistente
Equipment persistente
Vault persistente
Skills autoritativas runtime
Level/EXP persistentes
WorldDrop pickup durable
WorldDrop no recogido conserva runtime durante vida del GS
0 warnings/errors
```

Gaps post-F19 ya aceptados:

```text
Position/map durable
HP/MP durable
Skill ownership durable real
Skill Scroll + requirements + Trainer
Economy con moneda propia de VHAL
PvP/PK Sin system + Priest confession
WorldDrop durable tras restart GS
Merchant
Stats completos
más contenido/mapas/mobs
```

Dirección de Skill Learning:

```text
Scroll
+ clase
+ level
+ stats
+ trainer compatible
→ server validation
→ learned skill durable
```

Dirección PvP:

```text
Inocente
→ Diablillo
→ Delincuente
→ Pecador / Sinner

agresión inicial
→ auto-defense para víctima

Pecador
→ apariencia roja
→ cualquiera puede atacarlo sin penalización

Redención
├── Sacerdote + pago proporcional al pecado
└── matar mobs lentamente
```

Economía:

```text
NO usar "Zen" como nombre final.
Nombre/lore de moneda VHAL pendiente.
```

Persistencia recomendada siguiente:

```text
map_id
position
rotation_y
HP
MP
```

sin duplicar la persistencia Level/EXP ya existente.

**No abrir el siguiente checkpoint hasta commitear, pushear y confirmar esta actualización canónica de F19.**

---
