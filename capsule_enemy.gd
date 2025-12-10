extends Node3D

@export var health := 10

func _on_area_3d_capsule_hit(dam: Variant) -> void:
	health -= dam
	print(health)
	if health <= 0:
		queue_free()
