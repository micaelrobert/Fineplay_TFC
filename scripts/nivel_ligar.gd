extends Node2D

# config de nivel
enum ModoJogo { PARES_CLASSICOS, SEQUENCIA_NUMERICA }
@export var modo_atual: ModoJogo = ModoJogo.PARES_CLASSICOS
@export var total_objetivos: int = 3

# navegacao
@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria = preload("res://scenes/telaVitoria/TelaVitoria.tscn")

# visual
@export var cor_linha: Color = Color.WHITE
@export var cor_certa: Color = Color.GREEN

# sons locais
# Referências aos nós de áudio criados na cena
@onready var som_click_objeto = $SonsLocais/SomClickObjeto
@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_vitoria = $SonsLocais/SomVitoria

# var internas
var ponto_inicial = null
var linha_atual: Line2D = null
var acertos = 0

func _ready():
	randomize()
	randomizar_posicoes()
	
	# Garante que a música global esteja tocando
	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
			musica.play()

func randomizar_posicoes():
	var todos_pontos = get_tree().get_nodes_in_group("pontos")
	
	if modo_atual == ModoJogo.SEQUENCIA_NUMERICA:
		var posicoes = []
		for ponto in todos_pontos:
			posicoes.append(ponto.global_position)
		posicoes.shuffle()
		for i in range(todos_pontos.size()):
			todos_pontos[i].global_position = posicoes[i]

	elif modo_atual == ModoJogo.PARES_CLASSICOS:
		var pontos_saida = []
		var pontos_chegada = []
		
		for ponto in todos_pontos:
			if ponto.tipo == ponto.Tipo.SAIDA:
				pontos_saida.append(ponto)
			elif ponto.tipo == ponto.Tipo.CHEGADA:
				pontos_chegada.append(ponto)
		
		var posicoes_saida = []
		for p in pontos_saida: posicoes_saida.append(p.global_position)
		posicoes_saida.shuffle()
		for i in range(pontos_saida.size()):
			pontos_saida[i].global_position = posicoes_saida[i]
			
		var posicoes_chegada = []
		for p in pontos_chegada: posicoes_chegada.append(p.global_position)
		posicoes_chegada.shuffle()
		for i in range(pontos_chegada.size()):
			pontos_chegada[i].global_position = posicoes_chegada[i]

func _input(event):
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

func tentar_iniciar_linha(ponto):
	var pode_iniciar = false
	
	if modo_atual == ModoJogo.PARES_CLASSICOS:
		if ponto.tipo == ponto.Tipo.SAIDA and not ponto.esta_conectado_saida:
			pode_iniciar = true
			
	elif modo_atual == ModoJogo.SEQUENCIA_NUMERICA:
		if not ponto.esta_conectado_saida:
			pode_iniciar = true

	if pode_iniciar:
		ponto_inicial = ponto
		
		#  som ao clicar na bolinha
		som_click_objeto.play()
		
		criar_visual_linha(ponto.global_position)

func criar_visual_linha(pos_inicial):
	linha_atual = Line2D.new()
	linha_atual.width = 12.0
	linha_atual.default_color = cor_linha
	linha_atual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linha_atual.end_cap_mode = Line2D.LINE_CAP_ROUND
	linha_atual.add_point(pos_inicial)
	linha_atual.add_point(get_global_mouse_position())
	add_child(linha_atual)

func finalizar_linha():
	var ponto_final = buscar_ponto_sob_mouse()
	var acertou = false
	
	if ponto_final and ponto_final != ponto_inicial:
		if modo_atual == ModoJogo.PARES_CLASSICOS:
			if ponto_final.tipo == ponto_final.Tipo.CHEGADA and not ponto_final.esta_conectado_chegada:
				if ponto_final.id_par == ponto_inicial.id_par:
					acertou = true

		elif modo_atual == ModoJogo.SEQUENCIA_NUMERICA:
			if ponto_final.valor_numero == ponto_inicial.valor_numero + 1:
				if not ponto_final.esta_conectado_chegada:
					acertou = true

	if acertou:
		linha_atual.set_point_position(1, ponto_final.global_position)
		linha_atual.default_color = cor_certa
		
		ponto_inicial.esta_conectado_saida = true
		ponto_final.esta_conectado_chegada = true
		
		# som de conexão correta 
		som_acerto.play()
		
		linha_atual = null
		ponto_inicial = null
		verificar_vitoria()
	else:
		linha_atual.queue_free()
		linha_atual = null
		ponto_inicial = null

func verificar_vitoria():
	acertos += 1
	if acertos >= total_objetivos:
		print("NÍVEL CONCLUÍDO!")
		
		# som jingle de vitória 
		som_vitoria.play()
		
		await get_tree().create_timer(1.0).timeout
		mostrar_tela_vitoria()

func mostrar_tela_vitoria():
	var tela = cena_vitoria.instantiate()
	tela.configurar(proxima_fase_cena)
	add_child(tela)
