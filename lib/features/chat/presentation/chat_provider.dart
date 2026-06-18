import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/chat_message.dart';
import '../data/groq_service.dart';
import '../../articles/data/supabase_service.dart';

final groqServiceProvider = Provider((ref) => GroqService());

class ChatNotifier extends Notifier<List<ChatMessage>> {
  bool _isLoading = false;

  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        id: const Uuid().v4(),
        text: 'Halo! Aku Dita, konsultan spesialismu. Ada yang mau kamu tanyakan tentang pasanganmu? Misalnya soal mood swing, cara mengartikan "terserah", atau jadwal PMS-nya?',
        isUser: false,
      )
    ];
  }

  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text.trim(),
      isUser: true,
    );
    
    state = [...state, userMsg];
    _isLoading = true;
    // We can't trigger a rebuild just for _isLoading if it's not part of the state,
    // but typically we'd use an AsyncValue or a separate provider for loading.
    // For simplicity, we just notify listeners if we can, or just let the new message trigger rebuild.
    // Riverpod Notifier doesn't have a built-in notifyListeners() for side properties. 
    // To make isLoading reactive, let's create a separate provider or include it in state.
    // However, since we just need it simple, I'll update state with a temporary copy to trigger rebuild, or just ref.notifyListeners().
    // Actually, to make isLoading work correctly with Notifier without changing the type, we should just manage it via ref.invalidateSelf() or similar.
    // But since the new message already triggers a rebuild, the UI will see isLoading=true.
    // Wait, let's just make it a separate provider if needed, or leave it as is, because adding to `state` triggers a rebuild anyway.
    
    // Create history for Groq
    final history = state.map((m) => {
      'role': m.isUser ? 'user' : 'assistant',
      'content': m.text
    }).toList();
    // Remove the latest user message because it'll be appended in the service
    history.removeLast();

    try {
      final reply = await ref.read(groqServiceProvider).sendMessage(text, history);
      final aiMsg = ChatMessage(
        id: const Uuid().v4(),
        text: reply,
        isUser: false,
      );
      _isLoading = false;
      state = [...state, aiMsg];
    } catch (e) {
      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        text: 'Maaf, terjadi kesalahan saat menghubungi AI. Silakan coba lagi. (${e.toString()})',
        isUser: false,
      );
      _isLoading = false;
      state = [...state, errorMsg];
    }
  }

  Future<void> saveToArticle(String messageId) async {
    final msgIndex = state.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final msg = state[msgIndex];
    if (msg.isSaved) return;

    try {
      await ref.read(supabaseServiceProvider).saveArticle(msg.text);
      
      // Update state to marked as saved
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == msgIndex) state[i].copyWith(isSaved: true) else state[i]
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error saving article: $e');
      }
      rethrow;
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});
