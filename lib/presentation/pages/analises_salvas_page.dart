import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../routes/rotas_app.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';

/// Lista análises persistidas no SQLite e permite reabrir o fluxo salvo.
///
/// A reabertura carrega entidades e caminhos persistidos, sem bytes de imagem.
/// Isso mantém a imagem original preservada e permite continuar revisão,
/// visualização, salvamento e exportação com dados reais.
class AnalisesSalvasPage extends StatefulWidget {
  const AnalisesSalvasPage({this.consultaAnaliseService, super.key});

  final ConsultaAnaliseService? consultaAnaliseService;

  @override
  State<AnalisesSalvasPage> createState() => _AnalisesSalvasPageState();
}

class _AnalisesSalvasPageState extends State<AnalisesSalvasPage> {
  late final ConsultaAnaliseService _consultaAnaliseService;
  late Future<List<ResumoAnaliseSalva>> _resumosFuture;
  String? _analiseReabrindoId;

  @override
  void initState() {
    super.initState();
    _consultaAnaliseService =
        widget.consultaAnaliseService ?? ConsultaAnaliseService();
    _resumosFuture = _consultaAnaliseService.listarAnalisesSalvas();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ResumoAnaliseSalva>>(
      future: _resumosFuture,
      builder: (context, snapshot) {
        final filhos = <Widget>[];

        if (snapshot.connectionState == ConnectionState.waiting) {
          filhos.add(const LinearProgressIndicator());
        } else if (snapshot.hasError) {
          filhos.add(
            CartaoInformativo(
              titulo: 'Falha ao carregar análises',
              texto:
                  'Não foi possível consultar o banco. Detalhe: ${snapshot.error}',
              icone: Icons.error_outline,
            ),
          );
        } else {
          final resumos = snapshot.data ?? const <ResumoAnaliseSalva>[];
          if (resumos.isEmpty) {
            filhos.add(
              const CartaoInformativo(
                titulo: 'Nenhuma análise salva ainda',
                texto:
                    'Salve uma análise na tela de resultados para que ela apareça nesta lista.',
                icone: Icons.folder_off_outlined,
              ),
            );
          } else {
            filhos.addAll([
              for (final resumo in resumos)
                _ItemAnaliseSalva(
                  resumo: resumo,
                  reabrindo: _analiseReabrindoId == resumo.analise.id,
                  aoTocar: () => _reabrirAnalise(resumo.analise.id),
                ),
            ]);
          }
        }

        return PaginaBase(titulo: 'Análises salvas', filhos: filhos);
      },
    );
  }

  Future<void> _reabrirAnalise(String analiseId) async {
    setState(() {
      _analiseReabrindoId = analiseId;
    });

    try {
      final dados = await _consultaAnaliseService.buscarAnaliseCompletaPorId(
        analiseId,
      );
      if (!mounted) {
        return;
      }

      Navigator.pushNamed(context, RotasApp.analise, arguments: dados);
    } on Object catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível reabrir a análise: $erro')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _analiseReabrindoId = null;
        });
      }
    }
  }
}

class _ItemAnaliseSalva extends StatelessWidget {
  const _ItemAnaliseSalva({
    required this.resumo,
    required this.reabrindo,
    required this.aoTocar,
  });

  final ResumoAnaliseSalva resumo;
  final bool reabrindo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final percentualDossel = resumo.percentualDosselExibido;
    final status = resumo.validada ? 'Validada' : 'Sem validação final';
    final origemResultado = resumo.validada
        ? 'Resultado final'
        : 'Resultado automático';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tema.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: reabrindo
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                resumo.validada
                    ? Icons.verified_outlined
                    : Icons.pending_actions,
                color: tema.colorScheme.primary,
              ),
        title: Text(resumo.analise.nome),
        subtitle: Text(
          'Atualizada em ${_formatarData(resumo.analise.dataAtualizacao)}\n'
          '$status\n'
          '$origemResultado: ${percentualDossel == null ? 'não calculado' : '${percentualDossel.toStringAsFixed(2)}% de dossel'}',
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: reabrindo ? null : aoTocar,
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
