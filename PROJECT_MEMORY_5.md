# VHAL — PROJECT MEMORY 5 / F22-G → F22-J CLOSURE

**Volumen:** 5  
**Inicio:** 06/09/2026  
**Última actualización canónica:** 06/09/2026  
**Motor Client / Game Server:** Godot 4.7.1  
**Backend:** Laravel + MySQL  
**Rama habitual:** `dev`

---

# 0. ORDEN DE LECTURA Y PRECEDENCIA

```text
1. PROJECT_MEMORY.md
2. PROJECT_MEMORY_2.md
3. PROJECT_MEMORY_3.md
4. PROJECT_MEMORY_4.md
5. PROJECT_MEMORY_5.md
6. futuros volúmenes
7. repositorios reales branch dev
```

Este volumen prevalece para F22-G, F22-H, F22-I, F22-J y decisiones posteriores cuando contradiga estados históricos anteriores.

Los repositorios reales en `dev` siguen prevaleciendo sobre memoria si el código cambió después de esta actualización.

`PROJECT_MEMORY_4.md` queda como cierre histórico de F22-F.

---

# 1. WORKFLOW OBLIGATORIO ACTUAL

```text
ETAPA / FASE ACORDADA
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
.tscn → siempre editar manualmente desde Godot Editor.
.gd   → completo o cambios exactos.
.md canónico → archivo completo, nunca patch.
```

Objetivo habitual:

```text
0 warnings
0 errors
```

Hooks/audits temporales:

```text
pueden existir durante una prueba
→ se prueban
→ se eliminan
→ recién después se cierra el bloque
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

# 3. HEADS REMOTOS VERIFICADOS — 06/09/2026

## Client

```text
4ff9c79b1fa3376bb155d318e18856da3807ccf9
chore: remove temporary enhancement debug trigger
```

Relevantes:

```text
5a3e14eb9bd729b06b33c4c50031d8aeb56ee0d8
feat: complete equipment enhancement client roundtrip

b147419974397dfc99bd66ddbaed812cac5b284e
feat: add equipment enhancement client transport
```

## Game Server

```text
cb84c83dfac5220b651159f09bab1af1a7bec563
feat: add skill scaling and usage requirements
```

Anterior:

```text
1a5e117511f412fc110d53d7e10a472c6407e4f9
fix: normalize persisted item state from backend
```

## Backend

```text
ce3e0b02dbb1772204e12d1c2bb29d777b28b750
feat: expose equipment enhancement persistence endpoint
```

Anterior:

```text
c76f9d937f1a252780025e065ae2e7567aa52b1a
feat: persist equipment enhancement transitions
```

---

# 4. ESTADO GENERAL

```text
F19 ✅
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

NEXT:
F22-K — Integrated Balance Audit
```

---

# 5. F22-G — ARMOR / CRIT ✅

Integrado:

```text
Critical Strike Chance
Critical Damage Multiplier
Physical Armor Mitigation
Character Physical Defense Profile foundation
```

Foundation actual:

```text
critical_strike_chance = 0.0
critical_damage_multiplier = 1.5
```

Basic Attack autoritativo:

```text
base damage
+
Physical Power
→ pre-critical damage
→ Critical Roll
→ Critical Multiplier
→ Physical Armor mitigation
→ mob damage
```

Mitigación física:

```text
floor(pre_damage * 1000 / (armor + 1000))
```

Mínimo:

```text
1
```

Training Goblin:

```text
base_armor_rating = 100
```

El Critical Roll ocurre sólo en Game Server.

---

# 6. F22-H — ATTACK SPEED / MOVEMENT SPEED ✅

Breakdown:

```text
H1-A Derived Attack/Movement Speed contract ✅
H1-B Server consumption ✅
H1-C Client movement prediction sync ✅
H2-A Class Attack Speed balance ✅
H2-B AGI → Attack Speed formula ✅
```

Movement Speed:

```text
4.0
```

Attack Speed:

```text
Warrior:
1 + 0.35 * AGI / (AGI + 300)

Mage:
1 + 0.25 * AGI / (AGI + 350)

Archer:
1 + 0.60 * AGI / (AGI + 250)
```

Basic Attack cooldown efectivo:

```text
base cooldown / attack_speed_multiplier
```

Client usa Movement Speed autoritativo para prediction; Game Server sigue siendo autoridad.

---

# 7. F22-I — EQUIPMENT + ENHANCEMENT FOUNDATION ✅

Breakdown cerrado:

```text
I1-A Equipment Item Usage Contract ✅
I1-B-A Enhancement Profile Contract ✅
I1-B-B Enhancement Instance State ✅
I1-B-C Enhancement Scaling Curves ✅

I1-C-A Equipment Stat Modifier Vocabulary ✅
I1-C-B Equipment Modifier Sources ✅
I1-C-C Aggregation ✅
I1-C-D Resolved Equipment Contributions ✅

I2-A Effective Primary Resolution ✅
I2-B-A Derived Formula Input ✅
I2-B-B Equipment → Resolved Derived ✅
I2-C-A Equipment-Aware Derived Bootstrap ✅
I2-C-B Live Equipment → Session Stats ✅
I2-C-C Preserve Equipment on Primary/Progression Rebuilds ✅

I3-A Weapon Damage → Basic Attack ✅
I3-B-A Character Physical Defense Profile ✅
I3-C-A Enhanced Equipment Usage Eligibility ✅
I3-C-B Live Equipment Eligibility Gate ✅
I3-C-C-A Equipment Snapshot Usage Eligibility Contract ✅
I3-C-C-B Persisted Equipment Load Gate ✅

I4-A Enhancement State Transition Contract ✅
I4-B-A Durable Enhancement Persistence Contract ✅
I4-B-B Internal Enhancement Persistence Endpoint ✅
I4-C-A Backend Enhancement Repository Transport ✅
I4-C-B Server Enhancement Orchestration ✅
I4-C-C-A Server Enhancement Request Protocol ✅
I4-C-C-B Connect Enhancement Request to Coordinator ✅
I4-D-A Client Enhancement Request Transport ✅
I4-D-B First Enhancement End-to-End Roundtrip ✅
I4-D-C Remove Temporary E2E Trigger ✅
```

---

# 8. PRIMARY / EFFECTIVE / DERIVED — CONTRATO CANÓNICO

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

Permanent Primary:

```text
Class Base
+
Allocated
+
futuros Permanent Bonuses
```

Regla crítica:

> Equipment Usage Requirements se evalúan contra Permanent Primary, nunca contra Effective Primary.

Por lo tanto:

```text
Equipment bonus NO habilita su propio requisito.
Equipment bonus NO habilita el requisito de otro Equipment.
```

---

# 9. EQUIPMENT MODIFIERS / BASIC ATTACK

Equipment puede aportar:

```text
strength
agility
vitality
energy
weapon_damage
armor_rating
```

Pipeline weapon:

```text
Equipment Snapshot
→ main_hand
→ weapon_damage
→ BasicAttackProfile.base_damage
→ + Physical Power
→ Crit
→ Armor
→ daño final
```

Bronze Sword foundation:

```text
base weapon_damage = 1000
```

---

# 10. ENHANCEMENT — ESTADO DURABLE

Estado canónico:

```gdscript
{
	"item_id": "bronze_sword",
	"state": {
		"enhancement_level": 4
	}
}
```

Legacy:

```text
state missing / null / [] / {}
→ +0
```

Array no vacío es inválido.

`state` puede contener otros campos durables futuros.

---

# 11. ENHANCEMENT — CURVAS ACTUALES

Máximo foundation:

```text
+13
```

Weapon cumulative percentage:

```text
+0   0%
+1  20%
+2  40%
+3  60%
+4  80%
+5 100%
+6 125%
+7 150%
+8 180%
+9 220%
+10 270%
+11 330%
+12 400%
+13 500%
```

Ejemplo Bronze Sword base 1000:

```text
+0  = 1000
+7  = 1150
+13 = 1500
```

Armor flat bonus:

```text
+0   0
+1  +1
+2  +2
+3  +3
+4  +4
+5  +5
+6  +6
+7  +7
+8  +9
+9 +11
+10 +14
+11 +17
+12 +21
+13 +26
```

Leather Helmet base 20:

```text
+0  = 20
+7  = 27
+13 = 46
```

---

# 12. ENHANCEMENT — REQUIREMENTS

Enhancement puede elevar requirements.

Bronze Sword:

```text
Base STR Requirement = 15
+13 extra STR        = 15
Final +13            = 30
```

Eligibility usa Permanent Primary.

```text
Permanent STR 27 → Sword +13 rechazada
Permanent STR 30 → permitida
```

---

# 13. ENHANCEMENT — TRANSITION / PERSISTENCE

Foundation actual:

```text
+N → +(N+1)
```

Transition Rules:

```text
valida current item
valida next level
deep-copy
preserva state adicional
canonicaliza legacy +0
```

Todavía NO decide:

```text
costos
joyas
RNG
failure
downgrade
materiales
UI
```

Backend endpoint:

```text
PATCH
/api/internal/accounts/{accountId}/characters/{characterId}/equipment/items/{uid}/enhancement
```

Payload foundation:

```json
{
  "expected_container": "inventory",
  "expected_current_level": 7,
  "next_level": 8
}
```

Backend usa:

```text
transaction
lockForUpdate
stale guard
persist exact transition
```

Laravel NO decide gameplay de Enhancement.

---

# 14. ENHANCEMENT — E2E PROBADO

Pipeline:

```text
Client
→ equipment_enhancement_request(uid)
→ GameServer
→ EquipmentCoordinator
→ Transition Rules
→ Usage Eligibility si está equipado
→ Repository
→ Laravel/MySQL
→ reload Inventory + Equipment
→ Client snapshots
```

Client sólo envía:

```text
uid
```

Probado durablemente:

```text
+1 → +2
+2 → +3
+3 → +4
```

El siguiente request siempre parte del nuevo nivel recibido por snapshot.

---

# 15. JSON ITEM STATE NORMALIZATION

Problema detectado:

```text
enhancement_level JSON podía llegar a Godot como float
```

Se agregó:

```text
BackendItemStateTransportNormalizer
```

Semántica:

```text
1.0 → 1
7.0 → 7

1.5 queda float y el dominio rechaza
"1" queda String y el dominio rechaza
```

No se relajó el dominio.

---

# 16. ENHANCEMENT — DECISIÓN FUTURA DE JOYAS

DECIDIDO, PERO NO IMPLEMENTADO.

Mecánica inspirada en MU.

Requirement:

```text
Equipment debe estar desequipado
y dentro de Inventory
```

Interacción futura:

```text
arrastrar Joya
→ soltar sobre Equipment target
→ enviar intención
```

Payload conceptual futuro:

```text
jewel_uid
target_item_uid
```

Client NO envía:

```text
current level
next level
probability
success/failure
container autoritativo
```

Tiers:

```text
+0 → +6
Joya A
(se usa sobre +0..+5)

+6 → +9
Joya B distinta
(se usa sobre +6..+8)

+9 → +13
DEFERRED
```

Failure:

```text
si falla:
baja 1 nivel
```

Ejemplo:

```text
+5 → fail → +4
```

Probabilidades exactas:

```text
DEFERRED
```

Autoridad del Game Server:

```text
ownership target
target en inventory
target desequipado
target es equipment
ownership jewel
jewel en inventory
jewel compatible con tier
current level
probability
RNG
success/failure
result level
```

RNG:

```text
Game Server ✅
Client ❌
Backend ❌
```

Backend futuro debe persistir atómicamente:

```text
consumir Joya
+
persistir resultado de Enhancement
```

---

# 17. F22-J — SKILL SCALING + REQUIREMENTS + RESET-SAFE USAGE ✅

Implementado:

```text
Skill Scaling Profile ✅
Authoritative Scaling Resolver ✅
Permanent Primary Requirements para learning ✅
Reset-safe Skill Usage ✅
Heal migrado al Scaling Resolver ✅
```

Fire Ball y Poison siguen sin efecto real.

Eso es intencional.

---

# 18. SKILL SCALING

Power Sources:

```text
none
physical_power
magic_power
healing_power
```

Perfil:

```text
flat_effect_value
power_source
power_coefficient
```

Fórmula:

```text
Effect
=
Flat Effect
+
Power Source * Coefficient
```

Resolver autoritativo:

```text
ServerSkillScalingResolver
```

Client no calcula Skill Scaling autoritativo.

---

# 19. HEAL

Balance actual:

```text
Flat = 0
Power Source = Healing Power
Coefficient = 1.0
```

Entonces:

```text
Heal = 0 + Healing Power * 1.0
```

Prueba real:

```text
Atilio
Healing Power = 10
Requested Heal = 10
```

Con HP completo:

```text
Requested Heal = 10
Restored Heal = 0
```

Correcto:

```text
Requested = efecto calculado
Restored = HP realmente restaurado tras clamp
```

---

# 20. SKILL LEARNING REQUIREMENTS

Learning ya tenía:

```text
allowed classes
minimum level
trainer
scroll ownership
```

F22-J agregó:

```text
Permanent Primary Stat Requirements
```

Equipment bonuses NO ayudan a aprender Skills.

Balance foundation actual:

## Fire Ball

```text
Class: Mage
Minimum Level: 10
Permanent Energy: 50
```

## Poison

```text
Class: Archer
Minimum Level: 10
Permanent Agility: 45
```

## Heal

```text
Class: Warrior / Mage / Archer
Minimum Level: 5
Permanent Energy: 20
```

Estos valores pueden revisarse en F22-K.

---

# 21. RESET-SAFE SKILL USAGE

Regla:

```text
LEARNING REQUIREMENTS
!=
CAST REQUIREMENTS
```

Al aprender se valida:

```text
class
level
Permanent Primary Stats
trainer
scroll
```

Una vez aprendida:

```text
ownership durable permanece
```

Durante cast NO se revalida:

```text
learning minimum level
learning primary stat requirements
reset_count
```

Esto permite que futuros Resets bajen Level/allocations sin borrar ni inutilizar automáticamente una Skill aprendida.

El cast sí sigue validando:

```text
ownership
character alive
target
mana
cooldown
effect-specific rules
```

Prueba real:

```text
Atilio:
Heal aprendido
Permanent ENE = 10

Nuevo requirement de aprendizaje:
ENE >= 20

Cast:
Accepted = true
```

Eso confirma reset-safe usage.

No significa que un personaje nuevo con ENE 10 pueda aprender Heal.

---

# 22. FIRE BALL / POISON — ESTADO

Existen en catálogos, pero SkillCastCoordinator responde:

```text
skill_not_implemented
```

Intencional.

Fire Ball requiere un bloque propio para:

```text
Magic Power consumer real
skill damage profile
range
damage application
mitigation/resistance
combat result payload
```

Poison requiere:

```text
status effect / DoT runtime
ticks
duration
stacking/refresh
replication
```

No mezclar esos scopes dentro de F22-J.

---

# 23. ARQUITECTURA AUTORITATIVA VIGENTE

```text
Client
= intención + representación + prediction limitada

Game Server
= autoridad runtime/gameplay

Backend Laravel
= API durable + transacciones

MySQL
= verdad durable
```

Nunca mover al Client:

```text
damage authoritative
skill scaling authoritative
equipment eligibility
enhancement resolution
enhancement RNG futuro
critical RNG
armor mitigation
learning requirements authoritative
```

---

# 24. SIGUIENTE FASE

```text
F22-K — Integrated Balance Audit
```

Objetivo:

```text
auditar F22 como sistema integrado
```

Áreas:

```text
Class Primary Stats
Derived Vitals
Physical / Magic / Healing Power
Crit
Attack Speed
Movement Speed
Equipment Primary modifiers
Weapon Damage
Armor Rating
Equipment requirements
Enhancement scaling
Skill scaling
Skill learning requirements
reset-safe usability
```

F22-K NO debe convertirse automáticamente en:

```text
Fire Ball implementation
Poison implementation
Jewel Enhancement system
Reset implementation
```

Esas features deben abrirse como bloques propios.

---

# 25. CRITERIO DE ENTRADA A F22-K

```text
F22-J remoto verificado ✅
PROJECT_MEMORY_5 creado ✅
PROJECT_MEMORY_5 push remoto ⏳ pendiente al escribir este archivo
repos limpios → verificar
```

No avanzar permanentemente a F22-K hasta que este documento esté commiteado, pusheado y remoto verificado.

---

# 26. DECISIONES QUE NO DEBEN PERDERSE

```text
Permanent Primary ≠ Effective Primary.

Equipment Requirements usan Permanent Primary.

Skill Learning Requirements usan Permanent Primary.

Skill Learning Requirements NO se revalidan al castear.

Derived consume Effective Primary.

Equipment se conserva en rebuilds de Primary/Progression.

Enhancement Level es durable por instancia.

Client nunca decide Enhancement Level ni RNG.

Future Enhancement:
Joya A +0→+6
Joya B +6→+9
+9→+13 deferred
drag jewel sobre equipment en inventory
target desequipado
failure baja 1 nivel
RNG server-side
jewel consumption + transition atómico.

Heal:
0 + Healing Power * 1.0.

Fire Ball / Poison siguen sin efecto real.
```

---

# 27. RESUMEN PARA RETOMAR

```text
F22-G ✅ Armor / Crit
F22-H ✅ Attack Speed / Movement
F22-I ✅ Equipment + Enhancement Foundation
F22-J ✅ Skill Scaling + Requirements + reset-safe usage

Client HEAD:
4ff9c79b1fa3376bb155d318e18856da3807ccf9

Game Server HEAD:
cb84c83dfac5220b651159f09bab1af1a7bec563

Backend HEAD:
ce3e0b02dbb1772204e12d1c2bb29d777b28b750

NEXT:
F22-K Integrated Balance Audit
```
