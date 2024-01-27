class_name PlayerController
extends CharacterBody2D

@export_category("Character Speed Controls")
@export var GROUND_SPEED = 400
@export var AIR_SPEED = 0
@export var AIR_ACCEL = 200
@export var STOP_SPEED = 300
@export var JUMP_VELOCITY = -400
@export var FLAP_FORCE = 0
@export var MAX_SPEED = 1000

@export var LAND_COOLDOWN = 0.05
@export var FLAP_COOLDOWN = 1000000
@export var ARM_SPEED_BUFFER = 10

@export var GRAVITY_MUL = 1.9
@export var GRAVITY_RAMP = 300
@export var GRAVITY_MIN = 1.0

@export var FLY_ANIMATION = "testFlyAnimation"
@export var IDLE_ANIMATION = "testIdleAnimation"

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _arm = $Arm


enum STATES {
	GROUNDED,
	JUMPING,
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
	_state_timer = LAND_COOLDOWN

func _set_state_jumping():
	_animated_sprite.stop()
	_animated_sprite.play(FLY_ANIMATION)
	_state = STATES.JUMPING
	_state_timer = FLAP_COOLDOWN
	
func _process_state_jumping(delta):
	if is_on_floor():
		_set_state_grounded()
		return
		
	if Input.is_action_pressed("jump"):
		#velocity = flap_dir.normalized() * FLAP_FORCE
		
		var mouse_diff = get_global_mouse_position() - position
		var mouse_dist = mouse_diff.length()
		var mouse_dir = mouse_diff / mouse_dist
		
		if _state_timer == 0:
			if mouse_dir.y < 0:
				if mouse_dist > 10:
					velocity = mouse_dir * AIR_SPEED
					_state_timer = FLAP_COOLDOWN
			elif mouse_dir.y > .9 and mouse_dist > 100:
				velocity.y += FLAP_FORCE
			else:
				velocity.x = move_toward(velocity.x, sign(mouse_dir.x) * AIR_SPEED, AIR_SPEED)
				_state_timer = FLAP_COOLDOWN
	
	# Add gravity.
	velocity.y += _get_gravity(velocity.y) * delta
	
	# Get the input direction and handle the movement/deceleration.
	if _xinput:
		if sign(velocity.x) != sign(_xinput):
			velocity.x += _xinput * AIR_ACCEL * 10 * delta
		else:
			velocity.x += _xinput * AIR_ACCEL * delta
		
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED

func _process_state_grounded(_delta):
	if not is_on_floor():
		_set_state_jumping()
		return
		
	# Handle jump.
	if Input.is_action_pressed("jump") and _state_timer == 0:
		velocity.y = JUMP_VELOCITY
		_set_state_jumping()
	
	# Get the input direction and handle the movement/deceleration.
	if _xinput:
		velocity.x = _xinput * GROUND_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, STOP_SPEED)

func _physics_process(delta):
	_state_timer = move_toward(_state_timer, 0, delta)
	
	if _state == STATES.GROUNDED:
		_process_state_grounded(delta)
		
	elif _state == STATES.JUMPING:
		_process_state_jumping(delta)
		
	if _ave_arm_speed > 10:
		velocity -= Vector2.from_angle(_arm.rotation) * AIR_ACCEL * delta * 7

	move_and_slide()
