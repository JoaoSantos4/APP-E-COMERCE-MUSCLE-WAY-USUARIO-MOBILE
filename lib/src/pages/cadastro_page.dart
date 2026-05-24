import 'package:pi/src/database/usuario_database.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/widgets/botao_widget.dart';
import 'package:pi/src/widgets/brand_logo_widget.dart';
import 'package:pi/src/widgets/campo_formulario_widget.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> cadastrar() async {
    if (!formKey.currentState!.validate()) return;

    final sucesso = await UsuarioDatabase.cadastrarUsuario(
      nome: nomeController.text,
      email: emailController.text,
      senha: senhaController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UsuÃ¡rio cadastrado com sucesso!'),
          backgroundColor: AppTheme.success,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este e-mail jÃ¡ estÃ¡ cadastrado.'),
        backgroundColor: AppTheme.danger,
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BrandLogoWidget(iconSize: 36)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cadastre-se para salvar seu carrinho e receber sugestÃµes da IA.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                ),
                const SizedBox(height: 26),
                CampoFormularioWidget(
                  label: 'Nome',
                  icon: Icons.person_outline,
                  controller: nomeController,
                  obscure: false,
                  validatorless: Validatorless.required('Campo obrigatÃ³rio'),
                ),
                const SizedBox(height: 16),
                CampoFormularioWidget(
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  obscure: false,
                  validatorless: Validatorless.multiple([
                    Validatorless.required('Campo obrigatÃ³rio'),
                    Validatorless.email('E-mail invÃ¡lido'),
                  ]),
                ),
                const SizedBox(height: 16),
                CampoFormularioWidget(
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  controller: senhaController,
                  obscure: true,
                  validatorless: Validatorless.multiple([
                    Validatorless.required('Campo obrigatÃ³rio'),
                    Validatorless.min(8, 'MÃ­nimo 8 caracteres'),
                  ]),
                ),
                const SizedBox(height: 16),
                CampoFormularioWidget(
                  label: 'Confirmar senha',
                  icon: Icons.lock_reset,
                  controller: confirmarSenhaController,
                  obscure: true,
                  validatorless: Validatorless.multiple([
                    Validatorless.required('Campo obrigatÃ³rio'),
                    Validatorless.compare(
                      senhaController,
                      'As senhas sÃ£o diferentes',
                    ),
                  ]),
                ),
                const SizedBox(height: 26),
                BotaoWidget(
                  title: 'Cadastrar',
                  icon: Icons.person_add_alt_1,
                  onClick: cadastrar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

