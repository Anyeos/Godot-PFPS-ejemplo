extends MeshInstance

var enemigo: Personaje
var Vision: RayCast
var ShootPoint: Position3D
var Target: Position3D
var health = 1000
var dead = false

func _ready():
	$Area.connect("body_entered", self, "enemigo_entered")
	
	ShootPoint = $ShootPoint
	
	Vision = $Vision
	Vision.add_exception(self)
	
	Target = get_parent().get_node("Target")

var search_time = 0.0
var dontshoot = true
var t_rot = 0.0
func _process(delta):
	if t_rot < 1:
		t_rot += 0.5*delta
	rotation = rotation.linear_interpolate(Target.rotation, t_rot)
	
	var lista = get_parent().lista
	if not lista:
		Target.rotation = Vector3(0,0,0)
		return

	if not enemigo:
		return
		
	if health <= 0:
		return

	if (enemigo.global_transform.origin - global_transform.origin).length() > 60:
		enemigo = null
		get_parent().cerrar()
		return
	
	search_time -= delta
	if not dontshoot: shoot(delta)
	if search_time <= 0:
		Target.look_at(enemigo.global_transform.origin+Vector3(0, 1.3, 0), Vector3(0,1,0))
		Target.rotate_object_local(Vector3(0,1,0), PI)
		t_rot = 0.0
		#$Tween.interpolate_property(self, "rotation", rotation, Target.rotation, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		#$Tween.start()
		
		Vision.force_raycast_update()
		if Vision.get_collider() != enemigo:
			#print("dontshoot: ", Vision.get_collider())
			dontshoot = true
		else:
			dontshoot = false
		
		search_time = 0.25


func enemigo_entered(body):
	if not body is Personaje:
		return
	var lista = get_parent().lista
	if not lista:
		if get_parent().activa:
			get_parent().abrir()
	enemigo = body

var shoottime = 0.0
var res_bullet = preload("res://weapons/EnergyBall_Scene.tscn")
var snd_shot = preload("res://weapons/sounds/gunshot.wav")
var res_audioplayer = preload("res://3D_Audio_Player.tscn")
func shoot(delta):
	shoottime -= delta
	if shoottime <= 0:
		var dir = ShootPoint.global_transform.basis.z.normalized()
		var bullet = res_bullet.instance()

		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(bullet)
		
		bullet.global_transform = ShootPoint.global_transform
		bullet.forward_dir = dir
				
		bullet.attacker = self
		bullet.weapon = self

		bullet.scale = Vector3(0.2, 0.2, 0.2)
		bullet.DAMAGE = 15
		
		var audioplayer = res_audioplayer.instance()
		audioplayer.stream = snd_shot
		add_child(audioplayer)
		
		shoottime = 0.1

func do_damage(damage, dmg_global_trans, attacker = null, impulse = Vector3(0,0,0)):
	if dead:
		return
	health = health - damage
	if health <= 0:
		died()

func died():
	dead = true
	pass
