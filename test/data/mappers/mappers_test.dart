import 'package:cobertura_dossel/data/data.dart';
import 'package:cobertura_dossel/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../entidades_teste.dart';

void main() {
  group('mapeadores da Fase 2', () {
    test(
      'converte análise para mapa e mapa para análise preservando os dados',
      () {
        final analise = criarAnaliseTeste();

        final mapa = AnaliseMapper.paraMapa(analise);
        final restaurada = AnaliseMapper.deMapa(mapa);

        expect(mapa['id'], 'analise-1');
        expect(mapa['status_validacao'], 0);
        expect(restaurada.nome, analise.nome);
        expect(restaurada.versaoAlgoritmo, analise.versaoAlgoritmo);
      },
    );

    test(
      'converte imagem preservando apenas caminho e metadados do arquivo original',
      () {
        final imagem = criarImagemTeste();

        final mapa = ImagemMapper.paraMapa(imagem);
        final restaurada = ImagemMapper.deMapa(mapa);

        expect(mapa['caminho_arquivo'], imagem.caminhoArquivo);
        expect(restaurada.origem, OrigemImagem.arquivo);
        expect(restaurada.caminhoArquivo, imagem.caminhoArquivo);
      },
    );

    test('converte máscara com contagens de pixels e caminho separado', () {
      final mascara = criarMascaraTeste();

      final mapa = MascaraMapper.paraMapa(mascara);
      final restaurada = MascaraMapper.deMapa(mapa);

      expect(mapa['tipo_mascara'], TipoMascara.automatica.name);
      expect(restaurada.pixelsValidos, 900000);
      expect(restaurada.caminhoArquivo, mascara.caminhoArquivo);
    });

    test('converte resultado mantendo vínculo com análise e máscara', () {
      final resultado = criarResultadoTeste();

      final mapa = ResultadoAnaliseMapper.paraMapa(resultado);
      final restaurado = ResultadoAnaliseMapper.deMapa(mapa);

      expect(mapa['tipo_resultado'], TipoMascara.automatica.name);
      expect(restaurado.analiseId, resultado.analiseId);
      expect(restaurado.percentualDossel, 50);
    });

    test('converte metadados de campo', () {
      final metadados = criarMetadadosTeste();

      final mapa = MetadadosAnaliseMapper.paraMapa(metadados);
      final restaurados = MetadadosAnaliseMapper.deMapa(mapa);

      expect(mapa['condicao_ceu'], CondicaoCeu.parcialmenteNublado.name);
      expect(restaurados.tipoAmbiente, TipoAmbiente.floresta);
      expect(restaurados.observacoesCampo, metadados.observacoesCampo);
    });

    test('converte edição de máscara como ação auditável sobre a máscara', () {
      final edicao = criarEdicaoTeste();

      final mapa = EdicaoMascaraMapper.paraMapa(edicao);
      final restaurada = EdicaoMascaraMapper.deMapa(mapa);

      expect(mapa['classe_aplicada'], ClassePixel.naoCeu.name);
      expect(restaurada.mascaraId, edicao.mascaraId);
      expect(restaurada.tamanhoPincel, 12);
    });

    test(
      'converte item de dataset sem ativar inteligência artificial no MVP',
      () {
        final item = criarItemDatasetTeste();

        final mapa = ItemDatasetTreinamentoMapper.paraMapa(item);
        final restaurado = ItemDatasetTreinamentoMapper.deMapa(mapa);

        expect(mapa['autorizado'], 1);
        expect(restaurado.autorizado, isTrue);
        expect(restaurado.caminhoImagemOriginal, item.caminhoImagemOriginal);
      },
    );
  });
}
