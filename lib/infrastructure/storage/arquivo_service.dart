import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Serviço de infraestrutura para organização dos arquivos locais.
///
/// O serviço cria diretórios e copia arquivos externos para o armazenamento
/// interno. A cópia preserva o arquivo original: não há compressão,
/// redimensionamento, pintura ou alteração de bytes nesta fase.
class ArquivoService {
  ArquivoService({Directory? diretorioBase}) : _diretorioBase = diretorioBase;

  static const String nomeDiretorioRaiz = 'cobertura_dossel';
  static const String nomeDiretorioImagensOriginais = 'imagens_originais';
  static const String nomeDiretorioMascaras = 'mascaras';
  static const String nomeDiretorioExportacoes = 'exportacoes';

  final Directory? _diretorioBase;

  Future<Directory> _obterDiretorioRaiz() async {
    final base = _diretorioBase ?? await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, nomeDiretorioRaiz));
  }

  /// Cria os diretórios internos esperados pelo MVP.
  Future<void> prepararDiretorios() async {
    await obterDiretorioImagensOriginais();
    await obterDiretorioMascaras();
    await obterDiretorioExportacoes();
  }

  /// Retorna o diretório reservado para imagens originais preservadas.
  Future<Directory> obterDiretorioImagensOriginais() {
    return _criarSubdiretorio(nomeDiretorioImagensOriginais);
  }

  /// Retorna o diretório reservado para arquivos de máscara.
  Future<Directory> obterDiretorioMascaras() {
    return _criarSubdiretorio(nomeDiretorioMascaras);
  }

  /// Retorna o diretório reservado para exportações futuras.
  Future<Directory> obterDiretorioExportacoes() {
    return _criarSubdiretorio(nomeDiretorioExportacoes);
  }

  /// Monta um caminho para imagem original, sem criar ou alterar arquivo.
  Future<String> caminhoImagemOriginal(String nomeArquivo) async {
    final diretorio = await obterDiretorioImagensOriginais();
    return p.join(diretorio.path, nomeArquivo);
  }

  /// Gera um caminho interno seguro para armazenar uma cópia da imagem original.
  ///
  /// O nome gerado usa identificador e timestamp para evitar sobrescrita
  /// acidental. A extensão original é preservada em minúsculas.
  Future<String> gerarCaminhoSeguroImagemOriginal(
    String nomeArquivoOriginal, {
    String? id,
    DateTime? dataHora,
  }) async {
    final diretorio = await obterDiretorioImagensOriginais();
    final extensao = p.extension(nomeArquivoOriginal).toLowerCase();
    final nomeSemExtensao = p.basenameWithoutExtension(nomeArquivoOriginal);
    final nomeSeguro = _normalizarNomeArquivo(nomeSemExtensao);
    final marcador = id ?? (dataHora ?? DateTime.now()).microsecondsSinceEpoch;
    final base = '${nomeSeguro}_$marcador$extensao';
    var caminho = p.join(diretorio.path, base);
    var contador = 1;

    while (await File(caminho).exists()) {
      caminho = p.join(
        diretorio.path,
        '${nomeSeguro}_${marcador}_$contador$extensao',
      );
      contador++;
    }

    return caminho;
  }

  /// Copia um arquivo externo para o diretório de imagens originais.
  ///
  /// A origem não é modificada. A cópia resultante será usada pelo aplicativo
  /// como arquivo local preservado para as próximas fases.
  Future<File> copiarArquivoExternoParaImagemOriginal(
    File arquivoExterno, {
    String? id,
    DateTime? dataHora,
  }) async {
    final caminhoDestino = await gerarCaminhoSeguroImagemOriginal(
      p.basename(arquivoExterno.path),
      id: id,
      dataHora: dataHora,
    );

    return arquivoExterno.copy(caminhoDestino);
  }

  /// Monta um caminho futuro para máscara, sem criar ou alterar arquivo.
  Future<String> caminhoMascara(String nomeArquivo) async {
    final diretorio = await obterDiretorioMascaras();
    return p.join(diretorio.path, nomeArquivo);
  }

  /// Gera um caminho seguro para máscara automática em PNG.
  ///
  /// Máscaras ficam em diretório separado das imagens originais. O nome usa id
  /// ou timestamp para evitar sobrescrita acidental.
  Future<String> gerarCaminhoSeguroMascaraAutomatica({
    required String imagemId,
    String? id,
    DateTime? dataHora,
  }) async {
    final diretorio = await obterDiretorioMascaras();
    final marcador = id ?? (dataHora ?? DateTime.now()).microsecondsSinceEpoch;
    final imagemIdSeguro = _normalizarNomeArquivo(imagemId);
    final base = 'mascara_automatica_${imagemIdSeguro}_$marcador.png';
    var caminho = p.join(diretorio.path, base);
    var contador = 1;

    while (await File(caminho).exists()) {
      caminho = p.join(
        diretorio.path,
        'mascara_automatica_${imagemIdSeguro}_${marcador}_$contador.png',
      );
      contador++;
    }

    return caminho;
  }

  /// Gera um caminho seguro para máscara final validada em PNG.
  ///
  /// A máscara final é salva em novo arquivo para preservar tanto a imagem
  /// original quanto a máscara automática preliminar.
  Future<String> gerarCaminhoSeguroMascaraFinal({
    required String imagemId,
    String? id,
    DateTime? dataHora,
  }) async {
    final diretorio = await obterDiretorioMascaras();
    final marcador = id ?? (dataHora ?? DateTime.now()).microsecondsSinceEpoch;
    final imagemIdSeguro = _normalizarNomeArquivo(imagemId);
    final base = 'mascara_final_${imagemIdSeguro}_$marcador.png';
    var caminho = p.join(diretorio.path, base);
    var contador = 1;

    while (await File(caminho).exists()) {
      caminho = p.join(
        diretorio.path,
        'mascara_final_${imagemIdSeguro}_${marcador}_$contador.png',
      );
      contador++;
    }

    return caminho;
  }

  /// Monta um caminho futuro para exportação, sem gerar arquivo exportado.
  Future<String> caminhoExportacao(String nomeArquivo) async {
    final diretorio = await obterDiretorioExportacoes();
    return p.join(diretorio.path, nomeArquivo);
  }

  Future<Directory> _criarSubdiretorio(String nome) async {
    final raiz = await _obterDiretorioRaiz();
    final diretorio = Directory(p.join(raiz.path, nome));
    return diretorio.create(recursive: true);
  }

  String _normalizarNomeArquivo(String nome) {
    final normalizado = nome
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (normalizado.isEmpty) {
      return 'imagem_original';
    }

    return normalizado;
  }
}
