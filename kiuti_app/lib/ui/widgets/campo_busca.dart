import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
const _semAcento = 'aaaaaeeeeiiiiooooouuuuc';

String _normalizar(String texto) {
  final b = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    final i = _comAcento.indexOf(c);
    b.write(i < 0 ? c : _semAcento[i]);
  }
  return b.toString();
}

/// True se [nome] contém [busca], sem diferenciar maiúsculas nem acentos. Busca vazia casa com tudo.
bool combinaComBusca(String nome, String busca) => _normalizar(nome).contains(_normalizar(busca.trim()));

/// Barra de pesquisa rosa com lupa e botão de limpar. Quem usa guarda o texto em [aoMudar].
class CampoBusca extends StatefulWidget {
  const CampoBusca({super.key, required this.aoMudar, this.dica = 'Buscar'});

  final ValueChanged<String> aoMudar;
  final String dica;

  @override
  State<CampoBusca> createState() => _CampoBuscaState();
}

class _CampoBuscaState extends State<CampoBusca> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _limpar() {
    _controller.clear();
    widget.aoMudar('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.aoMudar,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.dica,
        prefixIcon: const Icon(Icons.search, color: Cores.cinza),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(icon: const Icon(Icons.close), onPressed: _limpar),
        ),
        filled: true,
        fillColor: Cores.rosaClaro,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
