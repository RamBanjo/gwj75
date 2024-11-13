extends Area2D
class_name MirrorObject

signal recheck_mirrors_request

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	var casted_body = body as PlayerCharacter
	
	if casted_body:
		recheck_mirrors_request.emit()
	
func _on_body_exited(body: Node2D) -> void:
	var casted_body = body as PlayerCharacter
	
	if casted_body:
		recheck_mirrors_request.emit()

	
func player_on_mirror_check() -> bool:
	var body_list = get_overlapping_bodies()
	
	for body in body_list:
		var casted_body = body as PlayerCharacter
		
		if casted_body:
			return true
			
	return false
