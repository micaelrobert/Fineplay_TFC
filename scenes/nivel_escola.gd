extends Node2D

@onready var robo = $ProfessorRobo

# navegation
@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria = preload("res://scenes/telaVitoria/TelaVitoria.tscn")

@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_vitoria = $SonsLocais/SomVitoria
@onready var som_erro = $SonsLocais/SomErro
@onready var som_click_forma = $SonsLocais/SomClickNaForma

#confetes
@onready var confetes = $CPUParticles2D

var total_pecas = 0
var acertos_atuais = 0

func _ready():
	randomize()
	
	randomizar_layout()
	
	# config inital 
	for filho in get_children():
		if filho.has_signal("peca_encaixada"):
			total_pecas += 1
			if not filho.peca_encaixada.is_connected(_on_peca_acertou):
				filho.peca_encaixada.connect(_on_peca_acertou)
			if not filho.peca_clicada.is_connected(_on_peca_clicada):
				filho.peca_clicada.connect(_on_peca_clicada)
			if not filho.peca_errou.is_connected(_on_peca_errou):
				filho.peca_errou.connect(_on_peca_errou)
	
	print("Nível iniciado com ", total_pecas, " peças.")

	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
			musica.play()

func randomizar_layout():
	# get_children() verifica o grupo para não pegar slots de outras cenas se houver confusão
	var slots_da_fase = []
	for filho in get_children():
		if filho.is_in_group("slots"):
			slots_da_fase.append(filho)
	
	# Coleta posições, embaralha e reaplica
	var pos_slots = []
	for s in slots_da_fase: pos_slots.append(s.global_position)
	pos_slots.shuffle()
	for i in range(slots_da_fase.size()):
		slots_da_fase[i].global_position = pos_slots[i]

	# mesma coisa com os obj arrastaveis
	var pecas_da_fase = []
	for filho in get_children():
		if filho.is_in_group("pecas"): #grupo dos obj arrastaveis, nomeei de pecas
			pecas_da_fase.append(filho)
	
	var pos_pecas = []
	for p in pecas_da_fase: pos_pecas.append(p.global_position)
	pos_pecas.shuffle()
	for i in range(pecas_da_fase.size()):
		pecas_da_fase[i].global_position = pos_pecas[i]

#funcoes de som

func _on_peca_clicada():
	if som_click_forma: som_click_forma.play()

func _on_peca_errou():
	if som_erro: som_erro.play()

func _on_peca_acertou():
	acertos_atuais += 1
	if som_acerto: som_acerto.play()
	if robo: robo.comemorar()
	
	if acertos_atuais == total_pecas:
		print("GANHOU O JOGO!")
		if confetes: confetes.emitting = true
		if som_vitoria: som_vitoria.play()
		await get_tree().create_timer(1.0).timeout 
		mostrar_vitoria_padrao()

func mostrar_vitoria_padrao():
	var tela = cena_vitoria.instantiate()
	tela.configurar(proxima_fase_cena)
	add_child(tela)
