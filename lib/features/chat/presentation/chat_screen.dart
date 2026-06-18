import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_theme.dart';
import 'chat_provider.dart';
import '../domain/chat_message.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final chatNotifier = ref.watch(chatProvider.notifier);
    
    // Auto scroll when new messages arrive
    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi AI'),
        backgroundColor: AppTheme.backgroundLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined, color: AppTheme.textDark),
            tooltip: 'Hapus Riwayat',
            onPressed: () {
              ref.read(chatProvider.notifier).resetHistory();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(context, message, chatNotifier);
              },
            ),
          ),
          if (chatNotifier.isLoading)
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TypingIndicator(),
              ),
            ),
          _buildInputArea(chatNotifier),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, ChatNotifier chatNotifier) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.darkPastelGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
                border: isUser ? null : Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: AppTheme.textDark, fontSize: 16, height: 1.5),
                        strong: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
                        em: const TextStyle(color: AppTheme.textDark, fontStyle: FontStyle.italic),
                        listBullet: const TextStyle(color: AppTheme.darkPastelPink),
                      ),
                    ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'Analisis psikologi AI bisa saja tidak akurat, komunikasikan juga dengan pasangan.',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (!isUser)
              InkWell(
                onTap: message.isSaved ? null : () async {
                  final titleController = TextEditingController();
                  final title = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      title: const Text('Simpan ke Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan judul artikel...',
                          filled: true,
                          fillColor: AppTheme.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal', style: TextStyle(color: AppTheme.textLight)),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, titleController.text),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.darkPastelGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );

                  if (title == null || title.trim().isEmpty) return;

                  try {
                    await chatNotifier.saveToArticle(message.id, title.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tersimpan di Artikel!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menyimpan artikel')),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        message.isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                        size: 16,
                        color: message.isSaved ? AppTheme.darkPastelGreen : AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.isSaved ? 'Tersimpan' : 'Tambah ke Artikel',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: message.isSaved ? AppTheme.darkPastelGreen : AppTheme.textLight,
                          fontWeight: message.isSaved ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatNotifier chatNotifier) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildPillTip('Mood Swing', Icons.mood_bad, chatNotifier),
              _buildPillTip('Arti Terserah', Icons.question_mark, chatNotifier),
              _buildPillTip('Jadwal PMS', Icons.calendar_month, chatNotifier),
              _buildPillTip('Cara Minta Maaf', Icons.volunteer_activism, chatNotifier),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesanmu...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      chatNotifier.sendMessage(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.darkPastelGreen,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      chatNotifier.sendMessage(_controller.text);
                      _controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillTip(String text, IconData icon, ChatNotifier chatNotifier) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppTheme.darkPastelPink),
        label: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.darkPastelPink.withAlpha(50)),
        ),
        onPressed: () {
          chatNotifier.sendMessage("Ceritakan tentang $text");
        },
      ),
    );
  }
}
