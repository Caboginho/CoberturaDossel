import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../models/dados_exportacao_analise.dart';
import '../models/resultado_exportacao.dart';

/// Serviço responsável por exportar resultados de análise em arquivos externos.
///
/// A exportação usa apenas dados já calculados e caminhos persistidos ou em
/// memória. Ela não altera a imagem original, a máscara automática nem a máscara
/// final validada pelo pesquisador.
class ExportacaoService {
  ExportacaoService({
    ArquivoService? arquivoService,
    BancoDadosLocal? bancoDadosLocal,
    bool registrarExportacaoNoBanco = true,
  }) : _arquivoService = arquivoService ?? ArquivoService(),
       _bancoDadosLocal = registrarExportacaoNoBanco
           ? (bancoDadosLocal ?? BancoDadosLocal())
           : null;

  final ArquivoService _arquivoService;
  final BancoDadosLocal? _bancoDadosLocal;

  static const List<String> cabecalhoCsv = [
    'analise_id',
    'nome_analise',
    'data_criacao',
    'data_atualizacao',
    'status_validacao',
    'caminho_imagem_original',
    'caminho_mascara_automatica',
    'caminho_mascara_final',
    'pixels_ceu_automatico',
    'pixels_nao_ceu_automatico',
    'percentual_ceu_automatico',
    'percentual_dossel_automatico',
    'pixels_ceu_final',
    'pixels_nao_ceu_final',
    'percentual_ceu_final',
    'percentual_dossel_final',
    'diferenca_percentual',
    'observacoes',
    'local_descricao',
    'condicao_ceu',
    'tipo_ambiente',
  ];

  /// Exporta a análise no formato escolhido e retorna o caminho do arquivo.
  ///
  /// CSV e JSON são suportados nesta fase. PDF permanece como evolução futura.
  Future<ResultadoExportacao> exportarAnalise(
    DadosExportacaoAnalise dados,
  ) async {
    final dataExportacao = DateTime.now();

    try {
      _validarDadosEssenciais(dados);

      if (dados.formatoExportacao == FormatoExportacao.pdf) {
        return ResultadoExportacao(
          sucesso: false,
          formato: dados.formatoExportacao,
          mensagem: 'Exportação PDF ficará para evolução posterior.',
          dataExportacao: dataExportacao,
        );
      }

      final caminho = await _gerarCaminhoArquivo(dados, dataExportacao);
      final conteudo = dados.formatoExportacao == FormatoExportacao.csv
          ? gerarConteudoCsv(dados)
          : gerarConteudoJson(dados, dataExportacao: dataExportacao);

      await File(caminho).writeAsString(conteudo);
      await _registrarExportacaoQuandoPossivel(dados, caminho, dataExportacao);

      return ResultadoExportacao(
        sucesso: true,
        formato: dados.formatoExportacao,
        caminhoArquivo: caminho,
        mensagem:
            'Exportação ${dados.formatoExportacao.name.toUpperCase()} gerada em $caminho',
        dataExportacao: dataExportacao,
      );
    } on Object catch (erro) {
      return ResultadoExportacao(
        sucesso: false,
        formato: dados.formatoExportacao,
        mensagem: 'Não foi possível exportar a análise. Detalhe: $erro',
        dataExportacao: dataExportacao,
      );
    }
  }

  /// Gera CSV simples, compativel com planilhas.
  ///
  /// O conteúdo diferencia resultado automático e resultado final. Campos sem
  /// dado, como máscara final ainda não validada, ficam vazios.
  String gerarConteudoCsv(DadosExportacaoAnalise dados) {
    _validarDadosEssenciais(dados);

    final resultadoFinal = dados.resultadoFinal;
    final mascaraFinal = dados.mascaraFinal;
    final metadados = dados.metadadosAnalise;
    final linha = [
      dados.analise.id,
      dados.analise.nome,
      dados.analise.dataCriacao.toIso8601String(),
      dados.analise.dataAtualizacao.toIso8601String(),
      dados.analise.statusValidacao.toString(),
      dados.imagem.caminhoArquivo,
      dados.mascaraAutomatica.caminhoArquivo,
      mascaraFinal?.caminhoArquivo ?? '',
      dados.resultadoAutomatico.pixelsCeu.toString(),
      dados.resultadoAutomatico.pixelsNaoCeu.toString(),
      _formatarNumero(dados.resultadoAutomatico.percentualCeu),
      _formatarNumero(dados.resultadoAutomatico.percentualDossel),
      resultadoFinal?.pixelsCeu.toString() ?? '',
      resultadoFinal?.pixelsNaoCeu.toString() ?? '',
      resultadoFinal == null
          ? ''
          : _formatarNumero(resultadoFinal.percentualCeu),
      resultadoFinal == null
          ? ''
          : _formatarNumero(resultadoFinal.percentualDossel),
      _formatarDiferenca(dados),
      dados.analise.observacoes,
      metadados?.localDescricao ?? '',
      metadados?.condicaoCeu.name ?? '',
      metadados?.tipoAmbiente.name ?? '',
    ];

    return '${cabecalhoCsv.join(',')}\n${linha.map(_escaparCsv).join(',')}\n';
  }

  /// Gera JSON organizado para leitura por scripts e ferramentas externas.
  ///
  /// A estrutura preserva a separação entre análise, imagem, máscaras,
  /// resultado automático, resultado final e metadados.
  String gerarConteudoJson(
    DadosExportacaoAnalise dados, {
    DateTime? dataExportacao,
  }) {
    _validarDadosEssenciais(dados);

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(
      _montarMapaJson(dados, dataExportacao ?? DateTime.now()),
    );
  }

  Future<String> _gerarCaminhoArquivo(
    DadosExportacaoAnalise dados,
    DateTime dataExportacao,
  ) {
    if (dados.formatoExportacao == FormatoExportacao.csv) {
      return _arquivoService.gerarCaminhoSeguroExportacaoCsv(
        analiseId: dados.analise.id,
        dataHora: dataExportacao,
      );
    }

    return _arquivoService.gerarCaminhoSeguroExportacaoJson(
      analiseId: dados.analise.id,
      dataHora: dataExportacao,
    );
  }

  Future<void> _registrarExportacaoQuandoPossivel(
    DadosExportacaoAnalise dados,
    String caminhoArquivo,
    DateTime dataExportacao,
  ) async {
    final bancoDadosLocal = _bancoDadosLocal;
    if (bancoDadosLocal == null) {
      return;
    }

    try {
      final banco = await bancoDadosLocal.abrir();
      final analises = await banco.query(
        'analises',
        where: 'id = ?',
        whereArgs: [dados.analise.id],
        limit: 1,
      );
      if (analises.isEmpty) {
        return;
      }

      await banco.insert('exportacoes', {
        'id':
            'exportacao_${dados.analise.id}_${dataExportacao.microsecondsSinceEpoch}',
        'analise_id': dados.analise.id,
        'formato': dados.formatoExportacao.name,
        'caminho_arquivo': caminhoArquivo,
        'data_exportacao': dataExportacao.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);
    } on Object {
      // A exportação em arquivo não deve falhar apenas porque o registro de
      // auditoria ainda não pode ser gravado, por exemplo em análise em memória.
    }
  }

  void _validarDadosEssenciais(DadosExportacaoAnalise dados) {
    if (dados.analise.id.trim().isEmpty) {
      throw StateError('Análise sem identificador para exportação.');
    }
    if (dados.imagem.caminhoArquivo.trim().isEmpty) {
      throw StateError('Imagem original sem caminho para exportação.');
    }
    if (dados.mascaraAutomatica.caminhoArquivo.trim().isEmpty) {
      throw StateError('Máscara automática sem caminho para exportação.');
    }
    if (dados.resultadoAutomatico.mascaraId != dados.mascaraAutomatica.id) {
      throw StateError(
        'Resultado automático não está vinculado à máscara automática.',
      );
    }
    if ((dados.mascaraFinal == null) != (dados.resultadoFinal == null)) {
      throw StateError(
        'Máscara final e resultado final devem ser exportados juntos.',
      );
    }
  }

  String _formatarDiferenca(DadosExportacaoAnalise dados) {
    final diferenca =
        dados.resultadoFinal?.diferencaPercentual ??
        dados.resultadoAutomatico.diferencaPercentual;
    if (diferenca == null) {
      return '';
    }
    return _formatarNumero(diferenca);
  }

  String _formatarNumero(double valor) {
    return valor.toStringAsFixed(2);
  }

  String _escaparCsv(String valor) {
    final escapado = valor.replaceAll('"', '""');
    return '"$escapado"';
  }

  Map<String, Object?> _montarMapaJson(
    DadosExportacaoAnalise dados,
    DateTime dataExportacao,
  ) {
    return {
      'analise': _mapaAnalise(dados.analise),
      'imagem': _mapaImagem(dados.imagem),
      'mascaraAutomatica': _mapaMascara(dados.mascaraAutomatica),
      'mascaraFinal': dados.mascaraFinal == null
          ? null
          : _mapaMascara(dados.mascaraFinal!),
      'resultadoAutomatico': _mapaResultado(dados.resultadoAutomatico),
      'resultadoFinal': dados.resultadoFinal == null
          ? null
          : _mapaResultado(dados.resultadoFinal!),
      'metadados': dados.metadadosAnalise == null
          ? null
          : _mapaMetadados(dados.metadadosAnalise!),
      'exportacao': {
        'formato': dados.formatoExportacao.name,
        'dataExportacao': dataExportacao.toIso8601String(),
        'observacao': 'Arquivo gerado sem alterar imagem original ou máscaras.',
      },
    };
  }

  Map<String, Object?> _mapaAnalise(Analise analise) {
    return {
      'id': analise.id,
      'nome': analise.nome,
      'dataCriacao': analise.dataCriacao.toIso8601String(),
      'dataAtualizacao': analise.dataAtualizacao.toIso8601String(),
      'observacoes': analise.observacoes,
      'versaoAlgoritmo': analise.versaoAlgoritmo,
      'statusValidacao': analise.statusValidacao,
    };
  }

  Map<String, Object?> _mapaImagem(Imagem imagem) {
    return {
      'id': imagem.id,
      'analiseId': imagem.analiseId,
      'caminhoArquivo': imagem.caminhoArquivo,
      'largura': imagem.largura,
      'altura': imagem.altura,
      'formato': imagem.formato,
      'origem': imagem.origem.name,
      'dataCaptura': imagem.dataCaptura?.toIso8601String(),
      'dataImportacao': imagem.dataImportacao?.toIso8601String(),
    };
  }

  Map<String, Object?> _mapaMascara(Mascara mascara) {
    return {
      'id': mascara.id,
      'analiseId': mascara.analiseId,
      'tipo': mascara.tipo.name,
      'caminhoArquivo': mascara.caminhoArquivo,
      'largura': mascara.largura,
      'altura': mascara.altura,
      'pixelsCeu': mascara.pixelsCeu,
      'pixelsNaoCeu': mascara.pixelsNaoCeu,
      'pixelsInvalidos': mascara.pixelsInvalidos,
      'origemMascara': mascara.origemMascara,
      'dataCriacao': mascara.dataCriacao.toIso8601String(),
    };
  }

  Map<String, Object?> _mapaResultado(ResultadoAnalise resultado) {
    return {
      'id': resultado.id,
      'analiseId': resultado.analiseId,
      'mascaraId': resultado.mascaraId,
      'tipoMascara': resultado.tipoMascara.name,
      'pixelsValidos': resultado.pixelsValidos,
      'pixelsCeu': resultado.pixelsCeu,
      'pixelsNaoCeu': resultado.pixelsNaoCeu,
      'percentualCeu': resultado.percentualCeu,
      'percentualDossel': resultado.percentualDossel,
      'diferencaPercentual': resultado.diferencaPercentual,
      'dataCalculo': resultado.dataCalculo.toIso8601String(),
    };
  }

  Map<String, Object?> _mapaMetadados(MetadadosAnalise metadados) {
    return {
      'id': metadados.id,
      'analiseId': metadados.analiseId,
      'localDescricao': metadados.localDescricao,
      'latitude': metadados.latitude,
      'longitude': metadados.longitude,
      'condicaoCeu': metadados.condicaoCeu.name,
      'tipoAmbiente': metadados.tipoAmbiente.name,
      'observacoesCampo': metadados.observacoesCampo,
    };
  }
}
