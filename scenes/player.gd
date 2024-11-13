extends CharacterBody2D
class_name PlayerCharacter

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_dying_player = false

const last_player_action_before_death = {"movement_dir": Vector2.ZERO, "pos": Vector2.ZERO, "pos_records": []}
static var player_death_records = [] 

var player_pos_records = []

@export var player_corpse : PackedScene
@export var delete_potential : bool = true

@onready var player_collision = $CollisionShape2D

static var death_counter = 0

signal player_die

#If the player has already won, they won't be able to move.
func _physics_process(delta: float) -> void:
	
	#Player cannot move if they already won or is holding mirror.
	if GameStage.player_has_won or GameStage.holding_mirror:
		return
	
	#var motion := Vector2()
	#
	#motion.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	#motion.y = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	#
	velocity = get_motion().normalized() * SPEED

	move_and_slide()
	
	if get_slide_collision_count() > 0:
		check_collide_box(get_motion())
	
func check_collide_box(motion: Vector2):
	if abs(motion.x) + abs(motion.y) > 1:
		return
		
	var box := get_slide_collision(0).get_collider() as BoxObject
	
	if box:
		var direction_to_box = self.position.direction_to(box.position).round()
		if motion.normalized() == direction_to_box:
			box.push(motion.normalized() * SPEED * 1.5)

#When the player dies, record the death position then destroy this, then create a corpse and record the death information in it.
func die():
	death_counter += 1
	is_dying_player = true
	await get_tree().create_timer(0.01).timeout
	player_die.emit()
	
	var self_pos = self.position
	var new_corpse = player_corpse.instantiate()
	new_corpse.position = self_pos
	
	#There is a small delay so the corpse doesn't get spawned before the player is removed. We also make it so the player, for a split moment on death, stops colliding.
	player_collision.set_deferred("disabled", true)
	await get_tree().create_timer(0.01).timeout
	get_parent().add_child(new_corpse)
	await get_tree().create_timer(0.01).timeout
	
	queue_free()

func record_death():
	#Only record to the death is it's the dying player doing the recording.
	if is_dying_player:
		var new_entry = last_player_action_before_death.duplicate()
		
		new_entry["movement_dir"] = get_motion()
		new_entry["pos"] = position
		new_entry["pos_records"] = player_pos_records.duplicate()
		
		player_death_records.append(new_entry)
		
	else:
		player_pos_records.append(position)
	#Otherwise, just record the position to self's records instead.

func restore_latest_death_state():
	if player_pos_records.is_empty():
		queue_free()
	else:
		position = player_pos_records.pop_back()

func get_motion():
	
	var motion : Vector2
	motion.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	motion.y = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	return motion
