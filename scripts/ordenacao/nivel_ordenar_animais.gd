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
# REFERÊNCIAS DAS PEÇAS
# ==========================================
@onready var peca_p = $AreaJogo/Pecas/Peca_Pequena
@onready var peca_m = $AreaJogo/Pecas/Peca_Media
@onready var peca_g = $AreaJogo/Pecas/Peca_Grande
@onready var peca_gg = $AreaJogo/Pecas/Peca_Gigante

# ==========================================
# REFERÊNCIAS DE FEEDBACK
# ==========================================
@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D

@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_vitoria = $SonsLocais/SomVitoria
@onready var som_erro = $SonsLocais/SomErro
@onready var som_click_forma = $SonsLocais/SomClickNaForma


func _ready() -> void:
	randomize()

	get_viewport().size_changed.connect(_ajustar_responsivo)
	_ajustar_responsivo()

	randomizar_pecas()

	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
			musica.play()


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


# ==========================================
# LÓGICA DO JOGO E VALIDAÇÃO
# ==========================================

func slot_esta_ocupado(slot_verificado, peca_ignorada) -> bool:
	var todas_pecas = [peca_p, peca_m, peca_g, peca_gg]

	for peca in todas_pecas:
		if peca != peca_ignorada and peca.slot_atual == slot_verificado:
			return true

	return false


func verificar_vitoria() -> void:
	var todas_acertaram = (
		peca_p.slot_atual != null
		and peca_m.slot_atual != null
		and peca_g.slot_atual != null
		and peca_gg.slot_atual != null
	)

	if todas_acertaram:
		vitoria()
	else:
		if robo and robo.has_method("comemorar"):
			robo.comemorar()


func vitoria() -> void:
	print("Vitória! Ordenação concluída.")

	if confetes:
		confetes.emitting = true

	if som_vitoria:
		som_vitoria.play()

	if robo and robo.has_method("vitoria"):
		robo.vitoria()
	elif robo and robo.has_method("comemorar"):
		robo.comemorar()

	await get_tree().create_timer(1.0).timeout
	mostrar_vitoria_padrao()


func mostrar_vitoria_padrao() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	await get_tree().process_frame

	tela.configurar(proxima_fase_cena)


# ==========================================
# UTILITÁRIOS
# ==========================================

func randomizar_pecas() -> void:
	var pecas_da_fase = [peca_p, peca_m, peca_g, peca_gg]
	var pos_pecas := []

	for p in pecas_da_fase:
		pos_pecas.append(p.global_position)

	pos_pecas.shuffle()

	for i in range(pecas_da_fase.size()):
		pecas_da_fase[i].global_position = pos_pecas[i]

		# Atualiza a posição inicial para que o erro retorne ao local embaralhado.
		pecas_da_fase[i].posicao_inicial = pos_pecas[i]


func tocar_som_clique() -> void:
	if som_click_forma:
		som_click_forma.play()


func tocar_som_acerto() -> void:
	if som_acerto:
		som_acerto.play()


func tocar_som_erro() -> void:
	if som_erro:
		som_erro.play()

	if robo and robo.has_method("errar"):
		robo.errar()
