# VHAL — PROJECT MEMORY / ARQUITECTURA / ROADMAP CANÓNICO

**Última actualización:** 23/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama de desarrollo habitual:** `dev`  
**Estado general:** Foundation avanzada, F15-B cerrado, F15-R validado de punta a punta, vertical slice real en construcción.

> Este archivo es la **fuente canónica única de contexto del proyecto VHAL**.
>
> A partir de este checkpoint absorbe también las decisiones y el roadmap que antes estaban distribuidos en:
>
> - `PROJECT_MEMORY.md`
> - `VHAL_ROADMAP_ARQUITECTURA_2026-08-21.md`
> - revisiones anteriores del roadmap
>
> Los roadmaps viejos pueden conservarse como historial, pero para continuar el desarrollo se debe leer **este archivo primero**.

---

# 1. PROPÓSITO DE VHAL

VHAL es un proyecto de MMORPG desarrollado en Godot.

No se está construyendo solamente:

- una demo visual;
- un laboratorio de UI;
- una colección de escenas;
- un clon pequeño de un juego existente;
- un prototipo descartable.

La meta es construir progresivamente la base de un **MMORPG real**, con una arquitectura que pueda crecer durante años sin transformarse en un código inmanejable.

La intención es poder incorporar con el tiempo:

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

# 2. CONTEXTO DE APRENDIZAJE Y FORMA DE ACOMPAÑAR EL DESARROLLO

Este punto es **parte oficial del proyecto**, no una nota secundaria.

La persona que está desarrollando VHAL está **aprendiendo Godot, GDScript, networking, arquitectura de juegos y desarrollo de MMORPG de manera progresiva**.

Por lo tanto el objetivo no es únicamente llegar al resultado final.

También importa:

```text
entender qué estamos haciendo
entender por qué se hace
aprender a usar Godot
aprender a leer las escenas
aprender a conectar nodos y signals
aprender a separar responsabilidades
aprender a probar sistemas
aprender a diagnosticar errores
```

## 2.1 Regla pedagógica

Cada implementación importante debe explicar, en lenguaje claro:

```text
qué problema resuelve
qué responsabilidad tiene
en qué capa vive
por qué se coloca ahí
qué archivos toca
qué flujo produce
cómo se prueba
```

No asumir conocimiento avanzado.

Tampoco simplificar la arquitectura sólo porque el desarrollador todavía está aprendiendo.

La regla es:

> **Arquitectura profesional, explicación progresiva.**

---

# 3. FORMA DE IMPLEMENTACIÓN PREFERIDA

Las implementaciones nuevas deben hacerse de forma **manual, controlada y entendible**, tal como se viene trabajando.

No buscamos que una herramienta modifique silenciosamente decenas de archivos y entregue únicamente el resultado.

## 3.1 Para código nuevo

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
9. recién después hacer commit.
```

Cuando un cambio es pequeño, se puede indicar el bloque exacto.

Cuando un archivo queda difícil de editar parcialmente, es preferible entregar el archivo completo para reemplazarlo y evitar errores manuales de bloques incompletos.

## 3.2 Para escenas y cambios visuales

Para:

```text
Node tree
Control
Container
anchors
offsets
Theme
StyleBox
TextureRect
NinePatchRect
Panel
Button
slots
HUD
ventanas
componentes visuales
```

se prefiere **hacer los cambios manualmente dentro del editor de Godot** siempre que sea razonable.

La explicación debería decir, por ejemplo:

```text
abrí esta escena
seleccioná este nodo
agregá este hijo
cambiá esta propiedad del Inspector
asigná este recurso
conectá esta signal
ejecutá esta escena
```

Esto es especialmente importante porque forma parte del aprendizaje.

No reemplazar una escena `.tscn` completa automáticamente cuando un cambio visual pequeño puede enseñarse claramente desde el editor.

## 3.3 Excepciones

Se puede entregar un archivo completo o un paquete de archivos cuando:

- el archivo es muy grande;
- hay muchas modificaciones relacionadas;
- editar bloques manualmente tiene alto riesgo de error;
- el usuario lo solicita;
- el objetivo de esa etapa es arquitectura y no aprender un detalle del editor.

Aun así se debe explicar qué cambió.

---

# 4. WORKFLOW OBLIGATORIO DE DESARROLLO

VHAL usa el siguiente ciclo:

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

## 4.1 Regla de errores

Si aparece:

```text
Parser Error
warning nuevo
runtime error
ERR_BUSY inesperado
estado inconsistente
regresión
contrato fallido
```

la etapa actual **no está terminada**.

Se corrige antes de avanzar.

Objetivo habitual:

```text
0 parser errors
0 warnings nuevos
0 runtime errors inesperados
```

## 4.2 Git

Cuando una etapa queda lista para checkpoint, entregar juntos:

```bash
git status
git add .
git commit -m "mensaje"
git push
```

Se utiliza deliberadamente:

```bash
git add .
```

y no una lista manual de archivos.

Después del push se espera la respuesta:

```text
pusheado
```

y se confirma el commit remoto antes de avanzar.

---

# 5. REGLA DE REVISIÓN DEL REPOSITORIO

Antes de indicar una modificación concreta:

> **revisar el estado real actual del repositorio.**

No responder con frases ambiguas como:

```text
si ya tenés...
si existe...
quizás tu archivo...
probablemente...
```

cuando el repositorio está disponible para revisar.

La indicación correcta debe ser:

```text
este archivo existe
actualmente contiene esto
se reemplaza por esto
se agrega este archivo
este otro no se toca
```

Esto reduce errores y hace que el proceso sea reproducible.

---

# 6. MANDATO ARQUITECTÓNICO PRINCIPAL

La prioridad oficial de VHAL es:

> **Escalabilidad, mantenibilidad, consistencia y claridad de responsabilidades antes que velocidad de implementación.**

Una solución no se considera buena solamente porque funcione hoy.

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
¿Cómo se podrá optimizar después sin reescribir todo?
```

Si una implementación empieza a crear excepciones como:

```text
if warehouse...
if merchant...
if special_item...
if this_window...
if this_class...
if this_map...
```

dispersas simultáneamente por UI, networking, dominio y persistencia, hay que detenerse y diseñar una abstracción mejor.

---

# 7. ARQUITECTURA GENERAL ACTUAL

La arquitectura real actual es:

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

Los repositorios son:

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

---

# 8. AUTORIDAD DE DATOS

Regla oficial:

```text
Cliente     = intención + representación
Game Server = autoridad de gameplay/runtime
Backend     = identidad + API + persistencia durable
MySQL       = almacenamiento durable
```

## 8.1 Cliente

Puede decir:

```text
quiero moverme aquí
quiero mover este item
quiero equipar este UID
quiero interactuar con este NPC
quiero castear esta skill
```

No puede decidir definitivamente:

```text
mi posición real es ésta
el item ya quedó equipado
el mob recibió 500 daño
gané 1000 EXP
me quedan 12 MP
el drop existe
```

## 8.2 Game Server

Decide:

```text
movimiento
presencia
servicios NPC
inventory
equipment
vault
skills
combat
mana
cooldowns
damage
death
drops
pickup
EXP
level
PvP
trade
```

según se vayan implementando.

## 8.3 Backend

Responsabilidades:

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

La dirección del proyecto es:

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

No buscamos una arquitectura académica por nombre.

Buscamos patrones:

- claros;
- repetibles;
- fáciles de encontrar;
- fáciles de probar;
- fáciles de extender.

---

# 10. CAPAS CONCEPTUALES

## 10.1 Definitions

Describen qué existe.

Ejemplos:

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

No convertir prematuramente todo el contenido en tablas o JSON sólo por “escalabilidad”.

## 10.2 Runtime State

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
movimiento autoritativo
servicio NPC activo
snapshots persistentes conocidos
futuro combat state
futuro mob runtime state
```

## 10.3 UI / View

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

## 10.4 Networking

Debe encargarse de:

```text
transport
serialization
parsing
versionado
validación estructural básica
routing de mensajes
```

No convertirse en gameplay.

## 10.5 Domain Rules / Validators

Aquí viven las reglas reutilizables.

Ejemplos actuales:

```text
ServerEquipmentRules
ServerEquipmentSnapshotValidator
ServerEquipmentTransferValidator
ServerCharacterInventorySnapshotValidator
ServerVaultSnapshotValidator
ServerItemContainerTransferValidator
EquipmentRules
```

## 10.6 Repositories

Encapsulan infraestructura HTTP/backend.

Ejemplos:

```text
BackendTicketValidator
BackendCharacterInventoryRepository
BackendCharacterEquipmentRepository
BackendVaultRepository
BackendItemTransferRepository
```

El dominio no debe conocer rutas Laravel.

## 10.7 Coordinators / Flows

Coordinan casos de uso.

No son “Managers para todo”.

Cada uno tiene una responsabilidad concreta.

---

# 11. IDs ESTABLES COMO CONTRATO

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
class_id   = ...
skill_id   = ...
```

Esto permite reorganizar escenas/código sin corromper datos persistentes.

---

# 12. ESTRUCTURA ACTUAL DEL CLIENTE

El cliente ya utiliza organización principalmente feature-first.

Estructura conceptual actual relevante:

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
│   │   └── networking/
│   │       ├── game_server_client.gd
│   │       └── protocols/
│   │           ├── game_server_world_protocol.gd
│   │           ├── game_server_presence_protocol.gd
│   │           ├── game_server_movement_protocol.gd
│   │           ├── game_server_npc_protocol.gd
│   │           └── game_server_item_protocol.gd
│   ├── inventory/
│   ├── items/
│   ├── player/
│   ├── skills/
│   ├── vault/
│   └── world/
│
├── ui/
│   └── shared/
│
├── assets/
├── art_source/
├── debug/
├── shared/
└── test/
```

La estructura puede seguir evolucionando gradualmente.

No crear carpetas vacías “por si acaso”.

Se crea una carpeta cuando aparece una responsabilidad real que la necesita.

---

# 13. CLIENTE — APPLICATION FLOW POST F15-R

Después de F15-R11:

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
└── Inventory/Vault/Equipment bridge
```

`app/main.gd` ya no debe volver a transformarse en un archivo donde termine toda la lógica nueva.

---

# 14. CLIENTE — NETWORKING POST F15-R

Existe:

```text
GameServerClient
```

y sigue existiendo **una sola conexión ENet**.

Arquitectura:

```text
GameServerClient
│
├── ENetMultiplayerPeer único
├── autenticación de conexión
├── envelope/versionado
├── packet dispatch
├── send centralizado
│
├── GameServerWorldProtocol
├── GameServerPresenceProtocol
├── GameServerMovementProtocol
├── GameServerNpcProtocol
└── GameServerItemProtocol
```

No crear un ENet peer por feature.

No crear:

```text
InventoryConnection
CombatConnection
ChatConnection
NpcConnection
```

como sockets independientes sin una razón arquitectónica real.

## 14.1 ItemProtocol

Inventory, Vault y Equipment continúan juntos internamente donde necesitan compartir la serialización de mutaciones.

Regla:

```text
Inventory move
Vault move
Inventory ↔ Vault
Inventory ↔ Equipment
```

no deben iniciar simultáneamente cuando comparten estado pendiente.

La serialización sigue siendo parte del contrato del cliente.

---

# 15. ESTRUCTURA ACTUAL DEL GAME SERVER

Estructura conceptual:

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
│       └── world_presence_coordinator.gd
│
└── core/
	├── networking/
	├── backend/
	├── world/
	│   ├── movement/
	│   ├── navigation/
	│   └── npcs/
	└── domain / catalogs / validators
```

## 15.1 ServerMain

Después de F15-R:

```text
ServerMain
└── composition root
```

Sus responsabilidades son principalmente:

```text
resolver nodos/dependencias
validar configuración
ejecutar contratos/self-tests
inicializar registries
configurar coordinators
conectar dependencias de alto nivel
arrancar el servidor
manejar fallos de startup
```

No debe volver a absorber:

```text
equip request
inventory request
NPC interaction
movement decisions
world presence
authentication callbacks
```

directamente.

---

# 16. RESPONSABILIDADES DE LOS COORDINATORS DEL GAME SERVER

## CharacterItemStateCoordinator

Responsable de estado compartido persistente del personaje:

```text
Inventory snapshot
Equipment snapshot
initial load
reload
resend
stale recovery
```

No contiene las reglas de Equip ni las reglas de mover Inventory.

## EquipmentCoordinator

Responsable de:

```text
Equip
Unequip
validación de transferencia
persistencia
resync
```

## InventoryCoordinator

Responsable de:

```text
movimiento interno Inventory
validación
persistencia
resync
```

## VaultCoordinator

Responsable de:

```text
carga Vault
movimiento interno Vault
estado Vault activo
```

Vault es account-wide.

## ItemContainerTransferCoordinator

Responsable de:

```text
Inventory → Vault
Vault → Inventory
```

## NpcServiceCoordinator

Responsable de:

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

Responsable de:

```text
movement intent
NavMesh resolution
path validation
movement authorization
rejection
replication
NPC range checks durante movimiento
```

El movimiento físico/tick permanece en:

```text
WorldMovementSystem
```

## WorldPresenceCoordinator

Responsable de:

```text
same-map roster
initial presence
player joined
player left
```

## AuthenticationCoordinator

Responsable de:

```text
ticket flow
connection authentication
WorldSession creation
initial world snapshot
presence bootstrap
persistent item bootstrap
disconnect cleanup
```

---

# 17. BACKEND / PERSISTENCIA

Backend Laravel real.

Estructura Laravel estándar con responsabilidades del proyecto dentro de:

```text
app/
database/
routes/
config/
tests/
```

El Backend no es autoridad de gameplay en tiempo real.

Es autoridad de:

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

## 17.1 Tabla item_instances

Modelo actual conceptual:

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

Regla:

```text
ItemDefinition = tipo de item
ItemInstance   = instancia concreta
```

Ejemplo:

```text
bronze_sword
```

es definición.

Una espada específica que posee un jugador tiene:

```text
uid
quantity
container
position
equipment slot
future state
```

El campo `state` puede crecer, por ejemplo:

```json
{
  "durability": 42,
  "upgrade_level": 7,
  "excellent_options": [],
  "sockets": [],
  "bound": false
}
```

Pero no meter indiscriminadamente todo en JSON.

Datos con query/indexación fuerte pueden merecer columnas o tablas específicas.

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

## 20.1 Hand modes

```text
none
main_hand_only
one_hand
two_hand
off_hand_only
```

## 20.2 TWO_HAND

Contrato:

```text
item TWO_HAND
→ se almacena una sola vez en main_hand
→ off_hand queda reservado de forma derivada
→ nunca se duplica el UID
```

El slot lógico, la reserva de slots y el attachment visual son conceptos separados.

---

# 21. ITEMS REALES DE FOUNDATION

Ejemplos de contenido real actual utilizado para test:

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

# 22. ESTADO FUNCIONAL REAL ACTUAL

Están probados de punta a punta:

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
```

VHAL ya no debe describirse como “UI Lab”.

---

# 23. F00 → F14 — FOUNDATION

## F00 — Estabilización

✅ COMPLETADO / absorbido.

## F01 — Organización feature-first

✅ MAYORMENTE COMPLETADO.

## F02 — ClientSession + ScreenRouter

✅ IMPLEMENTADO.

## F03 — Service Layer

✅ IMPLEMENTADO en la base real.

Algunos mocks transitorios pueden seguir existiendo donde todavía no se sustituyeron por gameplay definitivo.

## F04 — PlayerRuntimeState

✅ IMPLEMENTADO.

## F05 — Debug fixtures

✅/🟡 suficientes.

Se retiran gradualmente conforme cada sistema se vuelve real.

## F06 — UI Core

✅ base funcional.

## F07 — Backend / cuentas reales

✅ IMPLEMENTADO.

## F08 — Personajes reales

✅ IMPLEMENTADO.

## F09 — Loading + Game Session

✅ IMPLEMENTADO.

## F10 — Primer mapa

✅ `test_town`.

## F11 — Player Actor 3D

✅ base funcional.

Visual/model final pendiente.

## F12 — Cámara + movimiento

✅ base autoritativa funcional.

## F13 — Networking autoritativo

✅ FOUNDATION implementada.

## F14 — NPC Framework

✅ FOUNDATION implementada.

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

## B1 / B1R

Contrato estable de slots + semántica de manos.

## B2

Backend persistente.

## B3

Game Server domain + snapshot + validation + persistence flow.

## B4

Protocolo ENet.

## B5

Client snapshot → runtime → UI + drag & drop.

## B6

Integridad y edge cases.

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

## B7

Cierre formal y smoke completo.

Resultado:

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

No fue una optimización de performance.

No agregó gameplay nuevo.

## R0 — Architectural baseline

✅

Cliente:

```text
b16d55211603831e15f5f2cca9ede5f5f21ba93e
docs: record architectural refactor baseline
```

## R1 — CharacterItemStateCoordinator

✅

Game Server:

```text
719f1d1116ea250d77a08e633aacb7b128b0b193
refactor: extract character item state coordination
```

## R2 — EquipmentCoordinator

✅

```text
f82e5c37d7e48f531202f328a6da0adbe3661649
refactor: extract equipment coordination
```

## R3 — InventoryCoordinator

✅

```text
dd35175184d10e69f49841a7120ea38e0551f272
refactor: extract inventory coordination
```

## R4 — VaultCoordinator

✅

```text
547a591d5499a16e5ffbe358041d513f5483ebd4
refactor: extract vault coordination
```

## R5 — ItemContainerTransferCoordinator

✅

```text
f0287015a333f329a872c5a6d08a385c9bbbd2bd
refactor: extract item container transfer coordination
```

## R6 — NpcServiceCoordinator

✅

```text
6349ef9d592cef994e1f9fb5abd8fd91cf1a1e64
refactor: extract npc service coordination
```

## R7 — MovementCoordinator

✅

```text
1e121832aac19a1c9e624d0312285d3f5fe0e095
refactor: extract movement coordination
```

## R8 — WorldPresenceCoordinator

✅

```text
944b2be56b3f8979c6d6d4b00d8048ad458d73fc
refactor: extract world presence coordination
```

## R9 — AuthenticationCoordinator

✅

```text
c62a67f442936a29eb8c6bad37c473a5ba4e7b3c
refactor: extract authentication coordination
```

## R10 — GameServerClient protocol split

✅

Cliente:

```text
e1c939fed4b6b626217ed069e0d935a36d010f12
refactor: split game server client protocols
```

## R11 — Client application flow split

✅

```text
cc12482d38c3e22b399ebda6562e0451eebfd21b
refactor: split client application flows
```

## R12 — Cleanup + full regression

✅ VALIDADO EN RUNTIME EL 23/08/2026.

Validación final:

```text
Application flow                      OK
Authentication                        OK
World bootstrap                       OK
Movement                              OK
Two-player Presence                   OK
NPC interaction                       OK
Warehouse lifecycle                   OK
Inventory internal move               OK
Vault internal move                   OK
Inventory → Vault                     OK
Vault → Inventory                     OK
Inventory → Equipment                 OK
Equipment → Inventory                 OK
Persistent relog                      OK
Stale-state recovery                  OK
Unexpected ERR_BUSY                   NONE
Client warnings/errors                NONE
Game Server warnings/errors           NONE
Backend unexpected errors             NONE
```

---

# 27. CHECKPOINTS IMPORTANTES PREVIOS DE F15

## Cliente

```text
1645ff315365d8125302832d163fa3f359718147
foundation: add stable equipment slot contract

9c8d49364997ddd72b0ecdfdf50b779f93a84706
foundation: migrate equipment slots to stable semantic ids

3bc5d692c93b349973ece119a3e88c531504d7c1
foundation: add semantic equipment hand rules

7614a3be009ccd0a1e1ac90fa34cebcbd025a580
foundation: add authoritative equipment client protocol

1a8cda066af11716a3617e91d47d4fec6a593b97
foundation: apply authoritative equipment state

8ba6a9a72eac1fd7a11f8e159bd19975ae1087ba
foundation: add authoritative equipment drag and drop

7921e91c5f50a90cd128b6c676b1b64c38ed2d40
fix: serialize authoritative item mutations

6dcd698c9e6c544a043952d3a3ce42357fd6761c
docs: add canonical project memory checkpoint
```

## Game Server

```text
df1f61855ca5eb28dd83afcba34b79b9212971fa
foundation: add authoritative equipment snapshot

a58ca5a8e6361936a02c64f92ac89f5df8091c7b
foundation: add authoritative equipment transfer validation

49ddad490a9157051640b7c03a81779f3ce8016e
foundation: add authoritative equipment persistence flow

64778af6906c0c0efa67609ddf795e36cdbf299c
foundation: add authoritative equipment network protocol

0c5d9cee1adfd8a1bbb8563e2a5cc308d5ae7642
test: strengthen equipment transfer integrity contract

13c225a5fd0c18d8143064a156fcc79fed1add57
test: add equipment snapshot integrity contract
```

## Backend

```text
f163645958a990a133e6cb983abee3427c94483e
foundation: add atomic inventory vault transfers

5e875cae0ac403fafb9fc9d92ce4a165c82d2243
foundation: add persistent character equipment backend
```

---

# 28. STALE-STATE RECOVERY

Este flujo es parte del contrato arquitectónico.

Ejemplo probado:

```text
Client/Game Server creen:
Bronze Sword en posición vieja

MySQL:
posición modificada manualmente
```

Resultado:

```text
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

Dirección conceptual:

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

---

# 30. UI — DIRECCIÓN VISUAL

La UI final debe tener identidad propia de VHAL.

No queremos depender permanentemente de assets placeholder/Kenney.

La referencia conceptual para densidad y funcionalidad es un MMORPG clásico, especialmente una interfaz compacta tipo MU Online, pero **no se busca copiar visualmente MU**.

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

## 30.1 Ventanas

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

## 30.2 Inventory

Dirección:

```text
compacto
grid multicelda
gaps pequeños
Equipment compacto
drag & drop claro
tooltip consistente
```

## 30.3 Assets

Paquete VHAL ideal:

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

Nombres:

```text
lowercase_snake_case.png
```

Estados visuales del mismo control deben usar:

```text
mismo canvas
mismo tamaño
misma posición
misma geometría
```

y cambiar sólo el feedback visual.

## 30.4 9-slice

Para paneles/ventanas:

```text
NinePatch / StyleBoxTexture
```

separar:

```text
Texture Margins
≠
Content Margins
```

---

# 31. REGLA SOBRE `windows/`

`Window` es un concepto correcto.

Lo que se evita es una carpeta global gigante como:

```text
windows/
├── inventory
├── trade
├── guild
├── quest
├── crafting
├── merchant
├── ...
```

Preferir organización por feature:

```text
features/inventory/ui/inventory_window.*
features/vault/ui/vault_window.*
features/skills/ui/skills_window.*
```

y dejar shared únicamente para verdaderos componentes reutilizables:

```text
ui/shared/windows/base_window.*
```

---

# 32. DATOS DE CONTENIDO A GRAN ESCALA

No intentar resolver hoy todo el contenido futuro con una única técnica.

Regla:

```text
static definition
runtime state
persistent player/account state
```

son problemas distintos.

## Static definitions

Pueden comenzar como:

```text
Godot Resources
catalogs
configs
```

con IDs estables.

Ejemplos:

```text
ItemDefinition
SkillDefinition
MobDefinition
NpcDefinition
MapDefinition
```

## Persistencia

Datos únicos por jugador/cuenta:

```text
inventory
equipment
vault
character progression
quests
currencies
```

pertenecen a persistencia durable.

## Futuro

Cuando el contenido crezca mucho se evaluará de forma medida qué conviene mover a:

```text
DB
data tables
JSON/config
admin tooling
content pipeline
```

No hacer migraciones de arquitectura de contenido anticipadas sin necesidad real.

---

# 33. ESCALABILIDAD DE MMORPG

“Pensar a gran escala” no significa implementar clustering hoy.

Significa no tomar decisiones que lo vuelvan imposible mañana.

VHAL debe permitir evolucionar hacia:

```text
muchos jugadores
muchos NPCs
muchos mobs
muchos items
muchas skills
múltiples mapas
interest management
spatial partition
varios procesos Game Server
world/channel/shard architecture cuando sea necesaria
observabilidad
persistencia desacoplada del tick de combate
```

pero sólo introducir cada complejidad cuando exista una necesidad medida.

---

# 34. MAPAS

No crear un mapa final enorme antes de tener el vertical slice.

La estrategia actual es:

```text
test_town
→ validar sistemas
→ agregar mapa/zonas reales de forma progresiva
```

Cada mapa debe tener un `map_id` estable.

El Game Server mantiene autoridad de:

```text
posición
navegación
presencia
entidades runtime
```

La escena visual del cliente no es la fuente de verdad persistente.

---

# 35. NPCs

No crear un script especial para cada NPC.

Modelo futuro:

```text
NpcDefinition
+
NpcRuntimeState / registry
+
services
+
NpcActor presentation
```

Primer ejemplo real:

```text
warehouse_keeper
→ warehouse
```

El patrón debe poder reutilizarse para:

```text
merchant
quest giver
teleporter
trainer
crafting
etc.
```

sin agregar condicionales globales dispersos.

---

# 36. SKILLS Y COMBAT — REGLA CRÍTICA

Skills/Combat NO deben copiar el flujo persistente lento de Inventory para cada acción.

Incorrecto:

```text
cast
→ Laravel
→ MySQL
→ esperar
→ daño
```

Correcto conceptualmente:

```text
Client intent
→ Game Server runtime authority
→ validación inmediata
→ resultado gameplay
→ replicación
→ persistencia con política apropiada
```

El Game Server debe ser autoridad inmediata del combate.

---

# 37. F15-C — OPERACIONES DE ITEMS PENDIENTES

**Estado:** ⏳ EVALUAR AHORA QUE F15-R ESTÁ CERRADO.

No implementar automáticamente todas.

Posibles operaciones:

```text
stack merge autoritativo
stack split
partial quantity transfer
sort autoritativo
consumibles
durability
item state
```

Se implementará únicamente lo que sea estrictamente necesario para el vertical slice o para evitar una deuda funcional inmediata.

No mezclar semánticas diferentes bajo un endpoint genérico.

Ejemplo:

```text
move whole UID
```

no equivale a:

```text
merge quantity UID A → UID B
```

---

# 38. F16 — SKILLS + CAST REAL

**Estado:** ⏳ PRÓXIMO BLOQUE GRANDE después de evaluar F15-C.

Objetivo:

```text
skill seleccionada/hotbar
→ cast intent
→ Game Server
→ validación
→ resultado autoritativo
```

Game Server valida:

```text
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

# 39. F17 — PRIMER MOB + COMBATE

Implementar **un mob completo**, no veinte mobs incompletos.

Conceptos:

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

---

# 40. F18 — DROP + PICKUP + EXP + LEVEL

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

---

# 41. F19 — VERTICAL SLICE COMPLETO

Primer gran objetivo estratégico.

Debe funcionar:

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

Después multiplicar contenido.

---

# 42. PERFORMANCE — SEPARADA DEL REFACTOR

Regla:

```text
Refactor ≠ Optimization
```

F15-R ya resolvió estructura/mantenibilidad.

No fue diseñado para bajar ping.

## 42.1 Estado actual

Algunas mutaciones persistentes pueden tardar aproximadamente:

```text
~1 segundo o algo menos
```

porque el flujo conservador puede ser:

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

Durante Foundation esto fue aceptado para priorizar corrección y convergencia.

## 42.2 PERF-0

Se pueden agregar mediciones antes de optimizar:

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

## 42.3 PERF-1

Optimización agresiva después de F19 estable, salvo blocker real medido.

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

# 43. QUÉ NO HACER AHORA

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

# 44. AUTOLOADS

No convertir cada sistema en Singleton.

Un Autoload sólo debe existir cuando realmente representa una responsabilidad global de aplicación.

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

# 45. SIGNALS Y DEPENDENCIAS

Usar signals para desacoplar cuando existe una relación de eventos real.

No usar signals únicamente para ocultar dependencias.

Los sistemas importantes deben recibir explícitamente lo que necesitan mediante:

```text
setup(...)
node composition
constructor-like configuration
```

La dependencia debe ser rastreable.

---

# 46. TESTING

Cada nueva feature debe tener una estrategia de prueba.

Según el caso:

```text
self-test domain contract
unit/integration backend tests
manual Godot smoke
two-client test
stale-state test
relogin test
DB integrity check
```

No esperar al final del proyecto para descubrir que dos sistemas no conviven.

---

# 47. REGLA PARA DOS CLIENTES

Todo sistema relacionado con:

```text
presence
movement replication
combat multiplayer
party
trade
PvP
drops visibles
```

debe probarse con dos clientes reales cuando corresponda.

Un solo cliente no valida multiplayer.

---

# 48. ESTRATEGIA DE CRECIMIENTO

Orden estratégico:

```text
BASE CORRECTA
↓
VERTICAL SLICE COMPLETO
↓
MEDIR
↓
OPTIMIZAR
↓
ESCALAR CONTENIDO
↓
AMPLIAR SISTEMAS SOCIALES / ECONOMÍA / ENDGAME
```

No:

```text
100 features incompletas
↓
intentar arreglar arquitectura al final
```

---

# 49. ESTILO DE DECISIONES

Cuando existan dos alternativas, priorizar la que:

```text
mantenga IDs estables
mantenga una autoridad clara
reduzca acoplamiento
evite duplicar estado
permita tests
permita reemplazar implementación interna
permita agregar contenido sin editar lógica central
```

No elegir por “es menos código” solamente.

---

# 50. CÓMO CONTINUAR UNA NUEVA CONVERSACIÓN

Antes de proponer código:

1. leer este `PROJECT_MEMORY.md`;
2. revisar commits actuales de `dev`;
3. inspeccionar archivos reales involucrados;
4. identificar exactamente el checkpoint actual;
5. respetar workflow etapa → test → commit → push;
6. explicar la implementación pensando que el desarrollador está aprendiendo;
7. mantener arquitectura de MMORPG real y escalable;
8. no avanzar si hay warnings/errors;
9. preferir integración manual y educativa;
10. conservar `PROJECT_MEMORY.md` actualizado en cierres arquitectónicos importantes.

---

# 51. CHECKPOINT ACTUAL

Al 23/08/2026:

```text
F00-F14 Foundation             ✅
F15-A Inventory ↔ Vault       ✅
F15-B Equipment               ✅
F15-R Architectural Refactor  ✅ VALIDADO
F15-C Item operations         ⏳ EVALUAR SÓLO SI SON NECESARIAS
F16 Skills / Cast             ⏳
F17 Mob / Combat              ⏳
F18 Drop / Pickup / EXP       ⏳
F19 Vertical Slice            ⏳
PERF-1                        ⏳ después de F19 estable
```

Últimos checkpoints remotos previos al commit documental de cierre:

```text
CLIENT
cc12482d38c3e22b399ebda6562e0451eebfd21b
refactor: split client application flows

GAME SERVER
c62a67f442936a29eb8c6bad37c473a5ba4e7b3c
refactor: extract authentication coordination

BACKEND
5e875cae0ac403fafb9fc9d92ce4a165c82d2243
foundation: add persistent character equipment backend
```

---

# 52. CHECKPOINT EN UNA FRASE

> **VHAL ya posee una Foundation real de MMORPG con cuentas y personajes persistentes, entrada autenticada al mundo, movimiento y presencia server-authoritative, NPC Warehouse, Inventory/Vault/Equipment persistentes, recuperación stale, UID estable y una arquitectura post-refactor donde Game Server, networking cliente y application flow tienen responsabilidades separadas; el siguiente objetivo es evaluar si F15-C necesita alguna operación mínima de items y luego construir Skills/Cast, el primer Mob/Combat, Drops/Pickup/EXP/Level y cerrar el primer vertical slice real antes de escalar contenido u optimizar agresivamente.**

---

# 53. PRINCIPIO FINAL

VHAL no busca crecer rápido a costa de quedar inmantenible.

Busca aprender y construir al mismo tiempo.

La regla permanente es:

> **Cada sistema nuevo debe ser entendible, autoritativo donde corresponda, testeable, extensible y fácil de modificar sin romper sistemas no relacionados.**

Y la forma de trabajo permanente es:

```text
entender
→ diseñar
→ implementar manualmente
→ probar
→ corregir
→ commit
→ push
→ continuar
```
