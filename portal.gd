extends "res://planet.gd"


func _ready() -> void:
  type = PlanetType.PORTAL
  super._ready()

# portal do not spawn soldiers, but can be used to connect planets and transfer soldiers between planets
func start_spawn() -> void:
  pass
