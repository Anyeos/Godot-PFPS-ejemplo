extends StaticBody

var dead = false

var health = 600

var Luz: Light
var LuzMeshOn: MeshInstance
var LuzMeshOff: MeshInstance

var chispa_pos: Vector3
var is_on = true

func _ready():
	Luz = $Light
	LuzMeshOn = $LuzTechoOn
	LuzMeshOff = $LuzTechoOff

	if not is_on:
		died()
	else:
		LuzMeshOff.visible = false

	chispa_pos = Vector3(1-randf()*2, 0, 1 - int(randf()))

func do_damage(damage, dmg_global_trans, attacker = null, impulse = Vector3(0,0,0)):
	if dead:
		return

	health = health - damage

	if health <= 0:
		died()
	#else:
	#	pain(damage)

var res_chispa = preload("res://level/Objetos/ChispaLuz.tscn")
var t = 0.0
func _process(delta):
	if not dead:
		return
	
	t -= delta
	if t <= 0:
		var chispa = res_chispa.instance()
		$ChispaPoint.add_child(chispa)
		chispa.translate(chispa_pos)
		t = randf()*5
	

var res_material_off = preload("res://level/Objetos/Luz_off.material")
func died():
	dead = true
	LuzMeshOff.visible = true
	remove_child(Luz)
	remove_child(LuzMeshOn)
