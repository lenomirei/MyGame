extends Area2D

class_name Country

signal drag_enter()
signal drag_exit()

@export var color := Color.RED
@export var radius = 20.0
var spawn_cd: float = 1.0
var soldier_class: PackedScene = preload("res://soldier.tscn") as PackedScene
var mouse_enter: bool = false
var dragging: bool = false

func _init(c: Color = Color.RED) -> void:
	color = c

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_spawn()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		position = get_global_mouse_position()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

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
	if event is InputEventMouseButton and mouse_enter == true:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.is_released():
			dragging = false
			drag_exit.emit()
		else:
			dragging = true
			drag_enter.emit()

func _on_mouse_entered() -> void:
	mouse_enter = true

func _on_mouse_exited() -> void:
	mouse_enter = false
