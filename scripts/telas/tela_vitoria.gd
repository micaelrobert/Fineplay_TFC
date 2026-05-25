extends CanvasLayer

const BASE_SIZE := Vector2(720, 1280)

var caminho_proxima_fase: String = ""

@onready var ui_responsiva: Control = $UIResponsiva
@onready var fundo_responsivo: Control = $UIResponsiva/FundoResponsivo
@onready var center_container: CenterContainer = $UIResponsiva/CenterContainer
@onready var area_jogo: Control = $UIResponsiva/CenterContainer/AreaJogo

@onready var btn_proximo: Control = $UIResponsiva/CenterContainer/AreaJogo/BtnProximo
@onready var btn_reiniciar: Control = $UIResponsiva/CenterContainer/AreaJogo/BtnReiniciar
@onready var btn_menu: Control = $UIResponsiva/CenterContainer/AreaJogo/BtnMenu


func _ready() -> void:
	get_viewport().size_changed.connect(_ajustar_responsivo)
	call_deferred("_ajustar_responsivo")

	await get_tree().process_frame
	
	btn_proximo.pivot_offset = btn_proximo.size / 2
	btn_reiniciar.pivot_offset = btn_reiniciar.size / 2
	btn_menu.pivot_offset = btn_menu.size / 2


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	# Faz a camada de UI ocupar a tela real do dispositivo.
	ui_responsiva.position = Vector2.ZERO
	ui_responsiva.size = tamanho_tela

	# Fundo/overlay ocupa a tela inteira.
	fundo_responsivo.position = Vector2.ZERO
	fundo_responsivo.size = tamanho_tela

	# CenterContainer ocupa a tela real para centralizar a AreaJogo.
	center_container.position = Vector2.ZERO
	center_container.size = tamanho_tela

	# AreaJogo permanece como o "celular virtual" base.
	area_jogo.custom_minimum_size = BASE_SIZE
	area_jogo.size = BASE_SIZE

	# Força o container a recalcular a centralização.
	center_container.queue_sort()


func configurar(proxima_fase: String) -> void:
	caminho_proxima_fase = proxima_fase
	
	if caminho_proxima_fase == "":
		btn_proximo.visible = false
	else:
		btn_proximo.visible = true


# ==========================================
# BOTÃO: PRÓXIMO NÍVEL
# ==========================================
func _on_btn_proximo_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property(btn_proximo, "scale", Vector2(0.9, 0.9), 0.1)
	btn_proximo.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	
	if caminho_proxima_fase != "":
		get_tree().change_scene_to_file(caminho_proxima_fase)


func _on_btn_proximo_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_proximo, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_proximo_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_proximo, "scale", Vector2(1.0, 1.0), 0.1)
	btn_proximo.modulate = Color(1, 1, 1)


# ==========================================
# BOTÃO: REINICIAR
# ==========================================
func _on_btn_reiniciar_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property(btn_reiniciar, "scale", Vector2(0.9, 0.9), 0.1)
	btn_reiniciar.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	
	get_tree().reload_current_scene()


func _on_btn_reiniciar_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_reiniciar, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_reiniciar_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_reiniciar, "scale", Vector2(1.0, 1.0), 0.1)
	btn_reiniciar.modulate = Color(1, 1, 1)


# ==========================================
# BOTÃO: MENU PRINCIPAL
# ==========================================
func _on_btn_menu_pressed() -> void:
	AudioManager.play_click_ui()
	
	var tween = create_tween()
	tween.tween_property(btn_menu, "scale", Vector2(0.9, 0.9), 0.1)
	btn_menu.modulate = Color(0.8, 0.8, 0.8)
	
	await tween.finished
	
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")


func _on_btn_menu_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_menu, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_menu_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_menu, "scale", Vector2(1.0, 1.0), 0.1)
	btn_menu.modulate = Color(1, 1, 1)
