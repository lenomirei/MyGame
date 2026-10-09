extends Resource

class_name PlanetInfo

@export var id: int
@export var current_soldiers: int = 0
@export var max_soldiers: int
@export var radius: float
@export var master_state: Faction.State = Faction.State.NEUTRAL
@export var master_id: int
@export var position: Vector2
