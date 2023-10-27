extends CanvasLayer
const READRATE = .075

onready var textbox = $CONTAINER
onready var start = $CONTAINER/MarginContainer/Panel/HBoxContainer/START
onready var end = $CONTAINER/MarginContainer/Panel/HBoxContainer/END
onready var label = $CONTAINER/MarginContainer/Panel/HBoxContainer/Label2

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var textQueue = []

func _ready():
	print("Starting State: State.READY")
	hide_textbox()
	queueText("PRESS A AND D TO MOVE LEFT AND RIGHT")
	queueText("PRESS SPACE BAR TO JUMP UP")
	queueText("PRESS SHIFT TO DASH")
	
	
func _process(_delta):
	match current_state:
		State.READY:
			if !textQueue.empty():
				displayText()
		State.READING:
			if Input.is_action_just_pressed("enter"):
				label.percent_visible = 1.0
				$Tween.stop_all()
				end.text = "Enter"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("enter"):
				change_state(State.READY)
				hide_textbox()
	
func queueText(next_text):
	textQueue.push_back(next_text)  
func hide_textbox():
	start.text = ""
	end.text = ""
	label.text = ""
	textbox.hide()
	
func show_textbox():
	start.text = "*"
	textbox.show()

func displayText():
	var next_text = textQueue.pop_front()
	label.text = next_text
	label.percent_visible = 0.0
	change_state(State.READING)
	show_textbox() 
	$Tween.interpolate_property(label, "percent_visible", 0.0, 1.0, len(next_text) * READRATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Change state to: State.READY")
		State.READING:
			print("Change state to: State.READING")
		State.FINISHED:
			print("Change state to: State.FINISHED")



func _on_Tween_tween_all_completed():
	end.text = "Enter"
	change_state(State.FINISHED)
