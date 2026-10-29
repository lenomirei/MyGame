extends Node2D

class_name Level
# Called when the node enters the scene tree for the first time.

var factions_map: Dictionary[int, Faction]

func _ready() -> void:
	pass

func _generate_level(config_path: String) -> bool:
	var level1_configuration: LevelConfiguration = load("res://level_configurations/level1.tres")
	
	_parse_level_data(level1_configuration)
	return true

func _parse_level_data(level_configuration: LevelConfiguration) -> bool:
	var factions: Array[FactionInfo] = level_configuration.factions
	if null == factions:
		return false
	
	# create factions and add them to the level, only the enemy factions will be added to the factions_map, the player faction will be stored in GlobalData.player_faction, and the neutral faction will not be added to the factions_map
	for faction: FactionInfo in factions:
		if Faction.is_reserved_name(faction.name):
			push_error("Faction name \"%s\" is a reserved name for the neutral faction. Please modify %s" % [faction.name, level_configuration.resource_path])
			return false
		var faction_node: Faction = Faction.new()
		faction_node.color = faction.color
		faction_node.id = faction.id
		faction_node.state = faction.state
		faction_node.name = faction.name
		add_child(faction_node)
		factions_map[faction_node.id] = faction_node
		
	# add a fake faction for neutral faction
	var neutral_faction_node: Faction = Faction.new()
	neutral_faction_node.color = Color.GRAY
	neutral_faction_node.id = 0; # fixed id for special node
	neutral_faction_node.state = Faction.State.NEUTRAL
	neutral_faction_node.name = Faction.NEUTRAL_NAME
	add_child(neutral_faction_node)

	# TODO: add a player faction node for the player, and set the player faction to it
	var player_faction_node: Faction = Faction.new()
	player_faction_node.color = Color.BLUE
	player_faction_node.id = 0; # fixed id for special node
	player_faction_node.state = Faction.State.PLAYER
	player_faction_node.name = Faction.PLAYER_NAME
	GlobalData.player_faction = player_faction_node
	add_child(player_faction_node)
	
	var planets_data: Array[PlanetInfo] = level_configuration.planets
	if null == planets_data:
		return false
	
	var planet_scene: PackedScene = load("res://planet.tscn")
	for planet_data: PlanetInfo in planets_data:
		var planet_node: Planet = planet_scene.instantiate()
		planet_node.soldier_limit = planet_data.max_soldiers
		planet_node.radius = planet_data.radius
		planet_node.id = planet_data.id
		planet_node.position = Vector2(planet_data.position.x, planet_data.position.y)
		var master_state: Faction.State = planet_data.master_state
		match master_state:
			Faction.State.NEUTRAL:
				planet_node.master_faction = $"Neutral"
			Faction.State.PLAYER:
				planet_node.master_faction = player_faction_node
				player_faction_node.max_soldier_count += planet_node.soldier_limit
			_:
				# use master_id to find the master faction, and set the master faction's max soldier count
				if factions_map.has(planet_data.master_id):
					var master_faction: Faction = factions_map[planet_data.master_id]
					planet_node.master_faction = master_faction
					master_faction.max_soldier_count += planet_node.soldier_limit
				else:
					# can not find the faction in faction map, the enemy may not exist
					planet_node.master_faction = $"Neutral"
		
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
