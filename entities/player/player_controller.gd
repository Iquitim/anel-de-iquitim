class_name PlayerController
extends CharacterBody2D

## Controlador Principal do Jogador
##
## Gerencia movimentação, estados (Humano/Anel/Iquitim) e input.

# Constantes de Movimento (Game Feel) - GDD 10.2
const SPEED_HUMAN: float = 90.0 # Lento, vulneravel
const SPEED_RING: float = 130.0 # Agil, combate
const SPEED_IQUITIM: float = 220.0 # Descontrolado
const ACCELERATION: float = 800.0 # Inercia pesada
const FRICTION: float = 1000.0 # Parada nao-imediata

# Estados da Máquina de Estados
enum State {
	IDLE,
	MOVE,
	DASH,
	ATTACK,
	DEAD
}

var current_state: State = State.IDLE
var is_ring_active: bool = false
var is_iquitim_form: bool = false

# Referências aos Componentes
@onready var possession_component: PossessionComponent = $PossessionComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Conectar sinais se necessário
	pass

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.MOVE:
			_state_move(delta)
		State.DASH:
			pass # TODO: Implementar Dash
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_ring"):
		toggle_ring_state()

# --- Lógica de Estados ---

func _state_idle(delta: float) -> void:
	_apply_friction(delta)
	
	if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") != Vector2.ZERO:
		current_state = State.MOVE

func _state_move(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_vector == Vector2.ZERO:
		current_state = State.IDLE
		_apply_friction(delta)
	else:
		_apply_movement(input_vector, delta)

# --- Física e Movimento ---

func get_target_speed() -> float:
	if is_iquitim_form: return SPEED_IQUITIM
	if is_ring_active: return SPEED_RING
	return SPEED_HUMAN

func _apply_movement(input_vector: Vector2, delta: float) -> void:
	var target_speed = get_target_speed()
	velocity = velocity.move_toward(input_vector * target_speed, ACCELERATION * delta)

func _apply_friction(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

# --- Mecânica do Anel (GDD 10.4) ---

func toggle_ring_state() -> void:
	is_ring_active = !is_ring_active
	
	# Emitir signal para UI
	SignalBus.ring_toggled.emit(is_ring_active)
	
	if is_ring_active:
		# Feedback Visual: Verde Iquitim (#2BFF81)
		sprite.modulate = Color(0.17, 1.0, 0.51)
		
		# Penalidade instantânea ao ativar
		if possession_component:
			possession_component.add_possession(10.0)
		
		# Alerta inimigos (Quebra Stealth)
		SignalBus.noise_generated.emit(global_position, 200.0)
		
		print("🟢 Anel ATIVADO")
		print("  └─ Velocidade: ", get_target_speed(), " px/s")
		print("  └─ Possessão: +10%")
	else:
		# Feedback Visual: Normal
		sprite.modulate = Color(1.0, 1.0, 1.0)
		
		# Regressão ao desativar
		if possession_component:
			possession_component.reduce_possession(10.0)
		
		print("⚪ Anel DESATIVADO")
		print("  └─ Velocidade: ", get_target_speed(), " px/s")
		print("  └─ Possessão: -10%")
