extends Node2D

@export var level_to_project : PackedScene
@export var left_scene_is_main : bool = true

@onready var viewport_info := {
	"left":{
		viewport = $Control/HBoxContainer/leftport/SubViewport,
		camera = $Control/HBoxContainer/leftport/SubViewport/Camera2D
	},
	"right":{
		viewport = $Control/HBoxContainer/rightport/SubViewport,
		camera = $Control/HBoxContainer/rightport/SubViewport/Camera2D
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var chosen_screen = "left"
	var unchosen_screen = "right"
	if not left_scene_is_main:
		chosen_screen = "right"
		unchosen_screen = "left"
		
	var chosen_viewport_node = viewport_info[chosen_screen].viewport
	var unchosen_viewport_node = viewport_info[unchosen_screen].viewport
	
	unchosen_viewport_node.world_2d = chosen_viewport_node.world_2d
	
	var new_stage_instance = level_to_project.instantiate()
	chosen_viewport_node.add_child(new_stage_instance)
	#
	#for node in viewport_info.values():
		#var remote_transform := RemoteTransform2D.new()
		#remote_transform.remote_path = node.camera.get_path()
		#node.viewport.add_child(remote_transform)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
