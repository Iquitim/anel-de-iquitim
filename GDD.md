# O ANEL DE IQUITIM
## Game Design Document - Versão 1.4

**Status:** Em Desenvolvimento  
**Engine:** Godot 4.5.1  
**Linguagem:** GDScript 2.0  
**Plataforma:** PC (Windows)  
**Estilo:** Pixel Art Sombrio (Top-down 2D)  
**Gênero:** Ação-Aventura / Horror Urbano / Souls-like 2D

---

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Narrativa](#narrativa)
3. [Mecânica Core](#mecânica-core)
4. [Física e Movimentação](#física-e-movimentação)
5. [Sistema de Possessão](#sistema-de-possessão)
6. [Progressão](#progressão)
7. [Mundo e Ambientação](#mundo-e-ambientação)
8. [Personagens](#personagens)
9. [Inimigos e Bosses](#inimigos-e-bosses)
10. [Interface (UI)](#interface-ui)
11. [Arquitetura Técnica](#arquitetura-técnica)
12. [Diretrizes para IA](#diretrizes-para-ia)

---

## 🎮 VISÃO GERAL

### Objetivo do Projeto
Desenvolver **O Anel de Iquitim**, um jogo completo de ação-aventura 2D com duração de 4-5 horas. Uma experiência polida que demonstra a viabilidade da Godot 4.3 com fluxos de trabalho assistidos por IA.

### Conceito Central
**Gerenciamento de Autocontrole** - O poder é um risco calculado:
- **Lutar (Anel Ativado):** Permite matar inimigos e usar magias, mas impede cura e pode causar Game Over súbito
- **Fugir (Anel Desativado):** Permite regenerar vida e usar stealth, mas deixa vulnerável

### Público-Alvo
Jovens adultos (16+) fãs de jogos indie que misturam dificuldade técnica com narrativas profundas. Inspirações: *Hyper Light Drifter*, *Blasphemous*, *Silent Hill*.

### Tom e Atmosfera
**Terror Melancólico e Urbano** - Sem jumpscares. Foco em opressão atmosférica: São Paulo cinzenta + horror cósmico roxo/verde.

### Game Loop
```
Exploração (Humano) 
    ↓
Encontro com Inimigo
    ↓
Decisão: ATIVAR ANEL?
    ↓
Combate & Risco (Possessão sobe)
    ↓
Execução e Saque (XP)
    ↓
Estabilização (Café, Cura, Fugir)
```

---

## 📖 NARRATIVA

### Sinopse
**2005, São Paulo.** O protagonista e quatro amigos estão em um bar. Ao voltarem de ônibus, cochilam e acordam em um cemitério misterioso. Todos desaparecem, exceto o protagonista.

### A Jornada

#### 1. O Cemitério
- Ponto de partida
- Grupo de garotas (As Três Irmãs) também está perdido
- Protagonista se afasta para vomitar (presságio da corrupção)
- Ao retornar: **todos desapareceram**

#### 2. A Cripta
- Pegadas levam a uma cripta antiga
- Porteiro grotesco guarda a entrada
- Deve usar stealth para passar

#### 3. O Pacto
- No subsolo, encontra uma carta: *"LIVRE-SE DO ANEL"*
- Ao lado: anel de aro escuro com pedra verde pulsante
- Coloca o anel → Luz verde toma seu braço
- Voz antiga ecoa: **Iquitim**

#### 4. A Revelação
- Iquitim: entidade aprisionada, ex-governante do submundo
- Traído e selado por quatro generais (as Bestas)
- Ruído do pacto atrai o porteiro
- Com o poder do anel, derrota o monstro

#### 5. A Missão
- Para salvar os amigos: descer pelas cavernas dimensionais
- Ajudar Iquitim a se vingar das **Quatro Bestas**
- **Dilema:** Cada vitória fortalece Iquitim e corrompe o protagonista

---

## ⚙️ MECÂNICA CORE

### Sistema de Toggle (Ativar/Desativar)

#### Estado 1: Anel Desativado (Humano)
- ✅ Regeneração de vida (3s parado)
- ✅ Stealth ativo
- ✅ Passos silenciosos
- ❌ Combate fraco (soco/chute)

#### Estado 2: Anel Ativado (Modo Combate)
- ✅ Magias e habilidades liberadas
- ✅ Combate efetivo
- ❌ **Penalidade:** 10% da vida vira possessão ao ativar
- ❌ Stealth desativado (anel emana luz/som)
- ❌ Sem regeneração natural

### A Forma Iquitim (Transformação)

**Gatilho:** Barra de Possessão > Barra de Vida

**Características:**
- Duração: 7 segundos
- Velocidade: 220 px/s (descontrolado)
- Poder massivo
- **DEVE ser desativada manualmente antes do fim**
- Cooldown: 15 segundos após uso

**⚠️ GAME OVER CRÍTICO:**
Se a Possessão ultrapassar a Vida enquanto a Forma estiver em **Cooldown** → **MORTE INSTANTÂNEA**

---

## 🏃 FÍSICA E MOVIMENTAÇÃO

### Parâmetros do Jogador (CharacterBody2D)

```gdscript
# Constantes de Movimento
const SPEED_HUMAN: float = 90.0      # Lento, vulnerável
const SPEED_RING: float = 130.0      # Ágil, combate
const SPEED_IQUITIM: float = 220.0   # Descontrolado
const ACCELERATION: float = 800.0    # Inércia pesada
const FRICTION: float = 1000.0       # Parada não-imediata
```

### Dash (Esquiva)
- **Distância:** ~60px (2 tiles de 32px)
- **Cooldown:** 1.2 segundos
- **I-Frames:** 0.2s de invencibilidade
- **Custo:** Nenhum (limitado apenas por cooldown)

### ⚠️ NÃO EXISTE STAMINA
O limitador é a **Barra de Possessão** e os **Cooldowns**.

---

## 👻 SISTEMA DE POSSESSÃO

### Mecânica de Risco

```gdscript
func _check_possession_limit() -> void:
    # Se a possessão cobriu toda a vida
    if current_possession >= current_health:
        
        # SE estiver em Cooldown = Morte Instantânea
        if not iquitim_cooldown_timer.is_stopped():
            SignalBus.emit_signal("game_over", "SOBRECARGA_COOLDOWN")
            return

        # SENÃO = Transformação Forçada
        _trigger_transformation()
```

### Toggle do Anel

```gdscript
func toggle_ring_state() -> void:
    is_ring_active = !is_ring_active
    
    if is_ring_active:
        # Penalidade instantânea ao ativar
        add_possession(10.0) 
        # Para regeneração
        health_regen_timer.stop()
        # Alerta inimigos (Quebra Stealth)
        emit_signal("noise_generated", global_position, 200.0)
    else:
        # Volta a regenerar (delay de 2s)
        health_regen_timer.start(2.0)
```

---

## 📈 PROGRESSÃO

### Árvore de Habilidades (O Anel)
Inimigos dropam **orbes de energia** que o anel absorve para subir de nível:
- Aumento de dano
- Redução de custo de possessão
- Novos feitiços
- Melhorias passivas

### Consumíveis

#### ☕ Café
- **Efeito:** Diminui a Barra de Possessão
- **Uso:** Item essencial de gerenciamento de risco

#### 🥤 Refrigerante Antigo
- **Efeito:** Cura a Vida instantaneamente
- **Estética:** Latas de 2005 (Guaraná, Coca-Cola)

#### 📞 Relíquias
- **Cartão Telefônico:** Save Point (orelhões)
- **MP3 Player:** Isca sonora para distrair inimigos

---

## 🗺️ MUNDO E AMBIENTAÇÃO

### Paleta de Cores
- **Verde Iquitim:** `#2BFF81` (corrupção, magia)
- **Roxo Possessão:** `#B400FF` (poder, perigo)
- **Preto Profundo:** `#0B0B0B` (sombras, vazio)

### Setores do Mundo

#### Setor 0: O Cemitério (Hub Central)
- **Tema:** A Superfície Silenciosa
- **Função:** Área segura, NPCs resgatados
- **Visual:** Lápides, neblina, portão para o subsolo

#### Setor 1: Minas Antigas
- **Tema:** O Ralo do Mundo
- **Atmosfera:** Úmido, escuro, lama negra
- **Detalhes 2005:** Carcaças de carros, pneus, monitores CRT
- **Inimigos:** Rastejantes cegos, mineradores deformados
- **Boss:** Guardião da Mente

#### Setor 2: Abismo Verde
- **Tema:** Bioluminescência e Vertigem
- **Atmosfera:** Fenda colossal, pontes suspensas
- **Visual:** Verde tóxico, fungos gigantes
- **Perigo:** Esporos venenosos (alucinações visuais)
- **Boss:** Guardião das Sombras

#### Setor 3: Ruínas Perdidas
- **Tema:** A Cidade Esquecida
- **Atmosfera:** Necrópole subterrânea
- **Visual:** Brutalismo + favelas fossilizadas
- **Inimigos:** Criaturas brutais com escombros
- **Boss:** Guardião do Caos

#### Setor 4: Templo Central
- **Tema:** Horror Cósmico
- **Atmosfera:** Realidade instável
- **Visual:** Geometria impossível, roxo pulsante
- **Desafio:** Puzzles de manipulação ambiental
- **Boss:** Guardião do Mundo

---

## 👥 PERSONAGENS

### O Protagonista (Hospedeiro)
- **Nome:** Definido pelo jogador
- **Visual 2005:** Calça cargo, All-Star, camiseta de banda, MP3 no pescoço
- **Personalidade:** Mudo, estoico, determinado
- **Motivação:** Resgatar os quatro amigos
- **Fraqueza:** Sem o anel, fisicamente fraco

### Iquitim (A Entidade)
- **Natureza:** Anti-herói sarcástico e cruel
- **Papel:** Voz na cabeça do protagonista
- **Visão:** Vê o protagonista como "veículo" para vingança
- **Interação com o Moderno:**
  - Celulares = "Espelhos Mortos"
  - Metrô/Ônibus = "Vermes de Ferro"
  - Refrigerante = "Poção de Açúcar Negro"

### Os Quatro Amigos

#### 1. A Sabedoria (Garota de Óculos)
- **Arquétipo:** Voz da razão
- **Captor:** Guardião da Mente
- **Situação:** Conhecimentos torcidos em labirintos

#### 2. O Medo (Garoto Mais Novo)
- **Arquétipo:** Inocência
- **Captor:** Guardião das Sombras
- **Situação:** Pesadelo constante

#### 3. A Paciência (Pessoa Não-Binária)
- **Arquétipo:** Mediador calmo
- **Captor:** Guardião do Caos
- **Situação:** Ciclo de fúria

#### 4. O Respeito (Garota Autista)
- **Arquétipo:** Sensitiva
- **Captor:** Guardião do Mundo
- **Situação:** Conexão usada para distorcer realidade

---

## 👹 INIMIGOS E BOSSES

### Inimigos Comuns

#### Setor 1 (Minas)
- **Mineradores Deformados:** Lentos, tank
- **Rastejantes Cegos:** Rápidos, sensíveis ao som

#### Setor 2 (Abismo)
- **Fungos Vivos:** Explosivos, AoE
- **Sombras Ambulantes:** Invisíveis

### As Três Garotas (Mini-Bosses Recorrentes)
Filhas do Guardião das Sombras, não morrem em combates normais.

#### 1. Sabedoria Distorcida
- **Ataque:** Inverte controles, ilusões de plataformas

#### 2. Luxúria
- **Ataque:** Aura que acelera Possessão passivamente

#### 3. Ambição
- **Ataque:** Luta física, rouba itens de cura

### Os Guardiões (Bosses Principais)

#### 1. Guardião da Mente (Minas)
- **Tipo:** Mago/Ilusionista
- **Mecânica:** Cria clones, dano de rebote
- **Recompensa:** Clone Mental (isca de aggro)

#### 2. Guardião das Sombras (Abismo)
- **Tipo:** Assassino/Speedster
- **Mecânica:** Apaga luzes, teleporte
- **Recompensa:** Shadow Dash (atravessa grades)

#### 3. Guardião do Caos (Ruínas)
- **Tipo:** Brute/Berserker
- **Mecânica:** Arena minúscula, ataques massivos
- **Recompensa:** Punho Titânico (quebra paredes)

#### 4. Guardião do Mundo (Templo)
- **Tipo:** Controlador de Terreno
- **Mecânica:** Altera geometria da sala
- **Recompensa:** Manipulação de Matéria (cria blocos)

---

## 🖥️ INTERFACE (UI)

### HUD Principal: Medidor de Conflito
Localizado no canto superior esquerdo - **recipiente de vidro rachado**:

- **Barra de Vida (Roxa `#B400FF`):** Preenche esquerda → direita
- **Barra de Possessão (Verde `#2BFF81`):** Preenche direita → esquerda
- **Ponto de Ruptura:** Onde as cores se encontram
- **Quebra Visual:** Se verde cobrir todo roxo → vidro "quebra"

### Indicadores de Estado do Anel

#### Desativado (Humano)
- Ícone: Pedra cinza opaca com rachaduras

#### Ativado (Poder)
- Ícone: Verde neon pulsante (ritmo cardíaco)

#### Alerta de Cooldown
- Ícone: Vermelho piscante com cadeado
- Mensagem: *"Se a barra encher agora, você morre"*

### Feedback de Tela (Juice)

#### 0-50% Possessão
- Tela limpa, foco nítido

#### 51-80% Possessão
- Vinheta escura nos cantos
- Leve aberração cromática

#### 81-99% Possessão (CRÍTICO)
- Distorções de glitch (VHS estragado)
- Áudio abafado (low-pass filter)
- Sussurros aumentam
- Controle vibra

### Menu de Inventário Rápido
Canto inferior esquerdo - Display de celular antigo (verde/preto):
- Slot 1: Refrigerante (Cura)
- Slot 2: Café (Sanidade)
- Contador numérico (pixel font)

---

## 🏗️ ARQUITETURA TÉCNICA

### Stack Tecnológico
- **Engine:** Godot 4.5.1
- **Linguagem:** GDScript 2.0 (tipagem estática forte)
- **IDE:** VS Code + godot-tools
- **Controle de Versão:** Git
- **Testes:** GdUnit4

### Estrutura de Diretórios

```
res://
├── _core/                  # Singletons e Sistemas Globais
│   ├── game_manager.gd     # Estado do jogo (Pause, GameOver)
│   ├── signal_bus.gd       # Hub de Sinais (Observer Pattern)
│   ├── save_system.gd      # Serialização e Persistência
│   └── audio_manager.gd    # Mixer de canais e pools de SFX
│
├── assets/                 # Recursos brutos
│   ├── sprites/
│   ├── audio/
│   └── fonts/
│
├── data/                   # Dados estáticos
│   ├── dialogs.json
│   ├── items_db.json
│   └── enemy_stats.tres
│
├── entities/               # Objetos instanciáveis
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player_controller.gd
│   │   └── player_camera.gd
│   ├── enemies/
│   └── projectiles/
│
├── systems/                # Componentes reutilizáveis
│   ├── health_component.gd
│   ├── possession_component.gd
│   ├── hitbox_component.gd
│   └── interaction_component.gd
│
├── world/                  # Cenas de mapa
│   ├── sectors/
│   │   ├── sector_0_cemetery.tscn
│   │   ├── sector_1_mines.tscn
│   │   ├── sector_2_abyss.tscn
│   │   ├── sector_3_ruins.tscn
│   │   └── sector_4_temple.tscn
│   └── props/
│
└── ui/                     # Interfaces
    ├── hud_overlay.tscn
    ├── inventory_grid.tscn
    └── dialog_box.tscn
```

### Padrões de Projeto

#### 1. Composição sobre Herança
- Usar Nodes como Componentes
- Exemplo: `HealthComponent`, `PossessionComponent`

#### 2. Signal Bus (Observer Pattern)
- Comunicação desacoplada via `SignalBus`
- Exemplo: `SignalBus.emit_signal("player_died")`

#### 3. Máquina de Estados (FSM)
**Player States:**
- `Idle`
- `Move`
- `Dash`
- `Attack_Light`
- `Cast_Magic`
- `Transformation_Sequence`
- `Dead`

### Sistemas Críticos

#### Sistema de Possessão
```gdscript
# Cálculo de Risco (a cada frame)
if possession_current >= (max_health - health_current):
    _trigger_transformation_or_death()
```

#### Gestão de Mundos (Sector Streaming)
- Trigger Areas nas bordas dos mapas
- Background Loading assíncrono
- Persistência local de estado

#### Sistema de Salvamento
- **Formato:** JSON criptografado
- **Trigger:** Orelhões (checkpoints manuais)
- **Dados:** Posição, inventário, flags, habilidades

### Otimização
- **Object Pooling:** Projéteis e partículas
- **Physics Server:** Para hordas de inimigos

---

## 🤖 DIRETRIZES PARA IA

### Master Prompt

```
Aja como um Engenheiro Sênior de Gameplay especializado em Godot 4.5 e GDScript 2.0.
Você está desenvolvendo 'O Anel de Iquitim'.

CONTEXTO:
Jogo 2D Top-down de terror urbano (SP 2005) com mecânica de risco/recompensa (Vida vs. Possessão).

DIRETRIZES PRIORITÁRIAS:
1. Estilo de Código: Tipagem estática estrita + docstrings
2. Arquitetura: Composição (Nodes) > Herança
3. Comunicação: Signals para desacoplamento
4. Mecânica Core: Toggle Humano/Anel com gerenciamento de Possessão
5. Regra de Ouro: Possessão > Vida durante cooldown = Game Over imediato

VALORES OBRIGATÓRIOS:
- SPEED_HUMAN: 90.0 px/s
- SPEED_RING: 130.0 px/s
- SPEED_IQUITIM: 220.0 px/s
- ACCELERATION: 800.0
- FRICTION: 1000.0
```

### Regras de Implementação

#### Tipagem Estática SEMPRE
```gdscript
# ✅ CORRETO
var health: int = 100
var speed: float = 90.0

# ❌ ERRADO
var health = 100
var speed = 90.0
```

#### Docstrings Obrigatórias
```gdscript
## Gerencia o estado de possessão do jogador.
## Verifica a cada frame se a possessão ultrapassou a vida.
func _check_possession_limit() -> void:
    pass
```

#### Signals para Comunicação
```gdscript
# Emitir
SignalBus.emit_signal("noise_generated", global_position, 200.0)

# Escutar
SignalBus.connect("noise_generated", _on_noise_detected)
```

### Física e Game Feel

#### Movimento com Inércia
```gdscript
func _physics_process(delta: float) -> void:
    var input_vector := Input.get_vector("left", "right", "up", "down")
    
    if input_vector != Vector2.ZERO:
        velocity = velocity.move_toward(
            input_vector * get_target_speed(),
            ACCELERATION * delta
        )
    else:
        velocity = velocity.move_toward(
            Vector2.ZERO,
            FRICTION * delta
        )
    
    move_and_slide()
```

### Lógica de Game Over

```gdscript
## Verifica condição crítica de morte por possessão.
func _check_critical_possession() -> void:
    if possession >= health:
        if transformation_on_cooldown:
            # MORTE INSTANTÂNEA
            GameManager.trigger_game_over("POSSESSION_OVERFLOW")
        else:
            # Transformação forçada
            _force_iquitim_transformation()
```

---

## 📝 CHECKLIST DE IMPLEMENTAÇÃO

### Fase 1: Core Systems
- [ ] `signal_bus.gd` - Hub de sinais
- [ ] `game_manager.gd` - Estado global
- [ ] `player_controller.gd` - Movimentação e FSM
- [ ] `possession_component.gd` - Sistema de possessão
- [ ] `health_component.gd` - Sistema de vida

### Fase 2: Gameplay
- [ ] Toggle do anel (TAB/L1)
- [ ] Dash com I-frames
- [ ] Regeneração de vida (modo humano)
- [ ] Penalidade de ativação (10% possessão)
- [ ] Transformação Iquitim
- [ ] Game Over por cooldown

### Fase 3: Combat
- [ ] Ataque básico (humano)
- [ ] Magias (anel ativado)
- [ ] Hitbox/Hurtbox system
- [ ] Inimigos básicos (Setor 1)
- [ ] Boss 1: Guardião da Mente

### Fase 4: World
- [ ] Setor 0: Cemitério (hub)
- [ ] Setor 1: Minas Antigas
- [ ] Sistema de transição entre setores
- [ ] Save system (orelhões)
- [ ] Consumíveis (café, refri)

### Fase 5: Polish
- [ ] UI/HUD completo
- [ ] Feedback visual (juice)
- [ ] Áudio e música
- [ ] Partículas e efeitos
- [ ] Balanceamento

---

## 🎨 REFERÊNCIAS VISUAIS

### Paleta de Cores
```
Verde Iquitim:  #2BFF81 (RGB: 43, 255, 129)
Roxo Possessão: #B400FF (RGB: 180, 0, 255)
Preto Profundo: #0B0B0B (RGB: 11, 11, 11)
```

### Estética 2005 (São Paulo)
- Orelhões vermelhos da Telefônica
- Ônibus amarelos/vermelhos
- Celulares flip (Motorola V3)
- MP3 players (iPod Shuffle)
- Latas de refrigerante antigas
- Monitores CRT
- Calças cargo
- All-Star / tênis de lona

---

## 📚 GLOSSÁRIO

- **Possessão:** Medida de quanto Iquitim controla o corpo
- **Toggle:** Alternar entre modo Humano e Anel
- **Forma Iquitim:** Transformação temporária de poder máximo
- **Cooldown Fatal:** Período após transformação onde Game Over é instantâneo
- **Stealth:** Modo furtivo (apenas quando anel desativado)
- **I-Frames:** Invencibilidade temporária durante dash
- **Orbes:** Energia que inimigos dropam (XP do anel)

---

## 🔄 HISTÓRICO DE VERSÕES

### v1.4 (Atual)
- Documento completo com física e game loop
- Diretrizes para IA
- Checklist de implementação

### v1.0
- Conceito inicial
- Narrativa base
- Mecânicas core

---

**Hash de Verificação:** IQUITIM_V1.4_GODOT_4.5  
**Última Atualização:** 2025-11-21  
**Documento para:** Desenvolvimento + IA Assistida
