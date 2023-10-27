extends Label

var timeElapsed := 0.0

func _timeString(time: float):
	var minutes := time / 60
	var seconds := fmod(time, 60)
	var milliseconds := fmod(time, 1) * 100
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func _process(delta: float) -> void:
	timeElapsed += delta
	text = _timeString(timeElapsed)
