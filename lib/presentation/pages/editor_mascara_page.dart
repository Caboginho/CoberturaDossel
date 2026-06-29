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
  double _tamanhoPincel = 5;
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
    if (argumento is DadosProcessamentoAnalise) {
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

    return _AreaEdicaoMascara(
      bytesMascara: bytes,
      largura: mascara.width,
      altura: mascara.height,
      aoIniciarEdicao: _iniciarEdicao,
      aoContinuarEdicao: _continuarEdicao,
      aoFinalizarEdicao: _finalizarEdicao,
      aoTocar: _aplicarToque,
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
    ResultadoProcessamentoImagem resultadoProcessamento,
  ) async {
    setState(() {
      _carregandoMascara = true;
      _erroCarregamento = null;
    });

    try {
      final mascara = await _ferramentaEdicaoService.carregarMascaraAutomatica(
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
    _registrarEstadoParaGesto();
    _aplicarEdicao(posicao);
  }

  void _continuarEdicao(Offset posicao) {
    _registrarEstadoParaGesto();
    _aplicarEdicao(posicao);
  }

  void _finalizarEdicao() {
    _estadoRegistradoNoGesto = false;
  }

  void _aplicarToque(Offset posicao) {
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

class _AreaEdicaoMascara extends StatelessWidget {
  const _AreaEdicaoMascara({
    required this.bytesMascara,
    required this.largura,
    required this.altura,
    required this.aoIniciarEdicao,
    required this.aoContinuarEdicao,
    required this.aoFinalizarEdicao,
    required this.aoTocar,
  });

  final Uint8List bytesMascara;
  final int largura;
  final int altura;
  final ValueChanged<Offset> aoIniciarEdicao;
  final ValueChanged<Offset> aoContinuarEdicao;
  final VoidCallback aoFinalizarEdicao;
  final ValueChanged<Offset> aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

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
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: largura.toDouble(),
                  height: altura.toDouble(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (detalhes) => aoTocar(detalhes.localPosition),
                    onPanStart: (detalhes) =>
                        aoIniciarEdicao(detalhes.localPosition),
                    onPanUpdate: (detalhes) =>
                        aoContinuarEdicao(detalhes.localPosition),
                    onPanEnd: (_) => aoFinalizarEdicao(),
                    onPanCancel: aoFinalizarEdicao,
                    child: Image.memory(
                      bytesMascara,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
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
