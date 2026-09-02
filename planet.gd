extends Area2D

class_name Planet

signal connecting_enter()
signal connecting_exit()
signal captured_by(old_faction: Faction, new_faction: Faction)

@export var master_faction: Faction = null
@export var radius: float = 20.0
@export var soldier_limit: int = 50:
	set(value):
		soldier_limit = value
		$"Label".text = String.num_uint64(value)
	get:
		return soldier_limit
@export var spawn_cd: float = 1.0
var soldier_class: PackedScene
var mouse_enter: bool = false
var connecting: bool = false
var id: int
var soldiers_map: Dictionary[Faction, Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	soldier_class = load("res://soldier.tscn") as PackedScene
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

func _is_attack(soldier: Soldier) -> bool:
	return soldier.master_faction != self.master_faction

func _handle_attack_soldier(soldier: Soldier) -> void:
	if _is_attack(soldier):
		var guard_soldiers_count: int = 0 if master_faction.state == Faction.State.NEUTRAL else soldiers_map[master_faction].size()
		if guard_soldiers_count > 0:
			# delete soldier
			var top_soldier: Soldier = soldiers_map[master_faction].pop_back()
			$"Soldiers".remove_child(top_soldier)
			top_soldier.queue_free()
			soldier.queue_free()
		else:
			soldier.reparent(self.get_node(^"Soldiers"), true)
			_start_capture(soldier.master_faction)
	else:
		# not attack reparent the soldier to this planet
		soldier.reparent(self.get_node(^"Soldiers"), true)
		
	_update_soldiers_information()

func _move_soldiers_to_target(target: Planet) -> void:
	if target != null:
		_fly_soldiers(target)
	pass
	
func _fly_soldiers(target: Planet):
	for soldier in $"Soldiers".get_children():
			soldier = soldier as Soldier
			soldier.reparent(get_parent(), true)
			soldier._fly_to(target)
			_update_soldiers_information()
			#target._handle_attack_soldier(soldier, self)
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if connecting and master_faction.state == Faction.State.PLAYER:
		queue_redraw()

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
	var capture_progress: ProgressBar = $"ProgressBar"
	capture_progress.add_theme_color_override("font_color", faction.color)
	_captured(faction)
	pass

func _captured(faction: Faction) -> void:
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
	for faction in soldiers_map:
		var soldier_label: Label = Label.new()
		soldier_label.text = String.num_uint64(soldiers_map[faction].size())
		soldier_label.modulate = faction.color
		$"SoldiersBox".add_child(soldier_label)
