class_name Fireball
extends Area2D

## Projétil de Fogo Verde (Anel)
##
## Causa dano em inimigos e desaparece.

@export var speed: float = 400.0
@export var damage: float = 10.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Pequeno delay antes de ativar colisões (evita colidir com player ao spawnar)
	await get_tree().create_timer(0.05).timeout
	body_entered.connect(_on_body_entered)
	
	# Destruir após tempo de vida
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Ignorar o player
	if body is PlayerController:
		return
		
	# Causar dano se for inimigo com HealthComponent ou take_damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("🔥 Fireball atingiu inimigo! Dano: ", damage)
	
	# Destruir ao bater em parede ou inimigo
	queue_free()
