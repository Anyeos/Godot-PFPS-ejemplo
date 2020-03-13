extends MeshInstance

var activa = false
var lista = false
var moviendo = false
var abriendo = false

var Torreta

var up_origin: Vector3
func _ready():
	#up_origin = translation
	up_origin = Vector3(0, 0, 0)
	
var up_offset = Vector3(0, -1, 0)
var t = 0.0
func _process(delta):
	if not activa:
		return	
	t += delta*0.5
	if moviendo:
		if abriendo:
			translation = up_origin.linear_interpolate(up_offset, t)
			if (t >= 1):
				lista = true
		else:
			translation = up_offset.linear_interpolate(up_origin, t)
			lista = false
		if (t >= 1):
			t = 0
			moviendo = false

	#if not moviendo and (t >= 10):
	#	t = 0
	#	moviendo = true
	#	abriendo = false

func abrir():
	if moviendo:
		return
	moviendo = true
	abriendo = true
	activa = true
	t = 0

func cerrar():
	if moviendo:
		return
	moviendo = true
	abriendo = false
	t = 0

