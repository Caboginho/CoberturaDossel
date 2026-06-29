import 'package:cobertura_dossel/domain/domain.dart';

final DateTime dataBaseTeste = DateTime(2026, 6, 28, 10, 30);

Analise criarAnaliseTeste() {
  return Analise(
    id: 'analise-1',
    nome: 'Parcela A',
    dataCriacao: dataBaseTeste,
    dataAtualizacao: dataBaseTeste,
    observacoes: 'Primeira análise de teste.',
    versaoAlgoritmo: 'regras-visuais-0.1',
    statusValidacao: false,
  );
}

Imagem criarImagemTeste() {
  return Imagem(
    id: 'imagem-1',
    analiseId: 'analise-1',
    caminhoArquivo: '/imagens/original-1.jpg',
    largura: 1200,
    altura: 900,
    formato: 'jpg',
    origem: OrigemImagem.arquivo,
    dataImportacao: dataBaseTeste,
  );
}

Mascara criarMascaraTeste() {
  return Mascara(
    id: 'mascara-1',
    analiseId: 'analise-1',
    tipo: TipoMascara.automatica,
    caminhoArquivo: '/mascaras/mascara-1.png',
    largura: 1200,
    altura: 900,
    pixelsCeu: 450000,
    pixelsNaoCeu: 450000,
    pixelsInvalidos: 0,
    origemMascara: 'regras-visuais',
    dataCriacao: dataBaseTeste,
  );
}

ResultadoAnalise criarResultadoTeste() {
  return ResultadoAnalise(
    id: 'resultado-1',
    analiseId: 'analise-1',
    mascaraId: 'mascara-1',
    tipoMascara: TipoMascara.automatica,
    pixelsValidos: 900000,
    pixelsCeu: 450000,
    pixelsNaoCeu: 450000,
    percentualCeu: 50,
    percentualDossel: 50,
    diferencaPercentual: 0,
    dataCalculo: dataBaseTeste,
  );
}

MetadadosAnalise criarMetadadosTeste() {
  return MetadadosAnalise(
    id: 'metadados-1',
    analiseId: 'analise-1',
    localDescricao: 'Área experimental',
    latitude: -14.798,
    longitude: -39.173,
    condicaoCeu: CondicaoCeu.parcialmenteNublado,
    tipoAmbiente: TipoAmbiente.floresta,
    observacoesCampo: 'Teste de persistência local.',
  );
}

EdicaoMascara criarEdicaoTeste() {
  return EdicaoMascara(
    id: 'edicao-1',
    analiseId: 'analise-1',
    mascaraId: 'mascara-1',
    dataHora: dataBaseTeste,
    ferramenta: TipoFerramenta.pincel,
    classeAplicada: ClassePixel.naoCeu,
    tamanhoPincel: 12,
    descricao: 'Correção manual em borda de copa.',
  );
}

ItemDatasetTreinamento criarItemDatasetTeste() {
  return ItemDatasetTreinamento(
    id: 'dataset-1',
    analiseId: 'analise-1',
    caminhoImagemOriginal: '/imagens/original-1.jpg',
    caminhoMascaraAutomatica: '/mascaras/automatica-1.png',
    caminhoMascaraFinal: '/mascaras/final-1.png',
    versaoAlgoritmo: 'regras-visuais-0.1',
    diferencaPercentual: 4.5,
    autorizado: true,
    dataRegistro: dataBaseTeste,
  );
}
