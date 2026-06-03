extends Node

class_name FeedbackAudioManager

# ============================================================
# FEEDBACK AUDIO MANAGER
# Gerenciador universal de sons e vozes dos minigames.
#
# Responsabilidades:
# - tocar som de clique;
# - tocar som de acerto;
# - tocar som de erro;
# - tocar som de vitória;
# - tocar voz aleatória de erro;
# - tocar voz aleatória de vitória;
# - parar vozes anteriores antes de tocar novas.
#
# Este script NÃO valida regras do jogo.
# Este script NÃO controla input.
# Este script NÃO controla vitória.
# Ele apenas centraliza feedback sonoro.
# ============================================================


# ============================================================
# REFERÊNCIA AO CONTAINER DE SONS
# ============================================================
# Em vez de arrastar áudio por áudio, basta apontar para o nó SonsLocais.
# Exemplo no Inspector:
# sons_locais_path = ../SonsLocais
@export_node_path("Node") var sons_locais_path: NodePath

@onready var sons_locais: Node = get_node_or_null(sons_locais_path)


# ============================================================
# SONS FIXOS
# ============================================================
var som_click_objeto: Node = null
var som_click_forma: Node = null
var som_acerto: Node = null
var som_erro: Node = null
var som_vitoria: Node = null


# ============================================================
# VOZES
# ============================================================
var vozes_erro: Array = []
var vozes_vitoria: Array = []


# ============================================================
# INICIALIZAÇÃO
# ============================================================
func _ready() -> void:
	configurar_referencias()


func configurar_referencias() -> void:
	if not sons_locais:
		push_warning("FeedbackAudioManager: sons_locais_path não foi configurado ou não encontrou o nó SonsLocais.")
		return

	som_click_objeto = sons_locais.get_node_or_null("SomClickObjeto")
	som_click_forma = sons_locais.get_node_or_null("SomClickNaForma")
	som_acerto = sons_locais.get_node_or_null("SomAcerto")
	som_erro = sons_locais.get_node_or_null("SomErro")
	som_vitoria = sons_locais.get_node_or_null("SomVitoria")

	vozes_erro.clear()
	vozes_vitoria.clear()

	adicionar_voz_se_existir(vozes_erro, "VozErro1")
	adicionar_voz_se_existir(vozes_erro, "VozErro2")
	adicionar_voz_se_existir(vozes_erro, "VozErro3")
	adicionar_voz_se_existir(vozes_erro, "VozErro4")

	adicionar_voz_se_existir(vozes_vitoria, "VozVitoria1")
	adicionar_voz_se_existir(vozes_vitoria, "VozVitoria2")
	adicionar_voz_se_existir(vozes_vitoria, "VozVitoria3")
	adicionar_voz_se_existir(vozes_vitoria, "VozVitoria4")


func adicionar_voz_se_existir(lista: Array, nome_node: String) -> void:
	if not sons_locais:
		return

	var voz = sons_locais.get_node_or_null(nome_node)

	if voz:
		lista.append(voz)


# ============================================================
# MÉTODO SEGURO PARA TOCAR ÁUDIO
# ============================================================
func tocar_audio(audio: Node) -> void:
	if not audio:
		return

	if audio.has_method("play"):
		audio.play()


func parar_audio(audio: Node) -> void:
	if not audio:
		return

	if audio.has_method("stop"):
		audio.stop()


func audio_esta_tocando(audio: Node) -> bool:
	if not audio:
		return false

	var valor_playing = audio.get("playing")

	if valor_playing == null:
		return false

	return bool(valor_playing)


# ============================================================
# MÉTODOS PÚBLICOS — SONS SIMPLES
# ============================================================
func tocar_click_objeto() -> void:
	tocar_audio(som_click_objeto)


func tocar_click_forma() -> void:
	if som_click_forma:
		tocar_audio(som_click_forma)
	else:
		tocar_audio(som_click_objeto)


func tocar_acerto() -> void:
	tocar_audio(som_acerto)


func tocar_erro_simples() -> void:
	tocar_audio(som_erro)


func tocar_vitoria_simples() -> void:
	tocar_audio(som_vitoria)


# ============================================================
# MÉTODOS PÚBLICOS — FEEDBACK PEDAGÓGICO
# ============================================================
func tocar_erro_pedagogico() -> void:
	tocar_audio(som_erro)
	tocar_voz_erro_aleatoria()


func tocar_vitoria_pedagogica() -> void:
	tocar_audio(som_vitoria)
	tocar_voz_vitoria_aleatoria()


# ============================================================
# VOZES ALEATÓRIAS
# ============================================================
func tocar_voz_erro_aleatoria() -> void:
	if vozes_erro.is_empty():
		return

	parar_vozes(vozes_erro)

	var voz_escolhida = vozes_erro.pick_random()
	tocar_audio(voz_escolhida)


func tocar_voz_vitoria_aleatoria() -> void:
	if vozes_vitoria.is_empty():
		return

	parar_vozes(vozes_vitoria)

	var voz_escolhida = vozes_vitoria.pick_random()
	tocar_audio(voz_escolhida)


func parar_vozes(lista_vozes: Array) -> void:
	for voz in lista_vozes:
		if audio_esta_tocando(voz):
			parar_audio(voz)


func parar_todas_as_vozes() -> void:
	parar_vozes(vozes_erro)
	parar_vozes(vozes_vitoria)
