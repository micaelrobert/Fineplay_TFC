extends Node2D

@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria = preload("res://scenes/telaVitoria/TelaVitoria.tscn")

# Referências das Peças
@onready var peca_p = $Pecas/Peca_Pequena
@onready var peca_m = $Pecas/Peca_Media
@onready var peca_g = $Pecas/Peca_Grande

# Referências de Feedback
@onready var robo = $ProfessorRobo 
@onready var confetes = $CPUParticles2D 
@onready var som_acerto = $SonsLocais/SomAcerto
@onready var som_vitoria = $SonsLocais/SomVitoria
@onready var som_erro = $SonsLocais/SomErro
@onready var som_click_forma = $SonsLocais/SomClickNaForma

func _ready():
	randomize()
	randomizar_pecas()
	
	if has_node("/root/AudioManager"):
		var musica = get_node("/root/AudioManager/MusicaFundo")
		if not musica.playing:
			musica.play()

# ==========================================
# LÓGICA DO JOGO E VALIDAÇÃO
# ==========================================

# Resolve o bug: Confere se há alguma OUTRA peça usando este slot
func slot_esta_ocupado(slot_verificado, peca_ignorada) -> bool:
	var todas_pecas = [peca_p, peca_m, peca_g]
	for peca in todas_pecas:
		if peca != peca_ignorada and peca.slot_atual == slot_verificado:
			return true
	return false

func verificar_vitoria():
	# Só checa se todas as 3 peças estão em algum slot
	if peca_p.slot_atual and peca_m.slot_atual and peca_g.slot_atual:
		
		# A Lógica de Seriação: P -> 1, M -> 2, G -> 3
		var ordem_correta = (
			peca_p.slot_atual.name == "Slot_1" and
			peca_m.slot_atual.name == "Slot_2" and
			peca_g.slot_atual.name == "Slot_3"
		)
		
		if ordem_correta:
			vitoria()

func vitoria():
	print("Vitória! Ordenação concluída.")
	if confetes: confetes.emitting = true
	if som_vitoria: som_vitoria.play()
	if robo and robo.has_method("comemorar"): robo.comemorar()
	
	await get_tree().create_timer(1.0).timeout 
	mostrar_vitoria_padrao()

func mostrar_vitoria_padrao():
	var tela = cena_vitoria.instantiate()
	tela.configurar(proxima_fase_cena)
	add_child(tela)

# ==========================================
# UTILITÁRIOS (Randomização e Sons)
# ==========================================

func randomizar_pecas():
	# Diferente do jogo de Formas, aqui embaralhamos APENAS as peças lá embaixo.
	# Os slots 1, 2 e 3 devem permanecer estáticos e na ordem correta!
	var pecas_da_fase = [peca_p, peca_m, peca_g]
	var pos_pecas = []
	
	for p in pecas_da_fase: 
		pos_pecas.append(p.global_position)
	
	pos_pecas.shuffle()
	
	for i in range(pecas_da_fase.size()):
		pecas_da_fase[i].global_position = pos_pecas[i]
		# É vital atualizar a posição inicial para o erro fazê-las voltar para o lugar embaralhado
		pecas_da_fase[i].posicao_inicial = pos_pecas[i]

func tocar_som_clique():
	if som_click_forma: som_click_forma.play()

func tocar_som_acerto():
	if som_acerto: som_acerto.play()

func tocar_som_erro():
	if som_erro: som_erro.play()
