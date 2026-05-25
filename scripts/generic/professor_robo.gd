extends Sprite2D

const POSE_DIR := "res://assets/kenney_toon-characters-1/Robot/PNG/Poses/"

@export var deslocamento_idle_y: float = -5.0
@export var escala_idle: float = 1.025
@export var tempo_idle: float = 0.85

@export var deslocamento_vitoria_y: float = -26.0
@export var escala_acerto: float = 1.12
@export var escala_vitoria: float = 1.22

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

	texture = pose_idle
	iniciar_idle()


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
		return load(caminho)

	print("Pose não encontrada: ", caminho)
	return null


func _set_pose(pose: Texture2D) -> void:
	if pose:
		texture = pose


func _resetar_transformacao() -> void:
	position = posicao_base
	scale = escala_base
	rotation = rotacao_base


func _matar_tweens() -> void:
	if tween_idle:
		tween_idle.kill()
		tween_idle = null

	if tween_acao:
		tween_acao.kill()
		tween_acao = null


# ==========================================
# IDLE REGULAR
# ==========================================
func iniciar_idle() -> void:
	if bloqueado or em_acao:
		return

	if tween_idle:
		tween_idle.kill()
		tween_idle = null

	_resetar_transformacao()

	tween_idle = create_tween()
	tween_idle.set_loops()

	tween_idle.tween_property(
		self,
		"position",
		posicao_base + Vector2(0, deslocamento_idle_y),
		tempo_idle
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_idle.parallel().tween_property(
		self,
		"scale",
		escala_base * escala_idle,
		tempo_idle
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_idle.tween_property(
		self,
		"position",
		posicao_base,
		tempo_idle
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_idle.parallel().tween_property(
		self,
		"scale",
		escala_base,
		tempo_idle
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_animacao_poses_idle()


func _animacao_poses_idle() -> void:
	var token_local := token_animacao

	while is_inside_tree() and not bloqueado:
		if em_acao or token_local != token_animacao:
			return

		_set_pose(pose_idle)
		await get_tree().create_timer(1.8).timeout

		if em_acao or token_local != token_animacao:
			return

		_set_pose(pose_talk)
		await get_tree().create_timer(0.35).timeout

		if em_acao or token_local != token_animacao:
			return

		_set_pose(pose_idle)
		await get_tree().create_timer(1.4).timeout

		if em_acao or token_local != token_animacao:
			return

		if pose_think:
			_set_pose(pose_think)
		else:
			_set_pose(pose_talk)

		await get_tree().create_timer(0.45).timeout


# ==========================================
# ACERTO
# ==========================================
func comemorar() -> void:
	if bloqueado:
		return

	token_animacao += 1
	em_acao = true
	_matar_tweens()
	_resetar_transformacao()

	_set_pose(pose_cheer0)

	tween_acao = create_tween()
	tween_acao.set_parallel(true)

	tween_acao.tween_property(
		self,
		"scale",
		escala_base * escala_acerto,
		0.12
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween_acao.tween_property(
		self,
		"rotation",
		deg_to_rad(5),
		0.12
	)

	await tween_acao.finished

	_set_pose(pose_cheer1)

	tween_acao = create_tween()
	tween_acao.set_parallel(true)

	tween_acao.tween_property(self, "scale", escala_base, 0.14)
	tween_acao.tween_property(self, "rotation", rotacao_base, 0.14)

	await tween_acao.finished

	_set_pose(pose_idle)
	em_acao = false
	iniciar_idle()


# ==========================================
# ERRO
# ==========================================
func errar() -> void:
	if bloqueado:
		return

	token_animacao += 1
	em_acao = true
	_matar_tweens()
	_resetar_transformacao()

	if pose_hurt:
		_set_pose(pose_hurt)
	elif pose_think:
		_set_pose(pose_think)

	tween_acao = create_tween()

	tween_acao.tween_property(self, "position", posicao_base + Vector2(-10, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base + Vector2(10, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base + Vector2(-6, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base + Vector2(6, 0), 0.05)
	tween_acao.tween_property(self, "position", posicao_base, 0.05)

	await tween_acao.finished
	await get_tree().create_timer(0.15).timeout

	_set_pose(pose_idle)
	em_acao = false
	iniciar_idle()


# ==========================================
# VITÓRIA / PASSOU DE FASE
# ==========================================
func vitoria() -> void:
	if bloqueado:
		return

	token_animacao += 1
	em_acao = true
	bloqueado = true

	_matar_tweens()
	_resetar_transformacao()

	_set_pose(pose_show)

	tween_acao = create_tween()
	tween_acao.set_parallel(true)

	tween_acao.tween_property(
		self,
		"scale",
		escala_base * escala_vitoria,
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween_acao.tween_property(
		self,
		"position",
		posicao_base + Vector2(0, deslocamento_vitoria_y),
		0.18
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween_acao.finished

	_set_pose(pose_cheer0)
	await get_tree().create_timer(0.22).timeout

	_set_pose(pose_cheer1)
	await get_tree().create_timer(0.22).timeout

	if pose_jump:
		_set_pose(pose_jump)
	else:
		_set_pose(pose_cheer1)

	tween_acao = create_tween()
	tween_acao.set_parallel(true)

	tween_acao.tween_property(self, "scale", escala_base, 0.16)
	tween_acao.tween_property(self, "position", posicao_base, 0.16)
	tween_acao.tween_property(self, "rotation", rotacao_base, 0.16)

	await tween_acao.finished

	bloqueado = false
	em_acao = false

	_set_pose(pose_idle)
	iniciar_idle()


func passar_fase() -> void:
	vitoria()
