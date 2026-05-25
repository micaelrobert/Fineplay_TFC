extends Node2D

const BASE_SIZE := Vector2(720, 1280)

@export var total_objetivos: int = 3
@export_file("*.tscn") var proxima_fase_cena: String

var cena_vitoria = preload("res://scenes/telas/TelaVitoria.tscn")

# ==========================================
# CONFIGURAÇÃO VISUAL DAS LINHAS
# ==========================================
@export var cor_linha_preview: Color = Color(1.0, 1.0, 1.0, 0.72)
@export var cor_linha_preview_sombra: Color = Color(0.0, 0.0, 0.0, 0.18)

@export var cor_linha_final: Color = Color(0.20, 0.85, 0.45, 0.42)
@export var cor_linha_final_sombra: Color = Color(0.0, 0.0, 0.0, 0.10)

@export var largura_linha_preview: float = 8.0
@export var largura_linha_preview_sombra: float = 16.0

@export var largura_linha_final: float = 5.0
@export var largura_linha_final_sombra: float = 10.0

@export var distancia_minima_arrasto: float = 18.0

# ==========================================
# RESPONSIVIDADE
# ==========================================
@onready var fundo_responsivo: Sprite2D = $FundoResponsivo
@onready var area_jogo: Node2D = $AreaJogo
@onready var camada_linhas: Node2D = $CamadaLinhas

# ==========================================
# REFERÊNCIAS DE FEEDBACK
# ==========================================
@onready var som_click_objeto = $SonsLocais/SomClickObjeto
@onready var som_click_forma = $SonsLocais/SomClickNaForma
@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_erro = $SonsLocais/SomErro
@onready var som_vitoria = $SonsLocais/SomVitoria

@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D

var ponto_inicial = null
var linha_atual: Line2D = null
var linha_sombra_atual: Line2D = null

var acertos := 0
var arrastou_linha := false
var pos_inicio_interacao := Vector2.ZERO


func _ready() -> void:
	randomize()

	get_viewport().size_changed.connect(_ajustar_responsivo)
	_ajustar_responsivo()

	randomizar_posicoes()

	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
			musica.play()


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	# Centraliza a área lógica 720x1280 dentro da tela real.
	area_jogo.position = (tamanho_tela - BASE_SIZE) / 2.0

	# A camada de linhas fica no root usando coordenadas globais.
	camada_linhas.position = Vector2.ZERO

	# Faz o fundo cobrir toda a tela real.
	if fundo_responsivo and fundo_responsivo.texture:
		var tamanho_textura: Vector2 = fundo_responsivo.texture.get_size()

		fundo_responsivo.centered = true
		fundo_responsivo.position = tamanho_tela / 2.0

		var escala_x := tamanho_tela.x / tamanho_textura.x
		var escala_y := tamanho_tela.y / tamanho_textura.y
		var escala_final = max(escala_x, escala_y)

		fundo_responsivo.scale = Vector2(escala_final, escala_final)


func pegar_pontos_da_fase() -> Array:
	var pontos := []

	for filho in area_jogo.get_children():
		if filho.is_in_group("pontos"):
			pontos.append(filho)

	return pontos


func randomizar_posicoes() -> void:
	var todos_pontos = pegar_pontos_da_fase()

	var pontos_saida := []
	var pontos_chegada := []

	for ponto in todos_pontos:
		if ponto.tipo == ponto.Tipo.SAIDA:
			pontos_saida.append(ponto)
		elif ponto.tipo == ponto.Tipo.CHEGADA:
			pontos_chegada.append(ponto)

	var posicoes_saida := []

	for p in pontos_saida:
		posicoes_saida.append(p.global_position)

	posicoes_saida.shuffle()

	for i in range(pontos_saida.size()):
		pontos_saida[i].global_position = posicoes_saida[i]

	var posicoes_chegada := []

	for p in pontos_chegada:
		posicoes_chegada.append(p.global_position)

	posicoes_chegada.shuffle()

	for i in range(pontos_chegada.size()):
		pontos_chegada[i].global_position = posicoes_chegada[i]


func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ponto = buscar_ponto_sob_mouse()

		# Se já existe uma linha aberta, o próximo clique pode finalizar a ligação.
		if linha_atual:
			if ponto and ponto != ponto_inicial:
				finalizar_linha_com_ponto(ponto)
			return

		# Se ainda não existe linha aberta, tenta iniciar uma nova.
		if ponto:
			pos_inicio_interacao = get_global_mouse_position()
			arrastou_linha = false
			tentar_iniciar_linha(ponto)

	elif event is InputEventMouseMotion and linha_atual:
		var pos_mouse := get_global_mouse_position()

		linha_atual.set_point_position(1, pos_mouse)

		if linha_sombra_atual:
			linha_sombra_atual.set_point_position(1, pos_mouse)

		if pos_mouse.distance_to(pos_inicio_interacao) >= distancia_minima_arrasto:
			arrastou_linha = true

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		# Se arrastou, finaliza ao soltar.
		# Se foi só clique, mantém a linha aberta aguardando o segundo ponto.
		if linha_atual and arrastou_linha:
			finalizar_linha()


func buscar_ponto_sob_mouse():
	var physics_space = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()

	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var resultados = physics_space.intersect_point(query)

	for res in resultados:
		if res.collider.is_in_group("pontos"):
			return res.collider

	return null


func tentar_iniciar_linha(ponto) -> void:
	# Lógica exclusiva de pares: saída -> chegada.
	if ponto.tipo == ponto.Tipo.SAIDA and not ponto.esta_conectado_saida:
		ponto_inicial = ponto

		if som_click_forma:
			som_click_forma.play()
		elif som_click_objeto:
			som_click_objeto.play()

		criar_visual_linha(ponto.global_position)


func criar_visual_linha(pos_inicial: Vector2) -> void:
	# Linha de sombra: cria profundidade sem poluir visualmente.
	linha_sombra_atual = Line2D.new()
	linha_sombra_atual.width = largura_linha_preview_sombra
	linha_sombra_atual.default_color = cor_linha_preview_sombra
	linha_sombra_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_sombra_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_sombra_atual.joint_mode = Line2D.LINE_JOINT_ROUND
	linha_sombra_atual.z_index = 5
	linha_sombra_atual.add_point(pos_inicial)
	linha_sombra_atual.add_point(get_global_mouse_position())
	camada_linhas.add_child(linha_sombra_atual)

	# Linha principal: visível durante o arrasto, mas sem brilho excessivo.
	linha_atual = Line2D.new()
	linha_atual.width = largura_linha_preview
	linha_atual.default_color = cor_linha_preview
	linha_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_atual.joint_mode = Line2D.LINE_JOINT_ROUND
	linha_atual.z_index = 6
	linha_atual.add_point(pos_inicial)
	linha_atual.add_point(get_global_mouse_position())
	camada_linhas.add_child(linha_atual)


func transformar_linha_em_acerto(pos_final: Vector2) -> void:
	if linha_sombra_atual:
		linha_sombra_atual.set_point_position(1, pos_final)
		linha_sombra_atual.width = largura_linha_final_sombra
		linha_sombra_atual.default_color = cor_linha_final_sombra
		linha_sombra_atual.z_index = 1

	if linha_atual:
		linha_atual.set_point_position(1, pos_final)
		linha_atual.width = largura_linha_final
		linha_atual.default_color = cor_linha_final
		linha_atual.z_index = 2

	linha_sombra_atual = null
	linha_atual = null


func apagar_linha_atual() -> void:
	if linha_sombra_atual:
		linha_sombra_atual.queue_free()

	if linha_atual:
		linha_atual.queue_free()

	linha_sombra_atual = null
	linha_atual = null


func finalizar_linha() -> void:
	var ponto_final = buscar_ponto_sob_mouse()

	if ponto_final:
		finalizar_linha_com_ponto(ponto_final)
	else:
		apagar_linha_atual()
		ponto_inicial = null
		arrastou_linha = false


func finalizar_linha_com_ponto(ponto_final) -> void:
	var acertou := false

	if ponto_final and ponto_final != ponto_inicial:
		# Lógica exclusiva de pares: mesmo id_par.
		if ponto_final.tipo == ponto_final.Tipo.CHEGADA and not ponto_final.esta_conectado_chegada:
			if ponto_final.id_par == ponto_inicial.id_par:
				acertou = true

	if acertou:
		transformar_linha_em_acerto(ponto_final.global_position)

		ponto_inicial.esta_conectado_saida = true
		ponto_final.esta_conectado_chegada = true

		if som_acerto:
			som_acerto.play()

		ponto_inicial = null
		arrastou_linha = false

		verificar_vitoria()
	else:
		if ponto_final and ponto_final != ponto_inicial:
			if som_erro:
				som_erro.play()

		apagar_linha_atual()
		ponto_inicial = null
		arrastou_linha = false


func verificar_vitoria() -> void:
	acertos += 1

	if robo and robo.has_method("comemorar"):
		robo.comemorar()

	if acertos >= total_objetivos:
		if confetes:
			confetes.emitting = true

		if som_vitoria:
			som_vitoria.play()

		await get_tree().create_timer(1.0).timeout
		mostrar_tela_vitoria()


func mostrar_tela_vitoria() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	await get_tree().process_frame

	tela.configurar(proxima_fase_cena)
