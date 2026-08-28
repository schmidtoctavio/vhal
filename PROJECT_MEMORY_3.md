# VHAL — PROJECT MEMORY 3 / F22 STATS, PROGRESSION & RESETS

**Volumen:** 3  
**Inicio:** 28/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  
**Estado general:** F19 ✅, F20 ✅, F21-A ✅, F21-B ✅, F22-A ✅, F22-B ✅, F22-C ✅.  
**Siguiente checkpoint:** F22-D — Stat Allocation Protocol + UI.

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

GitHub actual sigue prevaleciendo sobre memoria si el código real cambió.

---

# 1. WORKFLOW OBLIGATORIO

```text
ETAPA
→ implementación manual y explicada
→ test
→ corregir warnings/errors
→ git status
→ revisar scope
→ commit
→ push
→ esperar "pusheado"
→ verificar remoto
→ siguiente etapa
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

Los `.md` canónicos siempre se entregan COMPLETOS para reemplazar.

Cuando un volumen se acerque a ~5.000 líneas:

```text
cerrar volumen actual
→ abrir PROJECT_MEMORY_4.md
```

No seguir inflando indefinidamente un mismo archivo.

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

# 3. BASELINES RELEVANTES

## Cliente / memoria

Cierre F21:

```text
3a9ac1c1b2918d13d6559f39dc6c0cbbe910cba9
docs: close F21 durable skill learning
```

Contrato F22 + transición de memoria:

```text
91f746733629f9b4544fb40a711a708175e30d43
docs: define F22 stats progression and reset contract
```

## Game Server

Último baseline funcional antes de F22:

```text
968c1a19ea01b04d61b721ee59929fd55c036339
feat: recover skill trainer after learning rejection
```

## Backend

F22-B commits:

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

Última regresión Backend al cierre F22-B:

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

Durable antes de F22:

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

F22 no debe romper esos sistemas.

---

# 5. DECISIÓN F22

Sistema elegido:

```text
F22 — Character Stats & Progression
```

Motivo:

```text
Stats
├── Skill requirements
├── Equipment requirements
├── damage scaling
├── HP / MP derivados
├── builds
├── level-up points
├── crit
├── defenses/resistances
├── attack speed
├── movement speed
├── Resets
└── PvP balance
```

Otros sistemas siguen futuros:

```text
Consumables
Economy
Merchant
PvP/PK/Sin
World/content expansion
```

---

# 6. FILOSOFÍA DE BALANCE

Objetivo:

> Crear builds distintas sin permitir que una sola clase, un solo Primary Stat o una sola Skill concentren todas las ventajas relevantes.

Regla central:

```text
un Primary Stat
NO debe ser simultáneamente
la mejor fuente de:

damage
defense
crit
attack speed
movement speed
survivability
```

Queremos tradeoffs:

```text
más daño
↔ menos supervivencia

más Vitality
↔ menos presupuesto ofensivo

más utility
↔ menos daño puro
```

Balance futuro debe contemplar:

```text
PvE
PvP
progresión comparable
resets
gear
skills
status effects
```

---

# 7. PRIMARY STATS CANÓNICOS

Foundation:

```text
Strength
Agility
Vitality
Energy
```

No agregar un quinto Primary Stat todavía.

Stats adicionales existirán como:

```text
secondary
derived
ratings
percent modifiers
temporary effects
```

---

# 8. STRENGTH

Rol principal:

```text
melee physical power
```

Usos previstos:

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

Usos:

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

Razón:

Movement Speed modifica:

```text
kite
persecución
rango
PvP
NavMesh
NPC ranges
animaciones
replicación
```

Agility tampoco debe convertirse en:

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

todo simultáneamente.

---

# 10. VITALITY

Rol principal:

```text
Max HP
```

Usos:

```text
Max HP fuerte
HP Regeneration pequeña/moderada
posible pequeña contribución a Tenacity
```

No dar también gran Damage Reduction.

```text
más HP × menos damage
```

crece multiplicativamente.

Armor/Resistances deben provenir principalmente de Equipment y Secondary Stats.

---

# 11. ENERGY

Rol principal:

```text
Magic Power
```

Usos:

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

Foundation inicial:

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

Estos valores NO son balance final.

Deben vivir en catálogo autoritativo de clase.

NO duplicarlos como base individual en cada Character.

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

La arquitectura puede permitir excepciones futuras de clase, pero no se usarán inicialmente.

---

# 14. BUDGET DE STATS

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

Invariante crítica:

```text
spent <= total_budget
```

---

# 15. NO PERSISTIR UNSPENT

No crear como verdad primaria:

```text
unspent_stat_points
```

si puede calcularse desde:

```text
level
reset_count
bonus_stat_points
allocations
```

Esto evita divergencias del tipo:

```text
subió level
pero olvidamos sumar puntos
```

El Level durable ya implica el budget.

---

# 16. BASE / ALLOCATED / PERMANENT / VARIABLE / EFFECTIVE

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

Requirements usan por defecto:

```text
Permanent
```

No:

```text
Effective
```

---

# 17. REQUIREMENTS Y EQUIPMENT

Ejemplo:

```text
Permanent STR = 150

Sword actual:
+20 STR

Effective STR = 170

Nueva arma requiere:
160 STR
```

Resultado:

```text
NO puede equiparla
```

porque el requisito mira:

```text
Permanent STR = 150
```

Esto evita cadenas circulares de Equipment habilitando Equipment.

---

# 18. DERIVED / SECONDARY STATS

## Vitals

```text
Max HP
Max MP
HP Regeneration
MP Regeneration
```

## Ofensivos

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

## Defensivos

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

## Movilidad

```text
Movement Speed
```

---

# 19. QUÉ NO PERSISTIR COMO VERDAD DURABLE

No persistir:

```text
physical_damage
magic_damage
healing_power
max_hp
max_mp
armor
critical_chance
critical_damage
attack_speed
movement_speed
resistances
```

Son derivados.

Se reconstruyen desde:

```text
Class Base
+
Allocation
+
Equipment
+
Buffs/Effects
+
Rules
```

---

# 20. ATTACK SPEED

El sistema actual usa:

```text
basic_attack_cooldown_seconds
```

por arma/modo.

Futuro:

```text
effective_attack_interval
=
base_attack_interval
/
(1 + attack_speed_bonus)
```

Ejemplo:

```text
base 0.90 sec
+20% Attack Speed
→ 0.75 sec
```

Representación preferida:

```text
percentage / basis points
```

Posible representación interna:

```text
100 bps = 1%
```

Cap conceptual normal de foundation:

```text
~+50%
```

Agility sólo aportará una fracción pequeña/capada.

Gear/skills serán fuentes principales.

---

# 21. MOVEMENT SPEED

Foundation actual pre-F22:

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

Ejemplo:

```text
Boots +5%
4.0 → 4.2
```

Primary Stats NO aumentan Movement Speed directamente.

Cap conceptual inicial:

```text
normal total bonus
≈ +25%
```

Movement Speed será raro/controlado.

---

# 22. CRITICAL CHANCE

Foundation conceptual:

```text
Base Crit Chance ≈ 5%
```

Item:

```text
+2% Crit Chance
```

significa:

```text
5% → 7%
```

Representación futura sugerida:

```text
critical_chance_bps
```

Cap conceptual normal:

```text
≈ 50%
```

PvP puede usar otro cap.

---

# 23. CRITICAL DAMAGE

Foundation conceptual:

```text
Base Crit Damage ≈ 150%
```

Item:

```text
+10% Crit Damage
```

significa:

```text
150% → 160%
```

Cap conceptual normal:

```text
≈ 250%
```

No convertir Crit Damage en crecimiento infinito.

---

# 24. ARMOR Y RESISTANCE RATINGS

Items otorgan ratings planos.

Ejemplo:

```text
Leather Helmet
+30 Armor
```

Servidor convierte rating a reducción con diminishing returns.

Concepto:

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

# 25. DAMAGE TAXONOMY

Dos dimensiones.

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

---

# 26. DAMAGE PIPELINE FUTURO

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

Evitar fórmulas aisladas totalmente distintas por Skill.

---

# 27. SKILL SCALING

Skill definitions futuras deberán poder expresar:

```text
Base Power
Damage School
Element
Scaling coefficients
can_crit
Status Effects
```

Game Server es autoridad de coeficientes.

---

# 28. STATUS EFFECTS / CONTROL

Separar:

```text
Hard Control
Soft Control
Damage over Time
Debuff
Buff
```

PvP no debe permitir:

```text
permanent stun
permanent root
permanent silence
```

Hard CC futuro usará:

```text
Tenacity
+
Diminishing Returns
+
duration caps
```

Concepto DR inicial:

```text
1º CC → 100%
2º → ~50%
3º → ~25%
posteriores → inmunidad breve o duración mínima
```

Valores exactos TBD.

Tenacity reduce duración determinísticamente.

Cap conceptual:

```text
~50%
```

Slow PvP conceptual:

```text
normal movement slow cap ~40%
```

DoTs:

```text
default no crit
explicit stack policy
explicit max stacks
explicit refresh policy
```

No stack infinito.

---

# 29. PvP COMBAT PROFILE FUTURO

Stats base compartidos PvE/PvP.

Capa futura:

```text
PvP Combat Profile
```

Puede ajustar:

```text
final damage
healing
Crit caps
CC durations
Tenacity interaction
DoT modifiers
```

---

# 30. MAX LEVEL Y EXP

Decisión:

```text
MAX_LEVEL = 400
```

Foundation EXP propuesta:

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

Ejemplos:

| Level actual | XP al siguiente |
|---:|---:|
| 1 | 50 |
| 2 | 67 |
| 3 | 88 |
| 5 | 142 |
| 10 | 347 |
| 20 | 1,057 |
| 50 | 5,587 |
| 100 | 21,137 |
| 200 | 82,237 |
| 300 | 183,337 |
| 399 | 322,828 |

Total aproximado 1→400:

```text
43.4 millones EXP
```

El mismo mob NO aumenta su reward porque el jugador suba.

Training Goblin sigue temporalmente:

```text
experience_reward = 50
```

---

# 31. RESET SYSTEM — DIRECCIÓN CANÓNICA

VHAL tendrá Resets.

```text
Level 400
↓
Reset NPC
↓
requirements
↓
confirm
↓
GS context validation
↓
Backend atomic transaction
↓
Level 1
Reset Count +1
Class Spawn
Base Stats
+ Reset budget
```

Reset todavía NO está implementado.

---

# 32. RESET COUNT / RESET POINTS

Durable por Character:

```text
reset_count
```

Implementado en Backend:

```text
characters.reset_count
default 0
```

Reset points:

```text
RESET_STAT_POINTS = 350

reset_points
=
reset_count * 350
```

Ejemplos:

```text
R0 → 0
R1 → 350
R2 → 700
R10 → 3500
```

---

# 33. RESET EFFECT

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

Character vuelve a Class Base y recibe budget de Reset.

---

# 34. MAX RESETS / STAT CAPS

Todavía:

```text
MAX_RESETS = TBD
Primary Stat Hard Cap = TBD
```

Se diseñan juntos.

Principio:

> A max reset + level 400 no se deben poder maximizar automáticamente los cuatro Primary Stats.

Guideline de balance:

```text
max_total_budget
≈ 55%–70%
de lo requerido para fullear los cuatro Stats
```

Ejemplo sandbox NO final:

```text
cap 4000 cada Stat
full four = 16000
R20 Lv400 = 8995
≈ 56%
```

---

# 35. RESET NPC / COSTS

Reset NPC autoritativo:

```text
Client click
→ GS range/service validation
→ requirements snapshot
→ Reset Window
→ confirm
→ GS validation
→ Backend atomic reset
→ runtime rebuild
→ client update
```

Foundation requirements:

```text
level == 400
reset_count < MAX_RESETS
active Reset NPC
valid Character
```

Futuro:

```text
Currency
specific Item(s)
quest/progression
inventory space
```

Cost tiers:

```text
early → Currency
mid → more Currency
late → Currency + Item
near max → high Currency + rare/specific Item
```

Currency final TBD.

No canonizar `Zen`.

---

# 36. RESET + EQUIPMENT / SKILLS / INVENTORY

Equipment inválido post-reset:

```text
unequip
→ Inventory
```

Antes:

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

Reset spawn:

```text
Class Spawn Definition
```

No hardcodear TestTown.

Vitals:

```text
rederive max
current HP = new max
current MP = new max
```

---

# 37. BONUS POINTS / RESPEC

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

Endpoint normal de allocation NO puede bajar Stats.

---

# 38. F22 — ROADMAP ACTUAL

```text
F22-A  Stats/Progression Contract
	   ✅ CLOSED

F22-B  Durable Primary Stat Model
	   ✅ CLOSED

F22-C  Class Stats Catalog
	   + GS Stat Runtime
	   ⏳ NEXT

F22-D  Stat Allocation
	   GS protocol
	   client protocol
	   authoritative runtime update
	   UI
	   ⏳ FUTURE

F22-E  Progressive EXP
	   Max Level 400
	   ⏳ FUTURE

F22-F  Derived Vitals
	   Physical/Magic/Healing Power
	   ⏳ FUTURE

F22-G  Armor / Resistances / Crit
	   ⏳ FUTURE

F22-H  Attack Speed + Movement Speed
	   ⏳ FUTURE

F22-I  Equipment Stat Modifiers
	   ⏳ FUTURE

F22-J  Skill Scaling
	   Stat Requirements
	   reset-safe usability
	   ⏳ FUTURE

F22-K  Integrated Balance Audit
	   ⏳ FUTURE
```

Nota:

F22-B implementó anticipadamente la mutation durable Backend.

F22-D sigue pendiente para:

```text
Game Server request flow
network protocol
client state
Stat Window/UI
live allocation gameplay
```

---

# 39. F22-B — BREAKDOWN FINAL

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

# 40. F22-B1-A — SCHEMA

Commit:

```text
715d4c00d92c386a5eae7d946df67cb009fe41b7
feat: add durable character stat allocation schema
```

Durable:

```text
characters.reset_count
```

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

Cascade delete:

```text
Character delete
→ Stat Allocation delete
```

---

# 41. SEMÁNTICA DE FILA AUSENTE

Sin row:

```text
revision = 0
allocated = 0
bonus = 0
```

No crear rows vacías.

Primera mutation:

```text
revision 0
→ create row
→ revision 1
```

---

# 42. F22-B1-B1 — SNAPSHOT

Commit:

```text
d27a435b55d41aec28b81a49a52f43a2fbbd5de6
feat: add character stat budget snapshot
```

Clases:

```text
CharacterStatSnapshotBuilder
CharacterStatSnapshotException
```

Constants:

```text
STAT_POINTS_PER_LEVEL = 5
RESET_STAT_POINTS = 350
```

Snapshot:

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

Tests:

```text
4 passed
31 assertions
```

Suite:

```text
39 passed
219 assertions
```

---

# 43. F22-B1-B2 — READ + TICKET

Commit:

```text
9e84c8c76580c72a5f0bcd309e37b23b1c3d9d31
feat: expose durable character stat snapshot
```

GET:

```text
/api/internal/accounts/{accountId}/characters/{characterId}/stats
```

Session Ticket agregó:

```text
character.reset_count
character.stats
```

Invalid durable Stats:

```text
409
ticket remains unconsumed
```

Tests:

```text
6 passed
45 assertions
```

Suite:

```text
45 passed
264 assertions
```

---

# 44. F22-B2-A — PERSISTENCE

Commit:

```text
a77506185a97539bb5322a38c630b0137d07317d
feat: add durable character stat allocation persistence
```

Operación recibe final desired state:

```text
expected_revision
next STR/AGI/VIT/ENE
```

No recibe un delta durable.

Lock order:

```text
Character
→ Allocation row
```

Permite serializar con Progression y futuro Reset.

Retry exacto:

```text
idempotent = true
```

Stale:

```text
stale_revision
```

Overspend:

```text
stat_budget_exceeded
```

Reduction normal:

```text
allocation_regression
```

Tests:

```text
7 passed
30 assertions
```

Suite:

```text
52 passed
294 assertions
```

---

# 45. F22-B2-B — PATCH ENDPOINT

Commit:

```text
ce0b202561dfee2e412f6edaf4e8df7bd422842e
feat: expose durable character stat allocation
```

PATCH:

```text
/api/internal/accounts/{accountId}/characters/{characterId}/stats
```

Payload:

```json
{
  "expected_revision": 0,
  "next": {
	"strength": 10,
	"agility": 0,
	"vitality": 0,
	"energy": 0
  }
}
```

Controller sólo:

```text
validates HTTP
resolves Account/Character
delegates persistence
returns snapshot
```

Tests:

```text
8 passed
43 assertions
```

Suite:

```text
60 passed
337 assertions
```

---

# 46. F22-B2-C — REAL HTTP AUDIT

Audit contra:

```text
http://localhost:8080
```

Nginx:

```text
8080:80
```

Auth interna:

```text
X-VHAL-Game-Server-Key
```

No guardar ni documentar valor secreto.

---

# 47. AUDIT — ATILIO BEFORE

Inicial:

```text
Character ID 1
Level 124
Reset 0

revision 0
STR 0
AGI 0
VIT 0
ENE 0

total 615
spent 0
unspent 615
```

DB:

```text
statAllocation = null
```

---

# 48. AUDIT — REAL FIRST ALLOCATION

Se asignó REALMENTE:

```text
STR +10
```

Payload final:

```text
expected_revision = 0

next:
STR 10
AGI 0
VIT 0
ENE 0
```

Resultado:

```text
ok true
idempotent false
revision 1

spent 10
unspent 605
```

DB real:

```text
character_id = 1
allocated_strength = 10
allocated_agility = 0
allocated_vitality = 0
allocated_energy = 0
bonus_stat_points = 0
revision = 1
```

NO revertir automáticamente este estado.

---

# 49. AUDIT — RETRY / STALE

Retry exacto con:

```text
expected_revision = 0
same next state
```

resultado:

```text
idempotent true
revision 1
```

No duplicate spend.

Stale distinto:

```text
expected_revision = 0
next STR = 20
```

resultado:

```text
stale_revision
current revision = 1
current STR = 10
```

GET final:

```text
revision 1
STR 10
spent 10
unspent 605
```

---

# 50. POWERSHELL CURL QUIRK

JSON inline con:

```powershell
--data-raw '{"expected_revision":0,...}'
```

en Windows PowerShell produjo body inválido/vacío para Laravel.

Síntoma:

```text
422
field required
```

No fue bug Backend.

Patrón correcto:

```powershell
$body = @{
	expected_revision = 0
	next = @{
		strength = 10
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

Usar esto en audits futuros.

---

# 51. FINAL BACKEND REGRESSION

Después del audit real:

```text
60 tests
337 assertions
0 failures
```

Repo:

```text
working tree clean
```

---

# 52. TEST CHARACTERS ACTUALES

## Atilio

```text
ID 1
Warrior
Level 124
Experience 50
Reset 0
```

Durable Stats:

```text
revision 1
STR allocated 10
AGI allocated 0
VIT allocated 0
ENE allocated 0
bonus 0
```

Budget:

```text
level_points 615
reset_points 0
total 615
spent 10
unspent 605
```

## Lyra

```text
ID 2
Archer
Level 85
Experience 0
Reset 0
```

No allocation real hecha durante F22-B.

Expected if still no row:

```text
revision 0
allocated 0
bonus 0
total 420
spent 0
unspent 420
```

No inventar distribución histórica.

---

# 53. F22-B RESULTADO

Backend ahora resuelve autoritativamente:

```text
durable allocations
revision
level points
reset points
bonus points
total budget
spent
unspent
```

Puede:

```text
first allocation
next revision
exact retry
stale reject
overspend reject
regression reject
account isolation
ticket fail-closed
```

---

# 54. F22-B NO IMPLEMENTÓ

Todavía NO:

```text
Class Base Stats runtime
Permanent Stats runtime
Effective Stats runtime
derived HP/MP
damage scaling
physical power
magic power
healing power
Armor
Resistances
Crit
Attack Speed
Movement Speed modifiers
Equipment stat modifiers
Skill scaling
Skill stat requirements
Stat Window
client allocation buttons
GS stat allocation protocol
Reset NPC
Respec NPC
MAX_RESETS final
Primary Stat hard caps finales
```

---

# 55. SIGUIENTE CHECKPOINT — F22-C

```text
F22-C — Class Stats Catalog + Game Server Stat Runtime
```

Objetivo:

```text
Class Base
+
Durable Allocated
=
Permanent Primary Stats foundation
```

Ejemplo Atilio:

```text
Warrior Base
STR 25
AGI 15
VIT 25
ENE 10

Allocated
STR 10
AGI 0
VIT 0
ENE 0

Permanent foundation
STR 35
AGI 15
VIT 25
ENE 10
```

---

# 56. F22-C PRINCIPIOS

Class Catalog:

```text
Game Server authoritative
centralized
validated
fail closed on unknown class
```

Foundation data:

```text
class_id
starting_strength
starting_agility
starting_vitality
starting_energy
stat_points_per_level
```

Runtime distingue:

```text
base
allocated
permanent
```

En F22-C initially:

```text
variable = 0
effective = permanent
```

si conviene representar esos layers, pero no mezclar Equipment todavía.

---

# 57. F22-C BOOTSTRAP

Game Session Ticket ya contiene:

```text
character.class_id
character.level
character.reset_count
character.stats
```

F22-C debe consumir ese contrato.

No hacer segundo GET Backend innecesario durante bootstrap.

Fail closed si:

```text
unknown class_id
invalid stats payload
level/reset mismatch
negative allocation
invalid revision
budget inconsistency
```

---

# 58. F22-C NO MEZCLAR

Primer bloque F22-C NO debe incluir:

```text
damage
HP/MP formulas
attack speed
movement speed
crit
armor
resists
skill scaling
client UI
allocation network mutation
```

Primero:

```text
Class Catalog
+
Primary Stat Runtime
+
bootstrap validation
```

---

# 59. FOUNDATIONS EXISTENTES A NO ROMPER

Vitals pre-F22:

```text
DEFAULT_MAX_HP = 100000
DEFAULT_MAX_MP = 350
```

Basic attack:

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

No conectar AGI a Movement Speed.

Skills:

```text
Heal authoritative implemented
Fire Ball skill_not_implemented
Poison skill_not_implemented
```

No expandir damage skills en F22-C.

---

# 60. INPUT CANÓNICO — NO ROMPER

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

# 61. WEAPON-AWARE BASIC ATTACK

```text
sin weapon
→ unarmed/fists
→ protocol mode "unarmed"

sword/axe
→ melee

bow
→ ranged
```

Cliente sólo solicita entity.

Servidor resuelve:

```text
equipment
modality
range
damage
cooldown
```

No renombrar `unarmed`.

---

# 62. BACKEND NO EN HOT LOOP

```text
Client
→ intent
→ Game Server validation/mutation
→ authoritative result/events
→ clients
```

Backend NO entra en:

```text
per-hit
per-cast
per-attack
movement tick
```

Backend sirve durable state.

---

# 63. REVISION SEMANTICS

```text
no row
→ revision 0

first allocation
→ revision 1

valid next mutation
→ revision +1

exact retry
→ same revision

stale
→ same revision

overspend
→ same revision

regression
→ same revision
```

---

# 64. INVARIANTES CANÓNICOS F22 ACTUALIZADOS

```text
1. Stats asignados son por Character.
2. Base Stats viven en Class catalog.
3. Allocated Stats son durable player choice.
4. Derived Stats no se persisten como verdad final.
5. Requirements usan Permanent Stats por defecto.
6. Equipment/Buffs producen Variable Stats.
7. Effective = Permanent + Variable.
8. AGI no aumenta Movement Speed directamente.
9. Speed/Crit/Resistance usan caps o diminishing returns.
10. MAX_LEVEL = 400.
11. Warrior/Mage/Archer usan 5 points/level foundation.
12. Reset otorga 350 points acumulativos.
13. Reset vuelve Level a 1.
14. Reset borra allocations y vuelve a Class Base.
15. reset_count es durable en characters.
16. MAX_RESETS queda configurable/TBD.
17. Endgame no debe fullear automáticamente los 4 Primary Stats.
18. Reset será NPC + Backend atomic transaction.
19. Skill ownership persiste tras Reset.
20. Skill usability soportará requirements post-reset.
21. Equipment inválido post-reset no puede seguir activo.
22. Status Effects deben impedir stunlock/perma-control.
23. DoTs no stackean infinitamente por defecto.
24. PvP tendrá capa de balance separada.
25. unspent no se persiste si es derivable.
26. Ausencia de allocation row = revision 0 + allocation 0.
27. Allocation normal es monotónica.
28. Reset/Respec podrán reducir allocation mediante operaciones dedicadas.
29. Stat mutation usa final desired state, no delta durable.
30. Retry exacto debe ser idempotente.
31. Stale revision falla cerrado.
32. Overspend falla cerrado.
33. Character lock precede allocation lock.
34. Session Ticket inválido por Stats no se consume.
35. Backend no persiste derived combat stats.
36. Game Server será autoridad de Class Stats Catalog.
37. Game Server bootstrappea Stats desde Ticket.
38. Atilio mantiene STR allocated 10 / revision 1.
39. Lyra no recibe distribución automática histórica.
40. PowerShell HTTP audits prefieren ConvertTo-Json + --data-binary @-.
```

---

# 65. CHECKPOINT DE CONTINUIDAD

Estado:

```text
F22-A ✅
F22-B ✅
F22-C NEXT
```

Al retomar:

```text
NO rediseñar F22-A.
NO rehacer F22-B.
NO borrar STR10 de Atilio.
NO inventar Stats para Lyra.
NO introducir derived stats todavía.
NO introducir Reset NPC todavía.
NO introducir Stat UI todavía.
```

Continuar desde:

```text
Backend Ticket
character.class_id
character.stats
		│
		▼
Game Server Class Catalog
		│
		▼
Base Primary Stats
+
Durable Allocated Stats
		│
		▼
Permanent Primary Stats foundation
```

Primer sub-bloque recomendado:

```text
F22-C1
Server Class Stats Catalog
+
tests
```

Luego:

```text
F22-C2
Character Primary Stat Runtime
+
ticket bootstrap
```

Luego:

```text
F22-C3
Reconnect / per-character audit
```

Antes de cualquier código F22-C:

```text
reemplazar este PROJECT_MEMORY_3.md completo
git status
commit
push
esperar "pusheado"
verificar remoto
```

---

# 66. F22-C — CIERRE COMPLETO

Estado final:

```text
F22-C — Class Stats Catalog + Game Server Runtime
✅ CLOSED
```

Breakdown real:

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

No hubo cambios Backend ni Client durante F22-C.

---

# 67. F22-C1 — SERVER CLASS STATS CATALOG

Commit Game Server:

```text
b4544af42da7e4065ab5a96f250c98be867f08dc
feat: add authoritative class stats catalog
```

Se creó:

```text
core/stats/
├── server_class_stats_definition.gd
├── server_class_stats_definition.gd.uid
├── server_class_stats_catalog.gd
└── server_class_stats_catalog.gd.uid
```

`ServerClassStatsDefinition` representa exclusivamente:

```text
class_id
starting_strength
starting_agility
starting_vitality
starting_energy
stat_points_per_level
```

No contiene todavía:

```text
HP formulas
MP formulas
damage
armor
crit
resists
attack speed
movement speed
```

---

# 68. CLASS BASE STATS AUTORITATIVOS

Game Server authority:

```text
ServerClassStatsCatalog
```

Foundation actual:

```text
Warrior
STR 25
AGI 15
VIT 25
ENE 10
Total 75
5 points/level

Mage
STR 10
AGI 15
VIT 15
ENE 35
Total 75
5 points/level

Archer
STR 15
AGI 30
VIT 15
ENE 15
Total 75
5 points/level
```

IDs canónicos:

```text
warrior
mage
archer
```

Unknown class:

```text
get_definition(...)
→ null
```

El Game Server falla cerrado cuando una sesión intenta bootstrappear una Class no definida.

---

# 69. CLASS STATS CONTRACT VALIDATION

`ServerClassStatsCatalog.validate_contract()` valida:

```text
class_id no vacío
no duplicados
definition existente
definition válida
definition.class_id consistente
starting stat total = 75
stat_points_per_level = 5
```

Foundation constants:

```text
FOUNDATION_STARTING_STAT_TOTAL = 75
FOUNDATION_STAT_POINTS_PER_LEVEL = 5
```

Se integró la validación al startup de:

```text
app/main.gd
```

Startup correcto observado:

```text
ServerMain | Mob Drop Catalog Contract validado.
ServerMain | Class Stats Catalog Contract validado.
ServerMain | Skill Catalog Contract validado.
ServerMain | Skill Learning Catalog Contract validado.
ServerMain | Equipment Domain Contract validado.
ServerMain | Equipment Snapshot Contract validado.
ServerMain | Equipment Transfer Contract validado.
```

Game Server continuó hasta:

```text
VHAL Game Server | Listening on UDP 7000 | Max clients: 100
ServerMain | VHAL Game Server iniciado.
```

Audit:

```text
0 parser errors
0 warnings nuevos
0 errors
```

---

# 70. F22-C2 — PRIMARY STAT RUNTIME + TICKET BOOTSTRAP

Commit Game Server:

```text
7ab3f081f51506e1d68e8b991be516bdbd378e6d
feat: bootstrap authoritative character primary stats
```

Se creó:

```text
core/stats/
├── server_primary_stat_budget_rules.gd
├── server_primary_stat_budget_rules.gd.uid
├── server_character_primary_stats_state.gd
├── server_character_primary_stats_state.gd.uid
├── server_character_primary_stats_bootstrap.gd
└── server_character_primary_stats_bootstrap.gd.uid
```

Se modificó:

```text
core/world/player_world_session.gd
core/world/world_session_registry.gd
```

---

# 71. SERVER PRIMARY STAT BUDGET RULES

`ServerPrimaryStatBudgetRules` contiene foundation Game Server para validar el snapshot durable:

```text
RESET_STAT_POINTS = 350
```

Funciones:

```text
get_level_points(level, stat_points_per_level)
get_reset_points(reset_count)
```

No reemplaza todavía `ServerCharacterProgressionRules`.

F22-C deliberadamente NO cambió:

```text
MAX_LEVEL
EXP curve
```

Eso sigue reservado para F22-E.

---

# 72. SERVER CHARACTER PRIMARY STATS STATE

Runtime autoritativo:

```text
ServerCharacterPrimaryStatsState
```

Capas actuales:

```text
Base
Allocated
Permanent
```

En F22-C:

```text
Permanent
=
Base
+
Allocated
```

Todavía NO existe con contenido real:

```text
Variable
Effective
```

porque faltan Equipment/Buffs/Temporary Effects.

---

# 73. PRIMARY STAT RUNTIME FIELDS

Identity/progression:

```text
class_id
revision
level
reset_count
```

Base:

```text
base_strength
base_agility
base_vitality
base_energy
```

Allocated:

```text
allocated_strength
allocated_agility
allocated_vitality
allocated_energy
```

Permanent:

```text
permanent_strength
permanent_agility
permanent_vitality
permanent_energy
```

Budget:

```text
stat_points_per_level
stat_points_per_reset
level_points
reset_points
bonus_stat_points
total_points
spent_points
unspent_points
```

---

# 74. PRIMARY STAT STATE VALIDATION

`ServerCharacterPrimaryStatsState.is_valid()` valida:

```text
class_id no vacío
revision >= 0
level >= 1
reset_count >= 0

Base >= 0
Allocated >= 0

Permanent = Base + Allocated

stat_points_per_level > 0
stat_points_per_reset > 0

level_points =
(level - 1) * stat_points_per_level

reset_points =
reset_count * stat_points_per_reset

spent =
sum allocated

total =
level_points + reset_points + bonus

spent <= total

unspent =
total - spent
```

Revision 0 además exige:

```text
spent_points = 0
bonus_stat_points = 0
```

por semántica de fila durable ausente.

---

# 75. TICKET BOOTSTRAP DE STATS

`ServerCharacterPrimaryStatsBootstrap.create_from_character_data()` recibe el `character_data` ya transportado por Game Session Ticket.

Laravel entrega:

```text
character.class_id
character.level
character.experience
character.reset_count
character.stats
character.skills
character.runtime
```

No se agregó un GET Backend adicional.

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

---

# 76. SERVER RECALCULA EL BUDGET

El Game Server NO confía ciegamente en:

```text
level_points
reset_points
spent_points
total_points
unspent_points
```

recibidos desde Laravel.

Recalcula:

```text
expected_level_points
expected_reset_points
expected_spent_points
expected_total_points
expected_unspent_points
```

y compara el snapshot Backend contra sus reglas.

Inconsistencia:

```text
→ bootstrap null
→ PlayerWorldSession invalid
→ session creation rejected
```

---

# 77. FAIL-CLOSED CONDITIONS F22-C

La sesión no puede arrancar si aparece, por ejemplo:

```text
unknown class_id
stats missing
stats not dictionary
revision negativa
level inválido
reset_count negativo
stats.progression.level != character.level
stats.progression.reset_count != character.reset_count
allocated negativo
bonus negativo
points_per_level mismatch
points_per_reset mismatch
level_points mismatch
reset_points mismatch
spent mismatch
total mismatch
unspent mismatch
overspend
revision 0 con points gastados
```

No se crea una sesión parcialmente válida.

---

# 78. PLAYER WORLD SESSION — STATS

`PlayerWorldSession` ahora posee:

```text
reset_count
primary_stats
```

Tipo:

```text
ServerCharacterPrimaryStatsState
```

`is_valid()` exige:

```text
primary_stats != null
primary_stats.is_valid()
primary_stats.class_id == class_id
primary_stats.level == level
primary_stats.reset_count == reset_count
```

`class_id` se normaliza:

```text
trim
lowercase
```

---

# 79. CLIENT PROTOCOL DELIBERADAMENTE NO CAMBIÓ

Durante F22-C NO se agregó Primary Stats a:

```text
PlayerWorldSession.to_snapshot()
```

Por lo tanto el Client sigue recibiendo el mismo contrato previo.

Esto fue intencional:

```text
F22-C
=
Backend durable data
→ Game Server authoritative runtime
```

No:

```text
Game Server
→ Client Stats UI
```

Ese contrato pertenece a F22-D.

---

# 80. F22-C2 — AUDIT REAL ATILIO

Character:

```text
Atilio
ID 1
Warrior
Level 124
EXP 50
Reset 0
```

Durable allocation Backend:

```text
revision 1
STR 10
AGI 0
VIT 0
ENE 0
```

Game Server reconstruyó:

```text
Base Warrior:
STR 25
AGI 15
VIT 25
ENE 10

Allocated:
STR 10
AGI 0
VIT 0
ENE 0

Permanent:
STR 35
AGI 15
VIT 25
ENE 10
```

Log real:

```text
Stats revision: 1
Stats STR B/A/P: 25/10/35
AGI B/A/P: 15/0/15
VIT B/A/P: 25/0/25
ENE B/A/P: 10/0/10
Stat Points: 10/615
Unspent: 605
```

---

# 81. F22-C2 — REGRESSION FUNCIONAL

Con Primary Stats runtime activo siguieron funcionando:

```text
ticket consume
login
world snapshot
runtime restore
world presence
skills
inventory loading
equipment loading
HP/MP restore
mob roster
NPC roster
```

Ejemplo Atilio:

```text
HP 100000/100000
MP 62/350
Skills ["heal"]
Inventory 7
Equipment 1
Level 124
EXP 50/100
```

No se conectaron Stats con HP/MP ni damage.

---

# 82. F22-C3 — RECONNECT + PER-CHARACTER ISOLATION AUDIT

F22-C3 no requirió cambios de código.

Audit real:

```text
Atilio reconnect
→ Lyra
→ Atilio final
```

Objetivo:

```text
reconstrucción desde durable data
+
aislamiento por Character
+
ausencia de leakage entre sesiones
```

---

# 83. F22-C3 — ATILIO RECONNECT

Reconnect real de Atilio:

```text
Character ID 1
Warrior
Level 124
Reset 0

Stats revision 1

STR B/A/P 25/10/35
AGI B/A/P 15/0/15
VIT B/A/P 25/0/25
ENE B/A/P 10/0/10

Stat Points 10/615
Unspent 605
```

Runtime revision observado:

```text
18
```

El reconnect NO alteró:

```text
Stat revision
allocation
permanent stats
budget
```

---

# 84. F22-C3 — LYRA ISOLATION

Lyra:

```text
Character ID 2
Archer
Level 85
EXP 0
Reset 0
```

Skills observadas:

```text
heal
poison
```

Durable Stats:

```text
revision 0
sin allocation durable
```

Game Server reconstruyó:

```text
Archer Base:
STR 15
AGI 30
VIT 15
ENE 15

Allocated:
STR 0
AGI 0
VIT 0
ENE 0

Permanent:
STR 15
AGI 30
VIT 15
ENE 15

Stat Points:
0/420

Unspent:
420
```

Log real:

```text
Stats revision: 0
Stats STR B/A/P: 15/0/15
AGI B/A/P: 30/0/30
VIT B/A/P: 15/0/15
ENE B/A/P: 15/0/15
Stat Points: 0/420
Unspent: 420
```

Atilio `allocated STR = 10` NO se filtró a Lyra.

---

# 85. F22-C3 — ATILIO FINAL

Después de Lyra, Atilio volvió a reconstruirse como:

```text
revision 1

STR 25/10/35
AGI 15/0/15
VIT 25/0/25
ENE 10/0/10

Stat Points 10/615
Unspent 605
```

Secuencia confirmada:

```text
Atilio
→ correct state

Lyra
→ independent correct state

Atilio
→ original correct state again
```

---

# 86. MULTI-SESSION OBSERVATION

Durante el audit final existieron Atilio y Lyra simultáneamente como sesiones/presencias distintas.

El Client de Atilio recibió:

```text
Remotos: 1
```

y representó a Lyra como remoto.

Esto refuerza que el Primary Stat Runtime vive por:

```text
PlayerWorldSession
```

y no como singleton global compartido.

No se enviaron todavía Primary Stats de players remotos al Client.

---

# 87. F22-C — GIT / ERRORS FINAL

Al cierre:

```text
git status
→ nothing to commit, working tree clean
```

C3 no generó cambios.

Audits C1/C2/C3:

```text
0 parser errors
0 warnings nuevos
0 errors
```

No fue necesario hotfix.

---

# 88. F22-C — RESULTADO ARQUITECTÓNICO

Ahora existen tres verdades correctamente separadas:

```text
Backend
→ Durable Allocated Stats

Game Server Class Catalog
→ Base Stats

Game Server Character Runtime
→ Base + Allocated = Permanent
```

Ejemplo Atilio:

```text
Backend allocated STR = 10
Warrior base STR = 25
GS Permanent STR = 35
```

No se persiste `35` como verdad durable.

Se deriva.

---

# 89. QUÉ F22-C NO HIZO

Todavía NO:

```text
Client Stats snapshot
Stat Window
+ buttons
bulk allocation
GS allocation request protocol
Backend stat repository in GS
live Primary Stat runtime mutation
derived Vitals
Physical Power
Magic Power
Healing Power
Armor
Resistances
Crit
Attack Speed
Movement Speed modifiers
Equipment stat modifiers
Skill scaling
Skill stat requirements
Reset NPC
Respec
```

---

# 90. F22 ROADMAP — ESTADO ACTUAL

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

# 91. F22-D — SIGUIENTE CHECKPOINT

Siguiente fase:

```text
F22-D — Stat Allocation Protocol + UI
```

Objetivo general:

```text
Client Stat Window
↓
player allocation intent
↓
Game Server validation
↓
Backend durable PATCH
↓
authoritative updated Primary Stats runtime
↓
Client authoritative Stats update
```

Backend mutation ya existe desde F22-B.

No reimplementar allocation en Laravel.

---

# 92. F22-D — ARQUITECTURA ESPERADA

Flujo conceptual:

```text
Client
→ allocation intent

Game Server
→ request_id validation
→ Character/session validation
→ desired final allocation
→ Backend internal PATCH

Backend
→ optimistic revision
→ budget validation
→ durable commit

Game Server
→ authoritative response
→ update/rebuild Primary Stats runtime

Client
→ authoritative Stats update
→ UI refresh
```

Cliente NO escribe directo a Backend.

Cliente NO decide budget final.

---

# 93. F22-D — PAYLOAD DURABLE YA EXISTENTE

Backend PATCH:

```text
PATCH
/api/internal/accounts/{accountId}/characters/{characterId}/stats
```

Semántica:

```text
expected_revision
+
next final allocation
```

Ejemplo:

```json
{
  "expected_revision": 1,
  "next": {
	"strength": 15,
	"agility": 0,
	"vitality": 0,
	"energy": 0
  }
}
```

No usar delta durable tipo:

```text
+5 STR
```

Game Server puede transformar una intención Client en final desired state antes de persistir.

---

# 94. F22-D — IDEMPOTENCIA A PRESERVAR

Backend ya soporta:

```text
lost response
→ exact retry
→ idempotent true
```

Game Server debe preservar esa propiedad.

No convertir una retransmisión Client en doble gasto.

Roles distintos:

```text
request_id
→ Client ↔ Game Server protocol ordering/idempotence

revision
→ Game Server ↔ Backend durable optimistic concurrency
```

No confundirlos.

---

# 95. F22-D — CLIENT SNAPSHOT

Durante F22-C Stats NO entraron en `PlayerWorldSession.to_snapshot()`.

F22-D deberá definir explícitamente el contrato Client.

Preferencia:

```text
initial world snapshot
→ incluye Primary Stats autoritativos
```

Live mutation:

```text
dedicated stat allocation result/update
```

No reenviar roster completo por cada allocation.

---

# 96. F22-D — UI PRINCIPLES

UI prevista estilo MMORPG clásico:

```text
Strength
Agility
Vitality
Energy

Permanent/current display
Available points
+ buttons
```

Debe soportar cómodamente muchos puntos libres.

No diseñar todavía:

```text
Respec UI
Reset UI
giant derived character sheet
```

Primero allocation foundation.

---

# 97. F22-D — NO CONECTAR TODAVÍA A DAMAGE

Asignar STR/AGI/VIT/ENE en F22-D debe:

```text
persistir
actualizar GS runtime
actualizar Client
actualizar UI
```

pero todavía NO cambiar necesariamente:

```text
Basic Attack damage
HP
MP
Heal
Fire Ball
Poison
Armor
Movement Speed
```

Eso llega en F22-F+.

---

# 98. CHECKPOINT DE CONTINUIDAD ACTUALIZADO

Estado real:

```text
F22-A ✅
F22-B ✅
F22-C ✅
F22-D NEXT
```

Repos:

```text
Backend
→ durable allocation complete

Game Server
→ class catalog complete
→ primary stat runtime complete

Client
→ todavía no conoce Primary Stats
```

Antes de F22-D:

```text
reemplazar este PROJECT_MEMORY_3.md completo
git status
commit
push
esperar "pusheado"
verificar remoto
```

No iniciar F22-D antes del push documental.

---

# 99. BASELINES DESPUÉS DE F22-C

Game Server:

```text
b4544af42da7e4065ab5a96f250c98be867f08dc
feat: add authoritative class stats catalog

7ab3f081f51506e1d68e8b991be516bdbd378e6d
feat: bootstrap authoritative character primary stats
```

Backend F22-B:

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

Client/memory F22-B:

```text
b619429ab502f658a2f06e1be07e49b256585628
docs: close F22 durable stat backend
```

Siguiente commit documental:

```text
docs: close F22 class stats runtime
```

---

# 100. CONTINUATION RULE

Al retomar:

```text
NO rediseñar F22-A.
NO rehacer F22-B.
NO rehacer F22-C.

NO borrar Atilio STR10.
NO crear allocation ficticia para Lyra.

NO conectar Stats a combat todavía.
NO derivar HP/MP todavía.
NO introducir Reset todavía.
```

Continuar desde:

```text
F22-D — Stat Allocation Protocol + UI
```

con el ciclo:

```text
small stage
→ manual implementation
→ test
→ clean warnings/errors
→ git status
→ commit
→ push
→ "pusheado"
→ next stage
```
