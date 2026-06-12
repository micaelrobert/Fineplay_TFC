extends Node

const BASE_SIZE: Vector2 = Vector2(720, 1280)

var cena_atual: Node = null
var cobertura: ColorRect


func _ready() -> void:
	_criar_cobertura()
	get_viewport().size_changed.connect(_ajustar_responsividade)
	call_deferred("_ajustar_responsividade")


func _criar_cobertura() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 128
	cobertura = ColorRect.new()
	cobertura.color = Color.BLACK
	cobertura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cobertura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cobertura.visible = false
	canvas.add_child(cobertura)
	add_child(canvas)


func _process(_delta: float) -> void:
	if get_tree().current_scene != cena_atual:
		cobertura.visible = true
		cena_atual = get_tree().current_scene
		_ajustar_responsividade()
		await get_tree().process_frame
		await get_tree().process_frame
		cobertura.visible = false


func _ajustar_responsividade() -> void:
	cena_atual = get_tree().current_scene

	if cena_atual == null:
		return

	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	var area_jogo: Node = cena_atual.find_child("AreaJogo", true, false)
	var fundo_responsivo: Node = cena_atual.find_child("FundoResponsivo", true, false)
	var center_container: Node = cena_atual.find_child("CenterContainer", true, false)
	var ui_responsiva: Node = cena_atual.find_child("UIResponsiva", true, false)

	if area_jogo == null:
		return

	if OS.get_name() == "Android":
		_aplicar_android(tamanho_tela, area_jogo, fundo_responsivo, center_container, ui_responsiva)
	else:
		_aplicar_windows(tamanho_tela, area_jogo, fundo_responsivo, center_container, ui_responsiva)


func _aplicar_windows(
	tamanho_tela: Vector2,
	area_jogo: Node,
	fundo_responsivo: Node,
	center_container: Node,
	ui_responsiva: Node
) -> void:
	var escala: float = min(
		tamanho_tela.x / BASE_SIZE.x,
		tamanho_tela.y / BASE_SIZE.y
	)

	var tamanho_final: Vector2 = BASE_SIZE * escala
	var posicao_final: Vector2 = (tamanho_tela - tamanho_final) / 2.0

	_ajustar_control_tela_cheia(cena_atual, tamanho_tela)
	_ajustar_control_tela_cheia(ui_responsiva, tamanho_tela)
	_ajustar_control_tela_cheia(center_container, tamanho_tela)

	_ajustar_area_jogo(area_jogo, posicao_final, BASE_SIZE, Vector2(escala, escala))
	_ajustar_fundo_windows(fundo_responsivo, posicao_final, BASE_SIZE, Vector2(escala, escala))


func _aplicar_android(
	tamanho_tela: Vector2,
	area_jogo: Node,
	fundo_responsivo: Node,
	center_container: Node,
	ui_responsiva: Node
) -> void:
	var fator_escala: float = min(
		tamanho_tela.x / BASE_SIZE.x,
		tamanho_tela.y / BASE_SIZE.y
	)
	var escala_android: Vector2 = Vector2(fator_escala, fator_escala)

	var tamanho_final: Vector2 = BASE_SIZE * fator_escala
	var posicao_final: Vector2 = (tamanho_tela - tamanho_final) / 2.0

	_ajustar_control_tela_cheia(cena_atual, tamanho_tela)
	_ajustar_control_tela_cheia(ui_responsiva, tamanho_tela)
	_ajustar_control_tela_cheia(center_container, tamanho_tela)

	_ajustar_area_jogo(area_jogo, posicao_final, BASE_SIZE, escala_android)
	_ajustar_fundo_android(fundo_responsivo, tamanho_tela)


func _ajustar_control_tela_cheia(node: Node, tamanho_tela: Vector2) -> void:
	if node == null:
		return

	if node is Control:
		var control: Control = node as Control
		control.position = Vector2.ZERO
		control.size = tamanho_tela


func _ajustar_area_jogo(area_jogo: Node, posicao: Vector2, tamanho: Vector2, escala: Vector2) -> void:
	if area_jogo is Control:
		var control: Control = area_jogo as Control
		control.position = posicao
		control.size = tamanho
		control.custom_minimum_size = tamanho
		control.scale = escala

	elif area_jogo is Node2D:
		var node2d: Node2D = area_jogo as Node2D
		node2d.position = posicao
		node2d.scale = escala


func _ajustar_fundo_windows(fundo_responsivo: Node, posicao: Vector2, tamanho: Vector2, escala: Vector2) -> void:
	if fundo_responsivo == null:
		return

	if fundo_responsivo is Control:
		var control: Control = fundo_responsivo as Control
		control.position = posicao
		control.size = tamanho
		control.scale = escala


func _ajustar_fundo_android(fundo_responsivo: Node, tamanho_tela: Vector2) -> void:
	if fundo_responsivo == null:
		return

	if fundo_responsivo is Control:
		var control: Control = fundo_responsivo as Control
		control.position = Vector2.ZERO
		control.size = tamanho_tela
		control.scale = Vector2.ONE
