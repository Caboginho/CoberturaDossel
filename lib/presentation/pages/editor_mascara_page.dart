import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/imagem_com_mascara.dart';
import '../widgets/modo_visualizacao_mascara.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

enum ModoInteracaoEditorMascara { navegar, editar }

enum ModoVisualizacaoEditorMascara { sobreposicao, imagemOriginal, mascara }

/// Editor manual mínimo da máscara.
///
/// A Fase 7 permite pintar somente a máscara em memória e salvar uma nova
/// máscara final. A imagem original é usada apenas como referência visual e não
/// é modificada por esta tela.
class EditorMascaraPage extends StatefulWidget {
  const EditorMascaraPage({
    this.ferramentaEdicaoService,
    this.historicoEdicaoService,
    super.key,
  });

  final FerramentaEdicaoService? ferramentaEdicaoService;
  final HistoricoEdicaoService? historicoEdicaoService;

  @override
  State<EditorMascaraPage> createState() => _EditorMascaraPageState();
}

class _EditorMascaraPageState extends State<EditorMascaraPage> {
  late final FerramentaEdicaoService _ferramentaEdicaoService;
  late final HistoricoEdicaoService _historicoEdicaoService;

  Analise? _analise;
  ResultadoProcessamentoImagem? _resultadoProcessamento;
  img.Image? _mascaraEditada;
  Uint8List? _bytesMascaraEditada;
  ClassePixel _classeAtiva = ClassePixel.ceu;
  TipoFerramenta _ferramentaAtiva = TipoFerramenta.pincel;
  ModoInteracaoEditorMascara _modoInteracao =
      ModoInteracaoEditorMascara.navegar;
  ModoVisualizacaoEditorMascara _modoVisualizacao =
      ModoVisualizacaoEditorMascara.sobreposicao;
  double _tamanhoPincel = 5;
  double _opacidadeMascara = 0.60;
  bool _argumentosLidos = false;
  bool _carregandoMascara = false;
  bool _validandoMascara = false;
  bool _estadoRegistradoNoGesto = false;
  String? _erroCarregamento;

  @override
  void initState() {
    super.initState();
    _ferramentaEdicaoService =
        widget.ferramentaEdicaoService ?? FerramentaEdicaoService();
    _historicoEdicaoService =
        widget.historicoEdicaoService ?? HistoricoEdicaoService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosLidos) {
      return;
    }

    _argumentosLidos = true;
    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is DadosAnaliseReaberta) {
      _analise = argumento.analise;
      _resultadoProcessamento = argumento.processamento;
      _carregarMascara(
        argumento.processamento,
        caminhoMascaraBase:
            (argumento.mascaraFinal ?? argumento.mascaraAutomatica)
                .caminhoArquivo,
      );
    } else if (argumento is DadosProcessamentoAnalise) {
      _analise = argumento.analise;
      _resultadoProcessamento = argumento.processamento;
      _carregarMascara(argumento.processamento);
    } else if (argumento is ResultadoProcessamentoImagem) {
      _resultadoProcessamento = argumento;
      _carregarMascara(argumento);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultadoProcessamento = _resultadoProcessamento;

    return PaginaBase(
      titulo: 'Editor de máscara',
      filhos: [
        const CartaoInformativo(
          titulo: 'Imagem original preservada',
          texto:
              'A edição ocorre apenas sobre a máscara. A imagem original não '
              'será alterada.',
          icone: Icons.lock_outline,
        ),
        if (resultadoProcessamento != null)
          ImagemComMascara(
            caminhoImagemOriginal: resultadoProcessamento.imagem.caminhoArquivo,
            caminhoMascaraAutomatica:
                resultadoProcessamento.mascaraAutomatica.caminhoArquivo,
            modo: ModoVisualizacaoMascara.ladoALado,
          )
        else
          const CartaoInformativo(
            titulo: 'Máscara não carregada',
            texto:
                'Acesse o editor a partir da tela de análise após gerar a '
                'máscara automática.',
            icone: Icons.image_not_supported_outlined,
          ),
        const TituloSecao('Edição da máscara'),
        _controleVisualizacaoEditor(),
        _controleModoInteracao(),
        _areaEdicao(),
        const TituloSecao('Classe ativa'),
        _controleClasse(),
        const TituloSecao('Ferramenta'),
        _controleFerramenta(),
        _controleTamanhoPincel(),
        _controleHistorico(),
        BotaoPrimario(
          rotulo: _validandoMascara
              ? 'Validando máscara...'
              : 'Validar máscara',
          icone: Icons.check_circle_outline,
          aoPressionar: _mascaraEditada == null || _validandoMascara
              ? null
              : _validar,
        ),
      ],
    );
  }

  Widget _areaEdicao() {
    if (_carregandoMascara) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erroCarregamento != null) {
      return CartaoInformativo(
        titulo: 'Falha ao carregar máscara',
        texto: _erroCarregamento!,
        icone: Icons.error_outline,
      );
    }

    final mascara = _mascaraEditada;
    final bytes = _bytesMascaraEditada;
    if (mascara == null || bytes == null) {
      return const CartaoInformativo(
        titulo: 'Aguardando máscara automática',
        texto:
            'Quando a máscara automática estiver disponível, esta área permitirá '
            'pintar pixels como Céu ou Não céu.',
        icone: Icons.pending_outlined,
      );
    }

    return AreaEdicaoMascara(
      caminhoImagemOriginal: _resultadoProcessamento?.imagem.caminhoArquivo,
      bytesMascara: bytes,
      largura: mascara.width,
      altura: mascara.height,
      modoInteracao: _modoInteracao,
      modoVisualizacao: _modoVisualizacao,
      opacidadeMascara: _opacidadeMascara,
      classeAtiva: _classeAtiva,
      tamanhoPincel: _tamanhoPincel,
      aoIniciarEdicao: _iniciarEdicao,
      aoContinuarEdicao: _continuarEdicao,
      aoFinalizarEdicao: _finalizarEdicao,
      aoTocar: _aplicarToque,
    );
  }

  Widget _controleVisualizacaoEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ModoVisualizacaoEditorMascara>(
          segments: const [
            ButtonSegment(
              value: ModoVisualizacaoEditorMascara.sobreposicao,
              label: Text('Sobreposição'),
              icon: Icon(Icons.layers_outlined),
            ),
            ButtonSegment(
              value: ModoVisualizacaoEditorMascara.imagemOriginal,
              label: Text('Imagem original'),
              icon: Icon(Icons.image_outlined),
            ),
            ButtonSegment(
              value: ModoVisualizacaoEditorMascara.mascara,
              label: Text('Máscara'),
              icon: Icon(Icons.texture_outlined),
            ),
          ],
          selected: {_modoVisualizacao},
          onSelectionChanged: (selecionados) {
            setState(() {
              _modoVisualizacao = selecionados.first;
            });
          },
        ),
        const SizedBox(height: 8),
        Text('Opacidade da máscara: ${(_opacidadeMascara * 100).round()}%'),
        Slider(
          value: _opacidadeMascara,
          min: 0,
          max: 1,
          divisions: 20,
          label: '${(_opacidadeMascara * 100).round()}%',
          onChanged: (valor) {
            setState(() {
              _opacidadeMascara = valor;
            });
          },
        ),
      ],
    );
  }

  Widget _controleModoInteracao() {
    final modoNavegarAtivo =
        _modoInteracao == ModoInteracaoEditorMascara.navegar;
    final classe = _classeAtiva == ClassePixel.ceu ? 'Céu' : 'Não céu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ModoInteracaoEditorMascara>(
          segments: const [
            ButtonSegment(
              value: ModoInteracaoEditorMascara.navegar,
              label: Text('Navegar'),
              icon: Icon(Icons.pan_tool_alt_outlined),
            ),
            ButtonSegment(
              value: ModoInteracaoEditorMascara.editar,
              label: Text('Editar'),
              icon: Icon(Icons.brush_outlined),
            ),
          ],
          selected: {_modoInteracao},
          onSelectionChanged: (selecionados) {
            setState(() {
              _modoInteracao = selecionados.first;
              _estadoRegistradoNoGesto = false;
            });
          },
        ),
        const SizedBox(height: 8),
        CartaoInformativo(
          titulo: modoNavegarAtivo
              ? 'Modo atual: Navegar'
              : 'Modo atual: Editar',
          texto: modoNavegarAtivo
              ? 'Arraste com um dedo para mover a imagem e use pinça com dois dedos para zoom. Neste modo, o gesto não pinta a máscara.'
              : 'Toque ou arraste com um dedo para pintar a máscara. A imagem fica fixa durante a pintura. Classe ativa: $classe. Pincel: ${_tamanhoPincel.round()} px.',
          icone: modoNavegarAtivo
              ? Icons.open_with_outlined
              : Icons.edit_location_alt_outlined,
        ),
        const SizedBox(height: 8),
        const Text(
          'Em celular, use Navegar para posicionar a imagem e Editar para corrigir a máscara. A edição assistida com área lateral fica preparada como melhoria futura.',
        ),
      ],
    );
  }

  Widget _controleClasse() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<ClassePixel>(
        segments: const [
          ButtonSegment(
            value: ClassePixel.ceu,
            label: Text('Céu'),
            icon: Icon(Icons.wb_sunny_outlined),
          ),
          ButtonSegment(
            value: ClassePixel.naoCeu,
            label: Text('Não céu'),
            icon: Icon(Icons.forest_outlined),
          ),
        ],
        selected: {_classeAtiva},
        onSelectionChanged: (selecionados) {
          setState(() {
            _classeAtiva = selecionados.first;
          });
        },
      ),
    );
  }

  Widget _controleFerramenta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<TipoFerramenta>(
            segments: const [
              ButtonSegment(
                value: TipoFerramenta.pincel,
                label: Text('Pincel'),
                icon: Icon(Icons.brush_outlined),
              ),
              ButtonSegment(
                value: TipoFerramenta.borracha,
                label: Text('Borracha'),
                icon: Icon(Icons.auto_fix_off),
              ),
            ],
            selected: {_ferramentaAtiva},
            onSelectionChanged: (selecionados) {
              setState(() {
                _ferramentaAtiva = selecionados.first;
              });
            },
          ),
        ),
        if (_ferramentaAtiva == TipoFerramenta.borracha) ...[
          const SizedBox(height: 8),
          const Text('Na máscara binária, a borracha aplica a classe Não céu.'),
        ],
      ],
    );
  }

  Widget _controleTamanhoPincel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tamanho do pincel: ${_tamanhoPincel.round()} px'),
        Slider(
          value: _tamanhoPincel,
          min: 1,
          max: 40,
          divisions: 39,
          label: '${_tamanhoPincel.round()} px',
          onChanged: (valor) {
            setState(() {
              _tamanhoPincel = valor;
            });
          },
        ),
      ],
    );
  }

  Widget _controleHistorico() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _historicoEdicaoService.podeDesfazer ? _desfazer : null,
            icon: const Icon(Icons.undo),
            label: const Text('Desfazer'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _historicoEdicaoService.podeRefazer ? _refazer : null,
            icon: const Icon(Icons.redo),
            label: const Text('Refazer'),
          ),
        ),
      ],
    );
  }

  Future<void> _carregarMascara(
    ResultadoProcessamentoImagem resultadoProcessamento, {
    String? caminhoMascaraBase,
  }) async {
    setState(() {
      _carregandoMascara = true;
      _erroCarregamento = null;
    });

    try {
      final mascara = await _ferramentaEdicaoService.carregarMascaraAutomatica(
        caminhoMascaraBase ??
            resultadoProcessamento.mascaraAutomatica.caminhoArquivo,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _definirMascaraEditada(mascara);
        _carregandoMascara = false;
      });
    } on Object catch (erro) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erroCarregamento =
            'Não foi possível carregar a máscara automática. '
            'Volte ao processamento e gere a máscara novamente. Detalhe: $erro';
        _carregandoMascara = false;
      });
    }
  }

  void _iniciarEdicao(Offset posicao) {
    if (_modoInteracao != ModoInteracaoEditorMascara.editar) {
      return;
    }
    _registrarEstadoParaGesto();
    _aplicarEdicao(posicao);
  }

  void _continuarEdicao(Offset posicao) {
    if (_modoInteracao != ModoInteracaoEditorMascara.editar) {
      return;
    }
    _registrarEstadoParaGesto();
    _aplicarEdicao(posicao);
  }

  void _finalizarEdicao() {
    _estadoRegistradoNoGesto = false;
  }

  void _aplicarToque(Offset posicao) {
    if (_modoInteracao != ModoInteracaoEditorMascara.editar) {
      return;
    }
    _registrarEstadoParaGesto();
    _aplicarEdicao(posicao);
    _estadoRegistradoNoGesto = false;
  }

  void _registrarEstadoParaGesto() {
    final mascara = _mascaraEditada;
    if (mascara == null || _estadoRegistradoNoGesto) {
      return;
    }

    _historicoEdicaoService.adicionarEstado(mascara);
    _estadoRegistradoNoGesto = true;
  }

  void _aplicarEdicao(Offset posicao) {
    final mascara = _mascaraEditada;
    if (mascara == null) {
      return;
    }

    final acao = AcaoEdicaoMascara(
      x: posicao.dx.floor(),
      y: posicao.dy.floor(),
      tamanhoPincel: _tamanhoPincel.round(),
      classeAplicada: _classeAtiva,
      ferramenta: _ferramentaAtiva,
      dataHora: DateTime.now(),
    );
    final editada = _ferramentaEdicaoService.aplicarAcao(
      mascara: mascara,
      acao: acao,
    );

    setState(() {
      _definirMascaraEditada(editada);
    });
  }

  void _desfazer() {
    final mascara = _mascaraEditada;
    if (mascara == null) {
      return;
    }

    final anterior = _historicoEdicaoService.desfazer(mascara);
    if (anterior == null) {
      return;
    }

    setState(() {
      _definirMascaraEditada(anterior);
    });
  }

  void _refazer() {
    final mascara = _mascaraEditada;
    if (mascara == null) {
      return;
    }

    final refeito = _historicoEdicaoService.refazer(mascara);
    if (refeito == null) {
      return;
    }

    setState(() {
      _definirMascaraEditada(refeito);
    });
  }

  Future<void> _validar() async {
    final resultadoProcessamento = _resultadoProcessamento;
    final mascara = _mascaraEditada;
    if (resultadoProcessamento == null || mascara == null) {
      return;
    }

    setState(() {
      _validandoMascara = true;
    });

    try {
      final resultadoValidacao = await _ferramentaEdicaoService
          .validarMascaraEditada(
            processamento: resultadoProcessamento,
            mascaraEditada: mascara,
          );
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(
        context,
        RotasApp.resultados,
        arguments: _analise == null
            ? resultadoValidacao
            : DadosValidacaoAnalise(
                analise: _analiseValidada(_analise!),
                validacao: resultadoValidacao,
              ),
      );
    } on Object catch (erro) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível validar a máscara: $erro')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _validandoMascara = false;
        });
      }
    }
  }

  void _definirMascaraEditada(img.Image mascara) {
    _mascaraEditada = mascara;
    _bytesMascaraEditada = Uint8List.fromList(img.encodePng(mascara));
  }

  Analise _analiseValidada(Analise analise) {
    return Analise(
      id: analise.id,
      nome: analise.nome,
      dataCriacao: analise.dataCriacao,
      dataAtualizacao: DateTime.now(),
      observacoes: analise.observacoes,
      versaoAlgoritmo: analise.versaoAlgoritmo,
      statusValidacao: true,
    );
  }
}

/// Área touch usada pelo editor para separar navegação e pintura da máscara.
///
/// Em modo navegar, o `InteractiveViewer` recebe pan e zoom e os callbacks de
/// pintura ficam inativos. Em modo editar, pan e zoom são desativados para que
/// toque e arraste apliquem correções somente sobre a máscara em memória.
class AreaEdicaoMascara extends StatelessWidget {
  const AreaEdicaoMascara({
    this.caminhoImagemOriginal,
    required this.bytesMascara,
    required this.largura,
    required this.altura,
    required this.modoInteracao,
    required this.modoVisualizacao,
    required this.opacidadeMascara,
    required this.classeAtiva,
    required this.tamanhoPincel,
    required this.aoIniciarEdicao,
    required this.aoContinuarEdicao,
    required this.aoFinalizarEdicao,
    required this.aoTocar,
    super.key,
  });

  final String? caminhoImagemOriginal;
  final Uint8List bytesMascara;
  final int largura;
  final int altura;
  final ModoInteracaoEditorMascara modoInteracao;
  final ModoVisualizacaoEditorMascara modoVisualizacao;
  final double opacidadeMascara;
  final ClassePixel classeAtiva;
  final double tamanhoPincel;
  final ValueChanged<Offset> aoIniciarEdicao;
  final ValueChanged<Offset> aoContinuarEdicao;
  final VoidCallback aoFinalizarEdicao;
  final ValueChanged<Offset> aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final modoEdicaoAtivo = modoInteracao == ModoInteracaoEditorMascara.editar;
    final mostrarImagem =
        modoVisualizacao != ModoVisualizacaoEditorMascara.mascara &&
        caminhoImagemOriginal != null;
    final mostrarMascara =
        modoVisualizacao != ModoVisualizacaoEditorMascara.imagemOriginal;
    final classe = classeAtiva == ClassePixel.ceu ? 'Céu' : 'Não céu';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tema.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 360,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 8,
            panEnabled: !modoEdicaoAtivo,
            scaleEnabled: !modoEdicaoAtivo,
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: largura.toDouble(),
                  height: altura.toDouble(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (mostrarImagem)
                        Image.file(
                          File(caminhoImagemOriginal!),
                          fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) {
                            return ColoredBox(
                              color: tema.colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Text('Imagem original indisponível'),
                              ),
                            );
                          },
                        ),
                      if (mostrarMascara)
                        Opacity(
                          opacity:
                              modoVisualizacao ==
                                  ModoVisualizacaoEditorMascara.sobreposicao
                              ? opacidadeMascara.clamp(0.0, 1.0).toDouble()
                              : 1,
                          child: Image.memory(
                            bytesMascara,
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                          ),
                        ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: modoEdicaoAtivo
                            ? (detalhes) => aoTocar(detalhes.localPosition)
                            : null,
                        onPanStart: modoEdicaoAtivo
                            ? (detalhes) =>
                                  aoIniciarEdicao(detalhes.localPosition)
                            : null,
                        onPanUpdate: modoEdicaoAtivo
                            ? (detalhes) =>
                                  aoContinuarEdicao(detalhes.localPosition)
                            : null,
                        onPanEnd: modoEdicaoAtivo
                            ? (_) => aoFinalizarEdicao()
                            : null,
                        onPanCancel: modoEdicaoAtivo ? aoFinalizarEdicao : null,
                        child: const SizedBox.expand(),
                      ),
                      if (modoEdicaoAtivo)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: tema.colorScheme.surface.withAlpha(220),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: tema.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Text(
                                'Editando: $classe | ${tamanhoPincel.round()} px',
                                style: tema.textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
