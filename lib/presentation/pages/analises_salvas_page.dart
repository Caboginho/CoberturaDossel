import 'package:flutter/material.dart';

import '../../application/application.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';

/// Lista análises persistidas no SQLite.
///
/// A reabertura completa da análise fica para fase posterior; nesta fase a tela
/// confirma que o salvamento local já está consultável.
class AnalisesSalvasPage extends StatefulWidget {
  const AnalisesSalvasPage({this.consultaAnaliseService, super.key});

  final ConsultaAnaliseService? consultaAnaliseService;

  @override
  State<AnalisesSalvasPage> createState() => _AnalisesSalvasPageState();
}

class _AnalisesSalvasPageState extends State<AnalisesSalvasPage> {
  late final ConsultaAnaliseService _consultaAnaliseService;
  late Future<List<ResumoAnaliseSalva>> _resumosFuture;

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
                    'Salve uma análise na tela de resultados para que ela '
                    'apareça nesta lista.',
                icone: Icons.folder_off_outlined,
              ),
            );
          } else {
            filhos.addAll([
              for (final resumo in resumos) _ItemAnaliseSalva(resumo: resumo),
            ]);
          }
        }

        return PaginaBase(titulo: 'Análises salvas', filhos: filhos);
      },
    );
  }
}

class _ItemAnaliseSalva extends StatelessWidget {
  const _ItemAnaliseSalva({required this.resumo});

  final ResumoAnaliseSalva resumo;

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
        leading: Icon(
          resumo.validada ? Icons.verified_outlined : Icons.pending_actions,
          color: tema.colorScheme.primary,
        ),
        title: Text(resumo.analise.nome),
        subtitle: Text(
          'Atualizada em ${_formatarData(resumo.analise.dataAtualizacao)}\n'
          '$status\n'
          '$origemResultado: ${percentualDossel == null ? 'não calculado' : '${percentualDossel.toStringAsFixed(2)}% de dossel'}',
        ),
        isThreeLine: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Reabertura completa será implementada em fase posterior.',
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
