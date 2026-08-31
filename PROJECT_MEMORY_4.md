# VHAL — PROJECT MEMORY 4 / F22-F DERIVED STATS CLOSURE

**Volumen:** 4  
**Inicio:** 31/08/2026  
**Última actualización canónica:** 31/08/2026  
**Motor Client / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`  

**Estado general al abrir este volumen:**

```text
F19 ✅
F20 ✅
F21-A ✅
F21-B ✅

F22-A ✅
F22-B ✅
F22-C ✅
F22-D ✅ CLOSED
F22-E ✅ CLOSED
F22-F ✅ CLOSED
```

Breakdown F22-F:

```text
F22-F1 ✅ Derived Stats Foundation
F22-F2 ✅ Max HP / Max MP
F22-F3 ✅ Physical / Magic / Healing Power
```

Integraciones reales ya cerradas dentro de F22-F3:

```text
Physical Power → Basic Attack ✅
Healing Power  → Heal ✅
Magic Power    → Derived autoritativo ✅
Magic Power consumer ofensivo → DEFERRED hasta Skill Combat
```

**Checkpoint siguiente según roadmap existente:**

```text
F22-G
Armor / Resistances / Crit
```

Antes de implementar F22-G se debe revisar el repo real y confirmar si el
scope sigue siendo el siguiente bloque correcto. No renombrar automáticamente
como F23 ni saltar F22-G/H/I/J/K sin una decisión explícita.

---

# 0. ORDEN DE LECTURA Y PRECEDENCIA

Orden obligatorio:

```text
1. PROJECT_MEMORY.md
2. PROJECT_MEMORY_2.md
3. PROJECT_MEMORY_3.md
4. PROJECT_MEMORY_4.md
5. futuros volúmenes en orden
6. repositorios reales branch dev
```

Precedencia:

> Este volumen prevalece para F22-F y decisiones posteriores cuando contradiga estados históricos de Volumen 3.

Los repositorios reales en `dev` siguen prevaleciendo sobre memoria si el
código cambió después de esta actualización.

`PROJECT_MEMORY_3.md` queda cerrado como volumen histórico porque ya alcanzó
aproximadamente el límite de tamaño acordado (~5.000 líneas).

No seguir agregándole etapas nuevas salvo corrección histórica imprescindible.

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

Escenas:

```text
.tscn → SIEMPRE editar manualmente desde Godot Editor
.gd   → puede entregarse completo o con cambios exactos
.md canónico → SIEMPRE entregar archivo completo
```

Nunca entregar `.tscn` como texto para reemplazar.

Audits temporales:

```text
pueden existir localmente
→ probar
→ retirar completamente
→ recién después commit
```

---

# 2. REPOSITORIOS

```text
Client / memoria:
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

# 3. HEADS REMOTOS VERIFICADOS AL 31/08/2026

## Client / memoria

```text
5ad4229e6a32ef0403d44734e6889c24620cae4f
feat: apply live authoritative vitals updates
```

Padre:

```text
8d3b36381b26f56539371c0eb7c1a86a158eaaa2
refactor: place vitals protocol with networking protocols
```

Commits Client relevantes de F22-F2:

```text
4d4f1ea227440623fd5eda91322f3bfd1db71396
feat: receive live character vitals updates

8d3b36381b26f56539371c0eb7c1a86a158eaaa2
refactor: place vitals protocol with networking protocols

5ad4229e6a32ef0403d44734e6889c24620cae4f
feat: apply live authoritative vitals updates
```

## Game Server

HEAD:

```text
2f3934834d5f5bdc5ded56c2ad1e8b82ecfd9b73
feat: apply healing power to heal skill
```

Padre:

```text
338817c8785f7df35e6017c15826d0718d7fe3f7
feat: apply physical power to basic attack damage
```

Commits relevantes F22-F:

```text
645e7b61667d6d619515427e2fddc6a10836fbe3
feat: add derived stats runtime state

36f9f6a2ecc55f7df29967e209f3644c49a258e4
feat: add derived stats rules and bootstrap

4b9f308d4eec1749be808b18440bd53c99756d8a
feat: attach derived stats to world session

c9dee47d1fc8d0be07e97bba89bed19e9caa1358
feat: rebuild derived stats after primary changes

63b8519f8cdee84a70844baf4b7dc67f1798e47f
feat: add class derived vitals parameters

94fa1fdc75b9853b792121f9367f102f75f357aa
feat: derive max hp and mp from primary stats

985c1153e6f8c7dc984109a0aa32cb6b63200126
feat: drive runtime vitals from derived stats

18fcc3d1dddd3e7badfb28ef16470e9cf78dae48
feat: support live vitals maximum changes

d91aebc9ae71a0da852567e5e263756cd3e44035
feat: sync live vitals with derived stats

f7982f9a9c86490a6fd1a51aaed0e9232ac577b3
fix: keep progression stat updates level gated

75316c7fe63edca5abc58319e6454f75e975ad1b
feat: add live character vitals update contract

17c6362434bdfcdbbb7a1cb1be85a68906d98344
feat: replicate live vitals after stat changes

ad7b3af03c25df0e660367ebf5d736fd8acad1b9
feat: define class derived power balance

c44e104066e8dfcbab75012ae77c2b71dcfd693f
feat: calculate authoritative derived power

338817c8785f7df35e6017c15826d0718d7fe3f7
feat: apply physical power to basic attack damage

2f3934834d5f5bdc5ded56c2ad1e8b82ecfd9b73
feat: apply healing power to heal skill
```

## Backend

```text
ce0b202561dfee2e412f6edaf4e8df7bd422842e
feat: expose durable character stat allocation
```

Backend no fue modificado durante F22-F.

Derived Stats continúan siendo responsabilidad determinística del Game Server,
no verdad durable del Backend/MySQL.

---

# 4. ARQUITECTURA AUTORITATIVA VIGENTE

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

Derived Stats:

```text
MySQL              ❌ no persiste derived finales
Backend            ❌ no calcula derived como autoridad
Game Server        ✅ calcula / valida / usa
Client             ✅ representa snapshots autoritativos cuando corresponde
```

La fuente durable para Derived sigue siendo:

```text
Class
Level
Reset futuro
Primary allocations
bonus points
Equipment futuro
Permanent bonuses futuros
```

---

# 5. F22-F — CLOSED ✅

Objetivo cerrado:

```text
Permanent Primary Stats
↓
Derived Stats determinísticos
↓
Vitals derivados
↓
Power derivado
↓
primeros consumers reales de gameplay
```

F22-F NO convirtió Derived Stats en estado durable independiente.

Estado:

```text
F22-F1 Derived Stats Foundation ✅
F22-F2 Max HP / Max MP          ✅
F22-F3 Power                    ✅
```

---

# 6. F22-F1 — DERIVED STATS FOUNDATION ✅

Core Game Server:

```text
core/stats/server_character_derived_stats_state.gd
core/stats/server_character_derived_stats_rules.gd
core/stats/server_character_derived_stats_bootstrap.gd
```

`PlayerWorldSession` posee:

```text
derived_stats: ServerCharacterDerivedStatsState
```

El estado contiene foundation para:

```text
max_hp
max_mp
hp_regeneration
mp_regeneration
physical_power
magic_power
healing_power
```

Regeneration continúa en foundation `0` por ahora.

Los valores de Power y Max HP/MP ya dejaron de ser placeholders.

---

# 7. REBUILD DE DERIVED STATS

Derived se reconstruye cuando cambia una fuente relevante.

Actualmente comprobado en:

```text
fresh PlayerWorldSession
Primary Stat allocation
Level-Up
stale_revision recovery de Primary Stats
```

Invariante:

```text
derived_stats.source_primary_stats_revision
=
primary_stats.revision
```

Level puede cambiar sin aumentar `revision` de allocations.

Por eso Derived también debe reconstruirse por Progression aunque la revision de
Primary permanezca igual.

---

# 8. CLASS VITALS BALANCE CONTRACT v1

Parámetros por clase:

```text
base_max_hp
hp_per_level
hp_per_vitality

base_max_mp
mp_per_level
mp_per_energy
```

## Warrior

```text
base_max_hp      100
hp_per_level       8
hp_per_vitality    4

base_max_mp       30
mp_per_level        1
mp_per_energy       3
```

## Mage

```text
base_max_hp       70
hp_per_level       5
hp_per_vitality    3

base_max_mp      120
mp_per_level        4
mp_per_energy       5
```

## Archer

```text
base_max_hp       85
hp_per_level       6
hp_per_vitality    3

base_max_mp       70
mp_per_level        2
mp_per_energy       4
```

Validación:

```text
HP base > 0
HP per level >= 0
HP per VIT > 0

MP base >= 0
MP per level >= 0
MP per ENE > 0
```

---

# 9. MAX HP / MAX MP — FÓRMULAS CANÓNICAS

```text
Max HP
=
base_max_hp
+
(level - 1) * hp_per_level
+
Permanent VIT * hp_per_vitality
```

```text
Max MP
=
base_max_mp
+
(level - 1) * mp_per_level
+
Permanent ENE * mp_per_energy
```

Sólo el Game Server es autoridad de estas fórmulas.

El Client NO recalcula Max HP/MP desde Primary Stats.

---

# 10. SERVER VITALS — SEMÁNTICA CANÓNICA

`ServerVitalsState` distingue dos operaciones diferentes.

## Bootstrap / fresh session

```text
configure(max_hp, max_mp)
```

Semántica:

```text
crear Vitals con esos máximos
current HP = max HP
current MP = max MP
```

Luego el runtime durable puede restaurar `hp` / `mp` actuales usando setters y
quedar clampado contra los máximos recién derivados.

## Cambio live de máximos

```text
reconfigure_maximums(max_hp, max_mp)
```

Semántica:

```text
conservar current HP / MP
cambiar máximos
clamp sólo si el nuevo máximo quedó por debajo del current
```

Regla crítica:

```text
subir VIT / ENE o subir Level
NO cura
NO rellena mana
```

---

# 11. VITALS LIVE — CASOS AUDITADOS

Se comprobó en Primary allocation:

```text
+1 VIT
Max HP aumenta
current HP se conserva
```

Se comprobó en ENE:

```text
+1 ENE
Max MP aumenta
current MP se conserva
```

Se comprobó en Level-Up:

```text
Max HP aumenta
Max MP aumenta
current HP se conserva
current MP se conserva
```

No se usa un refill implícito como side effect de cambiar máximos.

---

# 12. LIVE VITALS NETWORK CONTRACT ✅

Game Server mensaje:

```text
character_vitals_updated
```

Payload conceptual:

```text
character_id
vitals
├── hp
├── max_hp
├── mp
└── max_mp
```

Transporte:

```text
reliable
channel 0
```

Game Server API:

```gdscript
send_character_vitals_updated(
	peer_id,
	character_id,
	vitals_snapshot
)
```

---

# 13. ORDEN DE REPLICACIÓN LIVE

## Primary Stat allocation

```text
Primary Stat Allocation Result
↓
Vitals Updated
```

## Level-Up

```text
Progression Updated
↓
Primary Stats Updated
↓
Vitals Updated
```

## stale_revision recovery

```text
Allocation Result / authoritative Primary snapshot
↓
Vitals Updated
```

Todo usa reliable/channel 0 para preservar orden.

---

# 14. CLIENT VITALS PROTOCOL ✅

Archivo canónico:

```text
features/gameplay/networking/protocols/game_server_vitals_protocol.gd
```

IMPORTANTE:

Existió inicialmente un error de ubicación:

```text
features/gameplay/protocols/
```

Fue corregido mediante commit:

```text
8d3b36381b26f56539371c0eb7c1a86a158eaaa2
refactor: place vitals protocol with networking protocols
```

No volver a crear una carpeta paralela `features/gameplay/protocols` para estos
protocolos.

---

# 15. CLIENT LIVE VITALS FLOW ✅

```text
Game Server
↓
character_vitals_updated
↓
GameServerVitalsProtocol
↓
GameServerClient.character_vitals_updated
↓
GameSessionFlowCoordinator
↓
PlayerRuntimeState.apply_vitals_snapshot(...)
↓
VitalsState
↓
hp_changed / mp_changed
↓
GameplayUI HUD
```

El Client valida identity de Character antes de aplicar el snapshot.

Si el update pertenece a otro Character o el snapshot es inválido:

```text
fail closed / end session
```

---

# 16. SKILL CASTS Y VITALS

Los casts ya poseen su propio resultado autoritativo:

```text
skill_cast_result
```

que incluye:

```text
vitals snapshot
cooldown
effect
```

Por eso Heal NO necesita emitir adicionalmente `character_vitals_updated`.

Flujo actual:

```text
Skill Cast Result
↓
GameServerClient
↓
GameSessionFlowCoordinator
↓
GameplayScreen.apply_authoritative_skill_cast_result
↓
PlayerRuntimeState.apply_vitals_snapshot
↓
HUD
```

No duplicar dos mensajes de Vitals para el mismo Heal sin una necesidad real.

---

# 17. CLASS POWER BALANCE CONTRACT v1

Parámetros Physical:

```text
base_physical_power
physical_power_per_level
physical_power_per_strength
physical_power_per_agility
```

Parámetros Magic:

```text
base_magic_power
magic_power_per_level
magic_power_per_energy
```

Parámetros Healing:

```text
base_healing_power
healing_power_per_level
healing_power_per_energy
```

---

# 18. POWER BALANCE — WARRIOR

```text
Physical:
base 10
+2 / Level
+2 / STR
+0 / AGI

Magic:
base 0
+0 / Level
+1 / ENE

Healing:
base 0
+0 / Level
+1 / ENE
```

Warrior sigue orientado a STR para Physical Power.

ENE sigue teniendo valor para mana y skills híbridas/support.

---

# 19. POWER BALANCE — MAGE

```text
Physical:
base 5
+1 / Level
+1 / STR
+0 / AGI

Magic:
base 20
+2 / Level
+2 / ENE

Healing:
base 10
+1 / Level
+2 / ENE
```

Mage posee Physical residual pero su crecimiento principal queda en ENE.

---

# 20. POWER BALANCE — ARCHER

```text
Physical:
base 15
+2 / Level
+1 / STR
+1 / AGI

Magic:
base 0
+0 / Level
+1 / ENE

Healing:
base 0
+0 / Level
+1 / ENE
```

Archer demuestra que Physical Power NO puede codificarse como `STR only`.

El catálogo de clase define los pesos.

---

# 21. POWER — FÓRMULAS CANÓNICAS

## Physical Power

```text
Physical Power
=
base_physical_power
+
(level - 1) * physical_power_per_level
+
Permanent STR * physical_power_per_strength
+
Permanent AGI * physical_power_per_agility
```

## Magic Power

```text
Magic Power
=
base_magic_power
+
(level - 1) * magic_power_per_level
+
Permanent ENE * magic_power_per_energy
```

## Healing Power

```text
Healing Power
=
base_healing_power
+
(level - 1) * healing_power_per_level
+
Permanent ENE * healing_power_per_energy
```

Functions canónicas actuales:

```gdscript
calculate_physical_power(...)
calculate_magic_power(...)
calculate_healing_power(...)
```

Estas funciones NO son scaffolding temporal.

Su existencia forma parte de la arquitectura de reglas.

Puede cambiar el balance interno o agregarse nuevos inputs en el futuro, pero
el resto del gameplay no debe copiar fórmulas por fuera de este dominio.

---

# 22. POWER LIVE REBUILD — AUDIT ✅

ProgAudit auditó:

```text
+1 STR
Power P/M/H:
80/12/12
→ 82/12/12
```

Luego:

```text
+1 ENE
Power P/M/H:
82/12/12
→ 82/13/13
```

Luego Level-Up 10 → 11:

```text
Power P/M/H:
82/13/13
→ 84/13/13
```

En el mismo Level-Up:

```text
Max HP / Max MP
280/78
→ 288/79
```

Current runtime permaneció:

```text
HP 260
MP 70
```

sin refill.

---

# 23. PHYSICAL POWER → BASIC ATTACK ✅

Commit:

```text
338817c8785f7df35e6017c15826d0718d7fe3f7
feat: apply physical power to basic attack damage
```

Nuevo core:

```text
core/combat/server_basic_attack_damage_rules.gd
```

Regla foundation:

```text
Pre-Mitigation Basic Attack Damage
=
Attack Profile Base Damage
+
Physical Power
```

La función produce explícitamente daño `pre_mitigation`.

No llamarlo final damage porque todavía faltan:

```text
Armor
Defense
Resistances
Crit
Block
Penetration
PvP modifiers
```

---

# 24. BASIC ATTACK COORDINATOR — RESPONSABILIDAD

`BasicAttackCoordinator` NO contiene la fórmula de balance.

Responsabilidad:

```text
resolver session
autenticar intent
resolver target
resolver attack profile
validar range/cooldown
pedir daño a ServerBasicAttackDamageRules
aplicar daño a WorldMobRegistry
replicar resultado
```

No volver a incrustar una fórmula `base + power` directamente en el coordinator.

---

# 25. UNARMED FOUNDATION ACTUAL

Se conserva temporalmente:

```text
UNARMED_BASE_DAMAGE = 500
```

No se rebalanceó durante F22-F3-D1.

Motivo:

```text
D1 = conectar Physical Power
NO = balance final de puños
```

Bronze Sword existente:

```text
basic_attack_base_damage = 1000
range = 2.0
cooldown = 0.9
```

El mismo damage rule puede consumir cualquier Attack Profile válido.

---

# 26. BASIC ATTACK AUDIT REAL ✅

ProgAudit durante D1:

```text
Physical Power = 84
Base Damage = 500
```

Resultado:

```text
Pre-Mitigation
500 + 84
= 584
```

Training Goblin:

```text
5000/5000
→
4416/5000
```

Log probado:

```text
Base Damage: 500
Physical Power: 84
Pre-Mitigation: 584
Damage: 584
Killed: false
```

Al usar un solo golpe:

```text
no muerte
no EXP
no drop
```

Así D1 aisló exclusivamente el cálculo de daño.

---

# 27. HEALING POWER → HEAL ✅

Commit:

```text
2f3934834d5f5bdc5ded56c2ad1e8b82ecfd9b73
feat: apply healing power to heal skill
```

`ServerHealEffect` eliminó el placeholder histórico:

```text
BASE_HEAL_AMOUNT = 20_000
```

Regla foundation actual:

```text
Requested Heal
=
Healing Power
```

Esta relación 1:1 es foundation, NO balance final de todas las skills de Heal.

A futuro una Skill Definition puede aportar:

```text
base heal
coefficient
scaling profile
```

sin duplicar la fórmula por coordinator.

---

# 28. SERVER HEAL EFFECT — SEMÁNTICA

Separación actual:

```text
calculate_heal_amount(derived_stats)
→ requested amount

apply(vitals, requested_heal_amount)
→ restored amount real
```

Esto permite distinguir:

```text
Requested Heal = 13
Restored Heal  = 13
```

o, cerca del máximo:

```text
Requested Heal = 13
Restored Heal  = 5
```

El payload autoritativo reporta:

```text
effect.kind = heal
effect.amount = restored_hp real
```

No reportar como effect amount una cantidad que realmente no entró en HP.

---

# 29. HEAL AUDIT REAL ✅

ProgAudit:

```text
Healing Power = 13
Heal mana cost = 40
Heal cooldown = 4.0 s
```

Antes:

```text
HP 260/288
MP 70/79
```

Cast:

```text
Requested Heal = 13
Restored Heal = 13
```

Después:

```text
HP 273/288
MP 30/79
```

Client aplicó el snapshot autoritativo del cast y el HUD cambió live.

Audit:

```text
0 warnings
0 errors
```

---

# 30. MAGIC POWER — ESTADO CANÓNICO

Magic Power está completamente resuelto como Derived Stat:

```text
Class balance contract ✅
formula autoritativa ✅
fresh bootstrap ✅
Primary allocation rebuild ✅
Level-Up rebuild ✅
audit live ✅
```

Pero todavía NO posee consumer ofensivo real.

Skills existentes:

```text
fire_ball
poison
heal
```

Estado Game Server:

```text
Heal      ✅ implemented
Fire Ball ❌ skill_not_implemented
Poison    ❌ skill_not_implemented
```

Decisión:

> No implementar Fire Ball artificialmente sólo para “usar” Magic Power dentro de F22-F.

Implementar Fire Ball correctamente abre un bloque de Skill Combat:

```text
skill damage profile
target range
Magic Power coefficient
mob damage
kill attribution
EXP/drop attribution
result effect
future element/resistance
```

Eso debe tener su propio scope.

---

# 31. HEAL SKILL OWNERSHIP — NUEVO BASELINE DURABLE

Durante la preparación de D2, ProgAudit no poseía Heal.

Se usó un audit temporal de drop:

```text
Training Goblin
health_potion 100%
→ temporalmente skill_scroll_heal 100%
```

El scroll se obtuvo por el flujo real:

```text
mob death
→ world drop
→ pickup
→ durable Inventory
```

Luego se aprendió en el NPC real:

```text
Skill Trainer
```

Game Server confirmó:

```text
Skill: heal
Learned: ["heal"]
Idempotent: false
```

Backend consumió el scroll dentro del mismo commit durable de aprendizaje.

Después:

```text
git restore core/world/drops/server_mob_drop_catalog.gd
```

Resultado:

```text
git status --short
# limpio
```

La fixture temporal NO quedó en remoto.

La skill Heal SÍ queda durable.

---

# 32. DROP TABLE OFICIAL NO CAMBIÓ

Training Goblin oficial sigue:

```text
health_potion
chance 1.0
quantity 1
```

No dejar `skill_scroll_heal` como drop fijo oficial sólo por haberlo usado en un audit.

---

# 33. BASELINE DURABLE ACTUAL — PROGAUDIT

```text
Character ID 5
Name ProgAudit
Class warrior
Reset 0
```

Progression durable después de los audits:

```text
Level 11
EXP 65/400
```

El paso `15 → 65` provino de la única muerte real usada para obtener el Heal Scroll.

No revertir esa EXP manualmente.

Primary Stats:

```text
revision 7
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
STR 2
AGI 0
VIT 2
ENE 3
```

Permanent:

```text
STR 27
AGI 15
VIT 27
ENE 13
```

Budget:

```text
level_points 50
reset_points 0
bonus_points 0

total 50
spent 7
unspent 43
```

Derived determinístico:

```text
Max HP 288
Max MP 79
Physical Power 84
Magic Power 13
Healing Power 13
HP Regeneration 0
MP Regeneration 0
```

Durable Skills:

```text
["heal"]
```

No quitar Heal manualmente.

---

# 34. PROGAUDIT — ÚLTIMO RUNTIME OBSERVADO

Último estado observado después del audit D2:

```text
HP 273/288
MP 30/79
```

IMPORTANTE:

> Este bloque describe el último runtime observado, no debe usarse como afirmación de que un fresh reconnect necesariamente cargará exactamente esos current HP/MP sin volver a verificar la persistencia runtime.

Los máximos `288/79` sí son determinísticos con Level/Primary actuales.

---

# 35. BASELINE DURABLE — ATILIO

No fue modificado durante F22-F.

```text
Character ID 1
Warrior
Level 124
EXP 50
Reset 0

Primary revision 3

Base:
25 / 15 / 25 / 10

Allocated:
12 / 0 / 0 / 0

Permanent:
37 / 15 / 25 / 10

spent 12/615
unspent 603
```

No revertir a STR11/STR10 ni revision 2/1.

Derived esperado determinísticamente con balance actual:

```text
Max HP 1184
Max MP 183
Physical Power 330
Magic Power 10
Healing Power 10
```

Si un audit futuro observa otra cosa, revisar el repo real antes de editar datos.

---

# 36. BASELINE DURABLE — LYRA

No fue modificada durante F22-F.

```text
Character ID 2
Archer
Level 85
EXP 0
Reset 0

Primary revision 0
Allocated 0/0/0/0

Permanent:
STR 15
AGI 30
VIT 15
ENE 15

spent 0/420
unspent 420
```

No crear allocations ficticias para Lyra.

Derived esperado determinísticamente con balance actual:

```text
Max HP 634
Max MP 298
Physical Power 228
Magic Power 15
Healing Power 15
```

---

# 37. CLIENT NO NECESITA DERIVED POWER COMO VERDAD LOCAL TODAVÍA

Actualmente el Client necesita representar live:

```text
Primary Stats
Progression
Vitals
```

Physical/Magic/Healing Power son consumidos por gameplay autoritativo del
Game Server y no existe todavía una Character Sheet que necesite mostrarlos.

No crear una segunda fórmula Client sólo para mostrar Power.

Cuando una UI necesite esos valores:

```text
Game Server snapshot
→ Client representation
```

No:

```text
Client recalcula con coeficientes copiados
```

---

# 38. SOURCE OF TRUTH — RESUMEN

```text
Level / EXP
→ durable Backend + authoritative GS progression rules

Primary allocations
→ durable Backend

Base Stats
→ Game Server Class Catalog

Permanent Primary
→ Game Server derived from Base + Allocated

Derived Stats
→ Game Server deterministic

Current HP / MP
→ Game Server runtime + durable runtime system cuando corresponda

UI
→ representation only
```

---

# 39. REGENERATION — TODAVÍA FOUNDATION

Actualmente:

```text
HP Regeneration = 0
MP Regeneration = 0
```

No inventar ticks de regen dentro de F22-F ya cerrado.

La futura implementación necesita decidir al menos:

```text
rate
interval
autoridad
combat/non-combat rules
network replication
caps
ENE/VIT scaling
```

Debe ser una etapa independiente.

---

# 40. COMBAT TODAVÍA PENDIENTE

F22-F sólo conectó un primer consumer simple de Physical Power.

Todavía faltan sistemas reales como:

```text
Armor
Magic Resistance
Elemental Resistances
Critical Chance
Critical Damage
Block
Accuracy
Evasion
Penetration
Skill coefficients
PvP modifiers
```

Por eso `pre_mitigation_damage` es el término correcto para Basic Attack actual.

---

# 41. F22-G — ROADMAP EXISTENTE

Volumen 3 definió como siguiente bloque:

```text
F22-G
Armor / Resistances / Crit
```

Estado:

```text
⏳ FUTURE / NEXT CANDIDATE
```

No implementar todo junto.

Antes de codear dividir en etapas pequeñas, por ejemplo sólo después de auditar
el estado real del repo:

```text
G1 defensive domain foundation
G2 armor / physical mitigation
G3 magic resistance / schools
G4 crit foundation
...
```

Los nombres exactos quedan sujetos al audit.

---

# 42. F22-H / I / J / K — TODAVÍA FUTURO

Roadmap histórico:

```text
F22-H
Attack Speed + Movement Speed

F22-I
Equipment Stat Modifiers

F22-J
Skill Scaling + Stat Requirements + reset-safe usability

F22-K
Integrated Balance Audit
```

No considerarlos implementados.

No saltarlos silenciosamente sólo porque F22-F esté cerrado.

Si se decide reorganizar F22/F23, documentar primero la nueva decisión.

---

# 43. DECISIONES DE BALANCE A NO ROMPER

```text
STR → principalmente Physical melee
AGI → ranged Physical / Accuracy / pequeña Attack Speed futura
VIT → Max HP
ENE → Max MP / Magic / Healing
```

AGI:

```text
NO aumenta Movement Speed directamente
```

Primary Stats no deben convertirse simultáneamente en la mejor fuente de:

```text
damage
defense
crit
attack speed
movement speed
survivability
```

Armor/Resistances deben provenir principalmente de Equipment/Secondary systems,
no de inflar VIT/AGI sin límites.

---

# 44. MAX LEVEL / PRIMARY BUDGET SIGUEN VIGENTES

```text
MAX_LEVEL = 400
STAT_POINTS_PER_LEVEL = 5
RESET_STAT_POINTS = 350
```

`unspent` continúa derivado:

```text
unspent
=
total budget
-
spent allocation
```

No persistir `unspent` como verdad durable.

---

# 45. RESET SIGUE FUTURO

F22-F NO implementó Reset.

Sigue vigente la dirección de Volumen 3:

```text
Level 400
→ Reset NPC
→ validation
→ Backend atomic transaction
→ Level 1
→ reset_count +1
→ normal allocations cleared
→ Reset budget acumulativo
```

No introducir Reset dentro de F22-G salvo decisión explícita.

---

# 46. BULK PRIMARY ALLOCATION SIGUE DEFERRED

Estado:

```text
+1 ✅
+5/+10/custom/all ⏸️ DEFERRED UX
```

El protocolo ya soporta `points > 1`.

No reabrir F22-D sólo por comodidad UX.

---

# 47. INPUT CANÓNICO — NO ROMPER

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

# 48. SKILLS ACTUALES

Catálogo:

```text
fire_ball
poison
heal
```

Learning:

```text
Fire Ball → Mage, level >= 10
Poison    → Archer, level >= 10
Heal      → Warrior/Mage/Archer, level >= 5
```

Runtime effects:

```text
Heal      ✅ real
Fire Ball ❌ not implemented
Poison    ❌ not implemented
```

No confundir existencia en catálogo con implementación de efecto real.

---

# 49. HEAL CURRENT FOUNDATION

```text
mana_cost = 40
cooldown = 4.0 seconds
target = self
```

Current scaling:

```text
requested_heal = Healing Power
```

Esto es foundation para validar ownership y flujo, no balance final.

---

# 50. BASIC ATTACK CURRENT FOUNDATION

Unarmed:

```text
base damage = 500
range = 1.5
cooldown = 1.0
```

Bronze Sword:

```text
base damage = 1000
range = 2.0
cooldown = 0.9
```

Current pre-mitigation formula:

```text
base damage + Physical Power
```

No aplicar Armor todavía hasta abrir la etapa correspondiente.

---

# 51. INVARIANTES F22-F CERRADOS

```text
1. Derived Stats no son verdad durable independiente.
2. Game Server es autoridad de fórmulas Derived.
3. Client no duplica fórmulas Derived como autoridad.
4. Derived se reconstruye desde Primary/Progression autoritativos.
5. Max HP usa Level + Permanent VIT + Class balance.
6. Max MP usa Level + Permanent ENE + Class balance.
7. Physical Power usa Class balance + Level + STR/AGI.
8. Magic Power usa Class balance + Level + ENE.
9. Healing Power usa Class balance + Level + ENE.
10. Subir máximo live NO rellena current HP/MP.
11. `configure()` y `reconfigure_maximums()` tienen semánticas distintas.
12. Live Vitals usan mensaje semántico `character_vitals_updated`.
13. Level-Up replica Progression → Primary → Vitals.
14. Allocation replica Result → Vitals.
15. Client aplica Vitals live al PlayerRuntimeState.
16. HUD se actualiza mediante VitalsState signals.
17. Basic Attack consume Physical Power mediante Damage Rules.
18. Basic Attack actual produce pre-mitigation damage.
19. Heal consume Healing Power mediante ServerHealEffect.
20. Heal effect amount representa HP realmente restaurado.
21. Magic Power no tiene consumer ofensivo real todavía.
22. Fire Ball/Poison siguen `skill_not_implemented`.
23. No implementar Fire Ball sólo para justificar F22-F.
24. HP/MP Regeneration siguen 0.
25. Derived Power no necesita persistencia Backend.
26. Atilio no se revierte.
27. Lyra no recibe allocations ficticias.
28. ProgAudit no se revierte después de audits válidos.
29. Heal quedó durablemente aprendido por ProgAudit.
30. Drop temporal de Heal Scroll fue eliminado antes de commit.
```

---

# 52. AUDITS TEMPORALES IMPORTANTES — NO RECREAR COMO FEATURES

Durante F22-F se usaron fixtures temporales controladas para probar situaciones
que no justificaban una feature permanente.

Ejemplos:

```text
MAX_LEVEL temporal 6 durante E5
Heal Scroll temporal como Training Goblin drop durante D2 prep
```

Ambas fueron restauradas antes de commits permanentes.

Regla:

```text
fixture de audit
!=
feature del juego
```

---

# 53. GIT CLEANUP / PATH RULE

Protocolos de gameplay networking viven en:

```text
features/gameplay/networking/protocols/
```

No en:

```text
features/gameplay/protocols/
```

El cleanup de Vitals ya fue realizado y verificado remotamente.

---

# 54. F22-F — RESUMEN DE FLUJO COMPLETO

```text
Durable Level / Primary allocations
↓
Game Server Primary Stats
↓
Derived Stats
├── Max HP / Max MP
├── Physical Power
├── Magic Power
└── Healing Power
↓
Runtime consumers
├── ServerVitalsState
├── Basic Attack Damage Rules
└── Heal Effect
↓
Authoritative replication
↓
Client runtime / HUD
```

Magic Power queda disponible para un consumer futuro de Skill Combat.

---

# 55. CHECKPOINT DE CONTINUIDAD

Al retomar desde este volumen:

```text
NO rehacer F22-F1.
NO rehacer Max HP/MP formulas.
NO volver a DEFAULT_MAX_HP históricos.
NO volver a Heal fijo 20_000.
NO quitar Physical Power del Basic Attack.
NO duplicar derived formulas en Client.
NO revertir ProgAudit Level/Stats/Heal.
NO dejar skill_scroll_heal como drop oficial del goblin.
NO implementar Fire Ball de apuro.
```

Primero:

```text
1. verificar HEAD de los tres repos
2. revisar F22-G roadmap
3. auditar combat/defensive domain real
4. partir G en una etapa pequeña
5. implementar manualmente
6. test
7. 0 warnings/errors
8. git diff --check/status
9. commit/push
10. esperar "pusheado"
```

---

# 56. PRÓXIMO CANDIDATO REAL — F22-G

Nombre histórico:

```text
F22-G
Armor / Resistances / Crit
```

Antes de implementar se debe responder:

```text
¿Qué estado defensivo existe hoy en mobs/players?
¿Hay Armor actual en Equipment catalog o todavía no?
¿Dónde debe vivir mitigation?
¿Damage taxonomy physical/magical ya merece entrar?
¿Conviene separar Armor y Crit en commits distintos?
¿Cómo evitar acoplar Fire Ball antes de tiempo?
```

Recomendación de proceso:

```text
audit primero
→ definir G1 mínimo
→ no implementar Armor + Resistances + Crit todo junto
```

---

# 57. POSIBLE DESCOMPOSICIÓN DE F22-G — NO DEFINITIVA

Sólo como guía para el audit:

```text
F22-G1
Defensive Stats domain foundation

F22-G2
Physical mitigation / Armor

F22-G3
Magic Resistance + Damage School foundation

F22-G4
Critical Chance / Critical Damage foundation
```

No considerar esta numeración canónica hasta revisar el repo real.

---

# 58. QUÉ NO HACER EN EL PRÓXIMO BLOQUE

Evitar mezclar inmediatamente:

```text
Armor
Magic Resistance
all elemental resistances
Crit
Block
Evasion
Penetration
PvP
Fire Ball
Poison
Attack Speed
Movement Speed
Equipment stat affixes
Reset
```

Elegir una sola capacidad mínima con un audit demostrable.

---

# 59. CRITERIO DE DISEÑO DE COMBAT FUTURO

Pipeline conceptual sigue siendo:

```text
Attack / Skill source
↓
Offensive Power
↓
Pre-Mitigation Damage
↓
Defense / Resistance
↓
Critical / modifiers según orden canónico futuro
↓
Final Damage
↓
Vitals mutation
```

El orden exacto de Crit respecto de mitigation todavía debe definirse antes de
implementarlo como contrato definitivo.

No asumirlo desde esta memoria.

---

# 60. CIERRE EJECUTIVO

F22-F queda cerrado con una foundation usable y ya conectada a gameplay real.

Se demostró:

```text
VIT/ENE/Level
→ Max HP/MP derivados
→ cambio live sin refill
→ networking autoritativo
→ HUD live

STR/AGI/ENE/Level
→ Physical/Magic/Healing Power
→ rebuild live

Physical Power
→ Basic Attack pre-mitigation

Healing Power
→ Heal real
```

No se forzó Magic Power dentro de una skill ofensiva inexistente.

El siguiente trabajo debe comenzar con un audit de `F22-G`, manteniendo el mismo
workflow incremental y sin reabrir sistemas ya cerrados.
