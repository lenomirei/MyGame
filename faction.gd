extends Node

class_name Faction

enum State {
	NEUTRAL,
	PLAYER,
	ENEMY
}

@export var color: Color = Color.GRAY
@export var current_soldier_count = 0
@export var max_soldier_count = 0
@export var id = 0
@export var state: State = State.NEUTRAL

signal defeated(faction: Faction)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _soldier_change(count: int) -> void:
	current_soldier_count += count
	
	if current_soldier_count <= 0:
		defeated.emit()

func _can_produce_soldier() -> bool:
	if current_soldier_count < max_soldier_count:
		return true
	else:
		return false
