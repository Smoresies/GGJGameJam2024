class_name FencingEnemyController
extends CharacterBody2D

@export_category("Character Speed Controls")
@export var GROUND_SPEED = 400
@export var STOP_SPEED = 300

@export var FENCING_LUNGE_COOLDOWN = .5
@export var FENCING_LUNGE_SPEED = 650
@export var FENCING_LUNGE_ARM_OFFSET = 15
@export var FENCING_HOP_SPEED = 125

@export var STUNNED_COOLDOWN = 2

@export var GRAVITY_MUL = 1.9
@export var GRAVITY_RAMP = 500
@export var GRAVITY_MIN = 1.0

@export var FLY_ANIMATION = "TestFlyAnimation"
@export var IDLE_ANIMATION = "TestIdleAnimation"
@export var FLUTTER_ANIMATION = "TestIdleAnimation"
@export var FENCING_ANIMATION = "TestIdleAnimation"
@export var FALL_ANIMATION = "TestIdleAnimation"
@export var STUNNED_ANIMATION = "TestStunnedAnimation"

@export var _player = Node2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _arm = $Arm


enum STATES {
	STUNNED,
	FENCING,
}

var _state = STATES.FENCING
var _state_timer = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _get_gravity(y_vel):
	return GRAVITY_MUL * gravity * (GRAVITY_MIN + 1 - clamp(GRAVITY_RAMP - abs(y_vel), 0, GRAVITY_RAMP) / GRAVITY_RAMP)
	
func _process(_delta):
	# update body
	_animated_sprite.flip_h = (_player.position.x - position.x < 0)
	
func _slide_feather(_delta, timer):
	# slide the feather up and down for fencing
	_arm.rotation = int(_player.position.x < position.x) * PI
	  
func _get_movement():
	return randi_range(-1, 1) * int(not randi_range(0,150))
	
func _get_lunge():
	return abs(_player.position.x - position.x) < 200 and randf() < .01
	
func _set_state_stunned():
	_set_state()
	_animated_sprite.play(STUNNED_ANIMATION)
	_state = STATES.STUNNED

func _set_state_jousting():
	_set_state()
	_animated_sprite.play(FENCING_ANIMATION)
	_state = STATES.FENCING
	
func _set_state():
	_state_timer = 0
	_arm.position.x = 0
	_arm.position.y = 0
	_animated_sprite.stop()
	
	
func _process_state_stunned(delta):
	if _state_timer > STUNNED_COOLDOWN:
		_set_state_jousting()
		return
	
	_arm.rotation_degrees = 270

func _process_state_fencing(delta):
	_slide_feather(delta, _state_timer)
	
	velocity.y += _get_gravity(velocity.y) * delta
	
	var xinput = _get_movement()
	if is_on_floor():
		_arm.position.x = 0
		if xinput and _state_timer > FENCING_LUNGE_COOLDOWN * .5:
			velocity.x = xinput * GROUND_SPEED
			velocity.y -= FENCING_HOP_SPEED
			_state_timer = 0
	
		elif _get_lunge() and _state_timer > FENCING_LUNGE_COOLDOWN:
			# lunge
			var facing_dir = sign(_player.position.x - position.x)
			velocity.x = facing_dir * FENCING_LUNGE_SPEED
			velocity.y -= FENCING_HOP_SPEED
			_arm.position.x = FENCING_LUNGE_ARM_OFFSET * facing_dir
			_state_timer = 0
			
		else:
			velocity.x = move_toward(velocity.x, 0, STOP_SPEED)
		
func _physics_process(delta):
	_state_timer += delta
	
	if _state == STATES.FENCING:
		_process_state_fencing(delta)
	elif _state == STATES.STUNNED:
		_process_state_stunned(delta)

	move_and_slide()

func _on_area_2d_area_entered(area):
	_set_state_stunned()
	print("enemy weapon hit")
