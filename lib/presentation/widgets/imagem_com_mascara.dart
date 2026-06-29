import 'dart:io';

import 'package:flutter/material.dart';

import 'modo_visualizacao_mascara.dart';

/// Exibe a imagem original e a máscara automática em modos alternáveis.
///
/// Este widget apenas lê arquivos existentes e monta a visualização. Ele não
/// altera a imagem original, não edita a máscara e não executa nova segmentação.
class ImagemComMascara extends StatelessWidget {
  const ImagemComMascara({
    required this.caminhoImagemOriginal,
    required this.caminhoMascaraAutomatica,
    required this.modo,
    this.opacidadeMascara = 0.55,
    super.key,
  });

  static const Key chaveImagemOriginal = Key('imagem_original_visualizacao');
  static const Key chaveMascaraAutomatica = Key(
    'mascara_automatica_visualizacao',
  );
  static const Key chaveSobreposicao = Key('sobreposicao_visualizacao');
  static const Key chaveLadoALado = Key('lado_a_lado_visualizacao');

  final String caminhoImagemOriginal;
  final String caminhoMascaraAutomatica;
  final ModoVisualizacaoMascara modo;
  final double opacidadeMascara;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: switch (modo) {
            ModoVisualizacaoMascara.imagemOriginal => _imagemOriginal(),
            ModoVisualizacaoMascara.mascaraAutomatica => _mascaraAutomatica(),
            ModoVisualizacaoMascara.sobreposicao => _sobreposicao(),
            ModoVisualizacaoMascara.ladoALado => _ladoALado(),
          },
        ),
      ),
    );
  }

  Widget _imagemOriginal() {
    return _imagemArquivo(
      key: chaveImagemOriginal,
      caminho: caminhoImagemOriginal,
      descricaoErro: 'Imagem original indisponível.',
    );
  }

  Widget _mascaraAutomatica() {
    return _imagemArquivo(
      key: chaveMascaraAutomatica,
      caminho: caminhoMascaraAutomatica,
      descricaoErro: 'Máscara automática indisponível.',
    );
  }

  Widget _sobreposicao() {
    return Stack(
      key: chaveSobreposicao,
      fit: StackFit.expand,
      children: [
        _imagemArquivo(
          key: chaveImagemOriginal,
          caminho: caminhoImagemOriginal,
          descricaoErro: 'Imagem original indisponível.',
        ),
        Opacity(
          opacity: opacidadeMascara.clamp(0.0, 1.0).toDouble(),
          child: _imagemArquivo(
            key: chaveMascaraAutomatica,
            caminho: caminhoMascaraAutomatica,
            descricaoErro: 'Máscara automática indisponível.',
          ),
        ),
      ],
    );
  }

  Widget _ladoALado() {
    return Row(
      key: chaveLadoALado,
      children: [
        Expanded(child: _imagemOriginal()),
        Expanded(child: _mascaraAutomatica()),
      ],
    );
  }

  Widget _imagemArquivo({
    required Key key,
    required String caminho,
    required String descricaoErro,
  }) {
    return Image.file(
      File(caminho),
      key: key,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Center(child: Text(descricaoErro));
      },
    );
  }
}
