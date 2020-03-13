extends KinematicBody

var DAMAGE = 15

var time_alive = 10

var hit = false
var bigball = false

# Estas dos variables hay que llenarlas desde el arma
var attacker = null # Quien disparó
var weapon = null # Desde qué arma se disparó

var forward_dir = Vector3(0, 0, 0)

func _ready():
	pass

var collision
func _physics_process(delta):
	collision = move_and_collide(forward_dir * 1000 / DAMAGE * delta, false, true, true)
	if collision and (collision.collider.get_class() != "EnergyBall"):
		move_and_collide(forward_dir * 1000 / DAMAGE * delta, false, true, false)
		collided(collision.collider)
	else:
		global_translate(forward_dir * 1000 / DAMAGE * delta)

	time_alive -= delta
	if time_alive < 0:
		queue_free()

func get_class(): return "EnergyBall"

func collided(body):
	# Sólo colisiona una vez
	if hit == true:
		return

	if body.has_method("do_damage"):
		body.do_damage(DAMAGE, global_transform, attacker, global_transform.basis.z.normalized() * DAMAGE / 4)

	# Si es la esfera grande explota
	if bigball == true:
		explode()
	else:
		chispa()
	
	#print("Collided: ", body.name)
	hit = true
	queue_free()

var explo_scene = preload("Explosion_Scene.tscn")
func explode():
	var scene_root = get_tree().root.get_children()[0]
	var explo = explo_scene.instance()
	explo.global_transform = global_transform
	explo.attacker = attacker
	scene_root.add_child(explo)

var impacto_res = preload("res://weapons/EnergyImpacto.tscn")
func chispa():
	var scene_root = get_tree().root.get_children()[0]
	var impacto = impacto_res.instance()
	impacto.global_transform = global_transform
	scene_root.add_child(impacto)
