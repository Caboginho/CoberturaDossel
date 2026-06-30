# Distribuição Beta do APK

Este documento orienta a distribuição beta manual do Cobertura Dossel para testes em smartphone Android. A versão beta deve ser usada para validação funcional do fluxo em campo, não como ferramenta científica final.

## Objetivo da Versão Beta

Permitir que usuários selecionados testem o fluxo principal do MVP em celulares Android:

1. criar análise;
2. importar ou capturar imagem;
3. gerar máscara automática por regras visuais;
4. revisar a máscara com imagem original sobreposta;
5. validar resultado final;
6. salvar análise localmente;
7. reabrir análise salva;
8. exportar CSV e JSON.

## O Que Já Funciona

- Cadastro simples de análise.
- Importação de imagem da galeria.
- Captura com câmera.
- Tentativa de recuperação de imagem perdida no Android com `retrieveLostData`.
- Preservação dos dados da análise em andamento.
- Geração de máscara automática por regras visuais simples.
- Visualização de imagem original, máscara e sobreposição.
- Editor com modos `Navegar` e `Editar`.
- Edição da máscara com imagem original como referência visual.
- Validação de máscara final em arquivo separado.
- Cálculo de céu visível e dossel estimado.
- Salvamento local em SQLite.
- Reabertura de análise salva.
- Exportação básica em CSV e JSON.

## O Que Não Funciona Nesta Versão

- Inteligência artificial.
- Medição direta de LAI.
- PDF real.
- Sincronização em nuvem.
- Autenticação.
- Estatísticas avançadas.
- Análise em lote.

## Limitações Conhecidas

- A segmentação por regras pode errar em céu nublado, folhas claras, flores claras, reflexos, galhos finos e bordas complexas.
- A edição manual ainda é mínima, sem ferramentas avançadas de seleção ou refinamento de borda.
- Imagens muito grandes podem exigir otimização futura de desempenho.
- A instalação beta é manual e depende das permissões do Android para instalar APK fora da loja.

## Como Gerar o APK

Execute os comandos abaixo na raiz do projeto:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O APK será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Como Instalar Manualmente

1. Copiar o arquivo `app-release.apk` para o smartphone Android.
2. Abrir o arquivo no aparelho.
3. Autorizar a instalação de aplicativos de fonte externa, se o Android solicitar.
4. Concluir a instalação.
5. Abrir o aplicativo `Cobertura Dossel`.

## Permissões Necessárias

- Câmera, para captura de novas imagens.
- Acesso a fotos ou mídia, para importação da galeria.
- Armazenamento interno do aplicativo, usado automaticamente para salvar imagens copiadas, máscaras e exportações.

## Como Testar

1. Criar uma nova análise.
2. Importar imagem da galeria.
3. Capturar imagem com câmera.
4. Gerar máscara automática.
5. Abrir a análise.
6. Revisar a máscara em modo sobreposição.
7. Validar a máscara final.
8. Salvar a análise.
9. Reabrir a análise salva.
10. Exportar CSV e JSON.

## Como Relatar Erro

Ao relatar erro, registre:

- modelo do celular;
- versão do Android;
- etapa do fluxo;
- mensagem exibida;
- se a imagem veio da câmera ou galeria;
- se a análise já estava salva ou era nova;
- captura de tela, quando possível;
- descrição curta do comportamento esperado e observado.

## Checklist Antes de Distribuir

- `flutter analyze` sem problemas.
- `flutter test` passando.
- `flutter build apk --release` concluído.
- APK instalado em pelo menos um smartphone real.
- Galeria testada.
- Câmera testada.
- Editor testado com sobreposição.
- Salvamento e reabertura testados.
- Exportação CSV e JSON testada.
- Limitações explicadas aos avaliadores.
