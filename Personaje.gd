# Hola, bienvenido al Ejemplo de FPS Procedural
# Este es el script de la clase Personaje. Acá va el código que son comunes a
# todo lo que es un personaje del juego (jugador, npc, monstruos, etc)

# Esta es una mejor forma de organizarse que ahorrará trabajo a la hora
# de añadir más tipos de enemigos al juego

# El ejemplo tiene algunos detalles que podrían mejorarse pero
# sirve a modo de ejemplo práctico.


extends KinematicBody

class_name Personaje


var health = 0
var energy = 0
var weapon = null
var animation: AnimationPlayer = null

var GRAVITY = -30
var vel: Vector3 = Vector3(0,0,0)
var dir: Vector3 = Vector3(0,0,0)

var MAX_SPEED = 12
var JUMP_SPEED = 12
var ACCEL = 3.0

var DEACCEL= 16
var MAX_SLOPE_ANGLE = 50

var skeleton: Skeleton = null
var collisions_attached = {}
var enemy = null

var snd_footsteps = [null, null, null, null]

func _physics_process(delta):
	move_collisions(delta) # Colisiones dinámicas
	process_movement(delta) # Física básica
	process_main(delta) # Otras acciones
	process_input(delta) # General input
	dir = Vector3(0, 0, 0) # Reset dir
	if health <= 0: # Muerto no puede controlarse
		return
	if animation.is_one_time():
		return
	process_control(delta) # Input Control


# La función que controla la física básica
# Esta es casi idéntica al ejemplo oficial
var old_vel = Vector3(0,0,0) # para saber a qué velocidad estábamos antes de chocar el suelo
var stoptimer = 0 # Tiempo para detenerse completamente cuando está en una rampa
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0

	var target = dir * MAX_SPEED

	var accel
	if dir != Vector3(0,0,0):
		accel = ACCEL
		stoptimer = 0.5
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	
	#print ("length=", vel.length())
	# Este código ayuda a detener al jugador cuando está en una rampa (slope)
	if vel.length() > 1.8:
		stoptimer = 0.5
	stoptimer -= delta
	if stoptimer <= 0:
		hvel.x = 0
		hvel.z = 0
	
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = move_and_slide(vel, Vector3(0, 1, 0), true, 3, deg2rad(MAX_SLOPE_ANGLE), false)

	# Esta es una estrategia práctica para controlar las animaciones del 
	# personaje.
	if (health <= 0) or animation.is_one_time():
		return
	if (vel.x != 0.0 or vel.y != 0.0 or vel.z != 0.0):
		if is_on_floor():
			animation.set_animation("Run")
		else:
			animation.set_animation("Jump")
	else:
		animation.set_animation("Idle")

	# Esta función agrega daño por impactar el suelo demasiado rápido
	if is_on_floor():
		if old_vel.y < -40:
			print("old_vel.y ", old_vel.y)
			animation.set_animation("Landing")
			do_damage(-old_vel.y * 3, global_transform)
			old_vel = Vector3(0,0,0)
		
	old_vel = vel

# Esta función es para mover las formas de colisión
func move_collisions(delta):
	var attached = collisions_attached.values()
	for n in range(attached.size()):
		attached[n][0].global_transform = attached[n][1].global_transform
	# collisions_attach debe contener Position3D que nos ayudará a colocar el
	# shape de colisión. Para lograrlo podemos añadir una figura visible similar
	# al shape como por ejemplo una esfera y dimensionarla visualmente
	# hasta que coincida con la forma del shape (en este caso una cápsula).
	# Luego movemos el Position3D hasta que coincida su centro con el de
	# la CollisionShape. Demás está decir que la collision shape deberá estar
	# ubicada gráficamente en su posición correcta según la forma que
	# queremos hacer colisionar.
	# Después ejecutamos el juego y vemos desde afuera (para eso corremos la
	# cámara también). Si la figura que acabamos de agregar está rotada 
	# incorrectamente entonces cambiamos la rotación del Position3D para corregir.

func do_damage(damage, dmg_global_trans, attacker = null, impulse = Vector3(0,0,0)):
	do_apply_impulse((dmg_global_trans.origin - global_transform.origin).normalized(), impulse)
	
	if health <= 0:
		return
	
	if attacker:
		enemy = attacker
	
	if energy > 0:
		energy = energy - damage
	else:
		health = health - damage
	
	if energy < 0:
		health = health + energy
	
	if health <= 0:
		animation.set_animation("Death")
		died()
	else:
		animation.set_animation("Pain")
		pain(damage)

func do_apply_impulse(offset, impulse):
	vel = vel + impulse

# Override this
func pain(damage):
	pass

# Override this
func died():
	pass

# Override this
func process_input(delta):
	pass

# Override this
func process_control(delta):
	pass

# Override this
func process_main(delta):
	pass

# Una función genérica para saltar
# Se puede hacer override de esta función si se requiere
func jump():
	vel.y = JUMP_SPEED

# Una función genérica para atacar
# Se puede hacer override sobre esta si se desea
func attack():
	if weapon:
		weapon.shoot()

func use_energy(amount):
	energy = energy - amount
