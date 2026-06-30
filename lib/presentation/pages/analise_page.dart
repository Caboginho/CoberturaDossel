import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/controle_visualizacao_mascara.dart';
import '../widgets/imagem_com_mascara.dart';
import '../widgets/modo_visualizacao_mascara.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de análise da imagem e das máscaras disponíveis.
///
/// A tela aceita análises recém-processadas e análises reabertas do SQLite. Ela
/// apenas visualiza arquivos já existentes e encaminha a revisão para o editor,
/// preservando a imagem original e a máscara automática.
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
    final dados = _normalizarArgumento(argumento);

    return PaginaBase(
      titulo: 'Análise',
      filhos: [
        const TituloSecao('Imagem e máscara'),
        if (dados != null) ...[
          ImagemComMascara(
            caminhoImagemOriginal: dados.imagem.caminhoArquivo,
            caminhoMascaraAutomatica:
                (dados.mascaraFinal ?? dados.mascaraAutomatica).caminhoArquivo,
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
          _ResumoAnaliseCompleta(dados: dados),
          if (!dados.possuiResultadoFinal)
            const CartaoInformativo(
              titulo: 'Resultado automático inicial — ainda não validado.',
              texto:
                  'O resultado automático é preliminar e serve apenas como apoio. O resultado final dependerá da validação humana da máscara.',
              icone: Icons.pending_actions,
            ),
        ] else
          const CartaoInformativo(
            titulo: 'Resultado automático inicial — ainda não validado.',
            texto:
                'Gere a máscara automática na tela de processamento ou reabra uma análise salva com dados completos. O resultado automático é preliminar e dependerá da validação humana da máscara.',
            icone: Icons.image_not_supported_outlined,
          ),
        const CartaoInformativo(
          titulo: 'Imagem original preservada',
          texto:
              'A imagem original é preservada. A revisão manual ocorre apenas sobre a máscara.',
          icone: Icons.lock_outline,
        ),
        BotaoPrimario(
          rotulo: dados?.possuiResultadoFinal == true
              ? 'Editar máscara validada'
              : 'Revisar máscara',
          icone: Icons.brush_outlined,
          aoPressionar: dados == null
              ? null
              : () => Navigator.pushNamed(
                  context,
                  RotasApp.editorMascara,
                  arguments: dados,
                ),
        ),
        BotaoPrimario(
          rotulo: 'Ver resultados',
          icone: Icons.percent,
          aoPressionar: dados == null
              ? null
              : () => Navigator.pushNamed(
                  context,
                  RotasApp.resultados,
                  arguments: dados,
                ),
        ),
      ],
    );
  }

  DadosAnaliseReaberta? _normalizarArgumento(Object? argumento) {
    if (argumento is DadosAnaliseReaberta) {
      return argumento;
    }

    if (argumento is DadosProcessamentoAnalise) {
      final processamento = argumento.processamento;
      return DadosAnaliseReaberta(
        analise: argumento.analise,
        imagem: processamento.imagem,
        mascaraAutomatica: processamento.mascaraAutomatica,
        resultadoAutomatico: processamento.resultadoAutomatico,
      );
    }

    if (argumento is ResultadoProcessamentoImagem) {
      return DadosAnaliseReaberta(
        analise: _analiseEmMemoria(argumento.imagem.analiseId),
        imagem: argumento.imagem,
        mascaraAutomatica: argumento.mascaraAutomatica,
        resultadoAutomatico: argumento.resultadoAutomatico,
      );
    }

    return null;
  }

  Analise _analiseEmMemoria(String analiseId) {
    final agora = DateTime.now();
    return Analise(
      id: analiseId,
      nome: 'Análise em memória',
      dataCriacao: agora,
      dataAtualizacao: agora,
      versaoAlgoritmo: 'regras_visuais_mvp',
    );
  }
}

class _ResumoAnaliseCompleta extends StatelessWidget {
  const _ResumoAnaliseCompleta({required this.dados});

  final DadosAnaliseReaberta dados;

  @override
  Widget build(BuildContext context) {
    final resultadoFinal = dados.resultadoFinal;
    final mascaraFinal = dados.mascaraFinal;

    return CartaoInformativo(
      titulo: dados.possuiResultadoFinal
          ? 'Análise reaberta com resultado final'
          : 'Resultado automático inicial — ainda não validado',
      texto:
          'Análise: ${dados.analise.nome}\n'
          'Status: ${dados.possuiResultadoFinal ? 'validada' : 'sem validação final'}\n'
          'Céu automático: ${dados.resultadoAutomatico.percentualCeu.toStringAsFixed(2)}%\n'
          'Dossel automático: ${dados.resultadoAutomatico.percentualDossel.toStringAsFixed(2)}%\n'
          '${resultadoFinal == null ? 'Resultado final: ainda não validado' : 'Dossel final: ${resultadoFinal.percentualDossel.toStringAsFixed(2)}%'}\n'
          'Máscara automática: ${dados.mascaraAutomatica.caminhoArquivo}'
          '${mascaraFinal == null ? '' : '\nMáscara final: ${mascaraFinal.caminhoArquivo}'}',
      icone: dados.possuiResultadoFinal
          ? Icons.verified_outlined
          : Icons.pending_actions,
    );
  }
}
