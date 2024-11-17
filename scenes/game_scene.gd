extends Node2D
class_name GameStage

@export var level_index = 0

@onready var win_screen = $WinScreen
@onready var tutorial_canvas = $LevelInfoCanvas
@onready var level_name_label = $LevelInfoCanvas/LevelName
@onready var mirror_effect = $MirrorEffect

@onready var camera : Camera2D = $Camera2D

@onready var sound_player : SoundPlayer = $SoundPlayer

static var player_object = preload("res://scenes/player.tscn")

var current_mirror : MirrorObject = null

const UNLOCKABLE_THINGS_IN_SCENE : Dictionary = {
	UnlockerObject.UnlockColor.RED: [],
	UnlockerObject.UnlockColor.GREEN: [],
	UnlockerObject.UnlockColor.YELLOW: [],
	UnlockerObject.UnlockColor.BLUE: []
}

static var unlockable_things_by_color : Dictionary = {
	UnlockerObject.UnlockColor.RED: [],
	UnlockerObject.UnlockColor.GREEN: [],
	UnlockerObject.UnlockColor.YELLOW: [],
	UnlockerObject.UnlockColor.BLUE: []
}

static var player_has_won = false
static var current_scene_instance : GameStage = null

var hovering_mirror = false
static var holding_mirror : bool = false

static var player_spawn_leniency : float = 32.0

var my_mirrors = []
#
#@export var next_stage : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	get_viewport().canvas_cull_mask = 1
	
	if current_scene_instance == null:
		current_scene_instance = self
	else:
		queue_free()
		
	level_name_label.text = GameOptions.LEVEL_DICTS[level_index]["level_name"]
	#
	#pass
	var unlockers_in_scene = get_tree().get_nodes_in_group("unlocker")
	
	for unlocker in unlockers_in_scene:
		var casted_unlocker = unlocker as UnlockerObject
		
		if casted_unlocker:
			casted_unlocker.toggle_count_changed.connect(_on_unlocker_activated.bind())
			
	var unlockable_in_scene = get_tree().get_nodes_in_group("unlockable")
	
	for unlockable in unlockable_in_scene:
		var casted_unlockable = unlockable as UnlockableObject
		
		if casted_unlockable:
			unlockable_things_by_color[casted_unlockable.my_color].append(casted_unlockable)
			
	var winners_in_scene = get_tree().get_nodes_in_group("victory")
	
	for winner in winners_in_scene:
		
		var casted_winner = winner as VictoryArea
		
		if casted_winner:
			casted_winner.win.connect(_on_player_win.bind())
			
	var players_in_scene = get_tree().get_nodes_in_group("player")

	for player in players_in_scene:
		
		var casted_player = player as PlayerCharacter

		if casted_player:
			casted_player.player_die.connect(_on_player_die.bind())
			
	var mirrors_in_scene = get_tree().get_nodes_in_group("mirror")
	#print(mirrors_in_scene)
	for mirror in mirrors_in_scene:
		#print("pizza")
		var casted_mirror = mirror as MirrorObject
		
		if casted_mirror:
			casted_mirror.recheck_mirrors_request.connect(_on_mirror_movement_detected.bind())
			my_mirrors.append(casted_mirror)
			
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_unlockable_things():
	unlockable_things_by_color = UNLOCKABLE_THINGS_IN_SCENE.duplicate(true)

func _on_unlocker_activated(my_color: UnlockerObject.UnlockColor):
	
	var things_to_toggle = unlockable_things_by_color[my_color]
	
	for thing in things_to_toggle:
		var casted_thing = thing as UnlockableObject
		
		if casted_thing:
			casted_thing.toggle_lock_state()
			
func _on_player_win():
	
	player_has_won = true
	win_screen.show()
	
	if level_index+1 == len(GameOptions.LEVEL_DICTS):
		win_screen.set_final_level_win_text()
	
	if tutorial_canvas:
		tutorial_canvas.hide()
	
	sound_player.stop_bgm()
	sound_player.play_win_sound()
	
func load_next_stage():
	
	if level_index > GameOptions.levels_unlocked:
		GameOptions.levels_unlocked = level_index+1
		GameOptions.save_max_level()
	
	reset_statics_before_load()
	#TODO: Get the Stage Object to switch to from the next stage variable.

	if level_index+1 == len(GameOptions.LEVEL_DICTS):
		#print("don't change scene! go to main menu instead")
		get_tree().change_scene_to_file("res://scenes/game_menu/main_menu.tscn")
	else:
		get_tree().change_scene_to_file(GameOptions.LEVEL_DICTS[level_index+1]["level_path"])

func reset_statics_before_load():
	reset_unlockable_things()
	UnlockerObject.reset_toggle_count()
	PlayerCharacter.reset_death_records()
	player_has_won = false
	current_scene_instance = null
	holding_mirror = false	

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("undo_death") and not player_has_won:
		undo_death()
	if event.is_action_pressed("take_mirror") and (holding_mirror or hovering_mirror):
		toggle_reflect()
	if event.is_action_pressed("restart_level") and not player_has_won:
		restart_level()
	if event.is_action_pressed("toggle_visual_aid") and not player_has_won:
		toggle_visual_aid()
		
func toggle_visual_aid():
	GameOptions.visual_aid = not GameOptions.visual_aid
	#print(GameOptions.visual_aid)
	var visual_aids_in_scene = get_tree().get_nodes_in_group("visual_aid")
	
	for thing in visual_aids_in_scene:
		
		var casted_aid = thing as VisualAid
		#print(casted_aid)
		if casted_aid:
			#print("yay")
			casted_aid.update_text()

func _on_player_die():
	
	#print(PlayerCharacter.death_counter)
	
	var undoable_in_scene = get_tree().get_nodes_in_group("undoable")
	
	for undoable_thing in undoable_in_scene:
		if undoable_thing.has_method("record_death"):
			undoable_thing.record_death()
			#print("Recorded %s on player death" % undoable_thing)
		else:
			pass
			#print("Can't record %s: record_death method not implemented!" % undoable_thing)
			
	UnlockerObject.record_toggle_count()
	
	#Check for spawners in the scene and make them spawn the player if possible.
	var spawners_in_scene = get_tree().get_nodes_in_group("spawner")
	
	for spawner in spawners_in_scene:
		var casted_spawner = spawner as PlayerSpawner
		
		if casted_spawner:
			casted_spawner.spawn_player()

func undo_death():
	#First of all, if there has not been any deaths yet we can't do anything. Return.
	if PlayerCharacter.death_counter <= 0:
		return
	
	#Next, we set the state of each undoable thing on the screen.
	var undoable_in_scene = get_tree().get_nodes_in_group("undoable")
	undoable_in_scene.sort_custom(sort_undoable_by_delete_potential)
	#print(undoable_in_scene)
	
	for undoable_thing in undoable_in_scene:
		if undoable_thing.has_method("restore_latest_death_state"):
			undoable_thing.restore_latest_death_state()
			#print("Restored state of %s on death undo" % undoable_thing)
		else:
			pass
			#print("Can't restore state of %s: restore_latest_death_statedeath method not implemented!" % undoable_thing)
			
	#Get the latest recorded toggle count from the UnlockerObject.
	UnlockerObject.restore_latest_toggle_count()
	#print(UnlockerObject.toggle_count_by_color)
		
	#Spawn the player. They should be 1 tile away from the death position in the direction of the death.
	spawn_player_from_undo()
	
	#Add a small delay so we make sure that the dead corpses are removed before we calculate if the unlockables should be touched or untouched.
	await get_tree().create_timer(0.01).timeout
	
	#After spawning the player, check for unlocker objects if they should be touched or untouched. Since we may have previously freed some corpses, we must get undoables again.
	undoable_in_scene = get_tree().get_nodes_in_group("undoable")
	for undoable_thing in undoable_in_scene:
		var potential_unlocker = undoable_thing as UnlockerObject
		
		if potential_unlocker:
			potential_unlocker.check_touched()
	
	#Finally, reduce the death counter by 1.
	#print(PlayerCharacter.death_counter)
	PlayerCharacter.death_counter -= 1
	PlayerCharacter.corpse_list.pop_back()
	if not PlayerCharacter.corpse_list.is_empty():
		PlayerCharacter.corpse_list[-1].undo_hint_sprite.show()

func sort_undoable_by_delete_potential(lhs : Node2D, rhs : Node2D):	
	if lhs.delete_potential > rhs.delete_potential:
		return true
	else:
		return false

func spawn_player_from_undo():
	var player_death_pos_info = PlayerCharacter.player_death_records.pop_back()
	var new_player_pos : Vector2 = player_death_pos_info["pos"] + (player_death_pos_info["movement_dir"] * GameStage.player_spawn_leniency * -1)
	
	#print(player_death_pos_info)
	var spawn_obstructed = GameStage.current_scene_instance.test_if_position_overlaps_unspawnable_position(new_player_pos)
	print(spawn_obstructed)
	if spawn_obstructed:	
		new_player_pos = get_current_scene_closest_spawnable_position(player_death_pos_info["pos"], player_death_pos_info["movement_dir"] * -1)
	
	var new_player = player_object.instantiate()
	new_player.alive_player_records = player_death_pos_info["pos_records"]
	new_player.player_die.connect(_on_player_die.bind())
	#print(player_death_pos_info)
	#print(new_player_pos)
	new_player.position = new_player_pos
	
	add_child(new_player)
	#print(player_death_pos_info, new_player_pos)

func toggle_reflect():
	holding_mirror = not holding_mirror
	
	set_mirror_effects(holding_mirror)
	
		
func set_mirror_effects(holding_mirror : bool):
	
	camera.zoom.x *= -1
	#print(holding_mirror)
	mirror_effect.visible = holding_mirror
	
	if holding_mirror:
		get_viewport().set_canvas_cull_mask_bit(1, true)
		get_viewport().set_canvas_cull_mask_bit(0, false)
		current_mirror.readjust_sprite(true)
		
	else:
		get_viewport().set_canvas_cull_mask_bit(0, true)
		get_viewport().set_canvas_cull_mask_bit(1, false)
		current_mirror.readjust_sprite(true)
		
	#print(get_viewport().canvas_cull_mask)

func _on_mirror_movement_detected():
	
	for mirror in my_mirrors:
		var casted_mirror = mirror as MirrorObject
		if casted_mirror:
			casted_mirror.readjust_sprite(false)
			
	for mirror in my_mirrors:
		var casted_mirror = mirror as MirrorObject
		
		if casted_mirror:
			if casted_mirror.player_on_mirror_check():
				hovering_mirror = true
				casted_mirror.readjust_sprite(true)
				current_mirror = casted_mirror
				return
							
	hovering_mirror = false
	current_mirror = null

static func get_current_scene_closest_spawnable_position(coords : Vector2, search_direction_relative_to_coord: Vector2, leniency_margin : float = player_spawn_leniency):
	if not current_scene_instance:
		return null
		
	var return_coord = null
	
	var max_x = coords.x + (leniency_margin)
	var max_y = coords.y + (leniency_margin)
	var min_x = coords.x - (leniency_margin)
	var min_y = coords.y - (leniency_margin)
	#print("X Range ({min}, {max})".format({"max": max_x, "min": min_x}))
	#print("Y Range ({min}, {max})".format({"max": max_y, "min": min_y}))
	
	if search_direction_relative_to_coord.x == -1:
		max_x = coords.x + (leniency_margin/2)
	elif search_direction_relative_to_coord.x == 1:
		min_x = coords.x - (leniency_margin/2)		
		
	if search_direction_relative_to_coord.y == -1:
		max_y = coords.y + (leniency_margin/2)
	elif search_direction_relative_to_coord.y == 1:
		min_y = coords.y - (leniency_margin/2)
		
	while return_coord == null:
		var test_pos : Vector2
		test_pos.x = randf_range(min_x, max_x)
		test_pos.y = randf_range(min_y, max_y)
		
		if not current_scene_instance.test_if_position_overlaps_unspawnable_position(test_pos):
			return_coord = test_pos

	return return_coord

func test_if_position_overlaps_unspawnable_position(test_pos : Vector2, print_results : bool = false):
	
	var space_state = get_world_2d().direct_space_state
	
	var test_2dpoint : PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	test_2dpoint.collide_with_areas = true
	test_2dpoint.position = test_pos
	test_2dpoint.collision_mask = 2
	
	var result = space_state.intersect_point(test_2dpoint)
	
	if print_results:
		print(result)
		
	return len(result) > 0

func _on_win_screen_win_clicked() -> void:
	load_next_stage()
	
func restart_level():
	reset_statics_before_load()
	get_tree().reload_current_scene()
