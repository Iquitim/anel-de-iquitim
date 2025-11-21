class_name PossessionComponent
extends Node

## Componente responsável pelo cálculo de risco e morte súbita.
##
## Monitora Vida vs Possessão e emite sinais críticos.

@export var max_health: float = 100.0
@export var possession_decay_rate: float = 5.0 # 10% em 2s = 5%/s
@export var health_component: HealthComponent

var current_possession: float = 0.0
var decayable_pool: float = 0.0

# Timer para o Cooldown da Forma Iquitim
var iquitim_cooldown_timer: Timer

func _ready() -> void:
	# Configurar Timer de Cooldown
	iquitim_cooldown_timer = Timer.new()
	iquitim_cooldown_timer.one_shot = true
	iquitim_cooldown_timer.wait_time = 15.0 # 15s de cooldown conforme GDD
	add_child(iquitim_cooldown_timer)

func _process(delta: float) -> void:
	_handle_decay(delta)
	_check_possession_limit()

func _handle_decay(delta: float) -> void:
	if decayable_pool > 0:
		var decay_amount = min(possession_decay_rate * delta, decayable_pool)
		decayable_pool -= decay_amount
		current_possession -= decay_amount
		
		# Safety checks
		decayable_pool = max(0.0, decayable_pool)
		current_possession = max(0.0, current_possession)
		
		SignalBus.possession_updated.emit(current_possession, max_health)

func add_possession(amount: float, is_decayable: bool = false) -> void:
	current_possession += amount
	
	if is_decayable:
		decayable_pool += amount
	
	current_possession = clamp(current_possession, 0.0, max_health * 1.5) # Cap de segurança
	SignalBus.possession_updated.emit(current_possession, max_health)

func reduce_possession(amount: float) -> void:
	current_possession -= amount
	current_possession = max(0.0, current_possession)
	
	# Se reduzirmos possessão manualmente (ex: desativar anel), 
	# devemos garantir que o pool não fique maior que o total
	if decayable_pool > current_possession:
		decayable_pool = current_possession
		
	SignalBus.possession_updated.emit(current_possession, max_health)

func _check_possession_limit() -> void:
	if not health_component: return
	
	# Se a possessao cobriu toda a vida
	if current_possession >= health_component.current_health:
		# SE estiver em Cooldown = Morte Instantanea
		if not iquitim_cooldown_timer.is_stopped():
			SignalBus.game_over.emit("SOBRECARGA_COOLDOWN")
			return

		# SENAO = Transformacao Forcada (Sinalizada para o PlayerController)
		# O PlayerController deve ouvir esse sinal e ativar a forma Iquitim
		SignalBus.possession_updated.emit(current_possession, max_health) # Força update UI
		# TODO: Emitir sinal específico de transformação forçada se necessário
