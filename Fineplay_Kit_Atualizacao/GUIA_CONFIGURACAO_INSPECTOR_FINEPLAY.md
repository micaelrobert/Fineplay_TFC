# Guia de substituição e configuração — FINEPLAY

## 1. Como substituir os arquivos

1. Feche a Godot antes de copiar os arquivos.
2. Faça uma cópia de segurança da pasta atual `scripts`.
3. Extraia o ZIP entregue e substitua a pasta `scripts` inteira do projeto.
4. Abra o projeto na Godot e aguarde a reimportação/varredura dos scripts.
5. Não anexe manualmente os dois scripts-base novos a nenhuma cena:
   - `scripts/ligue_os_pontos/nivel_ligar_base.gd`
   - `scripts/ordenacao/nivel_ordenacao_base.gd`

Os scripts que já estão anexados às cenas herdam automaticamente dessas classes-base.

## 2. Ajuste manual recomendado no Inspector

Embora o novo código detecte e corrija este problema em tempo de execução, corrija também o Inspector para manter a cena tecnicamente consistente.

### Cena
`scenes/hora_de_organizar/NivelOrdenarInvertido.tscn`

### Nó
Selecione o nó raiz `NivelOrdenarInvertido`.

### Campo incorreto
`Slot Pequeno Path`

### Valor atual incorreto
`AreaJogo/Pecas/Peca_Pequena`

### Valor correto
`AreaJogo/Slots/Slot_1`

Os demais campos devem permanecer:

- `Slot Medio Path`: `AreaJogo/Slots/Slot_2`
- `Slot Grande Path`: `AreaJogo/Slots/Slot_3`
- `Slot Gigante Path`: `AreaJogo/Slots/Slot_4`

## 3. Configurações que já podem permanecer como estão

Não é necessário refazer os sinais no Inspector. As conexões das peças de classificação são realizadas por código durante a inicialização da fase.

Também podem permanecer as referências atuais de:

- `HintManager > Area Jogo Path`;
- `HintManager > Camada Linhas Path`;
- `HintManager > Robo Path`;
- `FeedbackAudio > Sons Locais Path`;
- `LineRenderer > Camada Linhas Path`;
- caminhos de próxima fase;
- quantidade de objetivos das fases de ligação;
- nomes dos slots configurados nas peças.

## 4. Novas opções que aparecerão no Inspector

### ObjetoArrastavel

- `Manter Deslocamento do Toque`: recomendado `Ativado`.
- `Escala Durante Arraste`: recomendado `1.20`.

A escala visual original de cada peça agora é preservada. O valor `1.20` funciona como multiplicador da escala original e não substitui o tamanho definido na cena.

### ObjetoOrdenacao

- `Manter Deslocamento do Toque`: recomendado `Ativado`.

### HintManager

- `Limpar Pista ao Interagir`: recomendado `Ativado`.
- `Tempo Pista 1`: `8` segundos.
- `Tempo Pista 2`: `15` segundos.
- `Tempo Pista 3`: `25` segundos.

O temporizador agora representa inatividade real: cliques, toques, tentativas e arrastes reiniciam a contagem. Durante um arraste ativo, o sistema de pistas fica pausado.

### FeedbackAudio

- `Intervalo Minimo Voz Erro`: recomendado `0.8` segundo.
- `Recuperar Streams Ausentes`: recomendado `Ativado`.
- `Pasta Vozes Vitoria`: `res://assets/voices`.
- `Pasta Vozes Erro`: `res://assets/voices/voice_error`.

A recuperação automática só preenche players que estiverem sem stream. Áudios já configurados não são substituídos.

### ProfessorRobo

Novos parâmetros opcionais:

- `Escala Dica`: recomendado `1.08`.
- `Inclinacao Dica Graus`: recomendado `4`.

## 5. Sinais e métodos

Nenhum sinal precisa ser conectado manualmente.

O código passa a conectar automaticamente, quando disponíveis:

- `peca_encaixada`;
- `peca_clicada`;
- `peca_errou`;
- `arraste_iniciado`;
- `arraste_finalizado`.

O `ProfessorRobo` agora possui os métodos utilizados pelo `HintManager`:

- `pensar()`;
- `dar_dica()`;
- `apontar()`;
- além dos métodos já existentes de acerto, erro e vitória.

## 6. Teste rápido após a substituição

Execute cada fase e verifique:

1. peça arrastada pelo mouse acompanha o cursor sem alterar permanentemente seu tamanho;
2. peça arrastada por toque acompanha o dedo;
3. ao soltar fora do slot, retorna sem voz de erro;
4. ao soltar no slot errado, retorna com feedback de erro;
5. as pistas não aparecem enquanto a criança está arrastando;
6. após alguns segundos sem interação, origem, destino e linha de dica aparecem progressivamente;
7. na ordenação invertida, a pista da peça pequena aponta para `Slot_1`;
8. ligação funciona por arraste e por dois cliques/toques;
9. sequência numérica aceita apenas sucessores imediatos;
10. vitória abre a tela final uma única vez.

## 7. Observação sobre os arquivos de voz

O código agora tenta recuperar automaticamente streams ausentes usando as pastas de voz. Mesmo assim, a solução definitiva recomendada é renomear os arquivos de áudio no projeto com nomes simples, sem aspas curvas ou caracteres especiais, e reassociá-los no Inspector em uma revisão futura.
