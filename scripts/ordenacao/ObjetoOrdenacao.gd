extends Area2D

@export var nome_do_slot_correto: String = ""
@export var manter_deslocamento_do_toque := true

var arrastando := false
var posicao_inicial := Vector2.ZERO
var slot_atual: Node = null
var travado := false
var controlador: Node = null
var tween_movimento: Tween = null
var ponteiro_ativo := -999
var deslocamento_arraste := Vector2.ZERO

const PONTEIRO_MOUSE := -1
const PONTEIRO_NENHUM := -999


func _ready() -> void:
	await get_tree().process_frame
	posicao_inicial = global_position
	controlador = get_tree().current_scene
	input_pickable = true


func _exit_tree() -> void:
	_parar_tween_movimento()


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if travado or arrastando:
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
	if not arrastando or travado:
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
	if travado or arrastando:
		return

	if not controlador or not is_instance_valid(controlador):
		controlador = get_tree().current_scene

	if controlador and controlador.has_method("tentar_iniciar_peca"):
		if not bool(controlador.call("tentar_iniciar_peca", self)):
			return

	_parar_tween_movimento()
	ponteiro_ativo = id_ponteiro
	deslocamento_arraste = (
		global_position - posicao_ponteiro if manter_deslocamento_do_toque else Vector2.ZERO
	)
	arrastando = true
	z_index = 10


func _mover_para_ponteiro(posicao_ponteiro: Vector2) -> void:
	global_position = posicao_ponteiro + deslocamento_arraste


func finalizar_arraste() -> void:
	if travado or not arrastando:
		return

	arrastando = false
	ponteiro_ativo = PONTEIRO_NENHUM
	z_index = 0
	verificar_soltura()


func verificar_soltura() -> void:
	var areas := get_overlapping_areas()
	var encontrou_algum_slot := false
	var slot_correto: Node = null

	for area in areas:
		if not _area_e_slot(area):
			continue

		encontrou_algum_slot = true
		if area.name == nome_do_slot_correto:
			slot_correto = area
			break

	if slot_correto:
		if controlador and controlador.has_method("slot_esta_ocupado"):
			if bool(controlador.call("slot_esta_ocupado", slot_correto, self)):
				voltar_para_inicio_com_erro()
				return

		encaixar_no_slot(slot_correto)
	elif encontrou_algum_slot:
		voltar_para_inicio_com_erro()
	else:
		voltar_para_inicio_sem_erro()


func _area_e_slot(area: Node) -> bool:
	return area != null and (area.is_in_group("slots") or area.name.begins_with("Slot"))


func encaixar_no_slot(area: Node2D) -> void:
	_parar_tween_movimento()
	slot_atual = area
	travado = true
	arrastando = false
	ponteiro_ativo = PONTEIRO_NENHUM
	z_index = 0

	var posicao_final := area.global_position
	posicao_final.y -= _obter_altura_da_peca(area)

	tween_movimento = create_tween()
	(
		tween_movimento
		. tween_property(self, "global_position", posicao_final, 0.2)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)

	if controlador and controlador.has_method("tocar_som_acerto"):
		controlador.call("tocar_som_acerto")
	if controlador and controlador.has_method("verificar_vitoria"):
		controlador.call("verificar_vitoria")
	if controlador and controlador.has_method("notificar_fim_interacao"):
		controlador.call("notificar_fim_interacao")


func _obter_altura_da_peca(area: Node) -> float:
	for propriedade in area.get_property_list():
		if String(propriedade.name) == "altura_da_peca":
			return float(area.get("altura_da_peca"))
	return 40.0


func voltar_para_inicio_com_erro() -> void:
	_retornar_para_inicio(0.65)

	if controlador and controlador.has_method("tocar_som_erro"):
		controlador.call("tocar_som_erro")
	if controlador and controlador.has_method("notificar_fim_interacao"):
		controlador.call("notificar_fim_interacao")


func voltar_para_inicio_sem_erro() -> void:
	_retornar_para_inicio(0.45)

	if controlador and controlador.has_method("notificar_fim_interacao"):
		controlador.call("notificar_fim_interacao")


func _retornar_para_inicio(duracao: float) -> void:
	_parar_tween_movimento()
	slot_atual = null
	arrastando = false
	ponteiro_ativo = PONTEIRO_NENHUM
	z_index = 0

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
	if nome_do_slot_correto.is_empty():
		return null

	var pai := get_parent()
	if pai:
		var direto := pai.get_node_or_null(nome_do_slot_correto)
		if direto:
			return direto

	var cena_atual := get_tree().current_scene
	return cena_atual.find_child(nome_do_slot_correto, true, false) if cena_atual else null


func esta_disponivel_para_pista() -> bool:
	return not travado and not arrastando
