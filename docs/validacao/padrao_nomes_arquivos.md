# Padrão de Nomes de Arquivos

Use nomes padronizados para facilitar rastreabilidade entre imagem original, análise salva, exportações e evidências.

## Imagens

Padrão sugerido:

```text
CD_GRUPO_NUMERO_ORIGEM.ext
```

Exemplos:

```text
CD_CEU_AZUL_001_CAMPO.jpg
CD_GALHOS_FINOS_003_LICENCIADA.jpg
CD_CEU_CINZA_010_CAMPO.png
```

## Grupos Visuais

Use os seguintes identificadores:

- `CEU_AZUL`
- `CEU_BRANCO_CINZA`
- `CEU_PARCIAL_NUBLADO`
- `VEGETACAO_DENSA`
- `GALHOS_FINOS`
- `FOLHAS_CLARAS`
- `FLORES_FRUTOS_CLAROS`
- `BORDAS_COMPLEXAS`

## Origem

Use origem curta e rastreável:

- `CAMPO`: imagem própria capturada em campo.
- `COLABORADOR`: imagem cedida por colaborador.
- `LICENCIADA`: imagem pública com licença compatível.

## Exportações

Padrão sugerido para registros externos:

```text
EXPORT_CD_GRUPO_NUMERO_FORMATO.ext
```

Exemplos:

```text
EXPORT_CD_CEU_AZUL_001_CSV.csv
EXPORT_CD_CEU_AZUL_001_JSON.json
```

O aplicativo também gera nomes automáticos com identificador da análise e timestamp. Ao preencher a planilha, registre o caminho ou nome gerado.

## Evidências

Padrão sugerido:

```text
EVID_CD_GRUPO_NUMERO_TIPO.ext
```

Exemplos:

```text
EVID_CD_CEU_AZUL_001_TELA_RESULTADO.png
EVID_CD_GALHOS_FINOS_003_MASCARA_FINAL.png
```

Não versione evidências brutas com imagens protegidas por direitos autorais. Use apenas evidências autorizadas ou descrições textuais.
