# Plano de Validação com Imagens Reais

Este plano prepara a Fase 12, dedicada à validação funcional com imagens reais. O objetivo é observar o comportamento da segmentação por regras visuais, medir o esforço de correção manual e registrar diferenças entre resultado automático preliminar e resultado final validado.

## Grupos de Imagens

Use imagens digitais em JPG, JPEG ou PNG, preferencialmente capturadas em diferentes condições de campo.

| Grupo | Objetivo de observação | Risco esperado |
| --- | --- | --- |
| Céu azul | Verificar se pixels azuis são classificados como céu. | Baixo, quando o céu ocupa área clara e uniforme. |
| Céu branco ou cinza | Avaliar céu claro de baixa saturação. | Médio, pois nuvens e áreas claras podem se confundir com folhas ou reflexos. |
| Céu parcialmente nublado | Observar mistura de azul, branco e cinza. | Médio a alto, dependendo do contraste. |
| Vegetação densa | Verificar classificação de copa fechada como não céu. | Baixo a médio, com risco em folhas brilhantes. |
| Galhos finos | Avaliar bordas e estruturas estreitas contra o céu. | Alto, com risco de pixels mistos e bordas mal classificadas. |
| Folhas claras | Observar falso positivo como céu. | Alto, especialmente com folhas iluminadas. |
| Flores ou frutos claros | Observar falso positivo como céu claro. | Alto, especialmente em branco, amarelo ou tons pálidos. |
| Bordas complexas | Avaliar transições entre céu, folhas e galhos. | Alto, pois a heurística não faz refinamento avançado de borda. |

## Campos a Registrar

Use uma planilha ou arquivo CSV externo com os campos abaixo.

| Campo | Descrição |
| --- | --- |
| nome_imagem | Nome do arquivo analisado. |
| origem | Galeria, câmera ou arquivo externo. |
| condicao_ceu | Céu azul, branco, cinza, parcialmente nublado, nublado ou indefinida. |
| tipo_ambiente | Floresta, borda, clareira, área urbana ou outro. |
| percentual_automatico | Percentual de dossel estimado antes da correção manual. |
| percentual_final | Percentual de dossel estimado após validação da máscara. |
| diferenca_percentual | Diferença entre resultado automático e resultado final. |
| tempo_correcao | Tempo aproximado gasto corrigindo a máscara. |
| principais_erros | Erros visuais observados na máscara automática. |
| observacoes | Comentários do pesquisador sobre qualidade, iluminação e limitações. |

## Procedimento

1. Separar imagens em pastas por grupo de condição visual.
2. Executar o fluxo completo do MVP para cada imagem.
3. Exportar CSV ou JSON após cada análise.
4. Registrar o tempo aproximado de correção manual.
5. Comparar o resultado automático preliminar com o resultado final validado.
6. Anotar exemplos de falso céu, falso não céu e bordas problemáticas.
7. Identificar quais grupos precisam de ajuste futuro nos parâmetros de segmentação.

## Critérios de Observação

- A imagem original deve permanecer inalterada.
- A máscara automática deve permanecer separada e não deve ser sobrescrita.
- A máscara final deve ser salva como arquivo separado.
- O resultado automático e o resultado final devem permanecer distinguíveis.
- O sistema deve continuar tratando dossel estimado como cálculo derivado da máscara, sem medir LAI diretamente.
- O sistema não deve usar inteligência artificial nesta validação.

## Saída Esperada da Fase 12

- Conjunto de imagens testadas por grupo.
- Tabela com percentuais automáticos e finais.
- Lista dos principais erros observados.
- Sugestões de ajuste nos parâmetros da heurística.
- Indicação de casos em que a correção manual foi suficiente ou trabalhosa.
