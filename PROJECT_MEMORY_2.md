# VHAL — PROJECT MEMORY 2 / CONTINUIDAD CANÓNICA

**Volumen:** 2  
**Última actualización:** 25/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  
**Estado general:** F19 Vertical Slice cerrado y F20 Durable Character Runtime cerrado, probado y pusheado.  
**Siguiente bloque recomendado:** F21-A — Durable Skill Ownership Foundation.

---

# 0. CÓMO FUNCIONAN LOS PROJECT MEMORY POR VOLÚMENES

A partir de este punto VHAL usa memoria canónica por volúmenes para evitar que un único `PROJECT_MEMORY.md` crezca indefinidamente y se vuelva difícil de mantener.

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

## Orden obligatorio de lectura

Al retomar VHAL en una conversación nueva:

```text
1. leer PROJECT_MEMORY.md
2. leer PROJECT_MEMORY_2.md
3. revisar repositorios reales en dev
4. continuar desde el último volumen
```

## Regla de precedencia

Si existe una contradicción entre volúmenes:

> **El volumen más nuevo prevalece para el estado actual.**

Esto permite conservar historia sin reescribirla.

Ejemplo:

```text
PROJECT_MEMORY.md dice:
Position / HP / MP todavía no son durables

PROJECT_MEMORY_2.md dice:
F20 ya implementó esa persistencia

→ prevalece PROJECT_MEMORY_2.md
```

El volumen anterior sigue siendo válido como historia de cómo evolucionó el proyecto.

## Futuro PROJECT_MEMORY_3.md

Cuando este archivo se vuelva demasiado largo:

```text
PROJECT_MEMORY.md
PROJECT_MEMORY_2.md
PROJECT_MEMORY_3.md
```

Lectura:

```text
1 → 2 → 3
```

Y nuevamente:

```text
el volumen más reciente
→ autoridad sobre estado actual / roadmap / decisiones nuevas
```

No borrar los volúmenes anteriores salvo una decisión explícita de archivo histórico.

---

# 1. WORKFLOW OBLIGATORIO — SE MANTIENE SIN CAMBIOS

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

- no avanzar a la siguiente etapa antes de `pusheado`;
- preferir etapas pequeñas;
- probar antes de commit;
- revisar `git status` antes de commit;
- no mezclar scope ajeno;
- mantener objetivo habitual de `0 warnings / 0 errors`;
- revisar siempre el repositorio real antes de indicar cambios concretos;
- GitHub actual prevalece sobre recuerdos anteriores.

Cuando una modificación de escena/nodos/Inspector es razonablemente manual, el usuario la realiza en Godot para conservar aprendizaje y control.

---

# 2. REPOSITORIOS Y BASELINES ACTUALES

Rama activa habitual:

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

Baselines confirmados al cierre de F20:

## Cliente / memoria canónica

```text
557bee80258d09cfbc9084e42213d14caefd9b85
docs: close F19 vertical slice and record future systems
```

En F20 el cliente no necesitó cambios de gameplay porque el contrato `world_snapshot` ya podía representar `world` y `vitals` autoritativos.

## Game Server

```text
2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

Cadena F20 del Game Server:

```text
f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime

fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect

2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

## Backend

```text
55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence
```

Commit anterior importante ya incluido en su historia:

```text
1ae3036031bd8d2e8fb6289c94df4d2869c6e23c
fix: include experience in game session ticket
```

---

# 3. ARQUITECTURA CANÓNICA — CONTINÚA VIGENTE

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

Regla:

```text
Cliente
= intención + representación

Game Server
= autoridad inmediata de gameplay/runtime

Backend
= identidad + API + persistencia durable

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
item placement definitiva
EXP
level
loot
pickup success
skill ownership
estado PvP
```

---

# 4. REGLA CRÍTICA — BACKEND NO ENTRA EN EL HOT LOOP DE COMBAT

Continúa vigente:

```text
Client intent
→ Game Server validation/mutation
→ authoritative result/events
→ clients
```

Incorrecto:

```text
cada attack/cast
→ Laravel
→ MySQL
→ esperar
→ gameplay
```

Laravel se utiliza para persistencia durable con políticas apropiadas, no como autoridad síncrona de cada frame/ataque/cast.

F20 refuerza esta dirección:

```text
movimiento y Vitals
→ runtime inmediato Game Server

checkpoint periódico / disconnect
→ persistencia durable Backend
```

---

# 5. INPUT CANÓNICO ESTILO MU — NO CAMBIAR

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

Basic Attack sigue siendo weapon-aware y resuelto por Game Server:

```text
sin arma
→ unarmed

sword / axe / etc.
→ melee

bow futuro
→ ranged
```

No renombrar el modo protocolar `unarmed`.

`bronze_sword` continúa resolviendo modo:

```text
melee
```

El cliente sólo solicita entidad/acción. El Game Server decide arma, modalidad, rango, damage y cooldown.

Auto-chase sigue diferido a un checkpoint dedicado.

---

# 6. ESTADO HEREDADO DEL VOLUMEN 1 — F19

F19 cerró el primer vertical slice MMORPG real del proyecto.

Flujo ya validado antes de F20:

```text
Login
→ Character Select
→ Ticket
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

Al cierre F19 estaban comprobados:

```text
Inventory persistente
Equipment persistente
Vault persistente
Level / EXP persistentes
Skills autoritativas runtime
WorldDrop autoritativo mientras vive el GS
Pickup durable
Mob death / respawn
Heal / mana / cooldown
Basic Attack melee / unarmed
```

F19 dejó deliberadamente pendientes:

```text
Position/map durable
HP/MP durable
Skill ownership durable
Economy
PvP/PK
WorldDrop durability tras restart GS
Merchant
Stats completos
más mapas/contenido
```

F20 resolvió el primer grupo:

```text
Position/map/rotation durable
HP/MP durable
```

---

# 7. F20 — DURABLE CHARACTER RUNTIME

**Estado:** ✅ COMPLETADO, PROBADO, COMMITEADO Y PUSHEADO.

F20 resolvió la persistencia durable del runtime fundamental del personaje sin duplicar sistemas ya existentes.

Estado durable agregado:

```text
map_id
position x/y/z
rotation_y
hp
mp
```

Estado que NO se duplicó:

```text
level
experience
```

porque ya pertenece a Character Progression.

También NO se persiste:

```text
max_hp
max_mp
```

porque se derivan de reglas autoritativas actuales del Game Server.

Sub-etapas:

```text
F20-A  Durable Runtime Backend           ✅
F20-B1 Runtime Restore                  ✅
F20-B2 Disconnect Checkpoint            ✅
F20-C  Periodic Autosave / Crash        ✅
```

---

# 8. F20-A — DURABLE RUNTIME BACKEND

**Estado:** ✅ COMPLETADO.

## Decisión de modelo

No se agregaron campos mutables de sesión directamente a `characters`.

Se creó una relación 1:1:

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

No incluye:

```text
max_hp
max_mp
level
experience
```

## Contrato durable

Endpoint interno:

```text
PUT /api/internal/accounts/{accountId}/characters/{characterId}/runtime-state
```

Payload conceptual:

```json
{
  "expected_revision": 0,
  "state": {
    "world": {
      "map_id": "test_town",
      "position": {
        "x": 4.5,
        "y": 0,
        "z": 7.25
      },
      "rotation_y": 1.5
    },
    "vitals": {
      "hp": 85000,
      "mp": 290
    }
  }
}
```

## Revisionado

Primer persist:

```text
runtime no existe
expected_revision = 0
→ create
→ revision = 1
```

Update:

```text
expected_revision = N
estado válido
→ revision N + 1
```

Stale:

```text
expected_revision != current_revision
→ HTTP 409
→ current snapshot
```

## Idempotencia

Se soporta retry después de pérdida de respuesta.

Si el estado persistido coincide exactamente con el solicitado y la revisión corresponde al expected válido/replay:

```text
idempotent = true
→ no bump artificial de revision
```

## Concurrencia

Laravel utiliza:

```text
transaction
lock del Character
lock del runtime cuando existe
```

El lock del Character también serializa el caso en que todavía no existe fila runtime.

## Ticket de sesión

`InternalGameSessionTicketController` entrega ahora:

```text
character
├── id
├── name
├── class_id
├── level
├── experience
└── runtime
    ├── revision
    ├── world
    │   ├── map_id
    │   ├── position
    │   └── rotation_y
    └── vitals
        ├── hp
        └── mp
```

Si nunca se persistió runtime:

```text
runtime = null
```

## Tests Backend

```text
InternalCharacterRuntimeStateTest
5 passed
63 assertions
```

Casos:

```text
primer checkpoint
retry idempotente
update
stale rejection
session ticket incluye progression + runtime
```

Regresión de Progression:

```text
InternalCharacterProgressionTest
5 passed
23 assertions
```

Checkpoint:

```text
55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence
```

---

# 9. F20-B1 — RESTORE DURABLE RUNTIME

**Estado:** ✅ COMPLETADO.

`PlayerWorldSession` continúa construyendo primero foundation:

```text
vitals max/current foundation
skills foundation temporal
basic attack runtime
foundation map/spawn
```

Luego, si `character.runtime` existe, se aplica el estado durable.

Orden:

```text
foundation
→ durable override
```

Esto permite que un personaje que todavía nunca tuvo checkpoint siga entrando normalmente.

## runtime_revision

`PlayerWorldSession` mantiene:

```text
runtime_revision
```

Si no existe runtime durable:

```text
runtime_revision = 0
```

Si existe:

```text
runtime_revision = revision persistida
```

## Restore world

Se restauran:

```text
map_id
position
rotation_y
```

## Restore vitals

Se restauran:

```text
hp
mp
```

mediante las primitives de `ServerVitalsState`.

Esto clampa contra los máximos actuales del Game Server.

Por ejemplo:

```text
checkpoint viejo hp > max_hp actual
→ restore clamp
→ nunca HP por encima del máximo actual
```

## Runtime malformado

Diferenciar:

```text
runtime = null
→ válido
→ usar foundation

runtime presente pero estructuralmente inválido
→ bootstrap inválido
→ no aceptar silenciosamente
```

## Test real B1

Checkpoint manual:

```text
revision = 1
map = test_town
position = (1, 0, 1)
rotation_y = 1.25
hp = 87654
mp = 222
```

Game Server restauró:

```text
Posición: (1,0,1)
HP: 87654/100000
MP: 222/350
Runtime revision: 1
```

Cliente/HUD mostró los mismos valores.

Sin cambios de cliente.

Checkpoint:

```text
f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime
```

---

# 10. F20-B2 — DISCONNECT CHECKPOINT

**Estado:** ✅ COMPLETADO.

Objetivo:

```text
logout / disconnect
→ persistir estado final
```

Decisión importante:

> No mantener una `PlayerWorldSession` fantasma en el mundo esperando a Laravel.

Flujo real:

```text
peer disconnect
→ resolver PlayerWorldSession
→ capturar snapshot durable INMEDIATAMENTE
→ iniciar HTTP async
→ notify_presence_left
→ remove_session
→ Laravel confirma utilizando la copia capturada
```

## Nuevos componentes

Game Server:

```text
core/backend/backend_character_runtime_state_repository.gd
app/coordinators/character_runtime_state_coordinator.gd
```

`AuthenticationCoordinator` coordina teardown pero no contiene HTTP ni reglas de persistencia.

## Snapshot persistente de sesión

`PlayerWorldSession.to_persistent_runtime_state()` contiene sólo:

```text
world
├── map_id
├── position x/y/z
└── rotation_y

vitals
├── hp
└── mp
```

No contiene:

```text
max_hp
max_mp
level
experience
```

## Test real B2

Inicio:

```text
Revision 1
Position: (1,0,1)
HP: 87654
MP: 222
```

Gameplay:

```text
movimiento
→ (-2.420902, 0, 1.101203)

Heal
→ HP 100000
→ MP 182
```

Disconnect:

```text
Checkpoint iniciado
Reason: disconnect
Revision esperada: 1
Position: (-2.420902, 0, 1.101203)
HP: 100000
MP: 182

Checkpoint confirmado
Revision: 1 → 2
Idempotent: false
```

MySQL:

```text
position_x = -2.4209017753601
position_y = 0
position_z = 1.1012027263641
rotation_y = 1.6003711054053
hp = 100000
mp = 182
revision = 2
```

Reconnect:

```text
Runtime revision: 2
Position: (-2.420902, 0, 1.101203)
HP: 100000/100000
MP: 182/350
Level: 123
EXP: 50/100
Inventory: 5
Equipment: 1
```

Esto confirmó independencia entre dominios.

Checkpoint:

```text
fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect
```

---

# 11. F20-C — PERIODIC AUTOSAVE + CRASH RECOVERY

**Estado:** ✅ COMPLETADO.

Objetivo:

> No depender únicamente del logout/disconnect para conservar horas de gameplay.

## Política actual

```text
AUTOSAVE_INTERVAL_MSEC = 30000
AUTOSAVE_JITTER_MSEC = 5000
AUTOSAVE_SCAN_INTERVAL_SECONDS = 1.0
AUTOSAVE_RETRY_DELAY_MSEC = 5000
```

Conceptualmente:

```text
cada ~30–35 s por sesión
→ considerar autosave
```

El jitter evita que todos los jugadores conectados al mismo tiempo disparen HTTP exactamente en el mismo instante.

## No guardar sin cambios

Se conserva un baseline del último runtime confirmado.

Se compara:

```text
map_id
position x/y/z
rotation_y
hp
mp
```

Si no cambió:

```text
NO HTTP
NO write MySQL
```

Si cambió:

```text
autosave
→ persist
→ revision N → N+1
→ actualizar session.runtime_revision
→ nuevo baseline
```

No se persiste movimiento por frame/tick.

## Race autosave + disconnect

Caso crítico cubierto:

```text
autosave HTTP pendiente
↓
jugador desconecta
↓
disconnect intenta checkpoint
```

No se pierde el estado final.

Flujo:

```text
autosave pendiente
+
disconnect
→ capturar snapshot FINAL del disconnect
→ queued_disconnect_checkpoints
→ remover presencia/sesión normalmente
→ autosave confirma
→ usar nueva revision
→ persistir snapshot final encolado
```

Esto evita que un `ERR_BUSY` descarte el estado final.

## Stale recovery

Cuando Backend responde con una revisión actual distinta, el coordinator puede actualizar la revisión conocida y realizar el recovery necesario según el caso.

Para disconnect existe un retry acotado contra la revisión actual informada por Backend.

## Test real de autosave

Baseline:

```text
Revision 2
Position: (-2.420902, 0, 1.101203)
MP: 182
```

Gameplay:

```text
Position → (1.086995, 0, 5.266978)
Heal
MP → 142
```

Sin salir del juego:

```text
Checkpoint iniciado
Reason: autosave
Revision esperada: 2
HP: 100000
MP: 142

Checkpoint confirmado
Revision: 2 → 3
```

MySQL confirmó:

```text
position_x = 1.0869946479797
position_y = 0
position_z = 5.2669777870178
rotation_y = -2.4417133449578
hp = 100000
mp = 142
revision = 3
```

## Test real de crash del Game Server

Se realizó posteriormente una prueba explícita de hard-stop.

Autosave confirmado:

```text
Movement:
(-0.363776, 0, 1.591599)

Autosave:
Revision 5 → 6
```

Después del autosave:

```text
movimiento nuevo:
(-5.691637, 0, -1.650471)
```

Antes de otro autosave se finalizó abruptamente el proceso del Game Server:

```text
--- Debugging process stopped ---
```

No hubo disconnect checkpoint porque el proceso servidor murió.

Al reiniciar:

```text
Runtime revision: 6
Position: (-0.363776, 0, 1.591599)
HP: 100000/100000
MP: 142/350
```

La posición posterior no guardada:

```text
(-5.691637, 0, -1.650471)
```

no apareció después del restart.

Esto prueba correctamente:

```text
último autosave confirmado
→ durable

cambios posteriores al autosave
→ pueden perderse ante crash abrupto
```

Ese es el comportamiento esperado.

Con la política actual, la ventana de pérdida aproximada de runtime ante crash queda acotada al tiempo desde el último autosave.

Checkpoint:

```text
2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

---

# 12. CICLO DURABLE REAL DESPUÉS DE F20

Ahora VHAL posee:

```text
MySQL
↓
Login
↓
Game Session Ticket
↓
Game Server
↓
Durable Runtime Restore
↓
Gameplay Runtime
↓
Movement / Vitals
↓
Periodic Autosave
↓
MySQL
↓
Disconnect
↓
Final Checkpoint
↓
MySQL
↓
Login
↓
Exact Durable Reconstruction
```

Y ante crash:

```text
Gameplay
↓
último autosave confirmado
↓
Game Server crash
↓
restart
↓
restore último autosave
```

---

# 13. ESTADO DURABLE ACTUAL DEL PERSONAJE

Al cierre F20 existe persistencia durable real de:

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
```

Separación:

```text
Inventory / Equipment / Vault
→ persistent item/container domain

Level / EXP
→ Character Progression domain

Map / Position / Rotation / HP / MP
→ Character Runtime State domain
```

No fusionar estos dominios sólo porque pertenecen al mismo personaje.

---

# 14. ESTADO DELIBERADAMENTE RUNTIME-ONLY

Todavía NO es durable tras restart completo del Game Server:

```text
WorldDrops no recogidos
mob runtime actual
mob HP actual
cooldowns activos
combat temporal
NPC service activo
movement path activo
runtime request IDs
```

Por ejemplo:

```text
WorldDrop no recogido
→ reaparece tras reconnect mientras GS sigue vivo
→ NO reaparece tras restart del GS
```

Esto continúa siendo una limitación deliberada, no un bug de F20.

---

# 15. GAME SERVER — COMPONENTES NUEVOS DE F20

Estructura relevante:

```text
app/
├── main.gd
├── main.tscn
└── coordinators/
    ├── authentication_coordinator.gd
    ├── character_item_state_coordinator.gd
    ├── character_progression_coordinator.gd
    ├── character_runtime_state_coordinator.gd
    ├── equipment_coordinator.gd
    ├── inventory_coordinator.gd
    ├── vault_coordinator.gd
    ├── item_container_transfer_coordinator.gd
    ├── npc_service_coordinator.gd
    ├── movement_coordinator.gd
    ├── world_presence_coordinator.gd
    ├── world_drop_coordinator.gd
    ├── world_drop_pickup_coordinator.gd
    ├── skill_cast_coordinator.gd
    └── basic_attack_coordinator.gd

core/
├── backend/
│   ├── backend_character_runtime_state_repository.gd
│   ├── backend_character_progression_repository.gd
│   ├── backend_character_inventory_repository.gd
│   ├── backend_character_equipment_repository.gd
│   ├── backend_vault_repository.gd
│   └── ...
└── world/
    └── player_world_session.gd
```

## CharacterRuntimeStateCoordinator

Responsabilidad actual:

```text
checkpoint durable de PlayerWorldSession
periodic autosave
change detection
revision tracking
race autosave + disconnect
queued final disconnect snapshot
stale recovery foundation
cleanup tracking por peer
```

No debe convertirse en un persistence manager global para todos los dominios.

## BackendCharacterRuntimeStateRepository

Responsabilidad:

```text
HTTP interno del runtime durable
serialization
response parsing
success/failure signals
```

No contiene gameplay.

## PlayerWorldSession

Ahora compone también:

```text
runtime_revision
runtime bootstrap validity
persistent runtime snapshot helper
```

Regla sigue vigente:

```text
Session almacena/compone estado
Coordinators orquestan
Domain classes validan
Systems ejecutan lógica especializada
```

No convertir `PlayerWorldSession` en God Object.

---

# 16. BACKEND — COMPONENTES NUEVOS DE F20

Conceptualmente:

```text
Character
└── hasOne CharacterRuntimeState
```

Componentes:

```text
app/Models/CharacterRuntimeState.php
app/Application/Runtime/CharacterRuntimeStatePersistence.php
app/Application/Runtime/CharacterRuntimeStatePersistenceException.php
app/Http/Controllers/Api/InternalCharacterRuntimeStateController.php
database/migrations/...create_character_runtime_states_table.php
tests/Feature/InternalCharacterRuntimeStateTest.php
```

El ticket de sesión incluye runtime opcional.

El Backend no decide reglas de movimiento, max HP ni gameplay.

---

# 17. VITALS — REGLA ACTUAL

Game Server es autoridad runtime de:

```text
HP
MP
max HP
max MP
```

Backend persiste solamente:

```text
current HP
current MP
```

Game Server deriva máximos.

Consumidores futuros deben reutilizar el mismo pipeline:

```text
Heal
damage
Health Potion
regen
mob attacks
PvP
death
respawn
```

No crear estados paralelos de HP/MP por feature.

---

# 18. MAPAS / POSICIÓN — REGLA ACTUAL

`test_town` continúa siendo el mapa foundation.

Desde F20:

```text
logout / reconnect
→ conserva map_id
→ conserva position
→ conserva rotation_y
```

Persistencia:

```text
disconnect
→ checkpoint inmediato

sesión activa con cambios
→ autosave ~30–35 s

cada frame
→ NO persistir
```

## Fallbacks todavía pendientes

A futuro deben resolverse explícitamente:

```text
map_id inexistente
map deshabilitado
posición corrupta
posición fuera de NavMesh
map migration
spawn seguro
```

La dirección deseada es:

> un checkpoint inválido nunca debe dejar a un personaje permanentemente incapaz de entrar; debe existir fallback seguro.

No implementar estos fallbacks fuera de un checkpoint específico si todavía no hay necesidad real.

---

# 19. F15-C — SIGUE DIFERIDO

Continúan diferidas hasta necesidad funcional concreta:

```text
stack merge autoritativo
stack split
partial quantity transfer
sort autoritativo
consumibles
durability
item-specific state avanzado
```

Health Potion existe, pero el uso real debe apoyarse en Vitals autoritativos.

Flujo futuro correcto:

```text
use item intent
→ Game Server
→ validate item/quantity
→ apply effect through shared vitals/effects pipeline
→ persist quantity mutation
→ replicate inventory + vitals
```

No aplicar HP desde UI local.

---

# 20. SKILLS — ESTADO ACTUAL DESPUÉS DE F20

Skills foundation existentes:

```text
fire_ball
poison
heal
```

El cliente ya no inventa ownership desde debug.

Actual:

```text
Game Server
→ learned_skill_ids
→ world_snapshot
→ ClientSkillCatalog
→ SkillBook / Hotbar
```

Pero todavía existe bootstrap temporal:

```text
ServerCharacterRuntimeBootstrap
→ concede las tres foundation skills
→ a todos los personajes de desarrollo
```

Por lo tanto:

```text
Skill Runtime authority           ✅
Skill IDs enviados por GS         ✅
Client no auto-concede            ✅
Skill Ownership durable real      ❌
Skill Learning durable real       ❌
```

Esto es ahora el gap foundation más natural.

---

# 21. DIRECCIÓN CANÓNICA — SKILL OWNERSHIP / LEARNING

No mezclar:

```text
Character Progression
Skill Ownership
Skill Learning
Skill Runtime
```

Son dominios distintos.

## Ownership durable futuro

Backend debe almacenar learned skills por personaje.

Bootstrap esperado:

```text
Backend
→ game session ticket
→ learned skills
→ Game Server
→ ServerSkillRuntimeState
→ world_snapshot
→ Client
```

El cliente nunca envía como hecho consumado:

```text
"aprendí fire_ball"
```

## Learning canónico futuro

Una Skill se aprende mediante:

```text
Skill Scroll / Book
+
class requirement
+
minimum level
+
minimum stats
+
compatible Trainer NPC
→ Game Server validation
→ durable learned skill
```

El Trainer puede servir:

```text
una clase
varias clases
```

No obligar a un NPC por clase.

## Trainer como guía

Deberá poder informar:

```text
skills disponibles para tu clase
scroll requerido
level requerido
stats requeridos
si cumplís o no
mapas donde puede encontrarse el scroll
mobs que pueden dropearlo
```

Esos datos deben provenir de definitions/catalogs/drop content, no de strings duplicados en UI.

## Flujo futuro completo

```text
Mob / content
↓
Drop table
↓
Skill Scroll ItemInstance
↓
Inventory
↓
Trainer
↓
Game Server valida:
  scroll
  class
  level
  stats
  trainer compatibility
  skill not learned
↓
Backend durable ownership
↓
si corresponde consumir scroll
↓
ServerSkillRuntimeState
↓
Client SkillBook
```

El detalle `scroll se consume o no` todavía puede decidirse cuando se diseñe el sistema real.

---

# 22. ECONOMÍA — DIRECCIÓN CANÓNICA

Regla explícita:

```text
NO usar "Zen" como nombre final.
```

Nombre/lore de moneda VHAL todavía pendiente.

El modelo genérico técnico `CurrencyState` puede existir mientras se decide identidad final.

La economía futura deberá soportar:

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

No mezclar economía con F21-A.

---

# 23. PvP / PK / SIN — DIRECCIÓN CANÓNICA

Estados previstos:

```text
Inocente
→ Diablillo
→ Delincuente
→ Pecador / Sinner
```

Thresholds/balance todavía no fijados.

## Auto-defense

Dirección:

```text
A ataca primero a B
→ Game Server registra agresión
→ B obtiene contexto temporal de auto-defense
→ B puede defenderse/matar A sin penalización PK válido
```

Auto-defense es runtime del Game Server.

## Pecador

Dirección:

```text
otros jugadores pueden atacarlo sin penalización
```

Representación visual futura:

```text
body
armor
weapon
wings
main appearance
→ tint rojo según criminal state autoritativo
```

## Redención

Sacerdote/Priest:

```text
confession
→ costo en currency
→ costo escala con severidad / kills / sin points
```

Alternativa gratuita/lenta:

```text
matar mobs PvE válidos
→ reducir pecado progresivamente
```

Estado criminal durable:

```text
Backend
```

agresión/auto-defense temporal:

```text
Game Server
```

PvP debe construirse sobre Combat, no meter todo dentro de `BasicAttackCoordinator`.

No mezclar PvP con F21-A.

---

# 24. WORLD DROPS — LIMITACIÓN ACTUAL ACEPTADA

WorldDrop actual:

```text
runtime autoritativo Game Server
persistent item UID interno para grant
roster same-map
pickup durable
```

Pero:

```text
restart Game Server
→ drops runtime desaparecen
```

Esto continúa aceptado.

No convertir WorldDrop a DB sólo por anticipación.

Reevaluar cuando exista una necesidad concreta:

```text
long-lived loot
server restart preservation
multi-server ownership
loot ownership timers
world persistence
```

---

# 25. COMBAT — LÍMITES ACTUALES

Basic Attack ya es real:

```text
unarmed
→ 500 foundation damage
→ range 1.5
→ cooldown 1.0

bronze_sword melee
→ 1000 foundation damage
→ range 2.0
→ cooldown 0.9
```

Training Goblin foundation:

```text
HP 5000
EXP reward 50
Health Potion x1
100% drop para testing
respawn 3 s
```

Fire Ball / Poison todavía no deben expandirse por inercia dentro de F21-A.

Dirección:

```text
Fire Ball
→ entity target
→ damage pipeline compartido

Poison
→ status effect runtime
→ duration/ticks/stack policy
```

No crear damage separado fuera de `WorldMobRegistry.apply_damage_to_mob()` / pipeline autoritativo equivalente.

---

# 26. UI — REGLAS QUE CONTINÚAN VIGENTES

Ventanas como Inventory/Vault/Skills:

```text
tamaño fijo
draggable
no resize
no salir del viewport
```

Inventario:

```text
compacto
MU-like footprint
celdas/gaps pequeños
Equipment compacto
```

No volver al plan viejo de resize/expand/contract de ventanas.

La UI final debe tener identidad propia VHAL, no copiar visualmente MU.

---

# 27. PERFORMANCE — REGLA ACTUAL

```text
Refactor ≠ Optimization
```

No optimizar prematuramente sin medición.

F20 ya evita una mala práctica crítica:

```text
NO guardar posición por frame
```

Usa:

```text
runtime in-memory
+
checkpoint periódico
```

Cuando llegue PERF-1:

```text
measure
→ bottleneck
→ change one thing
→ measure again
```

Posibles métricas:

```text
Client → GS RTT
GS validation time
GS → Backend RTT
Laravel time
DB transaction time
serialization
packet sizes
HTTP checkpoint rate
concurrent autosave distribution
```

---

# 28. ROADMAP RESUMIDO ACTUAL

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

POST-F20
F21-A Durable Skill Ownership   ⏳ recomendado siguiente
Skill Scroll + Trainers         ⏳ evolución posterior
Economy / VHAL currency         ⏳ futuro
PvP / PK / Sin system           ⏳ futuro
World/content expansion         ⏳ futuro
Merchant                        ⏳ futuro
Stats completos                 ⏳ futuro

PERF-1                          ⏳ después de base estable
```

No abrir varios bloques post-F20 simultáneamente.

---

# 29. F21-A — SIGUIENTE CHECKPOINT RECOMENDADO

Nombre:

```text
F21-A — Durable Skill Ownership Foundation
```

Objetivo:

> Retirar el bootstrap temporal que concede las tres skills a todos y reemplazarlo por ownership durable por personaje.

## Scope inicial recomendado

Backend:

```text
persistir learned skill IDs por Character
exponerlos al bootstrap/ticket
operación durable preparada para learning futuro
```

Game Server:

```text
leer ownership real del ticket
reconstruir ServerSkillRuntimeState
NO auto-conceder todas las skills
validar skill IDs contra ServerSkillCatalog
```

Client:

```text
continuar recibiendo learned_skill_ids
representar exactamente ownership autoritativo
```

No hace falta cambiar UI si el contrato actual ya lo soporta.

## Criterio de éxito de F21-A

Debe demostrar:

```text
1. Character A tiene ownership durable concreto;
2. login entrega esas learned skills;
3. Game Server reconstruye ServerSkillRuntimeState;
4. no existen skills concedidas fuera del ownership;
5. cliente muestra SkillBook/Hotbar coherente;
6. logout/login conserva exactamente ownership;
7. Character B puede tener ownership distinto;
8. skill inexistente/corrupta no se convierte en autoridad válida;
9. Level/EXP/Inventory/Equipment/Runtime F20 no sufren regresión;
10. 0 warnings/errors.
```

## Fuera de scope F21-A

No mezclar todavía:

```text
Scroll consumption
Trainer UI
Trainer NPC completo
class requirement final
stats requirement final
Economy
PvP
Fire Ball damage
Poison status runtime
Merchant
más mapas
```

Después de ownership durable se podrá diseñar el flujo de learning real con una base correcta.

---

# 30. CRITERIO DE “REAL” — SIGUE VIGENTE

Un sistema se considera real cuando:

```text
la intención nace donde corresponde
la autoridad está definida
Game Server valida gameplay
runtime muta correctamente
persistencia ocurre donde corresponde
resultado vuelve al cliente
reconnect/recovery funciona cuando aplica
edge cases principales están probados
no depende de shortcut debug en flujo normal
```

F20 cumple este criterio para el Character Runtime durable.

---

# 31. ESTADO FUNCIONAL CANÓNICO AL CIERRE F20

Vertical slice durable actual:

```text
Login
→ Character Select
→ Game Session Ticket
→ Game Server
→ Durable Character Runtime Restore
→ World
→ Movement
→ Warehouse
→ Inventory / Vault / Equipment
→ Skill
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
→ Login
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
```

Autoritativo runtime pero todavía no durable real:

```text
Skill Ownership
WorldDrops tras restart GS
mob runtime tras restart
cooldowns activos
combat temporal
NPC service temporal
```

---

# 32. PRUEBAS CLAVE DE F20 — RESUMEN

Backend:

```text
InternalCharacterRuntimeStateTest
5 passed / 63 assertions

InternalCharacterProgressionTest
5 passed / 23 assertions
```

Restore B1:

```text
Revision 1
Position (1,0,1)
HP 87654
MP 222
→ cliente y GS exactos
```

Disconnect B2:

```text
movement + Heal
→ Position (-2.420902,0,1.101203)
→ HP 100000
→ MP 182
→ Revision 1 → 2
→ reconnect exacto
```

Autosave C:

```text
sin disconnect
→ Position (1.086995,0,5.266978)
→ MP 142
→ Revision 2 → 3
→ MySQL confirmado
```

Crash recovery C:

```text
Autosave Revision 5 → 6
Position guardada (-0.363776,0,1.591599)
↓
movimiento posterior (-5.691637,0,-1.650471)
↓
Game Server hard-stop
↓
restart
↓
Revision 6
Position (-0.363776,0,1.591599)
```

Comportamiento correcto.

---

# 33. CHECKPOINTS F20

Backend:

```text
55d69f7b63e853c2aa66b49570bd490d358aa9ca
feat: add durable character runtime persistence
```

Game Server — restore:

```text
f329f4fe854a416fd684322567951ee023f14606
feat: restore durable character runtime
```

Game Server — disconnect:

```text
fe41377ba59c38d4c19e40388bb937799163a450
feat: persist character runtime on disconnect
```

Game Server — autosave:

```text
2623eb60985b0af6070d137bda086c9c53dae1c4
feat: add periodic character runtime autosave
```

---

# 34. REGLAS PARA CONTINUAR DESDE ESTE VOLUMEN

Al retomar VHAL:

```text
1. leer PROJECT_MEMORY.md;
2. leer PROJECT_MEMORY_2.md;
3. revisar GitHub dev real;
4. confirmar SHAs/baselines;
5. identificar etapa activa;
6. continuar sólo esa etapa;
7. test;
8. corregir warnings/errors;
9. git status;
10. commit;
11. push;
12. esperar "pusheado".
```

No asumir que un bloque futuro ya fue implementado sólo porque está descrito como dirección.

Distinguir siempre:

```text
IMPLEMENTADO
VALIDADO
FUTURO / DIRECCIÓN
```

---

# 35. PRÓXIMO PASO EXACTO

El código de F20 ya está committeado y pusheado.

Antes de abrir F21-A falta cerrar la memoria canónica de F20.

Paso actual:

```text
agregar PROJECT_MEMORY_2.md al repo cliente/canónico
↓
git status
↓
verificar que el único cambio documental esperado sea este archivo
↓
commit
↓
push
↓
esperar "pusheado"
↓
verificar remoto
↓
recién entonces abrir F21-A
```

Commit documental sugerido:

```text
docs: add project memory volume 2 and close F20
```

**NO abrir F21-A antes de confirmar este checkpoint documental.**

---

# 36. POLÍTICA PARA FUTUROS VOLÚMENES

Cuando `PROJECT_MEMORY_2.md` crezca demasiado:

crear:

```text
PROJECT_MEMORY_3.md
```

El nuevo volumen debe comenzar con:

```text
qué volúmenes lo preceden
qué etapa inicia/cierra
baselines actuales
regla de precedencia
roadmap actual
```

No copiar miles de líneas históricas sin necesidad.

Objetivo de cada volumen nuevo:

```text
preservar historia
+
mantener continuidad suficiente
+
evitar un archivo monolítico inmanejable
```

Regla final:

> **Los volúmenes anteriores conservan la historia; el volumen más reciente conserva la verdad operativa actual.**

---

# 37. ESTADO FINAL DE ESTE VOLUMEN

Etapa funcionalmente cerrada más reciente:

```text
F20 — Durable Character Runtime             ✅
├── F20-A  Durable Runtime Backend          ✅
├── F20-B1 Restore Durable Runtime          ✅
├── F20-B2 Disconnect Checkpoint            ✅
└── F20-C  Periodic Autosave / Crash        ✅
```

Siguiente etapa recomendada, todavía NO abierta:

```text
F21-A — Durable Skill Ownership Foundation  ⏳
```

---
