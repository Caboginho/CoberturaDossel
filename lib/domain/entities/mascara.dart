import '../enums/tipo_mascara.dart';

/// Representa uma máscara separada da imagem original.
///
/// A máscara concentra a classificação céu/não céu e pode ser automática ou
/// final validada. As edições manuais devem modificar a máscara, nunca a imagem
/// original.
class Mascara {
  const Mascara({
    required this.id,
    required this.analiseId,
    required this.tipo,
    required this.caminhoArquivo,
    required this.largura,
    required this.altura,
    required this.pixelsCeu,
    required this.pixelsNaoCeu,
    this.pixelsInvalidos = 0,
    this.origemMascara = '',
    required this.dataCriacao,
  }) : assert(pixelsCeu >= 0),
       assert(pixelsNaoCeu >= 0),
       assert(pixelsInvalidos >= 0),
       assert(largura >= 0),
       assert(altura >= 0);

  final String id;
  final String analiseId;

  /// Indica se a máscara é automática ou se já representa a versão final.
  final TipoMascara tipo;

  /// Caminho do arquivo da máscara, separado do arquivo da imagem original.
  final String caminhoArquivo;

  final int largura;
  final int altura;
  final int pixelsCeu;
  final int pixelsNaoCeu;
  final int pixelsInvalidos;

  /// Identifica a origem da máscara, por exemplo uma regra visual automática.
  final String origemMascara;

  final DateTime dataCriacao;

  /// Total de pixels que participam do cálculo de céu visível e dossel.
  ///
  /// Pixels inválidos ficam fora do cálculo, conforme a regra de área válida de
  /// análise.
  int get pixelsValidos => pixelsCeu + pixelsNaoCeu;
}
