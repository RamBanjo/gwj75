extends CharacterBody2D
class_name PlayerCharacter

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_dying_player = false

const last_player_action_before_death = {"movement_dir": Vector2.ZERO, "pos": Vector2.ZERO, "pos_records": []}
static var player_death_records = []
static var corpse_list : Array[PlayerCorpse] = []

const alive_player_action_on_death = {"movement_dir": Vector2.ZERO, "pos": Vector2.ZERO}
var alive_player_records = []

@export var player_corpse : PackedScene
@export var delete_potential : bool = true

@onready var player_collision = $CollisionShape2D
@onready var anim_sprite = $Sprite2D

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
	
	var current_motion = get_motion()
	update_animation(current_motion)
	
	velocity = current_motion.normalized() * SPEED
	
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		check_collide_box(get_motion())

func update_animation(motion: Vector2):
	
	var animation = "one_frame"
	
	if motion.x > 0:
		animation = "right"
	elif motion.x < 0:
		animation = "left"
	elif motion.y < 0:
		animation = "up"
	elif motion.y > 0:
		animation = "idle_and_down"
		
	if anim_sprite.animation != animation:
		anim_sprite.play(animation)
			
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
	
	#If the player is already dying elsewhere, this prevents them from dying two times at once.
	if is_dying_player or not GameStage.current_scene_instance:
		return
	
	
	is_dying_player = true
	GameStage.current_scene_instance.sound_player.play_death_sound()
	
	await get_tree().create_timer(0.01).timeout
	
	death_counter += 1
	player_die.emit()
	
	var self_pos = self.position
	var new_corpse = player_corpse.instantiate()
	new_corpse.position = self_pos
	
	for corpse in corpse_list:
		corpse.undo_hint_sprite.hide()
	
	corpse_list.append(new_corpse)
	
	#There is a small delay so the corpse doesn't get spawned before the player is removed. We also make it so the player, for a split moment on death, stops colliding.
	player_collision.set_deferred("disabled", true)
	await get_tree().create_timer(0.01).timeout
	get_parent().add_child(new_corpse)
	new_corpse.undo_hint_sprite.show()
	new_corpse.undo_hint_sprite.scale = (Vector2.ONE / GameStage.current_scene_instance.camera.zoom) * 0.5
	
	if get_motion().x >0:
		new_corpse.face_right()
	else:
		new_corpse.face_left()
	
	await get_tree().create_timer(0.01).timeout
	
	queue_free()

func record_death():
	#Only record to the death is it's the dying player doing the recording.
	if is_dying_player:
		var new_entry = last_player_action_before_death.duplicate()
		
		new_entry["movement_dir"] = get_motion()
		new_entry["pos"] = position
		new_entry["pos_records"] = alive_player_records.duplicate()
		
		player_death_records.append(new_entry)
		
	else:
		var new_entry = alive_player_action_on_death.duplicate(true)
		
		new_entry["movement_dir"] = get_motion()
		new_entry["pos"] = position
		
		alive_player_records.append(new_entry)
	#Otherwise, just record the position to self's records instead.

func restore_latest_death_state():
	if alive_player_records.is_empty():
		queue_free()
	else:
		var pos_info = alive_player_records.pop_back()
		#print(pos_info)
		#position = pos_info["pos"] + (pos_info["movement_dir"] * -64)
		if GameStage.current_scene_instance:
			if not GameStage.current_scene_instance.test_if_position_overlaps_unspawnable_position(pos_info["pos"]):
				position = pos_info["pos"] + (pos_info["movement_dir"] * GameStage.player_spawn_leniency * -1)
			else:
				position = GameStage.get_current_scene_closest_spawnable_position(pos_info["pos"], pos_info["movement_dir"] *-1)
		else:
			position = pos_info["pos"] + (pos_info["movement_dir"] * GameStage.player_spawn_leniency * -1)

func get_motion() -> Vector2:
	
	var motion : Vector2
	motion.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	motion.y = (Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	return motion

static func reset_death_records():
	player_death_records.clear()
	death_counter = 0
	corpse_list.clear()
