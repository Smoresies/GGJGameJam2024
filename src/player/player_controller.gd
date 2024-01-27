class_name PlayerController
extends CharacterBody2D

@export_category("Character Speed Controls")
@export var GROUND_SPEED = 400
@export var LUNGE_FORCE = -50
@export var STOP_SPEED = 300
@export var AIR_ACCEL = 200
@export var AIR_DECEL = 2000
@export var FLAP_FORCE = 2500

@export var MIN_GUST_SPEED = 8
@export var MAX_GUST_SPEED = 20
@export var GUST_SPEED = 300
@export var ARM_LENGTH = 50

@export var JUMP_VELOCITY = -800
@export var MAX_SPEED = 1000

@export var FLAP_COOLDOWN = .1
@export var ARM_SPEED_BUFFER = 10

@export var GRAVITY_MUL = 1.9
@export var GRAVITY_RAMP = 300
@export var GRAVITY_MIN = 1.0

@export var FLY_ANIMATION = "TestFlyAnimation"
@export var IDLE_ANIMATION = "TestIdleAnimation"
@export var FLAP_ANIMATION = "TestIdleAnimation"
@export var FENCING_ANIMATION = "TestFencingAnimation"

@export var _gust_pool : Node

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _arm = $Arm


enum STATES {
	GROUNDED,
	JUMPING,
	FLAPPING,
}

var _state = STATES.JUMPING
var _state_timer = 0
var _xinput = 0

var _ave_arm_speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _get_gravity(y_vel):
	return GRAVITY_MUL * gravity * (GRAVITY_MIN + 1 - clamp(GRAVITY_RAMP - abs(y_vel), 0, GRAVITY_RAMP) / GRAVITY_RAMP)
	
func _process(delta):
	_xinput = Input.get_axis("left", "right")
	
	# update body
	_animated_sprite.flip_h = (get_global_mouse_position().x - position.x < 0)
	
	# update arm
	var angle_diff = _arm.get_angle_to(get_global_mouse_position())
	_arm.rotation += angle_diff
	
	_ave_arm_speed = (_ave_arm_speed * ARM_SPEED_BUFFER + abs(angle_diff) / delta) / (ARM_SPEED_BUFFER + 1)
	
func _set_state_grounded():
	_animated_sprite.stop()
	_animated_sprite.play(IDLE_ANIMATION)
	_state = STATES.GROUNDED
	_state_timer = 0

func _set_state_jumping():
	_animated_sprite.stop()
	_animated_sprite.play(FLY_ANIMATION)
	_state = STATES.JUMPING
	_state_timer = 0
	
func _set_state_flapping():
	_animated_sprite.stop()
	_animated_sprite.play(FLAP_ANIMATION)
	_state = STATES.FLAPPING
	_state_timer = FLAP_COOLDOWN
	
func _process_arm(delta):
	if MIN_GUST_SPEED < _ave_arm_speed and _ave_arm_speed < MAX_GUST_SPEED:
		var arm_direction = Vector2.from_angle(_arm.rotation)
		velocity -= arm_direction * FLAP_FORCE * delta
		var gust_pos = position + arm_direction * ARM_LENGTH
		var gust_dir = arm_direction * GUST_SPEED
		_gust_pool.spawn(gust_pos, gust_dir)
		return true
	return false

func _process_state_grounded(delta):
	if not is_on_floor():
		_set_state_jumping()
		return
		
	# Handle jump.
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		_set_state_jumping()
	
	# Get the input direction and handle the movement/deceleration.
	if _xinput:
		velocity.x = _xinput * GROUND_SPEED
		#velocity.y = LUNGE_FORCE
	else:
		velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
		
	if _process_arm(delta): # returns true if the player flapped their arm
		_set_state_flapping()
	
func _process_state_jumping(delta):
	if is_on_floor():
		_set_state_grounded()
		return
	
	# Add gravity.
	velocity.y += _get_gravity(velocity.y) * delta
	
	# Get the input direction and handle the movement/deceleration.
	if _xinput:
		if sign(velocity.x) != sign(_xinput):
			velocity.x += _xinput * AIR_DECEL * delta
		else:
			velocity.x += _xinput * AIR_ACCEL * delta
		
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED
	if velocity.y < -MAX_SPEED:
		velocity.y = -MAX_SPEED
	
func _process_state_flapping(delta):
	if is_on_floor():
		_set_state_grounded()
		return
	if _state_timer == 0:
		_set_state_jumping()
		return
	velocity.y += _get_gravity(velocity.y) * delta
	_process_arm(delta)

func _physics_process(delta):
	_state_timer = move_toward(_state_timer, 0, delta)
	
	if _state == STATES.GROUNDED:
		_process_state_grounded(delta)
		
	elif _state == STATES.JUMPING:
		_process_state_jumping(delta)
		
	elif _state == STATES.FLAPPING:
		_process_state_flapping(delta)

	move_and_slide()
