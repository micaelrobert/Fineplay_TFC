extends Area2D

@export var nome_do_slot_correto: String = ""

var arrastando := false
var posicao_inicial: Vector2
var slot_atual = null
var travado := false

var controlador = null


func _ready() -> void:
	await get_tree().process_frame

	posicao_inicial = global_position
	controlador = get_tree().current_scene


func _process(_delta) -> void:
	if arrastando and not travado:
		global_position = get_global_mouse_position()


func _input_event(_viewport, event, _shape_idx) -> void:
	if travado:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				arrastando = true
				z_index = 10

				if controlador and controlador.has_method("tocar_som_clique"):
					controlador.tocar_som_clique()
			else:
				arrastando = false
				z_index = 0
				verificar_soltura()


func verificar_soltura() -> void:
	var areas = get_overlapping_areas()
	var soltou_no_slot := false

	slot_atual = null

	for area in areas:
		if area.name.begins_with("Slot"):
			soltou_no_slot = true

			if area.name == nome_do_slot_correto:
				encaixar_no_slot(area)
			else:
				voltar_para_inicio()

			break

	if not soltou_no_slot:
		voltar_para_inicio()


func encaixar_no_slot(area) -> void:
	slot_atual = area
	travado = true

	var posicao_final: Vector2 = area.global_position

	# Puxa a altura personalizada do slot, se existir.
	if "altura_da_peca" in area:
		posicao_final.y -= area.altura_da_peca
	else:
		posicao_final.y -= 40.0

	var tween = create_tween()
	tween.tween_property(self, "global_position", posicao_final, 0.1)

	if controlador and controlador.has_method("tocar_som_acerto"):
		controlador.tocar_som_acerto()

	if controlador and controlador.has_method("verificar_vitoria"):
		controlador.verificar_vitoria()


func voltar_para_inicio() -> void:
	slot_atual = null

	var tween = create_tween()
	tween.tween_property(self, "global_position", posicao_inicial, 0.2)

	if controlador and controlador.has_method("tocar_som_erro"):
		controlador.tocar_som_erro()
