extends CharacterBody3D

@onready var camera_mount : Node3D = $camera_mount
@onready var animation_player  = $visuals/mixamo_base/AnimationPlayer
@onready var visuals  = $visuals

var rotation_speed = PI/2

var SPEED = 3.0
const JUMP_VELOCITY = 4.5

var walking_speed  = 3.0
var running_speed  = 6.0

var running  = false

var is_locked  = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity  = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var sens_horizontal  = 0.5
@export var sens_vertical  = 0.5

func camo():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		camera_mount.x = direction.x * SPEED
		camera_mount.z = direction.z * SPEED
	else:
		camera_mount.x = move_toward(velocity.x, 0, SPEED)
		camera_mount.z = move_toward(velocity.z, 0, SPEED)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # mouse movment

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal ))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal ))
		camera_mount.rotate_x(deg_to_rad(- event.relative.y *  sens_vertical))

func camo2():
	var input_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		camera_mount.rotate_y(deg_to_rad(direction.y))
		visuals.rotate_y(deg_to_rad(direction.y))
		camera_mount.rotate_x(deg_to_rad(direction.x))

func _physics_process(delta):
	camo2()
	if !animation_player.is_playing():
		is_locked=false

	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true

	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else :
		SPEED = walking_speed
		running = false

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir  = Input.get_vector("left", "right", "forward", "backward")
	var direction  = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else :
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			visuals.look_at(position + direction)

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked:
		move_and_slide()


#end
