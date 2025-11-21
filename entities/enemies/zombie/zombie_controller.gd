class_name ZombieController
extends CharacterBody2D

## Controlador do Inimigo Zombie
##
## FSM simples: Idle → Chase → Attack → Dead

# Constantes
const SPEED: float = 60.0
const DETECTION_RADIUS: float = 180.0
const ATTACK_RADIUS: float = 25.0
const ATTACK_DAMAGE: float = 15.0
const ATTACK_COOLDOWN: float = 1.5

# Estados
enum State {
	IDLE,
	CHASE,
	ATTACK,
	DEAD
}

var current_state: State = State.IDLE
var player: CharacterBody2D = null
var can_attack: bool = true

# Referências
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	# Configurar vida inicial
	if health_component:
		health_component.max_health = 50.0
		health_component.current_health = 50.0
		health_component.died.connect(_on_health_depleted)
	
	# Conectar sinais se não conectados na cena
	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)
	if not attack_area.body_exited.is_connected(_on_attack_area_body_exited):
		attack_area.body_exited.connect(_on_attack_area_body_exited)

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	match current_state:
		State.IDLE:
			_state_idle()
		State.CHASE:
			_state_chase(delta)
		State.ATTACK:
			_state_attack(delta)

func _state_idle() -> void:
	velocity = Vector2.ZERO
	sprite.play("idle")
	# Espera player entrar no raio de detecção

func _state_chase(_delta: float) -> void:
	if not player:
		current_state = State.IDLE
		return
	
	# Mover em direção ao player
	var direction := (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	
	# Animar caminhada
	sprite.play("walk")
	
	# Flipar sprite baseado na direção
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
	
	move_and_slide()

func _state_attack(_delta: float) -> void:
	# Não se move, só ataca
	velocity = Vector2.ZERO
	sprite.play("idle")
	
	# Atacar APENAS se cooldown permitir
	if can_attack and player and player.has_method("take_damage"):
		player.take_damage(ATTACK_DAMAGE)
		print("🧟 Zombie atacou! Dano: ", ATTACK_DAMAGE)
		
		# Cooldown
		can_attack = false
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true

## Recebe dano (chamado pelo fireball ou player)
func take_damage(amount: float) -> void:
	if current_state == State.DEAD:
		return
	
	if health_component:
		health_component.take_damage(amount)
		print("🧟 Zombie recebeu dano: ", amount, " | Vida restante: ", health_component.current_health)
		
		# Feedback visual simples
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

## Detecção do player
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player = body
		if current_state == State.IDLE:
			current_state = State.CHASE
			print("🧟 Zombie detectou player! Estado: CHASE")

## Player entrou na área de ataque
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is PlayerController and current_state == State.CHASE:
		current_state = State.ATTACK
		print("🧟 Zombie em alcance de ataque! Estado: ATTACK")

## Player saiu da área de ataque
func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is PlayerController and current_state == State.ATTACK:
		current_state = State.CHASE
		print("🧟 Player saiu do alcance! Estado: CHASE")

## Morte
func _on_health_depleted() -> void:
	current_state = State.DEAD
	print("💀 Zombie morreu!")
	
	# Feedback visual de morte
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
