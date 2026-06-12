extends Node2D


# ============================================================
# OBSERVAÇÃO IMPORTANTE
# ============================================================
# A responsividade agora é controlada pelo AutoLoad:
# ResponsividadeUniversal.gd
#
# Este script NÃO centraliza AreaJogo
# nem redimensiona FundoResponsivo.
#
# A cena ainda precisa manter os nós:
# - AreaJogo
# - FundoResponsivo
# ============================================================


# ============================================================
# MANAGERS GENÉRICOS
# ============================================================
@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")


# ============================================================
# ELEMENTOS DA FASE
# ============================================================
@onready var area_jogo: Node2D = $AreaJogo
@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D


# ============================================================
# NAVEGAÇÃO
# ============================================================
@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria: PackedScene = preload("res://scenes/telas/TelaVitoria.tscn")


# ============================================================
# FALLBACK DE SONS LOCAIS
# Usado apenas se o FeedbackAudio ainda não estiver configurado.
# ============================================================
@onready var som_acerto = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_vitoria = get_node_or_null("SonsLocais/SomVitoria")
@onready var som_erro = get_node_or_null("SonsLocais/SomErro")
@onready var som_click_forma = get_node_or_null("SonsLocais/SomClickNaForma")


# ============================================================
# CONTROLE DA FASE
# ============================================================
var total_pecas := 0
var acertos_atuais := 0
var nivel_concluido := false


func _ready() -> void:
	randomize()
	call_deferred("_inicializar_fase_com_seguranca")


func _inicializar_fase_com_seguranca() -> void:
	# Aguarda a cena montar completamente.
	await get_tree().process_frame

	# Aguarda mais um frame para o AutoLoad ResponsividadeUniversal
	# ajustar AreaJogo e FundoResponsivo.
	await get_tree().process_frame

	_inicializar_fase()


func _inicializar_fase() -> void:
	randomizar_layout()

	# CRÍTICO:
	# Depois de randomizar, atualiza a posição inicial real das peças.
	# Isso impede que uma peça volte para a posição antiga de outra peça.
	atualizar_posicoes_iniciais_das_pecas()

	configurar_pecas_da_fase()
	iniciar_musica_fundo()
	configurar_hint_manager()

	print("Nível iniciado com ", total_pecas, " peças.")


# ============================================================
# CONFIGURAÇÃO DOS MANAGERS
# ============================================================
func configurar_hint_manager() -> void:
	if not hint_manager:
		push_warning("HintManager não encontrado nesta fase. O jogo funciona, mas sem pistas progressivas.")
		return

	if hint_manager.has_method("reiniciar_sistema"):
		hint_manager.reiniciar_sistema()


func registrar_acao_no_hint_sem_resetar() -> void:
	# Clique e erro não devem limpar pistas nem zerar o tempo.
	if hint_manager and hint_manager.has_method("registrar_acao_sem_resetar_pista"):
		hint_manager.registrar_acao_sem_resetar_pista()


func registrar_acerto_no_hint() -> void:
	# Somente acerto deve limpar pista e reiniciar tempo.
	if hint_manager and hint_manager.has_method("registrar_acerto"):
		hint_manager.registrar_acerto()
	elif hint_manager and hint_manager.has_method("resetar_pistas"):
		hint_manager.resetar_pistas()


func finalizar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("finalizar_nivel"):
		hint_manager.finalizar_nivel()


# ============================================================
# CONFIGURAÇÃO DA FASE
# ============================================================
func configurar_pecas_da_fase() -> void:
	total_pecas = 0
	acertos_atuais = 0
	nivel_concluido = false

	for filho in area_jogo.get_children():
		if filho.has_signal("peca_encaixada"):
			total_pecas += 1

			if not filho.peca_encaixada.is_connected(_on_peca_acertou):
				filho.peca_encaixada.connect(_on_peca_acertou)

			if filho.has_signal("peca_clicada"):
				if not filho.peca_clicada.is_connected(_on_peca_clicada):
					filho.peca_clicada.connect(_on_peca_clicada)

			if filho.has_signal("peca_errou"):
				if not filho.peca_errou.is_connected(_on_peca_errou):
					filho.peca_errou.connect(_on_peca_errou)


func randomizar_layout() -> void:
	var slots_da_fase := []

	for filho in area_jogo.get_children():
		if filho.is_in_group("slots"):
			slots_da_fase.append(filho)

	var pos_slots := []

	for slot in slots_da_fase:
		pos_slots.append(slot.global_position)

	pos_slots.shuffle()

	for i in range(slots_da_fase.size()):
		slots_da_fase[i].global_position = pos_slots[i]


	var pecas_da_fase := []

	for filho in area_jogo.get_children():
		if filho.is_in_group("pecas"):
			pecas_da_fase.append(filho)

	var pos_pecas := []

	for peca in pecas_da_fase:
		pos_pecas.append(peca.global_position)

	pos_pecas.shuffle()

	for i in range(pecas_da_fase.size()):
		pecas_da_fase[i].global_position = pos_pecas[i]


func atualizar_posicoes_iniciais_das_pecas() -> void:
	for filho in area_jogo.get_children():
		if filho.is_in_group("pecas"):
			_atualizar_posicao_inicial_da_peca(filho)


func _atualizar_posicao_inicial_da_peca(peca: Node) -> void:
	if peca.has_method("atualizar_posicao_inicial"):
		peca.atualizar_posicao_inicial()
		return

	if _objeto_tem_propriedade(peca, "posicao_inicial"):
		peca.set("posicao_inicial", peca.global_position)


func _objeto_tem_propriedade(objeto: Object, nome_propriedade: String) -> bool:
	for propriedade in objeto.get_property_list():
		if propriedade.name == nome_propriedade:
			return true

	return false


func iniciar_musica_fundo() -> void:
	var musica = get_node_or_null("/root/AudioManager/MusicaFundo")

	if musica and not musica.playing:
		musica.play()


# ============================================================
# FEEDBACK DE ÁUDIO
# ============================================================
func tocar_click_forma() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.tocar_click_forma()
		return

	if som_click_forma:
		som_click_forma.play()


func tocar_acerto() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.tocar_acerto()
		return

	if som_acerto:
		som_acerto.play()


func tocar_erro_pedagogico() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_erro_pedagogico"):
		feedback_audio.tocar_erro_pedagogico()
		return

	if som_erro:
		som_erro.play()


func tocar_vitoria_pedagogica() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_vitoria_pedagogica"):
		feedback_audio.tocar_vitoria_pedagogica()
		return

	if som_vitoria:
		som_vitoria.play()


# ============================================================
# EVENTOS DAS PEÇAS
# ============================================================
func _on_peca_clicada() -> void:
	if nivel_concluido:
		return

	# Clique não deve resetar pista.
	registrar_acao_no_hint_sem_resetar()
	tocar_click_forma()


func _on_peca_errou() -> void:
	if nivel_concluido:
		return

	# Erro não deve resetar pista.
	registrar_acao_no_hint_sem_resetar()
	tocar_erro_pedagogico()

	if robo and robo.has_method("errar"):
		robo.errar()


func _on_peca_acertou() -> void:
	if nivel_concluido:
		return

	# Somente acerto reseta pista.
	registrar_acerto_no_hint()

	acertos_atuais += 1

	tocar_acerto()

	if acertos_atuais < total_pecas:
		if robo and robo.has_method("comemorar"):
			robo.comemorar()
	else:
		concluir_nivel()


# ============================================================
# VITÓRIA
# ============================================================
func concluir_nivel() -> void:
	if nivel_concluido:
		return

	nivel_concluido = true
	finalizar_hint_manager()

	print("GANHOU O JOGO!")

	if confetes:
		confetes.emitting = true

	tocar_vitoria_pedagogica()

	if robo and robo.has_method("vitoria"):
		robo.vitoria()
	elif robo and robo.has_method("comemorar"):
		robo.comemorar()

	await get_tree().create_timer(1.4).timeout
	mostrar_vitoria_padrao()


func mostrar_vitoria_padrao() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	# Ao chamar o configurar logo após o add_child, 
	# a Godot faz a alteração ANTES de desenhar a tela pro jogador!
	if tela.has_method("configurar"):
		tela.configurar(proxima_fase_cena)
	else:
		push_warning("TelaVitoria não possui o método configurar().")
