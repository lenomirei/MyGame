extends Area2D

class_name Planet

signal connecting_enter()
signal connecting_exit()
signal captured_by(old_faction: Faction, new_faction: Faction)

@export var master_faction: Faction = null
@export var radius: float = 20.0
@export var soldier_limit: int = 50
@export var spawn_cd: float = 1.0
var soldier_class: PackedScene
var mouse_enter: bool = false
var connecting: bool = false
var id: int

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
		var soldiers_count: int = $"Soldiers".get_child_count()
		if soldiers_count > 0:
			# delete soldier
			var top_soldier: Soldier = $Soldiers.get_child(0)
			$"Soldiers".remove_child(top_soldier)
			top_soldier.queue_free()
			soldier.queue_free()
		else:
			soldier.reparent(self.get_node(^"Soldiers"), true)
			captured(soldier.master_faction)
	else:
		soldier.reparent(self.get_node(^"Soldiers"), true)
		
	_update_label()

func _move_soldiers_to_target(target: Planet) -> void:
	if target != null:
		_fly_soldiers(target)
	pass
	
func _fly_soldiers(target: Planet):
	for soldier in $"Soldiers".get_children():
			soldier = soldier as Soldier
			soldier.reparent(get_parent(), true)
			soldier._fly_to(target)
			_update_label()
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
		var spawn_timer: Timer = $"Timer"
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
		_update_label()

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
			
func captured(faction: Faction) -> void:
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

func _update_label() -> void:
	$"Label".text = String.num_uint64($"Soldiers".get_child_count())
