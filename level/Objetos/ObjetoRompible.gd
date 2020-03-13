# Lo mismo que como hicimos con la clase Personaje pero para RigidBody
# Sirve para hacer objetos rompibles o que reciben daño y explotan ;)

extends RigidBody

class_name ObjetoRompible

var health = 0

func _ready():
	pass

func do_damage(damage, dmg_global_trans, attacker = null, impulse = Vector3(0,0,0)):
	apply_impulse((dmg_global_trans.origin - global_transform.origin).normalized(), impulse)

	health = health - damage

	if health <= 0:
		died()
	else:
		pain(damage)


# Override this
func pain(damage):
	pass

# Override this
func died():
	pass


