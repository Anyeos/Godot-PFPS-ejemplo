extends Camera

func _ready():
	$Area.connect("body_entered", self, "set_current")

func set_current(body):
	if not body is Player:
		return
	#self.current = true
	
	#print("body transform primero: ", body.global_transform)
	self.global_transform = body.global_transform
	print("body transform: ", body.global_transform)
