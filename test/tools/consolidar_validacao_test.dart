import 'package:flutter_test/flutter_test.dart';

import '../../tools/validacao/consolidar_validacao.dart';

void main() {
  group('consolidarValidacaoCsv', () {
    test('agrupa registros por grupo visual e calcula medias de dossel', () {
      const csv = '''
id_imagem,nome_arquivo,grupo_visual,percentual_dossel_automatico,percentual_dossel_final,diferenca_percentual,principais_erros_segmentacao
IMG_001,CD_CEU_AZUL_001_CAMPO.jpg,ceu_azul,55.0,58.0,3.0,"bordas finas em galhos"
IMG_002,CD_CEU_AZUL_002_CAMPO.jpg,ceu_azul,45.0,50.0,5.0,"bordas finas em galhos"
IMG_003,CD_FOLHAS_CLARAS_001_CAMPO.jpg,folhas_claras,40.0,52.0,12.0,"folhas claras classificadas como ceu"
''';

      final tabela = consolidarValidacaoCsv(csv);

      expect(
        tabela,
        contains(
          '| ceu_azul | 2 | 50.00 | 54.00 | 4.00 | bordas finas em galhos |',
        ),
      );
      expect(
        tabela,
        contains(
          '| folhas_claras | 1 | 40.00 | 52.00 | 12.00 | folhas claras classificadas como ceu |',
        ),
      );
    });

    test('interpreta campos entre aspas com virgulas nas observacoes', () {
      const csv = '''
id_imagem,grupo_visual,percentual_dossel_automatico,percentual_dossel_final,diferenca_percentual,principais_erros_segmentacao
IMG_001,bordas_complexas,61.5,65.5,4.0,"galhos finos, folhas claras"
''';

      final registros = lerCsvValidacao(csv);

      expect(registros, hasLength(1));
      expect(
        registros.first['principais_erros_segmentacao'],
        'galhos finos, folhas claras',
      );
    });
  });
}
