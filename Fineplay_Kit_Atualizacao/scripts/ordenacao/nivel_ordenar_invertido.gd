extends "res://scripts/ordenacao/nivel_ordenacao_base.gd"


func configurar_ordem_obrigatoria() -> void:
	ordem_obrigatoria = [peca_gg, peca_g, peca_m, peca_p]
	_limpar_nulos_da_ordem()


func _mensagem_inicio() -> String:
	return "Minigame de Ordenação 4 peças iniciado: maior para menor."
