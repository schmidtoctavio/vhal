# VHAL — PROJECT MEMORY 5 / COMBAT FOUNDATION → PvP + UI/CONTENT PASS

**Volumen:** 5  
**Inicio:** 06/09/2026  
**Última actualización canónica:** 09/09/2026  
**Motor Client / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`

---

# 0. PROPÓSITO Y PRECEDENCIA

Este archivo es la continuidad canónica más reciente de VHAL.

Reemplaza completamente la versión anterior de:

```text
PROJECT_MEMORY_5.md
```

sin reemplazar la historia conservada por los volúmenes anteriores.

Orden obligatorio al retomar:

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

```text
volumen más nuevo
→ prevalece sobre decisiones históricas anteriores

código realmente pusheado en dev
→ prevalece sobre cualquier memoria desactualizada
```

Política de volumen:

```text
~5000 líneas
→ cerrar volumen
→ abrir PROJECT_MEMORY_6.md
```

Este volumen TODAVÍA tiene margen suficiente.

NO abrir `PROJECT_MEMORY_6.md` todavía.

---

# 1. WORKFLOW OBLIGATORIO

Ciclo canónico:

```text
checkpoint único
→ revisar repos reales
→ explicar scope
→ implementación manual/controlada
→ test positivo
→ git status
→ revisar scope
→ commit
→ push
→ usuario dice "pusheado"
→ verificar remoto
→ recién entonces siguiente checkpoint
```

Reglas:

```text
No avanzar antes de "pusheado".
No mezclar scopes.
Preferir checkpoints pequeños.
No hacer refactors laterales sin necesidad.
No crear commits por el usuario.
No pushear por el usuario.
.tscn siempre editar desde Godot Editor.
.md canónico siempre entregar como archivo completo.
Objetivo: 0 warnings / 0 errors.
```

---

# 2. REPOSITORIOS

```text
Client:
schmidtoctavio/vhal

Game Server:
schmidtoctavio/vhal_game_server

Backend:
schmidtoctavio/vhal_backend

Branch habitual:
dev
```

---

# 3. HEADS REMOTOS VERIFICADOS — 09/09/2026

## Client

```text
57ace06e48dd6d6321c17960c20cf3a7d2ca28ff
feat: send pvp entity skill intents
```

## Game Server

```text
f714f8d9884cd9d677901beb9f9b00813be1611f
feat: unify authoritative player death and respawn
```

Parent inmediato relevante:

```text
33510bac38b132fe5ddba54067de70bc5ac7864f
feat: add authoritative pvp entity skills and player status effects
```

Anterior:

```text
6034ef77506161a7680e18b6282884e07884c93d
feat: add authoritative pvp basic attacks
```

Foundation PvP anterior:

```text
d73a2e6bf905f316084cc38b30ebbf690a805163
feat: add pvp targeting and safe zone foundation
```

## Backend

```text
ce3e0b02dbb1772204e12d1c2bb29d777b28b750
feat: expose equipment enhancement persistence endpoint
```

Backend no participa del Combat hot loop.

---

# 4. ESTADO GENERAL ACTUAL

```text
F00-F19 ✅
F20 ✅ Durable Character Runtime
F21 ✅ Durable Skill Ownership / Learning
F22 ✅ Character Stats / Integrated Balance
F23 ✅ Skill Combat Effects
F24 ✅ Unified Damage & Mitigation
F25 ✅ Hit Resolution & Defensive Outcomes
F26 ✅ PvE Enemy Combat Loop + Regen
F27 ✅ Action Approach / Auto-Chase
F28 ✅ Ranged / LOS / Position Combat foundation
F29 ✅ General Status Effects / Crowd Control foundation

F30-A ✅ PvP Targeting + Safe Zone Foundation
F30-B ✅ PvP Basic Attacks
F30-C ✅ PvP Entity Skills + Player Status Effects
Player Death/Respawn unificado ✅

F30-D ⏳ PvP Position Skills / Area Resolution
F30 final audit ⏳
```

El proyecto ya posee una base funcional suficiente para pausar temporalmente la expansión mecánica y realizar un pass de:

```text
UI
visual identity
icons
item presentation
skill presentation
content expansion controlada
```

sin cambiar la autoridad del gameplay.

---

# 5. ARQUITECTURA AUTORITATIVA — NO CAMBIAR

```text
Client
=
intención
+
representación
+
UI
+
VFX
+
prediction limitada

Game Server
=
autoridad inmediata de gameplay/runtime

Backend Laravel
=
identidad
+
persistencia
+
operaciones durables

MySQL
=
verdad durable
```

Combat:

```text
Client intent
→ Game Server validation
→ authoritative runtime mutation
→ authoritative result/events
→ Client representation
```

Incorrecto:

```text
hit/cast/tick
→ Laravel
→ esperar DB
→ gameplay
```

No mover al Client:

```text
damage final
hit result
crit
range authority
LOS authority
cooldown
mana
HP/MP
status tick
mob AI
PvP legality
safe zone legality
death
respawn
future PK penalty
```

---

# 6. DURABLE VS RUNTIME

Durable actual:

```text
Account / Character
Inventory
Equipment
Vault
Level / Experience
Map / Position / Rotation
Current HP / MP
Skill Ownership
Skill Learning
Primary Stats
Equipment Enhancement
```

Runtime Game Server:

```text
Derived Stats finales
cooldowns
Basic Attack runtime
Skill runtime
mob HP
mob status effects
player status effects
aggro/threat
combat timers
Action Approach state
pending respawn
hard-control immunity
WorldDrops mientras vive GS
```

Death NO debe persistir como estado permanente.

Un Character persistido accidentalmente con:

```text
HP = 0
```

se recupera al ingresar y completa el estado de respawn.

---

# 7. INPUT CANÓNICO ESTILO MU

```text
LEFT CLICK drop
→ pickup

LEFT CLICK NPC
→ interact

LEFT CLICK mob
→ Basic Attack PvE

LEFT CLICK terrain
→ move

RIGHT CLICK
→ selected Skill según target kind

CTRL + LEFT player
→ Basic Attack PvP

CTRL + RIGHT player
→ selected Skill PvP
```

Target kinds:

```text
self
entity
position
```

Regla:

```text
Client hace picking/intención
Game Server vuelve a resolver y validar
```

---

# 8. COMBAT DAMAGE FOUNDATION

Damage taxonomy:

```text
School:
physical
magical

Element:
none
fire
cold
lightning
poison

Delivery:
direct
periodic
```

Ejemplos:

```text
Sword
→ physical / none / direct

Fire Ball
→ magical / fire

Poison
→ magical / poison / periodic
```

Scaling Source es independiente de School/Element.

Poison actual:

```text
scaling
= Physical Power * 0.20

defensive taxonomy
= magical / poison / periodic
```

---

# 9. UNIFIED DAMAGE PIPELINE

```text
Raw Damage
↓
Hit / Defensive Outcome cuando aplica
↓
Critical cuando aplica
↓
School Mitigation
├── physical → Armor
└── magical → Magic Resistance
↓
Element Mitigation
↓
PvP modifier hook
↓
Final Damage
↓
authoritative Vitals
↓
Death transition
```

No duplicar:

```text
PvPDamageSystem
MobDamageSystem
SkillDamageSystem
```

como engines paralelos.

---

# 10. HIT RESOLUTION

Foundation real:

```text
miss
hit
dodge
block
```

Order:

```text
hit roll
→ dodge roll
→ block roll
```

Block foundation:

```text
damage multiplier = 0.50
```

Caps foundation:

```text
Dodge <= 0.75
Block <= 0.75
```

Basic Attack y Mob Attack reutilizan el dominio.

Poison tick NO hace un nuevo hit roll por cada tick.

---

# 11. BASIC ATTACK

Basic Attack NO es una Skill.

Game Server deriva:

```text
Equipment
→ attack mode
→ damage
→ range
→ cooldown
→ hit profile
```

Modes:

```text
unarmed
melee
ranged
```

No renombrar:

```text
unarmed
```

Current foundation:

```text
Unarmed:
damage 500
range 1.5
cooldown 1.0

Bronze Sword:
damage 1000
range 2.0
cooldown 0.9
```

Enhancement usa bonus flat acumulado.

---

# 12. CURRENT SKILLS

## Heal

```text
target = self
real
uses Healing Power
authoritative HP mutation
```

## Fire Ball

Current combat foundation incluye:

```text
magical/fire
direct damage
position/AoE foundation
hard CC foundation
LOS/range server-side
```

## Poison

```text
target = entity
magical/poison/periodic
5 ticks
1 tick/s
replace policy
Player y Mob Status Effect runtime
```

El proyecto está preparado para agregar nuevas Skills mediante Definitions/Profiles y consumers existentes, sin inventar un engine nuevo por habilidad.

---

# 13. F26 — PvE COMPLETE

Training Goblin posee:

```text
aggro
target selection
chase
leash
return
Basic Attack
Hit Resolution
Unified Damage
player damage
player death
respawn
```

Current foundation histórica:

```text
Aggro Radius = 5
Leash Radius = 10
Move = 2.5
Attack Range = 1.5
Cooldown = 1.25
Base Damage = 200
Accuracy = 100
```

No es balance definitivo.

---

# 14. F26-E — REGEN COMPLETE

Existe:

```text
CharacterRegenCoordinator
```

Policy:

```text
tick = 1 s
HP/MP regen fuera de combate
combat timeout = 5 s
dead player no regenera
caps en max HP/MP
```

Combat activity incluye PvE y PvP.

Combat timers:

```text
runtime only
```

---

# 15. F27 — ACTION APPROACH COMPLETE

Objetivo:

```text
acción fuera de rango
→ navegación autoritativa
→ entrar en rango
→ ejecutar exactamente una vez
```

Implementado para:

```text
Basic Attack
Entity Skill
```

Cancellation/replacement:

```text
manual movement
new Basic Attack
new Skill
NPC interaction
drop pickup
target death
target missing
wrong map
character death
unreachable approach
```

Server initiated movement usa:

```text
movement_decision request_id = 0
```

Client-originated IDs continúan > 0.

No frame spam.

Retarget controlado para targets móviles.

---

# 16. F28 — RANGED / LOS / POSITION FOUNDATION

Game Server posee LOS authority.

Ranged/position combat debe mantener:

```text
Client preview/picking
!=
authoritative hit/damage
```

Projectile visual:

```text
no implica automáticamente server projectile runtime
```

El servidor determina cuándo realmente necesita travel/collision runtime.

Position Skills:

```text
Client envía posición/intención
Game Server valida
Game Server decide víctimas
```

Client NO manda lista autoritativa de afectados.

---

# 17. F29 — GENERAL STATUS EFFECTS / CC

Foundation general existente:

```text
Buff
Debuff
DoT
Soft CC
Hard CC
```

Policies:

```text
duration
stacking
refresh
source attribution
expiration
replication
```

Existe:

```text
ServerStatusEffectCollection
ServerStatusEffectRuntime
PlayerStatusEffectCoordinator
```

Anti-permacontrol:

```text
hard-control immunity foundation
```

No permitir diseño futuro donde un Player quede permanentemente stuneado/root/silenced.

---

# 18. F30 — PvP COMBAT FOUNDATION

Objetivo:

```text
usar Combat existente contra Players
sin duplicar engines
```

PvP valida:

```text
target player
same map
alive
map PvP policy
safe zone
range
LOS cuando corresponde
equipment
mana
cooldown
hit
damage
status effects
death
```

Safe Zone actual foundation de `test_town`:

```text
centro = spawn (0,0,0)
radio = 3.0
```

Mapa desconocido:

```text
safe by default
```

---

# 19. F30-A — PvP TARGETING + SAFE ZONE ✅

Commit Game Server:

```text
d73a2e6bf905f316084cc38b30ebbf690a805163
feat: add pvp targeting and safe zone foundation
```

Artifacts principales:

```text
ServerCombatEntityRef
ServerPvpPolicy
ServerPvpFoundationContract
```

Player entity refs:

```text
player:<peer_id>
```

PvP engagement rechaza, entre otros:

```text
self target
dead attacker
dead target
wrong map
PvP disabled
NPC service busy
attacker in safe zone
target in safe zone
```

---

# 20. F30-B — PvP BASIC ATTACKS ✅

Commit Game Server:

```text
6034ef77506161a7680e18b6282884e07884c93d
feat: add authoritative pvp basic attacks
```

Flow:

```text
CTRL + LEFT Player
→ Basic Attack intent
→ PvP Policy
→ Action Approach si fuera de range
→ Equipment-derived attack profile
→ Hit Resolution
→ Unified Damage
→ target Player Vitals
```

Reutiliza:

```text
Armor
Evasion
Dodge
Block
Crit
Attack Speed
LOS para ranged
```

No existe fórmula paralela de PvP Basic Attack.

---

# 21. F30-C — PvP ENTITY SKILLS ✅

Commits:

```text
Game Server:
33510bac38b132fe5ddba54067de70bc5ac7864f
feat: add authoritative pvp entity skills and player status effects

Client:
57ace06e48dd6d6321c17960c20cf3a7d2ca28ff
feat: send pvp entity skill intents
```

Qué significa `Entity Skill`:

```text
una Skill cuyo objetivo es UNA entidad concreta
```

Ejemplos:

```text
Poison → Player específico
future single-target damage spell → Player específico
future root/stun/debuff → Player específico
future single-target heal/support → aliado específico cuando exista policy
```

NO significa:

```text
skill de área en el piso
```

Eso pertenece a `position`.

Current F30-C permite:

```text
CTRL + RIGHT sobre Player
→ selected Skill
→ sólo si target_kind = entity
→ Game Server valida Player
→ same map / safe zone / alive / range
→ Action Approach si corresponde
→ aplica Skill
```

Poison PvP:

```text
Player Status Effect runtime
→ ticks authoritative
→ Player Vitals
→ combat activity
→ death lifecycle unificado
```

F30-C también dejó la base para futuros Entity Skills sin crear lógica PvP separada por Skill.

---

# 22. PLAYER DEATH + RESPAWN UNIFICADO ✅

Commit:

```text
f714f8d9884cd9d677901beb9f9b00813be1611f
feat: unify authoritative player death and respawn
```

Existe:

```text
PlayerDeathCoordinator
```

Unifica muerte por:

```text
Mob
PvP Basic Attack
PvP periodic damage / Poison
futuras fuentes que lleguen a Player Vitals
```

Policy actual:

```text
death
→ HP 0
→ clear movement/status/NPC service
→ release mob targets
→ wait 3 s
→ full HP
→ full MP
→ DEFAULT_SPAWN_POSITION
→ replicate
→ checkpoint runtime
```

Disconnect durante ventana de muerte:

```text
normaliza respawn antes del checkpoint durable
```

Persisted HP 0 histórico:

```text
login
→ recuperación automática
→ full HP/MP
→ spawn
```

Ya no debería ser necesario revivir manualmente personajes por SQL.

---

# 23. QUÉ FALTA PARA F30 COMPLETE

Current:

```text
F30-A ✅ targeting + safe zone
F30-B ✅ Basic Attack PvP
F30-C ✅ Entity Skills PvP
death/respawn ✅
```

Pendiente principal:

```text
F30-D — PvP Position Skills
```

Objetivo F30-D:

```text
cast position Skill
→ servidor valida center/range/LOS
→ resuelve Players dentro del área
→ aplica damage/status por Player
→ puede coexistir con Mobs
→ una misma Skill puede afectar targets autorizados
→ Client nunca envía victims
```

Ejemplo principal:

```text
Fire Ball AoE
→ centro en world position
→ Game Server resuelve Mobs + Players válidos
→ Unified Damage
→ Player/Mob Status Effect
→ death lifecycle correspondiente
```

Después:

```text
F30-E / Final Audit
```

No necesariamente requiere gran feature nueva.

Debe validar integralmente:

```text
safe zone
Basic Attack
Entity Skills
Position Skills
Action Approach
LOS
status effects
death/respawn
regen/combat state
disconnect/reconnect
no regressions PvE
```

Con ese audit:

```text
F30 — PvP Combat Foundation ✅ COMPLETE
```

PK/Sin/Auto-Defense sigue siendo:

```text
F31
```

NO mezclarlo dentro de F30.

---

# 24. UI / VISUAL PASS — NUEVA PRIORIDAD ACORDADA

El proyecto ya tiene suficiente foundation mecánica para pausar temporalmente F30-D y mejorar Presentation/UI.

Objetivo:

```text
reemplazar interfaces placeholder
→ adoptar nueva identidad visual
→ conservar architecture/data flow
```

El usuario ya posee plantillas nuevas descargadas para realizar un rediseño completo.

Regla principal:

```text
cambiar apariencia
!=
reescribir gameplay
```

La UI nueva debe seguir consumiendo:

```text
PlayerRuntimeState
InventoryData
EquipmentData
SkillBookData
SkillHotbarData
authoritative network state
```

No duplicar state dentro de Controls/Windows.

---

# 25. UI PASS — ORDEN RECOMENDADO

Trabajar como arco independiente, checkpoint por checkpoint.

## UI-1 — Visual System / Theme Foundation

```text
tipografía
paneles
botones
frames
slots
colores
hover/pressed/disabled
tooltips
spacing
shared styles
```

Primero definir reusable visual primitives.

No diseñar cada ventana como sistema aislado.

## UI-2 — Gameplay HUD

```text
HP
MP
EXP
hotbar
selected Skill
target feedback
combat feedback
```

## UI-3 — Core Windows

```text
Inventory
Equipment
Skills
Vault
Stats / Character
```

## UI-4 — Front Screens

```text
Login
Character Select
Character Create
```

## UI-5 — polish / responsiveness

```text
resolution behavior
anchors
scaling
window placement
tooltips
hover states
transitions
```

No es obligatorio seguir exactamente este orden si la plantilla importada tiene una estructura que conviene aprovechar, pero sí mantener checkpoints separados.

---

# 26. ITEMS Y SKILLS — ICON PIPELINE

Después de estabilizar los slots/frames visuales:

```text
Item Definition
→ icon asset

Skill Definition
→ icon asset
```

No hardcodear imágenes por nombre dentro de ventanas.

Preferir que el asset visual pertenezca a la definition/presentation data.

Items:

```text
Inventory
Equipment
Vault
Drops/tooltips
→ mismo icon source
```

Skills:

```text
Skill Book
Hotbar
Tooltip
Cast feedback
→ mismo icon source
```

Placeholder permitido:

```text
si definition todavía no tiene icon
→ fallback icon
```

No romper gameplay porque falte una imagen.

---

# 27. CONTENT EXPANSION — ITEMS

Después del UI/Icon pass se puede empezar a ampliar contenido real.

Orden recomendado:

```text
pocos items
→ verificar Inventory
→ Equipment
→ Requirements
→ Enhancement
→ visual/icon
→ persistence
→ recién después escalar catálogo
```

Tipos razonables a ampliar:

```text
weapons melee
bows/ranged
armor pieces
consumables cuando exista su gameplay
skill scrolls
future jewels
```

No crear 100 items antes de probar una familia completa.

---

# 28. CONTENT EXPANSION — SKILLS

La arquitectura actual permite agregar Skills progresivamente.

Cada nueva Skill debe declarar explícitamente:

```text
skill_id
target_kind
class/learning rules
mana
cooldown
range
scaling source
effect semantics
damage taxonomy si hace damage
status profile si aplica
LOS policy
area policy si aplica
```

Categorías futuras posibles:

```text
single-target direct damage
DoT
heal
buff
debuff
stun/root/slow
position AoE
mobility
utility
```

No escribir:

```text
if skill_id == nueva_skill
```

por todo el proyecto.

Agregar data/profile + consumer reusable cuando el dominio lo permite.

---

# 29. ART / ICON POLICY

Las imágenes son Presentation.

No alteran autoridad.

Puede usarse:

```text
PNG/WebP para icons
atlases si luego conviene
textures en Godot
```

Mantener naming estable, por ejemplo:

```text
assets/items/icons/
assets/skills/icons/
assets/ui/
```

La ruta final debe definirse revisando la estructura real antes de mover assets.

No introducir masivamente archivos sin una convención.

---

# 30. F31 — PK / SIN / AUTO-DEFENSE

Sigue futuro.

Separación:

```text
Combat
→ hit / damage / death

PvP Policy
→ legalidad de engagement

PK/Sin
→ penalización

Backend/MySQL
→ criminal state durable

Client
→ representation
```

Auto-defense:

```text
runtime Game Server
```

Sin/Criminal:

```text
durable
```

No abrir F31 hasta cerrar F30.

---

# 31. F32 — COMBAT PRESENTATION & FEEL

Sigue futuro como bloque mecánico-visual especializado.

Incluye:

```text
attack animations
cast animations
hit reactions
death animations
respawn visuals
Fire Ball VFX
Poison VFX
projectile visuals
floating numbers
miss/dodge/block feedback
critical feedback
status FX
SFX
camera feedback
```

El UI redesign actual puede adelantarse a F32 porque:

```text
UI shell / windows / icons
!=
combat animation/VFX pass
```

No confundir ambos scopes.

---

# 32. REGLAS QUE NO DEBEN REGRESIONAR

```text
1. Client nunca decide damage final.
2. Backend no entra al Combat hot loop.
3. Basic Attack no es Skill.
4. Equipment real determina Basic Attack.
5. `unarmed` sigue canónico.
6. Range se valida en Game Server.
7. LOS se valida en Game Server.
8. Cooldown/Mana son server-side.
9. Attack Speed es server-side.
10. Hit/Miss/Dodge/Block son server-side.
11. Crit es server-side.
12. Unified Damage Resolver se reutiliza.
13. Scaling Source != School != Element.
14. Poison scaling = Physical Power * 0.20.
15. Poison taxonomy = magical/poison/periodic.
16. Poison ticks no hacen nuevo hit roll.
17. DoTs no stackean infinitamente por defecto.
18. Current Poison same-effect policy = replace.
19. Player/Mob Vitals son authoritative.
20. Mob aggro/chase/leash son server-side.
21. Regen/combat timers son runtime.
22. Action Approach no hace request spam.
23. Client no decide víctimas AoE.
24. PvP reutiliza Combat, no duplica engine.
25. Safe Zone es server-side.
26. F30-C Entity Skill = target único concreto.
27. F30-D Position Skill = world position + server area resolution.
28. Player death usa PlayerDeathCoordinator.
29. Death no debe quedar durablemente en HP 0.
30. Respawn actual = 3 s + full HP/MP + default spawn.
31. Status Effects sobre Player y Mob mantienen autoridad GS.
32. Hard CC debe evitar permacontrol.
33. UI nueva no debe poseer verdad de gameplay.
34. Icons pertenecen a Presentation/Definition data.
35. No escalar catálogo masivo antes de probar families completas.
36. PK/Sin sigue separado en F31.
```

---

# 33. NUEVO PUNTO DE RETOMA RECOMENDADO

Se permite pausar temporalmente:

```text
F30-D
```

para abrir un arco visual separado:

```text
UI-1 — Visual System / Theme Foundation
```

Motivo:

```text
PvE foundation sólida
PvP Basic Attack sólido
PvP Entity Skills sólido
Status Effects sólidos
Death/Respawn unificado
```

Esto da suficiente gameplay real para diseñar la UI contra datos reales.

Después del UI/Icon pass:

```text
volver a F30-D
→ Position Skills PvP
→ F30 Final Audit
→ cerrar F30
```

---

# 34. PROMPT DE RETOMA PARA NUEVO CHAT

```text
Continuamos VHAL desde los PROJECT_MEMORY canónicos.

Leer en orden:
PROJECT_MEMORY.md
PROJECT_MEMORY_2.md
PROJECT_MEMORY_3.md
PROJECT_MEMORY_4.md
PROJECT_MEMORY_5.md

Luego revisar repos reales branch dev.

Heads esperados:

Client:
57ace06e48dd6d6321c17960c20cf3a7d2ca28ff
feat: send pvp entity skill intents

Game Server:
f714f8d9884cd9d677901beb9f9b00813be1611f
feat: unify authoritative player death and respawn

Backend:
ce3e0b02dbb1772204e12d1c2bb29d777b28b750
feat: expose equipment enhancement persistence endpoint

Estado:
F24 ✅
F25 ✅
F26 ✅
F27 ✅
F28 ✅
F29 ✅
F30-A ✅
F30-B ✅
F30-C ✅
Player Death/Respawn unificado ✅

Pendiente:
F30-D Position Skills PvP
F30 Final Audit

Nueva prioridad temporal acordada:
UI / visual redesign usando plantillas nuevas del usuario.

Después:
icons de Items/Skills
→ ampliar Items
→ ampliar Skills
→ retomar F30-D

Mantener workflow:
implementación
→ test
→ git status
→ scope review
→ commit
→ push
→ "pusheado"
→ remote verify.
```

---

# 35. RESUMEN CORTO

```text
VHAL ya tiene una base jugable real:

PvE:
aggro
chase
leash
mob attack
hit/dodge/block
damage
death/respawn
regen

Combat:
Unified Damage
Armor/MR/Elements
Hit Resolution
LOS
Status Effects
CC foundation
Action Approach

PvP:
target Player
Safe Zone
Basic Attack
Entity Skills
Poison/Player Status Effects
unified Player death/respawn

Pendiente F30:
Position Skills PvP
Final Audit

Nueva prioridad:
rediseñar UI completa con templates nuevas
→ luego iconos
→ luego ampliar Items/Skills
→ después retomar F30-D.
```
