# VHAL — PROJECT MEMORY

Última actualización: 2026-08-21

## 1. Propósito

VHAL es un proyecto MMORPG desarrollado con una arquitectura server-authoritative.

El proyecto se divide actualmente en tres repositorios:

- Client:
  https://github.com/schmidtoctavio/vhal

- Game Server:
  https://github.com/schmidtoctavio/vhal_game_server

- Backend:
  https://github.com/schmidtoctavio/vhal_backend

Rama activa de desarrollo:

- `dev`

Principio arquitectónico principal:

> Scalability, maintainability, consistency, and clear responsibilities before speed of implementation.

El cliente expresa intención y representa estado.

El Game Server es la autoridad de gameplay.

Laravel administra identidad, API y persistencia durable.

MySQL conserva el estado persistente.

---

# 2. Arquitectura actual

```text
Godot Client
    |
    | ENet
    v
Godot Game Server
    |
    | HTTP interno
    v
Laravel Backend
    |
    v
MySQL
```

## Client

Responsabilidades:

- UI.
- Input.
- presentación del estado.
- intención del jugador.
- networking ENet.
- reconstrucción de snapshots autoritativos.
- estado runtime local derivado de snapshots.

El cliente no decide el resultado definitivo de una mutación persistente.

## Game Server

Responsabilidades:

- autoridad de gameplay.
- validación de dominio.
- sesiones activas.
- movimiento.
- presencia de mundo.
- servicios NPC.
- Inventory.
- Vault.
- Equipment.
- coordinación con persistencia.
- envío de snapshots autoritativos.

## Backend

Responsabilidades:

- autenticación.
- cuentas.
- personajes.
- tickets de sesión.
- persistencia.
- operaciones transaccionales.
- validaciones persistentes.
- protección contra stale state.

---

# 3. Estado funcional actual

Actualmente están operativos de punta a punta:

## Authentication

- login.
- selección de personaje.
- creación de personaje.
- ticket de entrada al Game Server.
- rechazo de sesiones inválidas.
- conexión ENet autenticada.

## World

- entrada al mundo.
- snapshot autoritativo.
- presencia de jugadores.
- movimiento server-authoritative.
- navegación.
- sincronización de posición.

Mapa de prueba actual:

- `test_town`

## NPC

Existe infraestructura de NPC autoritativa.

NPC funcional actual:

- `warehouse_keeper`

Servicio:

- `warehouse`

El Game Server valida:

- NPC.
- servicio.
- rango.
- sesión.
- apertura y cierre del servicio.

## Inventory

Inventory es persistente y server-authoritative.

Soporta:

- grid 8x8.
- items multicelda.
- stacking.
- movimiento.
- validación de colisiones.
- validación de límites.
- snapshots persistentes.
- UID estable.

## Vault

Vault es persistente y compartida por cuenta.

Soporta:

- grid 8x16.
- movimiento interno.
- Inventory → Vault.
- Vault → Inventory.
- persistencia.
- snapshots autoritativos.

Vault sólo puede manipularse durante una sesión Warehouse válida.

## Equipment

Equipment es persistente y server-authoritative.

Soporta:

- Inventory → Equipment.
- Equipment → Inventory.
- persistencia.
- relogin.
- snapshots autoritativos.
- validación de slots.
- validación semántica de equipamiento.
- prevención de UID duplicado.
- recuperación ante stale state.
- serialización de mutaciones concurrentes.

---

# 4. Equipment — contrato estable

Los slots usan IDs semánticos estables.

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

No se deben persistir:

- enum ordinals.
- índices visuales.
- NodePaths.
- rutas de recursos Godot.

Los IDs persistentes/network deben ser semánticos y estables.

---

# 5. Hand modes

Los modos actuales son:

```text
none
main_hand_only
one_hand
two_hand
off_hand_only
```

## TWO_HAND

Contrato:

- se almacena una sola instancia.
- se persiste en `main_hand`.
- `off_hand` queda reservado de manera derivada.
- nunca se duplica el UID para ocupar ambas manos.

Actualmente el contrato de dominio para TWO_HAND está cubierto por self-test.

Todavía no existe un item real TWO_HAND en `ServerItemCatalog`.

Cuando se agregue el primer item real TWO_HAND se debe agregar también un test end-to-end de snapshot con reserva real de `off_hand`.

---

# 6. Items reales actuales

Game Server `ServerItemCatalog`:

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

# 7. UID contract

Cada item posee un UID estable.

Mover un item entre:

```text
Inventory
Vault
Equipment
```

NO debe:

- eliminar la fila.
- recrear la fila.
- generar otro UID.

Debe modificarse la misma instancia persistente.

Contrato:

```text
same item
→ same database row
→ same UID
```

La integridad de UID fue validada durante F15-B6.

---

# 8. F15 — Inventory / Vault / Equipment

## F15-A — Inventory ↔ Vault

Estado:

```text
COMPLETE
```

Implementado:

- backend transaccional.
- repository Game Server.
- validadores.
- protocolo ENet.
- cliente.
- drag & drop.
- sincronización mediante snapshots.
- recuperación persistente.

## F15-B — Equipment

Estado:

```text
COMPLETE
```

### B1

Stable Equipment Slot Contract.

### B1R

Semantic slot identity + hand rules.

### B2

Backend persistent Equipment.

### B3A

Authoritative Equipment snapshot.

### B3B1

Equipment transfer validator + self-test.

### B3B2

Persistence flow and authoritative reload.

### B4A

Game Server ENet Equipment protocol.

### B4B

Client ENet Equipment protocol.

### B5A

Equipment Snapshot → PlayerRuntimeState → UI.

### B5B

Authoritative Inventory ↔ Equipment drag & drop.

### B6

Integrity and edge cases.

Validado:

- incompatible slot.
- occupied slot.
- stale Inventory position.
- stale Equipment slot.
- occupied Inventory destination.
- multicell collision.
- grid bounds.
- account mismatch.
- character mismatch.
- UID uniqueness.
- rejected operation recovery.
- relogin persistence.
- concurrency protection.
- same UID across container transfers.

### B7

Final regression and closure.

Smoke final validado:

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

# 9. Integridad de Equipment validada

Durante F15-B6 se comprobó deliberadamente stale state.

Ejemplo:

```text
Client/Game Server:
Bronze Sword at old Inventory position

MySQL:
Bronze Sword manually changed to another position
```

Resultado:

```text
Equip request
→ Game Server accepts runtime intention
→ Laravel detects stale persistent state
→ HTTP 409
→ Game Server reloads Inventory + Equipment
→ Client applies authoritative snapshots
→ pending operation clears
→ next valid operation succeeds
```

Esto confirma recuperación autoritativa sin necesidad de reiniciar la sesión.

---

# 10. Serialización de mutaciones

Las mutaciones de items del cliente se serializan.

Mientras exista cualquiera de estas operaciones pendiente:

```text
Inventory move
Vault move
Inventory ↔ Vault
Inventory ↔ Equipment
```

no puede comenzar otra mutación de items.

La regla está centralizada en:

```text
GameServerClient._has_item_mutation_pending()
```

y evita condiciones de carrera entre snapshots y respuestas persistentes.

---

# 11. Estado persistente validado

Se verificó:

```text
Equip
→ logout
→ login
→ item sigue equipado
```

y:

```text
Unequip
→ logout
→ login
→ item sigue en Inventory
```

También se verificó:

```text
Inventory
→ Equipment
→ Inventory
```

manteniendo exactamente el mismo UID.

No se detectaron UIDs duplicados en `item_instances`.

---

# 12. Equipment self-tests del Game Server

Al iniciar Game Server deben ejecutarse correctamente:

```text
ServerMain | Equipment Domain Contract validado.
ServerMain | Equipment Snapshot Contract validado.
ServerMain | Equipment Transfer Contract validado.
```

Si cualquiera falla, el servidor no debe continuar normalmente.

Estos contratos cubren reglas de dominio, estructura de snapshots e integridad de transferencias.

---

# 13. UI actual

La UI utiliza componentes reutilizables.

Entre ellos:

- BaseWindow.
- InventoryGrid.
- InventoryItemView.
- InventoryWindow.
- EquipmentPanel.
- EquipmentSlot.
- Vault.
- StatBar.
- SkillSlot.
- HudActionButton.
- ItemTooltip.

Las ventanas principales:

- tienen tamaño fijo.
- pueden moverse.
- deben mantenerse dentro del viewport.
- no son redimensionables.

Inventory mantiene una intención visual compacta tipo MU Online.

---

# 14. Estado del networking

Transporte actual:

```text
ENet
```

Modelo:

```text
Client intention
→ Game Server validation
→ persistence when required
→ authoritative snapshot
→ Client convergence
```

Actualmente las operaciones persistentes pueden tardar aproximadamente alrededor de un segundo.

Esto se acepta en esta fase para priorizar corrección.

No se realizará optimización agresiva antes de tener suficiente gameplay integrado y métricas reales.

---

# 15. Refactor arquitectónico pendiente

El siguiente bloque formal es:

```text
F15-R
```

Debe ejecutarse ANTES de Skills/Combat.

Objetivo:

reducir responsabilidades excesivas de archivos centrales sin cambiar comportamiento funcional.

Archivos principales a revisar:

## Game Server

```text
app/main.gd
```

Actualmente concentra demasiada orquestación.

Debe evolucionar hacia composition root / high-level lifecycle.

Extracciones previstas, una por una:

- CharacterItemStateCoordinator.
- EquipmentCoordinator.
- InventoryCoordinator.
- VaultCoordinator.
- ItemContainerTransferCoordinator.
- NpcServiceCoordinator.
- MovementCoordinator.
- WorldPresenceCoordinator.
- AuthenticationCoordinator.

Los nombres exactos pueden ajustarse según dependencias reales.

## Client

```text
features/gameplay/networking/game_server_client.gd
```

Debe conservar UNA conexión ENet pero separar protocolos/responsabilidades internas.

Áreas:

- World.
- Movement.
- Presence.
- NPC.
- Inventory.
- Vault.
- Equipment.
- posteriormente Skills/Combat.

También debe revisarse:

```text
app/main.gd
```

para separar flujos de aplicación y gameplay.

---

# 16. Reglas del refactor F15-R

El refactor NO debe modificar gameplay.

Proceso obligatorio:

```text
extract
→ test
→ commit/push
→ next extraction
```

No mezclar en un mismo checkpoint:

- nuevas features.
- cambios de protocolo.
- migraciones DB.
- nuevas reglas de gameplay.
- optimizaciones.

Objetivo:

```text
same behavior
better structure
```

---

# 17. Performance

Refactor y optimización son fases diferentes.

No hacer optimización agresiva durante F15-R.

## PERF-0

Se pueden agregar mediciones:

- Client → Game Server RTT.
- Game Server validation time.
- Game Server → Backend RTT.
- Laravel controller time.
- DB transaction time.
- snapshot reload time.
- serialization cost.
- packet size/frequency.

## PERF-1

La optimización estructural fuerte se abre después de que F19 Vertical Slice sea estable, salvo que profiling encuentre antes un blocker real.

Posibles futuras optimizaciones:

- revisions por container.
- deltas.
- menos reloads completos.
- runtime-first authority donde corresponda.
- batching.
- connection reuse.
- interest management.
- binary protocol si profiling lo justifica.

Regla:

```text
measure
→ identify bottleneck
→ change one thing
→ measure again
```

---

# 18. Skills y Combat

Skills/Combat NO deben copiar el flujo persistente de Inventory/Equipment para cada acción.

No se debe hacer:

```text
cast
→ Laravel
→ MySQL
→ wait
→ damage
```

Para combate:

```text
Client intention
→ Game Server runtime authority
→ immediate gameplay result
```

La persistencia tendrá una política distinta.

No se debe esperar Laravel/MySQL para cada hit o cast.

---

# 19. Próximo roadmap

Orden acordado:

```text
F15-B COMPLETE
↓
F15-R Architectural Refactor
↓
F15-C only if strictly necessary
↓
F16 Skills / Cast
↓
F17 Mob / Combat
↓
F18 Drop / Pickup / EXP / Level
↓
F19 Vertical Slice
↓
PERF-1 profiling + measured optimization
```

---

# 20. Git checkpoints funcionales

## Client

Último checkpoint funcional previo al cierre documental:

```text
7921e91c5f50a90cd128b6c676b1b64c38ed2d40
fix: serialize authoritative item mutations
```

Checkpoint documental de cierre F15-B:

```text
6dcd698c9e6c544a043952d3a3ce42357fd6761c
docs: add canonical project memory checkpoint
```

## Game Server

```text
13c225a5fd0c18d8143064a156fcc79fed1add57
test: add equipment snapshot integrity contract
```

## Backend

```text
5e875cae0ac403fafb9fc9d92ce4a165c82d2243
foundation: add persistent character equipment backend
```

---

# 21. Workflow obligatorio

Cada etapa de VHAL sigue:

```text
stage
→ test
→ commit
→ push
→ next stage
```

Si aparecen:

- parser errors.
- warnings relevantes.
- errores runtime.
- regresiones.
- contratos fallidos.

se corrigen ANTES de avanzar.

No acumular varias etapas sin checkpoint.

Después de cada push se confirma el checkpoint antes de avanzar a la siguiente etapa.

---

# 22. Estado actual

```text
F15-A Inventory/Vault       COMPLETE
F15-B Equipment             COMPLETE
F15-B6 Integrity            COMPLETE
F15-B7 Regression           COMPLETE

F15-R Architectural Refactor IN PROGRESS
```

VHAL tiene actualmente Inventory, Vault y Equipment persistentes y server-authoritative end-to-end.

El siguiente objetivo no es agregar gameplay nuevo.

El siguiente objetivo es reorganizar la arquitectura existente para poder escalar Skills, Combat, mobs, drops y futuras features sin convertir los archivos centrales en monolitos.

---

# 23. F15-R0 — Architectural Refactor Baseline

Estado:

```text
COMPLETE
```

F15-R comienza después del cierre completo de F15-B.

El objetivo de F15-R es reorganizar responsabilidades sin cambiar comportamiento funcional.

No es una fase de optimización.

No se modifican durante este refactor:

- reglas de gameplay.
- contratos persistentes.
- esquema de base de datos.
- protocolo observable Client ↔ Game Server.
- autoridad del Game Server.
- comportamiento funcional existente.

## 23.1 Hotspots actuales

Los principales archivos monolíticos actuales son:

### Game Server

```text
app/main.gd
~73 KB
```

Actualmente concentra:

- composition root.
- startup validation.
- authentication orchestration.
- world-session lifecycle.
- world presence.
- movement orchestration.
- NPC service orchestration.
- Inventory persistence orchestration.
- Vault persistence orchestration.
- Inventory ↔ Vault transfer orchestration.
- Equipment persistence orchestration.
- backend repository callbacks.
- authoritative snapshot send/reload/resync.

### Client networking

```text
features/gameplay/networking/game_server_client.gd
~56 KB
```

Actualmente concentra:

- ENet transport.
- authentication.
- packet parsing/routing.
- protocol constants.
- world protocol.
- movement protocol.
- presence protocol.
- NPC protocol.
- Inventory protocol.
- Vault protocol.
- Equipment protocol.
- request IDs.
- pending mutation state.
- snapshot synchronization state.

Debe conservar una única conexión ENet durante el refactor.

### Client application

```text
app/main.gd
~45 KB
```

Actualmente concentra:

- screen navigation.
- login flow.
- character flow.
- session-ticket flow.
- Game Server lifecycle.
- loading gate.
- World + Inventory + Equipment initial snapshots.
- gameplay signal forwarding.
- authoritative snapshot application.
- NPC/Vault flow.
- Inventory flow.
- Equipment flow.

## 23.2 Regla estructural

ServerMain debe evolucionar hacia:

```text
composition root
+
startup/lifecycle
+
high-level coordination
```

No debe seguir creciendo como implementación concreta de cada feature.

No se creará un único Manager global.

Se usarán coordinadores especializados con responsabilidades explícitas.

## 23.3 Composición

El Game Server ya utiliza composición explícita mediante nodos en:

```text
app/main.tscn
```

Los nuevos coordinadores seguirán ese patrón.

ServerMain resolverá y configurará las dependencias.

Los coordinadores no buscarán dependencias globales ocultas.

## 23.4 Dependencia compartida Inventory / Equipment

Inventory y Equipment comparten actualmente operaciones autoritativas de estado:

```text
Inventory snapshot
Equipment snapshot
reload Inventory + Equipment
resend Inventory + Equipment
stale-state recovery
```

Por este motivo el primer extraction checkpoint no será Equipment directamente.

Primero se extraerá una responsabilidad compartida:

```text
CharacterItemStateCoordinator
```

Su función será administrar exclusivamente el estado/sincronización autoritativa de Inventory + Equipment del personaje.

No contendrá reglas de Equip.

No contendrá reglas de movimiento de Inventory.

No contendrá reglas de Vault.

## 23.5 Orden del Game Server

Orden previsto:

```text
R1  CharacterItemStateCoordinator
R2  EquipmentCoordinator
R3  InventoryCoordinator
R4  VaultCoordinator
R5  ItemContainerTransferCoordinator
R6  NpcServiceCoordinator
R7  MovementCoordinator
R8  WorldPresenceCoordinator
R9  AuthenticationCoordinator
```

Cada extracción se realizará:

```text
extract
→ run
→ regression test
→ commit
→ push
→ next extraction
```

El orden puede ajustarse únicamente si las dependencias reales encontradas durante una extracción lo justifican.

## 23.6 Client networking

Después del Game Server:

```text
R10 GameServerClient protocol split
```

Se mantiene:

```text
ONE GameServerClient
ONE ENet connection
ONE transport authority
```

Se separarán responsabilidades de protocolo, no conexiones.

Áreas previstas:

- world.
- movement.
- presence.
- NPC.
- Inventory.
- Vault.
- Equipment.

GameServerClient permanecerá como fachada pública/transport owner.

## 23.7 Client application

Después:

```text
R11 app/main.gd application-flow split
```

Se separarán gradualmente:

- authentication/character flow.
- game-session bootstrap.
- gameplay lifecycle.
- authoritative gameplay forwarding.

ScreenRouter continuará siendo responsable de navegación visual.

## 23.8 Final

```text
R12 cleanup + full regression
```

F15-R se considerará terminado únicamente cuando:

- comportamiento previo sea equivalente.
- login siga funcionando.
- character select siga funcionando.
- world bootstrap siga funcionando.
- movement siga funcionando.
- NPC Warehouse siga funcionando.
- Inventory siga funcionando.
- Vault siga funcionando.
- Equipment siga funcionando.
- relogin siga funcionando.
- self-tests sigan pasando.
- no existan warnings/errors nuevos.

Después de F15-R:

```text
F16 Skills / Cast
```