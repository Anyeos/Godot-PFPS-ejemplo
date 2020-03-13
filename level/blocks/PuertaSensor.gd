extends MeshInstance

var Door: MeshInstance
var Body: StaticBody

var snd_abre = preload("res://level/blocks/sonidos/puertaabre.wav")
var snd_cierra = preload("res://level/blocks/sonidos/puertacierra.wav")
var res_soundplayer = preload("res://3D_Audio_Player.tscn")

var door_origin: Vector3
func _ready():
	$Area.connect("body_entered", self, "open_door")
	$Area.connect("body_exited", self, "can_close_door")
	Door = $Puerta
	Body = $Puerta/StaticBody
	if Door == null:
		Door = $Puerta001
		Body = $Puerta001/StaticBody
	door_origin = Door.translation


var open_door = false
var moving = false
var closed = true
var door_offset = Vector3(0, 0.9, 0)
var t = 0.0
func _process(delta):
	t += delta*0.2
	if moving:
		if open_door:
			Door.translation = Door.translation.linear_interpolate(door_origin + door_offset, t)
			closed = false
		else:
			Door.translation = Door.translation.linear_interpolate(door_origin, t)
			closed = true
		if (t >= 1):
			t = 0
			moving = false

	if not moving and not closed and (t >= 1):
		t = 0
		moving = true
		open_door = false
		var sound = res_soundplayer.instance()
		sound.unit_db = -15
		sound.stream = snd_cierra
		add_child(sound)

func open_door(body):
	if not body is Personaje:
		return
	#if not moving:
	moving = true
	open_door = true
	t = 0
	if closed:
		var sound = res_soundplayer.instance()
		sound.unit_db = -15
		sound.stream = snd_abre
		add_child(sound)

func can_close_door(body):
	if not body is Personaje:
		return
	if not moving:
		moving = true
		open_door = false
		t = 0


