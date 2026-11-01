extends RefCounted

class_name ConnectingInfo

signal connecting_started(from: Planet, to: Planet)
signal connecting_ended(from: Planet, to: Planet)

var from: Planet = null:
	set(planet):
		from = planet
		connecting_started.emit(from, to)
var to: Planet = null

func clear() -> void:
	connecting_ended.emit(from, to)
	from = null
	to = null
