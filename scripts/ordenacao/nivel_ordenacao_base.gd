extends Node2D

@export_file("*.tscn") var proxima_fase_cena: String

@export_node_path("Node2D") var slot_pequeno_path: NodePath
@export_node_path("Node2D") var slot_medio_path: NodePath
@export_node_path("Node2D") var slot_grande_path: NodePath
@export_node_path("Node2D") var slot_gigante_path: NodePath

var cena_vitoria: PackedScene = preload("res://scenes/telas/TelaVitoria.tscn")

@onready var area_jogo: Node2D = get_node_or_null("AreaJogo") as Node2D
@onready var robo: Node = get_node_or_null("AreaJogo/ProfessorRobo")
@onready var confetes: CPUParticles2D = get_node_or_null("AreaJogo/CPUParticles2D") as CPUParticles2D
@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")

@onready var som_acerto: Node = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_vitoria: Node = get_node_or_null("SonsLocais/SomVitoria")
@onready var som_erro: Node = get_node_or_null("SonsLocais/SomErro")
@onready var som_click_forma: Node = get_node_or_null("SonsLocais/SomClickNaForma")

var peca_p: Node = null
var peca_m: Node = null
var peca_g: Node = null
var peca_gg: Node = null

var slot_pequeno: Node = null
var slot_medio: Node = null
var slot_grande: Node = null
var slot_gigante: Node = null

var nivel_concluido := false
var ordem_obrigatoria: Array[Node] = []
var pecas_do_nivel: Array[Node] = []


func _ready() -> void:
	randomize()
	call_deferred("_inicializar_fase_com_seguranca")


func _inicializar_fase_com_seguranca() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_inicializar_fase()


func _inicializar_fase() -> void:
	if not area_jogo:
		push_error("Ordenação: nó AreaJogo não encontrado.")
		return

	nivel_concluido = false
	_resolver_pecas()
	_resolver_slots()
	configurar_ordem_obrigatoria()
	randomizar_pecas()
	configurar_hint_manager()
	iniciar_musica_fundo()

	if ordem_obrigatoria.is_empty():
		push_error("Ordenação: nenhuma peça foi configurada na ordem obrigatória.")
	else:
		print(_mensagem_inicio())


func _mensagem_inicio() -> String:
	return "Minigame de Ordenação iniciado."


func _resolver_pecas() -> void:
	peca_p = get_node_or_null("AreaJogo/Pecas/Peca_Pequena")
	peca_m = get_node_or_null("AreaJogo/Pecas/Peca_Media")
	peca_g = get_node_or_null("AreaJogo/Pecas/Peca_Grande")
	peca_gg = get_node_or_null("AreaJogo/Pecas/Peca_Gigante")

	pecas_do_nivel.clear()
	for peca in [peca_p, peca_m, peca_g, peca_gg]:
		if peca:
			pecas_do_nivel.append(peca)


func _resolver_slots() -> void:
	slot_pequeno = _resolver_slot_seguro(slot_pequeno_path, peca_p, "Slot_1")
	slot_medio = _resolver_slot_seguro(slot_medio_path, peca_m, "Slot_2")
	slot_grande = _resolver_slot_seguro(slot_grande_path, peca_g, "Slot_3")
	slot_gigante = _resolver_slot_seguro(slot_gigante_path, peca_gg, "Slot_4")


func _resolver_slot_seguro(caminho: NodePath, peca: Node, nome_fallback: String) -> Node:
	var candidato := get_node_or_null(caminho) if not caminho.is_empty() else null
	if _node_parece_slot(candidato):
		return candidato

	if candidato:
		push_warning(
			(
				"Ordenação: o NodePath configurado para um slot aponta para '"
				+ String(candidato.name)
				+ "', que não parece ser um slot. Aplicando busca automática."
			)
		)

	if peca and peca.has_method("get_slot_correto"):
		var slot_da_peca: Node = peca.call("get_slot_correto")
		if _node_parece_slot(slot_da_peca):
			return slot_da_peca

	var por_nome := area_jogo.find_child(nome_fallback, true, false) if area_jogo else null
	if _node_parece_slot(por_nome):
		return por_nome

	return null


func _node_parece_slot(node: Node) -> bool:
	return (
		node != null
		and is_instance_valid(node)
		and (node.is_in_group("slots") or node.name.begins_with("Slot"))
	)


func configurar_ordem_obrigatoria() -> void:
	ordem_obrigatoria = [peca_p, peca_m, peca_g]
	_limpar_nulos_da_ordem()


func _limpar_nulos_da_ordem() -> void:
	var ordem_limpa: Array[Node] = []
	for peca in ordem_obrigatoria:
		if peca:
			ordem_limpa.append(peca)
	ordem_obrigatoria = ordem_limpa


func obter_proxima_peca_obrigatoria() -> Node:
	for peca in ordem_obrigatoria:
		if peca and _obter_slot_atual(peca) == null:
			return peca
	return null


func peca_pode_ser_movida(peca: Node) -> bool:
	return not nivel_concluido and peca != null and peca == obter_proxima_peca_obrigatoria()


func tentar_iniciar_peca(peca: Node) -> bool:
	registrar_interacao_no_hint()

	if peca_pode_ser_movida(peca):
		pausar_hint_manager()
		tocar_som_clique()
		return true

	tocar_som_erro()
	if hint_manager and hint_manager.has_method("forcar_pista"):
		hint_manager.call("forcar_pista", 1)
	return false


func notificar_fim_interacao() -> void:
	retomar_hint_manager()


func configurar_hint_manager() -> void:
	if not hint_manager:
		push_warning("HintManager não encontrado. Pistas desativadas.")
		return

	if hint_manager.has_method("configurar_callbacks"):
		hint_manager.call(
			"configurar_callbacks",
			Callable(self, "buscar_peca_para_pista"),
			Callable(self, "buscar_destino_da_peca_para_pista")
		)

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


func randomizar_pecas() -> void:
	var posicoes: Array[Vector2] = []
	for peca in pecas_do_nivel:
		if peca is Node2D:
			posicoes.append((peca as Node2D).global_position)

	if posicoes.size() != pecas_do_nivel.size():
		push_warning("Ordenação: uma ou mais peças não são Node2D; randomização parcial cancelada.")
		return

	posicoes.shuffle()
	for indice in range(pecas_do_nivel.size()):
		var peca := pecas_do_nivel[indice]
		(peca as Node2D).global_position = posicoes[indice]
		if peca.has_method("atualizar_posicao_inicial"):
			peca.call("atualizar_posicao_inicial")
		elif _objeto_tem_propriedade(peca, "posicao_inicial"):
			peca.set("posicao_inicial", (peca as Node2D).global_position)


func iniciar_musica_fundo() -> void:
	var musica := get_node_or_null("/root/AudioManager/MusicaFundo")
	if musica and not bool(musica.get("playing")) and musica.has_method("play"):
		musica.call("play")


func tocar_som_clique() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.call("tocar_click_forma")
	elif som_click_forma and som_click_forma.has_method("play"):
		som_click_forma.call("play")


func tocar_som_acerto() -> void:
	registrar_acerto_no_hint()
	retomar_hint_manager()

	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.call("tocar_acerto")
	elif som_acerto and som_acerto.has_method("play"):
		som_acerto.call("play")


func tocar_som_erro() -> void:
	registrar_acao_no_hint_sem_resetar()
	retomar_hint_manager()

	if feedback_audio and feedback_audio.has_method("tocar_erro_pedagogico"):
		feedback_audio.call("tocar_erro_pedagogico")
	elif som_erro and som_erro.has_method("play"):
		som_erro.call("play")

	if robo and robo.has_method("errar"):
		robo.call("errar")


func tocar_som_vitoria() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_vitoria_pedagogica"):
		feedback_audio.call("tocar_vitoria_pedagogica")
	elif som_vitoria and som_vitoria.has_method("play"):
		som_vitoria.call("play")


func slot_esta_ocupado(slot_verificado: Node, peca_ignorada: Node) -> bool:
	if slot_verificado == null:
		return false

	for peca in pecas_do_nivel:
		if peca != peca_ignorada and _obter_slot_atual(peca) == slot_verificado:
			return true
	return false


func _obter_slot_atual(peca: Node) -> Node:
	if peca and _objeto_tem_propriedade(peca, "slot_atual"):
		return peca.get("slot_atual") as Node
	return null


func verificar_vitoria() -> void:
	if nivel_concluido:
		return

	for peca in pecas_do_nivel:
		if _obter_slot_atual(peca) == null:
			if robo and robo.has_method("comemorar"):
				robo.call("comemorar")
			return

	vitoria()


func vitoria() -> void:
	if nivel_concluido:
		return

	nivel_concluido = true
	finalizar_hint_manager()

	if confetes:
		confetes.emitting = true

	tocar_som_vitoria()
	if robo and robo.has_method("vitoria"):
		robo.call("vitoria")
	elif robo and robo.has_method("comemorar"):
		robo.call("comemorar")

	await get_tree().create_timer(1.4).timeout
	mostrar_vitoria_padrao()


func mostrar_vitoria_padrao() -> void:
	if not cena_vitoria:
		push_error("Ordenação: TelaVitoria não pôde ser carregada.")
		return

	var tela := cena_vitoria.instantiate()
	add_child(tela)
	if tela.has_method("configurar"):
		tela.call("configurar", proxima_fase_cena)


func buscar_peca_para_pista() -> Node:
	return obter_proxima_peca_obrigatoria()


func buscar_destino_da_peca_para_pista(peca: Node) -> Node:
	if not peca:
		return null

	var destino: Node = null
	if peca == peca_p:
		destino = slot_pequeno
	elif peca == peca_m:
		destino = slot_medio
	elif peca == peca_g:
		destino = slot_grande
	elif peca == peca_gg:
		destino = slot_gigante

	if _node_parece_slot(destino):
		return destino

	# Fallback decisivo: corrige em tempo de execução um NodePath errado no
	# Inspector, usando o nome de slot já configurado na própria peça.
	if peca.has_method("get_slot_correto"):
		var slot_da_peca: Node = peca.call("get_slot_correto")
		if _node_parece_slot(slot_da_peca):
			return slot_da_peca

	return null


func _objeto_tem_propriedade(objeto: Object, nome_propriedade: StringName) -> bool:
	if not objeto:
		return false
	for propriedade in objeto.get_property_list():
		if StringName(propriedade.name) == nome_propriedade:
			return true
	return false
