import 'dart:io';

/// Utilitario de apoio para transformar o CSV de validacao manual em uma
/// tabela Markdown resumida por grupo visual.
///
/// O script trabalha somente com registros textuais exportados ou preenchidos
/// pelo pesquisador. Ele nao acessa, copia ou altera imagens originais,
/// mascaras automaticas ou mascaras finais.
void main(List<String> argumentos) {
  if (argumentos.isEmpty || argumentos.contains('--help')) {
    stdout.writeln(_mensagemUso);
    return;
  }

  final caminhoEntrada = argumentos[0];
  final caminhoSaida = argumentos.length > 1 ? argumentos[1] : null;

  try {
    final conteudo = File(caminhoEntrada).readAsStringSync();
    final tabela = consolidarValidacaoCsv(conteudo);

    if (caminhoSaida == null) {
      stdout.writeln(tabela);
      return;
    }

    final arquivoSaida = File(caminhoSaida);
    arquivoSaida.parent.createSync(recursive: true);
    arquivoSaida.writeAsStringSync(tabela);
    stdout.writeln('Resumo de validacao salvo em: $caminhoSaida');
  } on FormatException catch (erro) {
    stderr.writeln('Falha ao interpretar o CSV de validacao: ${erro.message}');
    exitCode = 1;
  } on FileSystemException catch (erro) {
    stderr.writeln('Falha ao acessar arquivo de validacao: ${erro.message}');
    exitCode = 1;
  }
}

const _mensagemUso = '''
Uso:
  dart run tools/validacao/consolidar_validacao.dart entrada.csv [saida.md]

Exemplo:
  dart run tools/validacao/consolidar_validacao.dart docs/validacao/modelos/exemplo_registro_validacao_preenchido.csv docs/validacao/resultados/resumo_validacao.md
''';

/// Converte o conteudo CSV preenchido na validacao em uma tabela Markdown.
///
/// A consolidacao agrupa as imagens por `grupo_visual` e calcula medias dos
/// percentuais automaticos, finais e da diferenca percentual. Esses valores
/// ajudam a relatar a distancia entre a mascara automatica preliminar e a
/// mascara final validada pelo pesquisador.
String consolidarValidacaoCsv(String conteudo) {
  final registros = lerCsvValidacao(conteudo);
  final grupos = <String, _GrupoValidacao>{};

  for (final registro in registros) {
    final nomeGrupo = _valorTexto(registro, 'grupo_visual', 'sem_grupo');
    final grupo = grupos.putIfAbsent(
      nomeGrupo,
      () => _GrupoValidacao(nomeGrupo),
    );

    grupo.adicionar(
      dosselAutomatico: _valorDouble(registro, 'percentual_dossel_automatico'),
      dosselFinal: _valorDouble(registro, 'percentual_dossel_final'),
      diferencaPercentual: _valorDouble(registro, 'diferenca_percentual'),
      erroSegmentacao: _valorTexto(
        registro,
        'principais_erros_segmentacao',
        '',
      ),
    );
  }

  final buffer = StringBuffer()
    ..writeln(
      '| Grupo visual | Numero de imagens | Media do dossel automatico (%) | Media do dossel final (%) | Media da diferenca percentual | Principal erro observado | Observacoes |',
    )
    ..writeln('|---|---:|---:|---:|---:|---|---|');

  for (final grupo in grupos.values) {
    buffer.writeln(
      '| ${_escaparMarkdown(grupo.nome)} '
      '| ${grupo.quantidade} '
      '| ${grupo.mediaDosselAutomatico.toStringAsFixed(2)} '
      '| ${grupo.mediaDosselFinal.toStringAsFixed(2)} '
      '| ${grupo.mediaDiferencaPercentual.toStringAsFixed(2)} '
      '| ${_escaparMarkdown(grupo.principalErro)} '
      '| Conferir registros individuais e evidencias autorizadas. |',
    );
  }

  return buffer.toString().trimRight();
}

/// Le o CSV de validacao e retorna cada linha como um mapa indexado pelo
/// cabecalho. O parser aceita campos entre aspas e aspas escapadas, permitindo
/// observacoes textuais com virgulas.
List<Map<String, String>> lerCsvValidacao(String conteudo) {
  final linhas = _parseCsv(conteudo);
  if (linhas.isEmpty) {
    throw const FormatException('O arquivo CSV esta vazio.');
  }

  final cabecalho = linhas.first.map((valor) => valor.trim()).toList();
  if (cabecalho.isEmpty || cabecalho.every((valor) => valor.isEmpty)) {
    throw const FormatException('O cabecalho do CSV esta vazio.');
  }

  return linhas
      .skip(1)
      .where((linha) {
        return linha.any((valor) => valor.trim().isNotEmpty);
      })
      .map((linha) {
        final registro = <String, String>{};
        for (var indice = 0; indice < cabecalho.length; indice++) {
          final chave = cabecalho[indice];
          if (chave.isEmpty) {
            continue;
          }

          registro[chave] = indice < linha.length ? linha[indice].trim() : '';
        }
        return registro;
      })
      .toList();
}

List<List<String>> _parseCsv(String conteudo) {
  final linhas = <List<String>>[];
  var linhaAtual = <String>[];
  var campoAtual = StringBuffer();
  var dentroDeAspas = false;

  for (var indice = 0; indice < conteudo.length; indice++) {
    final caractere = conteudo[indice];

    if (caractere == '"') {
      final proximoEhAspas =
          indice + 1 < conteudo.length && conteudo[indice + 1] == '"';
      if (dentroDeAspas && proximoEhAspas) {
        campoAtual.write('"');
        indice++;
      } else {
        dentroDeAspas = !dentroDeAspas;
      }
      continue;
    }

    if (caractere == ',' && !dentroDeAspas) {
      linhaAtual.add(campoAtual.toString());
      campoAtual = StringBuffer();
      continue;
    }

    if ((caractere == '\n' || caractere == '\r') && !dentroDeAspas) {
      linhaAtual.add(campoAtual.toString());
      campoAtual = StringBuffer();
      if (linhaAtual.any((valor) => valor.isNotEmpty)) {
        linhas.add(linhaAtual);
      }
      linhaAtual = <String>[];

      if (caractere == '\r' &&
          indice + 1 < conteudo.length &&
          conteudo[indice + 1] == '\n') {
        indice++;
      }
      continue;
    }

    campoAtual.write(caractere);
  }

  if (dentroDeAspas) {
    throw const FormatException('Existe um campo com aspas sem fechamento.');
  }

  linhaAtual.add(campoAtual.toString());
  if (linhaAtual.any((valor) => valor.isNotEmpty)) {
    linhas.add(linhaAtual);
  }

  return linhas;
}

String _valorTexto(
  Map<String, String> registro,
  String chave,
  String valorPadrao,
) {
  final valor = registro[chave]?.trim();
  if (valor == null || valor.isEmpty) {
    return valorPadrao;
  }

  return valor;
}

double _valorDouble(Map<String, String> registro, String chave) {
  final valor = registro[chave]?.trim().replaceAll(',', '.');
  if (valor == null || valor.isEmpty) {
    return 0;
  }

  return double.tryParse(valor) ?? 0;
}

String _escaparMarkdown(String valor) {
  return valor.replaceAll('|', r'\|');
}

class _GrupoValidacao {
  _GrupoValidacao(this.nome);

  final String nome;
  var quantidade = 0;
  var somaDosselAutomatico = 0.0;
  var somaDosselFinal = 0.0;
  var somaDiferencaPercentual = 0.0;
  final errosSegmentacao = <String, int>{};

  void adicionar({
    required double dosselAutomatico,
    required double dosselFinal,
    required double diferencaPercentual,
    required String erroSegmentacao,
  }) {
    quantidade++;
    somaDosselAutomatico += dosselAutomatico;
    somaDosselFinal += dosselFinal;
    somaDiferencaPercentual += diferencaPercentual;

    final erroNormalizado = erroSegmentacao.trim();
    if (erroNormalizado.isNotEmpty) {
      errosSegmentacao.update(
        erroNormalizado,
        (quantidadeAtual) => quantidadeAtual + 1,
        ifAbsent: () => 1,
      );
    }
  }

  double get mediaDosselAutomatico => _media(somaDosselAutomatico);

  double get mediaDosselFinal => _media(somaDosselFinal);

  double get mediaDiferencaPercentual => _media(somaDiferencaPercentual);

  String get principalErro {
    if (errosSegmentacao.isEmpty) {
      return 'Nao informado';
    }

    var erroEscolhido = errosSegmentacao.keys.first;
    var maiorFrequencia = errosSegmentacao.values.first;

    for (final entrada in errosSegmentacao.entries.skip(1)) {
      if (entrada.value > maiorFrequencia) {
        erroEscolhido = entrada.key;
        maiorFrequencia = entrada.value;
      }
    }

    return erroEscolhido;
  }

  double _media(double soma) {
    if (quantidade == 0) {
      return 0;
    }

    return soma / quantidade;
  }
}
