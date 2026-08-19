extends Area2D

class_name Country

signal connecting_enter()
signal connecting_exit()

@export var color: Color = Color.RED
@export var radius: float = 20.0
@export var under_player_countrol: bool = false
@export var max_soldier_count: int = 50
var spawn_cd: float = 1.0
var soldier_class: PackedScene = preload("res://soldier.tscn") as PackedScene
var mouse_enter: bool = false
var connecting: bool = false
var hovered_country: Country

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func get_country_under_mouse() -> Country:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	for result in space.intersect_point(params, 8):
		var collider = result.collider
		if collider is Country and collider != self:
			return collider
	return null

func _move_soldiers_to_target(target: Country) -> void:
	if target != null:
		for soldier in $"Soldiers".get_children():
			soldier = soldier as Soldier
			soldier.fly_to_another_country(target)
			pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if connecting and under_player_countrol:
		queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
	
	if connecting and under_player_countrol:
		var mouse_position: Vector2 = get_local_mouse_position()
		draw_line(Vector2.ZERO, mouse_position, color, 5.0, true)

func set_color(c: Color) -> void:
	color = c
	queue_redraw()

func start_spawn() -> void:
	var spawn_timer: Timer = $"Timer"
	if spawn_timer.is_stopped():
		spawn_timer.one_shot = false
		spawn_timer.start(spawn_cd)

func _on_spawn_timer_timeout() -> void:
	if $"Soldiers".get_child_count() < max_soldier_count:
		var soldier: Soldier = soldier_class.instantiate() as Soldier
		soldier.initialize(color)
		$"Soldiers".add_child(soldier)
		soldier.position = Vector2(30, 30)
		_update_label()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.is_released() and connecting:
			connecting = false;
			connecting_exit.emit()
			# redraw to disable the line
			
			var target := get_country_under_mouse()
			_move_soldiers_to_target(target)
			queue_redraw()
		if mouse_event.is_pressed() and mouse_enter:
			connecting = true
			connecting_enter.emit()
			
func captured(e_c: Country) -> void:
	color = e_c.color
	under_player_countrol = e_c.under_player_countrol
	reset()
	pass
	
func reset() -> void:
	start_spawn()
	if under_player_countrol:
		connect("mouse_entered", _player_on_mouse_entered)
		connect("mouse_exited", _player_on_mouse_exited)

func _player_on_mouse_entered() -> void:
	mouse_enter = true

func _player_on_mouse_exited() -> void:
	mouse_enter = false

func _update_label() -> void:
	$"Label".text = String.num_uint64($"Soldiers".get_child_count())
