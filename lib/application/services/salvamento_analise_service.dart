import 'package:sqflite/sqflite.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../models/dados_salvamento_analise.dart';
import '../models/resultado_salvamento_analise.dart';

/// Serviço de aplicação que coordena o salvamento completo da análise.
///
/// O serviço grava somente metadados, caminhos de arquivos e resultados. Imagem
/// original, máscara automática e máscara final continuam como arquivos locais
/// separados e não são alterados durante o salvamento.
class SalvamentoAnaliseService {
  SalvamentoAnaliseService({BancoDadosLocal? bancoDadosLocal})
    : _bancoDadosLocal = bancoDadosLocal ?? BancoDadosLocal();

  final BancoDadosLocal _bancoDadosLocal;

  /// Salva análise, imagem, máscaras, resultados e metadados em uma transação.
  ///
  /// A análise parcial, sem resultado final validado, também é aceita para que o
  /// pesquisador possa retomar a validação em fase futura.
  Future<ResultadoSalvamentoAnalise> salvarAnalise(
    DadosSalvamentoAnalise dados,
  ) async {
    final agora = DateTime.now();

    try {
      _validarCoerencia(dados);
      final banco = await _bancoDadosLocal.abrir();
      final analisePersistida = _prepararAnaliseParaPersistencia(dados, agora);

      await banco.transaction((transacao) async {
        await transacao.insert(
          'analises',
          AnaliseMapper.paraMapa(analisePersistida),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await transacao.insert(
          'imagens',
          ImagemMapper.paraMapa(dados.imagem),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await transacao.insert(
          'mascaras',
          MascaraMapper.paraMapa(dados.mascaraAutomatica),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await transacao.insert(
          'resultados_analise',
          ResultadoAnaliseMapper.paraMapa(dados.resultadoAutomatico),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final mascaraFinal = dados.mascaraFinal;
        if (mascaraFinal != null) {
          await transacao.insert(
            'mascaras',
            MascaraMapper.paraMapa(mascaraFinal),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        final resultadoFinal = dados.resultadoFinal;
        if (resultadoFinal != null) {
          await transacao.insert(
            'resultados_analise',
            ResultadoAnaliseMapper.paraMapa(resultadoFinal),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        final metadados = dados.metadadosAnalise;
        if (metadados != null) {
          await transacao.insert(
            'metadados_analise',
            MetadadosAnaliseMapper.paraMapa(metadados),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      return ResultadoSalvamentoAnalise(
        sucesso: true,
        analiseId: dados.analise.id,
        mensagem: dados.possuiResultadoFinal
            ? 'Análise salva com resultado final validado.'
            : 'Análise salva sem validação final da máscara.',
        dataSalvamento: agora,
      );
    } on Object catch (erro) {
      return ResultadoSalvamentoAnalise(
        sucesso: false,
        analiseId: dados.analise.id,
        mensagem: 'Não foi possível salvar a análise. Detalhe: $erro',
        dataSalvamento: agora,
      );
    }
  }

  Analise _prepararAnaliseParaPersistencia(
    DadosSalvamentoAnalise dados,
    DateTime dataAtualizacao,
  ) {
    return Analise(
      id: dados.analise.id,
      nome: dados.analise.nome,
      dataCriacao: dados.analise.dataCriacao,
      dataAtualizacao: dataAtualizacao,
      observacoes: dados.analise.observacoes,
      versaoAlgoritmo: dados.analise.versaoAlgoritmo,
      statusValidacao: dados.possuiResultadoFinal,
    );
  }

  void _validarCoerencia(DadosSalvamentoAnalise dados) {
    final analiseId = dados.analise.id;

    _validarAnaliseId(dados.imagem.analiseId, analiseId, 'imagem');
    _validarAnaliseId(
      dados.mascaraAutomatica.analiseId,
      analiseId,
      'máscara automática',
    );
    _validarAnaliseId(
      dados.resultadoAutomatico.analiseId,
      analiseId,
      'resultado automático',
    );

    if (dados.resultadoAutomatico.mascaraId != dados.mascaraAutomatica.id) {
      throw StateError(
        'Resultado automático não está vinculado à máscara automática.',
      );
    }

    final mascaraFinal = dados.mascaraFinal;
    final resultadoFinal = dados.resultadoFinal;
    if ((mascaraFinal == null) != (resultadoFinal == null)) {
      throw StateError(
        'Máscara final e resultado final devem ser salvos juntos.',
      );
    }

    if (mascaraFinal != null && resultadoFinal != null) {
      _validarAnaliseId(mascaraFinal.analiseId, analiseId, 'máscara final');
      _validarAnaliseId(resultadoFinal.analiseId, analiseId, 'resultado final');
      if (resultadoFinal.mascaraId != mascaraFinal.id) {
        throw StateError('Resultado final não está vinculado à máscara final.');
      }
    }

    final metadados = dados.metadadosAnalise;
    if (metadados != null) {
      _validarAnaliseId(metadados.analiseId, analiseId, 'metadados');
    }
  }

  void _validarAnaliseId(String recebido, String esperado, String origem) {
    if (recebido != esperado) {
      throw StateError(
        'O campo analiseId de $origem não corresponde à análise atual.',
      );
    }
  }
}
