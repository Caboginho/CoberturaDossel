import 'dart:io';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;

import '../../domain/domain.dart';
import '../../infrastructure/storage/arquivo_service.dart';

typedef LeitorDimensoesImagem =
    Future<({int largura, int altura})> Function(File arquivo);

/// Metadados obtidos durante a preparação da imagem original.
///
/// O tamanho do arquivo fica fora da entidade de domínio atual, mas é útil para
/// mensagens de interface e futuras validações.
class ImagemPreparada {
  const ImagemPreparada({
    required this.imagem,
    required this.nomeArquivo,
    required this.tamanhoBytes,
  });

  final Imagem imagem;
  final String nomeArquivo;
  final int tamanhoBytes;
}

/// Serviço de aplicação para validar e preparar a imagem original.
///
/// A responsabilidade principal é copiar a imagem escolhida para o armazenamento
/// interno e criar a entidade [Imagem]. O serviço não comprime, redimensiona,
/// pinta ou altera o arquivo original.
class ImagemService {
  ImagemService({
    ArquivoService? arquivoService,
    LeitorDimensoesImagem? leitorDimensoes,
  }) : _arquivoService = arquivoService ?? ArquivoService(),
       _leitorDimensoes = leitorDimensoes ?? _obterDimensoesPadrao;

  static const Set<String> extensoesAceitas = {'.jpg', '.jpeg', '.png'};

  final ArquivoService _arquivoService;
  final LeitorDimensoesImagem _leitorDimensoes;

  /// Verifica se o caminho aponta para um formato aceito pelo MVP.
  ///
  /// Inicialmente são aceitos JPG, JPEG e PNG. A validação usa apenas a extensão
  /// do arquivo e não executa segmentação de imagem.
  bool validarFormatoImagem(String caminhoArquivo) {
    final extensao = p.extension(caminhoArquivo).toLowerCase();
    return extensoesAceitas.contains(extensao);
  }

  /// Copia a imagem para o armazenamento interno e cria a entidade [Imagem].
  ///
  /// A imagem externa de origem não é modificada. A entidade criada aponta para
  /// a cópia interna preservada.
  Future<ImagemPreparada> prepararImagemOriginal({
    required File arquivoExterno,
    required OrigemImagem origem,
    required String analiseId,
    String? idImagem,
    DateTime? dataHora,
  }) async {
    if (!validarFormatoImagem(arquivoExterno.path)) {
      throw const FormatException(
        'Formato de imagem inválido. Use JPG, JPEG ou PNG.',
      );
    }

    if (!await arquivoExterno.exists()) {
      throw FileSystemException(
        'Arquivo de imagem não encontrado.',
        arquivoExterno.path,
      );
    }

    final id = idImagem ?? _gerarIdImagem();
    final arquivoCopiado = await _arquivoService
        .copiarArquivoExternoParaImagemOriginal(
          arquivoExterno,
          id: id,
          dataHora: dataHora,
        );
    final dimensoes = await _leitorDimensoes(arquivoCopiado);
    final tamanhoBytes = await arquivoCopiado.length();

    return ImagemPreparada(
      imagem: Imagem(
        id: id,
        analiseId: analiseId,
        caminhoArquivo: arquivoCopiado.path,
        largura: dimensoes.largura,
        altura: dimensoes.altura,
        formato: p.extension(arquivoCopiado.path).replaceFirst('.', ''),
        origem: origem,
        dataCaptura: origem == OrigemImagem.camera
            ? dataHora ?? DateTime.now()
            : null,
        dataImportacao: origem == OrigemImagem.galeria
            ? dataHora ?? DateTime.now()
            : null,
      ),
      nomeArquivo: p.basename(arquivoCopiado.path),
      tamanhoBytes: tamanhoBytes,
    );
  }

  String _gerarIdImagem() {
    return 'imagem_${DateTime.now().microsecondsSinceEpoch}';
  }

  static Future<({int largura, int altura})> _obterDimensoesPadrao(
    File arquivo,
  ) async {
    final bytes = await arquivo.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final imagem = frame.image;
    final largura = imagem.width;
    final altura = imagem.height;
    imagem.dispose();
    codec.dispose();
    return (largura: largura, altura: altura);
  }
}
