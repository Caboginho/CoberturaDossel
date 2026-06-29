import '../../domain/entities/analise.dart';
import 'mapper_utils.dart';

/// Converte a entidade [Analise] para o formato usado pela tabela `analises`.
///
/// O mapper mantém no banco apenas dados textuais, datas, versão de algoritmo e
/// estado de validação. Relações com imagem, máscaras e resultados são gravadas
/// por seus próprios repositórios.
class AnaliseMapper {
  const AnaliseMapper._();

  static Map<String, dynamic> paraMapa(Analise analise) {
    return {
      'id': analise.id,
      'nome': analise.nome,
      'data_criacao': dataParaTexto(analise.dataCriacao),
      'data_atualizacao': dataParaTexto(analise.dataAtualizacao),
      'observacoes': analise.observacoes,
      'versao_algoritmo': analise.versaoAlgoritmo,
      'status_validacao': boolParaInteiro(analise.statusValidacao),
    };
  }

  static Analise deMapa(Map<String, dynamic> mapa) {
    return Analise(
      id: mapa['id'] as String,
      nome: mapa['nome'] as String,
      dataCriacao: textoParaData(mapa['data_criacao']),
      dataAtualizacao: textoParaData(mapa['data_atualizacao']),
      observacoes: mapa['observacoes'] as String? ?? '',
      versaoAlgoritmo: mapa['versao_algoritmo'] as String? ?? '',
      statusValidacao: inteiroParaBool(mapa['status_validacao']),
    );
  }
}
