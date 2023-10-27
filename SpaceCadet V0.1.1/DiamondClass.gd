extends Area2D

signal diamond_collected

func _on_DiamondClass_body_entered(body):
	emit_signal("diamond_collected")
	
	queue_free()
