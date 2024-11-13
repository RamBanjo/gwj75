extends UnlockableObject
class_name DoorObject

@onready var door_sprite = $Sprite2D
@onready var collider = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func toggle_lock_state():
	super.toggle_lock_state()
	set_door_lock_state()

func restore_latest_death_state():
	super.restore_latest_death_state()
	set_door_lock_state()

func set_door_lock_state():
	#print(lock_state, name)
	if lock_state:
		collider.set_deferred("disabled", false)
		door_sprite.modulate.a = 1
	else:
		collider.set_deferred("disabled", true)
		door_sprite.modulate.a = 0.25
