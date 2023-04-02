extends CharacterBody3D

@export var GRAVITY : float = 32.0
@export var MAX_SPEED : float = 5.0
@export var MAX_ACCEL : float = 150.0
@export var JUMP_FORCE : float = 12.0
@export var FRICTION : float = 0.76
@export var CONTROL : float = 15.0

var max_speed : float
var hvel : Vector3
var dir : Vector3
var is_sprinting : bool = false
var height : float = 1.0
var crouch : float = 0

func _ready():
	$animation_handler.player = self
	$animation_handler.anim = $anim
	$animation_handler.p_camera = $head/camera

func _physics_process(delta):
	is_sprinting = handle_sprint()
	handle_crouch(delta)
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	var input = Input.get_vector("move_left","move_right","move_up","move_down")
	
	dir = lerp(dir, (transform.basis * Vector3(input.x, 0, input.y)).normalized(), delta * CONTROL)
	hvel = velocity
	hvel.y = 0.0
	hvel *= FRICTION
	
	if hvel.length() < MAX_SPEED * 0.01:
		hvel = Vector3.ZERO
	
	if crouch > 0:
		max_speed = MAX_SPEED * 0.3
	elif is_sprinting:
		max_speed = MAX_SPEED * 3
	else:
		max_speed = MAX_SPEED
	
	var speed = hvel.dot(dir)
	var accel : float = clamp(max_speed - speed, 0.0, MAX_ACCEL * delta)
	hvel += dir * accel
	
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	move_and_slide()
	
func handle_sprint() -> bool:
	if Input.is_action_pressed("sprint") and is_on_floor():
		return true
	
	if not Input.is_action_pressed("sprint") and is_on_floor():
		return false
		
	if is_sprinting and not is_on_floor():
		return true
		
	return false
	
func handle_crouch(delta) -> void:
	if not is_on_floor():
		return
		
	crouch = float(Input.is_action_pressed("crouch")) * 0.5
	height = lerp(height, clamp(1.0 - crouch, 0.5, 1.0), delta * 10.0)
	$mesh_col.shape.height = 2 * height
	$head.global_transform.origin = global_transform.origin + Vector3.UP * height
	
