extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _generate_level() -> bool:
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _player_win():
	# todo: pause the game and emit play win signal to game manager
	pass
	
func _player_lose():
	# todo: pause the game and emit play lose signal to game manager
	pass
