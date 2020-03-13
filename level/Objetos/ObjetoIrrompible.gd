extends RigidBody

class_name UnbreackableRigid

func do_damage(damage, dmg_global_trans: Transform, attacker = null, impulse = Vector3(0,0,0)):
	apply_impulse( (dmg_global_trans.origin - global_transform.origin).normalized(), impulse)
