extends Area2D

var active = false

func _ready():
	connect("body_entered", self, '_on_NPC_body_entered')
	connect("body_exited", self, '_on_NPC_body_exited')

func _process(delta):
	$ExclamationMark3.visible = active

func _input(event):
	if get_node_or_null('DialogNode') == null: # checks if another dialogue box is open
		if event.is_action_pressed("ui_accept") and active:
			get_tree().paused = true # pauses game
			var dialog = Dialogic.start('timeline-3') # starts dialogue
			dialog.pause_mode = Node.PAUSE_MODE_PROCESS # unpauses only the dialogue timeline
			dialog.connect('timeline_end', self, 'unpause') # unpauses game when dialogue ends
			add_child(dialog) 

func unpause(timeline_name):
	get_tree().paused = false

func _on_NPC_body_entered(body):
	if body.name == 'SpaceCadet':
		active = true

func _on_NPC_body_exited(body):
	if body.name == 'SpaceCadet':
		active = false
