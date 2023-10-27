extends KinematicBody2D
const TYPE = "SpaceCadet"
export (int) var speed = 300
export (int) var jumpSpeed = -350
export (int) var gravity = 2000
export (int) var DOWN = 250
export (float, 0, 1.0) var friction = 0.25
export (float, 0, 1.0) var acceleration = 0.15


var diamondCount = 0
var velocity = Vector2.ZERO
var dashed = true
var climbing = false
var hookable = true
onready var timer = get_node("Timer")
onready var _animation_player = $AstroSprite/AnimationPlayer



func gravity(delta):
	velocity.y += gravity * delta	
	
	
func get_input():
	var dir = 0
	if Input.is_action_pressed("right"):
		_animation_player.play('walk')
		$AstroSprite.flip_h = false
		dir += 1
	if Input.is_action_pressed("left"):
		_animation_player.play('walk')
		$AstroSprite.flip_h = true
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		if is_on_floor() and (_animation_player.current_animation != "landing"):
			velocity.x = lerp(velocity.x, 0, friction)
			_animation_player.play('idle')
		
func climb(delta):
	if Input.is_action_pressed("climb"):
		velocity.y = 0
		climbing = true
		if Input.is_action_pressed("up"):
			velocity.y = -200
		elif Input.is_action_pressed("down"):
			velocity.y = 200
	elif not Input.is_action_pressed("climb"):
		climbing = false
		gravity(delta)

func dash():
	if Input.is_action_pressed("right"):
		if Input.is_action_pressed("up"):
			velocity.x = 700
			velocity.y = -500
		elif Input.is_action_pressed("down"):
			velocity.x = 700
			velocity.y = 500
		else:
			velocity.x = 1500
	elif Input.is_action_pressed("left"):
		if Input.is_action_pressed("up"):
			velocity.x = -700
			velocity.y = -500
		elif Input.is_action_pressed("down"):
			velocity.x = -700
			velocity.y = 500
		else:
			velocity.x = -1500
	elif Input.is_action_pressed("down"):
		velocity.y = 600
	else:
		velocity.y = -600

func _physics_process(delta):
	
	if is_on_wall():
		climb(delta)
	elif not climbing:
		gravity(delta)
	get_input()
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		dashed = false
	if Input.is_action_just_pressed("dash"):
		if !dashed:
			dashed = true
			dash()
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jumpSpeed
			
	if not is_on_floor():
		if velocity.y <= 0:
			if velocity.x == 0:
				_animation_player.play("jump")
			else:
				_animation_player.play("jumpForward")
		elif velocity.y > 0:
			if velocity.x == 0:
				_animation_player.stop()
				_animation_player.play("fall")
			else:
				_animation_player.stop()
				_animation_player.play("fallForward")
		
		var was_on_floor = is_on_floor() 
		
		var was_in_air = not is_on_floor()
		
		velocity = move_and_slide(velocity,Vector2.UP)
		
		var just_landed = is_on_floor() and was_in_air
		
		if just_landed:
			_animation_player.play("landing")
		
	#if Input.is_action_pressed("dash") and Input.is_action_pressed("right"):
	#	velocity.x = RUN + SPEED
	#if Input.is_action_pressed("dash") and Input.is_action_pressed("left"):
	#	velocity.x = -RUN + -SPEED
		#print(position)
		hook()
		update()
		if hooked:
			gravity(delta)
			swing(delta)
			velocity *= 0.8 #speed of swing
			velocity = move_and_slide(velocity)

	if Input.is_action_pressed("down"):
		if not climbing:
			velocity.y = velocity.y + DOWN
	velocity = move_and_slide(velocity, Vector2.UP)
		
	velocity.x = lerp(velocity.x, 0, friction)

func _on_DeadZone_body_entered(_body):
	print("deadzone")
	print(position)
	get_tree().reload_current_scene()

var hook_pos = Vector2()
var hooked = false
var rope_length = 500
var current_rope_length = rope_length

func _ready(): 
	current_rope_length = rope_length

func hook():
	if hookable == true:
		
		$Raycast.look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("left_click"):
			hook_pos = get_hook_pos()
			if hook_pos:
				hooked = true
				current_rope_length = global_position.distance_to(hook_pos)
				
		if Input.is_action_just_released("left_click") and hooked:
			if hooked == true:
				hookable = false
				timer.start()
			hooked = false

func get_hook_pos():
	for rayCast in $Raycast.get_children():
		if rayCast.is_colliding():
			return rayCast.get_collision_point()
			
	
func swing(delta):
	var radius = global_position - hook_pos
	if velocity.length() < 0.01 or radius.length() < 10: return
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var rad_vel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_vel
	
	if global_position.distance_to(hook_pos) > current_rope_length:
		global_position = hook_pos + radius.normalized() * current_rope_length
	velocity += (hook_pos - global_position).normalized() * 15000 * delta
		

func _draw():
	var pos = global_position
	
	if hooked:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(0.35, 0.7, 0.9), 3, true)
	else:
		return
		
		var colliding = $Raycast.is_colliding()
		var collide_point = $Raycast.get_collision_point()
		if colliding and pos.distance_to(collide_point) < rope_length:
			draw_line(Vector2(0, 0), to_local(collide_point), Color(0, 0, 0, 0.25), 0.5, true)
		


func _on_Timer_timeout():
	hookable = true

func _on_NextArea_body_entered(body):
	get_tree().change_scene("res://Cave Planet.tscn")
	print("Player went to next world")

func _on_Area2D_body_entered(body):
	if body.is_in_group("death"):
		print("Player died")
		get_tree().reload_current_scene()
	if body.is_in_group("ice"):
		friction = 0.1
	elif body.is_in_group("ground"):
		friction = 0.25

func add_diamond():
	print("Diamond collected")
	diamondCount = diamondCount + 1

