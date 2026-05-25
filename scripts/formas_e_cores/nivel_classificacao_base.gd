extends Node2D

const BASE_SIZE := Vector2(720, 1280)

# Responsividade
@onready var fundo_responsivo: Sprite2D = $FundoResponsivo
@onready var area_jogo: Node2D = $AreaJogo

# Elementos da fase
@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D

# Navegação
@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria = preload("res://scenes/telas/TelaVitoria.tscn")

# Sons locais
@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_vitoria = $SonsLocais/SomVitoria
@onready var som_erro = $SonsLocais/SomErro
@onready var som_click_forma = $SonsLocais/SomClickNaForma

var total_pecas := 0
var acertos_atuais := 0


func _ready() -> void:
	randomize()

	get_viewport().size_changed.connect(_ajustar_responsivo)
	_ajustar_responsivo()

	randomizar_layout()
	configurar_pecas_da_fase()
	iniciar_musica_fundo()

	print("Nível iniciado com ", total_pecas, " peças.")


func _ajustar_responsivo() -> void:
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size

	# Centraliza a área lógica 720x1280 dentro da tela real.
	area_jogo.position = (tamanho_tela - BASE_SIZE) / 2.0

	# Faz o fundo cobrir toda a tela real.
	if fundo_responsivo and fundo_responsivo.texture:
		var tamanho_textura: Vector2 = fundo_responsivo.texture.get_size()

		fundo_responsivo.centered = true
		fundo_responsivo.position = tamanho_tela / 2.0

		var escala_x := tamanho_tela.x / tamanho_textura.x
		var escala_y := tamanho_tela.y / tamanho_textura.y
		var escala_final = max(escala_x, escala_y)

		fundo_responsivo.scale = Vector2(escala_final, escala_final)


func configurar_pecas_da_fase() -> void:
	total_pecas = 0
	acertos_atuais = 0

	for filho in area_jogo.get_children():
		if filho.has_signal("peca_encaixada"):
			total_pecas += 1

			if not filho.peca_encaixada.is_connected(_on_peca_acertou):
				filho.peca_encaixada.connect(_on_peca_acertou)

			if not filho.peca_clicada.is_connected(_on_peca_clicada):
				filho.peca_clicada.connect(_on_peca_clicada)

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


func iniciar_musica_fundo() -> void:
	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
			musica.play()


func _on_peca_clicada() -> void:
	if som_click_forma:
		som_click_forma.play()


func _on_peca_errou() -> void:
	if som_erro:
		som_erro.play()


func _on_peca_acertou() -> void:
	acertos_atuais += 1

	if som_acerto:
		som_acerto.play()

	if robo:
		robo.comemorar()

	if acertos_atuais == total_pecas:
		concluir_nivel()


func concluir_nivel() -> void:
	print("GANHOU O JOGO!")

	if confetes:
		confetes.emitting = true

	if som_vitoria:
		som_vitoria.play()

	await get_tree().create_timer(1.0).timeout
	mostrar_vitoria_padrao()


func mostrar_vitoria_padrao() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	await get_tree().process_frame

	tela.configurar(proxima_fase_cena)
