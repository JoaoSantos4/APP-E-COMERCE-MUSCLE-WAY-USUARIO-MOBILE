import 'package:pi/src/database/produto_database.dart';
import 'package:pi/src/models/chat_mensagem_model.dart';
import 'package:pi/src/models/produto_model.dart';
import 'package:pi/src/services/assistente_suplementos_service.dart';
import 'package:pi/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChatIaPage extends StatefulWidget {
  const ChatIaPage({super.key});

  @override
  State<ChatIaPage> createState() => _ChatIaPageState();
}

class _ChatIaPageState extends State<ChatIaPage> {
  final mensagemController = TextEditingController();
  final scrollController = ScrollController();

  List<ProdutoModel> produtos = [];
  bool carregando = true;
  bool respondendo = false;
  final mensagens = <ChatMensagemModel>[
    const ChatMensagemModel(
      texto:
          'OlÃ¡! Sou o consultor Muscleway IA. Me conte seu objetivo e eu indico produtos do catÃ¡logo.',
      enviadaPeloUsuario: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    await ProdutoDatabase.inserirProdutosExemplo();
    final lista = await ProdutoDatabase.listarProdutos();

    if (!mounted) return;

    setState(() {
      produtos = lista;
      carregando = false;
    });
  }

  Future<void> enviarMensagem([String? textoRapido]) async {
    final texto = (textoRapido ?? mensagemController.text).trim();

    if (texto.isEmpty || carregando || respondendo) return;

    mensagemController.clear();

    setState(() {
      respondendo = true;
      mensagens.add(ChatMensagemModel(texto: texto, enviadaPeloUsuario: true));
    });

    try {
      final resposta = await AssistenteSuplementosService.responder(
        pergunta: texto,
        produtos: produtos,
      );

      if (!mounted) return;

      setState(() {
        mensagens.add(
          ChatMensagemModel(texto: resposta, enviadaPeloUsuario: false),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          respondendo = false;
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    mensagemController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultor IA')),
      body: Column(
        children: [
          _cabecalho(),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(18),
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      return _MensagemBolha(mensagem: mensagens[index]);
                    },
                  ),
          ),
          _atalhos(),
          if (respondendo)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Consultor pensando...',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          _campoMensagem(),
        ],
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surface, Color(0xFF102332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.primary, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muscleway IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'SugestÃµes por objetivo: massa, energia, emagrecimento, recuperaÃ§Ã£o ou imunidade.',
                  style: TextStyle(color: AppTheme.textMuted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _atalhos() {
    const atalhos = [
      'Quero ganhar massa',
      'Quero emagrecer',
      'Preciso de energia',
      'RecuperaÃ§Ã£o muscular',
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: atalhos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final atalho = atalhos[index];

          return ActionChip(
            onPressed: () => enviarMensagem(atalho),
            avatar: const Icon(
              Icons.flash_on,
              size: 18,
              color: AppTheme.primary,
            ),
            label: Text(atalho),
            backgroundColor: AppTheme.surface,
            side: const BorderSide(color: AppTheme.border),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  Widget _campoMensagem() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: mensagemController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => enviarMensagem(),
                decoration: const InputDecoration(
                  hintText: 'Ex: quero ganhar massa e ter energia',
                  prefixIcon: Icon(Icons.psychology_outlined),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: FilledButton(
                onPressed: respondendo ? null : enviarMensagem,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensagemBolha extends StatelessWidget {
  final ChatMensagemModel mensagem;

  const _MensagemBolha({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final enviada = mensagem.enviadaPeloUsuario;

    return Align(
      alignment: enviada ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enviada ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(enviada ? 18 : 4),
            bottomRight: Radius.circular(enviada ? 4 : 18),
          ),
          border: enviada ? null : Border.all(color: AppTheme.border),
        ),
        child: Text(
          mensagem.texto,
          style: TextStyle(
            color: enviada ? const Color(0xFF061017) : Colors.white,
            height: 1.35,
            fontWeight: enviada ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

