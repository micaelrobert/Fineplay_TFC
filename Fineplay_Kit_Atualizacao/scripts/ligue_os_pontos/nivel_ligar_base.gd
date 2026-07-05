extends Node2D

@export var total_objetivos: int = 3
@export_file("*.tscn") var proxima_fase_cena: String
@export_range(1.0, 100.0, 1.0) var distancia_minima_arrasto: float = 18.0

var cena_vitoria: PackedScene = preload("res://scenes/telas/TelaVitoria.tscn")

@onready var area_jogo: Node2D = get_node_or_null("AreaJogo") as Node2D
@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")
@onready var line_renderer: Node = get_node_or_null("LineRenderer")
@onready var robo: Node = get_node_or_null("AreaJogo/ProfessorRobo")
@onready var confetes: CPUParticles2D = get_node_or_null("AreaJogo/CPUParticles2D") as CPUParticles2D

@onready var som_click_objeto: Node = get_node_or_null("SonsLocais/SomClickObjeto")
@onready var som_click_forma: Node = get_node_or_null("SonsLocais/SomClickNaForma")
@onready var som_acerto: Node = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_erro: Node = get_node_or_null("SonsLocais/SomErro")
@onready var som_vitoria: Node = get_node_or_null("SonsLocais/SomVitoria")

var ponto_inicial: Node = null
var acertos := 0
var arrastou_linha := false
var pos_inicio_interacao := Vector2.ZERO
var nivel_concluido := false
var ponteiro_ativo := -999

const PONTEIRO_MOUSE := -1
const PONTEIRO_NENHUM := -999


func _ready() -> void:
	randomize()
	call_deferred("_inicializar_fase_com_seguranca")


func _exit_tree() -> void:
	apagar_linha_atual()


func _inicializar_fase_com_seguranca() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_inicializar_fase()


func _inicializar_fase() -> void:
	if not area_jogo:
		push_error("Ligue os Pontos: nó AreaJogo não encontrado.")
		return

	resetar_estado_do_nivel()
	randomizar_posicoes()
	configurar_managers()
	iniciar_musica_fundo()
	_validar_total_objetivos()
	print(_mensagem_inicio())


func _mensagem_inicio() -> String:
	return "Minigame Ligue os Pontos iniciado."


func resetar_estado_do_nivel() -> void:
	ponto_inicial = null
	acertos = 0
	arrastou_linha = false
	pos_inicio_interacao = Vector2.ZERO
	nivel_concluido = false
	ponteiro_ativo = PONTEIRO_NENHUM

	for ponto in pegar_pontos_da_fase():
		if ponto.has_method("resetar_conexoes"):
			ponto.call("resetar_conexoes")
		else:
			_set_propriedade_se_existir(ponto, "esta_conectado_saida", false)
			_set_propriedade_se_existir(ponto, "esta_conectado_chegada", false)


func configurar_managers() -> void:
	if hint_manager and hint_manager.has_method("reiniciar_sistema"):
		hint_manager.call("reiniciar_sistema")
	elif not hint_manager:
		push_warning("HintManager não encontrado. O minigame funcionará sem pistas progressivas.")

	if not feedback_audio:
		push_warning("FeedbackAudio não encontrado. O minigame usará SonsLocais diretamente.")

	if line_renderer and line_renderer.has_method("limpar_todas_as_linhas"):
		line_renderer.call("limpar_todas_as_linhas")
	elif not line_renderer:
		push_warning(
			"LineRenderer não encontrado. A validação funcionará, mas as linhas não serão exibidas."
		)


func registrar_interacao_no_hint() -> void:
	if hint_manager and hint_manager.has_method("registrar_interacao"):
		hint_manager.call("registrar_interacao")
	elif hint_manager and hint_manager.has_method("resetar_timer_sem_limpar_visual"):
		hint_manager.call("resetar_timer_sem_limpar_visual")


func registrar_acao_no_hint_sem_resetar() -> void:
	if hint_manager and hint_manager.has_method("registrar_acao_sem_resetar_pista"):
		hint_manager.call("registrar_acao_sem_resetar_pista")


func registrar_acerto_no_hint() -> void:
	if hint_manager and hint_manager.has_method("registrar_acerto"):
		hint_manager.call("registrar_acerto")
	elif hint_manager and hint_manager.has_method("resetar_pistas"):
		hint_manager.call("resetar_pistas")


func pausar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("pausar_pistas"):
		hint_manager.call("pausar_pistas")


func retomar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("retomar_pistas"):
		hint_manager.call("retomar_pistas")


func finalizar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("finalizar_nivel"):
		hint_manager.call("finalizar_nivel")


func existe_linha_aberta() -> bool:
	return (
		bool(line_renderer.call("existe_linha_aberta"))
		if line_renderer and line_renderer.has_method("existe_linha_aberta")
		else ponto_inicial != null
	)


func iniciar_musica_fundo() -> void:
	var musica := get_node_or_null("/root/AudioManager/MusicaFundo")
	if musica and not bool(musica.get("playing")) and musica.has_method("play"):
		musica.call("play")


func tocar_click_forma() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.call("tocar_click_forma")
	elif som_click_forma and som_click_forma.has_method("play"):
		som_click_forma.call("play")
	elif som_click_objeto and som_click_objeto.has_method("play"):
		som_click_objeto.call("play")


func tocar_acerto() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.call("tocar_acerto")
	elif som_acerto and som_acerto.has_method("play"):
		som_acerto.call("play")


func tocar_erro_pedagogico() -> void:
	registrar_acao_no_hint_sem_resetar()

	if feedback_audio and feedback_audio.has_method("tocar_erro_pedagogico"):
		feedback_audio.call("tocar_erro_pedagogico")
	elif som_erro and som_erro.has_method("play"):
		som_erro.call("play")

	if robo and robo.has_method("errar"):
		robo.call("errar")


func tocar_vitoria_pedagogica() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_vitoria_pedagogica"):
		feedback_audio.call("tocar_vitoria_pedagogica")
	elif som_vitoria and som_vitoria.has_method("play"):
		som_vitoria.call("play")


func pegar_pontos_da_fase() -> Array[Node]:
	var pontos: Array[Node] = []
	if not area_jogo:
		return pontos

	for node in get_tree().get_nodes_in_group("pontos"):
		if node is Node and area_jogo.is_ancestor_of(node):
			pontos.append(node)
	return pontos


func randomizar_posicoes() -> void:
	_randomizar_pontos_por_modo(pegar_pontos_da_fase())


func _randomizar_pontos_por_modo(pontos: Array[Node]) -> void:
	# Implementação padrão: mantém saídas e chegadas em seus respectivos lados.
	var saidas: Array[Node] = []
	var chegadas: Array[Node] = []

	for ponto in pontos:
		var tipo := int(ponto.get("tipo"))
		if tipo == 0:
			saidas.append(ponto)
		elif tipo == 1:
			chegadas.append(ponto)

	_randomizar_lista_de_nodes(saidas)
	_randomizar_lista_de_nodes(chegadas)


func _randomizar_lista_de_nodes(nodes: Array[Node]) -> void:
	var posicoes: Array[Vector2] = []
	for node in nodes:
		if node is Node2D:
			posicoes.append((node as Node2D).global_position)

	if posicoes.size() != nodes.size():
		return

	posicoes.shuffle()
	for indice in range(nodes.size()):
		(nodes[indice] as Node2D).global_position = posicoes[indice]


func _input(event: InputEvent) -> void:
	if nivel_concluido:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_processar_press(mouse_event.position, PONTEIRO_MOUSE)
		elif ponteiro_ativo == PONTEIRO_MOUSE:
			_processar_release(mouse_event.position, PONTEIRO_MOUSE)

	elif event is InputEventMouseMotion and ponteiro_ativo == PONTEIRO_MOUSE:
		_processar_movimento((event as InputEventMouseMotion).position, PONTEIRO_MOUSE)

	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_processar_press(touch_event.position, touch_event.index)
		elif ponteiro_ativo == touch_event.index:
			_processar_release(touch_event.position, touch_event.index)

	elif event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if ponteiro_ativo == drag_event.index:
			_processar_movimento(drag_event.position, drag_event.index)


func _processar_press(posicao_viewport: Vector2, id_ponteiro: int) -> void:
	if ponteiro_ativo != PONTEIRO_NENHUM:
		return

	registrar_interacao_no_hint()
	var posicao_global := _viewport_para_global(posicao_viewport)
	var ponto := buscar_ponto_na_posicao(posicao_global)

	if ponto_inicial:
		if ponto and ponto != ponto_inicial:
			finalizar_linha_com_ponto(ponto)
			get_viewport().set_input_as_handled()
		return

	if ponto and tentar_iniciar_linha(ponto, posicao_global):
		ponteiro_ativo = id_ponteiro
		pos_inicio_interacao = posicao_global
		arrastou_linha = false
		get_viewport().set_input_as_handled()


func _processar_movimento(posicao_viewport: Vector2, id_ponteiro: int) -> void:
	if id_ponteiro != ponteiro_ativo or not ponto_inicial:
		return

	var posicao_global := _viewport_para_global(posicao_viewport)
	if line_renderer and line_renderer.has_method("atualizar_linha"):
		line_renderer.call("atualizar_linha", posicao_global)

	if posicao_global.distance_to(pos_inicio_interacao) >= distancia_minima_arrasto:
		arrastou_linha = true


func _processar_release(posicao_viewport: Vector2, id_ponteiro: int) -> void:
	if id_ponteiro != ponteiro_ativo:
		return

	ponteiro_ativo = PONTEIRO_NENHUM
	var posicao_global := _viewport_para_global(posicao_viewport)

	if ponto_inicial and arrastou_linha:
		finalizar_linha_na_posicao(posicao_global)
	else:
		# No modo por clique, a linha permanece aberta aguardando o segundo ponto.
		retomar_hint_manager()

	arrastou_linha = false
	get_viewport().set_input_as_handled()


func buscar_ponto_sob_mouse() -> Node:
	return buscar_ponto_na_posicao(get_global_mouse_position())


func buscar_ponto_na_posicao(posicao_global: Vector2) -> Node:
	var physics_space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = posicao_global
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for resultado in physics_space.intersect_point(query, 32):
		var collider: Object = resultado.get("collider")
		if collider is Node and (collider as Node).is_in_group("pontos"):
			return collider as Node
	return null


func tentar_iniciar_linha(ponto: Node, posicao_ponteiro: Variant = null) -> bool:
	if not ponto or not _ponto_pode_iniciar(ponto):
		return false

	ponto_inicial = ponto
	tocar_click_forma()
	pausar_hint_manager()

	var ponta_inicial: Vector2 = (ponto as Node2D).global_position
	if posicao_ponteiro is Vector2:
		ponta_inicial = posicao_ponteiro

	if line_renderer and line_renderer.has_method("criar_linha"):
		line_renderer.call("criar_linha", (ponto as Node2D).global_position, ponta_inicial)
	return true


func _ponto_pode_iniciar(ponto: Node) -> bool:
	return int(ponto.get("tipo")) == 0 and not bool(ponto.get("esta_conectado_saida"))


func finalizar_linha() -> void:
	finalizar_linha_na_posicao(get_global_mouse_position())


func finalizar_linha_na_posicao(posicao_global: Vector2) -> void:
	var ponto_final := buscar_ponto_na_posicao(posicao_global)
	if ponto_final:
		finalizar_linha_com_ponto(ponto_final)
	else:
		cancelar_linha_atual(false)


func finalizar_linha_com_ponto(ponto_final: Node) -> void:
	if not ponto_inicial:
		cancelar_linha_atual(false)
		return

	var acertou := (
		ponto_final != null
		and ponto_final != ponto_inicial
		and _conexao_valida(ponto_inicial, ponto_final)
	)
	if acertou:
		registrar_acerto_no_hint()
		if line_renderer and line_renderer.has_method("transformar_linha_em_acerto"):
			line_renderer.call(
				"transformar_linha_em_acerto", (ponto_final as Node2D).global_position
			)

		_set_propriedade_se_existir(ponto_inicial, "esta_conectado_saida", true)
		_set_propriedade_se_existir(ponto_final, "esta_conectado_chegada", true)
		tocar_acerto()

		ponto_inicial = null
		arrastou_linha = false
		ponteiro_ativo = PONTEIRO_NENHUM
		retomar_hint_manager()
		verificar_vitoria()
	else:
		if ponto_final and ponto_final != ponto_inicial:
			tocar_erro_pedagogico()
		cancelar_linha_atual(false)


func _conexao_valida(origem: Node, destino: Node) -> bool:
	return (
		int(destino.get("tipo")) == 1
		and not bool(destino.get("esta_conectado_chegada"))
		and int(destino.get("id_par")) == int(origem.get("id_par"))
	)


func cancelar_linha_atual(registrar_interacao: bool = true) -> void:
	if line_renderer and line_renderer.has_method("apagar_linha_atual"):
		line_renderer.call("apagar_linha_atual")

	ponto_inicial = null
	arrastou_linha = false
	ponteiro_ativo = PONTEIRO_NENHUM

	if registrar_interacao:
		registrar_interacao_no_hint()
	retomar_hint_manager()


func apagar_linha_atual() -> void:
	cancelar_linha_atual(false)


func verificar_vitoria() -> void:
	acertos += 1
	if acertos >= total_objetivos:
		concluir_nivel()
	elif robo and robo.has_method("comemorar"):
		robo.call("comemorar")


func concluir_nivel() -> void:
	if nivel_concluido:
		return

	nivel_concluido = true
	finalizar_hint_manager()
	ponteiro_ativo = PONTEIRO_NENHUM

	if confetes:
		confetes.emitting = true

	tocar_vitoria_pedagogica()
	if robo and robo.has_method("vitoria"):
		robo.call("vitoria")
	elif robo and robo.has_method("comemorar"):
		robo.call("comemorar")

	await get_tree().create_timer(1.4).timeout
	mostrar_tela_vitoria()


func mostrar_tela_vitoria() -> void:
	if not cena_vitoria:
		push_error("Ligue os Pontos: TelaVitoria não pôde ser carregada.")
		return

	var tela := cena_vitoria.instantiate()
	add_child(tela)
	if tela.has_method("configurar"):
		tela.call("configurar", proxima_fase_cena)


func _validar_total_objetivos() -> void:
	if total_objetivos <= 0:
		push_warning("Ligue os Pontos: total_objetivos deve ser maior que zero.")


func _viewport_para_global(posicao_viewport: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * posicao_viewport


func _set_propriedade_se_existir(objeto: Object, nome: StringName, valor: Variant) -> void:
	if not objeto:
		return
	for propriedade in objeto.get_property_list():
		if StringName(propriedade.name) == nome:
			objeto.set(nome, valor)
			return
