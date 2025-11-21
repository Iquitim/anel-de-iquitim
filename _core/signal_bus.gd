extends Node

## Hub central de Sinais (Observer Pattern)
##
## Facilita a comunicação desacoplada entre sistemas distantes.

# Sinais de Jogo
signal game_over(reason: String)
signal player_died
signal noise_generated(position: Vector2, radius: float)
signal possession_updated(current: float, max_val: float)

# Sinais de Combate
signal enemy_killed(enemy_type: String, position: Vector2)
signal boss_defeated(boss_name: String)

# Sinais de UI
signal dialog_requested(dialog_id: String)
signal inventory_updated
