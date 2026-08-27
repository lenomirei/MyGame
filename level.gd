extends Node2D

# enemy_count means the total number of enemy countries
var enemy_count: int = 0
var player_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children: Array[Node] = self.get_children()
	for child in children:
		var c: Country = child as Country
		c.captured_by.connect(_country_captured_by)
		match (c.state):
			Country.State.ENEMY:
				enemy_count += 1
			Country.State.PLAYER:
				player_count += 1
			_:
				pass
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _country_captured_by(old_state: Country.State, new_state: Country.State):
	if old_state == Country.State.ENEMY && new_state == Country.State.PLAYER:
		enemy_count -= 1
		player_count += 1
	elif old_state == Country.State.PLAYER && new_state == Country.State.ENEMY:
		enemy_count += 1
		player_count -= 1
		
	if enemy_count <= 0:
		_player_win()

func _player_win():
	# todo: pause the game and emit play win signal to game manager
	pass
	
func _player_lose():
	# todo: pause the game and emit play lose signal to game manager
	pass
