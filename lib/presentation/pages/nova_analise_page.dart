import 'package:flutter/material.dart';

import '../../domain/domain.dart';
import '../routes/rotas_app.dart';
import '../widgets/botao_primario.dart';
import '../widgets/cartao_informativo.dart';
import '../widgets/pagina_base.dart';

/// Tela inicial de cadastro de uma nova análise.
///
/// A Fase 9 preserva nome e observações em uma entidade [Analise] que segue pelo
/// fluxo até o salvamento definitivo no SQLite.
class NovaAnalisePage extends StatefulWidget {
  const NovaAnalisePage({super.key});

  @override
  State<NovaAnalisePage> createState() => _NovaAnalisePageState();
}

class _NovaAnalisePageState extends State<NovaAnalisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaginaBase(
      titulo: 'Nova análise',
      filhos: [
        const CartaoInformativo(
          titulo: 'Dados iniciais',
          texto:
              'Informe os dados básicos da análise. Nesta fase, o formulário '
              'apenas prepara a navegação do fluxo do MVP.',
          icone: Icons.science_outlined,
        ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da análise',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe um nome para continuar.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
        BotaoPrimario(
          rotulo: 'Continuar',
          icone: Icons.arrow_forward,
          aoPressionar: () {
            if (_formKey.currentState!.validate()) {
              final agora = DateTime.now();
              final analise = Analise(
                id: 'analise_${agora.microsecondsSinceEpoch}',
                nome: _nomeController.text.trim(),
                dataCriacao: agora,
                dataAtualizacao: agora,
                observacoes: _observacoesController.text.trim(),
                versaoAlgoritmo: 'regras_visuais_mvp',
              );
              Navigator.pushNamed(
                context,
                RotasApp.escolherImagem,
                arguments: analise,
              );
            }
          },
        ),
      ],
    );
  }
}
