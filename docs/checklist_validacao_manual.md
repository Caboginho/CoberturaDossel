# Checklist de Validação Manual

Este checklist orienta a validação funcional do MVP antes dos testes com imagens reais da Fase 12. Durante todos os passos, confirme que a imagem original permanece preservada, que a edição ocorre apenas sobre máscaras e que o aplicativo não promete medição direta de LAI.

| Passo | Ação | Resultado esperado |
| --- | --- | --- |
| 1 | Abrir o aplicativo. | A tela inicial deve exibir o nome Cobertura Dossel, o objetivo do MVP e os limites: sem inteligência artificial, sem LAI direto e sem PDF nesta fase. |
| 2 | Tocar em `Nova análise`. | A tela de criação deve solicitar nome e observações da análise. |
| 3 | Criar uma nova análise e continuar. | O aplicativo deve avançar para a escolha da imagem mantendo os dados da análise em memória. |
| 4 | Tocar em `Importar da galeria`. | O seletor de imagem deve abrir. Se o usuário cancelar, a tela deve informar que a seleção foi cancelada sem travar. |
| 5 | Selecionar uma imagem JPG, JPEG ou PNG da galeria. | A imagem deve ser copiada para o armazenamento interno e exibida como imagem selecionada. |
| 6 | Tocar em `Capturar com câmera`. | A câmera deve abrir quando disponível. Se o usuário cancelar, a tela deve informar o cancelamento sem travar. |
| 7 | Tentar usar formato inválido, quando possível. | O aplicativo deve recusar o formato com mensagem compreensível. |
| 8 | Tocar em `Continuar para processamento`. | A tela de processamento deve receber a imagem e mostrar caminho, formato e dimensões. |
| 9 | Tocar em `Gerar máscara automática`. | Uma máscara automática PNG deve ser gerada em arquivo separado e o resultado automático preliminar deve ser exibido. |
| 10 | Conferir a imagem original após o processamento. | O arquivo original não deve ser alterado, comprimido, pintado ou sobrescrito. |
| 11 | Tocar em `Seguir para análise`. | A tela de análise deve exibir imagem original, máscara automática e resumo do resultado automático. |
| 12 | Alternar os modos de visualização. | Os modos `Imagem original`, `Máscara automática`, `Sobreposição` e `Lado a lado` devem funcionar sem alterar arquivos. |
| 13 | Ajustar a opacidade da máscara. | A sobreposição deve mudar visualmente sem recalcular nem alterar a máscara salva. |
| 14 | Tocar em `Revisar máscara`. | O editor deve abrir usando a máscara automática como base de edição em memória. |
| 15 | Pintar pixels como `Céu` e `Não céu`. | A edição deve modificar apenas a máscara em memória, nunca a imagem original. |
| 16 | Usar `Desfazer` e `Refazer`. | O histórico deve recuperar estados anteriores da máscara editada. |
| 17 | Validar a máscara. | Uma máscara final deve ser salva como novo arquivo separado e o resultado final deve ser calculado. |
| 18 | Conferir resultados. | A tela deve diferenciar resultado automático preliminar e resultado final validado. |
| 19 | Tocar em `Salvar análise`. | A análise deve ser salva no SQLite com caminhos, metadados e resultados, sem blobs de imagem. |
| 20 | Abrir `Análises salvas`. | A análise salva deve aparecer com nome, data, status de validação e percentual de dossel disponível. |
| 21 | Voltar aos resultados e tocar em `Exportar resultado`. | A tela de exportação deve abrir com resumo da análise e opções CSV e JSON. |
| 22 | Selecionar `CSV` e tocar em `Exportar`. | Um arquivo CSV deve ser gerado no diretório de exportações, sem alterar imagem ou máscaras. |
| 23 | Selecionar `JSON` e tocar em `Exportar`. | Um arquivo JSON formatado deve ser gerado no diretório de exportações, sem alterar imagem ou máscaras. |
| 24 | Conferir a opção PDF. | PDF deve aparecer como funcionalidade futura ou desabilitada, sem gerar arquivo. |
| 25 | Encerrar e abrir novamente o aplicativo. | O aplicativo deve abrir sem erros. A reabertura completa de uma análise salva pode permanecer parcial nesta fase. |

## Evidências Sugeridas

- Captura da tela inicial.
- Caminho da imagem original copiada.
- Caminho da máscara automática.
- Caminho da máscara final, quando validada.
- Caminho do CSV exportado.
- Caminho do JSON exportado.
- Registro dos percentuais automático e final.
- Observações sobre falhas, travamentos ou mensagens confusas.
