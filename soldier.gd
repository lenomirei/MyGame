extends CharacterBody2D

class_name Soldier

@export var radius: float = 2.0
var master_country: Country

func initialize(c: Country = null) -> void:
	master_country = c

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _draw() -> void:
	var draw_color := master_country.color if is_instance_valid(master_country) else Color.WHITE
	draw_circle(Vector2.ZERO, radius, draw_color)
