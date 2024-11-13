extends Area2D
class_name DeathArea

func _on_body_entered(body: Node2D) -> void:
	
	var player_casted_body = body as PlayerCharacter
	if player_casted_body:
		player_casted_body.die()
