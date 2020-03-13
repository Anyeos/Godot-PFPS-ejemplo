# Este es el script del jugador. Derivado de Personaje que es una clase que
# contiene código común a los personajes (monstruos, npc, etc) del juego.


extends Personaje

class_name Player

var bone_spine # Usado para mover la parte superior del personaje
var bone_spine_pose # Default pose of the bone at beginning
 
var camera: Camera
var rotation_helper # Para ayudar a apuntar horizontalmente

var MOUSE_SENSITIVITY = 0.1

var flashlight

var weapons = {"EnergyRifle":null}

var AimRay: RayCast

var UI_status_label
var UI_panel_mensaje
var UI_mensaje
var UI_codeintro
var UI_code: Label
var trampa_panel = null
var UI_deathscreen

func _ready():
	# La camara está colocada en un anclaje del skeleton del jugador
	# lo que no es estándar.
	# En el ejemplo oficial de Godot se hace de una forma más estándar
	# para hacer un FPS, pero yo quise darle un toque de realismo por
	# lo tanto lo coloqué de esta manera para no requerir simular la
	# visión del jugador pero requiere que la animación no mueva mucho
	# la cámara porque de lo contrario podría molestar a quien juega.
	# De esta manera tampoco tenemos control lineal del movimiento de
	# la cámara con respecto al movimiento del mouse. Pero la idea sirve
	# para implementar un control de puntería más sofisticado donde
	# el mouse movería rápidamente la puntería sin tener que mover 
	# la vision del jugador directamente.
	camera = $PlayerSkeleton/Skeleton/AnclajeCabeza/Camera
	flashlight = $PlayerSkeleton/Skeleton/AnclajeCabeza/Flashlight
	rotation_helper = $Rotation_Helper

	animation = $AnimationPlayer

	skeleton = $PlayerSkeleton/Skeleton
	bone_spine = skeleton.find_bone("spine_2")
	bone_spine_pose = skeleton.get_bone_pose(bone_spine)

	collisions_attached["superior"] = [
		$Superior_CollisionShape,
		$PlayerSkeleton/Skeleton/AnclajeSuperior/Position3D
		]

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	AimRay = $PlayerSkeleton/Skeleton/AnclajeCabeza/Camera/RayCast
	weapons["EnergyRifle"] = $PlayerSkeleton/Skeleton/AnclajeArma/EnergyRifle/ShootPoint
	weapons["EnergyRifle"].attacker = self

	UI_status_label = $HUD/Superior/Panel_border/Status_label
	UI_mensaje = $HUD/Inferior/PanelMensaje/Mensaje
	UI_panel_mensaje = $HUD/Inferior/PanelMensaje
	UI_panel_mensaje.visible = false
	
	# Botonera
	UI_codeintro = $HUD/CodeIntro
	UI_codeintro.visible = false
	UI_code = $HUD/CodeIntro/PanelMensaje/VBoxContainer/MarginContainer/VBoxContainer/Codigo
	for b in range(9):
		var button = get_node("HUD/CodeIntro/PanelMensaje/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer1/GridContainer/Button%s" % (b+1))
		button.connect("button_down", self, "ui_button%s" % (b+1))
	var button = get_node("HUD/CodeIntro/PanelMensaje/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer2/Button0")
	button.connect("button_down", self, "ui_button0")

	UI_deathscreen = $HUD/Death_Screen
	
	weapon = weapons['EnergyRifle']
	
	# Sonidos
	snd_footsteps[0] = load("res://player/sounds/step1.wav")
	snd_footsteps[1] = load("res://player/sounds/step2.wav")
	snd_footsteps[2] = load("res://player/sounds/step3.wav")
	snd_footsteps[3] = load("res://player/sounds/step4.wav")

	# Nuestro jugador vino del futuro con un traje protector especial
	# Por eso tenemos una armadura o energía principal del traje
	energy = 999
	health = 100


# Procesamos las entradas particulares del jugador
func process_control(delta):
	# ----------------------------------
	# Walking
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			jump()
	# ----------------------------------

	# ----------------------------------
	if Input.is_key_pressed(KEY_1):
		weapon.set_mode(0);
	if Input.is_key_pressed(KEY_2):
		weapon.set_mode(1);
	if Input.is_key_pressed(KEY_3):
		weapon.set_mode(2);
	if Input.is_key_pressed(KEY_4):
		weapon.set_mode(3);
	
	if Input.is_action_just_pressed("shift_weapon_positive"):
		weapon.set_mode(weapon.mode+1);
	if Input.is_action_just_pressed("shift_weapon_negative"):
		weapon.set_mode(weapon.mode-1);
	
	# ----------------------------------
	# Firing the weapons
	if Input.is_action_pressed("fire"):
		if not UI_codeintro.visible:
			attack()

	# ----------------------------------

# Procesamos las entradas genéricas
func process_input(delta):
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------


# Entradas tipo mouse
func _input(event):
	if health <= 0: 
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -90, 70)
		rotation_helper.rotation_degrees = camera_rot
		
		# Esta función controla la inclinación del torso del personaje
		# Sirve para apuntar el arma verticalmente
		# Es una forma más bien práctica de hacerlo, no es del todo correcta
		# pero queda bien estéticamente.
		var newpose = bone_spine_pose.rotated(Vector3(1.0, 0.0, 0.0), deg2rad(camera_rot.x))
		skeleton.set_bone_pose(bone_spine, newpose)
		# Nota: Para que el código anterior funcione se tuvo que desactivar
		# la influencia de la animación sobre el hueso correspondiente simplemente
		# destildando la casilla de verificación (en este caso spine_2)


func died():
	$Superior_CollisionShape.disabled = true
	$Inferior_CollisionShape.disabled = true
	print("player died")

var snd_pain = preload("res://player/sounds/pain1.wav")
var res_audioplayer = preload("res://3D_Audio_Player.tscn")
func pain(damage):
	var audioplayer = res_audioplayer.instance()
	audioplayer.stream = snd_pain
	audioplayer.pitch_scale = 1.1 - randf()*0.2
	add_child(audioplayer)

# El traje
# Este es un traje protector futurista
func process_main(delta):
	if health <= 0:
		UI_deathscreen.color.a += 0.2*delta
		if UI_deathscreen.color.a >= 1.0:
			UI_deathscreen.color.a = 1.0
		UI_deathscreen.color = Color(UI_deathscreen.color.r, UI_deathscreen.color.g, UI_deathscreen.color.b, UI_deathscreen.color.a)
		UI_deathscreen.visible = true
		return
	
	energy = int(energy) + 1
	if energy > 999:
		energy = 999
		
	# Actualizamos la visual
	UI_status_label.text = 'Suit: ' + str(energy)

	if message_time < 0:
		UI_panel_mensaje.visible = false
		message_time = 0
	elif message_time > 0:
		message_time -= delta
		if message_time == 0:
			message_time = -1



var message_time = 0.0
var snd_message = preload("res://fx/sounds/info.wav")
func screenprint(mensaje: String):
	message_time = 5.0
	UI_mensaje.text = mensaje
	UI_panel_mensaje.visible = true
	var audioplayer = res_audioplayer.instance()
	audioplayer.stream = snd_message
	add_child(audioplayer)


func ui_codeintro_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UI_codeintro.visible = true
	UI_code.text = ''

func ui_button0():
	UI_code.text += str(0)
	ui_codeintro_check()
func ui_button1():
	UI_code.text += str(1)
	ui_codeintro_check()
func ui_button2():
	UI_code.text += str(2)
	ui_codeintro_check()
func ui_button3():
	UI_code.text += str(3)
	ui_codeintro_check()
func ui_button4():
	UI_code.text += str(4)
	ui_codeintro_check()
func ui_button5():
	UI_code.text += str(5)
	ui_codeintro_check()
func ui_button6():
	UI_code.text += str(6)
	ui_codeintro_check()
func ui_button7():
	UI_code.text += str(7)
	ui_codeintro_check()
func ui_button8():
	UI_code.text += str(8)
	ui_codeintro_check()
func ui_button9():
	UI_code.text += str(9)
	ui_codeintro_check()

var snd_button = preload("res://fx/sounds/button.wav")
func ui_codeintro_check():
	var audioplayer = res_audioplayer.instance()
	audioplayer.stream = snd_button
	add_child(audioplayer)
	if trampa_panel == null:
		ui_codeintro_hide()
	if UI_code.text.length() >= 4:
		trampa_panel.entercodigo(self, str2var(UI_code.text))
		ui_codeintro_hide()

func ui_codeintro_hide():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	UI_codeintro.visible = false
	UI_code.text = ''
