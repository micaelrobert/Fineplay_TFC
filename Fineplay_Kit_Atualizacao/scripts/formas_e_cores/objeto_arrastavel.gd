extends Area2D

signal peca_encaixada
signal peca_clicada
signal peca_errou
signal arraste_iniciado
signal arraste_finalizado

@export var slot_correto_nome: String = ""
@export var textura_brava: Texture2D
@export var textura_feliz: Texture2D
@export var manter_deslocamento_do_toque := true
@export_range(1.0, 2.0, 0.05) var escala_durante_arraste := 1.2

var sprite_rosto: Sprite2D = null
var sendo_arrastado := false
var posicao_inicial := Vector2.ZERO
var esta_travado := false
var tween_movimento: Tween = null
var ponteiro_ativo := -999
var deslocamento_arraste := Vector2.ZERO
var escala_inicial := Vector2.ONE

const PONTEIRO_MOUSE := -1
const PONTEIRO_NENHUM := -999


func _ready() -> void:
	await get_tree().process_frame
	posicao_inicial = global_position
	escala_inicial = scale
	input_pickable = true

	if has_node("Rosto"):
		sprite_rosto = get_node("Rosto") as Sprite2D
		if sprite_rosto and textura_brava:
			sprite_rosto.texture = textura_brava


func _exit_tree() -> void:
	_parar_tween_movimento()


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if esta_travado or sendo_arrastado:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_iniciar_arraste_com_ponteiro(
				PONTEIRO_MOUSE, _viewport_para_global(mouse_event.position)
			)
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_iniciar_arraste_com_ponteiro(
				touch_event.index, _viewport_para_global(touch_event.position)
			)
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if not sendo_arrastado or esta_travado:
		return

	if event is InputEventMouseMotion and ponteiro_ativo == PONTEIRO_MOUSE:
		_mover_para_ponteiro(_viewport_para_global((event as InputEventMouseMotion).position))

	elif event is InputEventMouseButton and ponteiro_ativo == PONTEIRO_MOUSE:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_mover_para_ponteiro(_viewport_para_global(mouse_event.position))
			finalizar_arraste()

	elif event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if drag_event.index == ponteiro_ativo:
			_mover_para_ponteiro(_viewport_para_global(drag_event.position))

	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.index == ponteiro_ativo and not touch_event.pressed:
			_mover_para_ponteiro(_viewport_para_global(touch_event.position))
			finalizar_arraste()


func iniciar_arraste() -> void:
	_iniciar_arraste_com_ponteiro(PONTEIRO_MOUSE, get_global_mouse_position())


func _iniciar_arraste_com_ponteiro(id_ponteiro: int, posicao_ponteiro: Vector2) -> void:
	if esta_travado or sendo_arrastado:
		return

	_parar_tween_movimento()
	ponteiro_ativo = id_ponteiro
	deslocamento_arraste = (
		global_position - posicao_ponteiro if manter_deslocamento_do_toque else Vector2.ZERO
	)
	sendo_arrastado = true
	z_index = 10
	scale = escala_inicial * escala_durante_arraste

	peca_clicada.emit()
	arraste_iniciado.emit()


func _mover_para_ponteiro(posicao_ponteiro: Vector2) -> void:
	global_position = posicao_ponteiro + deslocamento_arraste


func finalizar_arraste() -> void:
	if esta_travado or not sendo_arrastado:
		return

	sendo_arrastado = false
	ponteiro_ativo = PONTEIRO_NENHUM
	verificar_encaixe()
	arraste_finalizado.emit()


func verificar_encaixe() -> void:
	var areas := get_overlapping_areas()
	var encontrou_slot := false
	var slot_correto: Area2D = null

	for area in areas:
		if not area.is_in_group("slots"):
			continue

		encontrou_slot = true
		if area.name == slot_correto_nome:
			slot_correto = area
			break

	if slot_correto:
		encaixar(slot_correto.global_position)
	elif encontrou_slot:
		peca_errou.emit()
		voltar_ao_inicio()
	else:
		voltar_ao_inicio_sem_erro()


func encaixar(posicao_alvo: Vector2) -> void:
	_parar_tween_movimento()
	esta_travado = true
	sendo_arrastado = false
	ponteiro_ativo = PONTEIRO_NENHUM
	scale = escala_inicial
	z_index = 0

	if sprite_rosto and textura_feliz:
		sprite_rosto.texture = textura_feliz

	tween_movimento = create_tween()
	(
		tween_movimento
		. tween_property(self, "global_position", posicao_alvo, 0.2)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	peca_encaixada.emit()


func voltar_ao_inicio() -> void:
	_retornar_para_posicao_inicial(0.65)


func voltar_ao_inicio_sem_erro() -> void:
	_retornar_para_posicao_inicial(0.3)


func _retornar_para_posicao_inicial(duracao: float) -> void:
	_parar_tween_movimento()
	sendo_arrastado = false
	ponteiro_ativo = PONTEIRO_NENHUM
	scale = escala_inicial
	z_index = 0

	if sprite_rosto and textura_brava:
		sprite_rosto.texture = textura_brava

	tween_movimento = create_tween()
	(
		tween_movimento
		. tween_property(self, "global_position", posicao_inicial, duracao)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)


func _parar_tween_movimento() -> void:
	if tween_movimento and tween_movimento.is_valid():
		tween_movimento.kill()
	tween_movimento = null


func _viewport_para_global(posicao_viewport: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * posicao_viewport


func atualizar_posicao_inicial() -> void:
	posicao_inicial = global_position


func get_slot_correto() -> Node:
	if slot_correto_nome.is_empty():
		return null

	var pai := get_parent()
	if pai:
		var direto := pai.get_node_or_null(slot_correto_nome)
		if direto:
			return direto

		return pai.find_child(slot_correto_nome, true, false)

	return null


func esta_disponivel_para_pista() -> bool:
	return not esta_travado and not sendo_arrastado
