# Cobertura Dossel

Aplicação mobile Flutter/Dart para estimativa semiautomática da cobertura aparente do dossel por imagens digitais. O sistema foi planejado para apoiar pesquisadores em campo, preservando a imagem original, gerando uma máscara separada céu/não céu, permitindo validação humana e calculando percentuais a partir da máscara validada.

## Escopo do MVP

Fluxo futuro previsto para o MVP completo:

1. Criar análise.
2. Importar ou capturar imagem.
3. Gerar máscara automática céu/não céu por regras visuais.
4. Revisar e corrigir a máscara.
5. Calcular céu visível e dossel estimado.
6. Salvar localmente.
7. Exportar resultados básicos.

Regras centrais:

- A imagem original nunca deve ser alterada.
- Edições ocorrem apenas sobre uma máscara separada.
- O sistema diferencia resultado automático e resultado final.
- O resultado final depende da máscara validada pelo pesquisador.
- O MVP não implementa inteligência artificial.
- O MVP não promete medição direta de LAI.
- Céu visível (%) = pixels de céu / pixels válidos * 100.
- Dossel estimado (%) = 100 - céu visível (%).

## Padrão de escrita

- Documentação, comentários, descrições de testes e mensagens internas devem usar português brasileiro claro.
- Nomes de arquivos, classes, métodos, variáveis, atributos, constantes, enums, tabelas e campos devem usar português sem acentos.
- Classes usam `PascalCase`, como `Analise` e `ResultadoAnalise`.
- Variáveis, atributos e métodos usam `camelCase`, como `percentualCeu` e `calcularPixelsValidos`.
- Tabelas e campos de banco usam minúsculas com underline, como `analises`, `resultados_analise` e `percentual_ceu`.

## Fases

- Fase 0 - Preparação do ambiente: projeto Flutter criado, estrutura em camadas e documentação inicial.
- Fase 1 - Estrutura de domínio: entidades, enumerações, serviço de cálculo e testes unitários.
- Fase 2 - Banco local e persistência: SQLite, mapeadores, repositórios e organização de diretórios locais.
- Fase 3 - Interface inicial e navegação.
- Fase 4 - Importação e captura de imagem: galeria, câmera, validação de formato e cópia preservada para armazenamento interno.
- Fase 5 - Segmentação automática inicial por regras visuais: classificador céu/não céu, máscara automática separada e resultado automático preliminar.
- Fase 6 - Visualização da imagem original e da máscara automática, com modos de comparação e sobreposição.
- Fase 7 - Editor manual mínimo da máscara, com pintura, desfazer/refazer e validação final.
- Fase 8 - Consolidação do cálculo e da apresentação dos resultados.
- Fase 9 - Salvamento completo da análise no SQLite e listagem de análises salvas.
- Fase 10 - Exportação básica em CSV e JSON.
- Fase 11 - Testes e validação funcional.
- Fase 12 - Validação com imagens.

## Arquitetura

Estrutura inicial em camadas:

```text
lib/
  presentation/
  application/
  domain/
    entities/
    enums/
    services/
  data/
    database/
    mappers/
    repositories/
  infrastructure/
    image/
    storage/
  presentation/
    app/
    pages/
    routes/
    widgets/
test/
  domain/
  data/
  presentation/
```

A Fase 2 concentra persistência local em `lib/data` e organização de arquivos em `lib/infrastructure/storage`. Não há telas, câmera, galeria, editor de máscara, segmentação de imagem ou exportação real nesta fase.

A Fase 3 cria a interface inicial e a navegação básica em `lib/presentation`. As telas são navegáveis e apresentam placeholders claros para câmera, galeria, segmentação real, editor real de máscara, salvamento completo e exportação real, que continuam reservados para fases posteriores.

A Fase 4 conecta a tela de escolha de imagem aos serviços de entrada por galeria e câmera. A imagem selecionada ou capturada é validada, copiada para o armazenamento interno e registrada como caminho de arquivo. A imagem original não é comprimida, redimensionada, pintada ou alterada.

A Fase 5 implementa a segmentação automática inicial por regras visuais. O processamento lê a imagem original preservada, gera uma máscara automática em arquivo PNG separado e calcula um resultado automático preliminar. A visualização com sobreposição foi iniciada na Fase 6, a correção manual mínima foi iniciada na Fase 7 e a apresentação dos resultados foi consolidada na Fase 8.

## Persistência Local

Dependências principais:

- `sqflite`: banco SQLite local.
- `path`: montagem segura de caminhos.
- `path_provider`: diretórios internos do aplicativo.
- `sqflite_common_ffi`: suporte de SQLite em memória para testes automatizados.

Banco local:

- Nome: `cobertura_dossel.db`.
- Classe gerenciadora: `BancoDadosLocal`.
- Versão inicial: `1`.

Tabelas criadas:

- `analises`
- `imagens`
- `mascaras`
- `resultados_analise`
- `metadados_analise`
- `edicoes_mascara`
- `exportacoes`
- `itens_dataset_treinamento`

As imagens originais continuam sendo tratadas apenas como caminhos de arquivo. O banco não armazena bytes de imagem e nenhuma regra de persistência altera a imagem original.

## Interface Inicial

Telas criadas na Fase 3:

- `TelaInicialPage`
- `NovaAnalisePage`
- `EscolherImagemPage`
- `ProcessamentoPage`
- `AnalisePage`
- `EditorMascaraPage`
- `ResultadosPage`
- `AnalisesSalvasPage`
- `ExportacaoPage`

A interface reforça que o resultado automático é preliminar, que o resultado final depende da máscara validada pelo pesquisador e que a imagem original não deve ser alterada. Câmera, galeria, segmentação inicial, editor mínimo, salvamento local e exportação básica em CSV/JSON já foram conectados ao fluxo do MVP.

## Entrada de Imagem

Dependência principal da Fase 4:

- `image_picker`: abertura da galeria e câmera do dispositivo.
- `image`: decodificação da imagem original preservada e geração da máscara automática PNG.

Serviços criados:

- `EntradaImagemService`: abstração para importar da galeria ou capturar com câmera, facilitando testes com fakes.
- `ImagePickerEntradaImagemService`: implementação baseada no plugin `image_picker`.
- `ImagemService`: valida JPG, JPEG e PNG, copia a imagem para o diretório interno de imagens originais e cria a entidade `Imagem`.

Cuidados mantidos:

- A imagem não é armazenada como blob no SQLite.
- O banco deve guardar apenas metadados e caminho do arquivo.
- A imagem original é copiada para armazenamento interno e não é alterada.
- Segmentação automática inicial e geração de máscara foram iniciadas na Fase 5.

## Segmentação Automática Inicial

A Fase 5 adiciona um classificador heurístico céu/não céu:

- Céu azul: canal azul dominante, brilho suficiente e diferença relevante em relação ao vermelho e ao verde.
- Céu claro ou nublado: pixel muito claro e com baixa saturação aproximada.
- Demais casos: não céu.

Serviços criados:

- `ParametrosSegmentacao`: concentra limiares ajustáveis da heurística.
- `ClassificadorCeuNaoCeuService`: classifica pixels RGB como `ceu` ou `naoCeu`.
- `ProcessamentoImagemService`: decodifica a imagem original, gera máscara automática separada, conta pixels e calcula resultado automático preliminar.

Cuidados mantidos:

- A segmentação não usa inteligência artificial, TensorFlow ou modelo treinado.
- O resultado automático é preliminar e ainda não validado.
- A imagem original não é alterada.
- A máscara automática é salva como arquivo PNG separado.
- Pixels individuais não são armazenados no SQLite.
- A correção manual mínima foi iniciada na Fase 7.

## Visualização da Máscara

A Fase 6 adiciona a visualização da imagem original preservada e da máscara automática gerada na Fase 5. A tela de análise permite alternar entre:

- `Imagem original`
- `Máscara automática`
- `Sobreposição`
- `Lado a lado`

Na sobreposição, a opacidade da máscara pode ser ajustada para apoiar a inspeção visual preliminar. A tela também apresenta o resumo do resultado automático com céu visível, dossel estimado, pixels de céu, pixels de não céu e caminho do arquivo da máscara.

Cuidados mantidos:

- A imagem original é apenas lida para visualização e nunca é alterada.
- A máscara automática continua em arquivo separado.
- O resultado automático é apresentado como inicial e ainda não validado.
- A revisão real da máscara foi iniciada na Fase 7 com um editor manual mínimo.
- Não há inteligência artificial, medição direta de LAI ou exportação visual nesta fase.

## Editor Manual da Máscara

A Fase 7 implementa um editor manual mínimo para corrigir a máscara automática. O pesquisador pode selecionar a classe `Céu` ou `Não céu`, escolher a ferramenta `Pincel` ou `Borracha`, ajustar o tamanho do pincel, pintar a máscara por toque ou arraste, usar zoom com navegação e acionar `Desfazer` ou `Refazer`.

Comportamento implementado:

- A edição ocorre somente sobre uma cópia em memória da máscara automática.
- A imagem original é usada apenas como referência visual e nunca é alterada.
- A máscara automática não é sobrescrita.
- Ao validar, a máscara final é salva como novo arquivo PNG separado.
- O resultado final é recalculado a partir da máscara validada pelo pesquisador.
- A tela de resultados diferencia resultado automático preliminar e resultado final validado.

Serviços criados:

- `FerramentaEdicaoService`: carrega a máscara, aplica pincel/borracha, conta pixels, salva a máscara final e calcula o resultado final.
- `HistoricoEdicaoService`: mantém pilhas simples de estados para desfazer e refazer com limite de memória.
- `AcaoEdicaoMascara`: registra a intenção da edição manual para facilitar testes e evolução futura.

Limitações da Fase 7:

- A persistência em SQLite da máscara final e do resultado final ainda não foi conectada ao fluxo da tela.
- A edição é funcional e mínima, sem ferramentas avançadas de seleção, preenchimento, atalhos ou ajustes finos de borda.
- A exportação básica em CSV/JSON foi implementada na Fase 10; PDF e relatórios avançados continuam reservados para evolução posterior.

## Resultados da Análise

A Fase 8 consolida o cálculo e a apresentação dos resultados. O sistema agora usa um serviço de aplicação para criar resultado automático, criar resultado final, calcular diferença percentual e montar um resumo de apresentação para a tela de resultados.

Serviços e modelos adicionados:

- `ResultadoAnaliseService`: centraliza a criação de resultados e delega as fórmulas ao `CalculoDosselService`.
- `ResumoResultadoAnalise`: agrupa imagem original, máscara automática, máscara final, resultado automático, resultado final, diferença percentual e mensagem de status.

Comportamento implementado:

- A `ResultadosPage` deixa de usar valores simulados quando recebe dados reais.
- O resultado automático preliminar e o resultado final validado são exibidos separadamente.
- Quando ainda não existe resultado final, a tela informa: `Resultado final ainda não validado pelo pesquisador.`
- Quando existe resultado final, a tela informa: `O resultado final foi calculado a partir da máscara validada pelo pesquisador.`
- A diferença percentual é calculada entre resultado automático e resultado final.
- A tela mostra percentuais de céu visível e dossel estimado, pixels de céu e não céu, caminho da imagem original, caminho da máscara automática e caminho da máscara final quando existir.

Cuidados mantidos:

- A imagem original não é alterada.
- A máscara automática não é sobrescrita.
- A máscara final permanece como arquivo separado.
- O sistema calcula céu visível e dossel estimado; não mede LAI diretamente.
- A persistência completa da análise, imagem, máscaras e resultados no SQLite fica reservada para a Fase 9.

## Salvamento da Análise

A Fase 9 implementa o salvamento completo da análise no SQLite. O fluxo passa a preservar a entidade `Analise` desde a tela inicial, associando imagem original, máscara automática, resultado automático, máscara final quando existir e resultado final validado.

Serviços e modelos adicionados:

- `DadosSalvamentoAnalise`: organiza análise, imagem, máscaras, resultados e metadados para persistência.
- `ResultadoSalvamentoAnalise`: informa sucesso, mensagem, identificador da análise e data do salvamento.
- `SalvamentoAnaliseService`: salva a análise completa em transação SQLite.
- `ConsultaAnaliseService`: lista análises salvas e busca dados associados por `analiseId`.
- `ResumoAnaliseSalva`: resume análise, imagem, máscaras e resultados para a lista.

Comportamento implementado:

- O botão `Salvar análise` grava dados reais no SQLite quando a tela de resultados recebe uma análise criada no fluxo.
- Análises sem validação final podem ser salvas com resultado automático preliminar.
- Análises com máscara final são salvas com `statusValidacao` verdadeiro.
- A tela `Análises salvas` consulta o banco e lista nome, data de atualização, status de validação e percentual de dossel disponível.
- A reabertura completa da análise salva fica preparada, mas ainda não implementada.

Cuidados mantidos:

- Imagens e máscaras são mantidas como arquivos locais separados.
- O banco armazena metadados, caminhos de arquivos e resultados, nunca blobs de imagem.
- Pixels individuais não são armazenados no SQLite.
- A imagem original não é alterada.
- A máscara automática não é sobrescrita.
- A máscara final permanece em arquivo separado.
- O sistema continua calculando céu visível e dossel estimado, sem medir LAI diretamente.

## Exportação de Resultados

A Fase 10 implementa a exportação básica dos resultados da análise em CSV e JSON. A tela `ExportacaoPage` permite selecionar o formato, revisar um resumo da análise e gerar um arquivo no diretório interno de exportações.

Serviços e modelos adicionados:

- `DadosExportacaoAnalise`: organiza análise, imagem, máscaras, resultados, metadados e formato escolhido.
- `ResultadoExportacao`: informa sucesso, formato, caminho do arquivo, mensagem e data de exportação.
- `ExportacaoService`: gera conteúdo CSV, gera JSON formatado, salva o arquivo exportado e registra a exportação quando a análise já existe no SQLite.

Comportamento implementado:

- O CSV usa cabeçalho simples, sem acentos, compatível com planilhas e scripts.
- O JSON organiza os dados em `analise`, `imagem`, `mascaraAutomatica`, `mascaraFinal`, `resultadoAutomatico`, `resultadoFinal`, `metadados` e `exportacao`.
- O botão `Exportar resultado` na tela de resultados encaminha os dados reais da análise atual para a tela de exportação.
- Arquivos CSV e JSON são gerados como novos arquivos no diretório `exportacoes`.
- PDF aparece apenas como funcionalidade futura e ainda não é gerado.

Cuidados mantidos:

- A exportação não altera a imagem original.
- A exportação não sobrescreve a máscara automática.
- A exportação não sobrescreve a máscara final validada.
- O banco e os arquivos exportados continuam armazenando caminhos, metadados e resultados, nunca blobs de imagem nem pixels individuais.
- Os arquivos exportados servem para análise posterior em planilhas ou scripts.

Limitações conhecidas:

- A heurística pode errar em folhas claras, flores claras, céu nublado, reflexos e bordas complexas.
- O resultado não mede LAI diretamente nem representa cobertura real absoluta do dossel.
- Imagens muito grandes podem exigir otimizações futuras, sempre preservando a imagem original.
- A reabertura completa de uma análise salva, a exportação PDF real e uma tela de histórico de exportações ficam para fases posteriores.

## Comandos

Instalar dependências:

```bash
flutter pub get
```

Executar análise estática:

```bash
flutter analyze
```

Executar testes:

```bash
flutter test
```

Executar o aplicativo base:

```bash
flutter run
```
