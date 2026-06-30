# Checklist de Validação Manual

Este checklist orienta a validação funcional do MVP antes dos testes com imagens reais da Fase 12. Durante todos os passos, confirme que a imagem original permanece preservada, que a edição ocorre apenas sobre máscaras e que o aplicativo não promete medição direta de LAI.

| Passo | Ação | Resultado esperado |
| --- | --- | --- |
| 1 | Abrir o aplicativo. | A tela inicial deve exibir o nome Cobertura Dossel, o objetivo do MVP e os limites: sem inteligência artificial, sem LAI direto e sem PDF nesta fase. |
| 2 | Tocar em `Nova análise`. | A tela de criação deve solicitar nome e observações da análise. |
| 3 | Criar uma nova análise e continuar. | O aplicativo deve avançar para a escolha da imagem mantendo os dados da análise em memória. |
| 4 | Tocar em `Importar da galeria`. | O seletor de imagem deve abrir. Se o usuário cancelar, a tela deve informar que a seleção foi cancelada sem travar. |
| 5 | Selecionar uma imagem JPG, JPEG ou PNG da galeria. | A imagem deve ser copiada para o armazenamento interno e exibida como imagem selecionada. |
| 6 | Tocar em `Capturar com câmera`. | A câmera deve abrir quando disponível. Se o usuário cancelar, a tela deve informar `A captura foi cancelada.` sem travar. |
| 7 | No Moto G15, tirar foto e confirmar na câmera. | A tela `Escolher imagem` deve voltar com o nome da análise preservado, mostrar a imagem selecionada e habilitar `Continuar para processamento`. |
| 8 | Simular retorno do Android após câmera, quando possível. | O aplicativo deve tentar recuperar a foto com `retrieveLostData`, informar `Imagem recuperada após retorno da câmera. Os dados da análise foram preservados.` e não voltar ao cadastro com campos vazios. |
| 9 | Tentar usar formato inválido, quando possível. | O aplicativo deve recusar o formato com mensagem compreensível. |
| 10 | Tocar em `Continuar para processamento`. | A tela de processamento deve receber a imagem e mostrar caminho, formato e dimensões. |
| 11 | Tocar em `Gerar máscara automática`. | Uma máscara automática PNG deve ser gerada em arquivo separado e o resultado automático preliminar deve ser exibido. |
| 12 | Conferir a imagem original após o processamento. | O arquivo original não deve ser alterado, comprimido, pintado ou sobrescrito. |
| 13 | Tocar em `Seguir para análise`. | A tela de análise deve exibir imagem original, máscara automática e resumo do resultado automático. |
| 14 | Alternar os modos de visualização. | Os modos `Imagem original`, `Máscara automática`, `Sobreposição` e `Lado a lado` devem funcionar sem alterar arquivos. |
| 15 | Ajustar a opacidade da máscara. | A sobreposição deve mudar visualmente sem recalcular nem alterar a máscara salva. |
| 16 | Tocar em `Revisar máscara`. | O editor deve abrir usando a máscara automática como base de edição em memória. |
| 17 | No editor, selecionar `Navegar`. | Arrastar deve mover a imagem e pinça deve aplicar zoom. Neste modo, o gesto não deve pintar a máscara. |
| 18 | No editor, selecionar `Editar`. | Toque ou arraste com um dedo deve pintar a máscara sem mover a imagem durante a pintura. |
| 19 | Pintar pixels como `Céu` e `Não céu`. | A edição deve modificar apenas a máscara em memória, nunca a imagem original. |
| 20 | Ajustar o tamanho do pincel e pintar novamente. | A área editada deve respeitar o tamanho escolhido e o feedback visual deve mostrar modo, classe ativa e pincel. |
| 21 | Usar `Desfazer` e `Refazer`. | O histórico deve recuperar estados anteriores da máscara editada. |
| 22 | Validar a máscara. | Uma máscara final deve ser salva como novo arquivo separado e o resultado final deve ser calculado. |
| 23 | Conferir resultados. | A tela deve diferenciar resultado automático preliminar e resultado final validado. |
| 24 | Tocar em `Salvar análise`. | A análise deve ser salva no SQLite com caminhos, metadados e resultados, sem blobs de imagem. |
| 25 | Abrir `Análises salvas`. | A análise salva deve aparecer com nome, data, status de validação e percentual de dossel disponível. |
| 26 | Tocar em uma análise salva. | A análise deve ser reaberta com imagem original, máscara automática, máscara final quando existir e resultados reais. |
| 27 | Na análise reaberta, tocar em `Editar máscara validada` ou `Revisar máscara`. | O editor deve abrir com imagem original e máscara em modo sobreposição. |
| 28 | Voltar aos resultados e tocar em `Exportar resultado`. | A tela de exportação deve abrir com resumo da análise e opções CSV e JSON. |
| 29 | Selecionar `CSV` e tocar em `Exportar`. | Um arquivo CSV deve ser gerado no diretório de exportações, sem alterar imagem ou máscaras. |
| 30 | Selecionar `JSON` e tocar em `Exportar`. | Um arquivo JSON formatado deve ser gerado no diretório de exportações, sem alterar imagem ou máscaras. |
| 31 | Conferir a opção PDF. | PDF deve aparecer como funcionalidade futura ou desabilitada, sem gerar arquivo. |
| 32 | Encerrar e abrir novamente o aplicativo. | O aplicativo deve abrir sem erros e manter a listagem de análises salvas disponível. |

## Evidências Sugeridas

- Captura da tela inicial.
- Caminho da imagem original copiada.
- Caminho da máscara automática.
- Caminho da máscara final, quando validada.
- Caminho do CSV exportado.
- Caminho do JSON exportado.
- Registro dos percentuais automático e final.
- Observações sobre falhas, travamentos ou mensagens confusas.
