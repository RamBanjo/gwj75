extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	
	var motion := Vector2()
	
	motion.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	motion.y = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	
	velocity = motion.normalized() * SPEED

	move_and_slide()
	
	if get_slide_collision_count() > 0:
		check_collide_box(motion)
	
func check_collide_box(motion: Vector2):
	if abs(motion.x) + abs(motion.y) > 1:
		return
		
	var box := get_slide_collision(0).get_collider() as BoxObject
	
	
	if box:
		
		var direction_to_box = self.position.direction_to(box.position).round()
		if motion.normalized() == direction_to_box:
			box.push(motion.normalized() * SPEED * 0.95)
