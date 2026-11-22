extends RefCounted

class_name SoldiersPool

static var _instance: SoldiersPool = null

var using: Dictionary[Soldier, bool] = {}
var idle: Array[Soldier] = []
var soldier_scene: PackedScene = preload("res://soldier/soldier.tscn")

static func get_instance() -> SoldiersPool:
	if _instance == null:
		_instance = SoldiersPool.new()
	return _instance

func _setup(max_count: int) -> void:
	print_debug("Soldiers pool set up with max count: %d" % max_count)
	if !using.is_empty():
		return

	if idle.size() > max_count:
		print_debug("Idle soldiers size %d is greater than max count %d, releasing extra soldiers..." % [idle.size(), max_count])
		while idle.size() > max_count:
			var extra: Soldier = idle.pop_back()
			extra.free()
		return

	print_debug("Instantiating soldiers...")
	for i in max_count / 2:
		var soldier: Soldier = soldier_scene.instantiate()
		idle.append(soldier)

	while idle.size() > max_count:
		var extra: Soldier = idle.pop_back()
		extra.free()
	
func _get_soldier() -> Soldier:
	print_debug("get soldier, idle size: %d, using size: %d" % [idle.size(), using.size()])
	var soldier: Soldier
	if idle.is_empty():
		soldier = soldier_scene.instantiate()
	else:
		soldier = idle.pop_back()
	using[soldier] = true
	return soldier

func _release_soldier(soldier: Soldier) -> void:
	print_debug("release soldier, idle size: %d, using size: %d" % [idle.size(), using.size()])
	if using.has(soldier):
		using.erase(soldier)
		idle.append(soldier)

func _release_all() -> void:
	for soldier in using.keys():
		idle.append(soldier)
	using.clear()

func _release_all_idle() -> void:
	idle.clear()

func _get_using_count() -> int:
	return using.size()
