extends Control
var is_paused = false setget set_is_paused
func _unhandled_input(event):
	if event.is_action_pressed('pause'):
		self.is_paused = !is_paused
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func _on_resumebutton_pressed():
	self.is_paused = false

func _on_quitbutton_pressed():
	get_tree().quit()


func _on_levelselector_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://LEVELSELECTOR.tscn")

func _ready():
	visible = false
	
