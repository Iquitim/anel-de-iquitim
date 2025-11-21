class_name HUDOverlay
extends CanvasLayer

## HUD principal do jogo
##
## Exibe a barra de Vida vs Possessão e o indicador de estado do anel.

# Cores do projeto (GDD)
const COLOR_HEALTH := Color("#B400FF") # Roxo (Vida)
const COLOR_POSSESSION := Color("#2BFF81") # Verde Iquitim (Possessão)
const COLOR_RING_OFF := Color(0.5, 0.5, 0.5) # Cinza (Anel desativado)
const COLOR_RING_ON := Color("#2BFF81") # Verde (Anel ativado)
const COLOR_RING_COOLDOWN := Color(1.0, 0.0, 0.0) # Vermelho (Cooldown)

# Referências aos nós
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/BarContainer/BarStack/HealthBar
@onready var possession_bar: ProgressBar = $MarginContainer/VBoxContainer/BarContainer/BarStack/PossessionBar
@onready var ring_indicator: ColorRect = $MarginContainer/VBoxContainer/RingIndicator/ColorRect

# Valores atuais
var current_health: float = 100.0
var max_health: float = 100.0
var current_possession: float = 0.0
var max_possession: float = 100.0

func _ready() -> void:
	_setup_bars()
	_connect_signals()
	_update_bars()

func _setup_bars() -> void:
	## Configura as cores e estilos das barras
	# Barra de Vida (Roxa)
	var health_stylebox := StyleBoxFlat.new()
	health_stylebox.bg_color = COLOR_HEALTH
	health_bar.add_theme_stylebox_override("fill", health_stylebox)
	
	# Barra de Possessão (Verde, invertida)
	var possession_stylebox := StyleBoxFlat.new()
	possession_stylebox.bg_color = COLOR_POSSESSION
	possession_bar.add_theme_stylebox_override("fill", possession_stylebox)
	
	# Background das barras (escuro)
	var bg_stylebox := StyleBoxFlat.new()
	bg_stylebox.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	health_bar.add_theme_stylebox_override("background", bg_stylebox)
	possession_bar.add_theme_stylebox_override("background", bg_stylebox.duplicate())
	
	# Indicador do anel (inicial: desativado)
	ring_indicator.color = COLOR_RING_OFF

func _connect_signals() -> void:
	## Conecta aos sinais do SignalBus
	if SignalBus.has_signal("possession_updated"):
		SignalBus.possession_updated.connect(_on_possession_updated)
	
	if SignalBus.has_signal("ring_toggled"):
		SignalBus.ring_toggled.connect(_on_ring_toggled)
	
	if SignalBus.has_signal("health_updated"):
		SignalBus.health_updated.connect(_on_health_updated)

func _update_bars() -> void:
	## Atualiza os valores visuais das barras
	# Atualizar barra de vida
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Atualizar barra de possessão
	possession_bar.max_value = max_possession
	possession_bar.value = current_possession

# --- Callbacks de Sinais ---

func _on_possession_updated(current: float, maximum: float) -> void:
	## Atualiza a barra de possessão quando o valor muda
	current_possession = current
	max_possession = maximum
	_update_bars()
	
	# Debug
	print("HUD: Possessão atualizada - ", current, "/", maximum)

func _on_ring_toggled(is_active: bool) -> void:
	## Atualiza o indicador visual do estado do anel
	if is_active:
		ring_indicator.color = COLOR_RING_ON
		print("HUD: Anel ATIVADO (verde)")
	else:
		ring_indicator.color = COLOR_RING_OFF
		print("HUD: Anel DESATIVADO (cinza)")

func _on_health_updated(current: float, maximum: float) -> void:
	## Atualiza a barra de vida quando o valor muda
	current_health = current
	max_health = maximum
	_update_bars()

# --- Métodos Públicos (para acesso direto se necessário) ---

func set_health(current: float, maximum: float) -> void:
	## Define a vida manualmente
	current_health = current
	max_health = maximum
	_update_bars()

func set_possession(current: float, maximum: float) -> void:
	## Define a possessão manualmente
	current_possession = current
	max_possession = maximum
	_update_bars()

func set_ring_state(is_active: bool, on_cooldown: bool = false) -> void:
	## Define o estado visual do anel
	if on_cooldown:
		ring_indicator.color = COLOR_RING_COOLDOWN
	elif is_active:
		ring_indicator.color = COLOR_RING_ON
	else:
		ring_indicator.color = COLOR_RING_OFF
