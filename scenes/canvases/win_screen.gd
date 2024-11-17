extends CanvasLayer
class_name WinScreen

signal win_clicked
@onready var win_label = $Label
@onready var level_button = $AdvanceLevelButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_final_level_win_text():
	win_label.text = "CONGRATULATIONS!"
	level_button.text = "Main Menu"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_advance_level_button_pressed() -> void:
	win_clicked.emit()
