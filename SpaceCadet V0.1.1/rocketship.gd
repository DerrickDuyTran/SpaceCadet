extends Node2D

#REST TIME FOR PLATFORM
const IDLE_DURATION = .2
#DECIDES WHERE THE PLATFORM MOVES
export var move_to = Vector2.UP * 1000000000000
#SPEED OF PLATFORM
export var speed = 3.0

var	follow = Vector2.ZERO
onready var platform = $platform
onready var tween = $MovesPlatform
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#FUNCTION THAT MOVES PLATFORM
func _init_tween():
	#TIME IT TAKES PLATFORM TO MOVE TO LOCATION
	var duration = move_to.length() / float(speed * 64)
	#Moves platform up to the final destination
	tween.interpolate_property(self, "follow",Vector2.ZERO, move_to,duration, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, IDLE_DURATION)
	#Moves platform back to its original location
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)
	#Starts the tween methods so that the platforms actuall move
	tween.start()

#FUNCTION MAKES IT SO THAT THE PLATFORM MOVES MORE SMOOTHLY
func _physics_process(delta):
	platform.position = platform.position.linear_interpolate(follow, .1)




func _on_Area2D_body_entered(body):
	if body.get("TYPE") == "SpaceCadet":
		_init_tween()
