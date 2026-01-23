import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/views/home_view.dart';
import '../../features/timeline/views/timeline_view.dart';
import '../../features/letters/views/letters_view.dart';
import '../../features/letters/views/letter_detail_view.dart';
import '../../features/letters/views/letter_editor_view.dart';
import '../../features/world/views/world_view.dart';
import '../../features/create/views/create_moment_view.dart';
import '../../features/timeline/views/moment_detail_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../shared/widgets/main_scaffold.dart';

/// 全局路由 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // 主 Shell 路由 - 带底部导航
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomeView(),
                  transitionsBuilder: _fadeTransition,
                ),
          ),
          GoRoute(
            path: '/timeline',
            name: 'timeline',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const TimelineView(),
                  transitionsBuilder: _fadeTransition,
                ),
          ),
          GoRoute(
            path: '/letters',
            name: 'letters',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const LettersView(),
                  transitionsBuilder: _fadeTransition,
                ),
          ),
          GoRoute(
            path: '/world',
            name: 'world',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const WorldView(),
                  transitionsBuilder: _fadeTransition,
                ),
          ),
        ],
      ),

      // 独立页面路由（无底部导航）
      GoRoute(
        path: '/create',
        name: 'create',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CreateMomentView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/moment/:id',
        name: 'momentDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: MomentDetailView(momentId: id),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),

      GoRoute(
        path: '/letter/:id',
        name: 'letterDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LetterDetailView(letterId: id),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),

      GoRoute(
        path: '/letter/:id/edit',
        name: 'letterEditor',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LetterEditorView(letterId: id),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),
    ],
  );
});

/// 淡入淡出过渡 - 用于标签页切换
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    child: child,
  );
}

/// 底部滑入过渡 - 用于模态页面
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  final fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOut,
  );

  return SlideTransition(
    position: slideAnimation,
    child: FadeTransition(opacity: fadeAnimation, child: child),
  );
}
