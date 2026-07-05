extends "res://scripts/ordenacao/nivel_ordenacao_base.gd"


func configurar_ordem_obrigatoria() -> void:
	ordem_obrigatoria = [peca_p, peca_m, peca_g]
	_limpar_nulos_da_ordem()


func _mensagem_inicio() -> String:
	return "Minigame de Ordenação iniciado: pequena, média e grande."
