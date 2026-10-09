extends ProgressBar

class_name CaptureProgress

signal progress_min(faction: Faction)
signal progress_max(faction: Faction)

var progressing_faction: Faction = null:
	set(new_faction):
		progressing_faction = new_faction
		add_theme_color_override("font_color", new_faction.color)

func _increase(increment: float, faction: Faction) -> void:
	if progressing_faction == null:
		progressing_faction = faction
		value += increment
	elif progressing_faction == faction:
		value += increment
	else:
		value -= increment
		if value == min_value:
			progress_min.emit(progressing_faction)
			progressing_faction = faction
		return
			
	if value == max_value:
		progress_max.emit(progressing_faction)
