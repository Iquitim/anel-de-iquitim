extends Node

## Gerencia o estado global do jogo (Pause, GameOver, Persistência de Sessão)

# Estado do Mundo (Inimigos mortos, itens coletados neste setor)
var world_state: Dictionary = {}

# Flags de Narrativa Global
var narrative_flags: Dictionary = {
	"boss_1_dead": false,
	"friend_saved_wisdom": false,
	"friend_saved_fear": false,
	"friend_saved_patience": false,
	"friend_saved_respect": false
}

func _ready() -> void:
	# Configurar Inputs Padrão (Fallback)
	if not InputMap.has_action("toggle_ring"):
		InputMap.add_action("toggle_ring")
		var ev = InputEventKey.new()
		ev.keycode = KEY_SPACE
		InputMap.action_add_event("toggle_ring", ev)

	# Conectar sinais globais
	# SignalBus.game_over.connect(_on_game_over) # Exemplo (comentado pois SignalBus é autoload)
	pass

func register_enemy_death(enemy_id: String) -> void:
	world_state[enemy_id] = true

func is_enemy_dead(enemy_id: String) -> bool:
	return world_state.get(enemy_id, false)

func _on_game_over(reason: String) -> void:
	print("Game Over: ", reason)
	# Implementar lógica de reload ou tela de morte
