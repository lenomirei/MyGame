extends Area2D

class_name Country

signal connecting_enter()
signal connecting_exit()

@export var color := Color.RED
@export var radius = 20.0
@export var under_player_countrol = false
var spawn_cd: float = 1.0
var soldier_class: PackedScene = preload("res://soldier.tscn") as PackedScene
var mouse_enter: bool = false
var connecting: bool = false

func _init(c: Color = Color.RED) -> void:
	color = c

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()
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
	spawn_timer.one_shot = false
	spawn_timer.start(spawn_cd)

func _on_spawn_timer_timeout() -> void:
	var soldier: Soldier = soldier_class.instantiate() as Soldier
	soldier.initialize(self)
	$"Soldiers".add_child(soldier)
	soldier.position = Vector2(30, 30)
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.is_released() and connecting:
			connecting = false;
			connecting_exit.emit()
			# redraw to disable the line
			queue_redraw()
		if mouse_event.is_pressed() and mouse_enter:
			connecting = true
			connecting_enter.emit()
			
func captured(e_c: Country) -> void:
	if e_c.under_player_countrol:
		pass
	else:
		pass
		
	
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
	
