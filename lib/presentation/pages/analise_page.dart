import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/controle_visualizacao_mascara.dart';
import '../widgets/imagem_com_mascara.dart';
import '../widgets/modo_visualizacao_mascara.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de análise da imagem e da máscara automática.
///
/// A Fase 6 permite visualizar a imagem original e a máscara automática gerada
/// na Fase 5. A tela não edita a imagem original nem a máscara.
class AnalisePage extends StatefulWidget {
  const AnalisePage({super.key});

  @override
  State<AnalisePage> createState() => _AnalisePageState();
}

class _AnalisePageState extends State<AnalisePage> {
  ModoVisualizacaoMascara _modoSelecionado =
      ModoVisualizacaoMascara.sobreposicao;
  double _opacidadeMascara = 0.55;

  @override
  Widget build(BuildContext context) {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final resultadoProcessamento = argumento is ResultadoProcessamentoImagem
        ? argumento
        : null;

    return PaginaBase(
      titulo: 'Análise',
      filhos: [
        const TituloSecao('Imagem e máscara'),
        if (resultadoProcessamento != null) ...[
          ImagemComMascara(
            caminhoImagemOriginal: resultadoProcessamento.imagem.caminhoArquivo,
            caminhoMascaraAutomatica:
                resultadoProcessamento.mascaraAutomatica.caminhoArquivo,
            modo: _modoSelecionado,
            opacidadeMascara: _opacidadeMascara,
          ),
          ControleVisualizacaoMascara(
            modoSelecionado: _modoSelecionado,
            opacidadeMascara: _opacidadeMascara,
            aoAlterarModo: (modo) {
              setState(() {
                _modoSelecionado = modo;
              });
            },
            aoAlterarOpacidade: (valor) {
              setState(() {
                _opacidadeMascara = valor;
              });
            },
          ),
          _ResumoResultadoAutomatico(resultado: resultadoProcessamento),
        ] else
          const CartaoInformativo(
            titulo: 'Máscara automática indisponível',
            texto:
                'Gere a máscara automática na tela de processamento para '
                'visualizar a imagem original e a máscara nesta tela.',
            icone: Icons.image_not_supported_outlined,
          ),
        const CartaoInformativo(
          titulo: 'Resultado automático inicial — ainda não validado.',
          texto:
              'O resultado automático é preliminar e serve apenas como apoio. '
              'O resultado final dependerá da validação humana da máscara.',
          icone: Icons.pending_actions,
        ),
        const CartaoInformativo(
          titulo: 'Imagem original preservada',
          texto:
              'A imagem original é preservada. A revisão futura ocorrerá '
              'apenas sobre a máscara.',
          icone: Icons.lock_outline,
        ),
        BotaoPrimario(
          rotulo: 'Revisar máscara',
          icone: Icons.brush_outlined,
          aoPressionar: () => Navigator.pushNamed(
            context,
            RotasApp.editorMascara,
            arguments: resultadoProcessamento,
          ),
        ),
        BotaoPrimario(
          rotulo: 'Ver resultados',
          icone: Icons.percent,
          aoPressionar: () => Navigator.pushNamed(
            context,
            RotasApp.resultados,
            arguments: resultadoProcessamento,
          ),
        ),
      ],
    );
  }
}

class _ResumoResultadoAutomatico extends StatelessWidget {
  const _ResumoResultadoAutomatico({required this.resultado});

  final ResultadoProcessamentoImagem resultado;

  @override
  Widget build(BuildContext context) {
    final mascara = resultado.mascaraAutomatica;
    final automatico = resultado.resultadoAutomatico;

    return CartaoInformativo(
      titulo: 'Resumo do resultado automático',
      texto:
          'Céu visível: ${automatico.percentualCeu.toStringAsFixed(2)}%\n'
          'Dossel estimado: ${automatico.percentualDossel.toStringAsFixed(2)}%\n'
          'Pixels de céu: ${mascara.pixelsCeu}\n'
          'Pixels de não céu: ${mascara.pixelsNaoCeu}\n'
          'Máscara automática: ${mascara.caminhoArquivo}',
      icone: Icons.analytics_outlined,
    );
  }
}
