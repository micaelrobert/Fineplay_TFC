extends CanvasLayer

# Variável que vai receber o endereço da próxima fase
var caminho_proxima_fase: String = ""

func _ready():
	# Ajusta o eixo de escala para o centro dos botões para a animação ficar perfeita
	$BtnProximo.pivot_offset = $BtnProximo.size / 2
	$BtnReiniciar.pivot_offset = $BtnReiniciar.size / 2
	$BtnMenu.pivot_offset = $BtnMenu.size / 2
	
	# Pausa o jogo lá trás para a criança não mexer em mais nada
	# get_tree().paused = true

func configurar(proxima_fase: String):
	caminho_proxima_fase = proxima_fase
	
	# se nao tiver prox fase, esconde o botao de prox
	if caminho_proxima_fase == "":
		$BtnProximo.visible = false

# ==========================================
# BOTÃO: PRÓXIMO NÍVEL
# ==========================================
func _on_btn_proximo_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property($BtnProximo, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnProximo.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	
	if caminho_proxima_fase != "":
		get_tree().change_scene_to_file(caminho_proxima_fase)

func _on_btn_proximo_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnProximo, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_proximo_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnProximo, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnProximo.modulate = Color(1, 1, 1)

# ==========================================
# BOTÃO: REINICIAR (JOGAR NOVAMENTE)
# ==========================================
func _on_btn_reiniciar_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property($BtnReiniciar, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnReiniciar.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	
	get_tree().reload_current_scene()

func _on_btn_reiniciar_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnReiniciar, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_reiniciar_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnReiniciar, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnReiniciar.modulate = Color(1, 1, 1)

# ==========================================
# BOTÃO: MENU PRINCIPAL
# ==========================================
func _on_btn_menu_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property($BtnMenu, "scale", Vector2(0.9, 0.9), 0.1)
	$BtnMenu.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

func _on_btn_menu_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($BtnMenu, "scale", Vector2(1.05, 1.05), 0.1)

func _on_btn_menu_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($BtnMenu, "scale", Vector2(1.0, 1.0), 0.1)
	$BtnMenu.modulate = Color(1, 1, 1)
