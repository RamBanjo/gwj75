extends Node
class_name SoundPlayer

@onready var death_sound : AudioStreamPlayer = $SoundEffectPlayer/DeathSound
@onready var win_sound : AudioStreamPlayer = $SoundEffectPlayer/WinSound
@onready var switch_sound : AudioStreamPlayer = $SoundEffectPlayer/SwitchSound
@onready var key_sound : AudioStreamPlayer = $SoundEffectPlayer/KeySound

@onready var sfx_list = [$SoundEffectPlayer/DeathSound, $SoundEffectPlayer/WinSound, $SoundEffectPlayer/SwitchSound, $SoundEffectPlayer/KeySound]
@onready var bgm_player : AudioStreamPlayer = $BGMPlayer

func _ready() -> void:
	set_bgm_volume(GameOptions.load_volume("music"))
	set_sfx_volume(GameOptions.load_volume("sfx"))
	
func stop_bgm():
	bgm_player.stop()
	
func play_death_sound():
	death_sound.play()
	
func play_win_sound():
	win_sound.play()
	
func play_switch_sound():
	switch_sound.play()
	
func play_key_sound():
	key_sound.play()

func set_bgm_volume(new_volume: float):
	bgm_player.volume_db = linear_to_db(new_volume)
	
func set_sfx_volume(new_volume: float):
	for sfx in sfx_list:
		sfx.volume_db = linear_to_db(new_volume)
	
