extends KinematicBody2D

var motion = Vector2()
var speed = 1000
var number_of_jumps = 5
var jump_counter
var can_double_jump


const GRAVITY = 100
const UP = Vector2(0, -1)
const JUMP_SPEED = 2000
const HEIGHT_BOUNDARY = 10000
const SLOWNESS_MODIFIER = 0.7



func _physics_process(delta):
	apply_gravity()
	wall_run()
	move()
	jump()
	animate()
	move_and_slide(motion, UP)
	lose()

func move():
	if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		motion.x = -speed
		$Sprite.flip_h = true
	elif Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		motion.x = speed
		$Sprite.flip_h = false
	else:
		motion.x = 0


func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		can_double_jump = false
		jump_counter = 1
		motion.y -= JUMP_SPEED
		$JumpTimer.start()
	if Input.is_action_just_pressed("jump") and not jump_counter == number_of_jumps and can_double_jump:
		can_double_jump = false
		motion.y = 0
		motion.y -= JUMP_SPEED
		jump_counter += 1
		$JumpTimer.start()


func wall_run():
	if is_on_wall():
		motion.y = GRAVITY / SLOWNESS_MODIFIER
		if jump_counter == number_of_jumps:
			jump_counter = number_of_jumps - 1
		if $Sprite.is_flipped_h():
			if Input.is_action_just_pressed("jump"):
				motion.x = JUMP_SPEED
		elif not $Sprite.is_flipped_h():
			if Input.is_action_just_pressed("jump"):
				motion.x = -JUMP_SPEED


func apply_gravity():
	if is_on_floor() and motion.y > 0:
		motion.y = GRAVITY
	elif is_on_ceiling():
		motion.y = 1
	else:
		motion.y += GRAVITY


func animate():
	var animation = $AnimationPlayer.get_current_animation()
	if motion.y < 0:
		$AnimationPlayer.play("Jump")
	elif not animation == "Jump" and motion.x > 0:
		$AnimationPlayer.play("Run")
	elif not animation == "Jump" and motion.x < 0:
		$AnimationPlayer.play("Run")
	else:
		$AnimationPlayer.play("Idle")


func lose():
	if position.y > HEIGHT_BOUNDARY:
		get_tree().reload_current_scene()


func _on_JumpTimer_timeout():
	can_double_jump = true
