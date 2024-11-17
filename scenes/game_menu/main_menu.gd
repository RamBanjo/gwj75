extends Node2D

@onready var level_selector = $MainMenuCanvas/LevelSelector
@onready var current_canvas = $MainMenuCanvas
@onready var bgm_slider = $OptionsCanvas/Panel/BGMSlider
@onready var sfx_slider = $OptionsCanvas/Panel/SFXSlider
@onready var sound_player = $SoundPlayer

@onready var menu_canvases = {
	"main_menu": $MainMenuCanvas,
	"options": $OptionsCanvas,
	"credits": $CreditsCanvas,
	"about_jam": $AboutJamCanvas
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameOptions.load_max_level()
	populate_level_selector()
		
	bgm_slider.value = GameOptions.load_volume("music")
	sfx_slider.value = GameOptions.load_volume("sfx")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func populate_level_selector():
	#level_selector.add_item(GameOptions.LEVEL_DICTS[0]["level_name"], 0)
	#level_selector.add_item(GameOptions.LEVEL_DICTS[0]["level_name"], 0)
	for i in range(0, GameOptions.levels_unlocked+1):
		
		if i < len(GameOptions.LEVEL_DICTS):
			level_selector.add_item(GameOptions.LEVEL_DICTS[i]["level_name"], i)

func _on_play_button_pressed() -> void:
	var current_chosen_level_idx = level_selector.get_selected_id()
	#print(level_selector.get_selected_id())
	get_tree().change_scene_to_file(GameOptions.LEVEL_DICTS[current_chosen_level_idx]["level_path"])
	pass # Replace with function body.

func switch_canvas(target_canvas_name: String):
	current_canvas.hide()
	
	var new_canvas = menu_canvases.get(target_canvas_name, "main_menu")
	
	new_canvas.show()
	current_canvas = new_canvas


func _on_options_pressed() -> void:
	switch_canvas("options")
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	switch_canvas("credits")
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_exit_options_pressed() -> void:
	switch_canvas("main_menu")
	pass # Replace with function body.


func _on_about_jam_pressed() -> void:
	switch_canvas("about_jam")
	pass # Replace with function body.


func _on_rich_text_label_2_meta_clicked(meta: Variant) -> void:
	#print(str(meta))
	OS.shell_open(str(meta))
	pass # Replace with function body.

func _on_bgm_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameOptions.music_vol = bgm_slider.value
		sound_player.set_bgm_volume(GameOptions.music_vol)
		GameOptions.save_volume()	
	pass # Replace with function body.


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameOptions.sfx_vol = sfx_slider.value
		sound_player.set_sfx_volume(GameOptions.sfx_vol)
		sound_player.play_key_sound()
		GameOptions.save_volume()	
	pass # Replace with function body.
