/// Serviço de domínio responsável pelos cálculos centrais do Cobertura Dossel.
///
/// Os métodos trabalham somente com contagens e percentuais derivados da
/// máscara. Nenhum cálculo altera a imagem original ou o arquivo da máscara.
class CalculoDosselService {
  const CalculoDosselService();

  /// Calcula a quantidade de pixels válidos da máscara.
  ///
  /// Pixels válidos são os pixels classificados como céu ou não céu. Pixels
  /// inválidos ficam fora do cálculo para respeitar a área válida de análise.
  int calcularPixelsValidos({
    required int pixelsCeu,
    required int pixelsNaoCeu,
  }) {
    _validarContagemPixel(pixelsCeu, 'pixelsCeu');
    _validarContagemPixel(pixelsNaoCeu, 'pixelsNaoCeu');

    return pixelsCeu + pixelsNaoCeu;
  }

  /// Calcula o percentual de céu visível.
  ///
  /// Este método usa a quantidade de pixels classificados como céu e o total de
  /// pixels válidos da máscara. O cálculo não altera a imagem original nem a
  /// máscara.
  double calcularPercentualCeu({
    required int pixelsCeu,
    required int pixelsValidos,
  }) {
    _validarContagemPixel(pixelsCeu, 'pixelsCeu');
    _validarContagemPixel(pixelsValidos, 'pixelsValidos');

    if (pixelsValidos == 0) {
      return 0;
    }

    if (pixelsCeu > pixelsValidos) {
      throw ArgumentError.value(
        pixelsCeu,
        'pixelsCeu',
        'Não pode ser maior que pixelsValidos.',
      );
    }

    return pixelsCeu / pixelsValidos * 100;
  }

  /// Calcula o percentual de dossel estimado.
  ///
  /// O dossel estimado é o complemento do céu visível: 100 - percentual de céu.
  /// O resultado representa estimativa baseada na máscara, não medição direta
  /// de LAI.
  double calcularPercentualDossel({
    required double percentualCeu,
    required int pixelsValidos,
  }) {
    _validarPercentual(percentualCeu, 'percentualCeu');
    _validarContagemPixel(pixelsValidos, 'pixelsValidos');

    if (pixelsValidos == 0) {
      return 0;
    }

    return 100 - percentualCeu;
  }

  /// Calcula a diferença absoluta entre resultado automático e resultado final.
  ///
  /// Essa diferença ajuda a registrar o impacto da validação humana sobre a
  /// máscara automática preliminar.
  double calcularDiferencaPercentual({
    required double percentualAutomatico,
    required double percentualFinal,
  }) {
    _validarPercentual(percentualAutomatico, 'percentualAutomatico');
    _validarPercentual(percentualFinal, 'percentualFinal');

    return (percentualFinal - percentualAutomatico).abs();
  }

  void _validarContagemPixel(int valor, String nome) {
    if (valor < 0) {
      throw ArgumentError.value(valor, nome, 'Não pode ser negativo.');
    }
  }

  void _validarPercentual(double valor, String nome) {
    if (valor < 0 || valor > 100) {
      throw ArgumentError.value(valor, nome, 'Deve estar entre 0 e 100.');
    }
  }
}
