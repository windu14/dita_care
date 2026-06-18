import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/articles/presentation/articles_screen.dart';
import '../../features/articles/presentation/article_detail_screen.dart';
import '../../features/data_cewe/presentation/data_cewe_screen.dart';
import '../../features/data_cewe/presentation/form_data_cewe_screen.dart';

import '../presentation/main_scaffold.dart';
import '../presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/articles',
                name: 'articles',
                builder: (context, state) => const ArticlesScreen(),
                routes: [
                  GoRoute(
                    path: 'article-detail',
                    builder: (context, state) {
                      final article = state.extra as Map<String, dynamic>;
                      return ArticleDetailScreen(article: article);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/data-cewe',
                name: 'data-cewe',
                builder: (context, state) => const DataCeweScreen(),
                routes: [
                  GoRoute(
                    path: 'form',
                    builder: (context, state) => const FormDataCeweScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
