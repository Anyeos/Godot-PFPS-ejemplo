extends Spatial

const DAMAGE = {
	0:15,
	1:15,
	2:30,
}
const TIME = {
	0:100,
	1:1000,
	2:3000,
}

const SCALE = {
	0:Vector3(.2, .2, .2),
	1:Vector3(.2, .2, .2),
	2:Vector3(.7, .7, .7),
}

var is_enabled = false

var bullet_scene = preload("EnergyBall_Scene.tscn")

var attacker = null # Quien usa el arma (debe llenarse desde el portador del arma)
var mode = 0 # Modo del arma
var nexttime = 0 # Para controlar el tiempo de disparo

var snd_gunshot = preload("res://weapons/sounds/gunshot.wav")
var snd_powergun = preload("res://weapons/sounds/powergun.wav")
var res_audioplayer = preload("res://3D_Audio_Player.tscn")

func _ready():
	pass

func single_shoot(forward_dir):
		var bullet = bullet_scene.instance()
	
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(bullet)
		
		bullet.global_transform = global_transform
		bullet.forward_dir = forward_dir
		
		bullet.attacker = attacker
		bullet.weapon = self
		
		var audioplayer = res_audioplayer.instance()
		add_child(audioplayer)
		if mode == 2:
			bullet.bigball = true
			audioplayer.stream = snd_powergun
		else:
			audioplayer.stream = snd_gunshot
			pass
		
		bullet.scale = SCALE[mode]
		bullet.DAMAGE = DAMAGE[mode]
	
func multi_shoot( forward_dir: Vector3, amount: int ):
	var dir: Vector3
	for n in range(amount):
		dir = forward_dir
		var ang = float(n) / amount * 2.0*PI
		#print("ang: ", sin(ang), " | ", cos(ang))
		dir += global_transform.basis.x.normalized() * sin(ang) * (0.025 - randf()*0.02)
		dir += global_transform.basis.y.normalized() * cos(ang) * (0.025 - randf()*0.02)
		# + global_transform.basis.x.normalized() * (0.01 - randf()*0.02) + global_transform.basis.y.normalized() * (0.01 - randf()*0.02)
		single_shoot(dir)

# Lo ideal sería que el jugador mueva el arma con las manos apuntando al centro
# de la pantalla. Pero como el arma está un poco hacia la derecha lo que 
# tendríamos que hacer es trazar un rayo desde el centro y utilizar el lugar de
# colisión del rayo como objetivo.
func shoot():
	var energy_load = DAMAGE[mode]*TIME[mode] / 200
	if attacker.energy < energy_load:
		return
	if nexttime <= OS.get_ticks_msec():
		# Puntería corregida disparando con respecto a un objetivo y no al cañón
		var AimRay: RayCast = attacker.AimRay
		AimRay.force_raycast_update()
		var aimpoint = AimRay.get_collision_point()
		var forward_dir = global_transform.basis.z.normalized()
		if AimRay.get_collider() != null:
			forward_dir = (aimpoint - global_transform.origin).normalized()
		

		#print("Attacker: ", attacker.name)
		#var shoot_from = global_transform.origin
		if mode == 1:
			multi_shoot(forward_dir, 10)
		else:
			single_shoot(forward_dir)

		attacker.use_energy(energy_load)
		nexttime = OS.get_ticks_msec()+TIME[mode]

func set_mode(weapon_mode):
	mode = weapon_mode % 3
	return mode
