import 'package:cobertura_dossel/application/application.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('adiciona estado ao histórico de desfazer', () {
    final historico = HistoricoEdicaoService();

    historico.adicionarEstado(_criarImagemComVermelho(10));

    expect(historico.podeDesfazer, isTrue);
    expect(historico.quantidadeDesfazer, 1);
  });

  test('desfaz para o estado anterior da máscara', () {
    final historico = HistoricoEdicaoService();
    final estadoAnterior = _criarImagemComVermelho(10);
    final estadoAtual = _criarImagemComVermelho(200);
    historico.adicionarEstado(estadoAnterior);

    final restaurado = historico.desfazer(estadoAtual);

    expect(restaurado, isNotNull);
    expect(restaurado!.getPixel(0, 0).r.toInt(), 10);
    expect(historico.podeRefazer, isTrue);
  });

  test('refaz estado desfeito', () {
    final historico = HistoricoEdicaoService();
    final estadoAnterior = _criarImagemComVermelho(10);
    final estadoAtual = _criarImagemComVermelho(200);
    historico.adicionarEstado(estadoAnterior);
    final restaurado = historico.desfazer(estadoAtual);

    final refeito = historico.refazer(restaurado!);

    expect(refeito, isNotNull);
    expect(refeito!.getPixel(0, 0).r.toInt(), 200);
  });

  test('limpa refazer após nova edição', () {
    final historico = HistoricoEdicaoService();
    final estadoAnterior = _criarImagemComVermelho(10);
    final estadoAtual = _criarImagemComVermelho(200);
    historico.adicionarEstado(estadoAnterior);
    historico.desfazer(estadoAtual);

    historico.adicionarEstado(_criarImagemComVermelho(30));

    expect(historico.podeRefazer, isFalse);
  });

  test('respeita limite de estados', () {
    final historico = HistoricoEdicaoService(limiteEstados: 2);

    historico.adicionarEstado(_criarImagemComVermelho(10));
    historico.adicionarEstado(_criarImagemComVermelho(20));
    historico.adicionarEstado(_criarImagemComVermelho(30));

    expect(historico.quantidadeDesfazer, 2);
    final primeiroRestaurado = historico.desfazer(_criarImagemComVermelho(40));
    final segundoRestaurado = historico.desfazer(primeiroRestaurado!);

    expect(primeiroRestaurado.getPixel(0, 0).r.toInt(), 30);
    expect(segundoRestaurado!.getPixel(0, 0).r.toInt(), 20);
  });
}

img.Image _criarImagemComVermelho(int vermelho) {
  final imagem = img.Image(width: 1, height: 1, numChannels: 4);
  imagem.setPixelRgba(0, 0, vermelho, 0, 0, 255);
  return imagem;
}
