# VHAL — PROJECT MEMORY 5 / F22 COMPLETE → F23 COMPLETE → COMBAT ROADMAP

**Volumen:** 5  
**Inicio:** 06/09/2026  
**Última actualización canónica:** 06/09/2026  
**Motor Client / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`

---

# 0. ORDEN DE LECTURA Y PRECEDENCIA

Orden obligatorio:

```text
1. PROJECT_MEMORY.md
2. PROJECT_MEMORY_2.md
3. PROJECT_MEMORY_3.md
4. PROJECT_MEMORY_4.md
5. PROJECT_MEMORY_5.md
6. futuros volúmenes
7. repositorios reales branch dev
```

Precedencia:

> Este volumen prevalece para F22-G en adelante y para toda decisión de combate posterior cuando contradiga estados históricos anteriores.

Los repositorios reales en `dev` siguen prevaleciendo sobre memoria si el código cambió después de esta actualización.

Historial:

```text
PROJECT_MEMORY.md
→ arquitectura/F00-F19 + contrato original de Combat/PvP

PROJECT_MEMORY_2.md
→ F20/F21 + continuidad del input/combat foundation

PROJECT_MEMORY_3.md
→ F22 Stats/Progression/Resets + taxonomía futura de Damage/Resistance/PvP

PROJECT_MEMORY_4.md
→ cierre Derived Stats + primeros consumers reales

PROJECT_MEMORY_5.md
→ F22-G→K
→ F22 COMPLETE
→ F23 Skill Combat Effects COMPLETE
→ roadmap canónico de Combat F24+
```

---

# 1. WORKFLOW OBLIGATORIO ACTUAL

Ciclo canónico:

```text
FASE / ETAPA ACORDADA
→ implementación manual
→ test positivo
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
No hacer auditorías negativas de rutina.
No usar git diff --check de rutina.
No usar git diff --stat de rutina.
Usar git status como verificación local habitual.
No actualizar documentación salvo que esté explícitamente planificado o pedido.
No crear commits por el usuario.
```

Escenas y archivos:

```text
.tscn
→ siempre editar manualmente desde Godot Editor

.gd
→ puede entregarse completo o mediante cambios exactos

.md canónico
→ siempre archivo completo
→ nunca patch
```

Objetivo habitual:

```text
0 warnings
0 errors
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

si representan reglas de dominio/gameplay y no nombres temporales del roadmap.

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

Branch:

```text
dev
```

---

# 3. HEADS REMOTOS VERIFICADOS — 06/09/2026

## Client

```text
616dcc5c5f42235ee8ef90c4b0c178e58425ea98
docs: close F22 integrated balance
```

Este documento será el siguiente checkpoint documental del Client.

## Game Server

HEAD actual:

```text
a4836954a3e51246993d919e9903e091fc5b0c8a
feat: add poison periodic damage runtime
```

Cadena F23:

```text
48590affe224436e560b179a497cc20d546b8aca
feat: add fire ball magic damage foundation

b2564a2b5480138bedf9ad883c6737f4d0b3e180
feat: integrate fire ball runtime combat

a4836954a3e51246993d919e9903e091fc5b0c8a
feat: add poison periodic damage runtime
```

Anterior F22:

```text
c6114f22c52630f190952c7f1c9360df2f6838b3
feat: add integrated gameplay balance contract

cb84c83dfac5220b651159f09bab1af1a7bec563
feat: add skill scaling and usage requirements
```

## Backend

HEAD actual:

```text
ce3e0b02dbb1772204e12d1c2bb29d777b28b750
feat: expose equipment enhancement persistence endpoint
```

Backend no fue modificado durante F23.

---

# 4. ESTADO GENERAL

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

F22 ✅ COMPLETE

F23-A ✅
F23-B ✅
F23-C ✅

F23 — Skill Combat Effects ✅ COMPLETE
```

Siguiente fase planificada:

```text
F24 — Unified Damage & Mitigation
```

F24 será el comienzo del nuevo arco de Combat.

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
transacciones

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
→ clients
```

INCORRECTO:

```text
attack/cast/tick
→ Laravel
→ MySQL
→ esperar
→ gameplay
```

Laravel sólo entra cuando una operación necesita durabilidad.

No mover al Client:

```text
damage
hit
crit roll
range authority
cooldown authority
mana authority
armor mitigation
resistance mitigation
skill scaling
status effect tick authority
mob HP
player HP
death
PvP legality
PK penalty
future combat RNG
```

---

# 6. INPUT CANÓNICO ESTILO MU

Este contrato viene desde Volumen 1 y fue reafirmado en los volúmenes posteriores.

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

`position` queda futuro.

---

# 7. BASIC ATTACK — CONTRATO CANÓNICO

Basic Attack NO es una Skill.

Protocolo:

```text
GameServerCombatProtocol
```

Client envía:

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
→ damage
→ crit
→ mitigation
→ HP
→ death
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

# 8. BASIC ATTACK — VALORES FOUNDATION ACTUALES

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

Enhancement modifica el intrinsic weapon damage mediante bonus flat acumulado.

Ejemplo:

```text
Bronze Sword +4
1000 + 80
= 1080
```

Current Basic Attack:

```text
Resolved Weapon / Unarmed Damage
+
Physical Power
→ Pre-Crit
→ Critical si corresponde
→ Pre-Mitigation
→ Physical Armor
→ Final Damage
```

---

# 9. PHYSICAL DAMAGE / ARMOR ACTUAL

Physical Armor mitigation está implementada.

Foundation:

```text
K = 1000
```

Fórmula:

```text
post_damage
=
floor(
	pre_damage * 1000
	/
	(armor + 1000)
)
```

Daño positivo mínimo:

```text
1
```

Training Goblin:

```text
base_armor_rating = 100
```

Ejemplo real de Atilio:

```text
Bronze Sword +4
Base Damage: 1080

Physical Power: 330

Pre-Crit:
1080 + 330
= 1410

Critical:
false

Armor:
100

Post-Mitigation:
floor(1410 * 1000 / 1100)
= 1281
```

Resultado probado:

```text
Damage = 1281
```

---

# 10. CRITICAL ACTUAL

Foundation vigente:

```text
Critical Strike Chance = 0.0
Critical Damage Multiplier = 1.5
```

El Game Server realiza:

```text
crit roll
```

El Client nunca decide:

```text
critical success
critical multiplier aplicado
```

IMPORTANTE:

Volumen 3 contenía una dirección conceptual histórica de:

```text
Crit Chance base ~5%
```

pero ESO NO es el estado actual.

La implementación real posterior prevalece:

```text
Crit Chance foundation = 0.0
Crit Multiplier = 1.5
```

Futuro balance puede agregar fuentes reales de Crit sin reescribir el pipeline.

---

# 11. ATTACK SPEED ACTUAL

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

# 12. MOVEMENT SPEED ACTUAL

Foundation:

```text
Movement Speed = 4.0
```

Primary Stats NO aumentan Movement Speed directamente.

Game Server usa la velocidad autoritativa.

Client puede usarla para prediction.

El Game Server sigue siendo autoridad de movimiento.

---

# 13. PRIMARY → EFFECTIVE → DERIVED

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

Equipment Requirements:

```text
Permanent Primary
```

Skill Learning Requirements:

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

# 14. CLASS DERIVED BALANCE ACTUAL

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

# 15. PRIMARY STAT PHILOSOPHY — NO ROMPER

Strength:

```text
principalmente melee Physical Power
```

Agility:

```text
ranged Physical identity
Accuracy futura
Attack Speed pequeña/controlada
```

Vitality:

```text
principalmente Max HP
```

Energy:

```text
Max MP
Magic Power
Healing Power
```

Regla de balance:

> Un Primary Stat no debe transformarse al mismo tiempo en la mejor fuente de daño, defensa, crit, velocidad y supervivencia.

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

# 16. VITALS — ÚNICO PIPELINE

Game Server es autoridad de:

```text
HP
MP
Max HP
Max MP
```

Todos los sistemas deben converger en los mismos Vitals:

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

No crear:

```text
PotionHPSystem
HealHPSystem
CombatHPSystem
```

con estados separados.

Cambiar máximos live:

```text
NO rellena HP/MP automáticamente
```

Fresh bootstrap:

```text
current = max
```

Durable runtime después puede restaurar current HP/MP clampado.

---

# 17. F22-I — EQUIPMENT / ENHANCEMENT CERRADO

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
future modifiers
```

Equipment es autoritativo y durable.

Enhancement Level es estado durable por ItemInstance.

Bronze Sword actual de Atilio:

```text
+4
```

---

# 18. ENHANCEMENT — CURVAS FLAT

IMPORTANTE:

> Enhancement usa BONUS FLAT ACUMULADO. NO porcentajes.

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

Ejemplos:

```text
Bronze Sword base 1000

+4  = 1080
+7  = 1150
+13 = 1500
```

```text
Leather Helmet base 20

+7  = 27
+13 = 46
```

---

# 19. ENHANCEMENT — FUTURE JEWEL SYSTEM

Decidido pero NO implementado.

Target:

```text
Equipment debe estar desequipado
+
en Inventory
```

UX:

```text
drag Jewel
→ drop sobre Equipment
```

Future intent:

```text
jewel_uid
target_item_uid
```

Client NO envía:

```text
current +N
next +N
probability
RNG result
success/failure
authoritative container
```

Tiers:

```text
+0 → +6
Joya A

+6 → +9
Joya B

+9 → +13
TBD
```

Failure actual decidido:

```text
baja 1 nivel
```

Ejemplo:

```text
+5
→ fail
→ +4
```

RNG:

```text
Game Server
```

Persistencia futura atómica:

```text
consume Jewel
+
persist Enhancement result
```

Nunca una sola mitad.

Este sistema NO se mezcla con el arco inmediato de Combat F24+.

---

# 20. F22-J — SKILL SCALING / LEARNING / RESET-SAFE

Skill Scaling:

```text
Effect
=
Flat
+
Power Source * Coefficient
```

Power Sources:

```text
none
physical_power
magic_power
healing_power
```

Game Server:

```text
ServerSkillScalingResolver
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

Una Skill ya aprendida:

```text
no revalida
minimum learning Level
learning Primary requirements
reset_count
```

durante el cast.

Esta regla posterior reemplaza la dirección histórica vieja de Volumen 3 que sugería que una Skill aprendida podía quedar inutilizable post-Reset por perder requirements.

Estado canónico ACTUAL:

> Una Skill durablemente aprendida continúa usable post-Reset mientras cumpla las reglas live normales del cast.

---

# 21. F22-K — INTEGRATED BALANCE CONTRACT

Artifact permanente:

```text
core/balance/server_integrated_balance_contract.gd
```

Class:

```text
ServerIntegratedBalanceContract
```

No contiene `F22` en el nombre permanente.

Startup:

```text
ServerMain | Integrated Balance Contract validado.
```

El contract protege relaciones críticas del balance actual.

---

# 22. INTEGRATED BALANCE SNAPSHOTS

| Class / Level | Max HP | Max MP | Physical | Magic | Healing |
|---|---:|---:|---:|---:|---:|
| Warrior L1 | 200 | 60 | 60 | 10 | 10 |
| Mage L1 | 115 | 295 | 15 | 90 | 80 |
| Archer L1 | 130 | 130 | 60 | 15 | 15 |
| Warrior L100 | 992 | 159 | 258 | 10 | 10 |
| Mage L100 | 610 | 691 | 114 | 288 | 179 |
| Archer L100 | 724 | 328 | 258 | 15 | 15 |

Identidad relativa:

```text
HP:
Warrior > Archer > Mage

MP:
Mage > Archer > Warrior

Magic:
Mage > Archer > Warrior

Healing:
Mage > Archer > Warrior

Attack Speed inicial:
Archer > Warrior > Mage
```

---

# 23. F23 — SKILL COMBAT EFFECTS COMPLETE ✅

F23 cerró los dos consumers ofensivos que F22 había dejado deliberadamente pendientes.

Breakdown:

```text
F23-A
Fire Ball Damage Foundation
✅

F23-B
Fire Ball Runtime Combat Integration
✅

F23-C
Poison Status Effect / DoT Foundation
✅
```

Resultado:

```text
Heal
→ real

Fire Ball
→ real

Poison
→ real
```

Todos siguen Game Server authority.

---

# 24. F23-A — FIRE BALL DAMAGE FOUNDATION ✅

Se agregó:

```text
ServerSkillDamageProfile
ServerSkillDamageRules
```

Fire Ball:

```text
mana = 30
cooldown = 3.0
target = entity

Scaling:
Flat 0
+
Magic Power * 1.0
```

Foundation inicial:

```text
Damage Type shorthand = magic
```

F23-A sólo estableció la semántica de daño.

La mutación real del mob llegó en F23-B.

---

# 25. F23-B — FIRE BALL RUNTIME ✅

Fire Ball actual:

```text
Mana Cost = 30
Cooldown = 3.0 s
Range = 6.0
Target = entity

Scaling:
0 + Magic Power * 1.0

Current mitigation:
ninguna Magic Resistance todavía
```

Pipeline:

```text
Client cast intent
→ SkillCastCoordinator
→ learned ownership
→ caster alive
→ target
→ same map
→ target alive
→ range
→ cooldown
→ mana
→ Scaling Resolver
→ raw Magic Damage
→ WorldMobRegistry.apply_damage_to_mob()
→ mob HP
→ mob_state_updated
→ Client
```

No existe un segundo lifecycle de muerte para Skills.

Fire Ball usa:

```text
WorldMobRegistry.apply_damage_to_mob()
```

igual que las demás fuentes de damage.

---

# 26. FIRE BALL — E2E REAL ✅

Personaje:

```text
mago
Character ID 6
Class Mage
Level 10

Permanent ENE = 50
Magic Power = 138
```

Fire Ball se aprendió por el flujo REAL:

```text
Skill Scroll durable
+
Mage
+
Level 10
+
Permanent ENE 50
+
Skill Trainer
→ durable learn
→ Scroll consumed
→ live SkillBook/Hotbar
```

Cast real:

```text
Magic Power: 138

Raw Damage:
138

Applied Damage:
138

Goblin:
5000 → 4862

MP:
406 → 376

Cooldown:
3.0
```

Client:

```text
Effect: damage
Amount: 138
```

No hubo cambios de protocolo Client para inventar el resultado.

El existing generic effect payload representó el resultado autoritativo.

---

# 27. F23-C — POISON DoT ✅

Poison actual:

```text
Mana Cost = 20
Cooldown = 5.0 s
Range = 6.0
Target = entity

Scaling per tick:
Flat 0
+
Physical Power * 0.20

Tick Interval:
1.0 s

Tick Count:
5

Duration:
5.0 s

Stacking:
no

Refresh Policy:
replace
```

Foundation actual usa shorthand:

```text
damage_type = poison
```

Esto será normalizado semánticamente en F24.

---

# 28. POISON STATUS RUNTIME

Nuevos conceptos permanentes:

```text
ServerSkillStatusEffectProfile
ServerSkillPeriodicDamageRules
WorldMobStatusEffectRuntime
```

Mob Runtime:

```text
status_effects_by_id
```

Policy:

```text
un solo status por effect_id

nuevo Poison
→ reemplaza/refresca el anterior
```

Scheduler:

```text
Game Server
```

Cada tick:

```text
Status Effect Runtime
→ WorldMobRegistry.apply_damage_to_mob()
→ HP
→ mob_periodic_damage_applied
→ WorldPresenceCoordinator
→ same-map clients
```

Status effects se limpian en:

```text
death
respawn
```

---

# 29. POISON — E2E REAL ✅

Lyra:

```text
Archer
Level 85

Physical Power = 228
```

Cálculo:

```text
floor(
	228 * 0.20
)
=
45
```

Primer Poison:

```text
MP:
298 → 278

Mob:
5000
→ 4955
→ 4910
→ 4865
→ 4820
→ 4775
```

Segundo Poison:

```text
MP:
278 → 258

Mob:
4775
→ 4730
→ 4685
→ 4640
→ 4595
→ 4550
```

Cada cast:

```text
5 ticks
45 damage/tick
225 total
```

Replicación Client:

```text
cada tick
→ mob_state_updated
→ MobActor HP refresh
```

La muerte por periodic damage usa el mismo `apply_damage_to_mob()` y por diseño puede converger al mismo `mob_died` usado por EXP/Drop.

Un kill letal específico por Poison no fue necesario como test separado durante F23-C.

---

# 30. F23 — PRINCIPIO CRÍTICO: SCALING ≠ DAMAGE SCHOOL

A partir de F24 se debe conservar esta separación:

```text
Scaling Source
!=
Damage School
!=
Damage Element
```

Ejemplo:

```text
Poison actual
→ escala con Physical Power
```

Eso NO obliga a que defensivamente sea:

```text
physical / none
```

El diseño histórico de VHAL ya había definido:

```text
Poison
→ magical / poison
```

Por lo tanto F24 normalizará la taxonomía sin revertir el Scaling probado de F23.

---

# 31. TAXONOMÍA DE DAMAGE CANÓNICA FUTURA

Volumen 3 ya definió dos ejes.

## Damage School

```text
physical
magical
```

## Damage Element

```text
none
fire
cold
lightning
poison
```

Ejemplos canónicos:

```text
Basic Attack con Sword
→ physical / none

Fire Ball
→ magical / fire

Poison
→ magical / poison
```

Esto reemplazará progresivamente los shorthands foundation actuales:

```text
physical
magic
poison
```

sin introducir un segundo sistema paralelo.

---

# 32. DELIVERY / EFFECT SEMANTICS

Además de School/Element, Combat debe poder distinguir cómo llega el efecto.

Conceptualmente:

```text
direct
periodic
```

Ejemplos:

```text
Sword
→ direct

Fire Ball
→ direct

Poison tick
→ periodic
```

Esto es independiente de:

```text
school
element
scaling source
```

Sirve para políticas futuras como:

```text
crit eligibility
block eligibility
status application
PvP tuning
combat log
VFX
```

No convertirlo en un enum gigante universal antes de necesitarlo.

---

# 33. PIPELINE DE DAMAGE OBJETIVO

Pipeline canónico a consolidar desde F24:

```text
Attack / Skill Base
↓
Scaling
↓
Flat offensive modifiers
↓
% offensive modifiers cuando existan
↓
Hit / defensive outcome cuando corresponda
↓
Critical si la fuente lo permite
↓
School Mitigation
├── Physical → Armor
└── Magical → Magic Resistance
↓
Elemental Resistance
↓
PvP Combat Modifier futuro
↓
Final Damage
↓
ServerVitalsState / WorldMobRuntimeState
↓
Death transition
```

Regla:

> No todas las fuentes tienen que participar en todas las capas.

Ejemplos:

```text
Poison DoT
→ puede no criticar
→ puede no ser bloqueable
→ sí puede usar Resistance

Heal
→ no entra al Damage pipeline
```

El orden actual ya consolidado para Basic Attack es:

```text
Crit
→ Armor
```

No revertirlo.

---

# 34. SCHOOL MITIGATION

## Physical

Ya existe:

```text
Armor
```

Foundation:

```text
reduction
=
rating / (rating + 1000)
```

equivalente a:

```text
remaining multiplier
=
1000 / (rating + 1000)
```

## Magical

F24 agregará:

```text
Magic Resistance
```

con una curva saturante equivalente como foundation inicial.

Objetivo:

```text
Magic Resistance rating
→ diminishing returns
→ nunca fácil 100% mitigation
```

`K` podrá evolucionar por:

```text
level
content tier
PvP profile
```

sin cambiar la responsabilidad del resolver.

---

# 35. ELEMENTAL RESISTANCES

Dirección histórica:

```text
Fire Resistance
Cold Resistance
Lightning Resistance
Poison Resistance
```

F24 debe dejar preparada la capa, pero no es obligatorio inventar Equipment/content de todos los elementos en el primer commit.

Ejemplo:

```text
Fire Ball
magical/fire
↓
Magic Resistance
↓
Fire Resistance
```

Poison:

```text
magical/poison
↓
Magic Resistance
↓
Poison Resistance
```

Sword:

```text
physical/none
↓
Armor
↓
sin elemental layer
```

---

# 36. CRITICAL POLICY FUTURA

Current real:

```text
Basic Attack
→ Critical pipeline existe

Crit Chance = 0
Crit Multiplier = 1.5
```

Para Skills:

```text
Fire Ball
Poison
```

todavía NO existe una decisión final de Crit por Skill.

F24 debe representar explícitamente:

```text
can_critical
```

o política equivalente.

Preservación inicial recomendada:

```text
Basic Attack
→ mantiene Crit existente

Fire Ball
→ no agregar Crit por accidente

Poison
→ no crit por tick por defecto
```

Si en el futuro una Skill puede criticar:

```text
debe declararlo en su definition/profile
```

No inferirlo sólo porque hace damage.

---

# 37. HIT / MISS / EVADE / BLOCK — TODAVÍA FUTURO

Volumen 3 dejó definidos como Secondary Stats futuros:

```text
Accuracy
Evasion / Dodge
Block Chance
```

Todavía NO existen como resultado real de combate.

No fingir que todo ataque futuro debe usarlos de la misma forma.

F25 deberá definir policies por acción.

Ejemplo conceptual:

```text
Basic Attack
→ Accuracy/Evasion aplicable
→ Block según target/equipment

Projectile Skill
→ policy propia

Poison tick
→ no hace nuevo hit roll por cada tick
```

No implementar RNG en Client.

---

# 38. PENETRATION / DAMAGE BONUSES — FUTURO

Conceptos previstos:

```text
Armor Penetration
Magic Penetration
Elemental Penetration
Physical Damage Bonus
Magic Damage Bonus
Skill Damage Bonus
```

No se implementan por completar una checklist.

Se incorporarán cuando:

```text
Equipment
Skill
Buff
Content
```

real necesite una fuente concreta.

El unified Damage pipeline debe poder evolucionar sin reescribir Combat.

---

# 39. RANGE / LINE OF SIGHT

Game Server valida actualmente range.

Current examples:

```text
Unarmed = 1.5
Bronze Sword = 2.0
Fire Ball = 6.0
Poison = 6.0
```

Line-of-sight:

```text
todavía no implementada
```

Desde Volumen 1 estaba previsto:

```text
validar LOS cuando corresponda
```

LOS no debe depender del Client.

El Client puede:

```text
raycast/picking
feedback local
```

pero la legalidad real del cast/attack es server-side.

---

# 40. AUTO-CHASE — DECISIÓN DE PRODUCTO / ROADMAP

Auto-chase fue explícitamente diferido varias veces.

No debe aparecer accidentalmente dentro de Movement, Basic Attack o Skills.

Se reserva:

```text
F27 — Action Approach / Auto-Chase
```

Dirección planificada:

```text
Player intenta acción sobre target fuera de range
↓
crear una intención de approach/action
↓
acercarse mediante navegación
↓
cuando entra en range
→ ejecutar la acción una vez
```

Casos:

```text
LEFT CLICK mob fuera de melee range
→ acercarse
→ Basic Attack

RIGHT CLICK entity skill fuera de cast range
→ acercarse
→ cast
```

Debe cancelarse si ocurre, por ejemplo:

```text
nuevo input manual
target muere
target desaparece
target cambia de mapa
acción deja de ser válida
```

No enviar:

```text
attack request cada frame
cast request cada frame
```

No mezclar este comportamiento con F24.

---

# 41. RANGED BASIC ATTACK — FUTURO

Basic Attack ya tiene mode previsto:

```text
ranged
```

Pero aún no existe un arma ranged real del vertical slice.

Future:

```text
Bow / ranged weapon
→ Equipment autoritativo
→ ServerBasicAttackProfileResolver
→ mode ranged
→ range propio
→ cadence propia
→ hit policy propia
```

Client no enviará:

```text
soy ranged
mi bow tiene range X
```

El Game Server lo deriva del Equipment.

---

# 42. PROJECTILES — AUTORIDAD VS PRESENTACIÓN

Cuando aparezcan projectiles reales:

```text
visual projectile
!=
autoridad de damage
```

Hay que decidir por Skill/Attack:

```text
instant authoritative resolution
con projectile visual
```

o:

```text
server runtime projectile
con travel/collision real
```

No asumir que todo proyectil visible necesita una entidad física server-side.

F28 será el checkpoint para tomar esa decisión por tipo de acción.

---

# 43. POSITION TARGET / AoE

Target kinds previstos:

```text
self
entity
position
```

`position` todavía no está implementado.

Future AoE:

```text
Client selecciona posición/intención
→ Game Server valida posición
→ range
→ map
→ LOS si aplica
→ resuelve entidades afectadas
→ aplica resultados
```

Client NO envía:

```text
lista autoritativa de víctimas
```

---

# 44. MOB COMBAT — GAP IMPORTANTE ACTUAL

El Training Goblin actualmente:

```text
spawn ✅
targetable ✅
receive damage ✅
death ✅
drops ✅
EXP ✅
respawn ✅
```

Pero aún falta el loop ofensivo real del mob:

```text
aggro
threat
target selection
chase
leash
mob Basic Attack / Skill
damage al player
player death
```

Esto estaba previsto desde el F17 histórico, pero no se implementó porque F17 priorizó el vertical slice mínimo.

Se retoma formalmente en:

```text
F26 — PvE Enemy Combat Loop
```

---

# 45. THREAT / AGGRO — DIRECCIÓN

No acoplar aggro directamente a:

```text
BasicAttackCoordinator
Fire Ball
Poison
```

Las fuentes de Combat deben emitir/aportar contexto suficiente.

Un sistema futuro de threat podrá reaccionar a:

```text
damage
heal
proximity
special skills
```

según reglas.

Mob AI debe poder distinguir:

```text
idle
aggro
chase
attack
return/leash
dead
respawn
```

No convertir `WorldMobRuntimeState` en un God Object de AI.

---

# 46. PLAYER DAMAGE / DEATH — DIRECCIÓN

Mob attacks y PvP deben reutilizar:

```text
ServerVitalsState
```

Player death:

```text
HP > 0
→ damage
→ HP = 0
→ authoritative death transition
```

Luego definir:

```text
movement lock
cast lock
basic attack lock
respawn policy
spawn point
HP/MP restore policy
death penalties futuras
```

No crear un segundo Vitals runtime.

---

# 47. REGENERATION — FUTURE COMBAT SYSTEM

Current:

```text
HP Regeneration = 0
MP Regeneration = 0
```

Antes de implementarla definir:

```text
rate
tick interval
combat vs non-combat
VIT/ENE scaling
caps
replication policy
```

Game Server:

```text
tick authority
```

Client:

```text
representation
```

Se planifica dentro del cierre del PvE combat loop, no como side effect de otro cambio.

---

# 48. GENERAL STATUS EFFECTS — DIRECCIÓN CANÓNICA

Poison es el primer DoT real, pero NO debe forzar que todos los status sean iguales.

Categorías históricas:

```text
Damage over Time
Debuff
Buff
Soft Control
Hard Control
```

Ejemplos futuros:

```text
slow
attack speed reduction
armor reduction
silence
root
stun
damage buff
defense buff
```

Necesitan policies propias.

---

# 49. ANTI-PERMACONTROL

Decisión histórica:

```text
NO permanent stun
NO permanent root
NO permanent silence
```

Future defensive concepts:

```text
Tenacity
Control Resistance
Diminishing Returns
duration caps
immunity windows cuando corresponda
```

PvP no debe convertirse en:

```text
primer CC conecta
→ jugador nunca vuelve a jugar
```

F29 será el bloque dedicado.

---

# 50. DoT STACKING

Decisión:

```text
DoTs NO stackean infinitamente por defecto
```

Poison actual:

```text
same effect_id
→ replace
```

Future skills pueden declarar otra policy explícita:

```text
replace
refresh
limited stacks
independent sources
```

pero debe ser decisión de definition/domain.

No hardcodear todas las policies dentro de `WorldMobRegistry`.

---

# 51. PvP — INPUT CANÓNICO

```text
CTRL + LEFT CLICK player
→ BASIC ATTACK PvP

CTRL + RIGHT CLICK player
→ SELECTED SKILL PvP
```

No convertir click normal sobre otro player en ataque accidental.

Game Server valida:

```text
target player
same map
range
line of sight cuando corresponda
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

# 52. PvP — ARQUITECTURA

PvP debe reutilizar Combat.

NO crear:

```text
PvPDamageSystem
```

con fórmulas completamente paralelas.

Pipeline:

```text
normal Combat resolution
↓
PvP Combat Profile / Modifier layer
↓
player Vitals
↓
player death
```

La capa PvP puede ajustar:

```text
damage multipliers
CC duration
healing rules
certain caps
```

sin duplicar todo el dominio.

---

# 53. SAFE ZONES / MAP PvP POLICY

Game Server debe decidir:

```text
si el mapa permite PvP
si la posición pertenece a Safe Zone
si existe un modo/evento especial
```

Client puede mostrar feedback.

Client no decide legalidad.

Future map/world definitions deben exponer los datos necesarios.

---

# 54. PK / SIN — ESTADOS CANÓNICOS

Dirección histórica:

```text
Inocente
↓
Diablillo
↓
Delincuente
↓
Pecador / Sinner
```

Thresholds exactos:

```text
TBD
```

El estado se deriva de una métrica durable server/backend-side como:

```text
sin points
criminal points
penalizable player kills
```

Nombre técnico final se decide al implementar.

---

# 55. AUTO-DEFENSE / LEGÍTIMA DEFENSA

Regla canónica:

```text
A agrede primero a B
↓
Game Server registra agresión válida
↓
B obtiene autorización temporal de defensa contra A
↓
B puede responder/matar a A
sin recibir penalización PK por esa defensa
```

Auto-defense:

```text
runtime Game Server
```

No debe persistirse como una condena durable.

Future decisions:

```text
duration
multiple aggressors
third-party intervention
party
guild
duel
event map
```

---

# 56. SINNER / PECADOR

Estado máximo previsto:

```text
Pecador / Sinner
```

Regla:

```text
otros players pueden atacarlo
sin ser penalizados por ese ataque
```

Presentación:

```text
body
armor
weapon
wings
main visual components
→ red tint
```

Client representa un estado autoritativo.

Client NO decide:

```text
este player es Sinner
```

---

# 57. PRIEST / CONFESSION

Future NPC service:

```text
Priest / Sacerdote
```

Flujo:

```text
player con pecado
→ interactúa con Priest
→ GS calcula costo
→ muestra deuda
→ player acepta
→ durable currency transaction
→ sin state reducido/limpiado
```

Costo:

```text
escala con gravedad del pecado
```

Fórmula:

```text
TBD
```

No implementar Priest antes de tener:

```text
PvP
PK/Sin
currency real
```

---

# 58. PvE REDEMPTION

Vía alternativa:

```text
matar mobs válidos
→ reducir pecado lentamente
```

Objetivo:

```text
Priest
→ rápido / costoso

PvE
→ lento / gratuito
```

Future anti-exploit:

```text
mob level
player level
zone
diminishing returns
valid kill criteria
```

---

# 59. PK ARCHITECTURE

Separación obligatoria:

```text
Combat
→ determina hit / damage / death

PvP Domain
→ determina legalidad/aggression/self-defense

PK/Sin Domain
→ determina penalización

Backend
→ persiste criminal state durable

Presence
→ replica estado necesario

Client
→ representa color/feedback
```

No meter todo dentro de:

```text
BasicAttackCoordinator
```

---

# 60. COMBAT PRESENTATION

Regla:

```text
gameplay authority
!=
presentation
```

Client será dueño visual de:

```text
attack animations
cast animations
hit reactions
death animations
respawn visuals
VFX
SFX
floating damage numbers
floating heal numbers
status effect visuals
projectile visuals cuando sean presentation-only
combat feedback
```

Pero esos elementos representan resultados del Game Server.

No deben autorizar damage.

---

# 61. CURRENT VISUAL LIMITATIONS

Actualmente varias representaciones siguen foundation/placeholder.

Ejemplos:

```text
MobActor technical representation
death visual placeholder
sin final combat animations
sin hit reactions finales
sin floating damage numbers
sin Fire Ball VFX final
sin Poison VFX final
```

No mezclar un mega art pass con la foundation mecánica.

Combat Presentation tendrá su propio checkpoint.

---

# 62. ROADMAP CANÓNICO DE COMBAT — F24+

A partir de este documento queda PLANIFICADO el siguiente arco.

```text
F24 — Unified Damage & Mitigation

F25 — Hit Resolution & Defensive Outcomes

F26 — PvE Enemy Combat Loop

F27 — Action Approach / Auto-Chase

F28 — Ranged / LOS / Projectile / Position Combat

F29 — General Status Effects / Crowd Control

F30 — PvP Combat Foundation

F31 — PK / Sin / Auto-Defense

F32 — Combat Presentation & Feel
```

Este orden puede subdividirse en commits pequeños.

No abrir dos fases grandes a la vez.

---

# 63. F24 — UNIFIED DAMAGE & MITIGATION

Objetivo:

> Tener un único modelo semántico para describir y resolver daño físico, mágico y elemental sin crear pipelines paralelos para Basic Attack, Fire Ball y Poison.

Estado:

```text
⏳ NEXT
```

Breakdown planificado:

```text
F24-A
Damage Taxonomy + Resolution Context

F24-B
Magic Resistance + Elemental Resistance foundation

F24-C
Unified Damage Resolver

F24-D
Migrate/verify Basic Attack + Fire Ball + Poison

F24-E
Integrated Combat Damage Audit
```

No es necesario que los nombres exactos de archivos lleven `F24`.

Los artifacts permanentes deben tener nombres de dominio.

---

# 64. F24-A — DAMAGE TAXONOMY

Debe formalizar:

```text
school:
physical
magical

element:
none
fire
cold
lightning
poison

delivery:
direct
periodic
```

Y separar:

```text
scaling
school
element
delivery
critical policy
```

No duplicar `ServerSkillDamageProfile` con una segunda arquitectura.

Debe evolucionarse/migrarse el dominio existente.

Preservar behavior actual mientras se normaliza semántica.

---

# 65. F24-B — RESISTANCE FOUNDATION

Agregar progresivamente:

```text
Magic Resistance

Fire Resistance
Cold Resistance
Lightning Resistance
Poison Resistance
```

No es requisito agregar Equipment real de todos esos ratings en el mismo commit.

Puede comenzar con:

```text
ratings 0
```

y contracts sintéticos.

Player y Mob deben poder exponer un defensive profile compatible.

No guardar estos valores finales como verdad durable si son derivables.

---

# 66. F24-C — UNIFIED DAMAGE RESOLVER

Resolver conceptualmente:

```text
Damage Input
↓
Critical policy/result
↓
School resistance
↓
Element resistance
↓
future PvP modifier hook
↓
Final Damage
```

Debe devolver breakdown útil para:

```text
logs
tests
combat result
future damage numbers
balance audit
```

Ejemplo conceptual:

```text
raw_damage
critical
pre_mitigation
school_rating
post_school
element_rating
post_element
final_damage
```

No permitir que Coordinators copien fórmulas.

---

# 67. F24-D — MIGRACIÓN SIN REGRESIÓN

Basic Attack:

```text
debe conservar exactamente su Armor behavior actual
```

Fire Ball:

```text
magic shorthand
→ magical/fire
```

Poison:

```text
poison shorthand
→ magical/poison
```

Poison conserva:

```text
Physical Power * 0.20 per tick
```

Scaling NO cambia por normalizar Damage taxonomy.

Heal queda fuera del Damage resolver.

---

# 68. F24-E — COMBAT DAMAGE AUDIT

Actualizar/expandir el contract permanente, sin nombres de roadmap en artifacts.

Debe fijar casos representativos como:

```text
Physical / none
Magic / fire
Magic / poison
zero resistance
positive resistance
crit off
crit on sintético cuando corresponda
periodic damage
```

Objetivo:

```text
cambiar balance conscientemente
≠
romper una fórmula sin enterarse
```

---

# 69. F25 — HIT RESOLUTION & DEFENSIVE OUTCOMES

Estado:

```text
⏳ PLANNED
```

Scope:

```text
Accuracy
Evasion / Dodge
Block
hit/miss/evade/block result vocabulary
action-specific policies
```

Reglas:

```text
RNG → Game Server

Client
→ representación
```

No todas las Skills deben hacer el mismo hit roll.

No usar Evasion como segunda Armor.

No usar Block como sinónimo de Evasion.

---

# 70. F25 — POLICY POR ACCIÓN

Ejemplos de diseño a resolver:

```text
Basic Attack
→ Accuracy/Evasion aplicable
→ Block según target/equipment

Projectile Skill
→ policy propia

Poison cast
→ hit/application roll si corresponde
→ los ticks posteriores NO hacen cinco nuevos accuracy rolls

Heal
→ no aplica hit resolution ofensiva
```

No decidir por nombre de Skill dentro del coordinator.

Usar definition/profile.

---

# 71. F26 — PvE ENEMY COMBAT LOOP

Estado:

```text
⏳ PLANNED
```

Completar lo que el F17 histórico dejó fuera.

Breakdown conceptual:

```text
F26-A
Aggro / Threat foundation

F26-B
Mob movement / chase / leash / return

F26-C
Mob Attack Profile + authoritative attack

F26-D
Player damage / death / respawn

F26-E
HP/MP Regeneration policy
```

Un único Training Goblin completo antes de crear muchos mobs.

---

# 72. F26 — MOB ATTACK

Mob attack debe usar:

```text
definition/profile
→ range
→ cadence
→ damage source
→ unified Damage Resolver
→ Player ServerVitalsState
```

No:

```text
mob.gd
→ player.hp -= 10
```

Mob offensive damage y Player offensive damage deben compartir primitives de Combat cuando semánticamente corresponda.

---

# 73. F26 — THREAT / LEASH

Necesita definir:

```text
aggro acquisition
threat sources
target selection
chase range
leash distance
return to spawn
target invalidation
death/reset
```

No persistir threat en MySQL.

Runtime Game Server.

---

# 74. F27 — ACTION APPROACH / AUTO-CHASE

Estado:

```text
⏳ PLANNED
```

Objetivo UX:

```text
click target fuera de range
→ no exigir clicks repetidos manualmente
→ acercarse
→ ejecutar acción al entrar en range
```

Debe reutilizar navegación.

No duplicar `WorldMovementSystem`.

Casos:

```text
Basic Attack
Skill entity target
future NPC action si alguna vez aplica
```

Cancellation y replacement de intents deben ser explícitos.

---

# 75. F28 — RANGED / LOS / PROJECTILE / POSITION

Estado:

```text
⏳ PLANNED
```

Incluye progresivamente:

```text
ranged Basic Attack real
Bow foundation
line-of-sight
projectile policy
position target
AoE target resolution
```

No es necesario implementar todo en un solo commit.

---

# 76. F28 — PROJECTILE DECISION

Cada acción podrá declarar algo equivalente a:

```text
instant
projectile visual
server projectile runtime
```

Decidir por necesidad real.

No crear cientos de server projectile entities sólo porque existe una animación visible.

No permitir que un visual projectile Client determine hit.

---

# 77. F29 — GENERAL STATUS EFFECTS / CC

Estado:

```text
⏳ PLANNED
```

Poison será el primer consumer heredado.

Objetivo:

```text
generalizar sin romper Poison
```

Scope:

```text
Buff
Debuff
DoT
Soft CC
Hard CC

duration
stacking
refresh
source attribution
expiration
replication
```

Luego:

```text
Tenacity
Control Resistance
Diminishing Returns
duration caps
```

---

# 78. F30 — PvP COMBAT FOUNDATION

Estado:

```text
⏳ PLANNED
```

Implementar primero Combat PvP SIN mezclar todavía todo PK/Sin.

Scope:

```text
CTRL + LEFT player
CTRL + RIGHT player

player target resolution
same map
safe zone / map policy
range / LOS
Basic Attack PvP
Skill PvP
Player Vitals
Player death
PvP Combat Profile
```

No empezar PK antes de que player-vs-player combat funcione como sistema limpio.

---

# 79. F30 — PvP COMBAT PROFILE

Debe ser una capa sobre Combat.

Ejemplo conceptual:

```text
PvE Final Damage
→ normal content modifier

PvP
→ same resolver
→ PvP modifier layer
```

Puede ajustar en el futuro:

```text
damage
healing
CC duration
certain caps
```

No duplicar todas las fórmulas PvE.

---

# 80. F31 — PK / SIN / AUTO-DEFENSE

Estado:

```text
⏳ PLANNED
```

Breakdown conceptual:

```text
F31-A
Aggression Context + Auto-Defense

F31-B
Durable Sin / Criminal State

F31-C
Sinner Presence + Red Visual State

F31-D
Priest Confession

F31-E
PvE Redemption
```

Economía real deberá existir antes de cobrar una Confession real.

---

# 81. F32 — COMBAT PRESENTATION & FEEL

Estado:

```text
⏳ PLANNED
```

Una vez estable el backbone mecánico:

```text
Basic Attack animation
Skill cast animation
Fire Ball visual
Poison visual
projectiles
hit reaction
death animation
respawn visual
floating damage
floating healing
critical feedback
miss/evade/block feedback
status effect feedback
SFX
camera feedback cuando corresponda
```

Autoridad permanece en Game Server.

---

# 82. QUÉ NO METER AUTOMÁTICAMENTE EN COMBAT

No agregar por inercia:

```text
50 Skills
20 mobs
bosses
guild wars
events
full endgame
mass PvP
all elemental gear
all CC types
all projectiles
all weapon classes
```

Primero:

```text
una capability
→ real
→ probada
→ reusable
```

Después contenido.

---

# 83. EQUIPMENT / COMBAT FUTURO

Equipment futuro puede aportar:

```text
Armor
Magic Resistance
Elemental Resistances
Accuracy
Block
Crit
Attack Speed
Damage modifiers
Penetration
```

Pero cada modifier entra sólo cuando exista su dominio real.

No agregar stats de Equipment que Combat todavía no sabe resolver.

---

# 84. RESET / COMBAT

Reset futuro:

```text
Level 400
→ Reset NPC
→ Backend atomic transaction
→ Level 1
→ reset_count +1
→ normal allocations cleared
→ reset budget
```

Skills:

```text
ownership persiste
usage reset-safe
```

Equipment inválido después de Reset:

```text
no puede permanecer equipado
```

Derived/Vitals:

```text
rebuild
```

Reset no se implementa dentro del arco inmediato F24.

---

# 85. CURRENT TEST CHARACTERS

## Atilio

```text
Character ID 1
Warrior
Level 124
EXP 50
Reset 0

Primary revision 3

Permanent:
STR 37
AGI 15
VIT 25
ENE 10

Physical Power 330
Magic Power 10
Healing Power 10

Bronze Sword durable +4
Heal learned
```

## Lyra

```text
Character ID 2
Archer
Level 85
Reset 0

Primary revision 0
Allocated 0/0/0/0

Permanent:
STR 15
AGI 30
VIT 15
ENE 15

Physical Power 228
Magic Power 15
Healing Power 15

Skills:
heal
poison
```

Durante F23-C:

```text
MP terminó observado en 258/298
```

## ProgAudit

```text
Character ID 5
Warrior
Level 11
EXP 65/400

Primary revision 7

Permanent:
STR 27
AGI 15
VIT 27
ENE 13

Max HP 288
Max MP 79
Physical 84
Magic 13
Healing 13

Heal learned
```

## mago

```text
Character ID 6
Mage
Level 10

Permanent ENE 50

Max HP 160
Max MP 406
Magic Power 138

Fire Ball learned
```

Fire Ball se aprendió mediante el flujo real de Trainer.

---

# 86. F23 — AUDIT RESULT SUMMARY

Fire Ball:

```text
Magic Power 138
Raw 138
Applied 138
Goblin 5000 → 4862
MP 406 → 376
Cooldown 3.0
```

Poison Lyra:

```text
Physical Power 228
Damage/tick 45
Ticks 5
Duration 5
Total 225
Cooldown 5
Mana 20
```

Basic Attack regression durante F23-B:

```text
continuó funcionando
```

Startup durante F23-A/B/C:

```text
Skill Catalog Contract validado
Integrated Balance Contract validado
Game Server listening
0 warnings/errors observados
```

---

# 87. DECISIONES HISTÓRICAS SUPERSEDIDAS

Para evitar contradicciones entre volúmenes:

## Poison scaling

Histórico conceptual de Volumen 3:

```text
Energy principal
+ posible Agility
```

Estado REAL posterior F23:

```text
Physical Power * 0.20 per tick
```

Prevalece F23.

Damage defensive taxonomy futura:

```text
magical / poison
```

es independiente del Scaling source.

## Reset Skill Usage

Histórico:

```text
Skill aprendida podría quedar no usable post-reset
por requirements
```

Estado REAL F22-J:

```text
learning requirements no se revalidan al cast
```

Prevalece F22-J.

## Critical

Histórico conceptual:

```text
base ~5%
```

Estado REAL:

```text
Crit Chance 0.0
Crit Multiplier 1.5
```

Prevalece F22-G.

## Attack Speed

Histórico conceptual:

```text
generic percent bonus
```

Estado REAL:

```text
class-specific diminishing curves
```

Prevalece F22-H.

---

# 88. REGLAS DE COMBAT QUE NO DEBEN REGRESIONAR

```text
1. Client nunca decide damage final.
2. Backend nunca entra al hot loop por hit/cast/tick.
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
16. Poison actual escala con Physical Power * 0.20.
17. Poison ticks son server-side.
18. Poison no stackea infinitamente.
19. Current Poison replace policy se conserva hasta decisión explícita.
20. WorldMobRegistry centraliza damage/death de mobs.
21. EXP/Drop no dependen de BasicAttackCoordinator.
22. Future Skill kills deben converger al mismo death lifecycle.
23. Armor usa diminishing rating.
24. Crit ocurre antes de Armor en el Basic Attack actual.
25. AGI no aumenta Movement Speed directamente.
26. Derived Stats no son verdad durable final.
27. Vitals son compartidos por todas las fuentes de HP/MP.
28. Damage Scaling, School y Element son conceptos distintos.
29. Auto-chase sólo entra en su checkpoint dedicado.
30. LOS será server-side cuando corresponda.
31. DoTs no stackean infinitamente por defecto.
32. CC futuro debe tener anti-permacontrol.
33. PvP reutiliza Combat, no duplica un engine aparte.
34. PK/Sin es dominio separado de hit/damage.
35. Auto-defense es runtime Game Server.
36. Criminal/Sin state durable pertenece a Backend/MySQL.
37. Sinner red tint es representación de estado autoritativo.
38. Priest confession depende de PvP/Sin + Economy real.
39. Combat presentation no decide gameplay.
40. No escalar contenido masivo antes de estabilizar cada nueva capability.
```

---

# 89. NEXT EXACT CHECKPOINT

Antes de escribir código F24:

```text
1. reemplazar PROJECT_MEMORY_5.md con este archivo
2. git status en Client
3. confirmar que sólo cambió PROJECT_MEMORY_5.md
4. commit documental
5. push dev
6. usuario dice "pusheado"
7. verificar remoto
8. recién entonces abrir F24-A
```

Commit sugerido:

```text
docs: close F23 and plan combat roadmap
```

Después:

```text
F24-A — Damage Taxonomy + Resolution Context
```

Será el próximo cambio permanente de gameplay.

---

# 90. RESUMEN CORTO PARA RETOMAR

```text
F22 ✅ COMPLETE

F23-A Fire Ball Damage Foundation ✅
F23-B Fire Ball Runtime Combat ✅
F23-C Poison DoT Runtime ✅

F23 — Skill Combat Effects ✅ COMPLETE
```

Current Heads:

```text
Client:
616dcc5c5f42235ee8ef90c4b0c178e58425ea98

Game Server:
a4836954a3e51246993d919e9903e091fc5b0c8a

Backend:
ce3e0b02dbb1772204e12d1c2bb29d777b28b750
```

Combat roadmap:

```text
F24 Unified Damage & Mitigation
F25 Hit Resolution & Defensive Outcomes
F26 PvE Enemy Combat Loop
F27 Action Approach / Auto-Chase
F28 Ranged / LOS / Projectile / Position Combat
F29 General Status Effects / Crowd Control
F30 PvP Combat Foundation
F31 PK / Sin / Auto-Defense
F32 Combat Presentation & Feel
```

NEXT:

```text
PROJECT_MEMORY_5 docs checkpoint
→ push
→ remote verification
→ F24-A
```
