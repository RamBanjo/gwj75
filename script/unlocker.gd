extends Area2D
class_name UnlockerObject

@export var destroy_self_on_touch : bool = false
@export var player_interactable : bool = true
@export var box_interactable : bool = false
@export var my_color : UnlockColor
@export var delete_potential : bool = true

@onready var visual_aid : VisualAid = $VisualAid

const DEATH_RECORD = {"toggled" : false}
var my_death_records = []
static var toggle_count_death_records = []

var toggled = false

signal toggle_count_changed

enum UnlockColor{
	RED, GREEN, BLUE, YELLOW
}

const DEFAULT_TOGGLE_COUNTER : Dictionary = {
	UnlockColor.RED : 0,
	UnlockColor.GREEN: 0,
	UnlockColor.BLUE: 0,
	UnlockColor.YELLOW: 0
}

static var toggle_count_by_color : Dictionary = DEFAULT_TOGGLE_COUNTER.duplicate()

static func reset_toggle_count():
	toggle_count_by_color = DEFAULT_TOGGLE_COUNTER.duplicate()
	
static func record_toggle_count():
	var duplicated_toggle_counter = toggle_count_by_color.duplicate()
	toggle_count_death_records.append(duplicated_toggle_counter)

static func restore_latest_toggle_count():
	toggle_count_by_color = toggle_count_death_records.pop_back()

func record_death():
	var new_record = DEATH_RECORD.duplicate()
	new_record["toggled"] = toggled
	my_death_records.append(new_record)
	
func restore_latest_death_state():
	#If we have no records of this object, this means this object was created after our last death. Delete it!
	if my_death_records.is_empty():
		queue_free()
	else:
		#Otherwise, move the position of this object to the popped position listed.
		var new_pos_info = my_death_records.pop_back()
		var new_toggle = new_pos_info["toggled"]

		#Here's the tricky part. If the thing destroys itself on touch, we need to figure out if we need to revive the key.
		#If the key is toggled, do nothing.
		#If the key is untoggled, bring it back.
		if toggled != new_toggle and destroy_self_on_touch:
			become_untouched(true)
			return
		
		#If this thing does NOT destroy itself on touch,
		#we figure out if it should spawned pressed or not by checking if there are currently things that triggers it touching it rather than by the toggle state.
		
		if not destroy_self_on_touch:
			#print(untouched_by_interactables())
			check_touched()
		
		toggled = new_toggle


func _ready():
	
	visual_aid.my_color = my_color
	visual_aid.update_text()
	pass
	#self.toggle_count_changed.connect(GameStage._on_unlocker_activated.bind())

func add_toggle_count():
	toggle_count_by_color[my_color] += 1
	toggle_count_changed.emit(my_color)
	
func subtract_toggle_count():
	toggle_count_by_color[my_color] -= 1
	toggle_count_changed.emit(my_color)
	
func _on_body_entered(body: Node2D) -> void:
	
	var player_body = body as PlayerCharacter
	var box_body = body as BoxObject
	
	check_touched()
	#if not untouched_by_interactables():
		#become_touched()

func _on_body_exited(body: Node2D) -> void:
	
	var player_body = body as PlayerCharacter
	var box_body = body as BoxObject
	
	check_touched()
	#if destroy_self_on_touch and toggled:
		#return
	#
	#if untouched_by_interactables():	
		#become_untouched()

func become_touched():
	if not toggled:	
		add_toggle_count()
		toggled = true
		
	if destroy_self_on_touch and toggled:
		#GameStage.current_scene_instance.sound_player.play_key_sound()
		self.hide()
	
func become_untouched(undestroy : bool = false):
	if toggled and (not destroy_self_on_touch or (destroy_self_on_touch and undestroy)):
		subtract_toggle_count()
		toggled = false
	
	if undestroy:
		self.show()

func untouched_by_interactables() -> bool:
	
	var overlapping_bodies = get_overlapping_bodies()
	
	var interactables = []
	
	for body in overlapping_bodies:
		var player_body = body as PlayerCharacter
		var box_body = body as BoxObject
		
		if (player_body and player_interactable) or (box_body and box_interactable):
			#print(body, " is touching ", name)
			interactables.append(body)
	
	return interactables.is_empty()

func check_touched():
	if untouched_by_interactables():
		#print(name, " becomes untouched")
		become_untouched()
	else:
		#print(name, " becomes touched")
		become_touched()
