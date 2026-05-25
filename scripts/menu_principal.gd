extends Control

const BASE_SIZE := Vector2(720, 1280)

@onready var fundo_responsivo: Control = $FundoResponsivo
@onready var center_container: CenterContainer = $CenterContainer
@onready var area_jogo: Control = $CenterContainer/AreaJogo
@onready var titulo: Control = $CenterContainer/AreaJogo/Label
@onready var robo_menu: TextureRect = $CenterContainer/AreaJogo/RoboMenu
@onready var botao_jogar: Control = $CenterContainer/AreaJogo/Botao_Jogar
@onready var som_click_ui = $GerenciadorDeSons/SomClick

# Poses do robô
var robo_idle = preload("res://assets/kenney_toon-characters-1/Robot/PNG/Poses HD/character_robot_idle.png")
var robo_talk = preload("res://assets/kenney_toon-characters-1/Robot/PNG/Poses HD/character_robot_talk.png")
var robo_show = preload("res://assets/kenney_toon-characters-1/Robot/PNG/Poses HD/character_robot_show.png")
var robo_cheer0 = preload("res://assets/kenney_toon-characters-1/Robot/PNG/Poses HD/character_robot_cheer0.png")
var robo_cheer1 = preload("res://assets/kenney_toon-characters-1/Robot/PNG/Poses HD/character_robot_cheer1.png")
var robo_jump = preload("res://assets/kenney_toon-characters-1/Robot/PNG/Poses HD/character_robot_jump.png")

var tween_botao_idle: Tween
var tween_robo_idle: Tween
var tween_hover: Tween

var escala_robo_base := Vector2.ONE
var bloqueado := false
var mouse_no_botao := false
var robo_animando := true


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_viewport().size_changed.connect(_ajustar_responsivo)
	call_deferred("_ajustar_responsivo")

	await get_tree().process_frame
	await get_tree().process_frame

	botao_jogar.pivot_offset = botao_jogar.size / 2
	titulo.pivot_offset = titulo.size / 2

	robo_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	robo_menu.texture = robo_idle
	escala_robo_base = robo_menu.scale

	await _animacao_entrada()

	_iniciar_pulsacao_botao()
	_iniciar_pulsacao_robo()
	_animacao_poses_robo()


func _ajustar_responsivo() -> void:
	var tamanho_tela := get_viewport().get_visible_rect().size

	position = Vector2.ZERO
	set_deferred("size", tamanho_tela)

	fundo_responsivo.position = Vector2.ZERO
	fundo_responsivo.set_deferred("size", tamanho_tela)

	center_container.position = Vector2.ZERO
	center_container.set_deferred("size", tamanho_tela)

	area_jogo.custom_minimum_size = BASE_SIZE
	area_jogo.set_deferred("size", BASE_SIZE)

	call_deferred("_recalcular_container")


func _recalcular_container() -> void:
	center_container.queue_sort()


func _animacao_entrada() -> void:
	area_jogo.modulate = Color(1, 1, 1, 0)

	titulo.scale = Vector2(0.94, 0.94)
	botao_jogar.scale = Vector2(0.94, 0.94)
	robo_menu.scale = escala_robo_base * 0.94

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(area_jogo, "modulate", Color(1, 1, 1, 1), 0.45)
	tween.tween_property(titulo, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(botao_jogar, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(robo_menu, "scale", escala_robo_base, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished


func _iniciar_pulsacao_botao() -> void:
	if bloqueado or mouse_no_botao:
		return

	if tween_botao_idle:
		tween_botao_idle.kill()

	tween_botao_idle = create_tween()
	tween_botao_idle.set_loops()

	tween_botao_idle.tween_property(botao_jogar, "scale", Vector2(1.035, 1.035), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_botao_idle.tween_property(botao_jogar, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _iniciar_pulsacao_robo() -> void:
	if bloqueado or mouse_no_botao:
		return

	if tween_robo_idle:
		tween_robo_idle.kill()

	tween_robo_idle = create_tween()
	tween_robo_idle.set_loops()

	tween_robo_idle.tween_property(robo_menu, "scale", escala_robo_base * 1.035, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_robo_idle.tween_property(robo_menu, "scale", escala_robo_base, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _parar_tweens_idle() -> void:
	if tween_botao_idle:
		tween_botao_idle.kill()
		tween_botao_idle = null

	if tween_robo_idle:
		tween_robo_idle.kill()
		tween_robo_idle = null


func _animacao_poses_robo() -> void:
	while is_inside_tree() and robo_animando:
		if not mouse_no_botao and not bloqueado:
			robo_menu.texture = robo_idle
		await get_tree().create_timer(1.8).timeout

		if not is_inside_tree() or not robo_animando:
			return

		if not mouse_no_botao and not bloqueado:
			robo_menu.texture = robo_talk
		await get_tree().create_timer(0.35).timeout

		if not is_inside_tree() or not robo_animando:
			return

		if not mouse_no_botao and not bloqueado:
			robo_menu.texture = robo_idle
		await get_tree().create_timer(1.4).timeout

		if not is_inside_tree() or not robo_animando:
			return

		if not mouse_no_botao and not bloqueado:
			robo_menu.texture = robo_cheer0
		await get_tree().create_timer(0.25).timeout

		if not is_inside_tree() or not robo_animando:
			return

		if not mouse_no_botao and not bloqueado:
			robo_menu.texture = robo_cheer1
		await get_tree().create_timer(0.25).timeout


func _on_botao_jogar_mouse_entered() -> void:
	if bloqueado:
		return

	mouse_no_botao = true
	_parar_tweens_idle()

	robo_menu.texture = robo_show
	robo_menu.scale = escala_robo_base

	if tween_hover:
		tween_hover.kill()

	tween_hover = create_tween()
	tween_hover.set_parallel(true)
	tween_hover.tween_property(botao_jogar, "scale", Vector2(1.08, 1.08), 0.12)
	tween_hover.tween_property(botao_jogar, "modulate", Color(1.10, 1.10, 1.10, 1), 0.12)


func _on_botao_jogar_mouse_exited() -> void:
	if bloqueado:
		return

	mouse_no_botao = false

	if tween_hover:
		tween_hover.kill()

	robo_menu.texture = robo_idle
	robo_menu.scale = escala_robo_base

	tween_hover = create_tween()
	tween_hover.set_parallel(true)
	tween_hover.tween_property(botao_jogar, "scale", Vector2.ONE, 0.12)
	tween_hover.tween_property(botao_jogar, "modulate", Color(1, 1, 1, 1), 0.12)

	await get_tree().create_timer(0.16).timeout

	if not bloqueado and not mouse_no_botao:
		_iniciar_pulsacao_botao()
		_iniciar_pulsacao_robo()


func _on_botao_jogar_pressed() -> void:
	if bloqueado:
		return

	bloqueado = true
	robo_animando = false
	mouse_no_botao = false

	_parar_tweens_idle()

	if tween_hover:
		tween_hover.kill()

	robo_menu.texture = robo_jump
	robo_menu.scale = escala_robo_base

	if som_click_ui:
		som_click_ui.play()

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(botao_jogar, "scale", Vector2(0.90, 0.90), 0.10)
	tween.tween_property(botao_jogar, "modulate", Color(0.8, 0.8, 0.8, 1), 0.10)
	tween.tween_property(robo_menu, "scale", escala_robo_base * 1.08, 0.10)

	await tween.finished
	await get_tree().create_timer(0.08).timeout

	get_tree().change_scene_to_file("res://scenes/telas/TelaSelecao.tscn")
