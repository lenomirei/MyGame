extends CharacterBody2D

class_name Soldier

@export var radius: float = 2.0
var soldier_color: Color = Color.RED
var moving: bool = false
var target_point: Vector2

func initialize(c: Color) -> void:
	soldier_color = c
	queue_redraw()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	# if moving:
	# 	position = position.move_toward(Vector2.ZERO, 1.0)
	# else:
	# 	# position = position.move_toward(Vector2.ZERO, 1.0)	
	# 	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, soldier_color)
