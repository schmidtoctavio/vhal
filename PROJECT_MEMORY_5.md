# VHAL — PROJECT MEMORY 5 / F22-G → F22 COMPLETE

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

> Este volumen prevalece para F22-G, F22-H, F22-I, F22-J, F22-K y decisiones posteriores cuando contradiga estados históricos anteriores.

Los repositorios reales en `dev` siguen prevaleciendo sobre memoria si el código cambió después de esta actualización.

`PROJECT_MEMORY_4.md` queda como cierre histórico de F22-F.

---

# 1. WORKFLOW OBLIGATORIO ACTUAL

Ciclo de trabajo canónico:

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
.gd   → puede entregarse completo o con cambios exactos.
.md canónico → siempre archivo completo, nunca patch.
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
→ recién después se considera cerrado el bloque
```

Los contracts permanentes de regresión sí pueden permanecer si representan
reglas de dominio/gameplay y no nombres temporales del roadmap.

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

# 3. HEADS REMOTOS VERIFICADOS — 06/09/2026

## Client

HEAD documental actual:

```text
80d071be1eb06c9c0909011edf8547e7010f777c
docs: close F22 equipment and skill foundations
```

Último HEAD runtime anterior:

```text
4ff9c79b1fa3376bb155d318e18856da3807ccf9
chore: remove temporary enhancement debug trigger
```

Commits relevantes de Enhancement Client:

```text
5a3e14eb9bd729b06b33c4c50031d8aeb56ee0d8
feat: complete equipment enhancement client roundtrip

b147419974397dfc99bd66ddbaed812cac5b284e
feat: add equipment enhancement client transport
```

## Game Server

HEAD actual:

```text
c6114f22c52630f190952c7f1c9360df2f6838b3
feat: add integrated gameplay balance contract
```

Anterior:

```text
cb84c83dfac5220b651159f09bab1af1a7bec563
feat: add skill scaling and usage requirements
```

Anterior relevante:

```text
1a5e117511f412fc110d53d7e10a472c6407e4f9
fix: normalize persisted item state from backend
```

## Backend

HEAD actual relevante:

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

Estado canónico:

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
F22-K ✅

F22 ✅ COMPLETE
```

El roadmap canónico existente no tenía un F23 ya definido.

Siguiente decisión recomendada:

```text
F23 — Skill Combat Effects
```

Motivo:

```text
Magic Power consumer ofensivo real quedó explícitamente deferred.
Fire Ball existe pero todavía responde skill_not_implemented.
Poison existe pero todavía responde skill_not_implemented.
Skill Scaling foundation ya está lista para consumidores reales.
```

Orden recomendado dentro de F23:

```text
F23-A Fire Ball / Magic Damage consumer
F23-B Skill target/range/damage result integration
F23-C Poison / Status Effect + DoT foundation
```

Esto es la continuación recomendada, no una fase histórica preexistente.

El sistema futuro de Joyas de Enhancement queda fuera de F23 para no mezclar scopes.

---

# 5. F22-G — ARMOR / CRIT ✅

F22-G quedó cerrado.

Integraciones principales:

```text
Critical Strike Chance
Critical Damage Multiplier
Physical Armor Mitigation
Character Physical Defense Profile foundation
```

Critical foundation actual:

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

Mitigación física canónica:

```text
post_damage
=
floor(
	pre_damage * 1000
	/
	(armor + 1000)
)
```

Mínimo de daño válido:

```text
1
```

Training Goblin actual:

```text
base_armor_rating = 100
```

El Game Server realiza el Critical Roll.

El Client nunca decide:

```text
critical roll
critical success
critical multiplier aplicado
armor mitigation
damage final
```

---

# 6. F22-H — ATTACK SPEED / MOVEMENT SPEED ✅

F22-H quedó cerrado.

Breakdown:

```text
H1-A Derived Attack/Movement Speed contract ✅
H1-B Server consumption ✅
H1-C Client movement prediction sync ✅
H2-A Class Attack Speed balance ✅
H2-B AGI → Attack Speed formula ✅
```

Movement Speed actual:

```text
4.0
```

Attack Speed usa saturación por clase.

## Warrior

```text
1 + 0.35 * AGI / (AGI + 300)
```

## Mage

```text
1 + 0.25 * AGI / (AGI + 350)
```

## Archer

```text
1 + 0.60 * AGI / (AGI + 250)
```

El Basic Attack cooldown efectivo se resuelve desde:

```text
base cooldown
÷
attack_speed_multiplier
```

El Movement Server usa Derived Movement Speed por sesión.

El Client usa Movement Speed autoritativo para prediction, pero el Game Server sigue siendo autoridad.

---

# 7. F22-I — EQUIPMENT + ENHANCEMENT FOUNDATION ✅

F22-I queda cerrado.

Breakdown completo:

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

Permanent Primary:

```text
Class Base
+
Allocated
+
futuros Permanent Bonuses
```

Effective Primary:

```text
Permanent Primary
+
Equipment
```

Regla crítica:

> Equipment Usage Requirements SIEMPRE se evalúan contra Permanent Primary, nunca contra Effective Primary.

Por lo tanto:

```text
Equipment bonus NO puede habilitar su propio requisito.
Equipment bonus NO puede habilitar el requisito de otro Equipment.
```

---

# 9. EQUIPMENT MODIFIERS

Equipment puede contribuir a:

```text
Primary:
strength
agility
vitality
energy

Derived / combat:
weapon_damage
armor_rating
otros vocabularios futuros
```

La agregación es autoritativa en Game Server.

El Client representa snapshots; no calcula el resultado autoritativo final.

---

# 10. WEAPON DAMAGE → BASIC ATTACK

Weapon Damage se resuelve desde Equipment.

Pipeline:

```text
Equipment Snapshot
→ main_hand
→ resolved weapon_damage
→ BasicAttackProfile.base_damage
→ + Physical Power
→ Crit
→ Armor
→ daño final
```

Ejemplo foundation:

```text
Bronze Sword base weapon_damage = 1000
```

Basic Attack:

```text
pre_critical_damage
=
weapon/base attack damage
+
derived physical_power
```

---

# 11. ENHANCEMENT — ESTADO DURABLE

Estado canónico de instancia:

```gdscript
{
	"item_id": "bronze_sword",

	"state": {
		"enhancement_level": 4
	}
}
```

`enhancement_level` es parte del estado durable de la instancia.

Semántica legacy:

```text
state missing
state = null
state = []
state = {}
→ +0
```

Array no vacío inválido.

`state` puede contener otros campos durables futuros.

---

# 12. ENHANCEMENT — CURVAS ACTUALES

Maximum foundation actual:

```text
+13
```

IMPORTANTE:

> Las curvas de Enhancement almacenan BONUS FLAT ACUMULADO.
> NO representan porcentajes.

## Weapon Damage cumulative flat bonus

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

Semántica:

```text
resolved final
=
base intrinsic value
+
flat cumulative enhancement bonus
```

Ejemplo Bronze Sword base 1000:

```text
+0:
1000 + 0
= 1000

+4:
1000 + 80
= 1080

+7:
1000 + 150
= 1150

+13:
1000 + 500
= 1500
```

NO es:

```text
1000 + 150%
```

## Armor Rating cumulative flat bonus

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

Ejemplo Leather Helmet base 20:

```text
+0  = 20
+7  = 27
+13 = 46
```

---

# 13. ENHANCEMENT — REQUIREMENTS

Enhancement puede elevar requirements del Equipment.

Ejemplo Bronze Sword:

```text
Base STR Requirement = 15
+13 extra STR        = 15
Final +13            = 30
```

Usage Eligibility evalúa contra:

```text
Permanent Primary
```

Ejemplo:

```text
Permanent STR 27
Bronze Sword +13 requires STR 30
→ rechazo

Permanent STR 30
→ permitido
```

---

# 14. ENHANCEMENT — TRANSITION CONTRACT

Transition Rules foundation actual:

```text
+N
→
+(N+1)
```

La transición:

```text
valida current item
valida next level
deep-copy del item
preserva state durable adicional
canonicaliza legacy +0
```

No decide todavía:

```text
costos
joyas
RNG
success/failure
downgrade
materiales
UI
```

---

# 15. ENHANCEMENT — PERSISTENCIA

Backend Laravel es autoridad durable junto a MySQL.

Endpoint interno:

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

Backend:

```text
transaction
+
lockForUpdate
+
stale guard
+
persist exact transition
```

Laravel NO decide gameplay de Enhancement.

No decide:

```text
max level gameplay
RNG
cost
material requerido
eligibility
```

Eso pertenece al Game Server.

---

# 16. ENHANCEMENT — GAME SERVER ORCHESTRATION

Pipeline probado:

```text
Client
→ equipment_enhancement_request(uid)
→ GameServer parser
→ EquipmentCoordinator
→ resolve authoritative source
→ Transition Rules
→ Usage Eligibility si está equipado
→ Backend Repository
→ Laravel
→ MySQL
→ reload Inventory
→ reload Equipment
→ Client snapshots
```

El Client sólo envía:

```text
uid
```

No envía:

```text
container
current level
next level
requirements
success
failure
```

El Game Server resuelve todo eso.

---

# 17. ENHANCEMENT — E2E PROBADO

Roundtrip real probado:

```text
+1 → +2
+2 → +3
+3 → +4
```

Comprobado:

```text
Game Server resuelve transición
Laravel persiste
Game Server recarga snapshots
Client reconstruye ItemInstance
siguiente request parte del nuevo level durable
```

Bronze Sword durable alcanzó:

```text
+4
```

en las pruebas de foundation.

---

# 18. JSON ITEM STATE NORMALIZATION

Se detectó un problema real de frontera JSON:

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

1.5 permanece float y dominio rechaza
"1" permanece String y dominio rechaza
```

No se relajó el dominio.

---

# 19. ENHANCEMENT — DECISIÓN FUTURA DE JOYAS

IMPORTANTE: decidido pero NO implementado todavía.

Mecánica inspirada en MU.

## Requirement de container

Para mejorar un Equipment:

```text
debe estar desequipado
debe estar dentro de Inventory
```

No debe poder mejorarse mientras está equipado.

## Interacción Client

Mecánica prevista:

```text
Inventory
→ arrastrar una Joya
→ soltarla encima del Equipment target
→ enviar intención
```

La intención conceptual futura debe contener algo equivalente a:

```text
jewel_uid
target_item_uid
```

El Client NO debe enviar:

```text
current enhancement level
next enhancement level
probability
success/failure
container authoritative
```

## Tiers de Joyas

Decisión actual:

```text
+0 → +6
Joya A

+6 → +9
Joya B distinta

+9 → +13
DEFERRED / definir más adelante
```

Interpretación exacta:

```text
Joya A se usa sobre +0..+5 para intentar llegar hasta +6.
Joya B se usa sobre +6..+8 para intentar llegar hasta +9.
```

## Failure

Habrá probabilidad de fallo.

Decisión actual:

```text
si falla:
enhancement_level baja 1
```

Ejemplo:

```text
+5
→ intento
→ falla
→ +4
```

Las probabilidades exactas todavía NO están definidas.

## Autoridad

El Game Server deberá validar:

```text
target pertenece al character
target está en Inventory
target está desequipado
target es Equipment

jewel pertenece al character
jewel está en Inventory
jewel corresponde al tier

current enhancement level
probability correspondiente
RNG
success/failure
next resulting level
```

RNG:

```text
Game Server ✅
Client ❌
Backend ❌
```

Backend deberá persistir atómicamente:

```text
consumir Joya
+
persistir resultado del Enhancement
```

Nunca debe existir:

```text
Equipment mejorado pero Joya no consumida
o
Joya consumida pero Equipment sin transición
```

---

# 20. F22-J — SKILL SCALING + REQUIREMENTS + RESET-SAFE USABILITY ✅

F22-J quedó cerrado.

Implementaciones:

```text
Skill Scaling Profile ✅
Authoritative Scaling Resolver ✅
Permanent Primary Stat Requirements para Learning ✅
Reset-safe Skill Usage ✅
Heal migrado al Scaling Resolver ✅
```

Fire Ball y Poison siguen sin efecto real.

Eso es intencional.

---

# 21. SKILL SCALING PROFILE

Power Sources soportados:

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

Fórmula canónica:

```text
Effect
=
Flat Effect
+
Power Source * Coefficient
```

Resolución autoritativa:

```text
ServerSkillScalingResolver
```

El Client no calcula Skill Scaling autoritativo.

---

# 22. HEAL — SCALING ACTUAL

Heal actual:

```text
Flat = 0
Power Source = Healing Power
Coefficient = 1.0
```

Fórmula:

```text
Heal
=
0
+
Healing Power * 1.0
```

Esto preserva exactamente el comportamiento anterior.

Prueba real:

```text
Atilio
Healing Power = 10
Requested Heal = 10
Accepted = true
```

Cuando estaba en HP completo:

```text
Requested Heal = 10
Restored Heal = 0
```

Correcto:

```text
Requested = efecto calculado
Restored = HP realmente restaurado después del clamp
```

En smoke test posterior de F22-K:

```text
MP = 22
Heal mana cost = 40
→ insufficient_mana
```

Eso fue un rechazo correcto por recursos, no un fallo del Scaling.

---

# 23. SKILL LEARNING REQUIREMENTS

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

Regla:

> Los requirements para APRENDER una Skill usan Permanent Primary Stats.

Equipment bonuses NO pueden ayudar a aprender una Skill.

Requirements actuales:

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

Estos números fueron incluidos en el Integrated Balance Contract.

---

# 24. RESET-SAFE SKILL USAGE

Diferencia canónica:

```text
LEARNING REQUIREMENTS
!=
CAST REQUIREMENTS
```

Al aprender:

```text
class
level
Permanent Primary Stats
trainer
scroll
```

Una vez durablemente aprendida:

```text
ownership permanece
```

Durante cast NO se vuelve a exigir:

```text
learning minimum level
learning primary stat requirements
reset_count
```

Esto permite que futuros Resets bajen Level / allocations sin borrar ni inutilizar automáticamente una Skill ya aprendida.

El cast sigue validando:

```text
skill ownership
character alive
target
mana
cooldown
effect-specific rules
```

---

# 25. RESET-SAFE — PRUEBA REAL

Atilio tenía:

```text
Heal aprendido
Permanent Energy = 10
```

Nuevo requirement para aprender Heal:

```text
Permanent Energy >= 20
```

Aun así:

```text
Heal cast Accepted = true
```

Esto prueba:

```text
skill ownership durable
→ cast permitido

sin revalidar requisito de aprendizaje
```

No significa que un personaje nuevo con ENE 10 pueda aprender Heal.

---

# 26. FIRE BALL / POISON — ESTADO ACTUAL

Existen en:

```text
ServerSkillCatalog
ServerSkillLearningCatalog
```

Pero SkillCastCoordinator todavía responde:

```text
skill_not_implemented
```

Eso es intencional.

## Fire Ball necesita

```text
Magic Power consumer real
Skill Damage Profile
target/range
damage application
mitigation/resistance decision
combat result payload
```

## Poison necesita

```text
Status Effect / DoT runtime
tick authority
duration
stacking/refresh semantics
runtime/persistence decision
replication
```

No mezclar esas decisiones dentro de F22.

---

# 27. F22-K — INTEGRATED BALANCE CONTRACT ✅

F22-K quedó cerrado y remoto verificado.

El artifact permanente se llama:

```text
core/balance/server_integrated_balance_contract.gd
```

Class:

```text
ServerIntegratedBalanceContract
```

No se dejó el nombre temporal:

```text
ServerF22IntegratedBalanceAudit
```

porque `F22` pertenece al roadmap, no al dominio permanente.

El contract se ejecuta durante startup del Game Server desde:

```text
app/main.gd
```

Print positivo:

```text
ServerMain | Integrated Balance Contract validado.
```

Si falla:

```text
ServerMain | Integrated Balance Contract inválido: ...
```

y el server aborta startup.

---

# 28. INTEGRATED BALANCE — CLASS SNAPSHOTS

El contract permanente fija actualmente:

| Class / Level | Max HP | Max MP | Physical | Magic | Healing |
|---|---:|---:|---:|---:|---:|
| Warrior L1 | 200 | 60 | 60 | 10 | 10 |
| Mage L1 | 115 | 295 | 15 | 90 | 80 |
| Archer L1 | 130 | 130 | 60 | 15 | 15 |
| Warrior L100 | 992 | 159 | 258 | 10 | 10 |
| Mage L100 | 610 | 691 | 114 | 288 | 179 |
| Archer L100 | 724 | 328 | 258 | 15 | 15 |

También fija identidad relativa foundation:

```text
Max HP:
Warrior > Archer > Mage

Max MP:
Mage > Archer > Warrior

Magic Power:
Mage > Archer > Warrior

Healing Power:
Mage > Archer > Warrior

Attack Speed inicial:
Archer > Warrior > Mage
```

Además comprueba:

```text
Crit Chance foundation = 0
Crit Damage = 1.5
Movement Speed = 4.0
Attack Speed respeta fórmula por Class
```

---

# 29. INTEGRATED BALANCE — BASIC ATTACK / ARMOR

Warrior Level 1:

```text
Physical Power = 60
Training Goblin Armor = 100
```

Casos contract:

## Unarmed

```text
Base = 500
Pre-Mitigation = 560
Post-Mitigation = 509
```

## Bronze Sword +0

```text
Base = 1000
Pre-Mitigation = 1060
Post-Mitigation = 963
```

## Bronze Sword +7

```text
Base = 1150
Pre-Mitigation = 1210
Post-Mitigation = 1100
```

## Bronze Sword +13

```text
Base = 1500
Pre-Mitigation = 1560
Post-Mitigation = 1418
```

También comprueba que Attack Speed:

```text
effective cooldown < base cooldown
```

cuando multiplier > 1.

---

# 30. INTEGRATED BALANCE — ENHANCEMENT

El contract fija explícitamente que las curvas son:

```text
flat cumulative bonuses
```

y comprueba:

```text
Bronze Sword:
+0  = 1000
+7  = 1150
+13 = 1500

Leather Helmet:
+0  = 20
+7  = 27
+13 = 46
```

Además verifica monotonicidad:

```text
cada nivel de Enhancement
debe mejorar el intrinsic bonus
respecto al anterior
```

Requirement contract:

```text
Bronze Sword +13
→ +15 STR requirement adicional
```

Warrior Level 1 base:

```text
STR 25

Sword +0:
requiere 15
→ usable

Sword +13:
requiere 30
→ insufficient_strength
```

---

# 31. INTEGRATED BALANCE — SKILLS

Heal:

```text
Mage L1 Healing Power 80
→ Heal 80

Warrior L1 Healing Power 10
→ Heal 10
```

Learning foundation:

```text
Fire Ball:
Mage
Level 10
ENE 50

Poison:
Archer
Level 10
AGI 45

Heal:
Warrior/Mage/Archer
Level 5
ENE 20
```

El Integrated Balance Contract también verifica que cada Skill sea
matemáticamente alcanzable por su Class permitida en su propio minimum_level
con los Stat Points disponibles.

Ejemplos:

```text
Fire Ball:
Mage L10
Base ENE 35
Need ENE 50
Déficit 15
Points disponibles 45
→ alcanzable

Poison:
Archer L10
Base AGI 30
Need AGI 45
Déficit 15
Points disponibles 45
→ alcanzable

Heal Warrior:
Warrior L5
Base ENE 10
Need ENE 20
Déficit 10
Points disponibles 20
→ alcanzable
```

También vuelve a comprobar Reset-Safe Usage.

---

# 32. F22-K — E2E RUNTIME REAL

Atilio durante cierre de F22-K:

```text
Level: 124
Permanent STR: 37
Permanent AGI: 15
Permanent VIT: 25
Permanent ENE: 10

Physical Power: 330
Magic Power: 10
Healing Power: 10
Attack Speed: 1.01666666666667
Movement Speed: 4.0

Bronze Sword durable: +4
```

Basic Attack real:

```text
Base Damage: 1080
Physical Power: 330
Pre-Crit: 1410
Crit Chance: 0.0
Critical: false
Pre-Mitigation: 1410
Armor: 100
Post-Mitigation: 1281
Damage: 1281
```

Esto prueba runtime:

```text
Enhancement +4
→ Weapon Damage 1080
→ + Physical Power 330
→ 1410
→ Crit false
→ Armor 100
→ 1281 final
```

Heal en ese mismo smoke:

```text
MP: 22
Mana Cost: 40
→ insufficient_mana
```

Ese rechazo fue correcto.

Heal Scaling ya había sido probado positivamente en F22-J.

---

# 33. ARQUITECTURA AUTORITATIVA VIGENTE

```text
Client
=
intención + representación + prediction limitada

Game Server
=
autoridad runtime/gameplay

Backend Laravel
=
API durable + transacciones

MySQL
=
verdad durable
```

Nunca mover al Client:

```text
damage authoritative
skill scaling authoritative
equipment eligibility
enhancement level resolution
enhancement RNG futuro
critical RNG
armor mitigation
learning requirements authoritative
```

---

# 34. F22 — CIERRE CANÓNICO

F22 queda oficialmente:

```text
COMPLETE ✅
```

Cubre:

```text
Primary Stats
Derived Stats
Vitals
Physical/Magic/Healing Power
Armor
Crit
Attack Speed
Movement Speed
Equipment modifiers
Effective Primary
Equipment-aware Derived
Weapon Damage
Physical Defense Profile
Equipment Usage Eligibility
Enhancement durable foundation
Enhancement persistence/network roundtrip
Skill Scaling
Skill Learning Requirements
Reset-safe Skill Usage
Integrated Balance Contract
```

No confundir cierre de F22 con implementación completa de todo el juego.

Permanecen futuros:

```text
Fire Ball real
Poison real
Magic Damage / Resistances
Status Effects / DoTs
Jewel Enhancement gameplay
Enhancement RNG
Reset gameplay real
más Equipment
más Skills
más contenido
```

---

# 35. SIGUIENTE ROADMAP RECOMENDADO

No existe un F23 histórico previo en los documentos canónicos.

La siguiente fase recomendada es:

```text
F23 — Skill Combat Effects
```

Motivo:

```text
F22 dejó Skill Scaling preparado.
Magic Power ya existe autoritativamente.
Fire Ball está aprendido/catalogado pero sin efecto real.
Poison está aprendido/catalogado pero sin efecto real.
```

Orden recomendado:

```text
F23-A — Fire Ball Damage Foundation
F23-B — Magic Damage / Target / Range Integration
F23-C — Poison Status Effect / DoT Foundation
```

Antes de implementar permanentemente F23:

```text
1. PROJECT_MEMORY_5 actualizado
2. commit
3. push
4. usuario dice "pusheado"
5. verificar remoto
6. recién entonces comenzar F23
```

Si se decide priorizar otro bloque, modificar primero este checkpoint canónico.

---

# 36. DECISIONES QUE NO DEBEN PERDERSE

```text
Permanent Primary ≠ Effective Primary.

Equipment Requirements usan Permanent Primary.

Skill Learning Requirements usan Permanent Primary.

Skill Learning Requirements NO se revalidan al castear.

Derived consume Effective Primary.

Equipment se conserva al rebuild de Primary/Progression.

Enhancement Level es estado durable por instancia.

Enhancement intrinsic curves son FLAT cumulative bonus, NO percentage.

Client nunca decide Enhancement Level ni RNG.

Future Enhancement:
Joya A +0→+6
Joya B +6→+9
+9→+13 deferred
drag jewel sobre equipment en Inventory
target debe estar desequipado
failure baja 1 nivel
RNG server-side
jewel consumption + enhancement transition debe ser atómico.

Heal usa:
0 + Healing Power * 1.0.

Fire Ball / Poison siguen sin efecto real.

Integrated Balance Contract es permanente:
core/balance/server_integrated_balance_contract.gd
```

---

# 37. RESUMEN CORTO PARA RETOMAR

```text
F22-G ✅ Armor / Crit
F22-H ✅ Attack Speed / Movement
F22-I ✅ Equipment + Enhancement Foundation
F22-J ✅ Skill Scaling + Requirements + reset-safe usage
F22-K ✅ Integrated Balance Contract

F22 ✅ COMPLETE

Client HEAD:
80d071be1eb06c9c0909011edf8547e7010f777c

Game Server HEAD:
c6114f22c52630f190952c7f1c9360df2f6838b3

Backend HEAD:
ce3e0b02dbb1772204e12d1c2bb29d777b28b750

NEXT RECOMMENDED:
F23 — Skill Combat Effects
```
