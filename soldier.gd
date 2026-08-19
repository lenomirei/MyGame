extends CharacterBody2D

class_name Soldier

@export var radius: float = 2.0
var soldier_color: Color = Color.RED

func initialize(c: Color) -> void:
	soldier_color = c
	queue_redraw()

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, soldier_color)
	
func fly_to_another_country(target: Country) -> void:
	pass
