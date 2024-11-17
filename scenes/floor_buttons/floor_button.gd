extends UnlockerObject
class_name FloorButton

@onready var button_sprite = $MySprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func restore_latest_death_state():
	super.restore_latest_death_state()
	update_sprite(toggled)
	
func untouched_by_interactables() -> bool:
	var result =  super.untouched_by_interactables()
	update_sprite(result)
	return result
	
func update_sprite(untouched : bool):
	#print("updated")
	if untouched:
		button_sprite.animation = "unpressed"
	else:
		button_sprite.animation = "pressed"	
		
func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	if GameStage.current_scene_instance:
		GameStage.current_scene_instance.sound_player.play_switch_sound()
	
func _on_body_exited(body: Node2D) -> void:
	super._on_body_exited(body)
	if GameStage.current_scene_instance:
		GameStage.current_scene_instance.sound_player.play_switch_sound()
