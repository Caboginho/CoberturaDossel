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
- Fase 6 - Visualização da máscara.
- Fase 7 - Editor manual mínimo.
- Fase 8 - Cálculo de resultados no fluxo da aplicação.
- Fase 9 - Salvamento da análise.
- Fase 10 - Exportação básica.
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

A Fase 5 implementa a segmentação automática inicial por regras visuais. O processamento lê a imagem original preservada, gera uma máscara automática em arquivo PNG separado e calcula um resultado automático preliminar. A visualização com sobreposição e a correção manual ficam para fases posteriores.

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

A interface reforça que o resultado automático é preliminar, que o resultado final depende da máscara validada pelo pesquisador e que a imagem original não deve ser alterada. Câmera e galeria foram conectadas na Fase 4. Segmentação de imagem, editor real de máscara e exportação real ainda não foram implementados.

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
- A visualização com sobreposição e a correção manual serão implementadas em fases futuras.

Limitações conhecidas:

- A heurística pode errar em folhas claras, flores claras, céu nublado, reflexos e bordas complexas.
- O resultado não mede LAI diretamente nem representa cobertura real absoluta do dossel.
- Imagens muito grandes podem exigir otimizações futuras, sempre preservando a imagem original.

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
