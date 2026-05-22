extends Node2D

@export_file("*.tscn") var proxima_fase_cena: String
var cena_vitoria = preload("res://scenes/telaVitoria/TelaVitoria.tscn")

# As referências mantêm os nomes padronizados que você escolheu
@onready var peca_p = $Pecas/Peca_Pequena
@onready var peca_m = $Pecas/Peca_Media
@onready var peca_g = $Pecas/Peca_Grande
@onready var peca_gg = $Pecas/Peca_Gigante 

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

func slot_esta_ocupado(slot_verificado, peca_ignorada) -> bool:
	var todas_pecas = [peca_p, peca_m, peca_g, peca_gg] 
	for peca in todas_pecas:
		if peca != peca_ignorada and peca.slot_atual == slot_verificado:
			return true
	return false

func verificar_vitoria():
	var todas_acertaram = peca_p.slot_atual != null and peca_m.slot_atual != null and peca_g.slot_atual != null and peca_gg.slot_atual != null
	
	if todas_acertaram:
		vitoria()

func vitoria():
	print("Vitória! Ordenação 2 concluída.")
	if confetes: confetes.emitting = true
	if som_vitoria: som_vitoria.play()
	if robo and robo.has_method("comemorar"): robo.comemorar()
	
	await get_tree().create_timer(1.0).timeout 
	mostrar_vitoria_padrao()

func mostrar_vitoria_padrao():
	var tela = cena_vitoria.instantiate()
	tela.configurar(proxima_fase_cena)
	add_child(tela)

func randomizar_pecas():
	var pecas_da_fase = [peca_p, peca_m, peca_g, peca_gg]
	var pos_pecas = []
	
	for p in pecas_da_fase: 
		pos_pecas.append(p.global_position)
	
	pos_pecas.shuffle()
	
	for i in range(pecas_da_fase.size()):
		pecas_da_fase[i].global_position = pos_pecas[i]
		pecas_da_fase[i].posicao_inicial = pos_pecas[i]

func tocar_som_clique():
	if som_click_forma: som_click_forma.play()

func tocar_som_acerto():
	if som_acerto: som_acerto.play()

func tocar_som_erro():
	if som_erro: som_erro.play()
