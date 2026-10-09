extends Area2D

class_name Planet

signal connecting_enter()
signal connecting_exit()
signal captured_by(old_faction: Faction, new_faction: Faction)

class PlanetFactionSoldierInfo:
	var soldiers: Array[Soldier] = [] # store soldiers of this faction on this planet by faction
	var soldier_count_label: Label = Label.new() # soldier count label for this faction on this planet

@export var master_faction: Faction = null
@export var radius: float = 20.0
@export var soldier_limit: int = 50:
	set(value):
		soldier_limit = value
		$"Label".text = String.num_uint64(value)
	get:
		return soldier_limit
@export var spawn_cd: float = 1.0
@export var battle_speed: float = 1.0  # 每秒损耗系数（越大打得越快）

var soldier_class: PackedScene
var mouse_enter: bool = false
var connecting: bool = false
var id: int
var soldiers_map: Dictionary[Faction, PlanetFactionSoldierInfo]
var capture_progress: CaptureProgress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	capture_progress = $"CaptureProgress"
	soldier_class = load("res://soldier.tscn") as PackedScene
	var label: Label = $"Label"
	label.position.y = -radius - label.size.y - 10
	var soldiers_box: HBoxContainer = $"SoldiersBox"
	soldiers_box.position.y = radius + 10
	reset()

func get_planet_under_mouse() -> Planet:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	for result in space.intersect_point(params, 8):
		var collider = result.collider
		if collider is Planet and collider != self:
			return collider
	return null

func _receive_soldiers(soldier: Soldier) -> void:
	if not soldiers_map.has(soldier.master_faction):
		print("add new faction")
		# soldiers from new faction
		soldiers_map[soldier.master_faction] = PlanetFactionSoldierInfo.new()
		var faction_info: PlanetFactionSoldierInfo = PlanetFactionSoldierInfo.new()
		soldiers_map[soldier.master_faction] = faction_info
		# add label to show soldier number
		$"SoldiersBox".add_child(faction_info.soldier_count_label)
	
	# add soldier to map
	soldiers_map[soldier.master_faction].soldiers.push_back(soldier)
	# reparent soldier
	soldier.reparent(self.get_node(^"Soldiers"), true)
	_update_soldiers_information()

func _move_soldiers_to_target(target: Planet) -> void:
	if target != null:
		_fly_soldiers(target)
	pass

# add a parameter to indicate which faction's soldiers to fly
func _fly_soldiers(target: Planet):
	for soldier in $"Soldiers".get_children():
			soldier = soldier as Soldier
			soldiers_map[soldier.master_faction].soldiers.erase(soldier)
			soldier.reparent(get_parent(), true)
			soldier._fly_to(target)
			_update_soldiers_information()
			#target._handle_attack_soldier(soldier, self)
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if connecting and master_faction.state == Faction.State.PLAYER:
		queue_redraw()

	_battle(delta)
	if soldiers_map.size() == 1 and soldiers_map.keys()[0] != master_faction:
		var spawn_timer: Timer = $"SpwanTimer"
		spawn_timer.stop()
		capture_progress.visible = true
		capture_progress._increase(capture_progress.step * soldiers_map.values()[0].soldiers.size(), soldiers_map.keys()[0])
		
	if soldiers_map.size() > 1:
		var timer = Timer.new()
		timer.wait_time = 1.0
		timer.timeout.connect(_on_battle_tick)
		add_child(timer)
		timer.start()

func _on_battle_tick():
	if soldiers_map.size() <= 1:
		return
	
	for faction in soldiers_map:
		var loss_faction:int = int(0.1 * soldiers_map[faction].soldiers.size())
		loss_faction = max(1, loss_faction)
		# free the solders byte the loss_faction count
		var remove_soldier: Soldier = soldiers_map[faction].soldiers.pop_back()
		self.get_node(^"Soldiers").remove_child(remove_soldier)
		remove_soldier.queue_free()
	
	# update soldiers information
	_update_soldiers_information()

	# 确保至少扣 1 点，避免两个兵力相差太大时完全不掉血
	# A = max(0, A - max(1, loss_A))
	# B = max(0, B - max(1, loss_B))
	

func _battle(delta: float) -> void:
	if soldiers_map.size() < 2:
		return  # 场上只有一个势力，不战斗

	# 1) 先统计各势力数量（不能在循环里改字典，先记下来）
	var counts: Dictionary = {}
	var total := 0
	for faction in soldiers_map:
		var c: int = soldiers_map[faction].soldiers.size()
		counts[faction] = c
		total += c

	# 2) 逐个势力结算损失
	var to_erase: Array[Faction] = []
	for faction in soldiers_map:
		var info: PlanetFactionSoldierInfo = soldiers_map[faction]
		var c: int = counts[faction]
		if c <= 0:
			to_erase.append(faction)
			continue
		var enemy_total: int = total - c
		# 人越少掉得越快
		var loss_per_sec: float = battle_speed * enemy_total / float(c)
		var loss_count: int = int(loss_per_sec * delta)  # 这一帧掉几个
		for i in loss_count:
			var dead: Soldier = info.soldiers.pop_back()
			$"Soldiers".remove_child(dead)
			dead.queue_free()

	# 3) 打光的势力从 map 里清掉（否则 size() 一直≥2 会永远战斗）
	for faction in to_erase:
		_remove_loser_faction(faction)

	# 4) 刷新数量显示（顺带，数量只剩 1 个势力时会走你现有的 capture 逻辑）
	_update_soldiers_information()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, master_faction.color)
	
	if connecting and master_faction.state == Faction.State.PLAYER:
		var mouse_position: Vector2 = get_local_mouse_position()
		draw_line(Vector2.ZERO, mouse_position, master_faction.color, 5.0, true)

func start_spawn() -> void:
	if master_faction.state != Faction.State.NEUTRAL:
		var spawn_timer: Timer = $"SpwanTimer"
		if spawn_timer.is_stopped():
			spawn_timer.one_shot = false
			spawn_timer.start(spawn_cd)

func _on_spawn_timer_timeout() -> void:
	if master_faction._can_produce_soldier():
		var soldier: Soldier = soldier_class.instantiate() as Soldier
		soldier.initialize(self, master_faction)
		if not soldiers_map.has(master_faction):
			var faction_info: PlanetFactionSoldierInfo = PlanetFactionSoldierInfo.new()
			soldiers_map[master_faction] = faction_info
			$"SoldiersBox".add_child(faction_info.soldier_count_label)
		soldiers_map[master_faction].soldiers.push_back(soldier)
		$"Soldiers".add_child(soldier)
		soldier.position = Vector2(30, 30)
		master_faction._soldier_change(1)
		_update_soldiers_information()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.is_released() and connecting:
			connecting = false;
			connecting_exit.emit()
			# redraw to disable the line
			
			var target := get_planet_under_mouse()
			_move_soldiers_to_target(target)
			queue_redraw()
		if mouse_event.is_pressed() and mouse_enter:
			connecting = true
			connecting_enter.emit()
			
func _start_capture(faction: Faction) -> void:
	#_captured(faction)
	pass

func _captured(faction: Faction) -> void:
	capture_progress.visible = false
	captured_by.emit(faction)
	master_faction.max_soldier_count -= self.soldier_limit
	faction.max_soldier_count += self.soldier_limit
	master_faction = faction
	reset()
	queue_redraw()
	pass
	
func reset() -> void:
	start_spawn()
	if master_faction.state == Faction.State.PLAYER:
		connect("mouse_entered", _player_on_mouse_entered)
		connect("mouse_exited", _player_on_mouse_exited)

func _player_on_mouse_entered() -> void:
	mouse_enter = true

func _player_on_mouse_exited() -> void:
	mouse_enter = false

# 需要实现soldier缓慢销毁后这个函数才有用
func _update_soldiers_information() -> void:
	# update soldier count label for each faction and add label to the SoldiersBox if not already added
	for faction in soldiers_map:
		var faction_info: PlanetFactionSoldierInfo = soldiers_map[faction]
		faction_info.soldier_count_label.text = String.num_uint64(faction_info.soldiers.size())
		faction_info.soldier_count_label.modulate = faction.color


func _on_capture_progress_progress_max(faction: Faction) -> void:
	_captured(faction)
	
func _remove_loser_faction(loser: Faction) -> void:
	$"SoldiersBox".remove_child(soldiers_map[loser].soldier_count_label)
	soldiers_map.erase(loser)
	
