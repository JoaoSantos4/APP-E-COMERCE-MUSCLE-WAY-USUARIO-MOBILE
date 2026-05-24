import 'package:pi/src/controllers/sessao_controller.dart';
import 'package:pi/src/database/usuario_database.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:pi/src/widgets/botao_widget.dart';
import 'package:pi/src/widgets/brand_logo_widget.dart';
import 'package:pi/src/widgets/campo_formulario_widget.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> acessar() async {
    if (!formKey.currentState!.validate()) return;

    final usuario = await UsuarioDatabase.buscarUsuarioPorLogin(
      email: emailController.text,
      senha: passwordController.text,
    );

    if (!mounted) return;

    if (usuario != null) {
      SessaoController.entrar(usuario);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-mail ou senha invÃ¡lidos.'),
        backgroundColor: AppTheme.danger,
      ),
    );
  }

  void cadastrar() {
    Navigator.pushNamed(context, '/cadastro');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                const BrandLogoWidget(iconSize: 64),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entre na sua conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acesse ofertas, recomendaÃ§Ãµes e seu carrinho Muscleway.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                        controller: passwordController,
                        obscure: true,
                        validatorless: Validatorless.required(
                          'Campo obrigatÃ³rio',
                        ),
                      ),
                      const SizedBox(height: 24),
                      BotaoWidget(
                        title: 'Entrar',
                        icon: Icons.login,
                        onClick: acessar,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: TextButton(
                    onPressed: cadastrar,
                    child: const Text(
                      'Criar uma conta Muscleway',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const _LoginBenefitStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginBenefitStrip extends StatelessWidget {
  const _LoginBenefitStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.workspace_premium_outlined, color: AppTheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Produtos selecionados, compra segura e sugestÃµes inteligentes.',
              style: TextStyle(color: AppTheme.textMuted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

