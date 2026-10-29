extends "res://planet.gd"

func _ready() -> void:
	type = PlanetType.PORTAL
	super._ready()

# portal do not spawn soldiers, but can be used to connect planets and transfer soldiers between planets
func start_spawn() -> void:
	pass

func _fly_soldiers(target: Planet):
	for soldier in $"Soldiers".get_children():
		soldier = soldier as Soldier
		soldiers_map[soldier.master_faction].soldiers.erase(soldier)
		soldier.reparent(get_parent(), true)
		soldier._flash_to(target)
		_update_soldiers_information()
		#target._handle_attack_soldier(soldier, self)
		pass
