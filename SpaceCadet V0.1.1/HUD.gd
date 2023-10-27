extends CanvasLayer

var diamonds = 0

func _ready():
	diamonds = 0
	$Diamonds.text = str(diamonds)

func _on_diamond_collected():
	diamonds = diamonds + 1
	$Diamonds.text = str(diamonds)
