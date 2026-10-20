import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:kiuti_app/models/configuracao.dart';
import 'package:kiuti_app/providers/configuracao_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/auth_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final Map<String, TextEditingController> _campos = {
    for (final chave in Configuracao.chaves)
      chave: TextEditingController(),
  };

  final Map<String, String> _erros = {};
  bool _salvando = false;
  bool _preenchido = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    for (final campo in _campos.values) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _carregar() async {
    await context.read<ConfiguracaoProvider>().carregar();
    if (!mounted) return;

    final config = context.read<ConfiguracaoProvider>().config;
    if (config == null) return;

    for (final chave in Configuracao.chaves) {
      _campos[chave]!.text =
          (config.valores[chave] ?? 0).toStringAsFixed(2).replaceAll('.', ',');
    }

    setState(() => _preenchido = true);
  }

  double? _numero(String texto) {
    final normalizado = texto.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalizado);
  }

  Future<void> _salvar() async {
    final config = context.read<ConfiguracaoProvider>().config;
    if (config == null) return;

    _erros.clear();
    final mudancas = <String, double>{};

    for (final chave in Configuracao.chaves) {
      final valor = _numero(_campos[chave]!.text);

      if (valor == null) {
        _erros[chave] = 'Informe um número válido.';
      } else if (valor < 0) {
        _erros[chave] = 'O valor não pode ser negativo.';
      } else if (chave == 'perc_taxa_shopee' && valor >= 100) {
        _erros[chave] = 'A taxa deve ser menor que 100%.';
      } else if (valor != config.valores[chave]) {
        mudancas[chave] = valor;
      }
    }

    setState(() {});
    if (_erros.isNotEmpty) return;

    if (mudancas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nada mudou.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      await context.read<ConfiguracaoProvider>().salvar(mudancas);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas.')),
      );
      await _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensagem)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _campo(String chave, String rotulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _campos[chave],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: rotulo,
          border: const OutlineInputBorder(),
          errorText: _erros[chave],
        ),
        onChanged: (_) {
          if (_erros.containsKey(chave)) {
            setState(() => _erros.remove(chave));
          }
        },
      ),
    );
  }

  Future<void> _sair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    await context.read<AuthService>().sair();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfiguracaoProvider>();

    if (provider.carregando && !_preenchido) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null && !_preenchido) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.erro!),
            ElevatedButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Taxas da Shopee',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _campo('perc_taxa_shopee', 'Percentual (%)'),
          _campo('taxa_fixa_shopee', 'Taxa fixa por venda (R\$)'),
          const SizedBox(height: 8),
          const Text(
            'Custos padrão por produto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _campo('embalagem_padrao', 'Embalagem (R\$)'),
          _campo('brinde_padrao', 'Brinde (R\$)'),
          _campo('envio_padrao', 'Envio (R\$)'),
          _campo('despesas_variaveis_padrao', 'Despesas variáveis (R\$)'),
          const SizedBox(height: 8),
          const Text(
            'Lucro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _campo('perc_lucro_padrao', 'Margem padrão (%)'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _salvando ? null : _salvar,
            child: Text(_salvando ? 'Salvando...' : 'Salvar configurações'),
          ),
          TextButton.icon(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}
