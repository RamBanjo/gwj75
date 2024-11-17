extends AnimatedSprite2D

@export var pulse_frequency: float = 10.0
@export var pulse_max: float = 2.0
@export var pulse_min: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pulse_amplitude = pulse_max - pulse_min
	var scale_mult = sin(Time.get_ticks_msec() * pulse_frequency) * (pulse_amplitude)
	scale = Vector2.ONE * (scale_mult + pulse_amplitude + pulse_min) 
