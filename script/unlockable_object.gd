extends StaticBody2D
class_name UnlockableObject

@export var lock_state = true
@export var my_color: UnlockerObject.UnlockColor
@export var delete_potential : bool = true

@onready var visual_aid : VisualAid = $VisualAid

const DEATH_RECORD = {"state": true}
var my_death_records = []

func _ready() -> void:
	visual_aid.my_color = my_color
	visual_aid.update_text()
	pass
	#GameStage.unlockable_things_by_color[my_color].append(self)
	#print(GameStage.unlockable_things_by_color)

func toggle_lock_state():
	lock_state = not lock_state

func record_death():
	var new_record = DEATH_RECORD.duplicate()
	new_record["state"] = lock_state
	my_death_records.append(new_record)
	
	#print(my_death_records, name)
	
func restore_latest_death_state():
	#If we have no records of this object, this means this object was created after our last death. Delete it!
	if my_death_records.is_empty():
		queue_free()
	else:
		#Otherwise, move the position of this object to the popped position listed.
		var new_pos_info = my_death_records.pop_back()
		lock_state = new_pos_info["state"]		
