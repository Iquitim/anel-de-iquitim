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
const IQUITIM_DURATION: float = 4.0 # Duracao da transformacao (4 segundos)

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
var iquitim_timer: float = 0.0
var is_transforming: bool = false

# Referências aos Componentes
@onready var possession_component: PossessionComponent = $PossessionComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var fireball_scene: PackedScene = preload("res://entities/projectiles/fireball.tscn")

func _ready() -> void:
	# Configurar dependências
	if possession_component and health_component:
		possession_component.health_component = health_component
		health_component.died.connect(_on_player_died)
		# Forward local health signal to global bus (HUD)
		health_component.health_updated.connect(func(current, max_val): SignalBus.health_updated.emit(current, max_val))
		# Force initial update
		SignalBus.health_updated.emit(health_component.current_health, health_component.max_health)
	
	# Conectar sinais se necessário
	pass

func _physics_process(delta: float) -> void:
	# Verificar transformação Iquitim
	_check_transformation(delta)
	
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.MOVE:
			_state_move(delta)
		State.DASH:
			_state_dash(delta)
	
	move_and_slide()

func _check_transformation(delta: float) -> void:
	if not possession_component or not health_component:
		return
	
	# Se possessão >= vida E não está em transformação, iniciar
	if possession_component.current_possession >= health_component.current_health and not is_transforming and not is_iquitim_form:
		_start_transformation()
	
	# Se está em forma Iquitim, contar tempo
	if is_iquitim_form:
		iquitim_timer += delta
		
		# Aviso visual quando tempo está acabando
		if iquitim_timer >= IQUITIM_DURATION - 1.0:
			var flash_speed = 5.0
			animated_sprite.modulate = Color.RED if int(iquitim_timer * flash_speed) % 2 == 0 else Color(0.17, 1.0, 0.51)
		
		# GAME OVER se não cancelou a tempo
		if iquitim_timer >= IQUITIM_DURATION:
			_trigger_game_over("TRANSFORMAÇÃO PERMANENTE")

func _start_transformation() -> void:
	is_transforming = true
	is_iquitim_form = true
	iquitim_timer = 0.0
	
	print("⚠️ TRANSFORMAÇÃO IQUITIM INICIADA! Pressione TAB para cancelar!")
	print("  └─ Tempo: 4 segundos")
	
	# Visual feedback extremo
	animated_sprite.modulate = Color(0.17, 1.0, 0.51) # Verde intenso

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_ring"):
		toggle_ring_state()
	elif event.is_action_pressed("dash") and can_dash and current_state != State.DASH:
		start_dash()
	elif event.is_action_pressed("attack"):
		attack()

# --- Lógica de Estados ---

func _state_idle(delta: float) -> void:
	_apply_friction(delta)
	
	# Play idle animation
	if animated_sprite.animation != "idle":
		animated_sprite.play("idle")
	
	if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") != Vector2.ZERO:
		current_state = State.MOVE

func _state_move(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_vector == Vector2.ZERO:
		current_state = State.IDLE
		_apply_friction(delta)
	else:
		# Play walk animation
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		
		# Flip sprite based on horizontal movement
		if input_vector.x != 0:
			animated_sprite.flip_h = input_vector.x < 0
		
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
	animated_sprite.modulate.a = 0.5
	
	# Timer de Duração
	await get_tree().create_timer(DASH_DURATION).timeout
	end_dash()

func _state_dash(_delta: float) -> void:
	velocity = dash_direction * DASH_SPEED

func end_dash() -> void:
	if current_state == State.DASH:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		animated_sprite.modulate.a = 1.0
		
		# Timer de Cooldown
		await get_tree().create_timer(DASH_COOLDOWN).timeout
		can_dash = true
		print("Dash pronto!")

func attack() -> void:
	# Só pode atacar com Anel Ativado (GDD)
	if not is_ring_active:
		return
		
	print("🔥 [DEBUG] Attack Start - HP: ", health_component.current_health)
		
	# Instanciar Fireball
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position
	
	# Direção do tiro (mouse ou movimento)
	# Por enquanto, usa a direção do movimento ou direita se parado
	var direction = Vector2.RIGHT
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		direction = input_vector.normalized()
	elif velocity != Vector2.ZERO:
		direction = velocity.normalized()
	
	fireball.direction = direction
	get_parent().add_child(fireball)
	
	# Custo de Possessão (+10%)
	if possession_component:
		possession_component.add_possession(10.0, true)
		print("🔥 [DEBUG] Attack End - HP: ", health_component.current_health)

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
	print("🩸 [DEBUG] Player take_damage CALLED! Amount: ", amount, " | Current HP: ", health_component.current_health)
	# Invulnerabilidade na forma Iquitim ou Dash
	if is_iquitim_form or current_state == State.DASH:
		print("🛡️ [DEBUG] Damage blocked (Invulnerable)")
		return
		
	if health_component:
		health_component.take_damage(amount)
		print("🩸 [DEBUG] Damage applied. New HP: ", health_component.current_health)
		# Feedback visual simples (piscar vermelho)
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

# --- Mecânica do Anel (GDD 10.4) ---

func toggle_ring_state() -> void:
	# Se está em forma Iquitim, cancelar transformação
	if is_iquitim_form:
		_cancel_transformation()
		return
	
	is_ring_active = !is_ring_active
	
	# Emitir signal para UI
	SignalBus.ring_toggled.emit(is_ring_active)
	
	if is_ring_active:
		# Feedback Visual: Verde Iquitim (#2BFF81)
		animated_sprite.modulate = Color(0.17, 1.0, 0.51)
		
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
		animated_sprite.modulate = Color(1.0, 1.0, 1.0)
		
		# Regressão ao desativar
		if possession_component:
			possession_component.reduce_possession(10.0)
		
		print("⚪ Anel DESATIVADO")
		print("  └─ Velocidade: ", get_target_speed(), " px/s")
		print("  └─ Possessão: -10%")

func _cancel_transformation() -> void:
	print("✅ Transformação CANCELADA!")
	print("  └─ Penalidade: -30% possessão")
	
	is_iquitim_form = false
	is_transforming = false
	iquitim_timer = 0.0
	is_ring_active = false
	
	# Penalidade por cancelar
	if possession_component:
		possession_component.reduce_possession(30.0)
	
	# Visual normal
	animated_sprite.modulate = Color(1.0, 1.0, 1.0)

func _on_player_died() -> void:
	_trigger_game_over("HP ZERADO")

func _trigger_game_over(reason: String) -> void:
	print("💀 GAME OVER: ", reason)
	current_state = State.DEAD
	
	# Emitir signal para GameManager
	SignalBus.game_over.emit(reason)
	
	# Instanciar game over screen
	var game_over_scene = load("res://ui/game_over_screen.tscn")
	var game_over_screen = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_screen)
	game_over_screen.show_game_over(reason)
