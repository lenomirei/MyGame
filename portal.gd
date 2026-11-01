extends "res://planet.gd"

func _ready() -> void:
	type = PlanetType.PORTAL
	super._ready()

# portal do not spawn soldiers, but can be used to connect planets and transfer soldiers between planets
func start_spawn() -> void:
	pass

func _fly_soldiers(operator: Faction, target: Planet):
	if !soldiers_map.has(operator):
		print("no soldiers_map of this faction on this planet")
		return

	while !soldiers_map[operator].soldiers.is_empty():
		var soldier: Soldier = soldiers_map[operator].soldiers.pop_front();
		soldier.reparent(get_parent(), true)
		if master_faction == operator:
			soldier._flash_to(target)
		else:
			soldier._fly_to(target)
		_update_soldiers_information()
		#target._handle_attack_soldier(soldier, self)
