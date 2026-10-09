extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level_scene: PackedScene = load("res://level.tscn")
	var level: Level = level_scene.instantiate()
	$"GameLevel".add_child(level)
	level._generate_level("")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
