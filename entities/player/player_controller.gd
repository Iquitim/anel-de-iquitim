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
const DASH_SPEED: float = 300.0 # Velocidade do Dash
const DASH_DURATION: float = 0.2 # Duracao do Dash
const DASH_COOLDOWN: float = 1.2 # Cooldown do Dash

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
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

# Referências aos Componentes
@onready var possession_component: PossessionComponent = $PossessionComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Configurar dependências
	if possession_component and health_component:
		possession_component.health_component = health_component
	
	# Conectar sinais se necessário
	pass

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.MOVE:
			_state_move(delta)
		State.DASH:
			_state_dash(delta)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_ring"):
		toggle_ring_state()
	elif event.is_action_pressed("dash") and can_dash and current_state != State.DASH:
		start_dash()

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
		# Sem regen enquanto move
		if health_component: health_component.can_regenerate = false

func start_dash() -> void:
	current_state = State.DASH
	can_dash = false
	
	# Determinar direção do dash (movimento atual ou frente padrão)
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		dash_direction = input_vector.normalized()
	else:
		# Se parado, dash para a direita (ou última direção se tivéssemos facing_direction)
		dash_direction = Vector2.RIGHT
	
	# Feedback visual (transparência)
	sprite.modulate.a = 0.5
	
	# Timer de Duração
	await get_tree().create_timer(DASH_DURATION).timeout
	end_dash()

func _state_dash(_delta: float) -> void:
	velocity = dash_direction * DASH_SPEED

func end_dash() -> void:
	if current_state == State.DASH:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		sprite.modulate.a = 1.0
		
		# Timer de Cooldown
		await get_tree().create_timer(DASH_COOLDOWN).timeout
		can_dash = true
		print("Dash pronto!")

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
	
	# Se estiver parado e anel desligado, permite regen (o delay é interno do componente)
	if velocity == Vector2.ZERO and not is_ring_active and health_component:
		health_component.can_regenerate = true

func take_damage(amount: float) -> void:
	# Invulnerabilidade na forma Iquitim ou Dash
	if is_iquitim_form or current_state == State.DASH:
		return
		
	if health_component:
		health_component.take_damage(amount)
		# Feedback visual simples (piscar vermelho)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

# --- Mecânica do Anel (GDD 10.4) ---

func toggle_ring_state() -> void:
	is_ring_active = !is_ring_active
	
	# Emitir signal para UI
	SignalBus.ring_toggled.emit(is_ring_active)
	
	if is_ring_active:
		# Feedback Visual: Verde Iquitim (#2BFF81)
		sprite.modulate = Color(0.17, 1.0, 0.51)
		
		# Penalidade instantânea ao ativar
		# Penalidade instantânea ao ativar
		if possession_component:
			possession_component.add_possession(10.0)
			
		if health_component:
			health_component.can_regenerate = false
		
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
