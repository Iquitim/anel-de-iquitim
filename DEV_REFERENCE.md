# O ANEL DE IQUITIM - Referência Rápida de Desenvolvimento

## 🎯 VALORES CRÍTICOS (NÃO ALTERAR)

### Física do Player
```gdscript
const SPEED_HUMAN: float = 90.0      # Lento, vulnerável
const SPEED_RING: float = 130.0      # Ágil, combate
const SPEED_IQUITIM: float = 220.0   # Descontrolado
const ACCELERATION: float = 800.0    # Inércia pesada
const FRICTION: float = 1000.0       # Parada não-imediata
```

### Dash
```gdscript
const DASH_DISTANCE: float = 60.0    # ~2 tiles
const DASH_COOLDOWN: float = 1.2     # segundos
const DASH_IFRAMES: float = 0.2      # invencibilidade
```

### Possessão
```gdscript
const RING_ACTIVATION_COST: float = 10.0  # % de vida que vira possessão
const IQUITIM_DURATION: float = 7.0       # segundos
const IQUITIM_COOLDOWN: float = 15.0      # segundos
const HEALTH_REGEN_DELAY: float = 3.0     # segundos parado
```

## 🔴 REGRAS IMUTÁVEIS

### Game Over Instantâneo
```gdscript
if possession >= health and transformation_on_cooldown:
    GameManager.trigger_game_over("POSSESSION_OVERFLOW")
```

### Penalidade de Ativação
```gdscript
func activate_ring() -> void:
    is_ring_active = true
    add_possession(10.0)  # SEMPRE 10%
    health_regen_timer.stop()
    emit_signal("noise_generated", global_position, 200.0)
```

### Alívio de Desativação
```gdscript
func deactivate_ring() -> void:
    is_ring_active = false
    reduce_possession(10.0) # Recua 10%
    health_regen_timer.start(2.0)
```

### Regeneração (Apenas Humano)
```gdscript
func _on_regen_timer_timeout() -> void:
    if not is_ring_active and not is_moving:
        health += REGEN_RATE * delta
```

## 📁 ESTRUTURA DE ARQUIVOS ATUAL

```
d:\anel-de-iquitim\
├── GDD.md                          # Documento mestre
├── DEV_REFERENCE.md                # Este arquivo
├── README.md                       # Apresentação do projeto
├── project.godot                   # ✅ Input "toggle_ring" configurado
│
├── _core/
│   ├── signal_bus.gd               # ✅ Implementado
│   ├── game_manager.gd             # ✅ Implementado
│   ├── save_system.gd              # ⏳ Pendente
│   └── audio_manager.gd            # ⏳ Pendente
│
├── entities/
│   └── player/
│       ├── player.tscn             # ✅ Top-down (CircleShape2D)
│       └── player_controller.gd    # ✅ Toggle implementado
│
├── systems/
│   ├── possession_component.gd     # ✅ Implementado
│   ├── health_component.gd         # ⏳ Pendente
│   ├── hitbox_component.gd         # ⏳ Pendente
│   └── interaction_component.gd    # ⏳ Pendente
│
├── world/
│   └── test_world.tscn             # ✅ Top-down com background
│
└── assets/
    └── sprites/
        ├── player_simple.png       # ✅ Placeholder (muda de cor)
        └── ground_simple.png       # ✅ Placeholder
```

## 🎨 PALETA DE CORES

```gdscript
# Cores do Projeto
const COLOR_IQUITIM_GREEN := Color("#2BFF81")  # RGB(43, 255, 129)
const COLOR_POSSESSION_PURPLE := Color("#B400FF")  # RGB(180, 0, 255)
const COLOR_DEEP_BLACK := Color("#0B0B0B")  # RGB(11, 11, 11)
```

## 🔧 SIGNALS GLOBAIS (SignalBus)

```gdscript
# Já implementados
signal noise_generated(position: Vector2, radius: float)
signal possession_updated(current: float, max: float)
signal game_over(reason: String)
signal ring_toggled(is_active: bool)

# A implementar
signal transformation_started()
signal transformation_ended()
signal player_died()
signal boss_defeated(boss_id: String)
signal friend_rescued(friend_id: String)
signal item_collected(item_id: String)
```

## 🎮 INPUTS (project.godot)

```ini
[input]

# Movimento
move_left={...}
move_right={...}
move_up={...}
move_down={...}

# Ações
toggle_ring={...}      # TAB ou L1
dash={...}             # Shift ou Circle
attack={...}           # Mouse Left ou Square
use_item_1={...}       # 1 ou D-Pad Left
use_item_2={...}       # 2 ou D-Pad Right

# Sistema
pause={...}            # ESC ou Start
interact={...}         # E ou X
```

## 📊 ESTADOS DO PLAYER (FSM)

```gdscript
enum PlayerState {
    IDLE,
    MOVE,
    DASH,
    ATTACK_LIGHT,
    CAST_MAGIC,
    TRANSFORMATION_SEQUENCE,
    DEAD
}
```

## 🎯 PRÓXIMAS TAREFAS PRIORITÁRIAS

### ✅ 1. Sistema de Toggle do Anel (CONCLUÍDO)
- [x] Input "toggle_ring" (TAB)
- [x] Feedback visual (modulate verde)
- [x] Ajuste de velocidade (90→130 px/s)
- [x] Penalidade de possessão (+10%)
- [x] Emissão de ruído (quebra stealth)

### 2. Barra de Possessão UI ⭐ (PRÓXIMO PASSO)
- [ ] Criar HUD overlay
- [ ] Recipiente rachado (conforme GDD)
- [ ] Barra de Vida (roxa) esquerda→direita
- [ ] Barra de Possessão (verde) esquerda→direita (overlay)
- [ ] Indicador de estado do anel
- [ ] Feedback de tela (vinheta, glitch em 80%+)

### 3. Sistema de Combate Básico
- [ ] Implementar ataque humano (fraco)
- [ ] Implementar magias do anel
- [ ] Sistema de hitbox/hurtbox
- [ ] Feedback visual de dano

### 4. Primeiro Inimigo
- [ ] Rastejante Cego (Setor 1)
- [ ] IA básica (patrulha + perseguição)
- [ ] Drop de orbes
- [ ] Morte e respawn

### 5. Sistema de Regeneração
- [ ] Vida regenera quando anel desativado
- [ ] Delay de 3s parado
- [ ] Para quando anel ativa
- [ ] Feedback visual de regeneração

## 🐛 DEBUGGING

### Comandos Úteis
```gdscript
# Ativar debug de física
get_tree().debug_collisions_hint = true

# Print de estado
print("State: ", current_state)
print("Possession: ", possession, "/", health)
print("Ring Active: ", is_ring_active)

# Teleporte rápido (debug)
global_position = Vector2(576, 468)
```

### Flags de Teste
```gdscript
# No game_manager.gd
const DEBUG_MODE := true
const GOD_MODE := false
const INFINITE_ITEMS := false
```

## 📚 RECURSOS EXTERNOS

### Documentação
- [Godot 4.5 Docs](https://docs.godotengine.org/en/stable/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

### Assets Placeholder
- [Kenney Assets](https://kenney.nl/assets)
- [OpenGameArt](https://opengameart.org/)
- [itch.io CC0](https://itch.io/game-assets/tag-creative-commons-zero)

## 🔄 WORKFLOW

### Antes de Começar uma Feature
1. Ler a seção relevante no `GDD.md`
2. Verificar valores críticos neste arquivo
3. Criar branch no Git (se aplicável)
4. Implementar com tipagem estática
5. Testar no test_world
6. Commit com mensagem descritiva

### Padrão de Commit
```
feat: Adiciona sistema de dash com I-frames
fix: Corrige game over durante cooldown
refactor: Melhora FSM do player
docs: Atualiza GDD com novos valores
```

---

**Última Atualização:** 2025-11-21  
**Versão do Projeto:** 0.1.0-alpha  
**Engine:** Godot 4.5.1
