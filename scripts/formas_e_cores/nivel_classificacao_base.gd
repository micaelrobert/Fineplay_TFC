extends Node2D

@export_file("*.tscn") var proxima_fase_cena: String

var cena_vitoria: PackedScene = preload("res://scenes/telas/TelaVitoria.tscn")

@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")
@onready var area_jogo: Node2D = get_node_or_null("AreaJogo") as Node2D
@onready var robo: Node = get_node_or_null("AreaJogo/ProfessorRobo")
@onready var confetes: CPUParticles2D = get_node_or_null("AreaJogo/CPUParticles2D") as CPUParticles2D

@onready var som_acerto: Node = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_vitoria: Node = get_node_or_null("SonsLocais/SomVitoria")
@onready var som_erro: Node = get_node_or_null("SonsLocais/SomErro")
@onready var som_click_forma: Node = get_node_or_null("SonsLocais/SomClickNaForma")

var total_pecas := 0
var acertos_atuais := 0
var nivel_concluido := false


func _ready() -> void:
	randomize()
	call_deferred("_inicializar_fase_com_seguranca")


func _inicializar_fase_com_seguranca() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_inicializar_fase()


func _inicializar_fase() -> void:
	if not area_jogo:
		push_error("Nível de classificação: nó AreaJogo não encontrado.")
		return

	randomizar_layout()
	atualizar_posicoes_iniciais_das_pecas()
	configurar_pecas_da_fase()
	iniciar_musica_fundo()
	configurar_hint_manager()

	if total_pecas <= 0:
		push_warning("Nível de classificação iniciado sem peças configuradas.")
	else:
		print("Nível de classificação iniciado com ", total_pecas, " peças.")


func configurar_hint_manager() -> void:
	if not hint_manager:
		push_warning(
			"HintManager não encontrado nesta fase. O jogo funciona, mas sem pistas progressivas."
		)
		return

	if hint_manager.has_method("reiniciar_sistema"):
		hint_manager.call("reiniciar_sistema")


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


func configurar_pecas_da_fase() -> void:
	total_pecas = 0
	acertos_atuais = 0
	nivel_concluido = false

	for filho in _pegar_pecas_da_fase():
		if not filho.has_signal("peca_encaixada"):
			continue

		total_pecas += 1
		_conectar_sinal_se_existir(filho, "peca_encaixada", Callable(self, "_on_peca_acertou"))
		_conectar_sinal_se_existir(filho, "peca_clicada", Callable(self, "_on_peca_clicada"))
		_conectar_sinal_se_existir(filho, "peca_errou", Callable(self, "_on_peca_errou"))
		_conectar_sinal_se_existir(
			filho, "arraste_iniciado", Callable(self, "_on_arraste_iniciado")
		)
		_conectar_sinal_se_existir(
			filho, "arraste_finalizado", Callable(self, "_on_arraste_finalizado")
		)


func _conectar_sinal_se_existir(node: Node, nome_sinal: StringName, callable: Callable) -> void:
	if not node.has_signal(nome_sinal):
		return

	if not node.is_connected(nome_sinal, callable):
		node.connect(nome_sinal, callable)


func _pegar_pecas_da_fase() -> Array[Node]:
	var pecas: Array[Node] = []
	if not area_jogo:
		return pecas

	for node in get_tree().get_nodes_in_group("pecas"):
		if node is Node and area_jogo.is_ancestor_of(node):
			pecas.append(node)

	return pecas


func _pegar_slots_da_fase() -> Array[Node]:
	var slots: Array[Node] = []
	if not area_jogo:
		return slots

	for node in get_tree().get_nodes_in_group("slots"):
		if node is Node and area_jogo.is_ancestor_of(node):
			slots.append(node)

	return slots


func randomizar_layout() -> void:
	_randomizar_posicoes(_pegar_slots_da_fase())
	_randomizar_posicoes(_pegar_pecas_da_fase())


func _randomizar_posicoes(nodes: Array[Node]) -> void:
	if nodes.size() <= 1:
		return

	var posicoes: Array[Vector2] = []
	for node in nodes:
		if node is Node2D:
			posicoes.append((node as Node2D).global_position)

	posicoes.shuffle()
	var indice := 0
	for node in nodes:
		if node is Node2D and indice < posicoes.size():
			(node as Node2D).global_position = posicoes[indice]
			indice += 1


func atualizar_posicoes_iniciais_das_pecas() -> void:
	for peca in _pegar_pecas_da_fase():
		if peca.has_method("atualizar_posicao_inicial"):
			peca.call("atualizar_posicao_inicial")
		elif _objeto_tem_propriedade(peca, "posicao_inicial") and peca is Node2D:
			peca.set("posicao_inicial", (peca as Node2D).global_position)


func _objeto_tem_propriedade(objeto: Object, nome_propriedade: StringName) -> bool:
	for propriedade in objeto.get_property_list():
		if StringName(propriedade.name) == nome_propriedade:
			return true
	return false


func iniciar_musica_fundo() -> void:
	var musica := get_node_or_null("/root/AudioManager/MusicaFundo")
	if musica and not bool(musica.get("playing")) and musica.has_method("play"):
		musica.call("play")


func tocar_click_forma() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.call("tocar_click_forma")
	elif som_click_forma and som_click_forma.has_method("play"):
		som_click_forma.call("play")


func tocar_acerto() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.call("tocar_acerto")
	elif som_acerto and som_acerto.has_method("play"):
		som_acerto.call("play")


func tocar_erro_pedagogico() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_erro_pedagogico"):
		feedback_audio.call("tocar_erro_pedagogico")
	elif som_erro and som_erro.has_method("play"):
		som_erro.call("play")


func tocar_vitoria_pedagogica() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_vitoria_pedagogica"):
		feedback_audio.call("tocar_vitoria_pedagogica")
	elif som_vitoria and som_vitoria.has_method("play"):
		som_vitoria.call("play")


func _on_arraste_iniciado() -> void:
	if nivel_concluido:
		return
	registrar_interacao_no_hint()
	pausar_hint_manager()


func _on_arraste_finalizado() -> void:
	if nivel_concluido:
		return
	retomar_hint_manager()


func _on_peca_clicada() -> void:
	if nivel_concluido:
		return
	registrar_interacao_no_hint()
	tocar_click_forma()


func _on_peca_errou() -> void:
	if nivel_concluido:
		return

	registrar_acao_no_hint_sem_resetar()
	tocar_erro_pedagogico()
	if robo and robo.has_method("errar"):
		robo.call("errar")


func _on_peca_acertou() -> void:
	if nivel_concluido:
		return

	registrar_acerto_no_hint()
	acertos_atuais += 1
	tocar_acerto()

	if acertos_atuais >= total_pecas:
		concluir_nivel()
	elif robo and robo.has_method("comemorar"):
		robo.call("comemorar")


func concluir_nivel() -> void:
	if nivel_concluido:
		return

	nivel_concluido = true
	finalizar_hint_manager()

	if confetes:
		confetes.emitting = true

	tocar_vitoria_pedagogica()
	if robo and robo.has_method("vitoria"):
		robo.call("vitoria")
	elif robo and robo.has_method("comemorar"):
		robo.call("comemorar")

	await get_tree().create_timer(1.4).timeout
	mostrar_vitoria_padrao()


func mostrar_vitoria_padrao() -> void:
	if not cena_vitoria:
		push_error("TelaVitoria não pôde ser carregada.")
		return

	var tela := cena_vitoria.instantiate()
	add_child(tela)
	if tela.has_method("configurar"):
		tela.call("configurar", proxima_fase_cena)
