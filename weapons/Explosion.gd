extends Spatial

var DAMAGE = 600 # Daño máximo en el centro de la explosión
var attacker = null # Quien provoca el daño

var freetime = 2 # Tiempo que dura la explosión
var explotime = 0.1

var blast_area
var col_shape
var bodies = Array()

var res_audioplayer = preload("res://3D_Audio_Player.tscn")
var snd_explo = preload("res://weapons/sounds/powerexplo.wav")

func _ready():
	$ExploCorona.emitting = true
	$Chispas.emitting = true

func _process(delta):
	freetime -= delta
	if freetime <= 0:
		queue_free()

	explotime -= delta
	if explotime > 0:
		return

	if $Blast_Area/Collision_Shape.disabled == true:
		return
	
	var audio = res_audioplayer.instance()
	audio.stream = snd_explo
	add_child(audio)
	var bodies = $Blast_Area.get_overlapping_bodies()
	for body in bodies:
		var dmg
		var distance
		if body.has_method("do_damage"):
			# Una explosión no te puede impactar a travez de las paredes u otros objetos
			var RayCheck: RayCast = $Blast_Area/RayCast
			RayCheck.look_at(body.global_transform.origin, Vector3(0, 1, 0))
			RayCheck.force_raycast_update()
			var collider = RayCheck.get_collider()
			if (collider != null) and (collider != body):
				continue
			
			distance = (body.global_transform.origin - global_transform.origin).length()
			dmg = DAMAGE / distance
			body.do_damage(dmg, global_transform, attacker, body.global_transform.looking_at(global_transform.origin, Vector3(0,1,0)).basis.z.normalized() * dmg / 4)
			print("Explo Collided: ", body.name, " Damage: ", dmg)
	
	$Blast_Area/Collision_Shape.disabled = true
	$OmniLight.visible = false
