extends Node

class_name FeedbackAudioManager

@export_node_path("Node") var sons_locais_path: NodePath

@export_group("Controle de vozes")
@export_range(0.0, 5.0, 0.1) var intervalo_minimo_voz_erro := 0.8
@export var recuperar_streams_ausentes := true
@export_dir var pasta_vozes_vitoria := "res://assets/voices"
@export_dir var pasta_vozes_erro := "res://assets/voices/voice_error"

@onready var sons_locais: Node = get_node_or_null(sons_locais_path)

var som_click_objeto: Node = null
var som_click_forma: Node = null
var som_acerto: Node = null
var som_erro: Node = null
var som_vitoria: Node = null

var vozes_erro: Array[Node] = []
var vozes_vitoria: Array[Node] = []
var ultimo_indice_erro := -1
var ultimo_indice_vitoria := -1
var ultimo_erro_com_voz_ms := -1000000


func _ready() -> void:
	configurar_referencias()


func configurar_referencias() -> void:
	_resolver_sons_locais()

	if not sons_locais:
		push_warning("FeedbackAudioManager: não foi possível localizar o nó SonsLocais.")
		return

	som_click_objeto = _como_player(sons_locais.get_node_or_null("SomClickObjeto"))
	som_click_forma = _como_player(sons_locais.get_node_or_null("SomClickNaForma"))
	som_acerto = _como_player(sons_locais.get_node_or_null("SomAcerto"))
	som_erro = _como_player(sons_locais.get_node_or_null("SomErro"))
	som_vitoria = _como_player(sons_locais.get_node_or_null("SomVitoria"))

	vozes_erro.clear()
	vozes_vitoria.clear()

	for indice in range(1, 5):
		_adicionar_player_se_existir(vozes_erro, "VozErro%d" % indice)
		_adicionar_player_se_existir(vozes_vitoria, "VozVitoria%d" % indice)

	if recuperar_streams_ausentes:
		_recuperar_streams_da_pasta(vozes_vitoria, pasta_vozes_vitoria, false)
		_recuperar_streams_da_pasta(vozes_erro, pasta_vozes_erro, true)


func _resolver_sons_locais() -> void:
	if sons_locais and is_instance_valid(sons_locais):
		return

	var cena_atual := get_tree().current_scene
	if cena_atual:
		sons_locais = cena_atual.find_child("SonsLocais", true, false)


func _como_player(node: Node) -> Node:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		return node
	return null


func _adicionar_player_se_existir(lista: Array, nome_node: String) -> void:
	if not sons_locais:
		return

	var node := sons_locais.get_node_or_null(nome_node)
	if node and (node is AudioStreamPlayer or node is AudioStreamPlayer2D):
		lista.append(node)


func _recuperar_streams_da_pasta(lista: Array, pasta: String, incluir_subpastas: bool) -> void:
	var players_sem_stream: Array = []
	for player in lista:
		if _obter_stream(player) == null:
			players_sem_stream.append(player)

	if players_sem_stream.is_empty():
		return

	var caminhos := _listar_arquivos_audio(pasta, incluir_subpastas)
	if caminhos.is_empty():
		return

	var indice_arquivo := 0
	for player in players_sem_stream:
		while indice_arquivo < caminhos.size():
			var caminho: String = caminhos[indice_arquivo]
			indice_arquivo += 1
			var stream := load(caminho) as AudioStream
			if stream:
				player.set("stream", stream)
				break


func _listar_arquivos_audio(pasta: String, incluir_subpastas: bool) -> Array[String]:
	var resultado: Array[String] = []
	var dir := DirAccess.open(pasta)
	if not dir:
		return resultado

	dir.list_dir_begin()
	var nome := dir.get_next()
	while not nome.is_empty():
		if nome.begins_with("."):
			nome = dir.get_next()
			continue

		var caminho := pasta.path_join(nome)
		if dir.current_is_dir():
			if incluir_subpastas:
				resultado.append_array(_listar_arquivos_audio(caminho, true))
		elif nome.get_extension().to_lower() in ["mp3", "ogg", "wav"]:
			resultado.append(caminho)

		nome = dir.get_next()

	dir.list_dir_end()
	resultado.sort()
	return resultado


func _obter_stream(audio: Variant) -> AudioStream:
	if not audio or not is_instance_valid(audio):
		return null
	return audio.get("stream") as AudioStream


func tocar_audio(audio: Variant, reiniciar: bool = true) -> void:
	if not audio or not is_instance_valid(audio):
		return
	if not audio.has_method("play"):
		return
	if _obter_stream(audio) == null:
		return

	if reiniciar and audio.has_method("stop"):
		audio.stop()
	audio.play()


func parar_audio(audio: Variant) -> void:
	if audio and is_instance_valid(audio) and audio.has_method("stop"):
		audio.stop()


func audio_esta_tocando(audio: Variant) -> bool:
	if not audio or not is_instance_valid(audio):
		return false
	return bool(audio.get("playing"))


func tocar_click_objeto() -> void:
	tocar_audio(som_click_objeto)


func tocar_click_forma() -> void:
	if som_click_forma and _obter_stream(som_click_forma):
		tocar_audio(som_click_forma)
	else:
		tocar_audio(som_click_objeto)


func tocar_acerto() -> void:
	parar_todas_as_vozes()
	tocar_audio(som_acerto)


func tocar_erro_simples() -> void:
	tocar_audio(som_erro)


func tocar_vitoria_simples() -> void:
	parar_todas_as_vozes()
	tocar_audio(som_vitoria)


func tocar_erro_pedagogico() -> void:
	parar_vozes_vitoria()
	tocar_audio(som_erro)

	var agora := Time.get_ticks_msec()
	if agora - ultimo_erro_com_voz_ms >= int(intervalo_minimo_voz_erro * 1000.0):
		ultimo_erro_com_voz_ms = agora
		tocar_voz_erro_aleatoria()


func tocar_vitoria_pedagogica() -> void:
	parar_todas_as_vozes()
	tocar_audio(som_vitoria)
	tocar_voz_vitoria_aleatoria()


func tocar_voz_erro_aleatoria() -> void:
	ultimo_indice_erro = _tocar_voz_aleatoria(vozes_erro, ultimo_indice_erro)


func tocar_voz_vitoria_aleatoria() -> void:
	ultimo_indice_vitoria = _tocar_voz_aleatoria(vozes_vitoria, ultimo_indice_vitoria)


func _tocar_voz_aleatoria(lista: Array, ultimo_indice: int) -> int:
	var disponiveis: Array = []
	for player in lista:
		if _obter_stream(player):
			disponiveis.append(player)

	if disponiveis.is_empty():
		return -1

	parar_vozes(lista)

	var indice := randi_range(0, disponiveis.size() - 1)
	if disponiveis.size() > 1 and indice == ultimo_indice:
		indice = (indice + 1) % disponiveis.size()

	tocar_audio(disponiveis[indice])
	return indice


func parar_vozes(lista: Array) -> void:
	for voz in lista:
		if audio_esta_tocando(voz):
			parar_audio(voz)


func parar_vozes_erro() -> void:
	parar_vozes(vozes_erro)


func parar_vozes_vitoria() -> void:
	parar_vozes(vozes_vitoria)


func parar_todas_as_vozes() -> void:
	parar_vozes_erro()
	parar_vozes_vitoria()
