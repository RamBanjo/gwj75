extends Node
class_name GameOptions

static var visual_aid = false

static var max_level_data = ConfigFile.new()
static var levels_unlocked = 0

static var options_data = ConfigFile.new()
static var music_vol : float = 1.0
static var sfx_vol : float = 1.0

static func save_max_level():
	
	max_level_data.set_value("max_level", "max_level", levels_unlocked)
	max_level_data.save("user://levels_cleared.cfg")
	
static func load_max_level():
	
	var err = 	max_level_data.load("user://levels_cleared.cfg")

	if err != OK:
		levels_unlocked = 0
		return
		
	levels_unlocked = max_level_data.get_value("max_level", "max_level")

static func save_volume():
	options_data.set_value("volume", "music", music_vol)
	options_data.set_value("volume", "sfx", sfx_vol)
	options_data.save("user://options.cfg")
	

static func load_volume(vol_type : String):
	
	var err = options_data.load("user://options.cfg")
	
	if err != OK:
		save_volume()
		
	var volume_info = options_data.get_value("volume", vol_type)
	
	return volume_info
	
		

const LEVEL_DICTS = [
	{
		"level_name": "1. Very Easy Level",
		"level_path": "res://scenes/levels/1-movement_tutorial.tscn"
	},{
		"level_name": "2. Box is Push",
		"level_path": "res://scenes/levels/2-boxes-tutorial.tscn"
	},{
		"level_name": "3. Lock and Key",
		"level_path": "res://scenes/levels/3-key-tutorial.tscn"
	},{
		"level_name": "4. Pressure Plates",
		"level_path": "res://scenes/levels/4-floor_buttons_tutorial.tscn"
	},{
		"level_name": "5-1. High Stakes",
		"level_path": "res://scenes/levels/5-1-undo.tscn"
	},{
		"level_name": "5-2. Softlock Preventation Measures",
		"level_path": "res://scenes/levels/5-2-reset-level.tscn"
	},{
		"level_name": "6. Over My Dead Body",
		"level_path": "res://scenes/levels/6-corpse_bridge.tscn"
	},{
		"level_name": "7. Reflections",
		"level_path": "res://scenes/levels/7-mirrors.tscn"
	},{
		"level_name": "8. Hall of Mirrors",
		"level_path": "res://scenes/levels/8-invisible_maze.tscn"
	},{
		"level_name": "9. Remember This!",
		"level_path": "res://scenes/levels/9-cryptography.tscn"
	},{
		"level_name": "10. Graveyard",
		"level_path": "res://scenes/levels/10-checkpoint.tscn"
	},{
		"level_name": "11. Double Back",
		"level_path": "res://scenes/levels/11-loadbearing.tscn"
	},{
		"level_name": "12. Don't Look Back",
		"level_path": "res://scenes/levels/12-limited.tscn"
	},{
		"level_name": "13. X Marks the Spot",
		"level_path": "res://scenes/levels/13-X.tscn"
	},{
		"level_name": "14. Entitlement",
		"level_path": "res://scenes/levels/14-Entitlement.tscn"
	},{
		"level_name": "15. Just One Of Each",
		"level_path": "res://scenes/levels/15-realignment.tscn"
	},{
		"level_name": "16. The Return Trip is Harder",
		"level_path": "res://scenes/levels/16-return_trip.tscn"
	},{
		"level_name": "17. You Can't See Me",
		"level_path": "res://scenes/levels/17-cena.tscn"
	},{
		"level_name": "18-1. Quiz Show: Jam",
		"level_path": "res://scenes/levels/18-1-quiz_jam.tscn"
	},{
		"level_name": "18-2. Quiz Show: Yellow Keys",
		"level_path": "res://scenes/levels/18-2-quiz_yellow_keys.tscn"
	},{
		"level_name": "18-3. Quiz Show: Maths",
		"level_path": "res://scenes/levels/18-3-quiz_math.tscn"
	},{
		"level_name": "18-4. Quiz Show: Do You Still Remember?",
		"level_path": "res://scenes/levels/18-4-quiz_memory.tscn"
	},{
		"level_name": "18-5. Quiz Show: Impossible",
		"level_path": "res://scenes/levels/18-5-quiz_cheeky_impossible.tscn"
	},{
		"level_name": "18-6. Quiz Show: [REDACTED]",
		"level_path": "res://scenes/levels/18-6-quiz_actual_impossible.tscn"
	},{
		"level_name": "19. Almost There!",
		"level_path": "res://scenes/levels/19-last_test.tscn"
	},{
		"level_name": "20. Thanks for Playing!",
		"level_path": "res://scenes/levels/20-thanks-for-playing.tscn"
	}
]
