extends CharacterBody2D

class_name Soldier

@export var radius: float = 2.0
var master_country: Country = null
var moving: bool = false
var target_country: Country

func initialize(c: Country) -> void:
	master_country = c
	queue_redraw()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if moving && target_country != null:
		position = position.move_toward(target_country.position, 3.0)
		if position == target_country.position:
			target_country._handle_attack_soldier(self, master_country)
			moving = false
			target_country = null
	else:
		pass
		# position = position.move_toward(Vector2.ZERO, 1.0)	
	
	
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, master_country.color)
	
func _fly_to(target: Country):
	moving = true
	target_country = target
	pass
