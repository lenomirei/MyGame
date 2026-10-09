extends Node2D

class_name Level
# Called when the node enters the scene tree for the first time.

var factions_map: Dictionary[int, Faction]

func _ready() -> void:
	pass

func _generate_level(config_path: String) -> bool:
	var database = TextDatabase.new()
	database.load_from_path("res://level_configurations/level1.json")
	var data = database.get_array()
	for level_data in data:
		_parse_level_data(level_data)
	return true

func _parse_level_data(level_data: Dictionary) -> bool:
	var factions: Array = level_data.get("factions")
	if null == factions:
		return false
	
	for faction in factions:
		var faction_node: Faction = Faction.new()
		faction_node.color = Color(faction.get("color"))
		faction_node.id = faction.get("id")
		faction_node.state = faction.get("state")
		faction_node.name = faction.get("name")
		add_child(faction_node)
		factions_map[faction_node.id] = faction_node
	# add a fake faction for neutral faction
	var neutral_faction_node: Faction = Faction.new()
	neutral_faction_node.color = Color.GRAY
	neutral_faction_node.state = Faction.State.NEUTRAL
	neutral_faction_node.name = "Neutral"
	add_child(neutral_faction_node)
	
	var planets_data: Array = level_data.get("planets")
	if null == planets_data:
		return false
	var planet_scene: PackedScene = load("res://planet.tscn")
	for planet_data in planets_data:
		var planet_node: Planet = planet_scene.instantiate()
		planet_node.soldier_limit = planet_data.get("max_soldiers")
		planet_node.radius = planet_data.get("radius")
		planet_node.id = planet_data.get("id")
		planet_node.position = Vector2(planet_data.get("position").get("x"), planet_data.get("position").get("y"))
		var master_state: Faction.State = planet_data.get("master_state")
		match master_state:
			Faction.State.NEUTRAL:
				planet_node.master_faction = $"Neutral"
			_:
				var master_faction: Faction = factions_map[planet_data.get("master_id")]
				planet_node.master_faction = master_faction
				master_faction.max_soldier_count += planet_node.soldier_limit
		
		add_child(planet_node)
		
		
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
