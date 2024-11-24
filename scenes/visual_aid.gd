extends RichTextLabel
class_name VisualAid

var my_color: UnlockerObject.UnlockColor

const VISUAL_AID_SYMBOL_DICT = {
	UnlockerObject.UnlockColor.RED : "🝔",
	UnlockerObject.UnlockColor.GREEN : "🜂",
	UnlockerObject.UnlockColor.BLUE : "🜨",
	UnlockerObject.UnlockColor.YELLOW : "⎔",
}

const VISUAL_AID_COLOR_DICT = {
	UnlockerObject.UnlockColor.RED : "C02020",
	UnlockerObject.UnlockColor.GREEN : "20C020",
	UnlockerObject.UnlockColor.BLUE : "2020C0",
	UnlockerObject.UnlockColor.YELLOW : "C0C020",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#text = update_text()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_text():
	#print("aids")
	if not GameOptions.visual_aid:
		text = ""
	else:
		var format_dict = {"symbol":VISUAL_AID_SYMBOL_DICT[my_color], "color":VISUAL_AID_COLOR_DICT[my_color]}
		text = "[center][color={color}][outline_size=10]{symbol}[/outline_size][/color][/center]".format(format_dict)
