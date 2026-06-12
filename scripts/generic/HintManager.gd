extends Node

class_name HintManager

enum ModoPista {
	ARRASTAR_PECAS,
	LIGAR_PARES,
	LIGAR_NUMEROS,
	CUSTOM
}

@export var modo_pista: ModoPista = ModoPista.ARRASTAR_PECAS

@export_node_path("Node2D") var area_jogo_path: NodePath
@export_node_path("Node2D") var camada_linhas_path: NodePath
@export_node_path("Label") var texto_dica_path: NodePath
@export_node_path("Node") var robo_path: NodePath

@onready var area_jogo: Node2D = get_node_or_null(area_jogo_path)
@onready var camada_linhas: Node2D = get_node_or_null(camada_linhas_path)
@onready var texto_dica: Label = get_node_or_null(texto_dica_path)
@onready var robo: Node = get_node_or_null(robo_path)

@export var ativar_pistas := true
@export var tempo_pista_1 := 8.0
@export var tempo_pista_2 := 15.0
@export var tempo_pista_3 := 25.0

@export var cor_amarela_pista: Color = Color(1.8, 1.55, 0.15, 1.0)
@export var cor_normal: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var escala_origem_pista := 1.10
@export var escala_destino_pista := 1.16

@export var largura_linha_dica := 10.0
@export var largura_linha_dica_sombra := 22.0
@export var cor_linha_dica: Color = Color(1.0, 0.85, 0.05, 1.0)
@export var cor_linha_dica_sombra: Color = Color(0.0, 0.0, 0.0, 0.28)

var tempo_sem_acao := 0.0
var nivel_pista_atual := 0
var pista_ativa := false
var sistema_pausado := false
var nivel_concluido := false

var origem_dica: Node = null
var destino_dica: Node = null

var tween_origem_cor: Tween = null
var tween_origem_escala: Tween = null
var tween_destino_cor: Tween = null
var tween_destino_escala: Tween = null
var tween_linha_dica: Tween = null
var tween_linha_largura: Tween = null

var linha_dica: Line2D = null
var linha_dica_sombra: Line2D = null

var modulates_originais := {}
var escalas_originais := {}

var callback_buscar_origem: Callable
var callback_buscar_destino: Callable


func _ready() -> void:
	if texto_dica:
		texto_dica.visible = false

	_resolver_referencias()


func _process(delta: float) -> void:
	if not ativar_pistas:
		return

	if sistema_pausado:
		return

	if nivel_concluido:
		return

	tempo_sem_acao += delta
	verificar_pistas_por_inatividade()


func _resolver_referencias() -> void:
	var cena_atual = get_tree().current_scene

	if not area_jogo and cena_atual:
		var area_encontrada = cena_atual.find_child("AreaJogo", true, false)
		if area_encontrada and area_encontrada is Node2D:
			area_jogo = area_encontrada

	if not camada_linhas and cena_atual:
		var camada_encontrada = cena_atual.find_child("CamadaLinhas", true, false)
		if camada_encontrada and camada_encontrada is Node2D:
			camada_linhas = camada_encontrada

	if camada_linhas:
		camada_linhas.z_index = 900
		camada_linhas.z_as_relative = false


func registrar_interacao() -> void:
	pass


func registrar_acao_sem_resetar_pista() -> void:
	pass


func registrar_acerto() -> void:
	resetar_pistas()


func resetar_timer_sem_limpar_visual() -> void:
	pass


func pausar_pistas() -> void:
	sistema_pausado = true


func retomar_pistas() -> void:
	sistema_pausado = false


func finalizar_nivel() -> void:
	nivel_concluido = true
	resetar_pistas()


func reiniciar_sistema() -> void:
	nivel_concluido = false
	sistema_pausado = false
	resetar_pistas()
	_resolver_referencias()


func configurar_callbacks(buscar_origem: Callable, buscar_destino: Callable) -> void:
	callback_buscar_origem = buscar_origem
	callback_buscar_destino = buscar_destino
	modo_pista = ModoPista.CUSTOM


func forcar_pista(nivel: int) -> void:
	if nivel_concluido:
		return

	if nivel <= 1:
		resetar_pistas()
		mostrar_pista(1)
		tempo_sem_acao = tempo_pista_1
		return

	if nivel == 2:
		mostrar_pista(2)
		tempo_sem_acao = tempo_pista_2
		return

	if nivel >= 3:
		mostrar_pista(3)
		tempo_sem_acao = tempo_pista_3
		return


func verificar_pistas_por_inatividade() -> void:
	if nivel_pista_atual == 0 and tempo_sem_acao >= tempo_pista_1:
		mostrar_pista(1)
		return

	if nivel_pista_atual == 1 and tempo_sem_acao >= tempo_pista_2:
		mostrar_pista(2)
		return

	if nivel_pista_atual == 2 and tempo_sem_acao >= tempo_pista_3:
		mostrar_pista(3)
		return


func mostrar_pista(nivel: int) -> void:
	if nivel_concluido:
		return

	if sistema_pausado:
		return

	_resolver_referencias()

	nivel_pista_atual = nivel
	pista_ativa = true

	if texto_dica:
		texto_dica.visible = false

	if nivel == 1:
		pista_1_origem_piscando()
	elif nivel == 2:
		pista_2_destino_piscando_e_movendo()
	elif nivel == 3:
		pista_3_linha_amarela()


func pista_1_origem_piscando() -> void:
	if not origem_dica or not is_instance_valid(origem_dica):
		origem_dica = buscar_origem_para_pista()

	if origem_dica:
		destacar_origem_piscando(origem_dica)

	animar_robo_dica()


func pista_2_destino_piscando_e_movendo() -> void:
	if not origem_dica or not is_instance_valid(origem_dica):
		origem_dica = buscar_origem_para_pista()

	destino_dica = buscar_destino_para_pista(origem_dica)

	if destino_dica:
		destacar_destino_piscando_e_movendo(destino_dica)

	animar_robo_apontar()


func pista_3_linha_amarela() -> void:
	if not origem_dica or not is_instance_valid(origem_dica):
		origem_dica = buscar_origem_para_pista()

	if not destino_dica or not is_instance_valid(destino_dica):
		destino_dica = buscar_destino_para_pista(origem_dica)

	if origem_dica and destino_dica:
		criar_linha_dica(origem_dica, destino_dica)

	animar_robo_apontar()


func buscar_origem_para_pista() -> Node:
	if modo_pista == ModoPista.CUSTOM:
		if callback_buscar_origem.is_valid():
			return callback_buscar_origem.call()
		return null

	if modo_pista == ModoPista.ARRASTAR_PECAS:
		return buscar_peca_disponivel()

	if modo_pista == ModoPista.LIGAR_PARES:
		return buscar_ponto_saida_ligar_pares()

	if modo_pista == ModoPista.LIGAR_NUMEROS:
		return buscar_numero_inicial_ligar_numeros()

	return null


func buscar_destino_para_pista(origem: Node) -> Node:
	if not origem:
		return null

	if modo_pista == ModoPista.CUSTOM:
		if callback_buscar_destino.is_valid():
			return callback_buscar_destino.call(origem)
		return null

	if modo_pista == ModoPista.ARRASTAR_PECAS:
		return buscar_slot_da_peca(origem)

	if modo_pista == ModoPista.LIGAR_PARES:
		return buscar_destino_ligar_pares(origem)

	if modo_pista == ModoPista.LIGAR_NUMEROS:
		return buscar_destino_ligar_numeros(origem)

	return null


func buscar_peca_disponivel() -> Node:
	if not area_jogo:
		return null

	for filho in area_jogo.get_children():
		if filho.is_in_group("pecas") and peca_esta_disponivel(filho):
			return filho

	for filho in area_jogo.get_children():
		if filho.has_signal("peca_encaixada") and peca_esta_disponivel(filho):
			return filho

	return null


func peca_esta_disponivel(peca: Node) -> bool:
	if not peca:
		return false

	if peca.has_method("esta_disponivel_para_pista"):
		return peca.esta_disponivel_para_pista()

	var valor_travado = peca.get("esta_travado")
	if valor_travado != null:
		return not bool(valor_travado)

	var valor_encaixada = peca.get("encaixada")
	if valor_encaixada != null:
		return not bool(valor_encaixada)

	var valor_ja_encaixada = peca.get("ja_encaixada")
	if valor_ja_encaixada != null:
		return not bool(valor_ja_encaixada)

	return true


func buscar_slot_da_peca(peca: Node) -> Node:
	if not peca:
		return null

	if peca.has_method("get_slot_correto"):
		return peca.get_slot_correto()

	var nome_slot = peca.get("slot_correto_nome")

	if nome_slot != null and String(nome_slot) != "":
		if area_jogo:
			return area_jogo.get_node_or_null(String(nome_slot))

	return null


func buscar_ponto_saida_ligar_pares() -> Node:
	var pontos = pegar_pontos_da_fase()

	for ponto in pontos:
		if ponto.tipo == ponto.Tipo.SAIDA and not ponto.esta_conectado_saida:
			return ponto

	return null


func buscar_destino_ligar_pares(ponto_saida: Node) -> Node:
	if not ponto_saida:
		return null

	var pontos = pegar_pontos_da_fase()

	for ponto in pontos:
		if ponto.tipo == ponto.Tipo.CHEGADA:
			if not ponto.esta_conectado_chegada and ponto.id_par == ponto_saida.id_par:
				return ponto

	return null


func buscar_numero_inicial_ligar_numeros() -> Node:
	var pontos = pegar_pontos_da_fase()
	var melhor_ponto: Node = null
	var menor_valor := 999999

	for ponto in pontos:
		if ponto.esta_conectado_saida:
			continue

		var destino = buscar_destino_ligar_numeros(ponto)

		if destino:
			if ponto.valor_numero < menor_valor:
				menor_valor = ponto.valor_numero
				melhor_ponto = ponto

	return melhor_ponto


func buscar_destino_ligar_numeros(ponto_saida: Node) -> Node:
	if not ponto_saida:
		return null

	var pontos = pegar_pontos_da_fase()
	var valor_destino = ponto_saida.valor_numero + 1

	for ponto in pontos:
		if ponto == ponto_saida:
			continue

		if ponto.valor_numero == valor_destino:
			if not ponto.esta_conectado_chegada:
				return ponto

	return null


func pegar_pontos_da_fase() -> Array:
	var pontos := []

	if not area_jogo:
		return pontos

	for filho in area_jogo.get_children():
		if filho.is_in_group("pontos"):
			pontos.append(filho)

	return pontos


func destacar_origem_piscando(origem: Node) -> void:
	if not origem or not origem is CanvasItem:
		return

	var canvas_item := origem as CanvasItem

	if not modulates_originais.has(origem):
		modulates_originais[origem] = canvas_item.modulate

	if origem is Node2D and not escalas_originais.has(origem):
		escalas_originais[origem] = origem.scale

	if tween_origem_cor:
		tween_origem_cor.kill()

	if tween_origem_escala:
		tween_origem_escala.kill()

	tween_origem_cor = create_tween()
	tween_origem_cor.set_loops()
	tween_origem_cor.tween_property(canvas_item, "modulate", cor_amarela_pista, 0.35)
	tween_origem_cor.tween_property(canvas_item, "modulate", cor_normal, 0.35)

	if origem is Node2D:
		tween_origem_escala = create_tween()
		tween_origem_escala.set_loops()
		tween_origem_escala.tween_property(origem, "scale", escalas_originais[origem] * escala_origem_pista, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_origem_escala.tween_property(origem, "scale", escalas_originais[origem], 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func destacar_destino_piscando_e_movendo(destino: Node) -> void:
	if not destino or not destino is CanvasItem:
		return

	var canvas_item := destino as CanvasItem

	if not modulates_originais.has(destino):
		modulates_originais[destino] = canvas_item.modulate

	if destino is Node2D and not escalas_originais.has(destino):
		escalas_originais[destino] = destino.scale

	if tween_destino_cor:
		tween_destino_cor.kill()

	if tween_destino_escala:
		tween_destino_escala.kill()

	tween_destino_cor = create_tween()
	tween_destino_cor.set_loops()
	tween_destino_cor.tween_property(canvas_item, "modulate", cor_amarela_pista, 0.32)
	tween_destino_cor.tween_property(canvas_item, "modulate", cor_normal, 0.32)

	if destino is Node2D:
		tween_destino_escala = create_tween()
		tween_destino_escala.set_loops()
		tween_destino_escala.tween_property(destino, "scale", escalas_originais[destino] * escala_destino_pista, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_destino_escala.tween_property(destino, "scale", escalas_originais[destino], 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func criar_linha_dica(origem: Node, destino: Node) -> void:
	remover_linha_dica()

	if not camada_linhas:
		push_warning("HintManager: CamadaLinhas não configurada.")
		return

	if not origem or not destino:
		return

	origem_dica = origem
	destino_dica = destino

	linha_dica_sombra = Line2D.new()
	linha_dica_sombra.name = "LinhaDicaSombra"
	linha_dica_sombra.width = largura_linha_dica_sombra
	linha_dica_sombra.default_color = cor_linha_dica_sombra
	linha_dica_sombra.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica_sombra.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica_sombra.joint_mode = Line2D.LINE_JOINT_ROUND
	linha_dica_sombra.z_index = 998
	linha_dica_sombra.z_as_relative = false
	camada_linhas.add_child(linha_dica_sombra)

	linha_dica = Line2D.new()
	linha_dica.name = "LinhaDica"
	linha_dica.width = largura_linha_dica
	linha_dica.default_color = cor_linha_dica
	linha_dica.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica.joint_mode = Line2D.LINE_JOINT_ROUND
	linha_dica.z_index = 999
	linha_dica.z_as_relative = false
	camada_linhas.add_child(linha_dica)

	_atualizar_linha_dica_animada(0.0)

	if tween_linha_dica:
		tween_linha_dica.kill()

	if tween_linha_largura:
		tween_linha_largura.kill()

	tween_linha_dica = create_tween()
	tween_linha_dica.set_loops()
	tween_linha_dica.tween_method(_atualizar_linha_dica_animada, 0.0, 1.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_linha_dica.tween_method(_atualizar_linha_dica_animada, 1.0, 0.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_linha_largura = create_tween()
	tween_linha_largura.set_loops()
	tween_linha_largura.tween_property(linha_dica, "width", largura_linha_dica + 5.0, 0.35)
	tween_linha_largura.tween_property(linha_dica, "width", largura_linha_dica, 0.35)


func _atualizar_linha_dica_animada(progresso: float) -> void:
	if not linha_dica or not is_instance_valid(linha_dica):
		return

	if not linha_dica_sombra or not is_instance_valid(linha_dica_sombra):
		return

	if not camada_linhas or not is_instance_valid(camada_linhas):
		return

	if not origem_dica or not is_instance_valid(origem_dica):
		return

	if not destino_dica or not is_instance_valid(destino_dica):
		return

	if not origem_dica is Node2D or not destino_dica is Node2D:
		return

	var origem_local: Vector2 = camada_linhas.to_local(origem_dica.global_position)
	var destino_local: Vector2 = camada_linhas.to_local(destino_dica.global_position)
	var ponto_animado: Vector2 = origem_local.lerp(destino_local, clamp(progresso, 0.0, 1.0))

	linha_dica.clear_points()
	linha_dica.add_point(origem_local)
	linha_dica.add_point(ponto_animado)

	linha_dica_sombra.clear_points()
	linha_dica_sombra.add_point(origem_local)
	linha_dica_sombra.add_point(ponto_animado)


func remover_linha_dica() -> void:
	if tween_linha_dica:
		tween_linha_dica.kill()
		tween_linha_dica = null

	if tween_linha_largura:
		tween_linha_largura.kill()
		tween_linha_largura = null

	if linha_dica_sombra and is_instance_valid(linha_dica_sombra):
		linha_dica_sombra.queue_free()

	if linha_dica and is_instance_valid(linha_dica):
		linha_dica.queue_free()

	linha_dica_sombra = null
	linha_dica = null


func resetar_pistas() -> void:
	tempo_sem_acao = 0.0
	nivel_pista_atual = 0
	pista_ativa = false

	if texto_dica:
		texto_dica.visible = false

	if tween_origem_cor:
		tween_origem_cor.kill()
		tween_origem_cor = null

	if tween_origem_escala:
		tween_origem_escala.kill()
		tween_origem_escala = null

	if tween_destino_cor:
		tween_destino_cor.kill()
		tween_destino_cor = null

	if tween_destino_escala:
		tween_destino_escala.kill()
		tween_destino_escala = null

	for node in modulates_originais.keys():
		if node and is_instance_valid(node) and node is CanvasItem:
			node.modulate = modulates_originais[node]

	for node in escalas_originais.keys():
		if node and is_instance_valid(node):
			node.scale = escalas_originais[node]

	modulates_originais.clear()
	escalas_originais.clear()

	origem_dica = null
	destino_dica = null

	remover_linha_dica()


func animar_robo_dica() -> void:
	if not robo:
		return

	if robo.has_method("dar_dica"):
		robo.dar_dica()
	elif robo.has_method("pensar"):
		robo.pensar()
	elif robo.has_method("comemorar"):
		robo.comemorar()


func animar_robo_apontar() -> void:
	if not robo:
		return

	if robo.has_method("apontar"):
		robo.apontar()
	elif robo.has_method("dar_dica"):
		robo.dar_dica()
	elif robo.has_method("pensar"):
		robo.pensar()
