import 'package:image/image.dart' as img;

/// Histórico simples de estados da máscara para desfazer e refazer.
///
/// A Fase 7 usa pilhas de imagens em memória. Cada estado é copiado antes de
/// entrar no histórico para evitar que edições futuras alterem estados antigos.
class HistoricoEdicaoService {
  HistoricoEdicaoService({this.limiteEstados = 20}) : assert(limiteEstados > 0);

  final int limiteEstados;
  final List<img.Image> _desfazer = [];
  final List<img.Image> _refazer = [];

  bool get podeDesfazer => _desfazer.isNotEmpty;
  bool get podeRefazer => _refazer.isNotEmpty;
  int get quantidadeDesfazer => _desfazer.length;
  int get quantidadeRefazer => _refazer.length;

  /// Adiciona um estado antes de uma nova edição.
  ///
  /// Qualquer nova edição invalida a pilha de refazer, como esperado em
  /// editores visuais simples.
  void adicionarEstado(img.Image estado) {
    _desfazer.add(_copiar(estado));
    if (_desfazer.length > limiteEstados) {
      _desfazer.removeAt(0);
    }
    _refazer.clear();
  }

  /// Retorna o estado anterior da máscara, quando existir.
  img.Image? desfazer(img.Image estadoAtual) {
    if (!podeDesfazer) {
      return null;
    }

    _refazer.add(_copiar(estadoAtual));
    return _desfazer.removeLast();
  }

  /// Retorna um estado refeito, quando existir.
  img.Image? refazer(img.Image estadoAtual) {
    if (!podeRefazer) {
      return null;
    }

    _desfazer.add(_copiar(estadoAtual));
    if (_desfazer.length > limiteEstados) {
      _desfazer.removeAt(0);
    }
    return _refazer.removeLast();
  }

  void limpar() {
    _desfazer.clear();
    _refazer.clear();
  }

  img.Image _copiar(img.Image estado) {
    return estado.clone(noAnimation: true);
  }
}
