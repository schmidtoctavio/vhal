# VHAL — PROJECT MEMORY 5 / COMBAT FOUNDATION F23 → F26

**Volumen:** 5  
**Inicio:** 06/09/2026  
**Última actualización canónica:** 07/09/2026  
**Motor Client / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`

---

# 0. PROPÓSITO DE ESTE VOLUMEN

Este archivo es la continuidad canónica más reciente de VHAL.

Reemplaza completamente la versión anterior de:

```text
PROJECT_MEMORY_5.md
```

sin reemplazar la historia conservada por los volúmenes anteriores.

Orden obligatorio al retomar el proyecto:

```text
1. PROJECT_MEMORY.md
2. PROJECT_MEMORY_2.md
3. PROJECT_MEMORY_3.md
4. PROJECT_MEMORY_4.md
5. PROJECT_MEMORY_5.md
6. futuros PROJECT_MEMORY_N.md
7. repositorios reales branch dev
```

Precedencia:

> El volumen más nuevo prevalece para el estado operativo actual cuando existe contradicción con un volumen anterior.

Y por encima de toda memoria:

> El código realmente pusheado en `dev` prevalece si cambió después de la última actualización documental.

Historial resumido:

```text
PROJECT_MEMORY.md
→ arquitectura general
→ F00-F19
→ primer vertical slice real

PROJECT_MEMORY_2.md
→ F20 Durable Character Runtime
→ F21 Durable Skill Ownership / Learning

PROJECT_MEMORY_3.md
→ F22 Stats / Progression / Reset design
→ Primary Stats
→ progression contracts

PROJECT_MEMORY_4.md
→ F22-F Derived Stats
→ Max HP / MP
→ Physical / Magic / Healing Power
→ primeros consumers reales

PROJECT_MEMORY_5.md
→ cierre F22 restante
→ F23 Skill Combat Effects
→ F24 Unified Damage & Mitigation
→ F25 Hit Resolution & Defensive Outcomes
→ F26 PvE Enemy Combat Loop
```

Política de tamaño:

```text
~5000 líneas
→ cerrar el volumen
→ abrir PROJECT_MEMORY_6.md
```

Este volumen todavía tiene margen suficiente y por eso NO se abre `PROJECT_MEMORY_6.md` en este checkpoint.

---

# 1. WORKFLOW OBLIGATORIO ACTUAL

Ciclo canónico:

```text
FASE / ETAPA ACORDADA
→ revisar repositorios reales
→ explicar scope
→ implementación manual/controlada
→ test positivo
→ corregir warnings/errors
→ git status
→ revisar scope
→ commit
→ push
→ usuario dice "pusheado"
→ verificar remoto
→ recién entonces siguiente etapa permanente
```

Reglas vigentes:

```text
No avanzar antes de "pusheado".
No mezclar scopes.
Preferir checkpoints pequeños.
No convertir una etapa en refactor general por inercia.
Usar git status como verificación local habitual.
No hacer auditorías negativas de rutina.
No usar git diff --check de rutina.
No usar git diff --stat de rutina.
No crear commits por el usuario.
No hacer push por el usuario salvo pedido explícito.
No actualizar documentación en medio de gameplay salvo checkpoint documental acordado.
```

Objetivo habitual:

```text
0 parser errors
0 warnings nuevos
0 runtime errors inesperados
```

Escenas y archivos:

```text
.tscn
→ siempre editar manualmente desde Godot Editor

.gd
→ puede entregarse completo o mediante cambios exactos

.md canónico
→ siempre entregar archivo completo para reemplazar
→ nunca patch parcial
```

Audits temporales:

```text
pueden existir localmente
→ se prueban
→ se eliminan
→ recién después se cierra el bloque
```

Contracts permanentes:

```text
sí pueden permanecer
```

cuando representan reglas de dominio/gameplay y no nombres temporales del roadmap.

---

# 2. REPOSITORIOS

```text
Client:
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

# 3. HEADS REMOTOS VERIFICADOS — 07/09/2026

## Client

```text
51134e2e0033d70a1903153a94270aa8134aa1fb
docs: close F23 and plan combat roadmap
```

No fueron necesarios cambios Client para F24/F25/F26-A-D.

El Client ya podía representar:

```text
mob movement/state
mob HP
live character vitals
movement corrections
respawn position
```

mediante contratos autoritativos existentes.

## Game Server

HEAD actual:

```text
a9af9a1a26e3f3fee7c0557fcbbca8d58b9ba4df
feat: add authoritative pve enemy combat loop
```

Cadena reciente relevante:

```text
91df340be277f45eaa61a22624512bccafb6a2f5
feat: add unified damage taxonomy foundation

dfc717fc2f66b65ef70a462d957a903fbd63b562
feat: add damage resistance foundation

37520ed3c9db1a65b9046311eec873452469f06b
feat: add unified damage resolver

1e2704e4df939e1ddd50b6759c203f74a11ab8b8
feat: migrate combat damage to unified resolver

993f7802b0418b82c7aacc5bf233fcc6f54a7c38
refactor: finalize unified combat damage domain

7567d1d620028e3f46c5aaf85f6769953c5aa240
feat: add hit resolution and defensive outcomes

a9af9a1a26e3f3fee7c0557fcbbca8d58b9ba4df
feat: add authoritative pve enemy combat loop
```

## Backend

HEAD actual:

```text
ce3e0b02dbb1772204e12d1c2bb29d777b28b750
feat: expose equipment enhancement persistence endpoint
```

Backend no fue modificado durante F23/F24/F25/F26-A-D.

Esto es correcto:

```text
Combat hot loop
→ Game Server

no
→ Laravel por hit/tick/aggro/movement de mob
```

---

# 4. ESTADO GENERAL ACTUAL

```text
F00-F19 ✅
F20 ✅
F21-A ✅
F21-B ✅

F22-A ✅
F22-B ✅
F22-C ✅
F22-D ✅
F22-E ✅
F22-F ✅
F22-G ✅
F22-H ✅
F22-I ✅
F22-J ✅
F22-K ✅

F22 — Character Stats / Integrated Balance ✅ COMPLETE

F23-A ✅ Fire Ball Damage Foundation
F23-B ✅ Fire Ball Runtime Combat
F23-C ✅ Poison DoT Runtime

F23 — Skill Combat Effects ✅ COMPLETE

F24-A ✅ Damage Taxonomy + Resolution Context
F24-B ✅ Damage Resistance Foundation
F24-C ✅ Unified Damage Resolver
F24-D ✅ Basic Attack / Fire Ball / Poison migration
F24-E ✅ Unified Combat Damage audit/finalization

F24 — Unified Damage & Mitigation ✅ COMPLETE

F25 ✅ Hit Resolution & Defensive Outcomes COMPLETE

F26-A ✅ Aggro / Threat foundation
F26-B ✅ Mob movement / chase / leash / return
F26-C ✅ Mob Attack Profile + authoritative attack
F26-D ✅ Player damage / death / respawn
F26-E ⏳ HP/MP Regeneration Policy
```

Siguiente etapa exacta:

```text
F26-E — HP/MP Regeneration Policy
```

No abrir todavía F27.

---

# 5. ARQUITECTURA AUTORITATIVA — NO CAMBIAR

```text
Client
=
intención
+
representación
+
prediction limitada

Game Server
=
autoridad inmediata de gameplay/runtime

Backend Laravel
=
identidad
+
API durable
+
transacciones persistentes

MySQL
=
verdad durable
```

Combat hot loop:

```text
Client intent
→ Game Server validation
→ Game Server runtime mutation
→ authoritative result/events
→ Client representation
```

Incorrecto:

```text
attack/cast/mob tick/aggro/regen tick
→ Laravel
→ MySQL
→ esperar
→ gameplay
```

Laravel sólo entra cuando una operación necesita durabilidad.

No mover al Client:

```text
damage
hit roll
miss/dodge/block result
crit roll
range authority
cooldown authority
mana authority
armor mitigation
magic resistance mitigation
element resistance mitigation
skill scaling
status effect tick authority
mob HP
player HP
mob aggro
mob target selection
mob chase authority
mob attack
player death
respawn authority
future regen tick
PvP legality
PK penalty
```

---

# 6. DURABLE VS RUNTIME

Durable actualmente según dominio:

```text
Account / Character identity
Inventory
Equipment
Vault
Level
Experience
Map
Position
Rotation Y
Current HP
Current MP
Skill Ownership
Skill Learning provenance
Primary Stat allocations
Equipment Enhancement Level
```

Runtime Game Server, no durable como estado vivo:

```text
Derived Stats finales
cooldowns activos
Basic Attack runtime
Skill cast runtime
mob HP runtime
mob status effects
mob aggro/threat
mob combat target
mob chase path
mob return path
mob attack cadence
pending player respawn
future combat timer
future regen tick timer
future out-of-combat timer
WorldDrops no recogidos mientras vive GS
```

Regla:

> No persistir en MySQL un dato porque exista; persistir sólo si necesita sobrevivir a restart/logout según su dominio.

---

# 7. INPUT CANÓNICO ESTILO MU

Prioridad contextual del LEFT CLICK:

```text
LEFT CLICK WorldDrop
→ PICKUP

LEFT CLICK NPC interactuable
→ INTERACT

LEFT CLICK mob hostil
→ BASIC ATTACK PvE

LEFT CLICK terreno
→ MOVE
```

Skills:

```text
RIGHT CLICK
→ SELECTED SKILL
→ comportamiento según target_kind
```

PvP futuro:

```text
CTRL + LEFT CLICK player
→ BASIC ATTACK PvP

CTRL + RIGHT CLICK player
→ SELECTED SKILL PvP
```

Regla:

> El Client resuelve picking local; el Game Server vuelve a resolver y validar la entidad real.

Nunca enviar screen coordinates como autoridad de combate.

Target kinds conceptuales:

```text
self
entity
position
```

Actualmente implementados:

```text
self
entity
```

`position` sigue futuro.

---

# 8. BASIC ATTACK — CONTRATO CANÓNICO

Basic Attack NO es una Skill.

Protocolo:

```text
GameServerCombatProtocol
```

Client envía intención equivalente a:

```text
request_id
target.kind
target.entity_id
```

Client NO envía como verdad:

```text
weapon
attack mode
range
damage
cooldown
critical
hit result
```

Game Server resuelve:

```text
PlayerWorldSession
→ Equipment autoritativo
→ Basic Attack Profile
→ range
→ Attack Speed
→ Hit Resolution
→ Damage Context
→ Unified Damage Resolver
→ mob HP
→ death lifecycle
```

Modalidades:

```text
sin arma
→ unarmed

sword / axe / melee weapon
→ melee

bow / ranged weapon futuro
→ ranged
```

No renombrar:

```text
unarmed
```

---

# 9. BASIC ATTACK — FOUNDATION ACTUAL

## Unarmed

```text
base_damage = 500
range = 1.5
base_cooldown = 1.0
```

## Bronze Sword

```text
base weapon_damage = 1000
range = 2.0
base_cooldown = 0.9
```

Enhancement modifica intrinsic weapon damage mediante bonus flat acumulado.

Ejemplo durable probado:

```text
Bronze Sword +4
1000 + 80
= 1080
```

Current offensive scaling:

```text
Resolved Weapon / Unarmed Damage
+
Physical Power
=
raw damage context
```

Luego:

```text
Hit Outcome
→ Critical si corresponde
→ School mitigation
→ Element mitigation
→ Final Damage
```

---

# 10. PRIMARY → EFFECTIVE → DERIVED

Pipeline actual:

```text
Permanent Primary
+
Equipment Primary Contributions
=
Effective Primary

Effective Primary
+
Resolved Equipment Derived Contributions
=
Derived Stats
```

Permanent:

```text
Class Base
+
Allocated
+
future Permanent Bonuses
```

Equipment Requirements usan:

```text
Permanent Primary
```

Skill Learning Requirements usan:

```text
Permanent Primary
```

Nunca:

```text
Equipment bonus
→ habilitar su propio Equipment requirement

Equipment bonus
→ habilitar otro Equipment requirement

Equipment bonus
→ habilitar Skill Learning requirement
```

Derived Stats:

```text
NO se persisten como verdad durable final
```

Se recalculan en Game Server.

---

# 11. CLASS DERIVED BALANCE ACTUAL

## Warrior

Base Primary:

```text
STR 25
AGI 15
VIT 25
ENE 10
```

Vitals:

```text
Max HP
=
100
+
(level - 1) * 8
+
VIT * 4

Max MP
=
30
+
(level - 1) * 1
+
ENE * 3
```

Power:

```text
Physical
=
10
+
(level - 1) * 2
+
STR * 2

Magic
=
ENE

Healing
=
ENE
```

## Mage

Base Primary:

```text
STR 10
AGI 15
VIT 15
ENE 35
```

Vitals:

```text
Max HP
=
70
+
(level - 1) * 5
+
VIT * 3

Max MP
=
120
+
(level - 1) * 4
+
ENE * 5
```

Power:

```text
Physical
=
5
+
(level - 1)
+
STR

Magic
=
20
+
(level - 1) * 2
+
ENE * 2

Healing
=
10
+
(level - 1)
+
ENE * 2
```

## Archer

Base Primary:

```text
STR 15
AGI 30
VIT 15
ENE 15
```

Vitals:

```text
Max HP
=
85
+
(level - 1) * 6
+
VIT * 3

Max MP
=
70
+
(level - 1) * 2
+
ENE * 4
```

Power:

```text
Physical
=
15
+
(level - 1) * 2
+
STR
+
AGI

Magic
=
ENE

Healing
=
ENE
```

---

# 12. PRIMARY STAT PHILOSOPHY — NO ROMPER

Strength:

```text
principalmente melee Physical Power
```

Agility:

```text
ranged Physical identity
Accuracy
Evasion
Attack Speed pequeña/controlada
```

Vitality:

```text
principalmente Max HP
future HP Regen
```

Energy:

```text
Max MP
Magic Power
Healing Power
future MP Regen
```

Regla:

> Un Primary Stat no debe transformarse a la vez en la mejor fuente de daño, defensa, crit, velocidad y supervivencia.

Tradeoff deseado:

```text
más daño
↔
menos presupuesto defensivo

más supervivencia
↔
menos presupuesto ofensivo

utility
↔
daño puro
```

---

# 13. ATTACK SPEED ACTUAL

Attack Speed es Derived Stat y usa saturación por clase.

## Warrior

```text
1
+
0.35 * AGI / (AGI + 300)
```

## Mage

```text
1
+
0.25 * AGI / (AGI + 350)
```

## Archer

```text
1
+
0.60 * AGI / (AGI + 250)
```

Basic Attack:

```text
effective_cooldown
=
base_cooldown
/
attack_speed_multiplier
```

AGI:

```text
sí
→ aporta Attack Speed controlada

no
→ Movement Speed directa
```

---

# 14. MOVEMENT SPEED ACTUAL

Foundation:

```text
Movement Speed = 4.0
```

Primary Stats NO aumentan Movement Speed directamente.

Game Server usa velocidad autoritativa.

Client puede usarla para prediction.

El Game Server sigue siendo autoridad de posición final.

---

# 15. VITALS — ÚNICO PIPELINE

Game Server es autoridad de:

```text
HP
MP
Max HP
Max MP
```

Todos los sistemas convergen en los mismos Vitals:

```text
damage
Heal
future potions
future regeneration
mob attacks
PvP
death
respawn
```

No crear estados separados como:

```text
PotionHPSystem
HealHPSystem
CombatHPSystem
MobDamageHPSystem
```

Cambiar máximos live:

```text
NO rellena HP/MP automáticamente
```

Fresh bootstrap:

```text
current = max
```

Durable runtime:

```text
restaura current HP/MP
→ clamp contra máximos derivados actuales
```

---

# 16. EQUIPMENT / ENHANCEMENT — ESTADO CANÓNICO

Equipment puede contribuir a:

```text
Primary:
STR
AGI
VIT
ENE

Combat:
weapon_damage
armor_rating
magic_resistance_rating
elemental resistance ratings
accuracy_rating
evasion_rating
dodge_chance
block_chance
future modifiers
```

Equipment es autoritativo y durable.

Enhancement Level es estado durable por ItemInstance.

Bronze Sword de Atilio:

```text
+4
```

Enhancement usa BONUS FLAT ACUMULADO.

NO porcentajes.

Weapon Damage:

```text
+0    +0
+1   +20
+2   +40
+3   +60
+4   +80
+5  +100
+6  +125
+7  +150
+8  +180
+9  +220
+10 +270
+11 +330
+12 +400
+13 +500
```

Armor Rating:

```text
+0    +0
+1    +1
+2    +2
+3    +3
+4    +4
+5    +5
+6    +6
+7    +7
+8    +9
+9   +11
+10  +14
+11  +17
+12  +21
+13  +26
```

Future Jewel System permanece diferido.

No mezclarlo con Combat actual.

---

# 17. SKILL SCALING / LEARNING / RESET-SAFE

Skill Scaling:

```text
Effect
=
Flat
+
Power Source * Coefficient
```

Power Sources actuales:

```text
none
physical_power
magic_power
healing_power
```

Learning Requirements usan:

```text
Permanent Primary
```

Current requirements:

```text
Fire Ball
Mage
Level 10
ENE 50

Poison
Archer
Level 10
AGI 45

Heal
Warrior/Mage/Archer
Level 5
ENE 20
```

Reset-safe usage:

```text
Learning Requirements
!=
Cast Requirements
```

Una Skill ya aprendida no revalida al castear:

```text
minimum learning Level
learning Primary requirements
reset_count
```

Ownership durable persiste.

---

# 18. F23 — SKILL COMBAT EFFECTS ✅ COMPLETE

## Heal

```text
real
→ usa Healing Power
→ muta ServerVitalsState
```

## Fire Ball

```text
Mana Cost = 30
Cooldown = 3.0 s
Range = 6.0
Target = entity

Scaling:
Flat 0
+
Magic Power * 1.0
```

Test histórico real:

```text
Mage L10
Magic Power 138

Goblin:
5000 → 4862

Damage = 138
MP 406 → 376
```

## Poison

```text
Mana Cost = 20
Cooldown = 5.0 s
Range = 6.0
Target = entity

Scaling por tick:
Flat 0
+
Physical Power * 0.20

Tick Interval = 1.0 s
Tick Count = 5
Duration = 5.0 s
Stacking = no
Refresh Policy = replace
```

Test histórico Lyra:

```text
Physical Power = 228

floor(228 * 0.20)
= 45 damage/tick

5 ticks
= 225 total
```

Poison mantiene:

```text
scaling source = Physical Power
```

pero defensivamente F24 formalizó:

```text
school = magical
element = poison
```

Scaling Source, Damage School y Damage Element son conceptos distintos.

---

# 19. F24 — UNIFIED DAMAGE & MITIGATION ✅ COMPLETE

F24 consolidó un único dominio de Damage para evitar pipelines paralelos.

Objetivo alcanzado:

```text
Basic Attack
Fire Ball
Poison
→ comparten primitives de Damage
```

Sin convertir Heal en Damage.

Artifacts permanentes principales incluyen:

```text
ServerDamageTaxonomy
ServerDamageResolutionContext
ServerDamageDefenseProfile
ServerCharacterDamageDefenseProfileResolver
ServerMobDamageDefenseProfileResolver
ServerResistanceMitigationRules
ServerDamageResolver
ServerDamageResolutionResult
```

Integrated Balance Contract valida el dominio.

---

# 20. F24 — DAMAGE TAXONOMY

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

Delivery:

```text
direct
periodic
```

Ejemplos:

```text
Basic Attack Sword
→ physical / none / direct

Fire Ball
→ magical / fire / direct

Poison tick
→ magical / poison / periodic
```

Context separa:

```text
raw_damage
school
element
delivery
can_critical
source_kind
source_id
```

Source kinds foundation:

```text
basic_attack
skill
status_effect
```

---

# 21. F24 — DEFENSIVE PROFILE

Player y Mob pueden exponer un profile compatible con:

```text
Armor Rating
Magic Resistance Rating
Fire Resistance Rating
Cold Resistance Rating
Lightning Resistance Rating
Poison Resistance Rating
```

Physical school consume:

```text
Armor
```

Magical school consume:

```text
Magic Resistance
```

Element `none`:

```text
no consume elemental resistance
```

Fire / Cold / Lightning / Poison:

```text
consume su rating correspondiente
```

Derived/equipment-resolved defenses NO son verdad durable final separada.

Se reconstruyen desde fuentes reales.

---

# 22. F24 — MITIGATION FOUNDATION

Rating mitigation usa foundation de diminishing returns equivalente a:

```text
post_damage
=
floor(
	pre_damage * 1000
	/
	(rating + 1000)
)
```

Daño positivo mínimo:

```text
1
```

Esto aplica por capa:

```text
School mitigation
→ Element mitigation
```

Ejemplo Fire Ball del contract:

```text
Raw 138
MR 100
→ 125

Fire Resistance 50
→ 119
```

Ejemplo Poison del contract:

```text
Raw 45
MR 80
→ 41

Poison Resistance 30
→ 39
```

---

# 23. F24/F25 — CURRENT DAMAGE PIPELINE

Pipeline vigente:

```text
Raw Damage
↓
Hit / Defensive Outcome
├── miss  → no Damage Resolver
├── dodge → no Damage Resolver
├── hit   → multiplier 1.0
└── block → multiplier 0.5 foundation
↓
Post Outcome Damage
↓
Critical si can_critical
↓
School Mitigation
├── physical → Armor
└── magical  → Magic Resistance
↓
Element Mitigation
├── none → 0 rating
└── element → corresponding resistance
↓
future PvP modifier hook
↓
Final Damage
```

IMPORTANTE:

```text
Block
→ ocurre antes de Critical + Mitigation
```

Current resolver recibe:

```text
outcome_damage_multiplier
```

Miss/Dodge no deberían entrar al resolver.

---

# 24. CRITICAL ACTUAL

Foundation:

```text
Critical Strike Chance = 0.0
Critical Damage Multiplier = 1.5
```

Basic Attack:

```text
can_critical = true
```

Fire Ball foundation:

```text
can_critical = false
```

Poison tick:

```text
can_critical = false
```

Game Server realiza el roll.

Client nunca decide Critical.

Decisión histórica supersedida:

```text
Crit base ~5%
```

Estado real actual:

```text
Crit Chance 0.0
Crit Multiplier 1.5
```

---

# 25. F25 — HIT RESOLUTION & DEFENSIVE OUTCOMES ✅ COMPLETE

F25 dejó un dominio reutilizable para:

```text
Accuracy
Evasion
Dodge
Block
miss/hit/dodge/block outcomes
```

RNG:

```text
Game Server
```

Client:

```text
representación futura/feedback
```

Artifacts principales incluyen:

```text
ServerCombatHitProfile
ServerCharacterCombatHitProfileResolver
ServerMobCombatHitProfileResolver
ServerHitResolutionRules
ServerHitResolutionResult
ServerHitResolutionContract
```

Basic Attack fue migrado al dominio.

Mob Attack de F26 reutiliza las mismas primitives.

---

# 26. CHARACTER HIT PROFILE FOUNDATION

Resolución del Character:

```text
BASE_ACCURACY_RATING = 100
ACCURACY_PER_AGILITY = 2
EVASION_PER_AGILITY = 1
```

Conceptualmente:

```text
Accuracy
=
100
+
Effective AGI * 2
+
Equipment Accuracy
```

```text
Evasion
=
Effective AGI
+
Equipment Evasion
```

Dodge:

```text
Equipment Dodge Chance
```

Block:

```text
Equipment Block Chance
```

Los Primary bonuses de Equipment participan mediante Effective Primary.

---

# 27. HIT CHANCE FOUNDATION

Fórmula:

```text
si Evasion = 0
→ Hit Chance = 1.0
```

En general:

```text
Hit Chance
=
Accuracy
/
(Accuracy + Evasion)
```

El resultado se clampa a:

```text
0.0 .. 1.0
```

Ejemplo F26 observado:

```text
Mob Accuracy = 100
Player Evasion = 15

Hit Chance
=
100 / 115
=
0.869565...
```

---

# 28. DODGE / BLOCK FOUNDATION

Caps:

```text
MAX_DODGE_CHANCE = 0.75
MAX_BLOCK_CHANCE = 0.75
```

Block foundation:

```text
BLOCK_DAMAGE_MULTIPLIER = 0.50
```

Order:

```text
1. hit roll
2. dodge roll
3. block roll
```

Outcomes:

```text
miss
→ multiplier 0
→ no damage

dodge
→ multiplier 0
→ no damage

block
→ multiplier 0.5
→ daño continúa por unified resolver

hit
→ multiplier 1.0
```

Un ataque válido puede ser:

```text
accepted = true
+
outcome miss/dodge
+
0 HP mutation
```

Cooldown se consume porque la acción sí se ejecutó.

---

# 29. HIT POLICY — NO GENERALIZAR MAL

No todas las Skills deben hacer el mismo hit roll.

Current seguro:

```text
Basic Attack
→ Hit Resolution

Mob Basic Attack
→ Hit Resolution

Poison periodic ticks
→ NO nuevo accuracy roll por cada tick

Heal
→ NO offensive hit resolution
```

Future projectile skills:

```text
policy propia declarada por definition/profile
```

No decidir por nombre dentro de coordinators.

---

# 30. F26 — PvE ENEMY COMBAT LOOP

Objetivo:

> Completar el loop ofensivo del primer Training Goblin antes de escalar a muchos mobs.

Estado:

```text
F26-A ✅
Aggro / Threat foundation

F26-B ✅
Mob movement / chase / leash / return

F26-C ✅
Mob Attack Profile + authoritative attack

F26-D ✅
Player damage / death / respawn

F26-E ⏳
HP/MP Regeneration Policy
```

Commit actual que cierra A-D:

```text
a9af9a1a26e3f3fee7c0557fcbbca8d58b9ba4df
feat: add authoritative pve enemy combat loop
```

---

# 31. TRAINING GOBLIN — CURRENT FOUNDATION

Identidad:

```text
mob_type_id = training_goblin
entity_id = mob_test_town_001
map = test_town
spawn = (4, 0, 4)
level = 1
max_hp = 5000
EXP reward = 50
mob respawn delay = 3.0 s
```

Damage Defense:

```text
Armor = 100
Magic Resistance = 0
Fire Resistance = 0
Cold Resistance = 0
Lightning Resistance = 0
Poison Resistance = 0
```

Hit Profile:

```text
Accuracy = 100
Evasion = 0
Dodge = 0.0
Block = 0.0
```

PvE Combat:

```text
Aggro Radius = 5.0
Leash Radius = 10.0
Combat Movement Speed = 2.5
Attack Range = 1.5
Attack Cooldown = 1.25 s
Base Attack Damage = 200
```

Estos números son foundation de prueba.

NO balance definitivo.

---

# 32. MOB COMBAT RUNTIME

Se agregó runtime separado del mob para evitar convertir `WorldMobRuntimeState` en un God Object.

Concepto principal:

```text
WorldMobRuntimeState
└── combat_runtime
```

Artifact:

```text
WorldMobCombatRuntime
```

Estados conceptuales:

```text
idle
chasing / combat movement
attacking / target retained
returning
```

El runtime mantiene datos temporales como:

```text
target_peer_id
combat state
attack cadence/deadline
repath timing
return state
```

No persistirlo.

---

# 33. MOB DEFINITION — PvE COMBAT PROFILE

`WorldMobDefinition` ahora posee:

```text
aggro_radius
leash_radius
combat_movement_speed
attack_range
attack_cooldown_seconds
base_attack_damage
```

Validation exige que, si existe cualquier parte del PvE combat profile, sea completo.

Relaciones importantes:

```text
leash_radius >= aggro_radius
attack_range <= aggro_radius
combat_movement_speed > 0
attack_cooldown > 0
base_attack_damage > 0
```

Profile incompleto:

```text
inválido
```

---

# 34. F26-A — AGGRO / TARGET FOUNDATION ✅

Current acquisition principal:

```text
proximity
```

Flow:

```text
mob idle
→ busca target válido cercano
→ nearest target dentro de aggro radius
→ acquire target
```

Validación del target incluye conceptualmente:

```text
sesión existe
target vivo
same map
target válido
```

Mob también escucha damage recibido para poder reaccionar a Combat source/context cuando corresponda.

Threat completo multi-source queda evolutivo.

Foundation actual logra:

```text
proximity aggro real
combat target real
invalidación de target
release
```

No persistir target/threat.

---

# 35. F26-B — CHASE / LEASH / RETURN ✅

Mob movement es Game Server authoritative.

Usa navegación existente.

No duplica un segundo world movement engine.

Cadence interna actual relevante:

```text
Mob state replication sample = 0.10 s
Repath interval = 250 ms
```

Flow:

```text
target fuera de attack range
→ chase
→ navegación
→ actualizar posición del mob
→ replicar mob state
```

Cuando entra en range:

```text
chase termina
→ attack phase
```

Leash:

```text
mob/target excede policy desde spawn
→ release target
→ returning
```

Return:

```text
returning
→ navega al spawn
→ al alcanzar spawn
→ combat reset
→ idle
```

Target inválido:

```text
death/disconnect/map invalid/etc.
→ release
→ return
```

---

# 36. MOVEMENT COORDINATION PLAYER + MOB

F26 tocó `MovementCoordinator` porque player movement y mob combat necesitan convivir sin dos autoridades distintas sobre navegación.

Regla:

```text
Player movement
→ MovementCoordinator / WorldMovementSystem

Mob combat movement
→ MobCombatCoordinator
→ WorldNavigationRegistry primitives
```

No duplicar:

```text
NavMesh
map registry
world map authority
```

Client sigue sin decidir movimiento del mob.

---

# 37. F26-C — MOB BASIC ATTACK ✅

Mob attack usa un profile/ruleset propio de dominio:

```text
ServerMobBasicAttackRules
ServerMobCombatRules
```

Pero reutiliza primitives generales de Combat:

```text
ServerCombatHitProfile
ServerHitResolutionRules
ServerDamageResolutionContext
ServerDamageResolver
ServerCharacterDamageDefenseProfileResolver
ServerVitalsState
```

Pipeline:

```text
Mob Definition
→ target session
→ attack range
→ attack cooldown
→ mob Hit Profile
→ character Hit Profile
→ Hit Resolution
→ physical/none/direct Damage Context
→ Character Damage Defense Profile
→ Unified Damage Resolver
→ ServerVitalsState
→ authoritative vitals replication
```

No existe:

```text
player.hp -= 200
```

hardcodeado en MobActor/Client.

---

# 38. MOB ATTACK — CURRENT DAMAGE

Training Goblin:

```text
Raw Damage = 200
School = physical
Element = none
Delivery = direct
```

Current Atilio test:

```text
Armor = 0
```

Por eso hits normales observados:

```text
Raw = 200
Outcome multiplier = 1.0
Post Outcome = 200
Armor = 0
Final = 200
```

Último golpe:

```text
HP remaining = 184
Final Damage = 200
Applied Damage = 184
HP = 0
```

Clamp correcto del Vitals runtime.

---

# 39. F26-D — PLAYER DAMAGE / DEATH / RESPAWN ✅

Player damage converge en:

```text
ServerVitalsState
```

No existe segundo Vitals para PvE.

Death:

```text
HP > 0
→ mob damage
→ HP = 0
→ player defeated
```

Al morir:

```text
mob libera aggro
target_dead
player queda pendiente de respawn
```

Player respawn delay actual:

```text
3.0 s
```

Current respawn foundation:

```text
position = (0, 0, 0)
HP = max_hp
MP = max_mp
```

Respawn es autoritativo.

Client recibe:

```text
live vitals
movement/position final
```

---

# 40. F26 A-D — TEST E2E REAL ✅

Personaje:

```text
Atilio
Warrior
Level 124
```

Snapshot observado:

```text
Max HP = 1184
Max MP = 183
```

Mob:

```text
Training Goblin
5000/5000
spawn (4,0,4)
```

Secuencia comprobada:

```text
1. conexión/autenticación
2. world snapshot
3. mob spawn
4. proximity aggro
5. attack range
6. mob attack
7. player se aleja
8. goblin chase
9. player vuelve a detenerse
10. goblin alcanza attack range
11. hits + miss reales
12. player HP llega a 0
13. aggro liberado por target_dead
14. player respawn después de 3 s
15. player HP/MP full
16. posición (0,0,0)
17. mob vuelve al spawn
18. return completed en (4,0,4)
```

Vitals observados:

```text
1184
→ 984
→ 784
→ 584
→ 384
→ 184
→ 0
→ respawn 1184
```

MP al respawn:

```text
183/183
```

Hit Resolution real observado:

```text
Mob Accuracy = 100
Player Evasion = 15
Hit Chance ≈ 0.869565
```

También ocurrió:

```text
Outcome = miss
→ sin daño
```

Esto valida que F25 no quedó sólo como contract sintético.

---

# 41. F26 — ARCHIVOS PRINCIPALES

Nuevos/permanentes del checkpoint A-D:

```text
app/coordinators/mob_combat_coordinator.gd
core/balance/server_pve_enemy_combat_contract.gd
core/combat/server_mob_basic_attack_rules.gd
core/combat/server_mob_combat_rules.gd
core/world/mobs/world_mob_combat_runtime.gd
```

Más sus `.uid` correspondientes.

Integración/modificación:

```text
app/coordinators/movement_coordinator.gd
app/main.gd
app/main.tscn
core/balance/server_integrated_balance_contract.gd
core/world/mobs/world_mob_definition.gd
core/world/mobs/world_mob_registry.gd
core/world/mobs/world_mob_runtime_state.gd
```

`ServerPveEnemyCombatContract` es permanente porque valida reglas reales del dominio.

---

# 42. INTEGRATED BALANCE / STARTUP CONTRACTS

Startup actual valida, entre otros:

```text
Mob Drop Catalog Contract
Class Stats Catalog Contract
Skill Catalog Contract
Skill Learning Catalog Contract
Integrated Balance Contract
Equipment Domain Contract
Equipment Snapshot Contract
Equipment Transfer Contract
Basic Attack Profile Contract
Physical Defense Profile Contract
Hit Resolution Contract integrado
PvE Enemy Combat Contract integrado
```

Objetivo:

```text
cambiar balance conscientemente
!=
romper relaciones críticas sin enterarse
```

No crear contracts con nombres temporales de roadmap cuando la regla es permanente.

---

# 43. F26-E — SIGUIENTE CHECKPOINT EXACTO

Nombre:

```text
F26-E — HP/MP Regeneration Policy
```

Objetivo:

> Incorporar regeneración autoritativa de HP/MP al Game Server sin duplicar Vitals ni mezclarla con MobCombatCoordinator.

No empezar F27 antes de cerrar F26-E.

---

# 44. F26-E — POLÍTICA INICIAL ACORDADA

Implementar:

```text
Tick autoritativo = 1.0 s
```

Jugador muerto:

```text
HP <= 0
→ no regenera
```

Recurso lleno:

```text
current >= max
→ no mutar
→ no broadcast inútil
```

HP Regen:

```text
sólo fuera de combate
```

MP Regen foundation:

```text
sólo fuera de combate
```

Salida de combate:

```text
5.0 s
sin interacción hostil
```

Actividad de combate debe incluir al menos:

```text
recibir daño de mob
realizar una acción ofensiva válida contra mob
```

No inventar un segundo Combat state aislado.

Reutilizar puntos autoritativos existentes.

---

# 45. F26-E — REGEN VALUES

`ServerCharacterDerivedStatsState` ya posee foundation histórica para:

```text
hp_regeneration
mp_regeneration
```

Hasta ahora esos valores permanecieron en:

```text
0
```

F26-E debe convertirlos en consumers reales.

Fuente conceptual:

```text
VIT
→ HP Regeneration

ENE
→ MP Regeneration
```

Pero la primera fórmula debe ser:

```text
mínima
explícita
centralizada
fácil de balancear
```

NO crear todavía una fórmula compleja definitiva.

NO hardcodear cantidades de regen dentro del coordinator.

Valores:

```text
Derived Stats / Balance Contract
→ coordinator consume
```

---

# 46. F26-E — CLAMP

Siempre:

```text
hp = min(max_hp, hp + hp_regen)
mp = min(max_mp, mp + mp_regen)
```

Usar primitives existentes de Vitals.

No mutar diccionarios arbitrarios.

No crear un segundo HP/MP state.

---

# 47. F26-E — REPLICATION

Todo cambio real de regen debe reutilizar el pipeline que actualmente produce:

```text
Vitals autoritativos actualizados
```

Flow:

```text
Game Server regen tick
→ ServerVitalsState mutation
→ authoritative vitals event
→ GameServerClient
→ PlayerRuntimeState
→ HUD
```

No crear:

```text
regen_protocol.gd
```

sólo porque la causa del cambio fue regeneración, salvo necesidad estructural real demostrada.

El Client no necesita conocer cómo se calculó el tick para representar HP/MP.

---

# 48. F26-E — COMBAT TIMER

Estado temporal requerido:

```text
last_hostile_activity
in_combat / equivalent
regen accumulator/tick timing
```

Todo esto:

```text
runtime Game Server
```

NO persistir:

```text
combat timer
out-of-combat deadline
regen tick accumulator
```

Muerte/respawn:

```text
limpiar/resetear correctamente
```

Después del respawn:

```text
no debe quedar combat lock residual permanente
```

---

# 49. F26-E — RESPONSABILIDAD ARQUITECTÓNICA

No convertir:

```text
MobCombatCoordinator
```

en un sistema general de regeneración.

Preferencia:

```text
responsabilidad propia
```

por ejemplo:

```text
CharacterRegenCoordinator
```

o nombre equivalente coherente con el código real.

Debe reutilizar:

```text
ServerVitalsState
PlayerWorldSession/runtime state
Derived Stats
Integrated Balance Contract
BasicAttackCoordinator / SkillCastCoordinator integration points
MobCombatCoordinator integration points
existing vitals replication
```

Evitar dependencia circular.

---

# 50. F26-E — TESTS MANUALES REQUERIDOS

## Test 1 — daño

```text
Training Goblin golpea player
→ HP baja
→ mientras está en combat
→ NO regen
```

## Test 2 — escapar

```text
player se aleja
→ mob pierde/rompe combate según policy
→ esperar 5 s
→ regen comienza
→ HP/MP suben autoritativamente
```

## Test 3 — caps

```text
llegar a max HP/MP
→ nunca superar máximos
→ no ticks inútiles posteriores
```

## Test 4 — reingreso

```text
regen activa
→ entrar nuevamente en combat
→ regen se detiene inmediatamente
```

## Test 5 — muerte

```text
morir
→ no regen mientras muerto
→ respawn
→ no stale combat lock
```

Al terminar implementación:

```text
NO commit
NO push
```

Primero:

```text
test
→ logs Client + GS
→ git status
→ revisar scope
→ commit
→ push
```

---

# 51. QUÉ NO IMPLEMENTAR EN F26-E

No agregar:

```text
consumibles
life steal
mana steal
regen buffs
regen debuffs
regen por equipment especial
resting/campfire
food
status effects generales
visual FX de regen
fórmulas definitivas complejas
```

No modificar salvo necesidad estricta:

```text
Inventory
Equipment
Drops
Skill ownership
Progression durable
Backend Laravel
World navigation
UI
```

---

# 52. ROADMAP CANÓNICO POST-F26

```text
F27 — Action Approach / Auto-Chase

F28 — Ranged / LOS / Projectile / Position Combat

F29 — General Status Effects / Crowd Control

F30 — PvP Combat Foundation

F31 — PK / Sin / Auto-Defense

F32 — Combat Presentation & Feel
```

No abrir dos bloques grandes simultáneamente.

---

# 53. F27 — ACTION APPROACH / AUTO-CHASE

Auto-chase sigue deliberadamente diferido.

Objetivo UX:

```text
click target fuera de range
→ no exigir clicks repetidos
→ approach mediante navegación
→ al entrar en range
→ ejecutar acción una vez
```

Casos:

```text
Basic Attack
entity Skill
future NPC action si alguna vez aplica
```

Debe reutilizar navegación existente.

No duplicar `WorldMovementSystem`.

Cancellation/replacement debe ser explícito:

```text
nuevo input
target muerto
target desaparece
target cambia mapa
acción deja de ser válida
```

No mandar attack/cast request cada frame.

---

# 54. F28 — RANGED / LOS / PROJECTILE / POSITION

Incluye progresivamente:

```text
ranged Basic Attack real
Bow foundation
line-of-sight
projectile policy
position target
AoE target resolution
```

LOS:

```text
Game Server authority
```

Client puede hacer:

```text
picking
preview
feedback
```

pero no autoriza hit.

Projectile visible:

```text
!= damage authority
```

Cada acción decidirá:

```text
instant authoritative + visual projectile
```

o:

```text
server projectile runtime
```

según necesidad real.

---

# 55. F29 — GENERAL STATUS EFFECTS / CC

Poison es el primer DoT real.

No asumir que todos los statuses son Poison.

Categorías:

```text
Buff
Debuff
DoT
Soft CC
Hard CC
```

Necesita policies de:

```text
duration
stacking
refresh
source attribution
expiration
replication
```

Anti-permacontrol obligatorio:

```text
NO permanent stun
NO permanent root
NO permanent silence
```

Future:

```text
Tenacity
Control Resistance
Diminishing Returns
duration caps
immunity windows si corresponde
```

DoTs:

```text
NO stackean infinitamente por defecto
```

Poison actual:

```text
same effect_id
→ replace
```

---

# 56. F30 — PvP COMBAT FOUNDATION

Input futuro:

```text
CTRL + LEFT player
→ Basic Attack PvP

CTRL + RIGHT player
→ selected Skill PvP
```

No convertir click normal en ataque accidental.

PvP debe reutilizar Combat.

NO crear:

```text
PvPDamageSystem
```

paralelo.

Pipeline:

```text
normal Combat resolution
→ PvP modifier layer
→ Player ServerVitalsState
→ player death
```

Game Server valida:

```text
target player
same map
range
LOS
safe zone
map PvP policy
attacker state
target state
auto-defense
equipment
skill
mana
cooldown
hit
damage
kill
```

---

# 57. F31 — PK / SIN / AUTO-DEFENSE

Separación obligatoria:

```text
Combat
→ hit / damage / death

PvP Domain
→ legalidad / aggression / self-defense

PK/Sin Domain
→ penalización

Backend
→ criminal state durable

Presence
→ replica estado necesario

Client
→ representa visual/feedback
```

Auto-defense:

```text
runtime Game Server
```

Criminal/Sin:

```text
durable
```

Sinner máximo:

```text
Pecador / Sinner
```

Otros players podrán atacarlo sin penalización según futura policy.

Client red tint:

```text
representa estado autoritativo
```

Priest Confession depende de:

```text
PvP real
PK/Sin real
Economy real
```

No implementarlo antes.

---

# 58. F32 — COMBAT PRESENTATION & FEEL

Gameplay authority:

```text
!=
Presentation
```

Client será dueño visual de:

```text
attack animations
cast animations
hit reactions
death animations
respawn visuals
Fire Ball VFX
Poison VFX
projectile visuals
floating damage numbers
floating heal numbers
critical feedback
miss/dodge/block feedback
status visuals
SFX
camera feedback
```

Pero todo representa resultados del Game Server.

Nunca autoriza damage.

---

# 59. CURRENT VISUAL LIMITATIONS

La mecánica ya avanzó más que la presentación.

Todavía existen placeholders/foundation en:

```text
MobActor representation
combat animations finales
hit reactions
death presentation
floating damage
Fire Ball VFX
Poison VFX
miss/dodge/block visual feedback
```

No mezclar un mega art pass con el backbone mecánico.

F32 sigue dedicado a eso.

---

# 60. CURRENT TEST CHARACTER — ATILIO

Checkpoint F26 observado:

```text
Character ID 1
Name Atilio
Class Warrior
Level 124
Reset 0
```

Primary snapshot observado:

```text
Base:
STR 25
AGI 15
VIT 25
ENE 10

Allocated:
STR +12
AGI +0
VIT +0
ENE +0

Permanent:
STR 37
AGI 15
VIT 25
ENE 10
```

Derived snapshot observado:

```text
Max HP = 1184
Max MP = 183
Physical Power = 330
Magic Power = 10
Healing Power = 10
Crit Chance = 0.0
Crit Multiplier = 1.5
Attack Speed ≈ 1.0166667
Movement Speed = 4.0
```

Skill:

```text
heal
```

Equipment histórico:

```text
Bronze Sword +4
```

---

# 61. DECISIONES HISTÓRICAS SUPERSEDIDAS

## Poison scaling

Histórico conceptual:

```text
Energy principal
+ posible Agility
```

Estado real:

```text
Physical Power * 0.20 per tick
```

Prevalece F23.

## Poison defensive taxonomy

Estado real F24:

```text
magical / poison / periodic
```

Independiente del scaling source.

## Reset Skill Usage

Histórico:

```text
Skill aprendida podría quedar no usable post-reset
por learning requirements
```

Estado real:

```text
learning requirements no se revalidan al cast
```

## Critical

Histórico conceptual:

```text
base ~5%
```

Estado real:

```text
Crit Chance 0.0
Crit Multiplier 1.5
```

## Attack Speed

Histórico conceptual:

```text
generic percent bonus
```

Estado real:

```text
class-specific diminishing curves
```

## Damage pipeline

Histórico PM5 previo:

```text
F24 planned
```

Estado real actual:

```text
F24 complete
unified resolver live
```

## Hit / Dodge / Block

Histórico PM5 previo:

```text
future F25
```

Estado real actual:

```text
F25 complete
Basic Attack + Mob Attack consumers reales
```

## Mob offensive combat

Histórico PM5 previo:

```text
gap F26 planned
```

Estado real actual:

```text
F26-A/B/C/D complete
E2E tested
```

---

# 62. REGLAS DE COMBAT QUE NO DEBEN REGRESIONAR

```text
1. Client nunca decide damage final.
2. Backend nunca entra al hot loop por hit/cast/tick/aggro/regen.
3. Basic Attack es independiente de Skills.
4. LEFT CLICK mob = Basic Attack PvE.
5. RIGHT CLICK = selected Skill.
6. CTRL + LEFT player = future Basic Attack PvP.
7. CTRL + RIGHT player = future selected Skill PvP.
8. Equipment real determina Basic Attack profile.
9. `unarmed` sigue siendo nombre canónico.
10. Range se valida en Game Server.
11. Cooldown se valida en Game Server.
12. Attack Speed modifica cadence server-side.
13. Physical Power alimenta Basic Attack.
14. Magic Power alimenta Fire Ball.
15. Healing Power alimenta Heal.
16. Poison escala con Physical Power * 0.20.
17. Poison es magical/poison/periodic defensivamente.
18. Poison ticks son server-side.
19. Poison no stackea infinitamente.
20. Current Poison same-effect policy = replace.
21. WorldMobRegistry centraliza damage/death de mobs.
22. EXP/Drop no dependen de BasicAttackCoordinator.
23. Skill kills convergen al mismo mob death lifecycle.
24. Armor usa diminishing rating.
25. Magic Resistance usa misma family de diminishing rating foundation.
26. Element Resistances son segunda capa después de School.
27. Crit no es decidido por Client.
28. Block ocurre antes de Critical/Mitigation como multiplier foundation.
29. Miss/Dodge no mutan HP.
30. Acción válida con miss/dodge puede seguir accepted=true.
31. Dodge y Block tienen cap foundation 0.75.
32. Block foundation conserva 50% de damage antes de crit/mitigation.
33. Accuracy/Evasion usan profiles, no fórmulas copiadas en coordinators.
34. Current Character Accuracy = 100 + Effective AGI*2 + Equipment.
35. Current Character Evasion = Effective AGI + Equipment.
36. Hit Chance = Accuracy/(Accuracy+Evasion), con Evasion 0 → 1.0.
37. AGI no aumenta Movement Speed directamente.
38. Derived Stats no son verdad durable final.
39. Vitals son compartidos por todas las fuentes de HP/MP.
40. Damage Scaling, School, Element y Delivery son conceptos distintos.
41. Basic Attack = physical/none/direct.
42. Fire Ball = magical/fire/direct.
43. Fire Ball foundation no crithea.
44. Poison tick no crithea.
45. Poison tick no hace nuevo hit roll por tick.
46. Heal no usa offensive hit resolution.
47. Mob Attack reutiliza Hit + Unified Damage + ServerVitalsState.
48. Mob aggro es runtime Game Server.
49. Mob target selection es server-side.
50. Mob movement/chase/return es server-side.
51. Mob combat profile vive en definition/domain, no Client.
52. Training Goblin actual es foundation, no balance final.
53. Player death por PvE es autoritativa.
54. Player respawn actual = 3 s, position (0,0,0), full HP/MP.
55. Mob libera target al morir el player.
56. Mob retorna a spawn tras release/leash/target invalid.
57. F26-E regen debe reutilizar Vitals/Derived, no crear segundo sistema.
58. Regen timer/combat timer serán runtime, no durable.
59. Auto-chase sólo entra en F27.
60. LOS será server-side cuando corresponda.
61. DoTs no stackean infinitamente por defecto.
62. CC futuro debe tener anti-permacontrol.
63. PvP reutiliza Combat, no duplica engine.
64. PK/Sin es dominio separado de hit/damage.
65. Auto-defense es runtime Game Server.
66. Criminal/Sin state durable pertenece a Backend/MySQL.
67. Sinner red tint es representación de estado autoritativo.
68. Priest confession depende de PvP/Sin + Economy real.
69. Combat presentation no decide gameplay.
70. No escalar contenido masivo antes de estabilizar cada capability.
```

---

# 63. NEXT EXACT CHECKPOINT

Estado de repositorios al momento de este documento:

```text
Client dev
→ 51134e2e0033d70a1903153a94270aa8134aa1fb

Game Server dev
→ a9af9a1a26e3f3fee7c0557fcbbca8d58b9ba4df

Backend dev
→ ce3e0b02dbb1772204e12d1c2bb29d777b28b750
```

Antes de escribir F26-E en un nuevo chat:

```text
1. reemplazar PROJECT_MEMORY_5.md con ESTE archivo completo
2. git status en Client
3. confirmar que sólo cambió PROJECT_MEMORY_5.md
4. commit documental
5. push dev
6. usuario dice "pusheado"
7. verificar remoto
8. recién entonces abrir F26-E
```

Commit documental sugerido:

```text
docs: update combat state through F26 pve loop
```

Después:

```text
F26-E — HP/MP Regeneration Policy
```

---

# 64. PROMPT DE RETOMA PARA NUEVO CHAT

```text
Continuamos VHAL desde los PROJECT_MEMORY canónicos.

Leer obligatoriamente, en orden:
PROJECT_MEMORY.md
PROJECT_MEMORY_2.md
PROJECT_MEMORY_3.md
PROJECT_MEMORY_4.md
PROJECT_MEMORY_5.md

y después revisar los repositorios reales en branch dev.

Estado actual:

F24 — Unified Damage & Mitigation ✅ COMPLETE
F25 — Hit Resolution & Defensive Outcomes ✅ COMPLETE
F26-A/B/C/D — PvE Enemy Combat Loop ✅ COMPLETE, probado E2E y pusheado

Game Server HEAD esperado:
a9af9a1a26e3f3fee7c0557fcbbca8d58b9ba4df
feat: add authoritative pve enemy combat loop

Siguiente scope ÚNICO:
F26-E — HP/MP Regeneration Policy.

No abrir F27 todavía.

Mantener workflow:
implementación → test → git status → review scope → commit → push → "pusheado".
```

---

# 65. RESUMEN CORTO PARA RETOMAR

```text
VHAL ya tiene:

F22 Stats/Balance ✅
F23 Heal + Fire Ball + Poison ✅
F24 Unified Damage + Resistances ✅
F25 Accuracy/Evasion/Dodge/Block ✅
F26-A Aggro ✅
F26-B Chase/Leash/Return ✅
F26-C Mob Attack ✅
F26-D Player Death/Respawn ✅

Training Goblin actual:
Aggro 5
Leash 10
Move 2.5
Range 1.5
Cooldown 1.25
Damage 200
Accuracy 100

Test E2E:
aggro
→ chase
→ hit/miss
→ player HP 1184→0
→ release
→ respawn 3 s
→ full HP/MP
→ mob return spawn
✅

NEXT:
F26-E HP/MP Regeneration Policy
```
