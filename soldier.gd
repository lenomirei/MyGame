extends CharacterBody2D

class_name Soldier

@export var radius: float = 2.0
var master_country: Country = null
var moving: bool = false
var target_country: Country
var angular_speed: float = 2.0 # 角速度
var orbit_angle: float = 0.0 # 当前角度
var orbit_radius_x: float = 30.0 # 轨道半径
var orbit_radius_y: float = 30.0 # 轨道半径

func initialize(c: Country) -> void:
	master_country = c
	
	orbit_radius_x = randf_range(master_country.radius + 20, master_country.radius + 30)
	orbit_radius_y = randf_range(master_country.radius + 20, master_country.radius + 30)
	orbit_angle = randf_range(0.0, TAU)
	angular_speed = randf_range(1.0, 2.5)

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
		orbit_angle += angular_speed * delta
		position = Vector2(cos(orbit_angle) * orbit_radius_x, sin(orbit_angle) * orbit_radius_y) 
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, master_country.color)
	
func _fly_to(target: Country):
	moving = true
	target_country = target
	pass
