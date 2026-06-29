import '../../domain/domain.dart';

/// Resumo usado para listar análises salvas sem carregar uma tela completa.
///
/// A lista apresenta o melhor resultado disponível: final validado quando
/// existir, ou automático preliminar quando a máscara ainda não foi validada.
class ResumoAnaliseSalva {
  const ResumoAnaliseSalva({
    required this.analise,
    this.imagem,
    required this.mascaras,
    required this.resultados,
    this.metadados,
  });

  final Analise analise;
  final Imagem? imagem;
  final List<Mascara> mascaras;
  final List<ResultadoAnalise> resultados;
  final MetadadosAnalise? metadados;

  bool get validada => analise.statusValidacao && resultadoFinal != null;

  ResultadoAnalise? get resultadoFinal {
    return _primeiroResultado(TipoMascara.finalValidada);
  }

  ResultadoAnalise? get resultadoAutomatico {
    return _primeiroResultado(TipoMascara.automatica);
  }

  Mascara? get mascaraFinal {
    return _primeiraMascara(TipoMascara.finalValidada);
  }

  Mascara? get mascaraAutomatica {
    return _primeiraMascara(TipoMascara.automatica);
  }

  ResultadoAnalise? get resultadoParaLista =>
      resultadoFinal ?? resultadoAutomatico;

  double? get percentualDosselExibido => resultadoParaLista?.percentualDossel;

  ResultadoAnalise? _primeiroResultado(TipoMascara tipoMascara) {
    for (final resultado in resultados) {
      if (resultado.tipoMascara == tipoMascara) {
        return resultado;
      }
    }
    return null;
  }

  Mascara? _primeiraMascara(TipoMascara tipoMascara) {
    for (final mascara in mascaras) {
      if (mascara.tipo == tipoMascara) {
        return mascara;
      }
    }
    return null;
  }
}
