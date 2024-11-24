extends CanvasLayer
class_name LevelInfoCanvas

@onready var level_name_label = $LevelName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	
	GameStage.reset_statics_before_load()
	get_tree().change_scene_to_file("res://scenes/game_menu/main_menu.tscn")
	pass # Replace with function body.
