extends Area2D

# ============================================================
# SINAIS
# ============================================================
signal peca_encaixada
signal peca_clicada
signal peca_errou


# ============================================================
# CONFIGURAÇÃO
# ============================================================
@export var slot_correto_nome: String = ""


# ============================================================
# TEXTURAS DE ROSTO
# ============================================================
@export var textura_brava: Texture2D
@export var textura_feliz: Texture2D


# ============================================================
# REFERÊNCIAS
# ============================================================
var sprite_rosto: Sprite2D = null


# ============================================================
# VARIÁVEIS INTERNAS
# ============================================================
var sendo_arrastado := false
var posicao_inicial := Vector2.ZERO
var esta_travado := false
var tween_movimento: Tween = null


func _ready() -> void:
	await get_tree().process_frame

	posicao_inicial = global_position

	if has_node("Rosto"):
		sprite_rosto = get_node("Rosto")

		if textura_brava:
			sprite_rosto.texture = textura_brava


func _process(_delta: float) -> void:
	if sendo_arrastado and not esta_travado:
		global_position = get_global_mouse_position()


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if esta_travado:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				iniciar_arraste()
			else:
				finalizar_arraste()


func iniciar_arraste() -> void:
	if esta_travado:
		return

	_parar_tween_movimento()

	sendo_arrastado = true
	z_index = 10
	scale = Vector2(1.2, 1.2)

	emit_signal("peca_clicada")


func finalizar_arraste() -> void:
	if esta_travado:
		return

	sendo_arrastado = false
	verificar_encaixe()


func verificar_encaixe() -> void:
	var areas = get_overlapping_areas()
	var encontrou_slot := false

	for area in areas:
		if area.is_in_group("slots"):
			encontrou_slot = true

			if area.name == slot_correto_nome:
				encaixar(area.global_position)
				return

	# Se encontrou algum slot, mas não era o correto:
	# aí sim é erro pedagógico com som/voz.
	if encontrou_slot:
		emit_signal("peca_errou")
		voltar_ao_inicio()
		return

	# Se soltou fora de qualquer slot:
	# apenas volta para a posição inicial, sem emitir erro.
	voltar_ao_inicio_sem_erro()


func encaixar(posicao_alvo: Vector2) -> void:
	_parar_tween_movimento()

	esta_travado = true
	sendo_arrastado = false
	scale = Vector2(1.0, 1.0)
	z_index = 0

	if sprite_rosto and textura_feliz:
		sprite_rosto.texture = textura_feliz

	tween_movimento = get_tree().create_tween()
	tween_movimento.tween_property(
		self,
		"global_position",
		posicao_alvo,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	emit_signal("peca_encaixada")


func voltar_ao_inicio() -> void:
	# Usado quando a peça foi colocada em um SLOT ERRADO.
	_parar_tween_movimento()

	sendo_arrastado = false
	scale = Vector2(1.0, 1.0)
	z_index = 0

	if sprite_rosto and textura_brava:
		sprite_rosto.texture = textura_brava

	tween_movimento = get_tree().create_tween()
	tween_movimento.tween_property(
		self,
		"global_position",
		posicao_inicial,
		0.65
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func voltar_ao_inicio_sem_erro() -> void:
	# Usado quando a peça foi solta fora de qualquer slot.
	# Não emite peca_errou e não deve gerar voz de erro.
	_parar_tween_movimento()

	sendo_arrastado = false
	scale = Vector2(1.0, 1.0)
	z_index = 0

	if sprite_rosto and textura_brava:
		sprite_rosto.texture = textura_brava

	tween_movimento = get_tree().create_tween()
	tween_movimento.tween_property(
		self,
		"global_position",
		posicao_inicial,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _parar_tween_movimento() -> void:
	if tween_movimento and tween_movimento.is_valid():
		tween_movimento.kill()

	tween_movimento = null


# ============================================================
# SUPORTE À RANDOMIZAÇÃO
# ============================================================
func atualizar_posicao_inicial() -> void:
	posicao_inicial = global_position


# ============================================================
# MÉTODOS PARA O SISTEMA DE PISTAS
# ============================================================
func get_slot_correto() -> Node:
	if slot_correto_nome == "":
		return null

	var pai = get_parent()

	if pai and pai.has_node(slot_correto_nome):
		return pai.get_node(slot_correto_nome)

	return null


func esta_disponivel_para_pista() -> bool:
	return not esta_travado
