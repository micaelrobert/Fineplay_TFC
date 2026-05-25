extends Node2D

const BASE_SIZE := Vector2(720, 1280)

@export var total_objetivos: int = 9
@export_file("*.tscn") var proxima_fase_cena: String

var cena_vitoria = preload("res://scenes/telas/TelaVitoria.tscn")

@export var cor_linha: Color = Color.WHITE
@export var cor_certa: Color = Color.GREEN

# ==========================================
# RESPONSIVIDADE
# ==========================================
@onready var fundo_responsivo: Sprite2D = $FundoResponsivo
@onready var area_jogo: Node2D = $AreaJogo

# ==========================================
# REFERÊNCIAS DE FEEDBACK
# ==========================================
@onready var som_click_objeto = $SonsLocais/SomClickObjeto
@onready var som_click_forma = $SonsLocais/SomClickNaForma
@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_erro = $SonsLocais/SomErro
@onready var som_vitoria = $SonsLocais/SomVitoria

@onready var robo = $AreaJogo/ProfessorRobo
@onready var confetes = $AreaJogo/CPUParticles2D

var ponto_inicial = null
var linha_atual: Line2D = null
var acertos := 0


func _ready() -> void:
	randomize()

	get_viewport().size_changed.connect(_ajustar_responsivo)
	_ajustar_responsivo()

	randomizar_posicoes()

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


func pegar_pontos_da_fase() -> Array:
	var pontos := []

	for filho in area_jogo.get_children():
		if filho.is_in_group("pontos"):
			pontos.append(filho)

	return pontos


func randomizar_posicoes() -> void:
	# Lógica exclusiva de sequência: embaralha todos os pontos juntos.
	var todos_pontos = pegar_pontos_da_fase()

	var posicoes := []

	for ponto in todos_pontos:
		posicoes.append(ponto.global_position)

	posicoes.shuffle()

	for i in range(todos_pontos.size()):
		todos_pontos[i].global_position = posicoes[i]


func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ponto = buscar_ponto_sob_mouse()
		if ponto:
			tentar_iniciar_linha(ponto)

	elif event is InputEventMouseMotion and linha_atual:
		linha_atual.set_point_position(1, get_global_mouse_position())

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if linha_atual:
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
	# Na sequência, a criança pode puxar a linha se o ponto ainda não for saída.
	if not ponto.esta_conectado_saida:
		ponto_inicial = ponto

		if som_click_forma:
			som_click_forma.play()
		elif som_click_objeto:
			som_click_objeto.play()

		criar_visual_linha(ponto.global_position)


func criar_visual_linha(pos_inicial: Vector2) -> void:
	linha_atual = Line2D.new()
	linha_atual.width = 12.0
	linha_atual.default_color = cor_linha
	linha_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_atual.z_index = 50

	# A linha fica no root usando coordenadas globais.
	# Isso evita desalinhamento depois que a AreaJogo é centralizada.
	linha_atual.add_point(pos_inicial)
	linha_atual.add_point(get_global_mouse_position())

	add_child(linha_atual)


func finalizar_linha() -> void:
	var ponto_final = buscar_ponto_sob_mouse()
	var acertou := false

	if ponto_final and ponto_final != ponto_inicial:
		# Lógica exclusiva de sequência numérica: N + 1.
		if ponto_final.valor_numero == ponto_inicial.valor_numero + 1:
			if not ponto_final.esta_conectado_chegada:
				acertou = true

	if acertou:
		linha_atual.set_point_position(1, ponto_final.global_position)
		linha_atual.default_color = cor_certa

		ponto_inicial.esta_conectado_saida = true
		ponto_final.esta_conectado_chegada = true

		if som_acerto:
			som_acerto.play()

		linha_atual = null
		ponto_inicial = null

		verificar_vitoria()
	else:
		if ponto_final and ponto_final != ponto_inicial:
			if som_erro:
				som_erro.play()

		linha_atual.queue_free()
		linha_atual = null
		ponto_inicial = null


func verificar_vitoria() -> void:
	acertos += 1

	if robo and robo.has_method("comemorar"):
		robo.comemorar()

	if acertos >= total_objetivos:
		if confetes:
			confetes.emitting = true

		if som_vitoria:
			som_vitoria.play()

		await get_tree().create_timer(1.0).timeout
		mostrar_tela_vitoria()


func mostrar_tela_vitoria() -> void:
	var tela = cena_vitoria.instantiate()
	add_child(tela)

	await get_tree().process_frame

	tela.configurar(proxima_fase_cena)
