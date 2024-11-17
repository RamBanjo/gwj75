extends DoorObject
class_name CountingDoorObject

var latest_known_lock_number = 0
@export var unlock_number = 2
@onready var my_label : RichTextLabel = $RichLabel

const LOCK_NUMBER_RECORD_ENTRY = {"lkln": 0, "unlock_num": 2}
var lock_number_records = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	latest_known_lock_number = UnlockerObject.toggle_count_by_color[my_color]
	update_my_label()
	#print(global_lock_number)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Instead of Toggling on and off with just one lock, whenever the a toggle should be called it recounts its own unlock number instead.
func toggle_lock_state():
	var new_lock_number = UnlockerObject.toggle_count_by_color[my_color]
	
	#If the new lock number is greater than the latest known lock number, set the new lock number, and increase by the difference.
	var current_lock_number_change = latest_known_lock_number - new_lock_number
	latest_known_lock_number = new_lock_number
	#print(current_lock_number_change)
	var unlock_number_is_positive = unlock_number > 0
	
	unlock_number += current_lock_number_change
	
	# If the Unlock Number was positive and touches 0, it toggles state.
	# Likewise, if the Unlock Number was non-positive and becomes positive, it also toggles state.
	if (unlock_number <= 0 and unlock_number_is_positive) or (unlock_number > 0 and not unlock_number_is_positive):
		super.toggle_lock_state()
		
	#Update the label too.
	update_my_label()
	
func update_my_label():
	my_label.text = wrap_string_with_richtext_bbcode("{my_number}".format({"my_number":unlock_number}))

func record_death():
	super.record_death()
	var new_record = LOCK_NUMBER_RECORD_ENTRY.duplicate()
	
	new_record["lkln"] = latest_known_lock_number
	new_record["unlock_num"] = unlock_number
	
	lock_number_records.append(new_record)

func restore_latest_death_state():
	super.restore_latest_death_state()
	set_door_lock_state()
	
	var latest_record = lock_number_records.pop_back()
	latest_known_lock_number = latest_record["lkln"]
	unlock_number = latest_record["unlock_num"]
	
	update_my_label()
	
func wrap_string_with_richtext_bbcode(to_wrap : String):
	return "[font_size=20]\n[/font_size][center][color=FFFE77][outline_size=10]%s[/outline_size][/color][/center]" % to_wrap
