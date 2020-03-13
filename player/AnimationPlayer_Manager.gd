# Este es el script de AnimationPlayer del ejemplo práctico de FPS
# A diferencia del ejemplo oficial de Godot, acá no necesitamos mucho

extends AnimationPlayer

var current = ""

var res_soundplayer = preload("res://3D_Audio_Player.tscn")

# Nota: Este script no sólo se usa en el jugador, así que usamos una nominación
# genérica de las animaciones: Idle, Run, Jump, Crouch, CWalk, Death
func _ready():
	set_animation("Idle")
	connect("animation_finished", self, "animation_ended")

# Esta función establece la animación. Es similar a la del ejemplo de Godot
# pero no necesitamos más que este pequeño código.
func set_animation(animation_name):
	if (current == animation_name):
		return false
	# Si está muerto no podemos cambiar ninguna animación
	if (current == "Death"):
		return false
	current = animation_name
	# Usamos un valor de "blending" de 0.05 para que el cambio de animación
	# no sea brusco, especialmente al dejar de correr.
	play(current, 0.05, 1)
	return true

# Si está ejecutando una animación no cíclica.
func is_one_time():
	if current == "Death": # Murió
		return true
	if (current == "Landing") and is_playing(): # Cayó al suelo y está recomponiéndose
		return true
	if (current == "Pain") and is_playing(): # Sufre por algún golpe
		return true
	return false

func animation_ended(animation_name):
	if current == "Run":
		# Acá usamos un blending también para evitar el efecto de movimiento
		# brusco producido por un problema práctico de que la animación
		# no termina exactamente como empezó
		play(current, 0.1, 1)
	elif current == "Idle":
		play(current, -1, 1)
	else:
		stop() # Detenemos la reproducción porque sino cambia a otra

func sound_step_left():
	var soundplayer = res_soundplayer.instance()
	soundplayer.stream = owner.snd_footsteps[int(randf()*3.5)]
	get_node("../SoundStepLeft").add_child(soundplayer)
func sound_step_right():
	var soundplayer = res_soundplayer.instance()
	soundplayer.stream = owner.snd_footsteps[int(randf()*3.5)]
	get_node("../SoundStepRight").add_child(soundplayer)
