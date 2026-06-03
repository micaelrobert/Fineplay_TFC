extends Node2D

const BASE_SIZE := Vector2(720, 1280)

@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria = preload("res://scenes/telas/TelaVitoria.tscn")

# ==========================================
# RESPONSIVIDADE
# ==========================================
@onready var fundo_responsivo: Sprite2D = $FundoResponsivo
@onready var area_jogo: Node2D = $AreaJogo

# ==========================================
# MANAGERS
# ==========================================
@onready var hint_manager: Node = get_node_or_null("HintManager")
@onready var feedback_audio: Node = get_node_or_null("FeedbackAudio")

# ==========================================
# PEÇAS
# ==========================================
@onready var peca_p = $AreaJogo/Pecas/Peca_Pequena
@onready var peca_m = $AreaJogo/Pecas/Peca_Media
@onready var peca_g = $AreaJogo/Pecas/Peca_Grande
@onready var peca_gg = $AreaJogo/Pecas/Peca_Gigante

# ==========================================
# SLOTS / DESTINOS PARA PISTAS
# ==========================================
@export_node_path("Node2D") var slot_pequeno_path: NodePath
@export_node_path("Node2D") var slot_medio_path: NodePath
@export_node_path("Node2D") var slot_grande_path: NodePath
@export_node_path("Node2D") var slot_gigante_path: NodePath

@onready var slot_pequeno: Node2D = get_node_or_null(slot_pequeno_path)
@onready var slot_medio: Node2D = get_node_or_null(slot_medio_path)
@onready var slot_grande: Node2D = get_node_or_null(slot_grande_path)
@onready var slot_gigante: Node2D = get_node_or_null(slot_gigante_path)

# ==========================================
# FEEDBACK
# ==========================================
@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D

@onready var som_acerto = get_node_or_null("SonsLocais/SomAcerto")
@onready var som_vitoria = get_node_or_null("SonsLocais/SomVitoria")
@onready var som_erro = get_node_or_null("SonsLocais/SomErro")
@onready var som_click_forma = get_node_or_null("SonsLocais/SomClickNaForma")

# ==========================================
# ESTADO
# ==========================================
var nivel_concluido := false
var ordem_obrigatoria := []


func _ready() -> void:
	randomize()

	get_viewport().size_changed.connect(_ajustar_responsivo)
	_ajustar_responsivo()

	configurar_ordem_obrigatoria()
	randomizar_pecas()
	configurar_hint_manager()
	iniciar_musica_fundo()


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	area_jogo.position = (tamanho_tela - BASE_SIZE) / 2.0

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
# ORDEM OBRIGATÓRIA
# ==========================================
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
	registrar_interacao_no_hint()

	if peca_pode_ser_movida(peca):
		tocar_som_clique()
		return true

	tocar_som_erro()

	if hint_manager and hint_manager.has_method("forcar_pista"):
		hint_manager.forcar_pista(2)

	return false


# ==========================================
# HINT MANAGER
# ==========================================
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

	hint_manager.set("mensagem_pista_professor", "Observe com calma. Organize do maior para o menor.")
	hint_manager.set("mensagem_pista_origem", "Comece pela maior peça destacada.")
	hint_manager.set("mensagem_pista_destino", "Agora leve essa peça para o lugar que está brilhando.")


func registrar_interacao_no_hint() -> void:
	if hint_manager and hint_manager.has_method("registrar_interacao"):
		hint_manager.registrar_interacao()


func finalizar_hint_manager() -> void:
	if hint_manager and hint_manager.has_method("finalizar_nivel"):
		hint_manager.finalizar_nivel()


# ==========================================
# RANDOMIZAÇÃO
# ==========================================
func randomizar_pecas() -> void:
	var pecas = [peca_p, peca_m, peca_g, peca_gg]
	var posicoes := []

	for p in pecas:
		posicoes.append(p.global_position)

	posicoes.shuffle()

	for i in range(pecas.size()):
		pecas[i].global_position = posicoes[i]
		pecas[i].posicao_inicial = posicoes[i]


# ==========================================
# ÁUDIO / FEEDBACK
# ==========================================
func tocar_som_clique() -> void:
	if feedback_audio and feedback_audio.has_method("tocar_click_forma"):
		feedback_audio.tocar_click_forma()
		return

	if som_click_forma:
		som_click_forma.play()


func tocar_som_acerto() -> void:
	registrar_interacao_no_hint()

	if feedback_audio and feedback_audio.has_method("tocar_acerto"):
		feedback_audio.tocar_acerto()
		return

	if som_acerto:
		som_acerto.play()


func tocar_som_erro() -> void:
	registrar_interacao_no_hint()

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


# ==========================================
# LÓGICA DO JOGO
# ==========================================
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

	await get_tree().process_frame

	tela.configurar(proxima_fase_cena)


# ==========================================
# CALLBACKS PARA HINTMANAGER
# ==========================================
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
