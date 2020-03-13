extends MeshInstance

var DoorUp: MeshInstance
var DoorDown: MeshInstance

var doorup_origin: Vector3
var doordown_origin: Vector3

var Torreta1
var Torreta2
var intentos = 2
func _ready():
	$AreaEntrada.connect("body_entered", self, "activar_codeintro")
	$AreaEntrada.connect("body_exited", self, "desactivar_codeintro")
	
	$AreaSalida.connect("body_entered", self, "close_door")
	
	DoorUp = $PuertaTrampaArriba
	DoorDown = $PuertaTrampaAbajo
	doorup_origin = DoorUp.translation
	doordown_origin = DoorDown.translation
	
	Torreta1 = $Turret1/Puerta
	Torreta2 = $Turret2/Puerta

var open_door = false
var moving = false
var up_offset = Vector3(0, 2.6, 0)
var down_offset = Vector3(0, -2.6, 0)
var t = 0.0
func _process(delta):
	t += delta*0.05
	if moving:
		if open_door:
			DoorUp.translation = DoorUp.translation.linear_interpolate(doorup_origin + up_offset, t)
			DoorDown.translation = DoorDown.translation.linear_interpolate(doordown_origin + down_offset, t)
		else:
			DoorUp.translation = DoorUp.translation.linear_interpolate(doorup_origin, t)
			DoorDown.translation = DoorDown.translation.linear_interpolate(doordown_origin, t)
		if (t >= 1):
			t = 0
			moving = false

	if not moving and (t >= 1):
		t = 0
		moving = true
		open_door = false

func open_door():
	moving = true
	open_door = true
	t = 0

func close_door(body):
	if not body is Player:
		return
	moving = true
	open_door = false
	t = 0

func activar_codeintro(body):
	if not body is Player:
		return
	body.trampa_panel = self
	body.ui_codeintro_show()

func desactivar_codeintro(body):
	if not body is Player:
		return
	body.trampa_panel = null
	body.ui_codeintro_hide()


func entercodigo( player:Player, codigo: int ):
	var Trampa = get_parent()
	if codigo == Trampa.codigo:
		open_door()
		player.screenprint("CLAVE ACEPTADA")
		Torreta1.cerrar()
		Torreta2.cerrar()
	else:
		intentos -= 1
		if intentos < 0:
			Torreta1.abrir()
			Torreta2.abrir()
		player.screenprint("CLAVE INCORRECTA")
			
		moving = true
		open_door = false
		t = 0



#func can_close_door(body):
#	if not body is Player:
#		return
#	if not moving:
#		moving = true
#		open_door = false
#		t = 0
