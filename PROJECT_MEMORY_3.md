# VHAL — PROJECT MEMORY 3 / F22 STATS, PROGRESSION & RESETS

**Volumen:** 3  
**Inicio:** 28/08/2026  
**Motor cliente / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  
**Estado general:** F19 ✅, F20 ✅, F21-A ✅, F21-B ✅. F22 Character Stats & Progression seleccionado y diseñado a nivel de contrato.  
**Siguiente checkpoint:** F22-B1 — Backend Durable Primary Stat Allocation Schema.

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

> este volumen prevalece para F22 y decisiones posteriores si contradice una propuesta anterior de Volumen 1 o 2.

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

No avanzar antes de `pusheado`.

No mezclar scopes.

Objetivo habitual:

```text
0 warnings
0 errors
```

Los `.md` canónicos siempre se entregan completos para reemplazar.

---

# 2. REPOSITORIOS Y BASELINES

```text
Cliente / memoria:
schmidtoctavio/vhal

Game Server:
schmidtoctavio/vhal_game_server

Backend:
schmidtoctavio/vhal_backend
```

Branch:

```text
dev
```

Baseline documental cliente:

```text
3a9ac1c1b2918d13d6559f39dc6c0cbbe910cba9
docs: close F21 durable skill learning
```

Game Server funcional:

```text
968c1a19ea01b04d61b721ee59929fd55c036339
feat: recover skill trainer after learning rejection
```

Backend funcional:

```text
64be9a85e90ec6a07f1cb1b47d0c21c670f7dc18
feat: add atomic durable skill learning
```

---

# 3. ESTADO CERRADO ANTES DE F22

```text
F19 Vertical Slice                  ✅
F20 Durable Character Runtime       ✅
F21-A Durable Skill Ownership       ✅
F21-B Durable Skill Learning        ✅
```

Durable actualmente:

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

F22 NO debe romper esos sistemas.

---

# 4. DECISIÓN F22

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

# 5. FILOSOFÍA DE BALANCE

Objetivo:

> crear builds distintas sin permitir que una sola clase, un solo Primary Stat o una sola Skill concentren todas las ventajas relevantes.

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

Queremos tradeoffs.

Ejemplo:

```text
más daño
↔ menos supervivencia

más Vitality
↔ menos presupuesto ofensivo

más utility
↔ menos daño puro
```

---

# 6. PRIMARY STATS CANÓNICOS

Foundation:

```text
Strength
Agility
Vitality
Energy
```

No agregar un quinto Primary Stat todavía.

Stats adicionales existirán como secundarios/derivados.

---

# 7. STRENGTH

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

# 8. AGILITY

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

y es un multiplicador demasiado sensible.

Agility tampoco debe convertirse en:

```text
damage + defense + crit + huge attack speed + movement speed
```

---

# 9. VITALITY

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

# 10. ENERGY

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

Coeficientes reales todavía TBD.

---

# 11. STARTING STATS POR CLASE

Foundation de pruebas:

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

Deben vivir en catálogo autoritativo, no duplicarse por Character en DB.

---

# 12. PUNTOS POR LEVEL

Foundation:

```text
Warrior = 5
Mage = 5
Archer = 5
```

Concepto:

```text
STAT_POINTS_PER_LEVEL = 5
```

No usar budgets distintos por clase inicialmente.

La arquitectura puede permitir excepciones futuras.

---

# 13. BUDGET DE STATS

```text
level_points
=
(level - 1)
*
stat_points_per_level
```

Con Resets:

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

# 14. NO PERSISTIR UNSPENT SI ES DERIVABLE

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

Esto evita bugs:

```text
subió level
pero no sumó puntos
```

El Level durable ya implica el budget.

---

# 15. MODELO DURABLE PROPUESTO

Entidad:

```text
character_stat_allocations
```

Campos foundation previstos:

```text
character_id PK/FK

allocated_strength
allocated_agility
allocated_vitality
allocated_energy

bonus_stat_points

revision
timestamps
```

Stats asignados son:

```text
por Character
```

NO por Account.

---

# 16. QUÉ NO PERSISTIR COMO VERDAD DURABLE

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

# 17. BASE / ALLOCATED / PERMANENT / VARIABLE / EFFECTIVE

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

No Effective.

---

# 18. REQUISITOS Y EQUIPMENT

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

Esto evita cadenas de items que se habilitan entre sí.

---

# 19. SECONDARY / DERIVED STATS

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

Vitals:

```text
Max HP
Max MP
HP Regeneration
MP Regeneration
```

Movilidad:

```text
Movement Speed
```

---

# 20. ATTACK SPEED

El sistema actual ya usa:

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

Preferencia de item:

```text
+X% Attack Speed
```

No:

```text
+5 velocidad
```

sin unidad.

Representación interna posible:

```text
basis points
100 bps = 1%
```

Cap conceptual de testing:

```text
Attack Speed Bonus normal
≈ +50%
```

Valor final se valida con animaciones/gameplay.

Agility sólo aportará una fracción pequeña/capada.

---

# 21. MOVEMENT SPEED

Foundation actual:

```text
4.0
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

Preferir porcentaje.

Cap conceptual inicial:

```text
bonus normal total ≈ +25%
```

Primary Stats NO aumentan directamente Movement Speed.

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

No multiplicación ambigua.

Representación futura:

```text
critical_chance_bps
```

Cap conceptual normal:

```text
≈ 50%
```

PvP puede tener otro cap.

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

Items otorgan valores/rating.

Ejemplo:

```text
Leather Helmet
+30 Armor
```

No preferir:

```text
-10% Physical Damage
```

por cada pieza.

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

Ejemplo:

```text
Fire Ball
Energy = primary scaling
magical/fire
```

Ejemplo:

```text
Archer physical Skill
Agility = strong
Strength = secondary
```

Game Server es autoridad de coeficientes.

---

# 28. SKILL SCALING EN UI

Cliente puede mostrar:

```text
Escala principalmente con Energía
```

o:

```text
Energy ★★★
Agility ★
```

No debe inventar el scaling.

Debe derivarse de metadata consistente con servidor.

---

# 29. STATUS EFFECT TAXONOMY

Separar:

```text
Hard Control
Soft Control
Damage over Time
Debuff
Buff
```

Hard Control:

```text
stun
root
silence futuro si corresponde
```

Soft Control:

```text
slow
attack speed slow
accuracy debuff
```

DoT:

```text
poison
burn
bleed futuro
```

Debuff:

```text
armor reduction
resistance reduction
damage reduction
healing reduction
```

No representar todo como un boolean genérico.

---

# 30. PRINCIPIO ANTI-STUNLOCK

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

Objetivo:

> ningún jugador debe quedar sin posibilidad real de actuar por una cadena infinita de una clase o composición.

---

# 31. DIMINISHING RETURNS DE HARD CC

Concepto de testing:

```text
1º CC de categoría
→ 100%

2º dentro de ventana DR
→ ~50%

3º
→ ~25%

repetición posterior
→ inmunidad breve o duración mínima
```

Valores exactos:

```text
TBD
```

PvE puede usar otra política.

Bosses pueden tener inmunidades/reducción propia.

---

# 32. TENACITY

Tenacity reduce duración de control.

Ejemplo:

```text
Stun 4 sec
Tenacity 25%
→ 3 sec antes de otros modifiers
```

Preferencia:

```text
reducción determinística
```

No:

```text
25% chance RNG de ignorar el Stun
```

como sistema normal.

Cap conceptual:

```text
≈ 50%
```

---

# 33. SLOWS

Un Slow no debe transformarse en Root accidental.

Cap PvP conceptual:

```text
maximum normal movement slow
≈ 40%
```

Root es categoría Hard CC aparte.

También habrá cap para Attack Speed debuffs.

---

# 34. DoT — POISON / BURN

Default futuro:

```text
DoT ticks
→ no crit
```

salvo definición explícita:

```text
can_crit = true
```

Cada DoT define:

```text
duration
tick interval
stack policy
max stacks
refresh policy
school
element
scaling
```

Stack modes posibles:

```text
refresh
replace_stronger
stack
```

No stack infinito global.

---

# 35. RESISTENCIA A EFFECTS

Separar:

```text
Damage Resistance
de
Control Resistance
```

Ejemplo:

```text
Poison Resistance
→ poison damage

Tenacity
→ control duration
```

No mezclar semánticas.

---

# 36. PvP COMBAT PROFILE FUTURO

Stats base serán compartidos PvE/PvP.

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

Esto permite balancear PvP sin destruir PvE.

---

# 37. MAX LEVEL CANÓNICO

Decisión:

```text
MAX_LEVEL = 400
```

Level 400 no avanza a 401.

Se convierte en candidato a:

```text
Reset
```

El MAX_LEVEL 65535 actual es foundation temporal.

---

# 38. EXP CURVE PROGRESIVA

La regla actual de 100 EXP por level se reemplazará.

Foundation propuesta:

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

No representa por sí solo tiempo de juego.

---

# 39. EXP DE MOBS

Cada mob mantiene:

```text
level
experience_reward
```

El mismo mob NO aumenta su reward porque el jugador suba.

Game Server futuro aplica multiplier por diferencia:

```text
Player Level
vs
Mob Level
```

Concepto:

```text
mismo/cercano
→ ~100%

bastante inferior
→ reducido

muy inferior
→ casi 0

mob superior
→ pequeño bonus con cap
```

Objetivo:

```text
Lvl 100
NO farmea Goblins Lv.1
como opción óptima.
```

---

# 40. EXP Y RESETS

Default:

```text
misma curva 1→400
en cada Reset
```

No agregar inicialmente penalización extra de XP por Reset.

Futuro opcional:

```text
reset_experience_multiplier
```

Default previsto:

```text
1.0
```

Si hace falta frenar resets, primero usar:

```text
Reset costs
requirements
content progression
```

---

# 41. RESET SYSTEM — DIRECCIÓN CANÓNICA

VHAL tendrá Resets.

Flujo:

```text
Level 400
↓
Reset NPC
↓
mostrar requirements
↓
confirmar
↓
Backend transaction
↓
Level 1
Reset Count +1
Class Spawn
Base Stats
+ Reset budget
```

Reset todavía NO está implementado.

F22 debe dejar la foundation preparada.

---

# 42. RESET COUNT

Durable por Character:

```text
reset_count
```

Inicio:

```text
0
```

Primer reset:

```text
1
```

---

# 43. RESET STAT POINTS

Decisión aprobada:

```text
RESET_STAT_POINTS = 350
```

Son acumulativos.

```text
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

# 44. QUÉ HACE RESET A LEVEL/EXP/STATS

Reset exitoso:

```text
level → 1
experience → 0

reset_count → +1

allocated_strength → 0
allocated_agility → 0
allocated_vitality → 0
allocated_energy → 0
```

Personaje vuelve a:

```text
Class Base Stats
```

y recibe libre:

```text
new_reset_count * 350
```

para redistribuir.

---

# 45. EJEMPLO DE RESET

Antes:

```text
Reset 0
Level 400
1995 level points gastados
```

Después:

```text
Reset 1
Level 1
Class Base Stats
350 unspent Reset Points
```

Al volver a subir:

```text
Level Points
+
Reset Points
```

forman el mismo presupuesto asignable.

---

# 46. TOTAL BUDGET A LEVEL 400

Con 5 puntos/level:

```text
(400 - 1) * 5
=
1995
```

Budget:

```text
1995
+
(reset_count * 350)
+
bonus_stat_points
```

Ejemplos sin bonus:

| Reset | Budget a Lv400 |
|---:|---:|
| 0 | 1,995 |
| 1 | 2,345 |
| 10 | 5,495 |
| 20 | 8,995 |
| 25 | 10,745 |

---

# 47. MAX RESETS — TBD

No fijar todavía número definitivo.

Debe ser configurable:

```text
MAX_RESETS
```

También habrá:

```text
Primary Stat Hard Cap
```

Ambos se diseñan juntos.

---

# 48. PRINCIPIO ANTI-FULL-STATS

Incluso en:

```text
MAX_RESETS
+
Level 400
```

NO queremos que automáticamente se puedan maximizar:

```text
STR
AGI
VIT
ENE
```

Si todos terminan full:

```text
desaparecen builds
desaparecen tradeoffs
todos convergen
```

---

# 49. GUÍA PARA RESET CAP / STAT CAP

Objetivo de balance inicial:

```text
max_total_budget
≈ 55%–70%
del presupuesto necesario
para fullear los cuatro Stats
```

No es regla matemática rígida.

Ejemplo sandbox NO definitivo:

```text
cap 4000 cada Stat
full four = 16000

Max Reset 20:
budget Lv400 = 8995
≈ 56%
```

Esto demuestra por qué:

```text
MAX_RESETS
y
STAT_CAP
```

se deciden juntos.

No convertir todavía 20/4000 en constants finales.

---

# 50. RESET NPC

Reset será un NPC service autoritativo.

Patrón:

```text
Client click
→ GS range/service validation
→ Reset requirements snapshot
→ Reset Window
→ Confirm
→ GS context validation
→ Backend atomic reset
→ GS runtime rebuild
→ Client authoritative update
```

Reutilizar principios de:

```text
Warehouse
Skill Trainer
```

---

# 51. RESET REQUIREMENTS

Base:

```text
level == 400
reset_count < MAX_RESETS
Reset NPC service activo
Character válido
```

Futuro:

```text
Currency
specific Item
multiple Items
quest/progression
inventory space
```

NPC debe decir claramente:

```text
qué falta
costo
qué se reinicia
qué se conserva
puntos obtenidos
```

---

# 52. RESET COST TIERS

No fijar costos ahora.

Dirección:

```text
early resets
→ Currency

mid
→ más Currency

late
→ Currency + Item

near max
→ Currency alta + Item raro/específico
```

Currency final todavía no se llama `Zen`.

---

# 53. RESET BACKEND TRANSACTION

Reset tocará múltiples durables.

Debe ser:

```text
atomic transaction
```

Conceptualmente:

```text
validate requirements
consume Currency
consume required Items
increment reset_count
level = 1
experience = 0
clear Stat allocations
resolve Equipment
set Class Spawn/runtime state
commit
```

Todo o nada.

---

# 54. RESET Y EQUIPMENT

Problema:

```text
Lv400 STR alta
arma equipada requiere STR alta
↓
Reset
↓
STR vuelve a base
```

No dejar Equipment inválido activo.

Política prevista:

```text
unequip items que ya no cumplen
→ Inventory
```

Antes de confirmar:

```text
validar espacio
```

Sin espacio:

```text
Reset rechazado
```

No permitir Equipment inválido otorgando bonuses.

---

# 55. RESET Y SKILLS

Skill ownership:

```text
PERSISTE
```

No obligar a consumir nuevamente Scrolls en cada Reset.

Pero Skill aprendida puede tener requirement superior al nuevo estado.

Por eso se distinguirá:

```text
learned
de
currently usable
```

Futuro:

```text
Skill ownership = durable knowledge
Skill usability = current requirements
```

Reset puede dejar temporalmente una Skill:

```text
locked/unusable
```

hasta recuperar Level/Stats.

---

# 56. RESET Y INVENTORY / VAULT

Default:

```text
Inventory persiste
Vault persiste
Item ownership persiste
```

Sólo se consumen items usados como costo de Reset.

---

# 57. RESET Y CLASS SPAWN

Reset exitoso vuelve a:

```text
spawn de la Class
```

Debe restaurar:

```text
Map
Position
Rotation
```

desde una futura Class/Spawn Definition.

No hardcodear TestTown como spawn definitivo.

---

# 58. RESET Y VITALS

Tras reset:

```text
Max HP
Max MP
```

se recalculan desde el nuevo estado.

Current:

```text
HP = Max HP
MP = Max MP
```

al reaparecer.

No conservar current HP superior al nuevo máximo.

---

# 59. RESET Y POWER PROGRESSION

Reset intencionalmente aumenta poder potencial.

No exigimos:

```text
Reset 0 = Reset 20
```

en Open World.

Balance de clases se evalúa principalmente entre progresión comparable.

PvP futuro puede añadir:

```text
reset brackets
matchmaking
normalized arenas
```

si se necesita.

---

# 60. RESETS NO PUEDEN ROMPER SECONDARY STATS

Más Primary Stats por Reset NO deben llevar a:

```text
100% Crit
0 cooldown
movement speed absurda
100% resistance
perma stun
infinite poison scaling
```

Secondary Stats sensibles usan:

```text
caps
diminishing returns
PvP profile
```

Ejemplo:

```text
AGI crece
pero contribution a Attack Speed
se desacelera/capa.
```

---

# 61. BONUS STAT POINTS

Campo futuro:

```text
bonus_stat_points
```

Para fuentes distintas a Level/Reset:

```text
quest
achievement
event
compensation
special progression
```

Reset NO usa ese campo.

Reset usa:

```text
reset_count * 350
```

---

# 62. STAT RESPEC FUTURO

Puede existir:

```text
Stat Respec NPC
```

Separado de Reset.

Respec:

```text
mismo Level
mismo Reset
mismo total budget
clear allocations
redistribute
```

Modelo durable F22 debe soportarlo naturalmente.

---

# 63. ITEM MODIFIERS FUTUROS

Ejemplos:

```text
+20 Strength
+10 Vitality
+30 Armor
+5% Movement Speed
+8% Attack Speed
+2% Crit Chance
+10% Crit Damage
+25 Fire Resistance
```

Separar semánticamente:

```text
flat primary modifiers
flat ratings
percentage modifiers
```

ServerItemCatalog será autoridad.

---

# 64. SKILL STAT REQUIREMENTS

F21-B hoy usa:

```text
class
level
scroll
trainer
```

F22-J agregará:

```text
minimum permanent stats
```

Ejemplo:

```text
Level 80
Energy 300
```

Requirement usa por defecto:

```text
Permanent Energy
```

No Equipment temporary boost.

---

# 65. BALANCE DATA DEBE SER CENTRALIZADA

Centralizar:

```text
starting stats
points per level
XP coefficients
Max Level
Reset points
Max Resets
Stat caps
Attack Speed cap
Movement Speed cap
Crit caps
Tenacity cap
PvP multipliers
```

No desperdigar entre:

```text
UI
MovementCoordinator
BasicAttackCoordinator
Skill scripts
```

Objetivo:

```text
balance patch
→ modificar reglas/datos centrales
→ no reescribir arquitectura
```

---

# 66. BACKWARD COMPATIBILITY — TEST CHARACTERS

Estado actual de laboratorio:

```text
Atilio Lv124
Lyra Lv85
```

Al introducir Allocation:

```text
allocated_* = 0
reset_count = 0
bonus_stat_points = 0
```

Budget inicial derivado:

```text
Atilio:
(124 - 1) * 5
= 615 libres

Lyra:
(85 - 1) * 5
= 420 libres
```

No inventar una distribución histórica automática.

---

# 67. MIGRACIÓN DE VITALS FOUNDATION

Actual:

```text
Max HP = 100000
Max MP = 350
```

son temporales.

Cuando F22 derive nuevos máximos:

```text
current HP/MP
```

deben respetar:

```text
current <= max
```

Política concreta de transición se decidirá en F22-F.

No cambiar silenciosamente durable current values.

---

# 68. LEVEL 400 STATE

Al alcanzar 400:

```text
level = 400
at_max_level = true
```

No Level 401.

Preferencia futura:

```text
experience = 0
experience_required = 0
```

UI:

```text
MAX
```

y orientar al Reset NPC.

---

# 69. LEVEL-UP Y PUNTOS

No escribir una columna mutable:

```text
+5 unspent
```

cada vez que sube Level.

Ejemplo:

```text
Lv10 budget = 45
Lv11 budget = 50
```

La fuente durable es `level`.

---

# 70. F22 — ORDEN DE IMPLEMENTACIÓN

```text
F22-A  Stats/Progression Contract
	   ✅ DISEÑADO

F22-B  Durable Primary Stat Model
	   ⏳ SIGUIENTE

F22-C  Class Stats Catalog
	   + GS Stat Runtime

F22-D  Stat Allocation
	   protocol + authoritative mutation + UI

F22-E  Progressive EXP
	   Max Level 400
	   earned level points

F22-F  Derived Vitals
	   Physical/Magic/Healing Power

F22-G  Armor
	   Resistances
	   Crit

F22-H  Attack Speed
	   Movement Speed

F22-I  Equipment Stat Modifiers

F22-J  Skill Scaling
	   Stat Requirements
	   reset-safe Skill usability

F22-K  Integrated Balance Audit
```

Reset real se implementará después de que estas primitives estén disponibles.

Fase exacta futura del Reset NPC:

```text
TBD
```

---

# 71. SIGUIENTE CHECKPOINT REAL

```text
F22-B1 — Backend Durable Primary Stat Allocation Schema
```

Scope:

```text
migration
model
relation
invariants
read contract
```

Todavía NO:

```text
allocation gameplay endpoint
GS formulas
damage
HP/MP derivados
speed
crit
Armor
Skill scaling
Reset NPC
```

---

# 72. INVARIANTES CANÓNICOS F22

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

11. Warrior/Mage/Archer reciben 5 points/level foundation.

12. Reset otorga 350 points acumulativos.

13. Reset vuelve Level a 1.

14. Reset borra allocations del ciclo y vuelve a Class Base.

15. reset_count es durable.

16. MAX_RESETS queda configurable/TBD.

17. Endgame no debe fullear automáticamente los 4 Primary Stats.

18. Reset será NPC + Backend atomic transaction.

19. Skill ownership persiste tras Reset.

20. Skill usability debe soportar requirements post-reset.

21. Equipment inválido tras Reset no puede seguir activo.

22. Status Effects deben impedir stunlock/perma-control.

23. DoTs no stackean infinitamente por defecto.

24. PvP tendrá una capa de balance separada de PvE.
```

---

# 73. RESUMEN EJECUTIVO F22

```text
PRIMARY
STR / AGI / VIT / ENE

LEVEL
Max 400
5 points per level
progressive XP

RESET
350 cumulative points per reset
Level → 1
EXP → 0
allocations → 0
Class Base Stats
Class Spawn
NPC future
atomic Backend transaction

DERIVED
Physical
Magic
Healing
HP/MP
Armor
Resists
Crit
Attack Speed
Movement Speed

ANTI-BREAK
caps
diminishing returns
Tenacity
CC DR
PvP profile

SKILLS
explicit scaling
explicit damage school/element
future permanent-stat requirements
reset-safe ownership/usability
```

---

# 74. ESTADO DE IMPLEMENTACIÓN AL CERRAR ESTE DOCUMENTO

No se ha modificado todavía código de F22.

Estado:

```text
F22-A Design Contract ✅

F22-B1
→ listo para comenzar
```

Antes de modificar Backend:

```text
git status
repos clean
review schema actual
etapa pequeña
test
commit
push
esperar "pusheado"
```
