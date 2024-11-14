extends Node2D
class_name GameStage

@onready var win_screen = $WinScreen
@onready var undo_hint = $UndoHint
@onready var mirror_hint = $MirrorDropHint
@onready var mirror_hold_hint = $MirrorHoldHint
@onready var tutorial_canvas = $TutorialCanvas

@onready var camera = $Camera2D

static var player_object = preload("res://scenes/player.tscn")

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
static var current_scene_instance = null

var hovering_mirror = false
static var holding_mirror : bool = false

var my_mirrors = []

@export var next_stage : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	get_viewport().canvas_cull_mask = 1
	
	if current_scene_instance == null:
		current_scene_instance = self
	else:
		queue_free()
	
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
	
	if tutorial_canvas:
		tutorial_canvas.hide()
	
	pass
	
func load_next_stage():
	
	reset_statics_before_load()
	#TODO: Get the Stage Object to switch to from the next stage variable.
	get_tree().change_scene_to_packed(next_stage)

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
			
	undo_hint.show()

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
	if PlayerCharacter.death_counter <= 0:
		undo_hint.hide()

func sort_undoable_by_delete_potential(lhs : Node2D, rhs : Node2D):	
	if lhs.delete_potential > rhs.delete_potential:
		return true
	else:
		return false

func spawn_player_from_undo():
	var player_death_pos_info = PlayerCharacter.player_death_records.pop_back()
	var new_player_pos = (player_death_pos_info["pos"]) + (player_death_pos_info["movement_dir"] * -64)
	
	var new_player = player_object.instantiate()
	new_player.player_pos_records = player_death_pos_info["pos_records"]
	new_player.player_die.connect(_on_player_die.bind())
	new_player.position = new_player_pos
	
	add_child(new_player)
	#print(player_death_pos_info, new_player_pos)

func toggle_reflect():
	holding_mirror = not holding_mirror
	
	set_mirror_effects(holding_mirror)
	
		
func set_mirror_effects(holding_mirror : bool):
	
	camera.zoom.x *= -1
	
	if holding_mirror:
		get_viewport().set_canvas_cull_mask_bit(1, true)
		get_viewport().set_canvas_cull_mask_bit(0, false)
		mirror_hint.show()
		
	else:
		get_viewport().set_canvas_cull_mask_bit(0, true)
		get_viewport().set_canvas_cull_mask_bit(1, false)
		mirror_hint.hide()		
		
	#print(get_viewport().canvas_cull_mask)

func _on_mirror_movement_detected():
	
	for mirror in my_mirrors:
		var casted_mirror = mirror as MirrorObject
		
		if casted_mirror:
			if casted_mirror.player_on_mirror_check():
				mirror_hold_hint.show()
				hovering_mirror = true
				return
				
	mirror_hold_hint.hide()
	hovering_mirror = false


func _on_win_screen_win_clicked() -> void:
	load_next_stage()
	
func restart_level():
	reset_statics_before_load()
	get_tree().reload_current_scene()
