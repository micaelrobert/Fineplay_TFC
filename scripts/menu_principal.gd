extends Control

@onready var som_click_ui = $GerenciadorDeSons/SomClick 




func _on_botao_jogar_pressed():
	som_click_ui.play()
	
	await get_tree().create_timer(0.2).timeout  

	get_tree().change_scene_to_file("res://scenes/telaSelecao/TelaSelecao.tscn")
