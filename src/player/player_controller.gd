class_name PlayerController
extends CharacterBody2D

@export_category("Character Speed Controls")
@export var GROUND_SPEED = 400
@export var STOP_SPEED = 300
@export var AIR_ACCEL = 1000
@export var AIR_DECEL = 2000
@export var FLUTTER_FORCE = 2500
@export var FLUTTER_GRAVITY_MOD = .7

@export var FENCING_LUNGE_COOLDOWN = .5
@export var FENCING_LUNGE_SPEED = 650
@export var FENCING_LUNGE_ARM_OFFSET = 15
@export var FENCING_HOP_SPEED = 125

@export var MIN_GUST_SPEED = 8
@export var MAX_GUST_SPEED = 30

@export var JUMP_VELOCITY = -800
@export var MAX_SPEED = 600

@export var ASSISTED_FLUTTER_HANDICAP = .3
@export var FLUTTER_COOLDOWN = 2.0
@export var ARM_SPEED_BUFFER = 10

@export var GRAVITY_MUL = 1.9
@export var GRAVITY_RAMP = 500
@export var GRAVITY_MIN = 1.0

@export var FLY_ANIMATION = "TestFlyAnimation"
@export var IDLE_ANIMATION = "TestIdleAnimation"
@export var FLUTTER_ANIMATION = "TestIdleAnimation"
@export var FENCING_ANIMATION = "TestIdleAnimation"
@export var FALL_ANIMATION = "TestIdleAnimation"

@export var _fencing_enemy = Node2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _arm = $Arm


enum STATES {
	GROUNDED,
	JUMPING,
	FALLING,
	FLUTTERING,
	FENCING,
}

var _state = STATES.GROUNDED
var _state_timer = 0

var _ave_arm_speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _get_gravity(y_vel):
	return GRAVITY_MUL * gravity * (GRAVITY_MIN + 1 - clamp(GRAVITY_RAMP - abs(y_vel), 0, GRAVITY_RAMP) / GRAVITY_RAMP)
	
func _process(_delta):
	# update body
	_animated_sprite.flip_h = (get_global_mouse_position().x - position.x < 0)
	
func _rotate_feather(delta, timer):
	# rotate the feather about the shoulder
	var angle_diff = _arm.get_angle_to(get_global_mouse_position())
	_arm.rotation += angle_diff + int(Input.is_action_pressed("flutter")) * .6 * sin(timer * 50)
	_ave_arm_speed = (_ave_arm_speed * ARM_SPEED_BUFFER + abs(angle_diff) / delta) / (ARM_SPEED_BUFFER + 1)
	
func _slide_feather(_delta, timer):
	# slide the feather up and down for fencing
	_arm.rotation = int(get_global_mouse_position().x < position.x) * PI
	_arm.position.y = clamp((get_global_mouse_position().y - position.y), -30, 30) 
	_arm.position.y += 2 * sin(timer*6)
	
func _clamp_speed():
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED

func _set_state_grounded():
	_set_state()
	_animated_sprite.play(IDLE_ANIMATION)
	_state = STATES.GROUNDED

func _set_state_jumping():
	_set_state()
	_animated_sprite.play(FLY_ANIMATION)
	_state = STATES.JUMPING
	
func _set_state_falling():
	_set_state()
	_animated_sprite.play(FALL_ANIMATION)
	_state = STATES.FALLING
	
func _set_state_fluttering():
	if _state == STATES.FLUTTERING:
		return
	_set_state()
	_animated_sprite.play(FLUTTER_ANIMATION)
	_state = STATES.FLUTTERING
	
func _set_state_jousting():
	_set_state()
	_animated_sprite.play(FENCING_ANIMATION)
	_state = STATES.FENCING
	
func _set_state():
	_state_timer = 0
	_arm.position.x = 0
	_arm.position.y = 0
	_animated_sprite.stop()
	
func _process_arm(delta):
	if MIN_GUST_SPEED < _ave_arm_speed and _ave_arm_speed < MAX_GUST_SPEED:
		var arm_direction = Vector2.from_angle(_arm.rotation)
		if velocity.y > 0:
			velocity.y  *= .1
		velocity -= arm_direction * FLUTTER_FORCE * delta
		_set_state_fluttering()

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
		
	_rotate_feather(delta, _state_timer)
	_process_arm(delta)
	
func _process_state_jumping(delta):
	_rotate_feather(delta, _state_timer)
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
		
	_clamp_speed()
	
func _process_state_fluttering(delta):
	if is_on_floor():
		_set_state_grounded()
		return
	if _state_timer > FLUTTER_COOLDOWN:
		_set_state_falling()
		return
		
	# Get the input direction and handle the movement/deceleration.
	var xinput = Input.get_axis("left", "right")
	if xinput:
		if sign(velocity.x) != sign(xinput):
			velocity.x += xinput * AIR_DECEL * delta
		else:
			velocity.x += xinput * AIR_ACCEL * delta
		
	velocity.y += _get_gravity(velocity.y) * delta * FLUTTER_GRAVITY_MOD
	_rotate_feather(delta, _state_timer)
	_process_arm(delta)
	
	_clamp_speed()
	if velocity.y < -MAX_SPEED:
		velocity.y = -MAX_SPEED
	
func _process_state_falling(delta):
	if is_on_floor():
		_set_state_grounded()
		return
	velocity.y += _get_gravity(velocity.y) * delta
	_rotate_feather(delta, _state_timer)
	
func _process_state_fencing(delta):
	_slide_feather(delta, _state_timer)
	
	velocity.y += _get_gravity(velocity.y) * delta
	
	var xinput = Input.get_axis("left", "right")
	if is_on_floor():
		_arm.position.x = 0
		if xinput and _state_timer > FENCING_LUNGE_COOLDOWN * .8:
			velocity.x = xinput * GROUND_SPEED
			velocity.y -= FENCING_HOP_SPEED
			_state_timer = FENCING_LUNGE_COOLDOWN * .3
	
		elif Input.is_action_pressed("jump") and _state_timer > FENCING_LUNGE_COOLDOWN:
			# lunge
			var facing_dir = sign(get_global_mouse_position().x - position.x)
			velocity.x = facing_dir * FENCING_LUNGE_SPEED
			velocity.y -= FENCING_HOP_SPEED
			_arm.position.x = FENCING_LUNGE_ARM_OFFSET * facing_dir
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
		
	elif _state == STATES.FLUTTERING:
		_process_state_fluttering(delta)
		
	elif _state == STATES.FENCING:
		_process_state_fencing(delta)

	move_and_slide()


func _on_area_2d_area_entered(area):
	print("player weapon hit")
