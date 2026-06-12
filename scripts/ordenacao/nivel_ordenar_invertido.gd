extends Node2D

# ============================================================
# Ordenação 4 peças — maior para menor
# Responsividade controlada pelo AutoLoad ResponsividadeUniversal.gd
# ============================================================

@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria: PackedScene = preload("res://scenes/telas/TelaVitoria.tscn")

@onready var area_jogo: Node2D = $AreaJogo
@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D

@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")

@onready var peca_p = $AreaJogo/Pecas/Peca_Pequena
@onready var peca_m = $AreaJogo/Pecas/Peca_Media
@onready var peca_g = $AreaJogo/Pecas/Peca_Grande
@onready var peca_gg = $AreaJogo/Pecas/Peca_Gigante

@export_node_path("Node2D") var slot_pequeno_path: NodePath
@export_node_path("Node2D") var slot_medio_path: NodePath
@export_node_path("Node2D") var slot_grande_path: NodePath
@export_node_path("Node2D") var slot_gigante_path: NodePath

@onready var slot_pequeno: Node2D = get_node_or_null(slot_pequeno_path)
@onready var slot_medio: Node2D = get_node_or_null(slot_medio_path)
@onready var slot_grande: Node2D = get_node_or_null(slot_grande_path)
@onready var slot_gigante: Node2D = get_node_or_null(slot_gigante_path)

@onready var som_acerto = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_vitoria = get_node_or_null("SonsLocais/SomVitoria")
@onready var som_erro = get_node_or_null("SonsLocais/SomErro")
@onready var som_click_forma = get_node_or_null("SonsLocais/SomClickNaForma")

var nivel_concluido := false
var ordem_obrigatoria := []


func _ready() -> void:
	randomize()
	call_deferred("_inicializar_fase_com_seguranca")


func _inicializar_fase_com_seguranca() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	_inicializar_fase()


func _inicializar_fase() -> void:
	nivel_concluido = false

	configurar_ordem_obrigatoria()
	randomizar_pecas()
	configurar_hint_manager()
	iniciar_musica_fundo()

	print("Minigame de Ordenação 4 peças iniciado: maior para menor.")


func iniciar_musica_fundo() -> void:
	var musica = get_node_or_null("/root/AudioManager/MusicaFundo")

	if musica and not musica.playing:
		musica.play()


func configurar_ordem_obrigatoria() -> void:
	# Ordem invertida: gigante -> grande -> média -> pequena.
	ordem_obrigatoria = [peca_gg, peca_g, peca_m, peca_p]


func obter_proxima_peca_obrigatoria() -> Node:
	for peca in ordem_obrigatoria:
		if peca and peca.slot_atual == null:
			return peca

	return null


func peca_pode_ser_movida(peca: Node) -> bool:
	if nivel_concluido:
		return false

	var proxima_peca = obter_proxima_peca_obrigatoria()

	if not proxima_peca:
		return false

	return peca == proxima_peca


func tentar_iniciar_peca(peca: Node) -> bool:
	# Clique não deve resetar pista.
	registrar_acao_no_hint_sem_resetar()

	if peca_pode_ser_movida(peca):
		tocar_som_clique()
		return true

	# Se a criança tenta pegar uma peça fora da ordem,
	tocar_som_erro()
	if hint_manager and hint_manager.has_method("forcar_pista"):
		hint_manager.forcar_pista(1)

	if robo and robo.has_method("errar"):
		robo.errar()
	elif robo.has_method("dar_dica"):
		robo.dar_dica()

	return false


func configurar_hint_manager() -> void:
	if not hint_manager:
		push_warning("HintManager não encontrado. Pistas desativadas.")
		return

	if hint_manager.has_method("configurar_callbacks"):
		hint_manager.configurar_callbacks(
			Callable(self, "buscar_peca_para_pista"),
			Callable(self, "buscar_destino_da_peca_para_pista")
		)

	if hint_manager.has_method("reiniciar_sistema"):
		hint_manager.reiniciar_sistema()


func registrar_acao_no_hint_sem_resetar() -> void:
	if hint_manager and hint_manager.has_method("registrar_acao_sem_resetar_pista"):
		hint_manager.registrar_acao_sem_resetar_pista()


func registrar_acerto_no_hint() -> void:
	if hint_manager and hint_manager.has_method("registrar_acerto"):
		hint_manager.registrar_acerto()
	elif hint_manager and hint_manager.has_method("resetar_pistas"):
		hint_manager.resetar_pistas()


func finalizar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("finalizar_nivel"):
		hint_manager.finalizar_nivel()


func randomizar_pecas() -> void:
	var pecas = [peca_p, peca_m, peca_g, peca_gg]
	var posicoes := []

	for p in pecas:
		if p:
			posicoes.append(p.global_position)

	posicoes.shuffle()

	var indice := 0

	for p in pecas:
		if p:
			p.global_position = posicoes[indice]

			if p.has_method("atualizar_posicao_inicial"):
				p.atualizar_posicao_inicial()
			else:
				p.posicao_inicial = p.global_position

			indice += 1


func tocar_som_clique() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.tocar_click_forma()
		return

	if som_click_forma:
		som_click_forma.play()


func tocar_som_acerto() -> void:
	registrar_acerto_no_hint()

	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.tocar_acerto()
		return

	if som_acerto:
		som_acerto.play()


func tocar_som_erro() -> void:
	# Erro no slot errado mantém a pista e o tempo.
	registrar_acao_no_hint_sem_resetar()

	if feedback_audio and feedback_audio.has_method("tocar_erro_pedagogico"):
		feedback_audio.tocar_erro_pedagogico()
	else:
		if som_erro:
			som_erro.play()

	if robo and robo.has_method("errar"):
		robo.errar()


func tocar_som_vitoria() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_vitoria_pedagogica"):
		feedback_audio.tocar_vitoria_pedagogica()
		return

	if som_vitoria:
		som_vitoria.play()


func slot_esta_ocupado(slot_verificado, peca_ignorada) -> bool:
	for peca in [peca_p, peca_m, peca_g, peca_gg]:
		if peca != peca_ignorada and peca.slot_atual == slot_verificado:
			return true

	return false


func verificar_vitoria() -> void:
	if nivel_concluido:
		return

	if (
		peca_p.slot_atual != null
		and peca_m.slot_atual != null
		and peca_g.slot_atual != null
		and peca_gg.slot_atual != null
	):
		vitoria()
	else:
		if robo and robo.has_method("comemorar"):
			robo.comemorar()


func vitoria() -> void:
	if nivel_concluido:
		return

	nivel_concluido = true
	finalizar_hint_manager()

	print("Vitória! Ordenação invertida concluída.")

	if confetes:
		confetes.emitting = true

	tocar_som_vitoria()

	if robo and robo.has_method("vitoria"):
		robo.vitoria()
	elif robo and robo.has_method("comemorar"):
		robo.comemorar()

	await get_tree().create_timer(1.4).timeout
	mostrar_vitoria_padrao()


func mostrar_vitoria_padrao() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	if tela.has_method("configurar"):
		tela.configurar(proxima_fase_cena)
	else:
		push_warning("TelaVitoria não possui o método configurar().")


func buscar_peca_para_pista() -> Node:
	return obter_proxima_peca_obrigatoria()


func buscar_destino_da_peca_para_pista(peca: Node) -> Node:
	if not peca:
		return null

	if peca == peca_gg:
		return slot_gigante

	if peca == peca_g:
		return slot_grande

	if peca == peca_m:
		return slot_medio

	if peca == peca_p:
		return slot_pequeno

	return null
