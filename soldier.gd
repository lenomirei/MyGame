extends CharacterBody2D

class_name Soldier

@export var radius: float = 2.0
var master_planet: Planet = null
var master_faction: Faction = null
var moving: bool = false
var target_planet: Planet
var angular_speed: float = 1.0 # 角速度
var orbit_angle: float = 0.0 # 当前弧度
var orbit_radius_x: float = 30.0 # 轨道半径x
var orbit_radius_y: float = 30.0 # 轨道半径y

func initialize(c: Planet, f: Faction) -> void:
	master_planet = c
	master_faction = f
	
	orbit_radius_x = randf_range(master_planet.radius + 20, master_planet.radius + 30)
	orbit_radius_y = randf_range(master_planet.radius + 20, master_planet.radius + 30)
	orbit_angle = randf_range(0.0, TAU)
	angular_speed = randf_range(0.1, 1.0)

	queue_redraw()

func _ready() -> void:
	pass
	
func _get_fly_target_position() -> Vector2:
	return Vector2()

func _process(delta: float) -> void:
	if moving && target_planet != null:
		# if moving is true the soldier's parent node is level, so the position is relative postition of the level root node
		position = position.move_toward(target_planet.position, 1.0)
		if position == target_planet.position:
			target_planet._handle_attack_soldier(self)
			moving = false
			target_planet = null
	else:
		orbit_angle = fmod(orbit_angle + angular_speed * delta, TAU)
		# relative position
		position = Vector2(cos(orbit_angle) * orbit_radius_x, sin(orbit_angle) * orbit_radius_y) 
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, master_faction.color)
	
func _fly_to(target: Planet):
	moving = true
	target_planet = target
	pass
