import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../../domain/domain.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';
import '../widgets/titulo_secao.dart';

/// Tela de exportação básica dos resultados em CSV e JSON.
///
/// A exportação gera arquivos novos no diretório de exportações e não altera a
/// imagem original, a máscara automática ou a máscara final validada.
class ExportacaoPage extends StatefulWidget {
  const ExportacaoPage({this.exportacaoService, super.key});

  final ExportacaoService? exportacaoService;

  @override
  State<ExportacaoPage> createState() => _ExportacaoPageState();
}

class _ExportacaoPageState extends State<ExportacaoPage> {
  FormatoExportacao _formatoSelecionado = FormatoExportacao.csv;
  bool _exportando = false;
  bool _argumentosLidos = false;
  DadosExportacaoAnalise? _dadosBase;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosLidos) {
      return;
    }

    final argumento = ModalRoute.of(context)?.settings.arguments;
    _dadosBase = _obterDadosExportacao(argumento);
    _argumentosLidos = true;
  }

  @override
  Widget build(BuildContext context) {
    final dados = _dadosBase;

    return PaginaBase(
      titulo: 'Exportação',
      filhos: [
        const CartaoInformativo(
          titulo: 'Arquivo separado da análise',
          texto:
              'A exportação gera um novo arquivo e não altera a imagem '
              'original, a máscara automática ou a máscara final.',
          icone: Icons.ios_share,
        ),
        if (dados == null)
          const CartaoInformativo(
            titulo: 'Dados insuficientes',
            texto:
                'Não há dados reais de análise para exportar nesta tela. '
                'Volte aos resultados de uma análise processada.',
            icone: Icons.error_outline,
          )
        else
          _ResumoExportacao(dados: dados),
        const TituloSecao('Formato'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.table_chart),
              label: const Text('CSV'),
              selected: _formatoSelecionado == FormatoExportacao.csv,
              onSelected: (_) => _selecionarFormato(FormatoExportacao.csv),
            ),
            ChoiceChip(
              avatar: const Icon(Icons.data_object),
              label: const Text('JSON'),
              selected: _formatoSelecionado == FormatoExportacao.json,
              onSelected: (_) => _selecionarFormato(FormatoExportacao.json),
            ),
            const FilterChip(
              avatar: Icon(Icons.picture_as_pdf),
              label: Text('PDF futuro'),
              selected: false,
              onSelected: null,
            ),
          ],
        ),
        BotaoPrimario(
          rotulo: _exportando ? 'Exportando...' : 'Exportar',
          icone: Icons.file_upload_outlined,
          aoPressionar: _exportando ? null : () => _exportar(context),
        ),
      ],
    );
  }

  void _selecionarFormato(FormatoExportacao formato) {
    setState(() {
      _formatoSelecionado = formato;
    });
  }

  Future<void> _exportar(BuildContext context) async {
    final dadosBase = _dadosBase;
    if (dadosBase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há dados essenciais para exportação.'),
        ),
      );
      return;
    }

    setState(() {
      _exportando = true;
    });

    final servico = widget.exportacaoService ?? ExportacaoService();
    final resultado = await servico.exportarAnalise(
      dadosBase.copiarComFormato(_formatoSelecionado),
    );

    if (!context.mounted) {
      return;
    }

    setState(() {
      _exportando = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(resultado.mensagem)));
  }

  DadosExportacaoAnalise? _obterDadosExportacao(Object? argumento) {
    if (argumento is DadosExportacaoAnalise) {
      return argumento;
    }

    if (argumento is DadosValidacaoAnalise) {
      final validacao = argumento.validacao;
      return DadosExportacaoAnalise(
        analise: argumento.analise,
        imagem: validacao.imagem,
        mascaraAutomatica: validacao.mascaraAutomatica,
        mascaraFinal: validacao.mascaraFinal,
        resultadoAutomatico: validacao.resultadoAutomatico,
        resultadoFinal: validacao.resultadoFinal,
        formatoExportacao: _formatoSelecionado,
      );
    }

    if (argumento is DadosProcessamentoAnalise) {
      final processamento = argumento.processamento;
      return DadosExportacaoAnalise(
        analise: argumento.analise,
        imagem: processamento.imagem,
        mascaraAutomatica: processamento.mascaraAutomatica,
        resultadoAutomatico: processamento.resultadoAutomatico,
        formatoExportacao: _formatoSelecionado,
      );
    }

    if (argumento is ResumoAnaliseSalva) {
      final imagem = argumento.imagem;
      final mascaraAutomatica = argumento.resultadoAutomatico == null
          ? null
          : _buscarMascaraPorId(
              argumento.mascaras,
              argumento.resultadoAutomatico!.mascaraId,
            );

      if (imagem == null ||
          mascaraAutomatica == null ||
          argumento.resultadoAutomatico == null) {
        return null;
      }

      return DadosExportacaoAnalise(
        analise: argumento.analise,
        imagem: imagem,
        mascaraAutomatica: mascaraAutomatica,
        mascaraFinal: argumento.mascaraFinal,
        resultadoAutomatico: argumento.resultadoAutomatico!,
        resultadoFinal: argumento.resultadoFinal,
        metadadosAnalise: argumento.metadados,
        formatoExportacao: _formatoSelecionado,
      );
    }

    return null;
  }

  Mascara? _buscarMascaraPorId(List<Mascara> mascaras, String id) {
    for (final mascara in mascaras) {
      if (mascara.id == id) {
        return mascara;
      }
    }
    return null;
  }
}

class _ResumoExportacao extends StatelessWidget {
  const _ResumoExportacao({required this.dados});

  final DadosExportacaoAnalise dados;

  @override
  Widget build(BuildContext context) {
    final resultadoFinal = dados.resultadoFinal;
    final textoFinal = resultadoFinal == null
        ? 'Resultado final: ainda não validado'
        : 'Resultado final: ${resultadoFinal.percentualDossel.toStringAsFixed(2)}% de dossel';

    return CartaoInformativo(
      titulo: dados.analise.nome,
      texto:
          'Análise: ${dados.analise.id}\n'
          'Imagem original: ${dados.imagem.caminhoArquivo}\n'
          'Máscara automática: ${dados.mascaraAutomatica.caminhoArquivo}\n'
          '${dados.mascaraFinal == null ? 'Máscara final: não validada' : 'Máscara final: ${dados.mascaraFinal!.caminhoArquivo}'}\n'
          'Resultado automático: ${dados.resultadoAutomatico.percentualDossel.toStringAsFixed(2)}% de dossel\n'
          '$textoFinal',
      icone: Icons.summarize_outlined,
    );
  }
}
