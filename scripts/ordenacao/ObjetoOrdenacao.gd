extends Area2D

# ==========================================
# CONFIGURAÇÃO
# ==========================================
@export var nome_do_slot_correto: String = ""


# ==========================================
# ESTADO
# ==========================================
var arrastando := false
var posicao_inicial: Vector2 = Vector2.ZERO
var slot_atual = null
var travado := false

var controlador = null
var tween_movimento: Tween = null


# ==========================================
# READY
# ==========================================
func _ready() -> void:
	await get_tree().process_frame

	posicao_inicial = global_position
	controlador = get_tree().current_scene


# ==========================================
# PROCESS
# ==========================================
func _process(_delta) -> void:
	if arrastando and not travado:
		global_position = get_global_mouse_position()


# ==========================================
# INPUT
# ==========================================
func _input_event(_viewport, event, _shape_idx) -> void:
	if travado:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				iniciar_arraste()
			else:
				finalizar_arraste()


func iniciar_arraste() -> void:
	if travado:
		return

	if controlador == null:
		controlador = get_tree().current_scene

	# Antes de permitir o arraste, verifica a ordem obrigatória.
	if controlador and controlador.has_method("tentar_iniciar_peca"):
		var permitido = controlador.tentar_iniciar_peca(self)

		if not permitido:
			return

	_parar_tween_movimento()

	arrastando = true
	z_index = 10


func finalizar_arraste() -> void:
	if travado:
		return

	if not arrastando:
		return

	arrastando = false
	z_index = 0

	verificar_soltura()


# ==========================================
# SOLTURA / ENCAIXE
# ==========================================
func verificar_soltura() -> void:
	var areas = get_overlapping_areas()

	var encontrou_algum_slot := false
	var slot_correto = null
	var slot_errado = null

	for area in areas:
		if _area_e_slot(area):
			encontrou_algum_slot = true

			if area.name == nome_do_slot_correto:
				slot_correto = area
			else:
				slot_errado = area

	# Prioridade absoluta: se encontrou o slot correto, tenta encaixar nele.
	# Isso evita erro quando a peça encosta em dois slots ao mesmo tempo.
	if slot_correto:
		if controlador and controlador.has_method("slot_esta_ocupado"):
			if controlador.slot_esta_ocupado(slot_correto, self):
				voltar_para_inicio_com_erro()
				return

		encaixar_no_slot(slot_correto)
		return

	# Se encontrou slot, mas nenhum era o correto: erro pedagógico.
	if encontrou_algum_slot and slot_errado:
		voltar_para_inicio_com_erro()
		return

	# Soltou fora de qualquer slot: volta sem voz/som de erro.
	voltar_para_inicio_sem_erro()


func _area_e_slot(area: Node) -> bool:
	if area == null:
		return false

	if area.is_in_group("slots"):
		return true

	if area.name.begins_with("Slot"):
		return true

	return false


func encaixar_no_slot(area) -> void:
	_parar_tween_movimento()

	slot_atual = area
	travado = true
	arrastando = false
	z_index = 0

	var posicao_final: Vector2 = area.global_position
	posicao_final.y -= _obter_altura_da_peca(area)

	tween_movimento = create_tween()
	tween_movimento.tween_property(
		self,
		"global_position",
		posicao_final,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if controlador and controlador.has_method("tocar_som_acerto"):
		controlador.tocar_som_acerto()

	if controlador and controlador.has_method("verificar_vitoria"):
		controlador.verificar_vitoria()


func _obter_altura_da_peca(area) -> float:
	var valor_altura = area.get("altura_da_peca")

	if valor_altura != null:
		return float(valor_altura)

	return 40.0


func voltar_para_inicio_com_erro() -> void:
	_parar_tween_movimento()

	slot_atual = null
	arrastando = false
	z_index = 0

	tween_movimento = create_tween()
	tween_movimento.tween_property(
		self,
		"global_position",
		posicao_inicial,
		0.65
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if controlador and controlador.has_method("tocar_som_erro"):
		controlador.tocar_som_erro()


func voltar_para_inicio_sem_erro() -> void:
	_parar_tween_movimento()

	slot_atual = null
	arrastando = false
	z_index = 0

	tween_movimento = create_tween()
	tween_movimento.tween_property(
		self,
		"global_position",
		posicao_inicial,
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _parar_tween_movimento() -> void:
	if tween_movimento and tween_movimento.is_valid():
		tween_movimento.kill()

	tween_movimento = null


# ==========================================
# SUPORTE À RANDOMIZAÇÃO / PISTAS
# ==========================================
func atualizar_posicao_inicial() -> void:
	posicao_inicial = global_position


func get_slot_correto() -> Node:
	if nome_do_slot_correto == "":
		return null

	var pai = get_parent()

	if pai and pai.has_node(nome_do_slot_correto):
		return pai.get_node(nome_do_slot_correto)

	var cena_atual = get_tree().current_scene

	if cena_atual:
		return cena_atual.find_child(nome_do_slot_correto, true, false)

	return null


func esta_disponivel_para_pista() -> bool:
	return not travado and not arrastando
