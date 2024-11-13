extends CharacterBody2D
class_name BoxObject

const DEATH_RECORD = {"pos_on_death": Vector2.ZERO}
var my_death_records = []

func push(velocity: Vector2) -> void:
	print("Push not implemented in %s" % get_class())

func record_death():
	var new_record = DEATH_RECORD.duplicate()
	
	new_record["pos_on_death"] = position
	
	my_death_records.append(new_record)
	
func restore_latest_death_state():
	#If we have no records of this object, this means this object was created after our last death. Delete it!
	if my_death_records.is_empty():
		queue_free()
	else:
		#Otherwise, move the position of this object to the popped position listed.
		var new_pos_info = my_death_records.pop_back()
		position = new_pos_info["pos_on_death"]		
		

	
