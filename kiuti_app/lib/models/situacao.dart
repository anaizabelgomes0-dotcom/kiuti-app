/// Situação do produto (contrato: "na_meta", "abaixo_da_meta", "ficha_incompleta").
enum Situacao {
  naMeta,
  abaixoDaMeta,
  fichaIncompleta;

  static Situacao deTexto(String texto) => switch (texto) {
        'na_meta' => Situacao.naMeta,
        'abaixo_da_meta' => Situacao.abaixoDaMeta,
        _ => Situacao.fichaIncompleta,
      };
}
