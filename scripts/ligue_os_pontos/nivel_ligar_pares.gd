extends Node2D

const BASE_SIZE := Vector2(720, 1280)

@export var total_objetivos: int = 3
@export_file("*.tscn") var proxima_fase_cena: String

var cena_vitoria = preload("res://scenes/telas/TelaVitoria.tscn")

# ==========================================
# RESPONSIVIDADE
# ==========================================
@onready var fundo_responsivo: Sprite2D = $FundoResponsivo
@onready var area_jogo: Node2D = $AreaJogo
@onready var camada_linhas: Node2D = $CamadaLinhas

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

	get_viewport().size_changed.connect(_ajustar_responsivo)
	_ajustar_responsivo()

	randomizar_posicoes()
	configurar_managers()
	iniciar_musica_fundo()


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


func registrar_interacao_no_hint() -> void:
	if hint_manager and hint_manager.has_method("registrar_interacao"):
		hint_manager.registrar_interacao()


func resetar_timer_hint_sem_limpar_visual() -> void:
	if hint_manager and hint_manager.has_method("resetar_timer_sem_limpar_visual"):
		hint_manager.resetar_timer_sem_limpar_visual()


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
# RESPONSIVIDADE
# ==========================================
func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	area_jogo.position = (tamanho_tela - BASE_SIZE) / 2.0
	camada_linhas.position = Vector2.ZERO

	if fundo_responsivo and fundo_responsivo.texture:
		var tamanho_textura: Vector2 = fundo_responsivo.texture.get_size()

		fundo_responsivo.centered = true
		fundo_responsivo.position = tamanho_tela / 2.0

		var escala_x := tamanho_tela.x / tamanho_textura.x
		var escala_y := tamanho_tela.y / tamanho_textura.y
		var escala_final = max(escala_x, escala_y)

		fundo_responsivo.scale = Vector2(escala_final, escala_final)


func iniciar_musica_fundo() -> void:
	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
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


# ==========================================
# INPUT
# ==========================================
func _input(event) -> void:
	if nivel_concluido:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		registrar_interacao_no_hint()

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
		resetar_timer_hint_sem_limpar_visual()

		var pos_mouse := get_global_mouse_position()

		if line_renderer and line_renderer.has_method("atualizar_linha"):
			line_renderer.atualizar_linha(pos_mouse)

		if pos_mouse.distance_to(pos_inicio_interacao) >= distancia_minima_arrasto:
			arrastou_linha = true

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		resetar_timer_hint_sem_limpar_visual()

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
		if res.collider.is_in_group("pontos"):
			return res.collider

	return null


func tentar_iniciar_linha(ponto) -> void:
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
		tocar_erro_pedagogico()
		apagar_linha_atual()

		ponto_inicial = null
		arrastou_linha = false


func finalizar_linha_com_ponto(ponto_final) -> void:
	var acertou := false

	if ponto_final and ponto_final != ponto_inicial:
		if ponto_final.tipo == ponto_final.Tipo.CHEGADA and not ponto_final.esta_conectado_chegada:
			if ponto_final.id_par == ponto_inicial.id_par:
				acertou = true

	if acertou:
		registrar_interacao_no_hint()

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

	await get_tree().process_frame

	tela.configurar(proxima_fase_cena)
