extends RefCounted

class_name DragInfo

var from: Planet = null
var to: Planet = null

func clear() -> void:
	if from != null:
		from.queue_redraw()
	if to != null:
		to.queue_redraw()
	from = null
	to = null
