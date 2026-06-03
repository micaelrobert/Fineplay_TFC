extends Node

class_name HintManager

# ============================================================
# HINT MANAGER
# Sistema universal de pistas progressivas para minigames.
#
# Responsabilidades:
# - contar tempo de inatividade;
# - mostrar pistas graduais;
# - destacar origem;
# - destacar destino;
# - desenhar linha/seta de dica;
# - limpar efeitos visuais;
# - comunicar animações simples ao ProfessorRobo.
#
# Este script NÃO valida acerto, NÃO conta vitória e NÃO controla input.
# O script principal continua sendo responsável pelas regras do jogo.
# ============================================================


# ============================================================
# MODOS DE PISTA
# ============================================================
enum ModoPista {
	ARRASTAR_PECAS,
	LIGAR_PARES,
	LIGAR_NUMEROS,
	CUSTOM
}

@export var modo_pista: ModoPista = ModoPista.LIGAR_PARES


# ============================================================
# REFERÊNCIAS DA CENA
# ============================================================
@export_node_path("Node2D") var area_jogo_path: NodePath
@export_node_path("Node2D") var camada_linhas_path: NodePath
@export_node_path("Label") var texto_dica_path: NodePath
@export_node_path("Node") var robo_path: NodePath

@onready var area_jogo: Node2D = get_node_or_null(area_jogo_path)
@onready var camada_linhas: Node2D = get_node_or_null(camada_linhas_path)
@onready var texto_dica: Label = get_node_or_null(texto_dica_path)
@onready var robo: Node = get_node_or_null(robo_path)


# ============================================================
# CONFIGURAÇÕES DE TEMPO
# ============================================================
@export var ativar_pistas := true

@export var tempo_pista_professor := 8.0
@export var tempo_pista_origem := 15.0
@export var tempo_pista_destino := 25.0


# ============================================================
# CONFIGURAÇÕES VISUAIS
# ============================================================
@export var cor_destaque_origem: Color = Color(1.45, 1.45, 0.55, 1.0)
@export var cor_destaque_destino: Color = Color(1.6, 1.35, 0.35, 1.0)
@export var cor_normal: Color = Color(1.0, 1.0, 1.0, 1.0)

@export var escala_destaque_destino := 1.12

@export var largura_linha_dica := 9.0
@export var largura_linha_dica_sombra := 18.0

@export var cor_linha_dica: Color = Color(1.0, 0.85, 0.05, 0.95)
@export var cor_linha_dica_sombra: Color = Color(0.0, 0.0, 0.0, 0.20)


# ============================================================
# MENSAGENS PADRÃO
# ============================================================
@export_multiline var mensagem_pista_professor := "Observe com calma. Pense no que combina."
@export_multiline var mensagem_pista_origem := "Comece pelo item destacado."
@export_multiline var mensagem_pista_destino := "Agora leve até o lugar que está brilhando."


# ============================================================
# ESTADO INTERNO
# ============================================================
var tempo_sem_acao := 0.0
var nivel_pista_atual := 0
var pista_ativa := false
var sistema_pausado := false
var nivel_concluido := false

var origem_dica: Node = null
var destino_dica: Node = null

var tween_origem: Tween = null
var tween_destino_cor: Tween = null
var tween_destino_escala: Tween = null
var tween_linha_dica: Tween = null

var linha_dica: Line2D = null
var linha_dica_sombra: Line2D = null

var modulates_originais := {}
var escalas_originais := {}

# Callbacks opcionais para minigames customizados.
# O script principal pode configurar funções próprias se necessário.
var callback_buscar_origem: Callable
var callback_buscar_destino: Callable


func _ready() -> void:
	if texto_dica:
		texto_dica.visible = false


func _process(delta: float) -> void:
	if not ativar_pistas:
		return

	if sistema_pausado:
		return

	if nivel_concluido:
		return

	tempo_sem_acao += delta
	verificar_pistas_por_inatividade()


# ============================================================
# API PÚBLICA PARA O SCRIPT PRINCIPAL
# ============================================================
func registrar_interacao() -> void:
	# Deve ser chamado pelo script principal quando o jogador clicar,
	# arrastar, soltar, acertar ou errar.
	resetar_pistas()


func resetar_timer_sem_limpar_visual() -> void:
	# Útil quando o jogador está arrastando uma linha.
	# Reinicia o tempo, mas não remove uma pista visual já exibida.
	tempo_sem_acao = 0.0


func pausar_pistas() -> void:
	sistema_pausado = true


func retomar_pistas() -> void:
	sistema_pausado = false
	tempo_sem_acao = 0.0


func finalizar_nivel() -> void:
	nivel_concluido = true
	resetar_pistas()


func reiniciar_sistema() -> void:
	nivel_concluido = false
	sistema_pausado = false
	resetar_pistas()


func configurar_callbacks(buscar_origem: Callable, buscar_destino: Callable) -> void:
	# Use isso somente quando um minigame tiver regra própria
	# que não caiba nos modos ARRASTAR_PECAS, LIGAR_PARES ou LIGAR_NUMEROS.
	callback_buscar_origem = buscar_origem
	callback_buscar_destino = buscar_destino
	modo_pista = ModoPista.CUSTOM


func forcar_pista(nivel: int) -> void:
	# Pode ser usado futuramente por um botão "Dica".
	mostrar_pista(nivel)


# ============================================================
# CONTROLE DE PISTAS
# ============================================================
func verificar_pistas_por_inatividade() -> void:
	if nivel_pista_atual == 0 and tempo_sem_acao >= tempo_pista_professor:
		mostrar_pista(1)
		return

	if nivel_pista_atual == 1 and tempo_sem_acao >= tempo_pista_origem:
		mostrar_pista(2)
		return

	if nivel_pista_atual == 2 and tempo_sem_acao >= tempo_pista_destino:
		mostrar_pista(3)
		return


func mostrar_pista(nivel: int) -> void:
	if nivel_concluido:
		return

	if sistema_pausado:
		return

	nivel_pista_atual = nivel
	pista_ativa = true

	if nivel == 1:
		pista_professor()
	elif nivel == 2:
		pista_destacar_origem()
	elif nivel == 3:
		pista_destacar_destino()


func pista_professor() -> void:
	mostrar_texto_dica(mensagem_pista_professor)
	animar_robo_dica()

	print("PISTA 1: ProfessorRobo orientando.")


func pista_destacar_origem() -> void:
	mostrar_texto_dica(mensagem_pista_origem)

	origem_dica = buscar_origem_para_pista()

	if origem_dica:
		destacar_origem(origem_dica)
		print("PISTA 2: Origem destacada: ", origem_dica.name)
	else:
		print("PISTA 2: Nenhuma origem disponível para dica.")

	animar_robo_apontar()


func pista_destacar_destino() -> void:
	mostrar_texto_dica(mensagem_pista_destino)

	if not origem_dica:
		origem_dica = buscar_origem_para_pista()

	destino_dica = buscar_destino_para_pista(origem_dica)

	if destino_dica:
		destacar_destino(destino_dica)
		criar_linha_dica(origem_dica, destino_dica)
		print("PISTA 3: Destino destacado: ", destino_dica.name)
	else:
		print("PISTA 3: Nenhum destino correto encontrado.")

	animar_robo_apontar()


func mostrar_texto_dica(mensagem: String) -> void:
	if texto_dica:
		texto_dica.text = mensagem
		texto_dica.visible = true

	print("DICA: ", mensagem)


# ============================================================
# BUSCA DE ORIGEM E DESTINO
# ============================================================
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


# ============================================================
# MODO: ARRASTAR PEÇAS
# ============================================================
func buscar_peca_disponivel() -> Node:
	if not area_jogo:
		return null

	for filho in area_jogo.get_children():
		if filho.is_in_group("pecas"):
			if peca_esta_disponivel(filho):
				return filho

	for filho in area_jogo.get_children():
		if filho.has_signal("peca_encaixada"):
			if peca_esta_disponivel(filho):
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


# ============================================================
# MODO: LIGAR PARES
# ============================================================
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


# ============================================================
# MODO: LIGAR NÚMEROS
# ============================================================
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


# ============================================================
# UTILITÁRIO: PONTOS DA FASE
# ============================================================
func pegar_pontos_da_fase() -> Array:
	var pontos := []

	if not area_jogo:
		return pontos

	for filho in area_jogo.get_children():
		if filho.is_in_group("pontos"):
			pontos.append(filho)

	return pontos


# ============================================================
# EFEITOS VISUAIS
# ============================================================
func destacar_origem(origem: Node) -> void:
	if not origem:
		return

	if not origem is CanvasItem:
		return

	var canvas_item := origem as CanvasItem

	if not modulates_originais.has(origem):
		modulates_originais[origem] = canvas_item.modulate

	if tween_origem:
		tween_origem.kill()

	tween_origem = create_tween()
	tween_origem.set_loops()
	tween_origem.tween_property(canvas_item, "modulate", cor_destaque_origem, 0.4)
	tween_origem.tween_property(canvas_item, "modulate", cor_normal, 0.4)


func destacar_destino(destino: Node) -> void:
	if not destino:
		return

	if not destino is CanvasItem:
		return

	var canvas_item := destino as CanvasItem

	if not modulates_originais.has(destino):
		modulates_originais[destino] = canvas_item.modulate

	if not escalas_originais.has(destino):
		escalas_originais[destino] = destino.scale

	if tween_destino_cor:
		tween_destino_cor.kill()

	if tween_destino_escala:
		tween_destino_escala.kill()

	tween_destino_cor = create_tween()
	tween_destino_cor.set_loops()
	tween_destino_cor.tween_property(canvas_item, "modulate", cor_destaque_destino, 0.35)
	tween_destino_cor.tween_property(canvas_item, "modulate", cor_normal, 0.35)

	tween_destino_escala = create_tween()
	tween_destino_escala.set_loops()
	tween_destino_escala.tween_property(destino, "scale", escalas_originais[destino] * escala_destaque_destino, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_destino_escala.tween_property(destino, "scale", escalas_originais[destino], 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func criar_linha_dica(origem: Node, destino: Node) -> void:
	remover_linha_dica()

	if not camada_linhas:
		return

	if not origem or not destino:
		return

	linha_dica_sombra = Line2D.new()
	linha_dica_sombra.name = "LinhaDicaSombra"
	linha_dica_sombra.width = largura_linha_dica_sombra
	linha_dica_sombra.default_color = cor_linha_dica_sombra
	linha_dica_sombra.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica_sombra.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica_sombra.joint_mode = Line2D.LINE_JOINT_ROUND
	linha_dica_sombra.z_index = 20
	linha_dica_sombra.add_point(origem.global_position)
	linha_dica_sombra.add_point(destino.global_position)
	camada_linhas.add_child(linha_dica_sombra)

	linha_dica = Line2D.new()
	linha_dica.name = "LinhaDica"
	linha_dica.width = largura_linha_dica
	linha_dica.default_color = cor_linha_dica
	linha_dica.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_dica.joint_mode = Line2D.LINE_JOINT_ROUND
	linha_dica.z_index = 21
	linha_dica.add_point(origem.global_position)
	linha_dica.add_point(destino.global_position)
	camada_linhas.add_child(linha_dica)

	if tween_linha_dica:
		tween_linha_dica.kill()

	tween_linha_dica = create_tween()
	tween_linha_dica.set_loops()
	tween_linha_dica.tween_property(linha_dica, "modulate:a", 0.25, 0.35)
	tween_linha_dica.tween_property(linha_dica, "modulate:a", 1.0, 0.35)


func remover_linha_dica() -> void:
	if tween_linha_dica:
		tween_linha_dica.kill()
		tween_linha_dica = null

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

	if tween_origem:
		tween_origem.kill()
		tween_origem = null

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


# ============================================================
# PROFESSOR ROBO
# ============================================================
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
