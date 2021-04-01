extends KinematicBody

export (int) var gravity = 30
export (int) var jump_speed = 10
export (int) var walk_speed = 3 # m/s
export (int) var sprint_speed = 8 # m/s
export (float, 0, 1.0) var acceleration = 0.25
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 0.1) var mouse_sensetivity = 0.002

var velocity = Vector3()
var is_sprinting = false
var is_jumping = false

var SPEED = {
	walk = 1.389,
	combat_pace_slow = 3.056,
	combat_pace_fast = 3.889,
	sprint = 5
}
var state = ["combat_pace_fast"]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var direction = _process_input()
	var speed = SPEED[get_state()]
	
	if direction.x == 0:
		velocity.x = lerp(velocity.x, 0, friction)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
	
	if direction.z == 0:
		velocity.z = lerp(velocity.z, 0, friction)
	else:
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	
	if is_on_floor():
		if is_jumping:
			velocity.y += jump_speed
			is_jumping = false
	else:
		velocity.y -= gravity * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)

func _process_input():
	var direction = Vector3()
	
	#is_sprinting = Input.is_action_pressed("sprint")
	is_jumping = Input.is_action_pressed("ui_accept")
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * transform.basis.x
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * transform.basis.z
	
	if Input.is_action_just_pressed("sprint"):
		set_state("sprint")
	elif Input.is_action_just_released("sprint"):
		state.pop_front()
	elif Input.is_action_just_pressed("walk_toggle"):
		if get_state() == "walk":
			set_state("combat_pace_fast")
		else:
			set_state("walk")
	
	return direction.normalized()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensetivity)
		$Head.rotate_x(-event.relative.y * mouse_sensetivity)
		$Head.rotation.x = clamp($Head.rotation.x, -1.2, 1.2)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("fire_secondary"):
		$Head/Weapon.view_ads()
		$Head/Camera.fov = 50
	elif event.is_action_released("fire_secondary"):
		$Head/Weapon.view_default()
		$Head/Camera.fov = 90

func get_state():
	return state.front()

func set_state(new_state):
	var current_state = get_state()
	
	if new_state == current_state:
		return
	elif new_state == "sprint":
		state.push_front("sprint")
	else:
		state[0] = new_state


