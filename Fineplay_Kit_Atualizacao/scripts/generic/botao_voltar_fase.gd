extends CanvasLayer

const BASE_SIZE := Vector2(720, 1280)

@export_file("*.tscn") var cena_destino: String = "res://scenes/telas/TelaSelecao.tscn"

@onready var ui_responsiva: Control = $UIResponsiva
@onready var center_container: CenterContainer = $UIResponsiva/CenterContainer
@onready var area_jogo: Control = $UIResponsiva/CenterContainer/AreaJogo
@onready var btn_voltar: Control = $UIResponsiva/CenterContainer/AreaJogo/BtnVoltarFase


func _ready() -> void:
	get_viewport().size_changed.connect(_ajustar_responsivo)
	call_deferred("_ajustar_responsivo")

	await get_tree().process_frame

	if btn_voltar:
		btn_voltar.pivot_offset = btn_voltar.size / 2


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	ui_responsiva.position = Vector2.ZERO
	ui_responsiva.size = tamanho_tela

	center_container.position = Vector2.ZERO
	center_container.size = tamanho_tela

	area_jogo.custom_minimum_size = BASE_SIZE
	area_jogo.size = BASE_SIZE

	center_container.queue_sort()


func _on_btn_voltar_fase_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click_ui()

	var tween = create_tween()
	tween.tween_property(btn_voltar, "scale", Vector2(0.9, 0.9), 0.08)

	await tween.finished

	btn_voltar.scale = Vector2(1.0, 1.0)

	get_tree().change_scene_to_file(cena_destino)


func _on_btn_voltar_fase_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(btn_voltar, "scale", Vector2(1.05, 1.05), 0.08)


func _on_btn_voltar_fase_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(btn_voltar, "scale", Vector2(1.0, 1.0), 0.08)
	btn_voltar.modulate = Color(1, 1, 1)
