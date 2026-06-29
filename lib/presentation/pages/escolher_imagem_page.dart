import 'dart:io';

import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de entrada da imagem original.
///
/// A imagem escolhida ou capturada é copiada para o armazenamento interno do
/// aplicativo. A origem externa não é modificada, e nenhuma segmentação ou
/// edição de máscara acontece nesta fase.
class EscolherImagemPage extends StatefulWidget {
  const EscolherImagemPage({
    this.entradaImagemService,
    this.imagemService,
    super.key,
  });

  final EntradaImagemService? entradaImagemService;
  final ImagemService? imagemService;

  @override
  State<EscolherImagemPage> createState() => _EscolherImagemPageState();
}

class _EscolherImagemPageState extends State<EscolherImagemPage> {
  late final EntradaImagemService _entradaImagemService;
  late final ImagemService _imagemService;

  ImagemPreparada? _imagemPreparada;
  String? _mensagem;
  Analise? _analise;
  bool _carregando = false;
  bool _argumentosLidos = false;

  @override
  void initState() {
    super.initState();
    _entradaImagemService =
        widget.entradaImagemService ?? ImagePickerEntradaImagemService();
    _imagemService = widget.imagemService ?? ImagemService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosLidos) {
      return;
    }
    _argumentosLidos = true;
    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Analise) {
      _analise = argumento;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: 'Escolher imagem',
      filhos: [
        const CartaoInformativo(
          titulo: 'Imagem original preservada',
          texto:
              'Importe uma imagem da galeria ou capture uma nova foto. '
              'O arquivo será copiado para o armazenamento interno sem alterar '
              'a imagem original.',
          icone: Icons.image_outlined,
        ),
        OutlinedButton.icon(
          onPressed: _carregando
              ? null
              : () => _obterImagem(
                  origem: OrigemImagem.galeria,
                  acao: _entradaImagemService.importarDaGaleria,
                ),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Importar da galeria'),
        ),
        OutlinedButton.icon(
          onPressed: _carregando
              ? null
              : () => _obterImagem(
                  origem: OrigemImagem.camera,
                  acao: _entradaImagemService.capturarComCamera,
                ),
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Capturar com câmera'),
        ),
        if (_carregando) const LinearProgressIndicator(),
        if (_mensagem != null)
          CartaoInformativo(
            titulo: 'Situação da imagem',
            texto: _mensagem!,
            icone: Icons.info_outline,
          ),
        if (_imagemPreparada != null) ...[
          const TituloSecao('Imagem selecionada'),
          _ResumoImagem(imagemPreparada: _imagemPreparada!),
          BotaoPrimario(
            rotulo: 'Continuar para processamento',
            icone: Icons.arrow_forward,
            aoPressionar: () => Navigator.pushNamed(
              context,
              RotasApp.processamento,
              arguments: _analise == null
                  ? _imagemPreparada!.imagem
                  : DadosImagemAnalise(
                      analise: _analise!,
                      imagem: _imagemPreparada!.imagem,
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _obterImagem({
    required OrigemImagem origem,
    required Future<ResultadoEntradaImagem> Function() acao,
  }) async {
    setState(() {
      _carregando = true;
      _mensagem = null;
    });

    try {
      final resultado = await acao();

      if (!mounted) {
        return;
      }

      if (resultado.cancelado) {
        setState(() {
          _imagemPreparada = null;
          _mensagem = 'Seleção de imagem cancelada.';
        });
        return;
      }

      if (resultado.possuiErro || !resultado.possuiArquivo) {
        setState(() {
          _imagemPreparada = null;
          _mensagem = resultado.mensagemErro ?? 'Nenhuma imagem foi obtida.';
        });
        return;
      }

      final preparada = await _imagemService.prepararImagemOriginal(
        arquivoExterno: resultado.arquivo!,
        origem: origem,
        analiseId: _analise?.id ?? 'analise_em_memoria',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _imagemPreparada = preparada;
        _mensagem = 'Imagem copiada para o armazenamento interno.';
      });
    } on Exception catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _imagemPreparada = null;
        _mensagem = 'Não foi possível preparar a imagem. Detalhe: $erro';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }
}

class _ResumoImagem extends StatelessWidget {
  const _ResumoImagem({required this.imagemPreparada});

  final ImagemPreparada imagemPreparada;

  @override
  Widget build(BuildContext context) {
    final imagem = imagemPreparada.imagem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagem.caminhoArquivo),
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const CartaoInformativo(
                titulo: 'Preview indisponível',
                texto:
                    'A imagem foi registrada, mas o preview não pôde ser exibido.',
                icone: Icons.broken_image_outlined,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text('Caminho interno: ${imagem.caminhoArquivo}'),
        Text('Formato: ${imagem.formato.toUpperCase()}'),
        Text('Largura: ${imagem.largura}px'),
        Text('Altura: ${imagem.altura}px'),
        Text('Origem: ${imagem.origem.name.toUpperCase()}'),
      ],
    );
  }
}
