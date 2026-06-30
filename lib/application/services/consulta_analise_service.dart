import '../../data/data.dart';
import '../../domain/domain.dart';
import '../models/dados_analise_reaberta.dart';
import '../models/resumo_analise_salva.dart';

/// Serviço de consulta para análises salvas no SQLite.
///
/// A consulta monta resumos para listagem sem carregar pixels ou bytes de
/// imagem. Arquivos continuam referenciados apenas pelos caminhos persistidos.
class ConsultaAnaliseService {
  ConsultaAnaliseService({
    BancoDadosLocal? bancoDadosLocal,
    AnaliseRepository? analiseRepository,
    ImagemRepository? imagemRepository,
    MascaraRepository? mascaraRepository,
    ResultadoAnaliseRepository? resultadoAnaliseRepository,
    MetadadosAnaliseRepository? metadadosAnaliseRepository,
  }) {
    final banco = bancoDadosLocal ?? BancoDadosLocal();
    _analiseRepository = analiseRepository ?? AnaliseRepository(banco);
    _imagemRepository = imagemRepository ?? ImagemRepository(banco);
    _mascaraRepository = mascaraRepository ?? MascaraRepository(banco);
    _resultadoAnaliseRepository =
        resultadoAnaliseRepository ?? ResultadoAnaliseRepository(banco);
    _metadadosAnaliseRepository =
        metadadosAnaliseRepository ?? MetadadosAnaliseRepository(banco);
  }

  late final AnaliseRepository _analiseRepository;
  late final ImagemRepository _imagemRepository;
  late final MascaraRepository _mascaraRepository;
  late final ResultadoAnaliseRepository _resultadoAnaliseRepository;
  late final MetadadosAnaliseRepository _metadadosAnaliseRepository;

  Future<List<ResumoAnaliseSalva>> listarAnalisesSalvas() async {
    final analises = await _analiseRepository.listarTodos();
    final resumos = <ResumoAnaliseSalva>[];

    for (final analise in analises) {
      resumos.add(await buscarResumoPorId(analise.id));
    }

    return resumos;
  }

  Future<ResumoAnaliseSalva> buscarResumoPorId(String analiseId) async {
    final analise = await _analiseRepository.buscarPorId(analiseId);
    if (analise == null) {
      throw StateError('Análise não encontrada.');
    }

    final imagens = await _imagemRepository.listarPorAnaliseId(analiseId);
    final mascaras = await _mascaraRepository.listarPorAnaliseId(analiseId);
    final resultados = await _resultadoAnaliseRepository.listarPorAnaliseId(
      analiseId,
    );
    final metadados = await _metadadosAnaliseRepository.buscarPorAnaliseId(
      analiseId,
    );

    return ResumoAnaliseSalva(
      analise: analise,
      imagem: imagens.isEmpty ? null : imagens.first,
      mascaras: _ordenarMascaras(mascaras),
      resultados: _ordenarResultados(resultados),
      metadados: metadados,
    );
  }

  /// Busca uma análise salva com os dados essenciais para reabertura do fluxo.
  ///
  /// A consulta retorna entidades e caminhos persistidos, sem carregar bytes da
  /// imagem original ou das máscaras. Isso preserva os arquivos originais e
  /// mantém a reabertura leve para uso em smartphone.
  Future<DadosAnaliseReaberta> buscarAnaliseCompletaPorId(
    String analiseId,
  ) async {
    final resumo = await buscarResumoPorId(analiseId);
    return _criarDadosReabertura(resumo);
  }

  Future<Analise?> buscarAnalisePorId(String analiseId) {
    return _analiseRepository.buscarPorId(analiseId);
  }

  Future<List<Imagem>> buscarImagensPorAnaliseId(String analiseId) {
    return _imagemRepository.listarPorAnaliseId(analiseId);
  }

  Future<List<Mascara>> buscarMascarasPorAnaliseId(String analiseId) {
    return _mascaraRepository.listarPorAnaliseId(analiseId);
  }

  Future<List<ResultadoAnalise>> buscarResultadosPorAnaliseId(
    String analiseId,
  ) {
    return _resultadoAnaliseRepository.listarPorAnaliseId(analiseId);
  }

  DadosAnaliseReaberta _criarDadosReabertura(ResumoAnaliseSalva resumo) {
    final imagem = resumo.imagem;
    final mascaraAutomatica = resumo.mascaraAutomatica;
    final resultadoAutomatico = resumo.resultadoAutomatico;

    if (imagem == null ||
        mascaraAutomatica == null ||
        resultadoAutomatico == null) {
      throw StateError(
        'Análise salva não possui imagem, máscara automática e resultado automático suficientes para reabertura.',
      );
    }

    return DadosAnaliseReaberta(
      analise: resumo.analise,
      imagem: imagem,
      mascaraAutomatica: mascaraAutomatica,
      mascaraFinal: resumo.mascaraFinal,
      resultadoAutomatico: resultadoAutomatico,
      resultadoFinal: resumo.resultadoFinal,
      metadadosAnalise: resumo.metadados,
    );
  }

  List<Mascara> _ordenarMascaras(List<Mascara> mascaras) {
    return [...mascaras]..sort((a, b) {
      if (a.tipo == TipoMascara.finalValidada &&
          b.tipo != TipoMascara.finalValidada) {
        return -1;
      }
      if (b.tipo == TipoMascara.finalValidada &&
          a.tipo != TipoMascara.finalValidada) {
        return 1;
      }
      return b.dataCriacao.compareTo(a.dataCriacao);
    });
  }

  List<ResultadoAnalise> _ordenarResultados(List<ResultadoAnalise> resultados) {
    return [...resultados]..sort((a, b) {
      if (a.tipoMascara == TipoMascara.finalValidada &&
          b.tipoMascara != TipoMascara.finalValidada) {
        return -1;
      }
      if (b.tipoMascara == TipoMascara.finalValidada &&
          a.tipoMascara != TipoMascara.finalValidada) {
        return 1;
      }
      return b.dataCalculo.compareTo(a.dataCalculo);
    });
  }
}
