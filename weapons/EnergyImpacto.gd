extends Spatial

var freetime = 0.5
var lighttime = 0.1

func _ready():
	$Impacto.emitting = true

var res_audioplayer = preload("res://3D_Audio_Player.tscn")
var snd_hit1 = preload("res://weapons/sounds/hit1.wav")
var snd_hit2 = preload("res://weapons/sounds/hit2.wav")
var playsound = true
func _process(delta):
	freetime -= delta
	if freetime <= 0:
		queue_free()

	lighttime -= delta
	if lighttime > 0:
		return
	
	if playsound:
		var sound = res_audioplayer.instance()
		#sound.stream = snd_hit2 if randf() < 0.9 else snd_hit1
		sound.stream = snd_hit2
		sound.pitch_scale = 1.1 - randf()*0.2
		sound.unit_db = 0.5
		add_child(sound)
		playsound = false
	
	$OmniLight.visible = false
