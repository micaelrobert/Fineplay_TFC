extends Control

const BASE_SIZE := Vector2(720, 1280)

@onready var fundo_responsivo: Control = $FundoResponsivo
@onready var center_container: CenterContainer = $CenterContainer
@onready var area_jogo: Control = $CenterContainer/AreaJogo

@onready var btn_formas = $CenterContainer/AreaJogo/BtnFormas
@onready var btn_pontos = $CenterContainer/AreaJogo/BtnPontos
@onready var btn_ordenar = $CenterContainer/AreaJogo/BtnOrdenar
@onready var btn_voltar = $CenterContainer/AreaJogo/BtnVoltar2


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_viewport().size_changed.connect(_ajustar_responsivo)
	call_deferred("_ajustar_responsivo")

	await get_tree().process_frame

	btn_formas.pivot_offset = btn_formas.size / 2
	btn_pontos.pivot_offset = btn_pontos.size / 2
	btn_ordenar.pivot_offset = btn_ordenar.size / 2
	btn_voltar.pivot_offset = btn_voltar.size / 2


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	# Faz a raiz ocupar a tela real do dispositivo.
	position = Vector2.ZERO
	size = tamanho_tela

	# Fundo ocupa a tela inteira.
	fundo_responsivo.position = Vector2.ZERO
	fundo_responsivo.size = tamanho_tela

	# CenterContainer ocupa a tela inteira real.
	center_container.position = Vector2.ZERO
	center_container.size = tamanho_tela

	# AreaJogo continua sendo o "celular virtual" 720x1280.
	area_jogo.custom_minimum_size = BASE_SIZE
	area_jogo.size = BASE_SIZE

	# Força o container a recalcular a centralização.
	center_container.queue_sort()


# ==========================================
# BOTÃO: FORMAS E CORES
# ==========================================
func _on_btn_formas_pressed() -> void:
	AudioManager.play_click_ui()

	var tween = create_tween()
	tween.tween_property(btn_formas, "scale", Vector2(0.9, 0.9), 0.1)
	btn_formas.modulate = Color(0.8, 0.8, 0.8)

	await tween.finished
	get_tree().change_scene_to_file("res://scenes/formas_e_cores/NivelEscola.tscn")


func _on_btn_formas_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_formas, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_formas_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_formas, "scale", Vector2(1.0, 1.0), 0.1)
	btn_formas.modulate = Color(1, 1, 1)


# ==========================================
# BOTÃO: LIGUE OS PONTOS
# ==========================================
func _on_btn_pontos_pressed() -> void:
	AudioManager.play_click_ui()

	var tween = create_tween()
	tween.tween_property(btn_pontos, "scale", Vector2(0.9, 0.9), 0.1)
	btn_pontos.modulate = Color(0.8, 0.8, 0.8)

	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ligue_os_pontos/NivelLigarFrutas.tscn")


func _on_btn_pontos_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_pontos, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_pontos_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_pontos, "scale", Vector2(1.0, 1.0), 0.1)
	btn_pontos.modulate = Color(1, 1, 1)


# ==========================================
# BOTÃO: ORDENAR
# ==========================================
func _on_btn_ordenar_pressed() -> void:
	AudioManager.play_click_ui()

	var tween = create_tween()
	tween.tween_property(btn_ordenar, "scale", Vector2(0.9, 0.9), 0.1)
	btn_ordenar.modulate = Color(0.8, 0.8, 0.8)

	await tween.finished
	get_tree().change_scene_to_file("res://scenes/hora_de_organizar/NivelOrdenacao.tscn")


func _on_btn_ordenar_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_ordenar, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_ordenar_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_ordenar, "scale", Vector2(1.0, 1.0), 0.1)
	btn_ordenar.modulate = Color(1, 1, 1)


# ==========================================
# BOTÃO: VOLTAR
# ==========================================
func _on_btn_voltar_2_pressed() -> void:
	AudioManager.play_click_ui()

	var tween = create_tween()
	tween.tween_property(btn_voltar, "scale", Vector2(0.9, 0.9), 0.1)
	btn_voltar.modulate = Color(0.8, 0.8, 0.8)

	await tween.finished
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")


func _on_btn_voltar_2_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_voltar, "scale", Vector2(1.05, 1.05), 0.1)


func _on_btn_voltar_2_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_voltar, "scale", Vector2(1.0, 1.0), 0.1)
	btn_voltar.modulate = Color(1, 1, 1)
