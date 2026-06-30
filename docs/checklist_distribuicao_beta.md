# Checklist de Distribuição Beta

Use este checklist antes de enviar o APK para avaliadores externos ou colaboradores.

| Passo | Ação | Resultado esperado |
| --- | --- | --- |
| 1 | Executar `flutter clean`. | Artefatos antigos de build devem ser removidos. |
| 2 | Executar `flutter pub get`. | Dependências devem ser resolvidas sem erro. |
| 3 | Executar `flutter analyze`. | A análise estática deve passar sem problemas. |
| 4 | Executar `flutter test`. | Todos os testes devem passar. |
| 5 | Executar `flutter build apk --release`. | APK release deve ser gerado. |
| 6 | Instalar o APK no celular. | Aplicativo deve abrir sem erro. |
| 7 | Testar importação da galeria. | Imagem deve ser copiada para armazenamento interno sem alterar a original. |
| 8 | Testar captura com câmera. | A análise em andamento deve ser preservada. |
| 9 | Gerar máscara automática. | Máscara PNG separada deve ser criada. |
| 10 | Editar máscara sobreposta. | Imagem original deve aparecer como referência e a edição deve alterar apenas a máscara. |
| 11 | Validar resultado. | Máscara final separada e resultado final devem ser gerados. |
| 12 | Salvar análise. | Dados devem ser gravados no SQLite como caminhos, metadados e resultados. |
| 13 | Reabrir análise salva. | Imagem, máscaras e resultados devem ser exibidos com dados reais. |
| 14 | Exportar CSV. | Arquivo CSV deve ser gerado sem alterar imagem ou máscaras. |
| 15 | Exportar JSON. | Arquivo JSON deve ser gerado sem alterar imagem ou máscaras. |
| 16 | Registrar limitações conhecidas. | Avaliadores devem saber que não há IA, LAI direto nem PDF real. |
