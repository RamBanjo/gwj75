extends UnlockerObject
class_name FloorButton

@onready var button_sprite = $MySprite

@export var untouched_sprite: Texture2D
@export var touched_sprite: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
func _on_body_exited(body: Node2D) -> void:
	super._on_body_exited(body)
