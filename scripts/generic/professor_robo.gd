extends Sprite2D

const POSE_DIR := "res://assets/kenney_toon-characters-1/Robot/PNG/Poses/"

@export_group("Idle")
@export var deslocamento_idle_y: float = -5.0
@export var escala_idle: float = 1.025
@export var tempo_idle: float = 0.85

@export_group("Feedback")
@export var deslocamento_vitoria_y: float = -26.0
@export var escala_acerto: float = 1.12
@export var escala_vitoria: float = 1.22
@export var escala_dica: float = 1.08
@export var inclinacao_dica_graus: float = 4.0

var pose_idle: Texture2D
var pose_talk: Texture2D
var pose_think: Texture2D
var pose_show: Texture2D
var pose_cheer0: Texture2D
var pose_cheer1: Texture2D
var pose_jump: Texture2D
var pose_hurt: Texture2D

var tween_idle: Tween = null
var tween_acao: Tween = null

var posicao_base := Vector2.ZERO
var escala_base := Vector2.ONE
var rotacao_base := 0.0

var em_acao := false
var bloqueado := false
var token_animacao := 0


func _ready() -> void:
	await get_tree().process_frame

	posicao_base = position
	escala_base = scale
	rotacao_base = rotation

	_carregar_poses()
	_set_pose(pose_idle)
	iniciar_idle()


func _exit_tree() -> void:
	token_animacao += 1
	_matar_tweens()


func _carregar_poses() -> void:
	pose_idle = _carregar_pose("character_robot_idle.png")
	pose_talk = _carregar_pose("character_robot_talk.png")
	pose_think = _carregar_pose("character_robot_think.png")
	pose_show = _carregar_pose("character_robot_show.png")
	pose_cheer0 = _carregar_pose("character_robot_cheer0.png")
	pose_cheer1 = _carregar_pose("character_robot_cheer1.png")
	pose_jump = _carregar_pose("character_robot_jump.png")
	pose_hurt = _carregar_pose("character_robot_hurt.png")


func _carregar_pose(nome_arquivo: String) -> Texture2D:
	var caminho := POSE_DIR + nome_arquivo

	if ResourceLoader.exists(caminho):
		return load(caminho) as Texture2D

	push_warning("ProfessorRobo: pose não encontrada: " + caminho)
	return null


func _set_pose(pose: Texture2D) -> void:
	if pose:
		texture = pose


func _resetar_transformacao() -> void:
	position = posicao_base
	scale = escala_base
	rotation = rotacao_base


func _matar_tweens() -> void:
	if tween_idle and tween_idle.is_valid():
		tween_idle.kill()
	tween_idle = null

	if tween_acao and tween_acao.is_valid():
		tween_acao.kill()
	tween_acao = null


func _iniciar_acao(travar: bool = false) -> int:
	if bloqueado and not travar:
		return -1

	token_animacao += 1
	em_acao = true
	bloqueado = travar
	_matar_tweens()
	_resetar_transformacao()
	return token_animacao


func _acao_valida(token: int) -> bool:
	return is_inside_tree() and token >= 0 and token == token_animacao


func _finalizar_acao(token: int, desbloquear: bool = true) -> void:
	if not _acao_valida(token):
		return

	if desbloquear:
		bloqueado = false

	em_acao = false
	_resetar_transformacao()
	_set_pose(pose_idle)
	iniciar_idle()


# ============================================================
# IDLE
# ============================================================
func iniciar_idle() -> void:
	if bloqueado or em_acao or not is_inside_tree():
		return

	if tween_idle and tween_idle.is_valid():
		tween_idle.kill()

	_resetar_transformacao()

	tween_idle = create_tween().set_loops()
	(
		tween_idle
		. tween_property(
			self, "position", posicao_base + Vector2(0, deslocamento_idle_y), tempo_idle
		)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)
	(
		tween_idle
		. parallel()
		. tween_property(self, "scale", escala_base * escala_idle, tempo_idle)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)
	(
		tween_idle
		. tween_property(self, "position", posicao_base, tempo_idle)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)
	(
		tween_idle
		. parallel()
		. tween_property(self, "scale", escala_base, tempo_idle)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)

	_animacao_poses_idle(token_animacao)


func _animacao_poses_idle(token_inicial: int) -> void:
	while is_inside_tree() and not bloqueado:
		if em_acao or token_inicial != token_animacao:
			return

		_set_pose(pose_idle)
		await get_tree().create_timer(1.8).timeout
		if em_acao or token_inicial != token_animacao:
			return

		_set_pose(pose_talk)
		await get_tree().create_timer(0.35).timeout
		if em_acao or token_inicial != token_animacao:
			return

		_set_pose(pose_idle)
		await get_tree().create_timer(1.4).timeout
		if em_acao or token_inicial != token_animacao:
			return

		_set_pose(pose_think if pose_think else pose_talk)
		await get_tree().create_timer(0.45).timeout


# ============================================================
# ACERTO
# ============================================================
func comemorar() -> void:
	var token := _iniciar_acao()
	if token < 0:
		return

	_set_pose(pose_cheer0)
	tween_acao = create_tween().set_parallel(true)
	(
		tween_acao
		. tween_property(self, "scale", escala_base * escala_acerto, 0.12)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	tween_acao.tween_property(self, "rotation", rotacao_base + deg_to_rad(5.0), 0.12)
	await tween_acao.finished
	if not _acao_valida(token):
		return

	_set_pose(pose_cheer1)
	tween_acao = create_tween().set_parallel(true)
	tween_acao.tween_property(self, "scale", escala_base, 0.14)
	tween_acao.tween_property(self, "rotation", rotacao_base, 0.14)
	await tween_acao.finished

	_finalizar_acao(token)


# ============================================================
# ERRO
# ============================================================
func errar() -> void:
	var token := _iniciar_acao()
	if token < 0:
		return

	_set_pose(pose_hurt if pose_hurt else pose_think)

	tween_acao = create_tween()
	tween_acao.tween_property(self, "position", posicao_base + Vector2(-10, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base + Vector2(10, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base + Vector2(-6, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base + Vector2(6, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base, 0.05)
	await tween_acao.finished
	if not _acao_valida(token):
		return

	await get_tree().create_timer(0.15).timeout
	_finalizar_acao(token)


# ============================================================
# PISTAS — API usada pelo HintManager
# ============================================================
func pensar() -> void:
	var token := _iniciar_acao()
	if token < 0:
		return

	_set_pose(pose_think if pose_think else pose_talk)
	tween_acao = create_tween().set_parallel(true)
	(
		tween_acao
		. tween_property(self, "scale", escala_base * escala_dica, 0.18)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)
	tween_acao.tween_property(
		self, "rotation", rotacao_base - deg_to_rad(inclinacao_dica_graus), 0.18
	)
	await tween_acao.finished
	if not _acao_valida(token):
		return

	await get_tree().create_timer(0.45).timeout
	_finalizar_acao(token)


func dar_dica() -> void:
	var token := _iniciar_acao()
	if token < 0:
		return

	_set_pose(pose_talk if pose_talk else pose_think)
	tween_acao = create_tween()
	(
		tween_acao
		. tween_property(self, "scale", escala_base * escala_dica, 0.16)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	tween_acao.tween_property(self, "scale", escala_base, 0.16)
	await tween_acao.finished
	if not _acao_valida(token):
		return

	_set_pose(pose_think if pose_think else pose_talk)
	await get_tree().create_timer(0.35).timeout
	_finalizar_acao(token)


func apontar() -> void:
	var token := _iniciar_acao()
	if token < 0:
		return

	_set_pose(pose_show if pose_show else pose_talk)
	tween_acao = create_tween().set_parallel(true)
	(
		tween_acao
		. tween_property(self, "scale", escala_base * escala_dica, 0.16)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	tween_acao.tween_property(
		self, "rotation", rotacao_base + deg_to_rad(inclinacao_dica_graus), 0.16
	)
	await tween_acao.finished
	if not _acao_valida(token):
		return

	await get_tree().create_timer(0.55).timeout
	_finalizar_acao(token)


# ============================================================
# VITÓRIA
# ============================================================
func vitoria() -> void:
	var token := _iniciar_acao(true)
	if token < 0:
		return

	_set_pose(pose_show)
	tween_acao = create_tween().set_parallel(true)
	(
		tween_acao
		. tween_property(self, "scale", escala_base * escala_vitoria, 0.18)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	(
		tween_acao
		. tween_property(self, "position", posicao_base + Vector2(0, deslocamento_vitoria_y), 0.18)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	await tween_acao.finished
	if not _acao_valida(token):
		return

	_set_pose(pose_cheer0)
	await get_tree().create_timer(0.22).timeout
	if not _acao_valida(token):
		return

	_set_pose(pose_cheer1)
	await get_tree().create_timer(0.22).timeout
	if not _acao_valida(token):
		return

	_set_pose(pose_jump if pose_jump else pose_cheer1)
	tween_acao = create_tween().set_parallel(true)
	tween_acao.tween_property(self, "scale", escala_base, 0.16)
	tween_acao.tween_property(self, "position", posicao_base, 0.16)
	tween_acao.tween_property(self, "rotation", rotacao_base, 0.16)
	await tween_acao.finished

	_finalizar_acao(token)


func passar_fase() -> void:
	vitoria()
