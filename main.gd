extends Node3D

@onready var time_label = $UI/TimeCounter

var total_time = 0.0
func _process(delta: float) -> void:
	total_time += delta
	time_label.text = str(snapped(total_time, 0.1))
	
