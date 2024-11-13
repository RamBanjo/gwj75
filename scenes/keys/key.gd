extends UnlockerObject
class_name KeyObject

@onready var my_sprite = $AnimatedSprite2D
@export var bob_amplitude : float= 10
@export var bob_frequency : float= 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready() # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#print(Time.get_ticks_msec())
	my_sprite.position.y = sin(Time.get_ticks_msec() * bob_frequency) * bob_amplitude
	
func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	
func _on_body_exited(body: Node2D) -> void:
	super._on_body_exited(body)
