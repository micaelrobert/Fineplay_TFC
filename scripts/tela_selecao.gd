extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Ajusta o eixo de escala para o centro dos botões 
	# (Isso faz com que eles cresçam a partir do meio, e não do canto superior esquerdo)
	$BtnFormas.pivot_offset = $BtnFormas.size / 2
	$BtnPontos.pivot_offset = $BtnPontos.size / 2
	$BtnOrdenar.pivot_offset = $BtnOrdenar.size / 2 # <-- ADICIONADO AQUI!
	$BtnVoltar2.pivot_offset = $BtnVoltar2.size / 2

# ==========================================
# BOTÃO: FORMAS E CORES
# ==========================================
func _on_btn_formas_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property($BtnFormas, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnFormas.modulate = Color(0.8, 0.8, 0.8) 
	
	await tween.finished 
	get_tree().change_scene_to_file("res://scenes/NivelEscola.tscn")

func _on_btn_formas_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnFormas, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_formas_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnFormas, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnFormas.modulate = Color(1, 1, 1)

# ==========================================
# BOTÃO: LIGUE OS PONTOS
# ==========================================
func _on_btn_pontos_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property($BtnPontos, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnPontos.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/NivelLigarFrutas.tscn")

func _on_btn_pontos_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnPontos, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_pontos_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnPontos, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnPontos.modulate = Color(1, 1, 1)

# ==========================================
# BOTÃO: ORDENAR
# ==========================================
func _on_btn_ordenar_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	# <-- CORRIGIDO AQUI (antes estava $BtnPontos)
	tween.tween_property($BtnOrdenar, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnOrdenar.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/NivelOrdenacao.tscn")

func _on_btn_ordenar_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnOrdenar, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_ordenar_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnOrdenar, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnOrdenar.modulate = Color(1, 1, 1)

# ==========================================
# BOTÃO: VOLTAR
# ==========================================
func _on_btn_voltar_2_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property($BtnVoltar2, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnVoltar2.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

func _on_btn_voltar_2_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnVoltar2, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_voltar_2_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnVoltar2, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnVoltar2.modulate = Color(1, 1, 1)
