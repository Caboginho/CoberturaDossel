import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de processamento automático inicial.
///
/// A Fase 5 gera uma máscara automática separada e um resultado preliminar. A
/// visualização com sobreposição e a correção manual ficam para fases futuras.
class ProcessamentoPage extends StatefulWidget {
  const ProcessamentoPage({this.processamentoImagemService, super.key});

  final ProcessamentoImagemService? processamentoImagemService;

  @override
  State<ProcessamentoPage> createState() => _ProcessamentoPageState();
}

class _ProcessamentoPageState extends State<ProcessamentoPage> {
  late final ProcessamentoImagemService _processamentoImagemService;
  ResultadoProcessamentoImagem? _resultadoProcessamento;
  String? _mensagemErro;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _processamentoImagemService =
        widget.processamentoImagemService ?? ProcessamentoImagemService();
  }

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final dadosImagem = argumento is DadosImagemAnalise ? argumento : null;
    final imagemRecebida =
        dadosImagem?.imagem ?? (argumento is Imagem ? argumento : null);

    return PaginaBase(
      titulo: 'Processamento',
      filhos: [
        if (imagemRecebida != null)
          CartaoInformativo(
            titulo: 'Imagem recebida',
            texto:
                'Arquivo: ${imagemRecebida.caminhoArquivo}\n'
                'Formato: ${imagemRecebida.formato.toUpperCase()}\n'
                'Dimensões: ${imagemRecebida.largura} x ${imagemRecebida.altura}px',
            icone: Icons.image_outlined,
          )
        else
          const CartaoInformativo(
            titulo: 'Nenhuma imagem recebida',
            texto:
                'Volte para a tela de escolha de imagem para importar ou '
                'capturar uma imagem antes de processar.',
            icone: Icons.warning_amber_outlined,
          ),
        const CartaoInformativo(
          titulo: 'Segmentação automática inicial',
          texto:
              'A Fase 5 classifica pixels em céu e não céu por regras '
              'visuais simples. Não há inteligência artificial, medição direta '
              'de LAI ou validação final nesta etapa.',
          icone: Icons.auto_fix_high,
        ),
        if (_processando) const LinearProgressIndicator(),
        if (_mensagemErro != null)
          CartaoInformativo(
            titulo: 'Falha no processamento',
            texto: _mensagemErro!,
            icone: Icons.error_outline,
          ),
        BotaoPrimario(
          rotulo: 'Gerar máscara automática',
          icone: Icons.auto_fix_high,
          aoPressionar: imagemRecebida == null || _processando
              ? null
              : () => _gerarMascaraAutomatica(imagemRecebida),
        ),
        if (_resultadoProcessamento != null) ...[
          const TituloSecao(
            'Resultado automático inicial — ainda não validado',
          ),
          _ResumoProcessamento(resultado: _resultadoProcessamento!),
          BotaoPrimario(
            rotulo: 'Seguir para análise',
            icone: Icons.analytics_outlined,
            aoPressionar: () => Navigator.pushNamed(
              context,
              RotasApp.analise,
              arguments: dadosImagem == null
                  ? _resultadoProcessamento
                  : DadosProcessamentoAnalise(
                      analise: dadosImagem.analise,
                      processamento: _resultadoProcessamento!,
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _gerarMascaraAutomatica(Imagem imagem) async {
    setState(() {
      _processando = true;
      _mensagemErro = null;
    });

    try {
      final resultado = await _processamentoImagemService
          .gerarMascaraAutomatica(imagem: imagem);

      if (!mounted) {
        return;
      }

      setState(() {
        _resultadoProcessamento = resultado;
      });
    } on Exception catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagemErro =
            'Não foi possível gerar a máscara automática. Detalhe: $erro';
      });
    } finally {
      if (mounted) {
        setState(() {
          _processando = false;
        });
      }
    }
  }
}

class _ResumoProcessamento extends StatelessWidget {
  const _ResumoProcessamento({required this.resultado});

  final ResultadoProcessamentoImagem resultado;

  @override
  Widget build(BuildContext context) {
    final mascara = resultado.mascaraAutomatica;
    final automatico = resultado.resultadoAutomatico;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Largura: ${mascara.largura}px'),
        Text('Altura: ${mascara.altura}px'),
        Text('Pixels de céu: ${mascara.pixelsCeu}'),
        Text('Pixels de não céu: ${mascara.pixelsNaoCeu}'),
        Text('Céu visível: ${automatico.percentualCeu.toStringAsFixed(2)}%'),
        Text(
          'Dossel estimado: ${automatico.percentualDossel.toStringAsFixed(2)}%',
        ),
        Text('Máscara automática: ${mascara.caminhoArquivo}'),
      ],
    );
  }
}
