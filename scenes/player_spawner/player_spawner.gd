extends Node2D
class_name PlayerSpawner

@onready var spawn_point = $SpawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#On death, 

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_released("ui_accept"):
		#spawn_player()

func spawn_player():
	
	#We check if the spawn point is obstructed. If it is, then we don't spawn anything.
	if spawn_point.has_overlapping_bodies():
		print("Can't spawn new player because overlap")
		return
		
	#if the SpawnPoint is not overlapping a body, spawns a Player object.
	var new_player = GameStage.player_object.instantiate()
	new_player.global_position = spawn_point.global_position
	#new_player.set_visibility_layer_bit(1, false)
	#new_player.velocity = Vector2.ZERO
	
	new_player.player_die.connect(GameStage.current_scene_instance._on_player_die.bind())
	GameStage.current_scene_instance.add_child(new_player)
