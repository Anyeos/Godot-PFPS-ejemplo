extends Spatial

class_name PasilloSeguridad

var continued = false
var door_closed = true
var generador
var index = 0
var first_index = 0
var codigo = 0
var saved_pcg = {x=0, y=0, z=0, w=0, recto=0}


func _ready():
	$Continue.connect("body_entered", self, "continue_game")
	print("Tipo3 ready. index: ", index, " first_index: ", first_index, " saved_pcg: ", saved_pcg)
	
func continue_game(body):
	if not body is Player:
		return
	
	if continued:
		return
	
	if not door_closed:
		return
	
	if first_index == index:
		return

	# Salvamos los valores de saved_pcg
	var file = File.new()
	print("Saving game...")
	file.open("user://save_game.dat", File.WRITE)
	file.store_var(saved_pcg)
	print("Saved game saved_pcg: ", saved_pcg)
	file.close()

	continued = true
	var n = first_index
	print("Tipo3 borrando, index: ", index, " first_index: ", first_index)
	while(n < index):
		print("borrando index: ", n)
		generador.bloques[n].queue_free()
		generador.bloques[n] = null
		n+=1
	generador.tipo_seg -= 1
