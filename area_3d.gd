extends Area3D

@export var damage := 1

signal capsule_hit(dam)

func _hit():
	emit_signal("capsule_hit", damage)
