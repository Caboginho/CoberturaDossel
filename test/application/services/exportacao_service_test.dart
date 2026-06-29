import 'dart:convert';
import 'dart:io';

import 'package:cobertura_dossel/application/application.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:cobertura_dossel/infrastructure/infrastructure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory diretorioTemporario;
  late ExportacaoService exportacaoService;

  setUp(() async {
    diretorioTemporario = await Directory.systemTemp.createTemp(
      'cobertura_dossel_exportacao_service_',
    );
    exportacaoService = ExportacaoService(
      arquivoService: ArquivoService(diretorioBase: diretorioTemporario),
      registrarExportacaoNoBanco: false,
    );
  });

  tearDown(() async {
    if (await diretorioTemporario.exists()) {
      await diretorioTemporario.delete(recursive: true);
    }
  });

  test('gera CSV com cabeçalho esperado', () {
    final csv = exportacaoService.gerarConteudoCsv(
      _criarDadosExportacao(possuiFinal: false),
    );

    expect(csv.split('\n').first, ExportacaoService.cabecalhoCsv.join(','));
  });

  test('gera CSV com resultado automático e final', () {
    final csv = exportacaoService.gerarConteudoCsv(
      _criarDadosExportacao(possuiFinal: true),
    );

    expect(csv, contains('"5"'));
    expect(csv, contains('"2"'));
    expect(csv, contains('"50.00"'));
    expect(csv, contains('"80.00"'));
    expect(csv, contains('"30.00"'));
  });

  test('gera CSV quando não houver resultado final', () {
    final csv = exportacaoService.gerarConteudoCsv(
      _criarDadosExportacao(possuiFinal: false),
    );

    expect(csv, contains('"mascara_automatica.png"'));
    expect(csv, isNot(contains('"mascara_final.png"')));
  });

  test('gera JSON válido', () {
    final jsonTexto = exportacaoService.gerarConteudoJson(
      _criarDadosExportacao(possuiFinal: true),
      dataExportacao: DateTime(2026, 6, 29, 13),
    );

    final mapa = jsonDecode(jsonTexto) as Map<String, dynamic>;

    expect(mapa['analise']['id'], 'analise-exportacao');
  });

  test('JSON contém análise, imagem, máscaras e resultados', () {
    final jsonTexto = exportacaoService.gerarConteudoJson(
      _criarDadosExportacao(possuiFinal: true),
    );
    final mapa = jsonDecode(jsonTexto) as Map<String, dynamic>;

    expect(mapa['analise'], isNotNull);
    expect(mapa['imagem'], isNotNull);
    expect(mapa['mascaraAutomatica'], isNotNull);
    expect(mapa['mascaraFinal'], isNotNull);
    expect(mapa['resultadoAutomatico'], isNotNull);
    expect(mapa['resultadoFinal'], isNotNull);
  });

  test('salva arquivo CSV em diretório de exportações', () async {
    final resultado = await exportacaoService.exportarAnalise(
      _criarDadosExportacao(possuiFinal: false),
    );

    expect(resultado.sucesso, isTrue);
    expect(resultado.caminhoArquivo, isNotNull);
    expect(resultado.caminhoArquivo, contains('exportacoes'));
    expect(p.extension(resultado.caminhoArquivo!), '.csv');
    expect(await File(resultado.caminhoArquivo!).exists(), isTrue);
  });

  test('salva arquivo JSON em diretório de exportações', () async {
    final resultado = await exportacaoService.exportarAnalise(
      _criarDadosExportacao(possuiFinal: true, formato: FormatoExportacao.json),
    );

    expect(resultado.sucesso, isTrue);
    expect(resultado.caminhoArquivo, contains('exportacoes'));
    expect(p.extension(resultado.caminhoArquivo!), '.json');
    expect(await File(resultado.caminhoArquivo!).exists(), isTrue);
  });

  test('exportação não altera caminhos da imagem e das máscaras', () async {
    final dados = _criarDadosExportacao(possuiFinal: true);
    final caminhoImagem = dados.imagem.caminhoArquivo;
    final caminhoMascaraAutomatica = dados.mascaraAutomatica.caminhoArquivo;
    final caminhoMascaraFinal = dados.mascaraFinal!.caminhoArquivo;

    await exportacaoService.exportarAnalise(dados);

    expect(dados.imagem.caminhoArquivo, caminhoImagem);
    expect(dados.mascaraAutomatica.caminhoArquivo, caminhoMascaraAutomatica);
    expect(dados.mascaraFinal!.caminhoArquivo, caminhoMascaraFinal);
  });
}

DadosExportacaoAnalise _criarDadosExportacao({
  required bool possuiFinal,
  FormatoExportacao formato = FormatoExportacao.csv,
}) {
  final data = DateTime(2026, 6, 29, 10);
  final analise = Analise(
    id: 'analise-exportacao',
    nome: 'Análise para exportação',
    dataCriacao: data,
    dataAtualizacao: data,
    observacoes: 'Observação de campo.',
    versaoAlgoritmo: 'regras_visuais_mvp',
    statusValidacao: possuiFinal,
  );
  final imagem = Imagem(
    id: 'imagem-exportacao',
    analiseId: analise.id,
    caminhoArquivo: 'imagem_original.png',
    largura: 10,
    altura: 10,
    formato: 'png',
    origem: OrigemImagem.galeria,
    dataImportacao: data,
  );
  final mascaraAutomatica = Mascara(
    id: 'mascara-automatica-exportacao',
    analiseId: analise.id,
    tipo: TipoMascara.automatica,
    caminhoArquivo: 'mascara_automatica.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    origemMascara: 'regras_visuais_mvp',
    dataCriacao: data,
  );
  final resultadoAutomatico = ResultadoAnalise(
    id: 'resultado-automatico-exportacao',
    analiseId: analise.id,
    mascaraId: mascaraAutomatica.id,
    tipoMascara: TipoMascara.automatica,
    pixelsValidos: 10,
    pixelsCeu: 5,
    pixelsNaoCeu: 5,
    percentualCeu: 50,
    percentualDossel: 50,
    dataCalculo: data,
  );
  final metadados = MetadadosAnalise(
    id: 'metadados-exportacao',
    analiseId: analise.id,
    localDescricao: 'Parcela experimental',
    condicaoCeu: CondicaoCeu.parcialmenteNublado,
    tipoAmbiente: TipoAmbiente.floresta,
  );

  if (!possuiFinal) {
    return DadosExportacaoAnalise(
      analise: analise,
      imagem: imagem,
      mascaraAutomatica: mascaraAutomatica,
      resultadoAutomatico: resultadoAutomatico,
      metadadosAnalise: metadados,
      formatoExportacao: formato,
    );
  }

  final mascaraFinal = Mascara(
    id: 'mascara-final-exportacao',
    analiseId: analise.id,
    tipo: TipoMascara.finalValidada,
    caminhoArquivo: 'mascara_final.png',
    largura: 10,
    altura: 10,
    pixelsCeu: 2,
    pixelsNaoCeu: 8,
    dataCriacao: data,
  );
  final resultadoFinal = ResultadoAnalise(
    id: 'resultado-final-exportacao',
    analiseId: analise.id,
    mascaraId: mascaraFinal.id,
    tipoMascara: TipoMascara.finalValidada,
    pixelsValidos: 10,
    pixelsCeu: 2,
    pixelsNaoCeu: 8,
    percentualCeu: 20,
    percentualDossel: 80,
    diferencaPercentual: 30,
    dataCalculo: data,
  );

  return DadosExportacaoAnalise(
    analise: analise,
    imagem: imagem,
    mascaraAutomatica: mascaraAutomatica,
    mascaraFinal: mascaraFinal,
    resultadoAutomatico: resultadoAutomatico,
    resultadoFinal: resultadoFinal,
    metadadosAnalise: metadados,
    formatoExportacao: formato,
  );
}
