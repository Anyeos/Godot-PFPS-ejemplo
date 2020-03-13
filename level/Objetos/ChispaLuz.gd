extends Spatial

var freetime = 1
var lighttime = 0.1

func _ready():
	$Chispa.emitting = true

func _process(delta):
	freetime -= delta
	if freetime <= 0:
		queue_free()

	lighttime -= delta
	if lighttime > 0:
		return

	$OmniLight.visible = false
