extends CharacterBody3D

@onready var camera = $Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const JOY_DEADZONE = 0.2
const JOY_AXIS_RESCALE = 1.0/(1.0 - JOY_DEADZONE)
const JOY_ROTATION_MULTIPLIER = 200.0 * PI / 180.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/4, PI/4)

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	if abs(xAxis) > JOY_DEADZONE:
		if xAxis > 0:
			xAxis = (xAxis - JOY_DEADZONE) * JOY_AXIS_RESCALE
		else:
			xAxis = (xAxis + JOY_DEADZONE) * JOY_AXIS_RESCALE
		
		rotate_y(-xAxis * delta * JOY_ROTATION_MULTIPLIER)
	
	var yAxis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(yAxis) > JOY_DEADZONE:
		if yAxis > 0:
			yAxis = (yAxis - JOY_DEADZONE) * JOY_AXIS_RESCALE
		else:
			yAxis = (yAxis + JOY_DEADZONE) * JOY_AXIS_RESCALE
		
		camera.rotate_x(-yAxis * delta * JOY_ROTATION_MULTIPLIER / 2)
		camera.rotation.x = clamp(camera.rotation.x, -PI/4, PI/4)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
