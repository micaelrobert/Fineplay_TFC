extends Node

class_name LineRendererManager

@export_node_path("Node2D") var camada_linhas_path: NodePath

@export_group("Linha de pré-visualização")
@export var cor_linha_preview: Color = Color(1.0, 1.0, 1.0, 0.72)
@export var cor_linha_preview_sombra: Color = Color(0.0, 0.0, 0.0, 0.18)
@export var largura_linha_preview: float = 8.0
@export var largura_linha_preview_sombra: float = 16.0
@export var z_index_linha_preview: int = 60
@export var z_index_linha_preview_sombra: int = 59

@export_group("Linha de acerto")
@export var cor_linha_final: Color = Color(0.20, 0.85, 0.45, 0.42)
@export var cor_linha_final_sombra: Color = Color(0.0, 0.0, 0.0, 0.10)
@export var largura_linha_final: float = 5.0
@export var largura_linha_final_sombra: float = 10.0
@export var z_index_linha_final: int = 20
@export var z_index_linha_final_sombra: int = 19

@onready var camada_linhas: Node2D = get_node_or_null(camada_linhas_path) as Node2D

var linha_atual: Line2D = null
var linha_sombra_atual: Line2D = null


func _ready() -> void:
	_resolver_camada_linhas()


func _exit_tree() -> void:
	apagar_linha_atual()


func _resolver_camada_linhas() -> void:
	if camada_linhas and is_instance_valid(camada_linhas):
		_configurar_camada_linhas()
		return

	var cena_atual := get_tree().current_scene
	if cena_atual:
		camada_linhas = cena_atual.find_child("CamadaLinhas", true, false) as Node2D

	if camada_linhas:
		_configurar_camada_linhas()
	else:
		push_warning("LineRendererManager: CamadaLinhas não foi encontrada.")


func _configurar_camada_linhas() -> void:
	camada_linhas.z_index = 50
	camada_linhas.z_as_relative = false


func _criar_line2d(nome: String, largura: float, cor: Color, indice_z: int) -> Line2D:
	var linha := Line2D.new()
	linha.name = nome
	linha.width = maxf(largura, 1.0)
	linha.default_color = cor
	linha.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha.joint_mode = Line2D.LINE_JOINT_ROUND
	linha.z_index = indice_z
	linha.z_as_relative = false
	return linha


func _global_para_local_da_camada(posicao_global: Vector2) -> Vector2:
	return camada_linhas.to_local(posicao_global) if camada_linhas else posicao_global


func existe_linha_aberta() -> bool:
	return linha_atual != null and is_instance_valid(linha_atual)


func criar_linha(posicao_inicial: Vector2, posicao_final_inicial: Vector2) -> void:
	_resolver_camada_linhas()
	if not camada_linhas:
		return

	apagar_linha_atual()
	var inicio_local := _global_para_local_da_camada(posicao_inicial)
	var fim_local := _global_para_local_da_camada(posicao_final_inicial)

	linha_sombra_atual = _criar_line2d(
		"LinhaPreviewSombra",
		largura_linha_preview_sombra,
		cor_linha_preview_sombra,
		z_index_linha_preview_sombra
	)
	linha_sombra_atual.points = PackedVector2Array([inicio_local, fim_local])
	camada_linhas.add_child(linha_sombra_atual)

	linha_atual = _criar_line2d(
		"LinhaPreview", largura_linha_preview, cor_linha_preview, z_index_linha_preview
	)
	linha_atual.points = PackedVector2Array([inicio_local, fim_local])
	camada_linhas.add_child(linha_atual)


func atualizar_linha(posicao_final: Vector2) -> void:
	var fim_local := _global_para_local_da_camada(posicao_final)

	if linha_atual and is_instance_valid(linha_atual) and linha_atual.get_point_count() >= 2:
		linha_atual.set_point_position(1, fim_local)
	if (
		linha_sombra_atual
		and is_instance_valid(linha_sombra_atual)
		and linha_sombra_atual.get_point_count() >= 2
	):
		linha_sombra_atual.set_point_position(1, fim_local)


func transformar_linha_em_acerto(posicao_final: Vector2) -> void:
	if not existe_linha_aberta():
		return

	var fim_local := _global_para_local_da_camada(posicao_final)

	if linha_sombra_atual and is_instance_valid(linha_sombra_atual):
		if linha_sombra_atual.get_point_count() >= 2:
			linha_sombra_atual.set_point_position(1, fim_local)
		linha_sombra_atual.width = maxf(largura_linha_final_sombra, 1.0)
		linha_sombra_atual.default_color = cor_linha_final_sombra
		linha_sombra_atual.z_index = z_index_linha_final_sombra
		linha_sombra_atual.name = "LinhaAcertoSombra"

	if linha_atual and is_instance_valid(linha_atual):
		if linha_atual.get_point_count() >= 2:
			linha_atual.set_point_position(1, fim_local)
		linha_atual.width = maxf(largura_linha_final, 1.0)
		linha_atual.default_color = cor_linha_final
		linha_atual.z_index = z_index_linha_final
		linha_atual.name = "LinhaAcerto"

	linha_sombra_atual = null
	linha_atual = null


func apagar_linha_atual() -> void:
	if linha_sombra_atual and is_instance_valid(linha_sombra_atual):
		linha_sombra_atual.queue_free()
	if linha_atual and is_instance_valid(linha_atual):
		linha_atual.queue_free()

	linha_sombra_atual = null
	linha_atual = null


func limpar_todas_as_linhas() -> void:
	_resolver_camada_linhas()
	if not camada_linhas:
		return

	for filho in camada_linhas.get_children():
		if filho is Line2D:
			filho.queue_free()

	linha_sombra_atual = null
	linha_atual = null
