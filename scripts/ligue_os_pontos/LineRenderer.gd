extends Node

class_name LineRendererManager

# ============================================================
# LINE RENDERER MANAGER
# Gerenciador visual de linhas para minigames de ligação.
#
# Responsabilidades:
# - criar linha de preview;
# - criar sombra da linha;
# - atualizar a ponta da linha durante o arrasto;
# - transformar a linha atual em linha definitiva de acerto;
# - apagar linha atual em caso de erro/cancelamento;
# - limpar todas as linhas;
# - informar se existe linha aberta.
#
# Este script NÃO valida regra do jogo.
# Este script NÃO toca áudio.
# Este script NÃO controla input.
# Este script NÃO controla responsividade.
#
# A responsividade é controlada pelo AutoLoad:
# ResponsividadeUniversal.gd
# ============================================================


# ============================================================
# REFERÊNCIA DA CAMADA DE LINHAS
# ============================================================
@export_node_path("Node2D") var camada_linhas_path: NodePath

@onready var camada_linhas: Node2D = get_node_or_null(camada_linhas_path)


# ============================================================
# CONFIGURAÇÃO VISUAL DAS LINHAS DE PREVIEW
# ============================================================
@export var cor_linha_preview: Color = Color(1.0, 1.0, 1.0, 0.72)
@export var cor_linha_preview_sombra: Color = Color(0.0, 0.0, 0.0, 0.18)

@export var largura_linha_preview: float = 8.0
@export var largura_linha_preview_sombra: float = 16.0

@export var z_index_linha_preview: int = 60
@export var z_index_linha_preview_sombra: int = 59


# ============================================================
# CONFIGURAÇÃO VISUAL DAS LINHAS FINAIS
# ============================================================
@export var cor_linha_final: Color = Color(0.20, 0.85, 0.45, 0.42)
@export var cor_linha_final_sombra: Color = Color(0.0, 0.0, 0.0, 0.10)

@export var largura_linha_final: float = 5.0
@export var largura_linha_final_sombra: float = 10.0

@export var z_index_linha_final: int = 20
@export var z_index_linha_final_sombra: int = 19


# ============================================================
# ESTADO INTERNO
# ============================================================
var linha_atual: Line2D = null
var linha_sombra_atual: Line2D = null


func _ready() -> void:
	if not camada_linhas:
		push_warning("LineRendererManager: camada_linhas_path não foi configurado ou não encontrou CamadaLinhas.")
		return

	_configurar_camada_linhas()


# ============================================================
# CONFIGURAÇÃO INTERNA
# ============================================================
func _configurar_camada_linhas() -> void:
	if not camada_linhas:
		return

	camada_linhas.z_index = 50
	camada_linhas.z_as_relative = false


func _criar_line2d(
	nome: String,
	largura: float,
	cor: Color,
	z_index_linha: int
) -> Line2D:
	var linha := Line2D.new()

	linha.name = nome
	linha.width = largura
	linha.default_color = cor
	linha.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha.joint_mode = Line2D.LINE_JOINT_ROUND
	linha.z_index = z_index_linha
	linha.z_as_relative = false

	return linha


func _global_para_local_da_camada(posicao_global: Vector2) -> Vector2:
	if not camada_linhas:
		return posicao_global

	return camada_linhas.to_local(posicao_global)


# ============================================================
# API PÚBLICA
# ============================================================
func existe_linha_aberta() -> bool:
	return linha_atual != null and is_instance_valid(linha_atual)


func criar_linha(posicao_inicial: Vector2, posicao_final_inicial: Vector2) -> void:
	if not camada_linhas:
		push_warning("LineRendererManager: não foi possível criar linha porque CamadaLinhas não existe.")
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

	linha_sombra_atual.add_point(inicio_local)
	linha_sombra_atual.add_point(fim_local)
	camada_linhas.add_child(linha_sombra_atual)

	linha_atual = _criar_line2d(
		"LinhaPreview",
		largura_linha_preview,
		cor_linha_preview,
		z_index_linha_preview
	)

	linha_atual.add_point(inicio_local)
	linha_atual.add_point(fim_local)
	camada_linhas.add_child(linha_atual)


func atualizar_linha(posicao_final: Vector2) -> void:
	var fim_local := _global_para_local_da_camada(posicao_final)

	if linha_atual and is_instance_valid(linha_atual):
		linha_atual.set_point_position(1, fim_local)

	if linha_sombra_atual and is_instance_valid(linha_sombra_atual):
		linha_sombra_atual.set_point_position(1, fim_local)


func transformar_linha_em_acerto(posicao_final: Vector2) -> void:
	var fim_local := _global_para_local_da_camada(posicao_final)

	if linha_sombra_atual and is_instance_valid(linha_sombra_atual):
		linha_sombra_atual.set_point_position(1, fim_local)
		linha_sombra_atual.width = largura_linha_final_sombra
		linha_sombra_atual.default_color = cor_linha_final_sombra
		linha_sombra_atual.z_index = z_index_linha_final_sombra
		linha_sombra_atual.z_as_relative = false
		linha_sombra_atual.name = "LinhaAcertoSombra"

	if linha_atual and is_instance_valid(linha_atual):
		linha_atual.set_point_position(1, fim_local)
		linha_atual.width = largura_linha_final
		linha_atual.default_color = cor_linha_final
		linha_atual.z_index = z_index_linha_final
		linha_atual.z_as_relative = false
		linha_atual.name = "LinhaAcerto"

	# Importante:
	# Não damos queue_free aqui, porque a linha correta precisa permanecer na tela.
	# Apenas soltamos a referência para permitir uma nova linha.
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
	if not camada_linhas:
		return

	for filho in camada_linhas.get_children():
		if filho is Line2D:
			filho.queue_free()

	linha_sombra_atual = null
	linha_atual = null
