extends Node

class_name HintManager

signal pista_exibida(nivel: int, origem: Node, destino: Node)
signal interacao_registrada

enum ModoPista { ARRASTAR_PECAS, LIGAR_PARES, LIGAR_NUMEROS, CUSTOM }

@export var modo_pista: ModoPista = ModoPista.ARRASTAR_PECAS

@export_node_path("Node2D") var area_jogo_path: NodePath
@export_node_path("Node2D") var camada_linhas_path: NodePath
@export_node_path("Label") var texto_dica_path: NodePath
@export_node_path("Node") var robo_path: NodePath

@export_group("Tempos das pistas")
@export var ativar_pistas := true
@export_range(0.5, 120.0, 0.5) var tempo_pista_1 := 8.0
@export_range(1.0, 180.0, 0.5) var tempo_pista_2 := 15.0
@export_range(1.5, 240.0, 0.5) var tempo_pista_3 := 25.0
@export var limpar_pista_ao_interagir := true

@export_group("Destaque visual")
@export var cor_amarela_pista: Color = Color(1.8, 1.55, 0.15, 1.0)
@export var escala_origem_pista := 1.10
@export var escala_destino_pista := 1.16
@export var largura_linha_dica := 10.0
@export var largura_linha_dica_sombra := 22.0
@export var cor_linha_dica: Color = Color(1.0, 0.85, 0.05, 1.0)
@export var cor_linha_dica_sombra: Color = Color(0.0, 0.0, 0.0, 0.28)

@onready var area_jogo: Node2D = get_node_or_null(area_jogo_path) as Node2D
@onready var camada_linhas: Node2D = get_node_or_null(camada_linhas_path) as Node2D
@onready var texto_dica: Label = get_node_or_null(texto_dica_path) as Label
@onready var robo: Node = get_node_or_null(robo_path)

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

var modulates_originais: Dictionary = {}
var escalas_originais: Dictionary = {}

var callback_buscar_origem: Callable
var callback_buscar_destino: Callable


func _ready() -> void:
	_normalizar_tempos()
	_resolver_referencias()

	if texto_dica:
		texto_dica.visible = false


func _exit_tree() -> void:
	_limpar_animacoes_e_visuais()


func _process(delta: float) -> void:
	if not ativar_pistas or sistema_pausado or nivel_concluido:
		return

	tempo_sem_acao += maxf(delta, 0.0)
	verificar_pistas_por_inatividade()


func _normalizar_tempos() -> void:
	tempo_pista_1 = maxf(tempo_pista_1, 0.5)
	tempo_pista_2 = maxf(tempo_pista_2, tempo_pista_1 + 0.5)
	tempo_pista_3 = maxf(tempo_pista_3, tempo_pista_2 + 0.5)


func _resolver_referencias() -> void:
	var cena_atual := get_tree().current_scene

	if not _node_valido(area_jogo) and cena_atual:
		area_jogo = cena_atual.find_child("AreaJogo", true, false) as Node2D

	if not _node_valido(camada_linhas) and cena_atual:
		camada_linhas = cena_atual.find_child("CamadaLinhas", true, false) as Node2D

	if not _node_valido(robo) and cena_atual:
		robo = cena_atual.find_child("ProfessorRobo", true, false)

	if camada_linhas:
		camada_linhas.z_index = 900
		camada_linhas.z_as_relative = false


# Registra uma ação real do jogador. Por padrão, reinicia o relógio de
# inatividade e limpa a pista visual anterior, porque o usuário retomou a tarefa.
func registrar_interacao() -> void:
	if nivel_concluido:
		return

	tempo_sem_acao = 0.0
	interacao_registrada.emit()

	if limpar_pista_ao_interagir and pista_ativa:
		_limpar_pista_visual_sem_alterar_estado()
		nivel_pista_atual = 0
		pista_ativa = false


# Mantém a pista que já está visível, mas reinicia o relógio de inatividade.
# É útil durante uma tentativa, um arraste ou um erro em que a orientação deve
# permanecer na tela.
func registrar_acao_sem_resetar_pista() -> void:
	resetar_timer_sem_limpar_visual()


func registrar_acerto() -> void:
	resetar_pistas()


func resetar_timer_sem_limpar_visual() -> void:
	if nivel_concluido:
		return

	tempo_sem_acao = 0.0
	interacao_registrada.emit()


func pausar_pistas() -> void:
	sistema_pausado = true


func retomar_pistas(reiniciar_timer: bool = true) -> void:
	sistema_pausado = false

	if reiniciar_timer:
		resetar_timer_sem_limpar_visual()


func finalizar_nivel() -> void:
	nivel_concluido = true
	sistema_pausado = true
	resetar_pistas()


func reiniciar_sistema() -> void:
	nivel_concluido = false
	sistema_pausado = false
	_normalizar_tempos()
	_resolver_referencias()
	resetar_pistas()


func configurar_callbacks(buscar_origem: Callable, buscar_destino: Callable) -> void:
	callback_buscar_origem = buscar_origem
	callback_buscar_destino = buscar_destino
	modo_pista = ModoPista.CUSTOM


func forcar_pista(nivel: int) -> void:
	if nivel_concluido or not ativar_pistas:
		return

	var nivel_seguro := clampi(nivel, 1, 3)

	if nivel_seguro == 1:
		resetar_pistas()
	else:
		_limpar_pista_visual_sem_alterar_estado()

	mostrar_pista(nivel_seguro)

	match nivel_seguro:
		1:
			tempo_sem_acao = tempo_pista_1
		2:
			tempo_sem_acao = tempo_pista_2
		3:
			tempo_sem_acao = tempo_pista_3


func verificar_pistas_por_inatividade() -> void:
	if nivel_pista_atual == 0 and tempo_sem_acao >= tempo_pista_1:
		mostrar_pista(1)
	elif nivel_pista_atual == 1 and tempo_sem_acao >= tempo_pista_2:
		mostrar_pista(2)
	elif nivel_pista_atual == 2 and tempo_sem_acao >= tempo_pista_3:
		mostrar_pista(3)


func mostrar_pista(nivel: int) -> void:
	if nivel_concluido or sistema_pausado or not ativar_pistas:
		return

	_resolver_referencias()
	_limpar_pista_visual_sem_alterar_estado()

	nivel_pista_atual = clampi(nivel, 1, 3)
	pista_ativa = true

	if texto_dica:
		texto_dica.visible = false

	match nivel_pista_atual:
		1:
			pista_1_origem_piscando()
		2:
			pista_2_destino_piscando_e_movendo()
		3:
			pista_3_linha_amarela()

	pista_exibida.emit(nivel_pista_atual, origem_dica, destino_dica)


func pista_1_origem_piscando() -> void:
	origem_dica = buscar_origem_para_pista()

	if origem_dica:
		destacar_origem_piscando(origem_dica)

	animar_robo_dica()


func pista_2_destino_piscando_e_movendo() -> void:
	if not _node_valido(origem_dica):
		origem_dica = buscar_origem_para_pista()

	destino_dica = buscar_destino_para_pista(origem_dica)

	if destino_dica:
		destacar_destino_piscando_e_movendo(destino_dica)

	animar_robo_apontar()


func pista_3_linha_amarela() -> void:
	if not _node_valido(origem_dica):
		origem_dica = buscar_origem_para_pista()

	if not _node_valido(destino_dica):
		destino_dica = buscar_destino_para_pista(origem_dica)

	if origem_dica and destino_dica:
		criar_linha_dica(origem_dica, destino_dica)

	animar_robo_apontar()


func buscar_origem_para_pista() -> Node:
	if modo_pista == ModoPista.CUSTOM:
		return callback_buscar_origem.call() if callback_buscar_origem.is_valid() else null

	match modo_pista:
		ModoPista.ARRASTAR_PECAS:
			return buscar_peca_disponivel()
		ModoPista.LIGAR_PARES:
			return buscar_ponto_saida_ligar_pares()
		ModoPista.LIGAR_NUMEROS:
			return buscar_numero_inicial_ligar_numeros()

	return null


func buscar_destino_para_pista(origem: Node) -> Node:
	if not _node_valido(origem):
		return null

	if modo_pista == ModoPista.CUSTOM:
		return callback_buscar_destino.call(origem) if callback_buscar_destino.is_valid() else null

	match modo_pista:
		ModoPista.ARRASTAR_PECAS:
			return buscar_slot_da_peca(origem)
		ModoPista.LIGAR_PARES:
			return buscar_destino_ligar_pares(origem)
		ModoPista.LIGAR_NUMEROS:
			return buscar_destino_ligar_numeros(origem)

	return null


func buscar_peca_disponivel() -> Node:
	if not area_jogo:
		return null

	for filho in _nos_do_grupo_na_area("pecas"):
		if peca_esta_disponivel(filho):
			return filho

	for filho in area_jogo.find_children("*", "Area2D", true, false):
		if filho.has_signal("peca_encaixada") and peca_esta_disponivel(filho):
			return filho

	return null


func peca_esta_disponivel(peca: Node) -> bool:
	if not _node_valido(peca):
		return false

	if peca.has_method("esta_disponivel_para_pista"):
		return bool(peca.call("esta_disponivel_para_pista"))

	for nome_propriedade in ["esta_travado", "encaixada", "ja_encaixada", "travado"]:
		if _objeto_tem_propriedade(peca, nome_propriedade):
			return not bool(peca.get(nome_propriedade))

	return true


func buscar_slot_da_peca(peca: Node) -> Node:
	if not _node_valido(peca):
		return null

	if peca.has_method("get_slot_correto"):
		var slot_por_metodo: Node = peca.call("get_slot_correto")
		if _node_valido(slot_por_metodo):
			return slot_por_metodo

	if not _objeto_tem_propriedade(peca, "slot_correto_nome"):
		return null

	var nome_slot := String(peca.get("slot_correto_nome"))
	if nome_slot.is_empty() or not area_jogo:
		return null

	var slot := area_jogo.get_node_or_null(nome_slot)
	if slot:
		return slot

	return area_jogo.find_child(nome_slot, true, false)


func buscar_ponto_saida_ligar_pares() -> Node:
	for ponto in pegar_pontos_da_fase():
		if _tipo_ponto(ponto) == 0 and not _bool_propriedade(ponto, "esta_conectado_saida"):
			return ponto

	return null


func buscar_destino_ligar_pares(ponto_saida: Node) -> Node:
	if not _node_valido(ponto_saida):
		return null

	var id_origem := int(ponto_saida.get("id_par"))

	for ponto in pegar_pontos_da_fase():
		if _tipo_ponto(ponto) == 1:
			if (
				not _bool_propriedade(ponto, "esta_conectado_chegada")
				and int(ponto.get("id_par")) == id_origem
			):
				return ponto

	return null


func buscar_numero_inicial_ligar_numeros() -> Node:
	var melhor_ponto: Node = null
	var menor_valor := 2147483647

	for ponto in pegar_pontos_da_fase():
		if _bool_propriedade(ponto, "esta_conectado_saida"):
			continue

		var destino := buscar_destino_ligar_numeros(ponto)
		if destino:
			var valor := int(ponto.get("valor_numero"))
			if valor < menor_valor:
				menor_valor = valor
				melhor_ponto = ponto

	return melhor_ponto


func buscar_destino_ligar_numeros(ponto_saida: Node) -> Node:
	if not _node_valido(ponto_saida):
		return null

	var valor_destino := int(ponto_saida.get("valor_numero")) + 1

	for ponto in pegar_pontos_da_fase():
		if ponto == ponto_saida:
			continue

		if (
			int(ponto.get("valor_numero")) == valor_destino
			and not _bool_propriedade(ponto, "esta_conectado_chegada")
		):
			return ponto

	return null


func pegar_pontos_da_fase() -> Array[Node]:
	return _nos_do_grupo_na_area("pontos")


func _nos_do_grupo_na_area(nome_grupo: StringName) -> Array[Node]:
	var resultado: Array[Node] = []

	if not area_jogo:
		return resultado

	for node in get_tree().get_nodes_in_group(nome_grupo):
		if node is Node and area_jogo.is_ancestor_of(node):
			resultado.append(node)

	return resultado


func destacar_origem_piscando(origem: Node) -> void:
	_destacar_node_piscando(origem, escala_origem_pista, true)


func destacar_destino_piscando_e_movendo(destino: Node) -> void:
	_destacar_node_piscando(destino, escala_destino_pista, false)


func _destacar_node_piscando(node: Node, multiplicador_escala: float, origem: bool) -> void:
	if not _node_valido(node) or not node is CanvasItem:
		return

	var canvas_item := node as CanvasItem
	if not modulates_originais.has(node):
		modulates_originais[node] = canvas_item.modulate

	if node is Node2D and not escalas_originais.has(node):
		escalas_originais[node] = (node as Node2D).scale

	var cor_original: Color = modulates_originais[node]
	var tween_cor := create_tween().set_loops()
	tween_cor.tween_property(canvas_item, "modulate", cor_amarela_pista, 0.34)
	tween_cor.tween_property(canvas_item, "modulate", cor_original, 0.34)

	var tween_escala: Tween = null
	if node is Node2D:
		var node_2d := node as Node2D
		var escala_original: Vector2 = escalas_originais[node]
		tween_escala = create_tween().set_loops()
		(
			tween_escala
			. tween_property(node_2d, "scale", escala_original * multiplicador_escala, 0.34)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_IN_OUT)
		)
		(
			tween_escala
			. tween_property(node_2d, "scale", escala_original, 0.34)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_IN_OUT)
		)

	if origem:
		tween_origem_cor = tween_cor
		tween_origem_escala = tween_escala
	else:
		tween_destino_cor = tween_cor
		tween_destino_escala = tween_escala


func criar_linha_dica(origem: Node, destino: Node) -> void:
	remover_linha_dica()
	_resolver_referencias()

	if not camada_linhas:
		push_warning(
			"HintManager: CamadaLinhas não configurada; a pista de nível 3 não será desenhada."
		)
		return

	if not origem is Node2D or not destino is Node2D:
		return

	origem_dica = origem
	destino_dica = destino

	linha_dica_sombra = _criar_line2d(
		"LinhaDicaSombra", largura_linha_dica_sombra, cor_linha_dica_sombra, 998
	)
	camada_linhas.add_child(linha_dica_sombra)

	linha_dica = _criar_line2d("LinhaDica", largura_linha_dica, cor_linha_dica, 999)
	camada_linhas.add_child(linha_dica)

	_atualizar_linha_dica_animada(0.0)

	tween_linha_dica = create_tween().set_loops()
	(
		tween_linha_dica
		. tween_method(_atualizar_linha_dica_animada, 0.0, 1.0, 0.7)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)
	(
		tween_linha_dica
		. tween_method(_atualizar_linha_dica_animada, 1.0, 0.0, 0.7)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)

	tween_linha_largura = create_tween().set_loops()
	tween_linha_largura.tween_property(linha_dica, "width", largura_linha_dica + 5.0, 0.35)
	tween_linha_largura.tween_property(linha_dica, "width", largura_linha_dica, 0.35)


func _criar_line2d(nome_linha: String, largura: float, cor: Color, indice_z: int) -> Line2D:
	var linha := Line2D.new()
	linha.name = nome_linha
	linha.width = largura
	linha.default_color = cor
	linha.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha.joint_mode = Line2D.LINE_JOINT_ROUND
	linha.z_index = indice_z
	linha.z_as_relative = false
	return linha


func _atualizar_linha_dica_animada(progresso: float) -> void:
	if not _node_valido(linha_dica) or not _node_valido(linha_dica_sombra):
		return
	if not _node_valido(camada_linhas) or not origem_dica is Node2D or not destino_dica is Node2D:
		return

	var origem_local := camada_linhas.to_local((origem_dica as Node2D).global_position)
	var destino_local := camada_linhas.to_local((destino_dica as Node2D).global_position)
	var ponto_animado := origem_local.lerp(destino_local, clampf(progresso, 0.0, 1.0))

	linha_dica.points = PackedVector2Array([origem_local, ponto_animado])
	linha_dica_sombra.points = PackedVector2Array([origem_local, ponto_animado])


func remover_linha_dica() -> void:
	_matar_tween(tween_linha_dica)
	_matar_tween(tween_linha_largura)
	tween_linha_dica = null
	tween_linha_largura = null

	if _node_valido(linha_dica_sombra):
		linha_dica_sombra.queue_free()
	if _node_valido(linha_dica):
		linha_dica.queue_free()

	linha_dica_sombra = null
	linha_dica = null


func resetar_pistas() -> void:
	tempo_sem_acao = 0.0
	nivel_pista_atual = 0
	pista_ativa = false
	_limpar_pista_visual_sem_alterar_estado()


func _limpar_pista_visual_sem_alterar_estado() -> void:
	if texto_dica:
		texto_dica.visible = false

	_matar_tween(tween_origem_cor)
	_matar_tween(tween_origem_escala)
	_matar_tween(tween_destino_cor)
	_matar_tween(tween_destino_escala)

	tween_origem_cor = null
	tween_origem_escala = null
	tween_destino_cor = null
	tween_destino_escala = null

	for node in modulates_originais.keys():
		if _node_valido(node) and node is CanvasItem:
			(node as CanvasItem).modulate = modulates_originais[node]

	for node in escalas_originais.keys():
		if _node_valido(node) and node is Node2D:
			(node as Node2D).scale = escalas_originais[node]

	modulates_originais.clear()
	escalas_originais.clear()
	origem_dica = null
	destino_dica = null
	remover_linha_dica()


func _limpar_animacoes_e_visuais() -> void:
	_limpar_pista_visual_sem_alterar_estado()


func animar_robo_dica() -> void:
	if not _node_valido(robo):
		return

	if robo.has_method("dar_dica"):
		robo.call("dar_dica")
	elif robo.has_method("pensar"):
		robo.call("pensar")


func animar_robo_apontar() -> void:
	if not _node_valido(robo):
		return

	if robo.has_method("apontar"):
		robo.call("apontar")
	elif robo.has_method("dar_dica"):
		robo.call("dar_dica")
	elif robo.has_method("pensar"):
		robo.call("pensar")


func _objeto_tem_propriedade(objeto: Object, nome_propriedade: StringName) -> bool:
	if not objeto:
		return false

	for propriedade in objeto.get_property_list():
		if StringName(propriedade.name) == nome_propriedade:
			return true

	return false


func _bool_propriedade(objeto: Object, nome_propriedade: StringName) -> bool:
	if not _objeto_tem_propriedade(objeto, nome_propriedade):
		return false
	return bool(objeto.get(nome_propriedade))


func _tipo_ponto(ponto: Node) -> int:
	if not _objeto_tem_propriedade(ponto, "tipo"):
		return -1
	return int(ponto.get("tipo"))


func _node_valido(node: Variant) -> bool:
	return node != null and is_instance_valid(node)


func _matar_tween(tween: Tween) -> void:
	if tween and tween.is_valid():
		tween.kill()
