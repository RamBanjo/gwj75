extends BoxObject

@export var is_corpse : bool = false
@export var delete_potential : bool = true

const SPEED = 300.0
func push(motion : Vector2) -> void:
	
	velocity = motion
	move_and_slide()
	check_collide_box(motion)

func _physics_process(delta: float) -> void:
	pass

func check_collide_box(motion: Vector2):
	
	if get_last_slide_collision() == null:
		return
	
	var box := get_slide_collision(0).get_collider() as BoxObject
	
	if box:
		var direction_to_box = self.position.direction_to(box.position).round()
		if motion.normalized() == direction_to_box:
			box.push(motion.normalized() * SPEED * 1.5)	
	
	pass
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
