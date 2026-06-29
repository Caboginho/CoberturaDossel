# Protocolo de Validação Inicial

## Objetivo

Validar o fluxo funcional do MVP do Cobertura Dossel com imagens reais ou licenciadas, observando a qualidade da máscara automática, o esforço de correção manual e a diferença entre resultado automático preliminar e resultado final validado.

## Materiais Necessários

- Aplicativo Cobertura Dossel instalado ou executando em ambiente de teste.
- Conjunto de imagens JPG, JPEG ou PNG com origem registrada.
- Planilha baseada em `modelos/modelo_registro_validacao.csv`.
- Local seguro para armazenar imagens reais fora do versionamento público.
- Cronômetro simples para medir tempo aproximado de correção.
- Ferramenta de planilha ou editor de texto para conferir CSV/JSON exportados.

## Grupos de Imagens

Use os grupos abaixo para organizar a validação:

- `ceu_azul`
- `ceu_branco_ou_cinza`
- `ceu_parcialmente_nublado`
- `vegetacao_densa`
- `galhos_finos`
- `folhas_claras`
- `flores_ou_frutos_claros`
- `bordas_complexas`

## Número Mínimo Sugerido

Para validação inicial, recomenda-se pelo menos 3 imagens por grupo visual. Quando não houver imagens suficientes, registre a limitação no campo `observacoes`.

## Passos de Execução

1. Selecionar uma imagem autorizada.
2. Confirmar nome do arquivo conforme `padrao_nomes_arquivos.md`.
3. Criar nova análise no aplicativo.
4. Importar ou capturar a imagem.
5. Gerar máscara automática.
6. Registrar percentuais automáticos de céu visível e dossel estimado.
7. Abrir a revisão de máscara.
8. Corrigir erros visíveis da máscara.
9. Validar a máscara final.
10. Registrar percentuais finais.
11. Salvar a análise.
12. Exportar CSV e JSON.
13. Preencher o registro de validação.
14. Anotar os principais erros observados.

## Registro dos Resultados

Use `modelos/modelo_registro_validacao.csv` como base. Cada linha deve representar uma imagem validada. Não invente dados. Quando um valor não puder ser obtido, deixe o campo vazio e explique em `observacoes`.

## Registro de Erros

No campo `principais_erros_segmentacao`, descreva erros como:

- céu classificado como não céu;
- folhas claras classificadas como céu;
- flores ou frutos claros classificados como céu;
- galhos finos perdidos na máscara;
- bordas com mistura de classes;
- reflexos classificados como céu.

## Critérios de Sucesso do MVP

- O aplicativo executa o fluxo completo sem travar.
- A imagem original permanece inalterada.
- A máscara automática é criada em arquivo separado.
- A máscara final é criada em arquivo separado.
- O resultado automático e o resultado final permanecem distintos.
- A análise pode ser salva localmente.
- CSV e JSON podem ser exportados.
- As limitações da heurística ficam registradas para evolução futura.

## Limitações Esperadas

A segmentação por regras visuais pode errar em céu nublado, folhas claras, flores claras, reflexos, galhos finos, bordas complexas e imagens com iluminação irregular. Esses erros são esperados nesta fase e devem ser documentados, não ocultados.
