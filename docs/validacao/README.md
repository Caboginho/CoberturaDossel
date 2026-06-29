# Validação Funcional com Imagens Reais

Esta pasta organiza a validação funcional inicial do MVP do Cobertura Dossel com imagens reais, próprias, fornecidas por colaboradores ou públicas com licença adequada. A validação deve apoiar o TCC e eventuais artigos, registrando evidências, resultados exportados e observações sobre limitações da segmentação por regras visuais.

## Objetivo

Validar o fluxo completo do MVP com imagens reais ou licenciadas:

1. criar análise;
2. importar ou capturar imagem;
3. gerar máscara automática;
4. revisar e corrigir a máscara;
5. validar máscara final;
6. salvar análise;
7. exportar CSV e JSON;
8. registrar resultados e erros observados.

## Escopo

A validação avalia o funcionamento do aplicativo, a clareza do fluxo e a diferença entre resultado automático preliminar e resultado final validado. Ela não mede LAI diretamente, não usa inteligência artificial e não produz PDF real.

## Critérios de Inclusão de Imagens

- Imagens próprias capturadas pelo pesquisador.
- Imagens fornecidas por colaboradores com autorização explícita.
- Imagens públicas com licença compatível e origem registrada.
- Arquivos JPG, JPEG ou PNG.
- Imagens com céu e vegetação em condições variadas.
- Imagens com registro mínimo de origem, condição do céu e grupo visual.

## Critérios de Exclusão de Imagens

- Imagens sem autorização ou licença identificável.
- Imagens com restrição de redistribuição incompatível com o repositório.
- Imagens que exponham pessoas, placas, propriedades privadas ou dados sensíveis sem autorização.
- Imagens em formato não suportado pelo MVP.
- Imagens corrompidas ou impossíveis de abrir no aplicativo.

## Orientação Sobre Direitos Autorais

Não versione imagens reais ou possivelmente protegidas por direitos autorais sem permissão. Guarde imagens reais em uma pasta local ignorada pelo Git, como `docs/validacao/imagens_reais/`, e registre a origem em `modelo_registro_validacao.csv`.

Os arquivos versionados nesta pasta devem ser modelos, protocolos, checklists e exemplos fictícios. Resultados reais só devem ser versionados quando não incluírem material protegido nem dados sensíveis.

## Estrutura

- `modelos/`: modelos de CSV, JSON e tabelas para TCC.
- `resultados/`: local sugerido para resultados consolidados textuais.
- `evidencias/`: local sugerido para evidências selecionadas e autorizadas.
- `imagens_exemplo/`: local para exemplos textuais ou imagens livres devidamente autorizadas.

## Fluxo Resumido de Validação

1. Escolher uma imagem autorizada.
2. Nomear o arquivo seguindo `padrao_nomes_arquivos.md`.
3. Executar o fluxo completo no aplicativo.
4. Registrar resultado automático.
5. Corrigir a máscara e validar o resultado final.
6. Exportar CSV e JSON.
7. Preencher o modelo de registro.
8. Anotar principais erros da segmentação.
9. Consolidar resultados por grupo visual.
