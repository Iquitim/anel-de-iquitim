class_name PossessionComponent
extends Node

## Componente responsável pelo cálculo de risco e morte súbita.
##
## Monitora Vida vs Possessão e emite sinais críticos.

@export var max_health: float = 100.0
@export var possession_decay_rate: float = 1.0 # Quanto a possessão cai por segundo (se houver mecânica de alívio passivo)

var current_health: float
var current_possession: float = 0.0

# Timer para o Cooldown da Forma Iquitim
var iquitim_cooldown_timer: Timer

func _ready() -> void:
	current_health = max_health
	
	# Configurar Timer de Cooldown
	iquitim_cooldown_timer = Timer.new()
	iquitim_cooldown_timer.one_shot = true
	iquitim_cooldown_timer.wait_time = 15.0 # 15s de cooldown conforme GDD
	add_child(iquitim_cooldown_timer)

func _process(delta: float) -> void:
	_check_possession_limit()

func add_possession(amount: float) -> void:
	current_possession += amount
	current_possession = clamp(current_possession, 0.0, max_health * 1.5) # Cap de segurança
	SignalBus.possession_updated.emit(current_possession, max_health)

func reduce_possession(amount: float) -> void:
	current_possession -= amount
	current_possession = max(0.0, current_possession)
	SignalBus.possession_updated.emit(current_possession, max_health)

func _check_possession_limit() -> void:
	# Se a possessao cobriu toda a vida
	if current_possession >= current_health:
		
		# SE estiver em Cooldown = Morte Instantanea
		if not iquitim_cooldown_timer.is_stopped():
			SignalBus.game_over.emit("SOBRECARGA_COOLDOWN")
			return

		# SENAO = Transformacao Forcada (Sinalizada para o PlayerController)
		# O PlayerController deve ouvir esse sinal e ativar a forma Iquitim
		SignalBus.possession_updated.emit(current_possession, max_health) # Força update UI
		# TODO: Emitir sinal específico de transformação forçada se necessário
