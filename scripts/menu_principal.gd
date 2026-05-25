extends Control

const BASE_SIZE := Vector2(720, 1280)

@onready var fundo_responsivo: Control = $FundoResponsivo
@onready var center_container: CenterContainer = $CenterContainer
@onready var area_jogo: Control = $CenterContainer/AreaJogo
@onready var botao_jogar: Control = $CenterContainer/AreaJogo/Botao_Jogar

@onready var som_click_ui = $GerenciadorDeSons/SomClick


func _ready() -> void:
	get_viewport().size_changed.connect(_ajustar_responsivo)
	call_deferred("_ajustar_responsivo")

	await get_tree().process_frame

	if botao_jogar:
		botao_jogar.pivot_offset = botao_jogar.size / 2


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	# Faz o MenuPrincipal ocupar a tela real.
	position = Vector2.ZERO
	set_deferred("size", tamanho_tela)

	# Fundo ocupa a tela inteira.
	fundo_responsivo.position = Vector2.ZERO
	fundo_responsivo.set_deferred("size", tamanho_tela)

	# CenterContainer ocupa a tela inteira real para centralizar a AreaJogo.
	center_container.position = Vector2.ZERO
	center_container.set_deferred("size", tamanho_tela)

	# AreaJogo permanece como o "celular virtual" base.
	area_jogo.custom_minimum_size = BASE_SIZE
	area_jogo.set_deferred("size", BASE_SIZE)

	# Aguarda o ajuste de size e força o container a recalcular.
	call_deferred("_recalcular_container")


func _recalcular_container() -> void:
	if center_container:
		center_container.queue_sort()


func _on_botao_jogar_pressed() -> void:
	som_click_ui.play()

	var tween = create_tween()
	tween.tween_property(botao_jogar, "scale", Vector2(0.9, 0.9), 0.1)

	await tween.finished

	botao_jogar.scale = Vector2(1.0, 1.0)

	get_tree().change_scene_to_file("res://scenes/telas/TelaSelecao.tscn")
