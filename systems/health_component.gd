class_name HealthComponent
extends Node

## Componente de Vida e Regeneração
##
## Gerencia a vida atual, dano, cura e regeneração passiva.

signal health_updated(current: float, max_val: float)
signal died

@export var max_health: float = 100.0
@export var regen_rate: float = 2.0 # Vida por segundo (reduzido)
@export var regen_delay: float = 3.0 # Tempo parado para iniciar regen
@export var max_regen_percent: float = 0.6 # Regenera até 60% do máximo

var current_health: float
var can_regenerate: bool = true
var _regen_timer: float = 0.0

func _ready() -> void:
	current_health = max_health
	# Inicializa UI
	call_deferred("_emit_update")

func _process(delta: float) -> void:
	var max_regen_health = max_health * max_regen_percent
	if can_regenerate and current_health < max_regen_health:
		_handle_regeneration(delta)

func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = max(0.0, current_health)
	
	_emit_update()
	
	# Resetar timer de regen ao tomar dano
	_regen_timer = 0.0
	
	if current_health <= 0:
		died.emit()

func heal(amount: float) -> void:
	current_health += amount
	current_health = min(current_health, max_health)
	_emit_update()

func _handle_regeneration(delta: float) -> void:
	# Limitar regeneração a 60% do máximo
	var max_regen_health = max_health * max_regen_percent
	
	if current_health >= max_regen_health:
		return # Não regenera além de 60%
	
	# Aplica regeneração
	current_health += regen_rate * delta
	current_health = min(current_health, max_regen_health)
	_emit_update()

func _emit_update() -> void:
	health_updated.emit(current_health, max_health)
