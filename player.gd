extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var max_jumps: int = 1

@onready var camera = $Camera3D
@onready var gun_anim = $Camera3D/gun/AnimationPlayer
@onready var bullet_spawn = $Camera3D/gun/RayCast3D
@onready var bullet = preload("res://bullet.tscn")
var instance

	# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var MOUSE_SENSITIVITY = 0.05
var look_dir: Vector2
var camera_sens = 50
var jumps_left: int = 0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1

	# Get the input direction and handle the movement.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		jumps_left = max_jumps
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		# Air control
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
		
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("recoil")
			instance = bullet.instantiate()
			instance.position = bullet_spawn.global_position
			instance.transform.basis = bullet_spawn.global_transform.basis
			get_parent().add_child(instance)
	
	
	_rotate_camera(delta)
	move_and_slide()
	
func _input(event):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	
func _rotate_camera(delta: float, sens_mod: float = 1.0):
	var input = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	look_dir += input
	rotation.y -= look_dir.x * camera_sens * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, deg_to_rad(-89), deg_to_rad(89))
	look_dir = Vector2.ZERO
