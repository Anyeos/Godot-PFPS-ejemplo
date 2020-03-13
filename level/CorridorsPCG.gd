extends Spatial
# Este es el generador del nivel
# Usa una técnica sencilla basada en bloques que definen un camino
# a modo de pasillo el cual tiene alguna variante de vez en cuando


var player: Player
var scene_root: Node = null

var res_player = preload("res://player/Player.tscn")
func _ready():
	#player = $Player
	#rand_w =  703844970
	
	# Cargamos los valores de saved_pcg
	var file = File.new()
	if file.open("user://save_game.dat", File.READ) == OK:
		print("Loading saved game.")
		saved_pcg = file.get_var()
		print("loaded saved_pcg: ", saved_pcg)
		file.close()


var time = 0.0
func _process(delta):
	time -= delta
	if scene_root == null:
		valores_iniciales()
		scene_root = get_tree().root.get_children()[0]
		player = res_player.instance()
		player.health = 100
		player.rotate(Vector3(0, 1, 0), PI*0.5)
		scene_root.add_child(player)
	
	if player.health <= 0:
		if player.UI_deathscreen.color.a >= 1.0:
			player.queue_free()
			scene_root = null
			while(index > 0):
				index -= 1
				if bloques[index] != null:
					if bloques[index] is PasilloSeguridad:
						copy_saved_pcg(bloques[index].saved_pcg, saved_pcg)
						print("saved_pcg: ", saved_pcg)
					print("borrando index: ", index)
					bloques[index].queue_free()
		return
	
	if time <= 0:
		time = 0.1
		generar()


const Norte = 1
const Sur = 2
const Este = 3
const Oeste = 4

const TIPO_PASILLO = 0
const TIPO_1HAB = 1
const TIPO_2HAB = 2
const TIPO_PASILLOSEG = 3
const TIPO_ESQUINA = 4

var dir = Este
var giro_dir = Este
var tipo = TIPO_PASILLOSEG
var llave_codigo = 0
var colocar_llave = false

var bloques = {}
var index = 0
var first_index = 0

var tipo_seg = 0

func valores_iniciales():
	dir = Este
	giro_dir = Este
	tipo = TIPO_PASILLOSEG
	llave_codigo = 0
	colocar_llave = false
	bloques = {}
	index = 0
	first_index = 0
	tipo_seg = 0
	time = 0.0
	pos = Vector3(0,0,0)

var angulos = {
	Norte: 90,
	Sur: 270,
	Este: 0,
	Oeste: 180,
}

var Pasillo_res = preload("res://level/blocks/Pasillo.tscn")
var Hab1_res = preload("res://level/blocks/Hab1.tscn")
var Hab2_res = preload("res://level/blocks/Hab2.tscn")
var PasilloSeg_res = preload("res://level/blocks/PasilloSeguridad.tscn")
var Esquina_res = preload("res://level/blocks/Curva.tscn")

var tipos = [
	Pasillo_res,
	Hab1_res,
	Hab2_res,
	PasilloSeg_res,
	Esquina_res,
	]

var pos = Vector3(0,0,0)
#const escala = 1
func generar():
	if tipo_seg >= 3:
		return

	print("generando: ", tipo, " index: ", index)
	var bloque = tipos[tipo].instance()
	bloques[index] = bloque
	
	# Pasillo de seguridad
	if tipo == TIPO_PASILLOSEG:
		tipo_seg += 1
		saved_pcg.recto = 2
		bloque.generador = self
		bloque.index = index
		bloque.first_index = first_index
		bloque.codigo = llave_codigo
		copy_saved_pcg(saved_pcg, bloque.saved_pcg)
		print("bloque.saved_pcg: ", bloque.saved_pcg)
		llave_codigo = 0
		first_index = index
	
	# 26 es el tamaño del bloque (26x26 unidades)
	bloque.translate(pos * 26);
	#bloque.global_translate(pos * 26 * escala);
	#bloque.scale_object_local(Vector3(escala, escala, escala))
	
	if tipo == TIPO_ESQUINA:
		bloque.rotate( Vector3(0, 1, 0), deg2rad(angulos[giro_dir]) )
	elif tipo == TIPO_1HAB:
		bloque.rotate( Vector3(0, 1, 0), deg2rad(angulos[dir] + (180 if (randpcg() < 0.5) else 0)) )
	else:
		bloque.rotate( Vector3(0, 1, 0), deg2rad(angulos[dir]) )
	
	scene_root.add_child(bloque)
	
	colocar_luces(bloque)
	
	if randpcg() < 0.8:
		colocar_objetos(bloque)
	
	if colocar_llave:
		colocar_llave(bloque)
		colocar_llave = false
	
	avanzar()
	cambiar_tipo()
	
	index += 1

func cambiar_tipo():
	if saved_pcg.recto > 0:
		if (llave_codigo != 0) and (randpcg() < 0.33):
			tipo = TIPO_PASILLOSEG
		else:
			tipo = int (randpcg()*2.5)
		
		if (llave_codigo == 0) and ((tipo == TIPO_1HAB) or (tipo == TIPO_2HAB)) and (randpcg() < 0.5):
			llave_codigo = int( rand_range(1111, 9999) )
			colocar_llave = true
			
		saved_pcg.recto -= 1
	else:
		girar()
		tipo = TIPO_ESQUINA
		saved_pcg.recto = int ( randpcg()*3 )

func girar():
	match dir:
		Norte:
			dir = Este
			giro_dir = Norte
		Sur:
			dir = Este
			giro_dir = Oeste
		Este:
			dir = Sur if (randpcg() < 0.50) else Norte
			if dir == Sur:
				giro_dir = Este
			else:
				giro_dir = Sur

func avanzar():
	match dir:
		Norte:
			pos.z -= 1
		Sur: 
			pos.z += 1
		Este:
			pos.x += 1
		Oeste:
			pos.x -= 1



var res_caja = preload("res://level/Objetos/Caja.tscn")
func colocar_objetos(bloque):
	var startpos: Vector3

	# Colocamos alguna caja por ahí
	if randpcg() < 0.2:
		var caja = res_caja.instance()
		if tipo == TIPO_ESQUINA:
			startpos = Vector3(4-randpcg()*8, 1, 4-randpcg()*8)
		else:
			startpos = Vector3(10-randpcg()*20, 1, 4-randpcg()*8)
		bloque.add_child(caja)
		caja.translate(startpos)

	# Colocamos cajas en las habitaciones
	if (tipo == TIPO_1HAB):
		startpos = Vector3(1-randpcg()*6, 1, 11)
		colocar_cajas(bloque, startpos)
	if (tipo == TIPO_2HAB):
		startpos = Vector3(1-randpcg()*6, 1, 11)
		colocar_cajas(bloque, startpos)
		startpos = Vector3(1-randpcg()*6, 1, -11)
		colocar_cajas(bloque, startpos)

func colocar_cajas(bloque, startpos):
	for x in range(3):
		for y in range(3):
			if randpcg() < 0.5:
				var caja = res_caja.instance()
				bloque.add_child(caja)
				caja.translate(startpos + Vector3(x*1.2, y, 0))


# Colocamos la llave
var res_cuerpo = preload("res://level/Objetos/Cuerpo.tscn")
func colocar_llave(bloque):
	var startpos: Vector3
	var cuerpo = res_cuerpo.instance()
	startpos = Vector3(1-randpcg()*2, 0, 9)
	if (tipo == TIPO_2HAB) and (randpcg() < 0.5):
		startpos = Vector3(1-randpcg()*2, 0, -9)
	
	bloque.add_child(cuerpo)
	cuerpo.codigo = llave_codigo
	cuerpo.translate(startpos)
	
	#player = res_player.instance()
	#bloque.add_child(player)


var res_luz = preload("res://level/Objetos/Luz.tscn")
func colocar_luces(bloque):
	var luz = res_luz.instance()
	luz.is_on = (randpcg() < 0.25)
	bloque.add_child(luz)
	if tipo == TIPO_1HAB:
		luz = res_luz.instance()
		luz.is_on = (randpcg() < 0.25)
		bloque.add_child(luz)
		luz.translate(Vector3(0, 0, 9))
	elif tipo == TIPO_2HAB:
		luz = res_luz.instance()
		luz.is_on = (randpcg() < 0.25)
		bloque.add_child(luz)
		luz.translate(Vector3(0, 0, 9))
		luz = res_luz.instance()
		luz.is_on = (randpcg() < 0.25)
		bloque.add_child(luz)
		luz.translate(Vector3(0, 0, -9))


# Estructura para almacenar (guardar la partida)
var saved_pcg = {
	x=396518359, 
	y=1057367412, 
	z=1137137296, 
	w=207911077,
	recto = 2,
	}
func copy_saved_pcg( src = {}, dst = {}):
	dst.x = src.x
	dst.y = src.y
	dst.z = src.z
	dst.w = src.w
	dst.recto = src.recto

# Una función de random predecible, muy predecible :-D
# Para poder generar el mismo nivel si se usan los mismos valores de
# inicialización.
func randpcg():
	var t = saved_pcg.x ^ ((saved_pcg.x << 11) & 0xFFFFFFFF)  # 32bit
	saved_pcg.x = saved_pcg.y
	saved_pcg.y = saved_pcg.z
	saved_pcg.z = saved_pcg.w
	saved_pcg.w = (saved_pcg.w ^ (saved_pcg.w >> 19)) ^ (t ^ (t >> 8))
	return float(saved_pcg.w) / float(0xFFFFFFFF)

#var rand_x = 123456789
#var rand_y = 362436069
#var rand_z = 521288629
#var rand_w = 88675123
#func randpcg_orig():
#	var t = rand_x ^ ((rand_x << 11) & 0xFFFFFFFF)  # 32bit
#	rand_x = rand_y
#	rand_y = rand_z
#	rand_z = rand_w
#	rand_w = (rand_w ^ (rand_w >> 19)) ^ (t ^ (t >> 8))
#	return float(rand_w) / float(0xFFFFFFFF)
