class_name PlayerController
extends CharacterBody2D

@export_category("Character Speed Controls")
@export var GROUND_SPEED = 400
@export var STOP_SPEED = 300
@export var AIR_ACCEL = 200
@export var AIR_DECEL = 2000
@export var FLAP_FORCE = 2500
@export var FLAP_GRAVITY_MOD = .7

@export var FENCING_LUNGE_COOLDOWN = .5
@export var FENCING_LUNGE_SPEED = 650
@export var FENCING_HOP_SPEED = 125

@export var MIN_GUST_SPEED = 8
@export var MAX_GUST_SPEED = 20

@export var JUMP_VELOCITY = -800
@export var MAX_SPEED = 1000

@export var FLAP_COOLDOWN = 2
@export var ARM_SPEED_BUFFER = 10

@export var GRAVITY_MUL = 1.9
@export var GRAVITY_RAMP = 300
@export var GRAVITY_MIN = 1.0

@export var FLY_ANIMATION = "TestFlyAnimation"
@export var IDLE_ANIMATION = "TestIdleAnimation"
@export var FLAP_ANIMATION = "TestIdleAnimation"
@export var FENCING_ANIMATION = "TestFencingAnimation"
@export var FALL_ANIMATION = "TestFencingAnimation"

@export var _gust_pool : Node

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _arm = $Arm


enum STATES {
	GROUNDED,
	JUMPING,
	FALLING,
	FLAPPING,
	FENCING,
}

var _state = STATES.GROUNDED
var _state_timer = 0

var _ave_arm_speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _get_gravity(y_vel):
	return GRAVITY_MUL * gravity * (GRAVITY_MIN + 1 - clamp(GRAVITY_RAMP - abs(y_vel), 0, GRAVITY_RAMP) / GRAVITY_RAMP)
	
func _process(delta):
	# update body
	_animated_sprite.flip_h = (get_global_mouse_position().x - position.x < 0)
	
func _rotate_feather(delta):
	# rotate the feather about the shoulder
	var angle_diff = _arm.get_angle_to(get_global_mouse_position())
	_arm.rotation += angle_diff
	_ave_arm_speed = (_ave_arm_speed * ARM_SPEED_BUFFER + abs(angle_diff) / delta) / (ARM_SPEED_BUFFER + 1)
	
func _slide_feather(delta):
	# slide the feather up and down for fencing
	_arm.rotation = int(get_global_mouse_position().x < position.x) * PI
	_arm.position.y = clamp((get_global_mouse_position().y - position.y), -30, 30)

func _set_state_grounded():
	print("grounded")
	_animated_sprite.stop()
	_animated_sprite.play(IDLE_ANIMATION)
	_state = STATES.GROUNDED
	_state_timer = 0

func _set_state_jumping():
	print("jumping")
	_animated_sprite.stop()
	_animated_sprite.play(FLY_ANIMATION)
	_state = STATES.JUMPING
	_state_timer = 0
	
func _set_state_falling():
	print("falling")
	_animated_sprite.stop()
	_animated_sprite.play(FALL_ANIMATION)
	_state = STATES.FALLING
	_state_timer = 0
	
func _set_state_flapping():
	if _state == STATES.FLAPPING:
		return
	print("flapping")
	_animated_sprite.stop()
	_animated_sprite.play(FLAP_ANIMATION)
	_state = STATES.FLAPPING
	_state_timer = 0
	
func _set_state_jousting():
	print("jousting")
	_animated_sprite.stop()
	_animated_sprite.play(FENCING_ANIMATION)
	_state = STATES.FENCING
	_state_timer = 0
	
func _process_arm(delta):
	if MIN_GUST_SPEED < _ave_arm_speed and _ave_arm_speed < MAX_GUST_SPEED:
		var arm_direction = Vector2.from_angle(_arm.rotation)
		velocity -= arm_direction * FLAP_FORCE * delta
		_set_state_flapping()

func _process_state_grounded(delta):
	if not is_on_floor():
		_set_state_jumping()
		return
		
	# Handle jump.
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		_set_state_jumping()
	
	# Get the input direction and handle the movement/deceleration.
	var xinput = Input.get_axis("left", "right")
	if xinput:
		velocity.x = xinput * GROUND_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
		
	_rotate_feather(delta)
	_process_arm(delta)
	
func _process_state_jumping(delta):
	_rotate_feather(delta)
	_process_arm(delta)
	if is_on_floor():
		_set_state_grounded()
		return
	
	# Add gravity.
	velocity.y += _get_gravity(velocity.y) * delta
	
	# Get the input direction and handle the movement/deceleration.
	var xinput = Input.get_axis("left", "right")
	if xinput:
		if sign(velocity.x) != sign(xinput):
			velocity.x += xinput * AIR_DECEL * delta
		else:
			velocity.x += xinput * AIR_ACCEL * delta
		
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED
	if velocity.y < -MAX_SPEED:
		velocity.y = -MAX_SPEED
	
func _process_state_flapping(delta):
	if is_on_floor():
		_set_state_grounded()
		return
	if _state_timer > FLAP_COOLDOWN:
		_set_state_falling()
		return
	velocity.y += _get_gravity(velocity.y) * delta * FLAP_GRAVITY_MOD
	_rotate_feather(delta)
	_process_arm(delta)
	
func _process_state_falling(delta):
	if is_on_floor():
		_set_state_grounded()
		return
	velocity.y += _get_gravity(velocity.y) * delta
	_rotate_feather(delta)
	
func _process_state_fencing(delta):
	
	_slide_feather(delta)
	
	velocity.y += _get_gravity(velocity.y) * delta
	
	var xinput = Input.get_axis("left", "right")
	if is_on_floor():
		if xinput and _state_timer > FENCING_LUNGE_COOLDOWN * .5:
			velocity.x = xinput * GROUND_SPEED
			velocity.y -= FENCING_HOP_SPEED
			_state_timer = 0
	
		elif Input.is_action_pressed("jump") and _state_timer > FENCING_LUNGE_COOLDOWN:
			# lunge
			velocity.x = sign(get_global_mouse_position().x - position.x) * FENCING_LUNGE_SPEED
			velocity.y -= FENCING_HOP_SPEED
			_state_timer = 0
			
		else:
			velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
		

func _physics_process(delta):
	_state_timer += delta
	
	if _state == STATES.GROUNDED:
		_process_state_grounded(delta)
		
	elif _state == STATES.JUMPING:
		_process_state_jumping(delta)
		
	elif _state == STATES.FALLING:
		_process_state_falling(delta)
		
	elif _state == STATES.FLAPPING:
		_process_state_flapping(delta)
		
	elif _state == STATES.FENCING:
		_process_state_fencing(delta)

	move_and_slide()


