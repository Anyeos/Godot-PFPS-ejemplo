extends AudioStreamPlayer3D
# Este es el reproductor de sonido que se ubica en un lugar del mundo del juego
# Para usarser debe instanciarse y pasarle la ubicación global y el stream del
# sonido

var free = false

func _process(delta):
	if free and not playing:
		queue_free()
	if not playing:
		play()
	free = true
