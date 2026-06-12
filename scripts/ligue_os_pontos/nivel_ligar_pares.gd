extends Node2D

# ============================================================
# OBSERVAÇÃO IMPORTANTE
# ============================================================
# A responsividade agora é controlada pelo AutoLoad:
# ResponsividadeUniversal.gd
#
# Este script NÃO centraliza AreaJogo,
# NÃO redimensiona FundoResponsivo
# e NÃO reposiciona CamadaLinhas.
#
# A cena precisa manter os nós:
# - FundoResponsivo
# - AreaJogo
# - CamadaLinhas
# - HintManager
# - FeedbackAudio
# - LineRenderer
# ============================================================


# ==========================================
# CONFIGURAÇÕES DA FASE
# ==========================================
@export var total_objetivos: int = 3
@export_file("*.tscn") var proxima_fase_cena: String

var cena_vitoria: PackedScene = preload("res://scenes/telas/TelaVitoria.tscn")


# ==========================================
# ESTRUTURA DA CENA
# ==========================================
@onready var area_jogo: Node2D = $AreaJogo


# ==========================================
# MANAGERS
# ==========================================
@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")
@onready var line_renderer: Node = get_node_or_null("LineRenderer")


# ==========================================
# REFERÊNCIAS DA FASE
# ==========================================
@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D


# ==========================================
# FALLBACK DE SONS
# Usado apenas se o FeedbackAudio não estiver configurado.
# ==========================================
@onready var som_click_objeto = get_node_or_null("SonsLocais/SomClickObjeto")
@onready var som_click_forma = get_node_or_null("SonsLocais/SomClickNaForma")
@onready var som_acerto = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_erro = get_node_or_null("SonsLocais/SomErro")
@onready var som_vitoria = get_node_or_null("SonsLocais/SomVitoria")


# ==========================================
# CONTROLE DO JOGO
# ==========================================
var ponto_inicial = null
var acertos := 0
var arrastou_linha := false
var pos_inicio_interacao := Vector2.ZERO
var nivel_concluido := false

@export var distancia_minima_arrasto: float = 18.0


func _ready() -> void:
	randomize()
	call_deferred("_inicializar_fase_com_seguranca")


func _inicializar_fase_com_seguranca() -> void:
	# Aguarda a cena montar completamente.
	await get_tree().process_frame

	# Aguarda mais um frame para o ResponsividadeUniversal
	# ajustar AreaJogo, FundoResponsivo e CamadaLinhas.
	await get_tree().process_frame

	_inicializar_fase()


func _inicializar_fase() -> void:
	resetar_estado_do_nivel()
	randomizar_posicoes()
	configurar_managers()
	iniciar_musica_fundo()

	print("Minigame Ligue os Pontos iniciado.")


func resetar_estado_do_nivel() -> void:
	ponto_inicial = null
	acertos = 0
	arrastou_linha = false
	pos_inicio_interacao = Vector2.ZERO
	nivel_concluido = false


# ==========================================
# CONFIGURAÇÃO DOS MANAGERS
# ==========================================
func configurar_managers() -> void:
	if hint_manager and hint_manager.has_method("reiniciar_sistema"):
		hint_manager.reiniciar_sistema()

	if not hint_manager:
		push_warning("HintManager não encontrado. O minigame funciona, mas sem pistas progressivas.")

	if not feedback_audio:
		push_warning("FeedbackAudio não encontrado. O minigame usará sons diretos de SonsLocais.")

	if not line_renderer:
		push_warning("LineRenderer não encontrado. As linhas não serão desenhadas corretamente.")
	else:
		if line_renderer.has_method("limpar_todas_as_linhas"):
			line_renderer.limpar_todas_as_linhas()


func registrar_acao_no_hint_sem_resetar() -> void:
	# Clique, arraste e erro não devem limpar pistas nem zerar tempo.
	if hint_manager and hint_manager.has_method("registrar_acao_sem_resetar_pista"):
		hint_manager.registrar_acao_sem_resetar_pista()


func registrar_acerto_no_hint() -> void:
	# Somente acerto deve limpar pista e reiniciar tempo.
	if hint_manager and hint_manager.has_method("registrar_acerto"):
		hint_manager.registrar_acerto()
	elif hint_manager and hint_manager.has_method("resetar_pistas"):
		hint_manager.resetar_pistas()


func pausar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("pausar_pistas"):
		hint_manager.pausar_pistas()


func retomar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("retomar_pistas"):
		hint_manager.retomar_pistas()


func finalizar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("finalizar_nivel"):
		hint_manager.finalizar_nivel()


func existe_linha_aberta() -> bool:
	if line_renderer and line_renderer.has_method("existe_linha_aberta"):
		return line_renderer.existe_linha_aberta()

	return false


# ==========================================
# MÚSICA DE FUNDO
# ==========================================
func iniciar_musica_fundo() -> void:
	var musica = get_node_or_null("/root/AudioManager/MusicaFundo")

	if musica and not musica.playing:
		musica.play()


# ==========================================
# ÁUDIO
# ==========================================
func tocar_click_forma() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.tocar_click_forma()
		return

	if som_click_forma:
		som_click_forma.play()
	elif som_click_objeto:
		som_click_objeto.play()


func tocar_acerto() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.tocar_acerto()
		return

	if som_acerto:
		som_acerto.play()


func tocar_erro_pedagogico() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_erro_pedagogico"):
		feedback_audio.tocar_erro_pedagogico()
	else:
		if som_erro:
			som_erro.play()

	if robo and robo.has_method("errar"):
		robo.errar()


func tocar_vitoria_pedagogica() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_vitoria_pedagogica"):
		feedback_audio.tocar_vitoria_pedagogica()
		return

	if som_vitoria:
		som_vitoria.play()


# ==========================================
# PONTOS DA FASE
# ==========================================
func pegar_pontos_da_fase() -> Array:
	var pontos := []

	for filho in area_jogo.get_children():
		if filho.is_in_group("pontos"):
			pontos.append(filho)

	return pontos


func randomizar_posicoes() -> void:
	var todos_pontos := pegar_pontos_da_fase()

	if todos_pontos.is_empty():
		push_warning("Nenhum ponto encontrado no grupo 'pontos'.")
		return

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


# ==========================================
# INPUT
# ==========================================
func _input(event) -> void:
	if nivel_concluido:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		registrar_acao_no_hint_sem_resetar()

		var ponto = buscar_ponto_sob_mouse()

		if existe_linha_aberta():
			if ponto and ponto != ponto_inicial:
				finalizar_linha_com_ponto(ponto)
			return

		if ponto:
			pos_inicio_interacao = get_global_mouse_position()
			arrastou_linha = false
			tentar_iniciar_linha(ponto)

	elif event is InputEventMouseMotion and existe_linha_aberta():
		var pos_mouse := get_global_mouse_position()

		if line_renderer and line_renderer.has_method("atualizar_linha"):
			line_renderer.atualizar_linha(pos_mouse)

		if pos_mouse.distance_to(pos_inicio_interacao) >= distancia_minima_arrasto:
			arrastou_linha = true

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if existe_linha_aberta() and arrastou_linha:
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
		if res.collider and res.collider.is_in_group("pontos"):
			return res.collider

	return null


func tentar_iniciar_linha(ponto) -> void:
	if ponto == null:
		return

	if ponto.tipo == ponto.Tipo.SAIDA and not ponto.esta_conectado_saida:
		ponto_inicial = ponto

		tocar_click_forma()
		pausar_hint_manager()

		if line_renderer and line_renderer.has_method("criar_linha"):
			line_renderer.criar_linha(ponto.global_position, get_global_mouse_position())


# ==========================================
# FINALIZAÇÃO DAS LIGAÇÕES
# ==========================================
func finalizar_linha() -> void:
	var ponto_final = buscar_ponto_sob_mouse()

	if ponto_final:
		finalizar_linha_com_ponto(ponto_final)
	else:
		# Soltar fora de qualquer ponto apenas cancela a linha.
		# Não toca voz de erro.
		apagar_linha_atual()

		ponto_inicial = null
		arrastou_linha = false


func finalizar_linha_com_ponto(ponto_final) -> void:
	var acertou := false

	if ponto_inicial == null:
		apagar_linha_atual()
		ponto_inicial = null
		arrastou_linha = false
		return

	if ponto_final and ponto_final != ponto_inicial:
		if ponto_final.tipo == ponto_final.Tipo.CHEGADA and not ponto_final.esta_conectado_chegada:
			if ponto_final.id_par == ponto_inicial.id_par:
				acertou = true

	if acertou:
		registrar_acerto_no_hint()

		if line_renderer and line_renderer.has_method("transformar_linha_em_acerto"):
			line_renderer.transformar_linha_em_acerto(ponto_final.global_position)

		ponto_inicial.esta_conectado_saida = true
		ponto_final.esta_conectado_chegada = true

		tocar_acerto()

		ponto_inicial = null
		arrastou_linha = false

		retomar_hint_manager()
		verificar_vitoria()
	else:
		if ponto_final and ponto_final != ponto_inicial:
			tocar_erro_pedagogico()

		apagar_linha_atual()

		ponto_inicial = null
		arrastou_linha = false


func apagar_linha_atual() -> void:
	if line_renderer and line_renderer.has_method("apagar_linha_atual"):
		line_renderer.apagar_linha_atual()

	retomar_hint_manager()


# ==========================================
# VITÓRIA
# ==========================================
func verificar_vitoria() -> void:
	acertos += 1

	if acertos >= total_objetivos:
		concluir_nivel()
	else:
		if robo and robo.has_method("comemorar"):
			robo.comemorar()


func concluir_nivel() -> void:
	if nivel_concluido:
		return

	nivel_concluido = true
	finalizar_hint_manager()

	if confetes:
		confetes.emitting = true

	tocar_vitoria_pedagogica()

	if robo and robo.has_method("vitoria"):
		robo.vitoria()
	elif robo and robo.has_method("comemorar"):
		robo.comemorar()

	await get_tree().create_timer(1.4).timeout
	mostrar_tela_vitoria()


func mostrar_tela_vitoria() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	if tela.has_method("configurar"):
		tela.configurar(proxima_fase_cena)
	else:
		push_warning("TelaVitoria não possui o método configurar().")
