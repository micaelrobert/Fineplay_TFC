# Textos para atualização do TCC — FINEPLAY

Este arquivo não altera o `.docx`. Ele indica exatamente onde substituir ou acrescentar textos após a atualização dos scripts.

## Orientação geral

Use apenas as alterações correspondentes à versão realmente entregue e testada. Não declare que os nove níveis foram novamente validados por usuários caso tenha sido feito somente teste técnico pelo autor. Os resultados da avaliação com dez adultos devem continuar vinculados à versão que eles efetivamente utilizaram.

---

# 1. Alterações obrigatórias nos requisitos

## 1.1. Quadro 1 — Requisitos funcionais

### RF11 — substituir a descrição atual

**Local:** seção `3.2.1. Requisitos Funcionais`, linha do requisito `RF11`.

**Substituir por:**

> O sistema deve permitir que o usuário inicie uma conexão em um ponto de origem e arraste a linha até o ponto de destino, utilizando mouse ou interação por toque em dispositivos compatíveis.

### RF12 — substituir a descrição atual

**Local:** seção `3.2.1. Requisitos Funcionais`, linha do requisito `RF12`.

**Substituir por:**

> O sistema deve permitir que o usuário selecione um ponto de origem e, em seguida, selecione o ponto de destino por um segundo clique ou toque, sem a necessidade de manter o ponteiro pressionado durante todo o movimento.

### RF22 — substituir a descrição atual

**Local:** seção `3.2.1. Requisitos Funcionais`, linha do requisito `RF22`.

**Substituir por:**

> O sistema deve apresentar pistas visuais progressivas quando transcorrer determinado período sem interação relevante do usuário, reiniciando a contagem após cliques, toques, tentativas ou arrastes e suspendendo-a durante uma ação de arraste em andamento.

### RF23 — substituir a descrição atual

**Local:** seção `3.2.1. Requisitos Funcionais`, linha do requisito `RF23`.

**Substituir por:**

> O sistema deve alterar o comportamento visual do ProfessorRobo conforme os estados de repouso, reflexão, apresentação de dica, indicação de alvo, acerto, erro e vitória.

## 1.2. Quadro 2 — Requisitos não funcionais

### RNF09 — substituir a descrição atual

**Local:** seção `3.2.2. Requisitos Não Funcionais`, linha do requisito `RNF09`.

**Substituir por:**

> O código deve separar responsabilidades entre objetos interativos, controladores-base dos minijogos, controladores específicos de fase e componentes auxiliares, reduzindo duplicação e facilitando manutenção e expansão.

### RNF10 — substituir a descrição atual

**Local:** seção `3.2.2. Requisitos Não Funcionais`, linha do requisito `RNF10`.

**Substituir por:**

> Sistemas como HintManager, FeedbackAudio, LineRenderer, tela de vitória, botão de retorno e controladores-base devem ser reutilizáveis em diferentes fases do jogo.

### RNF13 — substituir a descrição atual

**Local:** seção `3.2.2. Requisitos Não Funcionais`, linha do requisito `RNF13`.

**Substituir por:**

> O jogo deve permitir interações simples por mouse ou toque, incluindo selecionar, arrastar, soltar e conectar elementos, reduzindo barreiras motoras e operacionais dentro do escopo do MVP.

---

# 2. Metodologia e tecnologias

## 2.1. Seção 3.3 — Processo de Desenvolvimento de Software

**Local:** ao final da `Etapa 4 — Refatoração modular e estabilização`, depois do parágrafo que cita HintManager, FeedbackAudio e LineRenderer.

**Acrescentar:**

> Na etapa final de estabilização, também foram introduzidos controladores-base para os módulos de ligação e ordenação. O arquivo `nivel_ligar_base.gd` passou a concentrar o tratamento de entradas por mouse e toque, a criação e finalização das conexões, a contagem de acertos e o fluxo de vitória. De forma semelhante, o arquivo `nivel_ordenacao_base.gd` passou a centralizar a resolução das peças e dos slots, o controle da ordem obrigatória, a integração com o sistema de pistas e a conclusão dos níveis. Os scripts específicos de cada fase permaneceram responsáveis apenas pelas regras que diferenciam uma atividade da outra, como a estratégia de validação ou a sequência esperada.

## 2.2. Seção 3.4.1 — Godot Engine 4.x

**Local:** primeiro parágrafo da seção `3.4.1. Godot Engine 4.x`.

**Substituir o início “A Godot Engine foi utilizada...” por:**

> A Godot Engine foi utilizada como motor principal de desenvolvimento do jogo. A versão final do projeto foi organizada para a linha 4.x da engine e consolidada na versão 4.6.2. A escolha justifica-se por se tratar de uma ferramenta de código aberto, sob licença MIT, que permite a criação de jogos 2D e 3D sem custos de licenciamento e organiza o desenvolvimento por meio de cenas e nós reutilizáveis.

**Também atualizar na lista de referências:**

Substituir a referência da documentação 4.3 por uma referência correspondente à versão efetivamente utilizada no projeto. Antes da entrega final, confirme no editor em `Ajuda > Sobre` ou no arquivo `project.godot` qual versão deve constar no documento.

## 2.3. Seção 3.4.2 — GDScript

**Local:** depois do último parágrafo da seção `3.4.2. GDScript`.

**Acrescentar:**

> A versão refatorada passou a empregar herança entre scripts para centralizar comportamentos comuns. Os controladores específicos de ligação e ordenação estendem classes-base, preservando nas cenas os mesmos campos exportados utilizados no Inspector. Essa estratégia reduziu a repetição de código sem exigir reconstrução da hierarquia visual das fases.

---

# 3. Arquitetura do software

## 3.1. Seção 4.1 — Arquitetura do Software

**Local:** substituir o segundo e o terceiro parágrafos da seção, iniciados por “Inicialmente, os minigames concentravam...” e “A estrutura final adota...”.

**Novo texto:**

> Inicialmente, os minijogos concentravam em seus scripts principais responsabilidades como controle de entrada, validação, áudio, pistas, feedback e vitória. Durante a evolução do projeto, foi realizada uma refatoração para separar essas responsabilidades e reduzir duplicações. Além dos componentes auxiliares de áudio, pistas e linhas, foram criados controladores-base para os módulos de ligação e ordenação, mantendo nos scripts específicos apenas as regras que variam entre os níveis.
>
> A estrutura final distingue objetos interativos, controladores de fase, controladores-base e serviços auxiliares. Os objetos interativos tratam ações locais, como selecionar, arrastar, soltar e armazenar seu estado. Os controladores-base coordenam entrada, validação comum, contagem de acertos e conclusão. Os scripts específicos definem sequências ou estratégias particulares de cada nível. Por fim, HintManager, FeedbackAudio, LineRenderer e ProfessorRobo fornecem pistas, áudio, desenho vetorial e feedback visual. Essa organização aumenta a coesão, reduz repetição e facilita a inclusão de novos níveis.

## 3.2. Seção 4.1.2 — Gerenciamento de Estado e Sinais

**Local:** depois do parágrafo que começa com “Nos minijogos de arrastar e soltar...”.

**Acrescentar:**

> Os objetos arrastáveis também emitem eventos de início e término de arraste. Esses eventos permitem suspender temporariamente o contador de pistas enquanto o jogador está executando uma ação e retomá-lo após a soltura. Cliques, toques, tentativas e movimentos válidos são registrados como interação, evitando que uma pista seja exibida enquanto o usuário está ativamente manipulando uma peça.

**Local:** depois do parágrafo que começa com “Nos minijogos de ligar pontos...”.

**Acrescentar:**

> O controlador de ligação mantém ainda o identificador do ponteiro ativo, distinguindo mouse e toque. Esse estado impede que eventos duplicados, incluindo o mouse emulado após um toque, iniciem duas interações simultâneas. A mesma lógica permite concluir ou cancelar uma linha mesmo quando a liberação do ponteiro ocorre fora da área de colisão do ponto original.

## 3.3. Seção 4.1.3 — Managers e Componentes Reutilizáveis

**Local:** substituir o último parágrafo da seção.

**Novo texto:**

> A adoção desses elementos auxiliares, combinada aos controladores-base `nivel_ligar_base.gd` e `nivel_ordenacao_base.gd`, permitiu separar responsabilidades dentro do software. Os scripts concretos de cada fase passaram a concentrar apenas configurações ou regras específicas, enquanto entrada, estados compartilhados, pistas, áudio, renderização e conclusão são tratados por componentes reutilizáveis. Essa organização fortalece a manutenibilidade e reduz a duplicação entre fases pertencentes ao mesmo módulo.

## 3.4. Nova subseção 4.1.4 — Controladores-base e redução de duplicação

**Local:** inserir depois da seção `4.1.3. Managers e Componentes Reutilizáveis` e antes da seção `4.2`.

**Título:**

> 4.1.4. Controladores-base dos minijogos

**Texto:**

> Os módulos de ligação e ordenação compartilham grande parte de seu fluxo operacional entre níveis. Para evitar que cada fase mantivesse uma cópia própria dessa lógica, foram criados dois controladores-base. O `nivel_ligar_base.gd` centraliza entrada por mouse e toque, abertura e cancelamento de linhas, consulta dos pontos, atualização do estado das conexões, contagem de objetivos e apresentação da tela de vitória. Os níveis de pares e de sequência numérica estendem esse controlador e especializam somente a regra de validação e a forma de randomização necessária.
>
> O `nivel_ordenacao_base.gd` centraliza a resolução das referências de peças e slots, o bloqueio de elementos fora da ordem, a integração com o HintManager, os retornos de acerto e erro e a conclusão da fase. Cada nível derivado informa apenas a sequência esperada, como pequena–média–grande ou gigante–grande–média–pequena. Os campos exportados foram mantidos para preservar as referências já configuradas nas cenas.
>
> Essa aplicação de herança não elimina a independência visual das cenas. Cada nível continua possuindo seus próprios elementos, posições e recursos, mas reutiliza um fluxo técnico comum. A medida reduz pontos de manutenção e diminui o risco de uma correção ser aplicada em uma fase e esquecida em outra.

---

# 4. Minijogo 1 — Classificação

## 4.1. Seção 4.3.1 — Mecânica de Arrastar e Soltar

**Local:** substituir os três parágrafos da seção `4.3.1`.

**Novo texto:**

> A mecânica de arrastar e soltar foi implementada com nós do tipo Area2D, responsáveis por detectar entrada e sobreposição entre peças e slots. A versão atual trata explicitamente eventos de mouse e de toque. Ao pressionar uma peça, o objeto registra qual ponteiro iniciou a ação, armazena o deslocamento entre o ponto pressionado e o centro da peça, pausa temporariamente o sistema de pistas e eleva sua prioridade visual. Durante o movimento, a peça acompanha o mesmo ponteiro, evitando saltos para o centro e conflitos entre toque e mouse emulado.
>
> Ao liberar a peça, inclusive quando o ponteiro já se encontra fora da área de colisão original, o sistema consulta as áreas sobrepostas e verifica se existe um slot válido. Essa solução amplia a tolerância ao erro motor, pois o usuário não precisa posicionar a peça em um ponto exato. Quando a associação está correta, a peça é ajustada à posição final, bloqueada e sinalizada ao controlador da fase. Quando a associação está incorreta, retorna à posição inicial por Tween e o sistema fornece feedback de erro.
>
> A escala original configurada para cada peça é preservada. O aumento visual usado durante o arraste funciona como multiplicador temporário e é desfeito ao final da ação, evitando que objetos com tamanhos distintos sejam normalizados indevidamente. Após a soltura, o contador de pistas é retomado e a interação realizada reinicia o tempo de inatividade.

## 4.2. Seção 4.3.2 — Validação, Feedback e Sistema de Pistas

**Local:** substituir o último parágrafo, iniciado por “O HintManager atua como uma camada de mediação”.

**Novo texto:**

> O HintManager atua como uma camada de mediação baseada no tempo sem interação relevante. Cliques, toques, tentativas e arrastes reiniciam a contagem, enquanto um arraste em andamento suspende temporariamente as pistas. Se o usuário permanecer sem agir, o sistema apresenta ajuda em três etapas: destaque da peça de origem, destaque do destino e linha indicativa entre ambos. Uma nova interação remove os destaques e reinicia o processo, preservando o desafio e reduzindo a possibilidade de uma dica aparecer durante a manipulação ativa de um elemento.

---

# 5. Minijogo 2 — Ligue os Pontos

## 5.1. Seção 4.4.1 — Mecânica de Desenho Vetorial

**Local:** substituir os dois primeiros parágrafos da seção.

**Novo texto:**

> A implementação utiliza linhas vetoriais para representar as conexões. Quando o usuário inicia uma interação em um ponto válido, o controlador cria uma linha provisória que acompanha a posição do mouse ou do toque. A entrada é centralizada no controlador-base, que registra o ponteiro ativo, transforma a coordenada da tela em coordenada global da cena e consulta os pontos por meio do espaço físico 2D. Caso a conexão seja aceita, a linha provisória é finalizada e permanece visível; caso contrário, é removida para permitir nova tentativa.
>
> Além do arraste, foi mantido um modo alternativo por duas seleções. O usuário pode clicar ou tocar no ponto de origem, liberar o ponteiro e depois selecionar o destino. Essa alternativa reduz a exigência de manter o botão ou o dedo pressionado durante todo o trajeto. O controle do ponteiro impede que eventos de mouse emulado e toque sejam processados simultaneamente e permite cancelar a linha quando a liberação ocorre fora de um destino válido.

## 5.2. Seção 4.4.2 — Algoritmo de Validação

**Local:** depois do segundo parágrafo, iniciado por “No modo de sequência numérica...”.

**Acrescentar:**

> Os dois modos utilizam o mesmo fluxo técnico e diferem apenas na estratégia de validação. A classe-base verifica as condições comuns, como disponibilidade dos pontos, estado da linha e registro do acerto. O controlador de pares compara os identificadores de correspondência, enquanto o controlador numérico aceita somente o sucessor imediato. Essa separação permite reutilizar a entrada e a renderização sem misturar as regras pedagógicas específicas.

---

# 6. Minijogo 3 — Ordenação

## 6.1. Seção 4.5.1 — Mecânica de Arrastar e Soltar na Ordenação

**Local:** substituir os três primeiros parágrafos da seção.

**Novo texto:**

> O módulo de ordenação reutiliza uma mecânica de arrastar e soltar com suporte explícito a mouse e toque. Cada peça mantém seu identificador, sua posição inicial, o ponteiro responsável pelo arraste e o deslocamento do ponto pressionado. A liberação é processada mesmo quando ocorre fora da área original da peça, permitindo retorno seguro ou validação do slot.
>
> A diferença central em relação ao primeiro minijogo está na sequência obrigatória. O controlador-base consulta a ordem configurada pelo nível e libera somente a peça esperada naquele momento. Caso o usuário tente manipular outro elemento, a ação é bloqueada, um feedback de erro é executado e o HintManager pode destacar a peça correta.
>
> Os três níveis reutilizam o mesmo controlador técnico. O primeiro informa a sequência pequena–média–grande; o segundo acrescenta a peça gigante; e o terceiro fornece a ordem inversa. Dessa forma, a variação pedagógica é definida nos scripts específicos, sem duplicar o fluxo de entrada, validação, pistas, áudio e vitória.

## 6.2. Seção 4.5.2 — Algoritmo de Validação e Ajuste de Encaixe

**Local:** acrescentar depois do último parágrafo.

**Acrescentar:**

> Para aumentar a robustez, o controlador verifica se as referências configuradas correspondem realmente a slots e peças válidos. Quando encontra uma referência incompatível, tenta localizar de forma segura o elemento correspondente na hierarquia da área de jogo e registra um aviso técnico. Esse mecanismo funciona como proteção em tempo de execução, mas não substitui a configuração correta das referências no Inspector.

---

# 7. Sistemas auxiliares

## 7.1. Seção 4.6.1 — FeedbackAudio

**Local:** substituir os dois parágrafos da seção.

**Novo texto:**

> O FeedbackAudio é o componente responsável por centralizar os efeitos de clique, acerto, erro e vitória, além das vozes utilizadas em momentos específicos. O componente prioriza as referências já configuradas na cena e mantém fallback para os nós de SonsLocais quando necessário. Essa centralização reduz repetição e permite alterar o comportamento sonoro sem modificar cada controlador de fase.
>
> A versão atual interrompe uma voz anterior antes de iniciar outra, aplica um intervalo mínimo entre falas de erro e evita a repetição imediata da mesma locução. Também pode procurar recursos de áudio nas pastas configuradas quando um player estiver sem stream, aumentando a tolerância a referências ausentes. Essa recuperação é uma medida de segurança; os recursos devem permanecer corretamente associados no projeto definitivo.

## 7.2. Seção 4.6.2 — HintManager

**Local:** substituir toda a seção.

**Novo texto:**

> O HintManager é responsável pelas pistas progressivas e pelo controle do tempo de inatividade. O componente recebe registros de interação dos minijogos e reinicia sua contagem após cliques, toques, tentativas ou arrastes. Durante uma ação de arraste, o contador pode ser pausado para evitar que uma dica seja apresentada enquanto o usuário está executando a solução.
>
> As pistas são divididas em três etapas configuráveis. A primeira destaca o elemento de origem; a segunda acrescenta o destaque do destino; e a terceira apresenta uma linha indicativa entre os dois. Os destaques preservam as cores e escalas originalmente definidas nas cenas e são removidos quando ocorre nova interação, acerto, conclusão da fase ou reinicialização do sistema.
>
> Nos níveis de ordenação, o manager pode operar com a peça esperada na sequência atual. Nos níveis de classificação e ligação, busca a próxima relação ainda não resolvida. O ProfessorRobo acompanha o processo com estados específicos de pensamento, dica e indicação, sem utilizar a animação de comemoração como substituta de uma orientação.

## 7.3. Seção 4.6.3 — LineRenderer

**Local:** depois do último parágrafo da seção.

**Acrescentar:**

> O componente também valida a existência da camada de linhas antes de desenhar, resolve essa referência de forma segura e verifica a estrutura da linha antes de atualizar seus pontos. Caso o manager visual esteja ausente, o controlador ainda pode executar a validação lógica, registrando um aviso para facilitar o diagnóstico.

## 7.4. Seção 4.6.4 — ProfessorRobo como Feedback Visual

**Local:** substituir o parágrafo da seção.

**Novo texto:**

> O ProfessorRobo funciona como mascote e mediador visual. Além das reações de repouso, acerto, erro e vitória, passou a possuir comportamentos específicos para reflexão, apresentação de dica e indicação de um alvo. O controle das animações utiliza uma identificação interna da ação atual para impedir que uma animação assíncrona antiga substitua um estado mais recente, como uma vitória. Essa diferenciação torna o feedback não verbal mais coerente e evita que uma comemoração seja exibida em um momento de dificuldade.

---

# 8. Experiência do usuário

## 8.1. Seção 5.2 — Feedback como Ferramenta Pedagógica

**Local:** no parágrafo da terceira camada, iniciado por “A terceira camada é representada pelo ProfessorRobo”.

**Substituir por:**

> A terceira camada é representada pelo ProfessorRobo. O personagem reage de forma distinta em repouso, reflexão, dica, indicação de alvo, acerto, erro e vitória. Os estados de dica foram separados das comemorações, evitando mensagens visuais contraditórias. O controle das animações também impede que uma reação antiga interrompa um estado pedagógico ou uma conclusão de fase mais recente.

## 8.2. Seção 5.3 — Sistema de Pistas e Mediação da Aprendizagem

**Local:** substituir toda a seção.

**Novo texto:**

> A versão final do FINEPLAY incorporou um sistema de pistas progressivas por meio do HintManager. O componente mede o tempo sem interação relevante e recebe notificações dos minijogos sempre que o usuário clica, toca, tenta uma ação ou inicia e conclui um arraste. Assim, a contagem é reiniciada quando há participação ativa e permanece suspensa durante a manipulação de uma peça.
>
> Se o período de inatividade atingir os limites configurados, a ajuda é apresentada em três etapas. Primeiro, a peça ou o ponto de origem recebe destaque visual. Em seguida, o destino também é destacado. Por fim, uma linha indicativa mostra a relação entre os dois elementos. Uma nova interação remove a orientação e devolve ao usuário a oportunidade de resolver a tarefa com autonomia.
>
> Nos minijogos de ordenação, o HintManager recebe a peça correspondente à etapa atual da sequência. Nos demais módulos, identifica uma relação ainda não concluída. O ProfessorRobo complementa a orientação com estados próprios de pensamento, dica e indicação. Essa abordagem dialoga com a mediação descrita por Vygotsky, pois oferece apoio gradual sem executar automaticamente a resposta.

## 8.3. Seção 5.4 — Acessibilidade, Carga Cognitiva e Tolerância ao Erro

**Local:** substituir o segundo parágrafo, iniciado por “A tolerância ao erro também é um aspecto central...”.

**Novo texto:**

> A tolerância ao erro também é um aspecto central da experiência. Nos minijogos de arrastar e soltar, o usuário não precisa posicionar uma peça com precisão absoluta; basta sobrepô-la ao slot correspondente. As interações possuem tratamento explícito de mouse e toque, preservam o deslocamento entre o ponto pressionado e a peça e processam a liberação mesmo fora da área original do objeto. Em caso de erro, a peça retorna suavemente à posição inicial. Nos minijogos de ligação, é possível usar arraste ou duas seleções sucessivas, por clique ou toque.

**Local:** ao final da seção `5.4`.

**Acrescentar:**

> Essas medidas representam acessibilidade cognitiva e interacional inicial, dentro do escopo do MVP. O projeto ainda não implementa recursos amplos como leitor de tela, navegação integral por teclado, legendas para todas as vozes, configuração de contraste, alternativa específica para daltonismo ou redução de movimento. Tais recursos permanecem indicados para versões futuras e evitam que o trabalho atribua ao protótipo uma cobertura de acessibilidade maior do que a efetivamente implementada.

---

# 9. Avaliação de usabilidade — nota de transparência

## 9.1. Use este parágrafo somente se as correções foram feitas depois da coleta com os dez adultos

**Local:** final da seção `3.5. Avaliação de Usabilidade com Usuários Adultos Voluntários` e também, de forma resumida, no final da seção `5.5`.

**Texto para a seção 3.5:**

> Após a coleta das respostas, foram realizados ajustes internos de robustez, tratamento de toque, temporização das pistas e refatoração dos controladores. Essas alterações preservaram as mecânicas e o fluxo visual avaliados, mas não foram submetidas a uma nova rodada do mesmo questionário. Portanto, os resultados apresentados correspondem à versão efetivamente utilizada pelos participantes e não devem ser interpretados como avaliação formal de todas as correções posteriores.

**Texto resumido para o final da seção 5.5:**

> Ressalta-se ainda que ajustes técnicos posteriores à coleta não foram submetidos a uma nova rodada do questionário; por isso, as médias apresentadas permanecem vinculadas à versão testada pelos participantes.

**Não inserir esses parágrafos** caso os dez participantes tenham testado novamente a versão final e os dados tenham sido realmente atualizados.

---

# 10. Considerações finais

## 10.1. Seção 6.1 — Conclusões

**Local:** substituir o terceiro e o quarto parágrafos da seção, iniciados por “Do ponto de vista técnico...” e “A refatoração dos minigames...”.

**Novo texto:**

> Do ponto de vista técnico, o FINEPLAY demonstrou a viabilidade da Godot Engine para o desenvolvimento de um jogo educacional 2D organizado por cenas, nós, sinais e scripts em GDScript. A versão final incorporou tratamento explícito de mouse e toque, pistas baseadas em inatividade, feedback visual do ProfessorRobo, centralização de áudio, renderização vetorial de linhas, botão de retorno, responsividade e validações específicas para cada atividade.
>
> A refatoração separou objetos interativos, componentes auxiliares, controladores-base e scripts específicos de fase. Os módulos de ligação e ordenação passaram a reutilizar fluxos comuns por herança, reduzindo duplicação sem modificar a estrutura visual das cenas. Essa organização facilita correções, testes e futuras expansões, embora a versão atual ainda demande validação funcional em diferentes dispositivos, testes automatizados e avaliação pedagógica com o público-alvo.

## 10.2. Seção 6.2 — Limitações do Estudo

**Local:** acrescentar antes do último parágrafo da seção.

**Acrescentar:**

> A acessibilidade implementada também é limitada ao âmbito cognitivo e interacional inicial. O jogo oferece baixa dependência de texto, áreas de interação amplas, tolerância ao encaixe, pistas graduais e operação por mouse ou toque, mas ainda não contempla integralmente tecnologias assistivas, navegação por teclado, legendas, perfis de contraste ou alternativas específicas para usuários com deficiência visual, auditiva ou motora.

## 10.3. Seção 6.3 — Trabalhos Futuros

**Local:** depois do parágrafo sobre melhoria da acessibilidade.

**Acrescentar:**

> Também se recomenda a criação de uma suíte de testes técnicos. Essa suíte pode incluir testes unitários das regras de correspondência e sucessão numérica, testes de integração dos sinais, verificação automática dos NodePaths configurados nas cenas e testes manuais em diferentes resoluções, dispositivos de toque e arquiteturas Android. O registro dessas evidências permitirá demonstrar de forma mais objetiva requisitos de confiabilidade, compatibilidade e desempenho.

---

# 11. Apêndice A — verificação antes da entrega

## 11.1. Seção A.1 — Repositório de código

Antes de manter a afirmação de que o repositório contém “a estrutura completa”, confirme que o material publicado inclui pelo menos:

- `project.godot`;
- pasta `scenes`;
- pasta `scripts`, incluindo os dois controladores-base novos;
- assets utilizados;
- arquivo de licença/créditos dos assets;
- instruções de abertura;
- versão exata da Godot;
- preferencialmente `export_presets.cfg`, sem credenciais ou chaves privadas.

### Texto recomendado para substituir o parágrafo de A.1

> O código-fonte do projeto está versionado em repositório público. Para permitir a reprodução do ambiente, o repositório inclui o arquivo `project.godot`, as cenas, os scripts em GDScript, os recursos necessários, a identificação da versão da Godot e instruções de abertura e execução. Arquivos temporários de importação e credenciais de assinatura não integram o pacote público.

Não use esse texto até confirmar que todos os itens realmente estão disponíveis no repositório.

---

# 12. Texto curto para explicar a refatoração durante a apresentação

> A última refatoração não modificou o desenho das fases. Ela concentrou comportamentos repetidos em dois controladores-base, um para ligação e outro para ordenação. Também corrigiu o temporizador das pistas, adicionou tratamento explícito de toque e criou estados específicos de dica para o ProfessorRobo. Assim, as cenas mantiveram suas configurações visuais, enquanto os scripts ficaram mais reutilizáveis e seguros.

# 13. Resposta curta caso a banca pergunte se as cenas foram alteradas

> Não. A atualização técnica foi aplicada somente aos scripts. A hierarquia, as posições, os elementos visuais e os arquivos `.tscn` foram preservados. Um NodePath incorreto identificado na fase invertida pode ser corrigido manualmente no Inspector, embora o novo controlador possua uma recuperação segura em tempo de execução.
