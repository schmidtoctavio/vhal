# VHAL — PROJECT MEMORY 3 / F22 STATS, PROGRESSION & RESETS

**Volumen:** 3  
**Inicio:** 28/08/2026  
**Última actualización canónica:** 30/08/2026  
**Motor Cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  

**Estado general:**

```text
F19 ✅
F20 ✅
F21-A ✅
F21-B ✅

F22-A ✅
F22-B ✅
F22-C ✅
F22-D1 ✅
F22-D2 ✅
F22-D3-A ✅
F22-D3-B ✅
F22-D3-C ✅
F22-D4-A ✅
```

**Siguiente checkpoint real:**

```text
F22-D4-B
Primary Stats UI foundation
```

Todavía NO conectar Primary Stats con damage, HP/MP, Heal, Skills,
Attack Speed, Movement Speed, Equipment modifiers ni Reset.

---

# 0. ORDEN DE LECTURA Y PRECEDENCIA

Orden obligatorio:

```text
1. PROJECT_MEMORY.md
2. PROJECT_MEMORY_2.md
3. PROJECT_MEMORY_3.md
4. futuros volúmenes en orden
5. repositorios reales branch dev
```

Precedencia:

> Este volumen prevalece para F22 y decisiones posteriores si contradice una propuesta anterior de Volumen 1 o 2.

Los repositorios reales en `dev` prevalecen sobre memoria si el código cambió después de esta actualización.

---

# 1. WORKFLOW OBLIGATORIO

Ciclo de trabajo canónico:

```text
ETAPA PEQUEÑA
→ implementación manual y explicada
→ test
→ corregir warnings/errors
→ git diff --check
→ git status
→ revisar scope
→ commit
→ push
→ esperar "pusheado"
→ verificar remoto
→ recién entonces siguiente etapa
```

Reglas:

```text
No avanzar antes de "pusheado".
No mezclar scopes.
Preferir etapas pequeñas.
Testear antes de commit.
Corregir warnings/errors antes de continuar.
Actualizar memoria canónica al cerrar bloques importantes.
```

Objetivo habitual:

```text
0 warnings
0 errors
```

Los `.md` canónicos se entregan SIEMPRE COMPLETOS para reemplazar.

Cuando un volumen se acerque a ~5.000 líneas:

```text
cerrar volumen actual
→ abrir siguiente PROJECT_MEMORY_N.md
```

---

# 2. REPOSITORIOS

```text
Cliente / memoria:
schmidtoctavio/vhal

Game Server:
schmidtoctavio/vhal_game_server

Backend:
schmidtoctavio/vhal_backend
```

Branch habitual:

```text
dev
```

---

# 3. HEADS REMOTOS VERIFICADOS AL 30/08/2026

## Client / memoria

```text
b0b6516e4ec95c21f3232be25bb0ca05f49c8896
feat: apply live primary stat updates
```

Padre:

```text
871bd0675a70ab6836d8594cbb3d694b4f99a76c
feat: add primary stat allocation client protocol
```

Commits relevantes recientes:

```text
5e281b58238c4074d6570ac7cdf7502cf3a70137
feat: consume authoritative primary stats snapshot

312fbebe673fef240507ff4bc46a05150fada89d
docs: close F22 class stats runtime

b619429ab502f658a2f06e1be07e49b256585628
docs: close F22 durable stat backend

91f746733629f9b4544fb40a711a708175e30d43
docs: define F22 stats progression and reset contract
```

## Game Server

```text
8e6d02e304a0743dcdcdf1400f9ad6966e8cc736
feat: connect durable primary stat allocation
```

Commits relevantes:

```text
235379d8e970df764710987553ed33305629eaf7
feat: add backend character stats repository

36417577b46d8f640b88d7b197a66de3a8b477da
feat: add primary stat allocation transport

765e4e560dc419f716db9315b3e535e201e24f67
feat: expose primary stats in world snapshot

7ab3f081f51506e1d68e8b991be516bdbd378e6d
feat: bootstrap authoritative character primary stats

b4544af42da7e4065ab5a96f250c98be867f08dc
feat: add authoritative class stats catalog
```

## Backend

HEAD:

```text
ce0b202561dfee2e412f6edaf4e8df7bd422842e
feat: expose durable character stat allocation
```

F22-B completo:

```text
715d4c00d92c386a5eae7d946df67cb009fe41b7
feat: add durable character stat allocation schema

d27a435b55d41aec28b81a49a52f43a2fbbd5de6
feat: add character stat budget snapshot

9e84c8c76580c72a5f0bcd309e37b23b1c3d9d31
feat: expose durable character stat snapshot

a77506185a97539bb5322a38c630b0137d07317d
feat: add durable character stat allocation persistence

ce0b202561dfee2e412f6edaf4e8df7bd422842e
feat: expose durable character stat allocation
```

Última regresión Backend conocida al cierre F22-B:

```text
60 tests
337 assertions
0 failures
```

---

# 4. ESTADO CERRADO ANTES DE F22

```text
F19 Vertical Slice                  ✅
F20 Durable Character Runtime       ✅
F21-A Durable Skill Ownership       ✅
F21-B Durable Skill Learning        ✅
```

Durable previo a F22:

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

F22 no debe romper estos sistemas.

---

# 5. DECISIÓN GENERAL F22

Sistema:

```text
F22 — Character Stats & Progression
```

Primary Stats foundation:

```text
Strength
Agility
Vitality
Energy
```

Estos sistemas alimentarán más adelante:

```text
Skill requirements
Equipment requirements
damage scaling
HP / MP derivados
builds
level-up points
crit
defenses/resistances
attack speed
movement speed
Resets
PvP balance
```

Pero no se implementan todos a la vez.

---

# 6. ARQUITECTURA AUTORITATIVA

Regla general:

```text
Client
= intención + representación

Game Server
= autoridad runtime/gameplay

Backend Laravel
= identidad + API + operaciones durables

MySQL
= verdad durable
```

Flujo normal:

```text
Client intent
↓
Game Server validate
↓
Backend durable mutation cuando corresponde
↓
Game Server authoritative runtime
↓
Client authoritative representation
```

Backend NO entra en hot loops de gameplay:

```text
NO per-hit
NO per-cast
NO per-attack
NO movement tick
```

---

# 7. PRIMARY STATS — FILOSOFÍA DE BALANCE

Objetivo:

> Crear builds distintas sin que un solo Primary Stat sea simultáneamente la mejor fuente de daño, defensa, crit, velocidad y supervivencia.

Tradeoffs deseados:

```text
más daño
↔ menos supervivencia

más Vitality
↔ menos presupuesto ofensivo

más utility
↔ menos daño puro
```

Un Primary Stat NO debe ser simultáneamente la mejor fuente de:

```text
damage
defense
crit
attack speed
movement speed
survivability
```

---

# 8. STRENGTH

Rol principal:

```text
melee physical power
```

Usos futuros:

```text
Basic Attack melee scaling
Physical melee Skill scaling
requisitos de armas
requisitos de armaduras físicas
builds híbridas futuras
```

Strength NO debe otorgar fuertemente a la vez:

```text
Attack Speed
Movement Speed
Crit Chance
Armor
HP
```

---

# 9. AGILITY

Rol principal:

```text
ranged physical power
```

Usos futuros:

```text
Bow/ranged scaling
ranged Skill scaling
Accuracy
defensa moderada
pequeña contribución controlada a Attack Speed
```

Decisión canónica:

```text
Agility NO aumenta Movement Speed directamente.
```

No convertir AGI simultáneamente en:

```text
damage
+
defense
+
crit
+
huge attack speed
+
movement speed
```

---

# 10. VITALITY

Rol principal:

```text
Max HP
```

Usos futuros:

```text
Max HP fuerte
HP Regeneration pequeña/moderada
posible pequeña contribución a Tenacity
```

No dar además gran Damage Reduction.

Armor/Resistances deben provenir principalmente de Equipment y Secondary Stats.

---

# 11. ENERGY

Rol principal:

```text
Magic Power
```

Usos futuros:

```text
Max MP
Magic Power
Healing Power
MP Regeneration
Magic Skill scaling
Support scaling
DoT/utility scaling cuando corresponda
```

Ejemplos conceptuales:

```text
Fire Ball
→ Energy principal

Heal
→ Energy principal

Poison
→ Energy principal
  + posible Agility secundaria

Warrior physical Skill
→ Strength

Archer physical Skill
→ Agility
```

Coeficientes reales:

```text
TBD
```

---

# 12. STARTING STATS POR CLASE

Foundation:

| Class | STR | AGI | VIT | ENE | Total |
|---|---:|---:|---:|---:|---:|
| Warrior | 25 | 15 | 25 | 10 | 75 |
| Mage | 10 | 15 | 15 | 35 | 75 |
| Archer | 15 | 30 | 15 | 15 | 75 |

Principio:

```text
mismo presupuesto inicial total
distinta identidad
```

IDs canónicos:

```text
warrior
mage
archer
```

Estos valores viven en catálogo autoritativo del Game Server.

NO duplicarlos como base durable individual por Character.

---

# 13. PUNTOS POR LEVEL

Foundation actual:

```text
Warrior = 5
Mage = 5
Archer = 5
```

Concepto:

```text
STAT_POINTS_PER_LEVEL = 5
```

---

# 14. BUDGET DE PRIMARY STATS

Level points:

```text
level_points
=
(level - 1)
*
stat_points_per_level
```

Reset points:

```text
reset_points
=
reset_count
*
350
```

Total:

```text
total_budget
=
level_points
+
reset_points
+
bonus_stat_points
```

Gastado:

```text
spent
=
allocated_strength
+
allocated_agility
+
allocated_vitality
+
allocated_energy
```

Libre:

```text
unspent
=
total_budget
-
spent
```

Invariante:

```text
spent <= total_budget
```

---

# 15. UNSPENT NO ES VERDAD DURABLE

No persistir como fuente primaria:

```text
unspent_stat_points
```

Se deriva desde:

```text
level
reset_count
bonus_stat_points
allocations
```

Esto evita divergencias.

---

# 16. CAPAS DE STATS

Definiciones:

```text
Base
=
Class Starting Stats

Allocated
=
puntos gastados por jugador

Permanent
=
Base
+
Allocated
+
Permanent Bonuses futuros

Variable
=
Equipment
+
Buffs
+
Temporary Effects

Effective
=
Permanent
+
Variable
```

Estado actual F22-D:

```text
Base ✅
Allocated ✅
Permanent ✅

Variable ❌ todavía
Effective real ❌ todavía
```

Actualmente:

```text
Permanent = Base + Allocated
```

---

# 17. REQUIREMENTS

Por defecto, requisitos futuros usan:

```text
Permanent
```

No:

```text
Effective
```

Ejemplo conceptual:

```text
Permanent STR = 150
Sword actual = +20 STR
Effective = 170
Nueva arma requiere 160
```

Resultado:

```text
NO puede equiparla
```

porque el requisito mira `Permanent = 150`.

---

# 18. DERIVED / SECONDARY STATS FUTUROS

Vitals:

```text
Max HP
Max MP
HP Regeneration
MP Regeneration
```

Ofensivos:

```text
Physical Power
Magic Power
Healing Power
Accuracy
Attack Speed
Critical Chance
Critical Damage
Physical Damage Bonus
Magic Damage Bonus
Skill Damage Bonus
```

Defensivos:

```text
Armor
Magic Resistance
Fire Resistance
Cold Resistance
Lightning Resistance
Poison Resistance
Tenacity / Control Resistance
Block Chance futuro
Evasion/Dodge futuro
```

Movilidad:

```text
Movement Speed
```

Estos NO se persisten como verdad durable final.

---

# 19. ATTACK SPEED — DIRECCIÓN FUTURA

Sistema actual pre-derived:

```text
basic_attack_cooldown_seconds
```

Fórmula conceptual futura:

```text
effective_attack_interval
=
base_attack_interval
/
(1 + attack_speed_bonus)
```

Representación preferida:

```text
percentage / basis points
```

Ejemplo interno:

```text
100 bps = 1%
```

Cap conceptual foundation aproximado:

```text
~+50%
```

AGI sólo aportará una parte pequeña/capada.

---

# 20. MOVEMENT SPEED — DIRECCIÓN FUTURA

Foundation actual:

```text
MOVE_SPEED = 4.0
```

Futuro:

```text
effective_move_speed
=
base_move_speed
*
(1 + move_speed_bonus)
```

Primary Stats NO aumentan Movement Speed directamente.

Cap conceptual normal inicial:

```text
≈ +25%
```

Movement Speed debe ser raro/controlado.

---

# 21. CRITICAL CHANCE / DAMAGE — DIRECCIÓN FUTURA

Crit Chance conceptual:

```text
Base ≈ 5%
cap normal ≈ 50%
```

Representación futura sugerida:

```text
critical_chance_bps
```

Crit Damage conceptual:

```text
Base ≈ 150%
cap normal ≈ 250%
```

Estos valores todavía NO son implementación final de balance.

---

# 22. ARMOR / RESISTANCES — DIRECCIÓN FUTURA

Items otorgan ratings planos.

Conversión conceptual:

```text
reduction
=
rating
/
(rating + K)
```

`K` podrá depender de:

```text
level
content tier
PvP profile
```

Nunca permitir llegar fácilmente a 100% reducción.

---

# 23. DAMAGE TAXONOMY FUTURA

School:

```text
physical
magical
```

Element:

```text
none
fire
cold
lightning
poison
```

Ejemplos:

```text
Sword
physical / none

Fire Ball
magical / fire

Poison
magical / poison
```

Pipeline conceptual:

```text
Weapon / Skill Base Power
↓
Primary Stat Scaling
↓
Flat Bonuses
↓
% Bonuses
↓
Critical si aplica
↓
Armor / Magic Resistance
↓
Elemental Resistance
↓
PvP Modifier futuro
↓
Final Damage
```

---

# 24. STATUS EFFECTS / PvP — DIRECCIÓN FUTURA

Separar:

```text
Hard Control
Soft Control
Damage over Time
Debuff
Buff
```

Evitar:

```text
permanent stun
permanent root
permanent silence
```

Conceptos futuros:

```text
Tenacity
Diminishing Returns
duration caps
DoT stack policies
PvP Combat Profile
```

No implementar dentro de F22-D.

---

# 25. MAX LEVEL Y EXP — DECISIÓN CANÓNICA

```text
MAX_LEVEL = 400
```

Curva foundation propuesta:

```text
n = level - 1

XP_TO_NEXT(level)
=
50
+
15*n
+
2*n²
```

Total aproximado 1→400:

```text
43.4 millones EXP
```

Training Goblin permanece temporalmente:

```text
experience_reward = 50
```

F22-E será responsable de progresión EXP real.

---

# 26. RESET SYSTEM — DIRECCIÓN CANÓNICA

Flujo futuro:

```text
Level 400
↓
Reset NPC
↓
requirements
↓
confirm
↓
Game Server context validation
↓
Backend atomic transaction
↓
Level 1
Reset Count +1
Class Spawn
Base Stats
+ Reset budget
```

Durable:

```text
characters.reset_count
default 0
```

Foundation:

```text
RESET_STAT_POINTS = 350
```

Reset points:

```text
reset_points
=
reset_count * 350
```

Reset exitoso futuro:

```text
level → 1
experience → 0
reset_count → +1

allocated_strength → 0
allocated_agility → 0
allocated_vitality → 0
allocated_energy → 0
```

Reset todavía NO está implementado.

---

# 27. RESET + EQUIPMENT / SKILLS / INVENTORY

Equipment inválido post-reset:

```text
unequip
→ Inventory
```

Antes del Reset:

```text
validate inventory capacity
```

Sin espacio:

```text
Reset rejected
```

Skills:

```text
ownership persists
```

Pero:

```text
learned
!=
currently usable
```

Inventory/Vault:

```text
persist
```

excepto costos consumidos.

Vitals futuros:

```text
rederive max
current HP = new max
current MP = new max
```

---

# 28. BONUS POINTS / RESPEC

Durable:

```text
bonus_stat_points
```

Para:

```text
quest
achievement
event
compensation
special progression
```

Reset points NO se guardan ahí.

Respec futuro:

```text
same level
same reset
same total budget
clear allocations
redistribute
```

Allocation normal F22-D es monotónica.

Reset/Respec serán operaciones dedicadas que sí podrán reducir allocations.

---

# 29. F22-B — DURABLE PRIMARY STAT BACKEND ✅

Breakdown cerrado:

```text
F22-B1-A
Schema + Models durables
✅

F22-B1-B1
Stat Snapshot + Budget Invariants
✅

F22-B1-B2
Internal Read Contract + Game Session Ticket
✅

F22-B2-A
Atomic Allocation Persistence
✅

F22-B2-B
Internal Allocation Endpoint
✅

F22-B2-C
Integrated Backend Audit
✅
```

---

# 30. F22-B — SCHEMA

Tabla:

```text
character_stat_allocations
├── character_id PK/FK
├── allocated_strength
├── allocated_agility
├── allocated_vitality
├── allocated_energy
├── bonus_stat_points
├── revision
└── timestamps
```

También:

```text
characters.reset_count
```

Semántica de fila ausente:

```text
revision = 0
allocated = 0
bonus = 0
```

Primera mutation:

```text
revision 0
→ create row
→ revision 1
```

---

# 31. F22-B — SNAPSHOT DURABLE

Backend construye:

```text
revision

progression
├── level
└── reset_count

allocated
├── strength
├── agility
├── vitality
└── energy

bonus_stat_points

budget
├── points_per_level
├── points_per_reset
├── level_points
├── reset_points
├── bonus_points
├── total_points
├── spent_points
└── unspent_points
```

Fail closed:

```text
spent > total
→ stat_budget_exceeded
```

---

# 32. F22-B — INTERNAL READ + TICKET

GET:

```text
/api/internal/accounts/{accountId}/characters/{characterId}/stats
```

Game Session Ticket incluye:

```text
character.reset_count
character.stats
```

Stats durables inválidos:

```text
409
ticket remains unconsumed
```

---

# 33. F22-B — DURABLE PATCH

PATCH:

```text
/api/internal/accounts/{accountId}/characters/{characterId}/stats
```

Payload:

```json
{
  "expected_revision": 1,
  "next": {
	"strength": 11,
	"agility": 0,
	"vitality": 0,
	"energy": 0
  }
}
```

Semántica:

```text
expected_revision
+
final desired allocation
```

NO delta durable tipo:

```text
+1 STR
```

Lock order:

```text
Character
→ Allocation row
```

Soporta:

```text
first allocation
valid next revision
exact retry
stale reject
overspend reject
regression reject
account isolation
```

Retry exacto:

```text
idempotent = true
```

---

# 34. AUDIT BACKEND HISTÓRICO — PRIMERA ALLOCATION REAL

Atilio inicialmente estaba en:

```text
revision 0
allocated 0/0/0/0
```

Durante F22-B se realizó realmente:

```text
STR +10
```

Resultado histórico:

```text
revision 1
allocated STR 10
spent 10
unspent 605
```

Este fue el primer estado durable real.

IMPORTANTE:

> Ese STR10 fue posteriormente incrementado de forma real y válida a STR11 durante F22-D3-C. No volver a STR10.

---

# 35. POWERSHELL CURL QUIRK

Para audits HTTP en Windows PowerShell, evitar JSON inline frágil.

Patrón preferido:

```powershell
$body = @{
	expected_revision = 1
	next = @{
		strength = 11
		agility = 0
		vitality = 0
		energy = 0
	}
} | ConvertTo-Json -Depth 5 -Compress
```

y:

```powershell
$body | curl.exe ... --data-binary "@-"
```

No guardar ni documentar la clave secreta interna.

Header conceptual:

```text
X-VHAL-Game-Server-Key
```

---

# 36. F22-C — CLASS STATS CATALOG + GS RUNTIME ✅

Breakdown:

```text
F22-C1
Server Class Stats Catalog
✅

F22-C2
Character Primary Stat Runtime
+ Ticket Bootstrap
✅

F22-C3
Reconnect + Per-character Isolation Audit
✅
```

No hubo cambios Backend ni Client durante C1-C3.

---

# 37. F22-C1 — SERVER CLASS STATS CATALOG

Commit:

```text
b4544af42da7e4065ab5a96f250c98be867f08dc
feat: add authoritative class stats catalog
```

Archivos foundation:

```text
core/stats/
├── server_class_stats_definition.gd
└── server_class_stats_catalog.gd
```

Definition:

```text
class_id
starting_strength
starting_agility
starting_vitality
starting_energy
stat_points_per_level
```

Validation:

```text
class_id no vacío
no duplicados
definition existente
definition.class_id consistente
starting stat total = 75
stat_points_per_level = 5
```

Unknown class:

```text
fail closed
```

---

# 38. F22-C2 — SERVER CHARACTER PRIMARY STATS RUNTIME

Commit:

```text
7ab3f081f51506e1d68e8b991be516bdbd378e6d
feat: bootstrap authoritative character primary stats
```

Core:

```text
server_primary_stat_budget_rules.gd
server_character_primary_stats_state.gd
server_character_primary_stats_bootstrap.gd
```

Runtime:

```text
class_id
revision
level
reset_count

Base
Allocated
Permanent

stat_points_per_level
stat_points_per_reset
level_points
reset_points
bonus_stat_points
total_points
spent_points
unspent_points
```

`Permanent` actual:

```text
Base + Allocated
```

---

# 39. F22-C — BOOTSTRAP DESDE TICKET

Flujo:

```text
Backend Ticket
↓
BackendTicketValidator
↓
AuthenticationCoordinator
↓
WorldSessionRegistry
↓
PlayerWorldSession
↓
ServerCharacterPrimaryStatsBootstrap
```

No hacer segundo GET Backend durante bootstrap inicial.

Game Server recalcula y valida:

```text
level_points
reset_points
spent_points
total_points
unspent_points
```

No confía ciegamente en números derivados enviados por Laravel.

Fail closed si:

```text
unknown class_id
stats missing/invalid
revision negativa
level inválido
reset_count inválido
progression mismatch
allocated negativo
bonus negativo
budget mismatch
overspend
revision 0 con allocation/bonus
```

---

# 40. PLAYER WORLD SESSION — PRIMARY STATS

`PlayerWorldSession` posee:

```text
reset_count
primary_stats
latest_primary_stat_allocation_request_id
```

`primary_stats` es:

```text
ServerCharacterPrimaryStatsState
```

Primary Stats viven por sesión/personaje.

NO son singleton global.

Audit Atilio/Lyra comprobó aislamiento por Character.

---

# 41. LYRA — BASELINE DURABLE

Lyra:

```text
Character ID 2
Archer
Level 85
EXP 0
Reset 0
```

Durable Primary Stats:

```text
revision 0
allocated STR 0
allocated AGI 0
allocated VIT 0
allocated ENE 0
bonus 0
```

Base/Permanent:

```text
STR 15
AGI 30
VIT 15
ENE 15
```

Budget:

```text
total 420
spent 0
unspent 420
```

No inventar distribución histórica para Lyra.

No copiar Stats de Atilio a Lyra.

---

# 42. F22-D — ESTADO ACTUAL

Objetivo general:

```text
Client Stats
↓
allocation intent
↓
Game Server validation
↓
Backend durable PATCH
↓
authoritative GS Primary Stats runtime
↓
Client authoritative Primary Stats runtime
↓
UI
```

Estado:

```text
F22-D1 ✅
F22-D2 ✅
F22-D3-A ✅
F22-D3-B ✅
F22-D3-C ✅
F22-D4-A ✅
F22-D4-B NEXT
```

---

# 43. F22-D1 — INITIAL PRIMARY STATS SNAPSHOT ✅

Game Server commit:

```text
765e4e560dc419f716db9315b3e535e201e24f67
feat: expose primary stats in world snapshot
```

Client commit:

```text
5e281b58238c4074d6570ac7cdf7502cf3a70137
feat: consume authoritative primary stats snapshot
```

El world snapshot inicial incluye:

```text
primary_stats
```

Client creó/usa:

```text
features/gameplay/model/primary_stats_state.gd
```

`PlayerRuntimeState` aplica:

```text
apply_primary_stats_snapshot(...)
```

Validaciones Client:

```text
revision/progression válidos
Base válido
Allocated válido
Permanent válido
Permanent = Base + Allocated
budget consistente
level coincide con Character
```

Log autoritativo esperado:

```text
PlayerRuntimeState | Primary Stats autoritativos aplicados
```

---

# 44. CLIENT PRIMARY STATS STATE

`PrimaryStatsState` contiene:

```text
revision
level
reset_count

base_strength
base_agility
base_vitality
base_energy

allocated_strength
allocated_agility
allocated_vitality
allocated_energy

permanent_strength
permanent_agility
permanent_vitality
permanent_energy

stat_points_per_level
stat_points_per_reset
level_points
reset_points
bonus_stat_points
total_points
spent_points
unspent_points
```

Signal:

```text
primary_stats_changed(snapshot)
```

Esta signal será útil para UI.

---

# 45. F22-D2 — PRIMARY STAT ALLOCATION TRANSPORT ✅

Game Server commit:

```text
36417577b46d8f640b88d7b197a66de3a8b477da
feat: add primary stat allocation transport
```

Client commit:

```text
871bd0675a70ab6836d8594cbb3d694b4f99a76c
feat: add primary stat allocation client protocol
```

Mensajes:

```text
primary_stat_allocation_request
primary_stat_allocation_result
```

Client API:

```gdscript
send_primary_stat_allocation_request(
	stat_id: String,
	points: int
) -> Error
```

Stats válidos:

```text
strength
agility
vitality
energy
```

Roles:

```text
request_id
→ Client ↔ Game Server ordering/idempotence

revision
→ Game Server ↔ Backend durable optimistic concurrency
```

No confundirlos.

---

# 46. CLIENT PRIMARY STATS PROTOCOL

Archivo:

```text
features/gameplay/networking/protocols/game_server_primary_stats_protocol.gd
```

Responsabilidades:

```text
emitir request_id monotónico
normalizar stat_id
validar points
enviar primary_stat_allocation_request

validar result
validar request/stat/points/reason
validar authoritative primary_stats snapshot
emitir primary_stat_allocation_result_received
```

El Client NO decide:

```text
budget final
revision durable
allocation final durable
```

---

# 47. F22-D3-A — GAME SERVER BACKEND STATS REPOSITORY ✅

Commit:

```text
235379d8e970df764710987553ed33305629eaf7
feat: add backend character stats repository
```

Archivo:

```text
core/backend/backend_character_stats_repository.gd
```

Configuración:

```text
VHAL_BACKEND_URL
default http://127.0.0.1:8080

GAME_SERVER_INTERNAL_KEY
```

PATCH:

```text
/api/internal/accounts/{accountId}/characters/{characterId}/stats
```

Payload:

```json
{
  "expected_revision": 1,
  "next": {
	"strength": 11,
	"agility": 0,
	"vitality": 0,
	"energy": 0
  }
}
```

Repository valida:

```text
HTTP
JSON
account
character
revision
returned allocation
```

Signals:

```text
primary_stats_persisted
primary_stats_persist_failed
```

---

# 48. F22-D3-B — DURABLE ALLOCATION COORDINATOR ✅

Game Server commit:

```text
8e6d02e304a0743dcdcdf1400f9ad6966e8cc736
feat: connect durable primary stat allocation
```

Archivos relevantes:

```text
app/coordinators/primary_stat_allocation_coordinator.gd
app/main.gd
core/backend/backend_character_stats_repository.gd
core/stats/server_character_primary_stats_bootstrap.gd
```

Dependencies:

```text
GameServer
WorldSessionRegistry
BackendCharacterStatsRepository
```

Estado:

```text
pending_by_peer
```

Máximo una durable allocation en vuelo por Peer.

---

# 49. GAME SERVER — REQUEST FLOW DE ALLOCATION

Flujo actual:

```text
1. resolve session
2. primary_stats debe existir y ser válido
3. request_id debe ser monotónico
4. normalizar/validar stat
5. points > 0
6. reject allocation_busy
7. reject si points > unspent
8. expected_revision = runtime revision actual
9. construir next final allocation
10. guardar pending request
11. persistir mediante BackendCharacterStatsRepository
```

IMPORTANTE:

> El Game Server NO responde accepted=true antes de que Backend confirme persistencia.

---

# 50. GAME SERVER — PERSIST SUCCESS

En `primary_stats_persisted`:

```text
verificar pending identity
verificar expected revision
verificar next allocation exacta
verificar misma session account/character
verificar runtime local todavía en expected revision
rebuild authoritative state desde snapshot Backend
asignar session.primary_stats = next_state
recién entonces responder accepted=true reason=ok
```

Esto preserva:

```text
durability before acknowledgement
```

---

# 51. GAME SERVER — REJECTIONS IMPORTANTES

Ejemplos:

```text
stale_request
invalid_stat
invalid_points
allocation_busy
insufficient_points
stale_revision
backend/persistence failure
```

`insufficient_points` se rechaza antes del Backend PATCH.

`stale_revision` puede resincronizar runtime desde el estado durable actual si Backend devuelve snapshot utilizable.

---

# 52. F22-D3-C — END-TO-END DURABLE AUDIT ✅

Audit real dividido en:

```text
F22-D3-C1
real durable mutation
✅

F22-D3-C2
fresh ticket + durable reconnect
✅
```

No quedaron cambios temporales de audit en repos.

---

# 53. F22-D3-C1 — REAL +1 STR

Baseline previo:

```text
Atilio
revision 1
allocated STR 10
Base STR 25
Permanent STR 35
spent 10
total 615
unspent 605
```

Se envió REALMENTE:

```text
strength +1
```

Resultado:

```text
accepted true
reason ok

revision 1 → 2

allocated STR 10 → 11
Base STR 25
Permanent STR 35 → 36

spent 10 → 11
total 615
unspent 605 → 604
```

Otros allocated:

```text
AGI 0
VIT 0
ENE 0
```

Game Server confirmó:

```text
Idempotent: false
```

Esto prueba una mutation durable real, no un retry.

---

# 54. F22-D3-C2 — FRESH TICKET + RECONNECT

Después de destruir la sesión previa:

```text
nuevo ticket
nuevo peer
nueva PlayerWorldSession
```

Game Server reconstruyó desde durable data:

```text
Stats revision: 2

STR B/A/P: 25/11/36
AGI B/A/P: 15/0/15
VIT B/A/P: 25/0/25
ENE B/A/P: 10/0/10

Stat Points: 11/615
Unspent: 604
```

Client recibió:

```text
Stats revision: 2
Unspent: 604
```

y aplicó:

```text
Revision: 2
STR B/A/P: 25/11/36
AGI B/A/P: 15/0/15
VIT B/A/P: 25/0/25
ENE B/A/P: 10/0/10
Points: 11/615
Unspent: 604
```

No hubo:

```text
primary_stat_allocation_request
Persistencia iniciada
Allocation durable confirmada
revision 3
```

Conclusión:

```text
durable reconnect verified
```

---

# 55. BASELINE DURABLE ACTUAL — ATILIO

Este es el baseline canónico actual.

```text
Atilio
Character ID 1
Warrior
Level 124
EXP 50
Reset 0
Runtime revision observado: 18
```

Primary Stats:

```text
revision 2
bonus 0
```

Base:

```text
STR 25
AGI 15
VIT 25
ENE 10
```

Allocated:

```text
STR 11
AGI 0
VIT 0
ENE 0
```

Permanent:

```text
STR 36
AGI 15
VIT 25
ENE 10
```

Budget:

```text
level_points 615
reset_points 0
bonus_points 0

total 615
spent 11
unspent 604
```

REGLA CRÍTICA:

```text
NO revertir Atilio a STR10.
NO bajar revision a 1.
NO gastar otro punto sólo para probar sin necesidad.
```

---

# 56. F22-D4-A — LIVE CLIENT PRIMARY STATS UPDATE ✅

Client commit:

```text
b0b6516e4ec95c21f3232be25bb0ca05f49c8896
feat: apply live primary stat updates
```

Archivo modificado:

```text
app/flows/game_session_flow_coordinator.gd
```

Cambio permanente:

```text
game_server_client.primary_stat_allocation_result_received
↓
GameSessionFlowCoordinator
↓
PlayerRuntimeState.apply_primary_stats_snapshot(...)
↓
PrimaryStatsState
```

Esto cierra el hueco que existía entre:

```text
protocol recibe authoritative result
```

y:

```text
live PlayerRuntimeState realmente actualizado
```

---

# 57. F22-D4-A — HANDLER LIVE

Signal bind permanente:

```text
primary_stat_allocation_result_received
→ _on_primary_stat_allocation_result_received
```

Handler:

```text
obtiene GameplayScreen
verifica player_state
aplica authoritative primary_stats_snapshot
si falla → end_session fail closed
si funciona → runtime vivo queda sincronizado
```

IMPORTANTE:

El snapshot se aplica incluso si:

```text
accepted == false
```

porque un rechazo puede traer el estado autoritativo correcto para resincronización.

No hacer:

```text
if not accepted:
	return
```

antes de aplicar snapshot.

---

# 58. F22-D4-A — AUDIT SEGURO SIN GASTAR STATS

Se usó temporalmente un request imposible:

```text
Atilio unspent = 604
requested strength points = 605
```

Resultado Client:

```text
Accepted: false
Reason: insufficient_points
Revision: 2
STR allocated: 11
Unspent: 604
```

Luego:

```text
PlayerRuntimeState
→ volvió a aplicar authoritative revision 2
```

y:

```text
GameSessionFlowCoordinator
→ Primary Stats autoritativos aplicados en vivo
```

Game Server NO mostró:

```text
Persistencia iniciada
Allocation durable confirmada
```

por lo tanto:

```text
Backend/MySQL no mutaron
Atilio sigue revision 2 / STR11
```

Todo el trigger temporal fue eliminado antes del commit.

---

# 59. CURRENT CLIENT PRIMARY STATS FLOW

Initial login:

```text
new ticket
↓
Game Server PlayerWorldSession
↓
world snapshot.primary_stats
↓
GameServerClient
↓
GameSessionFlowCoordinator
↓
PlayerRuntimeState.apply_primary_stats_snapshot
↓
PrimaryStatsState
```

Live mutation:

```text
UI/player intent futuro
↓
GameServerClient.send_primary_stat_allocation_request
↓
Game Server
↓
Backend durable PATCH
↓
Game Server authoritative runtime update
↓
primary_stat_allocation_result
↓
GameServerClient
↓
GameSessionFlowCoordinator
↓
PlayerRuntimeState.apply_primary_stats_snapshot
↓
PrimaryStatsState
↓
UI refresh futuro
```

---

# 60. QUÉ YA ESTÁ RESUELTO EN F22-D

```text
Initial Primary Stats snapshot ✅
Client PrimaryStatsState ✅
Client world snapshot consumption ✅
Allocation request transport ✅
Allocation result transport ✅
request_id foundation ✅
GS Backend stats repository ✅
GS durable coordinator ✅
Backend optimistic revision ✅
Backend budget enforcement ✅
GS runtime rebuild after persistence ✅
End-to-end real durable mutation ✅
Fresh-ticket reconnect ✅
Live Client runtime application ✅
```

---

# 61. QUÉ FALTA EN F22-D

Principalmente:

```text
Primary Stats UI
allocation controls
available points display
comfortable bulk allocation UX
live UI refresh
visual feedback for rejected/busy requests
```

Todavía no crear:

```text
Respec UI
Reset UI
giant derived character sheet
combat scaling sheet
```

---

# 62. SIGUIENTE ETAPA REAL — F22-D4-B

Siguiente etapa pequeña:

```text
F22-D4-B
Primary Stats UI foundation
```

Objetivo:

```text
mostrar:
Strength
Agility
Vitality
Energy

mostrar Permanent/current foundation
mostrar Available Points
preparar + controls
refrescar desde PrimaryStatsState
```

La UI debe ser representación del runtime.

NO debe guardar verdad independiente.

---

# 63. PRINCIPIOS DE PRIMARY STATS UI

Estilo:

```text
MMORPG clásico
compacto
legible
sin convertirlo en una mega Character Sheet todavía
```

Debe soportar cómodamente:

```text
pocos puntos
decenas de puntos
cientos de puntos
```

Evitar UX donde asignar 300 puntos requiera necesariamente 300 clicks.

Pero implementar bulk allocation en etapas pequeñas y seguras.

---

# 64. SOURCE OF TRUTH DE UI

La UI lee:

```text
PlayerRuntimeState.primary_stats
```

y reacciona a:

```text
PrimaryStatsState.primary_stats_changed
```

La UI NO calcula como verdad primaria:

```text
unspent
Permanent
revision
```

Puede mostrarlos, pero vienen del snapshot autoritativo.

---

# 65. CLIENT INTENT RULE

Cuando exista el botón `+`:

```text
UI click
↓
intent
↓
GameSessionFlowCoordinator / GameServerClient
↓
Game Server
```

No:

```text
UI
→ mutar PrimaryStatsState local optimísticamente
```

No mostrar STR incrementado permanentemente antes de respuesta autoritativa.

---

# 66. CONCURRENCY / BUSY UX

Game Server ya permite:

```text
máximo una durable allocation en vuelo por Peer
```

UI futura debería contemplar:

```text
disable/lock controls while request pending
o
feedback allocation_busy
```

No enviar spam de mutaciones paralelas.

---

# 67. BULK ALLOCATION — DIRECCIÓN

El protocolo ya soporta:

```text
points > 1
```

Por lo tanto UI futura puede soportar, por ejemplo:

```text
+1
+5
+10
+all / custom
```

Pero no implementar todo de golpe.

Primero foundation y binding correcto.

---

# 68. NO CONECTAR TODAVÍA A DAMAGE / VITALS

Durante F22-D:

Asignar STR/AGI/VIT/ENE debe:

```text
persistir
actualizar GS runtime
actualizar Client runtime
actualizar UI
```

Pero todavía NO modificar:

```text
Basic Attack damage
Max HP
Max MP
current HP/MP
Heal
Fire Ball
Poison
Armor
Resistances
Crit
Attack Speed
Movement Speed
Equipment modifiers
Skill requirements
```

Eso llega en fases F22-F+.

---

# 69. FOUNDATIONS EXISTENTES A NO ROMPER

Vitals actuales:

```text
DEFAULT_MAX_HP = 100000
DEFAULT_MAX_MP = 350
```

Atilio observado:

```text
HP 100000/100000
MP 62/350
```

Basic attack foundation:

```text
unarmed
base_damage 500
range 1.5
cooldown 1.0

bronze_sword
mode melee
base_damage 1000
range 2.0
cooldown 0.9
```

Movement:

```text
MOVE_SPEED = 4.0
```

Skills actuales relevantes:

```text
Heal authoritative implemented
Fire Ball skill_not_implemented
Poison skill_not_implemented
```

No conectar Stats a estos sistemas durante D4-B.

---

# 70. INPUT CANÓNICO — NO ROMPER

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
→ SELECTED SKILL according to target_kind

CTRL + LEFT CLICK player
→ BASIC ATTACK PvP future

CTRL + RIGHT CLICK player
→ SELECTED SKILL PvP future
```

---

# 71. WEAPON-AWARE BASIC ATTACK — NO TOCAR EN D4

```text
sin weapon
→ unarmed/fists
→ protocol mode "unarmed"

sword/axe
→ melee

bow
→ ranged
```

Client solicita entity.

Game Server resuelve:

```text
equipment
modality
range
damage
cooldown
```

No renombrar `unarmed`.

---

# 72. INVARIANTES CANÓNICOS F22 ACTUALES

```text
1. Stats asignados son por Character.
2. Base Stats viven en Class catalog.
3. Allocated Stats son durable player choice.
4. Permanent actual = Base + Allocated.
5. Derived Stats no se persisten como verdad final.
6. Requirements usan Permanent Stats por defecto.
7. Equipment/Buffs producirán Variable Stats.
8. Effective futuro = Permanent + Variable.
9. AGI no aumenta Movement Speed directamente.
10. Speed/Crit/Resistance usarán caps o diminishing returns.
11. MAX_LEVEL = 400.
12. Warrior/Mage/Archer usan 5 points/level foundation.
13. Reset otorga 350 points acumulativos por reset.
14. Reset futuro vuelve Level a 1.
15. Reset futuro limpia normal allocations.
16. reset_count es durable en characters.
17. MAX_RESETS sigue TBD/configurable.
18. Endgame no debe fullear automáticamente los 4 Primary Stats.
19. Reset será NPC + Backend atomic transaction.
20. Skill ownership persiste tras Reset.
21. Skill usability futura soportará requirements post-reset.
22. Equipment inválido post-reset no puede seguir activo.
23. Status Effects deben impedir stunlock/perma-control.
24. DoTs no stackean infinitamente por defecto.
25. PvP tendrá capa de balance separada.
26. unspent no se persiste si es derivable.
27. Ausencia de allocation row = revision 0 + allocation 0.
28. Allocation normal es monotónica.
29. Reset/Respec podrán reducir allocation mediante operaciones dedicadas.
30. Durable stat mutation usa final desired state, no delta.
31. Retry exacto debe ser idempotente.
32. Stale revision falla cerrado.
33. Overspend falla cerrado.
34. Character lock precede allocation lock.
35. Session Ticket inválido por Stats no se consume.
36. Backend no persiste derived combat stats.
37. Game Server es autoridad de Class Stats Catalog.
38. Game Server bootstrappea Stats desde Ticket.
39. Client recibe Primary Stats en world snapshot.
40. Client valida Primary Stats estrictamente.
41. Allocation intent Client usa request_id.
42. Durable optimistic concurrency usa revision.
43. GS no acepta antes de persistencia Backend.
44. GS runtime se reconstruye desde snapshot durable confirmado.
45. Client live runtime aplica authoritative allocation result.
46. Rejected results también pueden resincronizar Client.
47. Atilio baseline actual es revision 2 / STR allocated 11.
48. NO revertir Atilio a STR10.
49. Lyra sigue revision 0 / allocation 0.
50. No crear allocation ficticia para Lyra.
51. No conectar Stats a combat todavía.
52. No derivar HP/MP todavía.
53. No introducir Reset todavía.
54. UI nunca es source of truth.
55. No mutar localmente PrimaryStatsState de forma optimista.
56. Una durable allocation máxima en vuelo por Peer.
57. `insufficient_points` se rechaza antes de Backend.
58. D3-C demostró persistencia real y fresh reconnect.
59. D4-A demostró aplicación live al PlayerRuntimeState.
60. Cualquier audit temporal debe eliminarse antes del commit.
```

---

# 73. CURRENT TEST CHARACTERS

## Atilio

```text
ID 1
Warrior
Level 124
EXP 50
Reset 0

Primary Stats revision 2

Base:
25 / 15 / 25 / 10

Allocated:
11 / 0 / 0 / 0

Permanent:
36 / 15 / 25 / 10

Budget:
11 / 615
Unspent 604
```

## Lyra

```text
ID 2
Archer
Level 85
EXP 0
Reset 0

Primary Stats revision 0

Base:
15 / 30 / 15 / 15

Allocated:
0 / 0 / 0 / 0

Permanent:
15 / 30 / 15 / 15

Budget:
0 / 420
Unspent 420
```

---

# 74. F22 ROADMAP — ESTADO REAL

```text
F22-A
Stats / Progression / Reset Contract
✅ CLOSED

F22-B
Durable Primary Stat Backend
✅ CLOSED

F22-C
Class Stats Catalog + Game Server Runtime
✅ CLOSED

F22-D
Stat Allocation Protocol + UI
🟡 IN PROGRESS

	F22-D1
	Primary Stats initial snapshot
	✅

	F22-D2
	Allocation transport + Client protocol
	✅

	F22-D3-A
	GS Backend Stats Repository
	✅

	F22-D3-B
	Durable allocation coordinator
	✅

	F22-D3-C
	Real mutation + reconnect audit
	✅

	F22-D4-A
	Live Client runtime application
	✅

	F22-D4-B
	Primary Stats UI foundation
	⏳ NEXT

F22-E
Progressive EXP + Max Level 400
⏳ FUTURE

F22-F
Derived Vitals / Physical / Magic / Heal
⏳ FUTURE

F22-G
Armor / Resistances / Crit
⏳ FUTURE

F22-H
Attack Speed + Movement Speed
⏳ FUTURE

F22-I
Equipment Stat Modifiers
⏳ FUTURE

F22-J
Skill Scaling + Stat Requirements + reset-safe usability
⏳ FUTURE

F22-K
Integrated Balance Audit
⏳ FUTURE
```

---

# 75. GIT / AUDIT STATUS AL CIERRE D4-A

F22-D4-A fue probado con:

```text
0 parser errors
0 warnings nuevos
0 errors
git diff --check limpio
```

El audit temporal `605 > 604` fue eliminado.

Commit remoto verificado:

```text
b0b6516e4ec95c21f3232be25bb0ca05f49c8896
feat: apply live primary stat updates
```

El commit modificó sólo:

```text
app/flows/game_session_flow_coordinator.gd
```

Cambios conceptuales permanentes:

```text
bind primary_stat_allocation_result_received
+
handler live PlayerRuntimeState apply
```

---

# 76. CHECKPOINT DE CONTINUIDAD ACTUAL

Al retomar desde este documento:

```text
NO rediseñar F22-A.
NO rehacer F22-B.
NO rehacer F22-C.
NO rehacer D1/D2/D3/D4-A.

NO borrar Atilio STR11.
NO volver revision 2 a revision 1.
NO crear allocation ficticia para Lyra.

NO conectar Stats a combat todavía.
NO derivar HP/MP todavía.
NO introducir Reset todavía.
NO introducir Respec todavía.
```

Continuar desde:

```text
F22-D4-B — Primary Stats UI foundation
```

---

# 77. F22-D4-B — PRIMER OBJETIVO RECOMENDADO

La primera UI debe resolver únicamente:

```text
abrir/cerrar Stats Window
mostrar STR/AGI/VIT/ENE
mostrar Permanent
mostrar Available Points
escuchar cambios de PrimaryStatsState
```

Después, en etapa posterior:

```text
+1 allocation intent
```

Después:

```text
pending/busy feedback
```

Después:

```text
bulk allocation UX
```

No mezclar todo en un único commit.

---

# 78. CRITERIO DE DISEÑO DE LA VENTANA

Debe respetar la arquitectura UI actual del proyecto.

Reglas ya vigentes del proyecto UI:

```text
ventanas de tamaño fijo
draggables dentro del viewport
no pueden salir del área visible del juego
sin resize/expand/contract
layout compacto estilo MMORPG clásico
```

Antes de crear una nueva ventana:

```text
revisar BaseWindow
revisar Theme
revisar patrones actuales de Inventory/Equipment/NPC windows
reutilizar foundation existente
```

No crear una segunda arquitectura de ventanas paralela.

---

# 79. PRIMARY STATS UI — DATOS A MOSTRAR

Foundation recomendada:

```text
Strength
[Permanent STR] [+]

Agility
[Permanent AGI] [+]

Vitality
[Permanent VIT] [+]

Energy
[Permanent ENE] [+]

Available Points: N
```

Opcional más adelante:

```text
tooltip con Base + Allocated
```

No hace falta inicialmente mostrar:

```text
revision
spent
total
points_per_level
points_per_reset
```

Esos datos son útiles para debug/modelo, no necesariamente para UI final.

---

# 80. LIVE REFRESH UI

La ventana deberá poder refrescar cuando:

```text
PrimaryStatsState.primary_stats_changed
```

se emita.

Caso real esperado:

```text
UI muestra STR 36 / Available 604
↓
usuario asigna +1 futuro
↓
Backend persiste
↓
GS responde authoritative snapshot
↓
PlayerRuntimeState aplica
↓
PrimaryStatsState emite changed
↓
UI muestra nuevo authoritative state
```

No refrescar desde valores inventados localmente.

---

# 81. REQUEST RESULT FEEDBACK FUTURO

Razones que UI podrá mapear a feedback amigable:

```text
ok
insufficient_points
allocation_busy
invalid_points
invalid_stat
stale_request
stale_revision
backend/persistence error
```

No hace falta resolver todos los textos visuales en D4-B foundation.

---

# 82. SEGURIDAD PARA FUTUROS TESTS

Evitar gastar puntos reales innecesariamente.

Preferir tests no mutantes cuando alcance:

```text
insufficient_points
invalid_points
invalid_stat
```

Si hace falta una mutation real futura:

```text
documentar baseline exacto antes
hacer una sola mutation controlada
validar durable reconnect
actualizar este memory
NO revertir manualmente después
```

---

# 83. REGLA SOBRE AUDITS TEMPORALES

Código temporal de audit:

```text
puede agregarse
→ probarse
→ eliminarse
```

Antes de commit:

```text
git diff --check
git status
git diff
```

Debe quedar únicamente implementación permanente.

No commitear triggers de audit.

---

# 84. CONTINUATION RULE FINAL

Próximo ciclo:

```text
F22-D4-B
→ revisar arquitectura UI actual
→ diseñar foundation mínima Stats Window
→ implementar sólo representación/binding
→ test visual + runtime
→ 0 warnings/errors
→ git diff --check
→ git status
→ commit
→ push
→ esperar "pusheado"
→ verificar remoto
```

Después recién decidir siguiente sub-etapa de botones/allocation UI.

---

# 85. RESUMEN EJECUTIVO ACTUAL

Hoy VHAL ya tiene este camino completo:

```text
MySQL durable Primary Stat allocation
↓
Laravel snapshot + optimistic mutation
↓
Game Session Ticket
↓
Game Server Class Base + Allocated
↓
Permanent Primary Stats
↓
initial authoritative world snapshot
↓
Client PrimaryStatsState
```

Y también:

```text
Client allocation intent
↓
Game Server validation
↓
Backend durable PATCH
↓
Game Server runtime rebuild
↓
authoritative allocation result
↓
Client live PlayerRuntimeState apply
```

Comprobado con una mutation real:

```text
Atilio
revision 1 → 2
STR allocated 10 → 11
Permanent STR 35 → 36
unspent 605 → 604
```

y un fresh reconnect que reconstruyó exactamente el mismo estado durable.

La foundation de Primary Stats está lista para empezar la UI sin conectar todavía derived combat systems.

---

# 86. BASELINE DE CONTINUIDAD INMEDIATO

```text
Client dev:
b0b6516e4ec95c21f3232be25bb0ca05f49c8896

Game Server dev:
8e6d02e304a0743dcdcdf1400f9ad6966e8cc736

Backend dev:
ce0b202561dfee2e412f6edaf4e8df7bd422842e
```

Siguiente trabajo:

```text
F22-D4-B
Primary Stats UI foundation
```

No avanzar a F22-E/F22-F hasta cerrar F22-D de forma explícita.
