extends RigidBody

var APlayer: AnimationPlayer
var codigo = 0

func _ready():
	APlayer = $Player/AnimationPlayer
	APlayer.play("Death", -1, 10)
	
	$Area.connect("body_entered", self, "mostrar_codigo")

func mostrar_codigo(body):
	if not body is Player:
		return
	body.screenprint("El código es: "+str(codigo))
