extends PhysicsBox
class_name PlayerCorpse

@onready var corpse_sprite : AnimatedSprite2D = $Sprite2D
@onready var undo_hint_sprite : AnimatedSprite2D = $UndoHintSprite

func _ready() -> void:
	pass
	
func face_left():
	corpse_sprite.play("left")
	
func face_right():
	corpse_sprite.play("right")
