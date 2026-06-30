import '../../domain/domain.dart';

/// Guarda temporariamente a análise em andamento durante o fluxo de captura,
/// processamento e validação.
///
/// Este serviço evita que nome, observações e identificador da análise se
/// percam quando o Android recria a tela após abrir a câmera. Ele não persiste
/// imagens nem resultados; arquivos continuam separados e a imagem original
/// permanece preservada.
class AnaliseEmAndamentoService {
  AnaliseEmAndamentoService();

  static final AnaliseEmAndamentoService instancia =
      AnaliseEmAndamentoService();

  Analise? _analise;

  /// Armazena a análise que ainda não foi salva definitivamente no SQLite.
  void guardarAnalise(Analise analise) {
    _analise = analise;
  }

  /// Recupera a análise em andamento, quando existir.
  Analise? recuperarAnalise() {
    return _analise;
  }

  /// Remove o estado temporário após salvamento ou encerramento do fluxo.
  void limpar() {
    _analise = null;
  }
}
