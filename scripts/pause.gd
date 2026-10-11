extends Control

func pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func _on_continuar_pressed() -> void:
	pause() # Esto quita la pausa y oculta el menú

func _on_opciones_pressed() -> void:
	pass # Replace with function body.

func _on_menú_principal_pressed() -> void:
	# 1. ¡OBLIGATORIO! Apagamos la pausa primero para que la nueva escena no nazca congelada
	get_tree().paused = false
	
	# 2. Ahora sí, cambiamos de escena de forma segura
	get_tree().change_scene_to_file("res://scenes/ui/inicio.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()
