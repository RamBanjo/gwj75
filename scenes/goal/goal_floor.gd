extends Area2D
class_name VictoryArea

signal win

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#If a body enters the Goal, check if it's a PlayerCharacter object. If it is, shoot a signal that says WIN!
func _on_body_entered(body: Node2D) -> void:
	
	var player_casted_body = body as PlayerCharacter
	if player_casted_body:
		win.emit()
		#print("WIN!")
	#pass # Replace with function body.
