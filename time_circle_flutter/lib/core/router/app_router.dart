import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/views/home_view.dart';
import '../../features/timeline/views/timeline_view.dart';
import '../../features/letters/views/letters_view.dart';
import '../../features/letters/views/letter_detail_view.dart';
import '../../features/letters/views/letter_editor_view.dart';
import '../../features/world/views/world_view.dart';
import '../../features/timeline/views/moment_detail_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/settings/views/profile_edit_view.dart';
import '../../features/settings/views/circle_info_view.dart';
import '../../features/settings/views/members_view.dart';
import '../../features/settings/views/visibility_view.dart';
import '../../features/settings/views/time_lock_view.dart';
import '../../features/settings/views/export_view.dart';
import '../../features/settings/views/backup_view.dart';
import '../../features/settings/views/about_view.dart';
import '../../features/settings/views/feedback_view.dart';
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

      // 设置子页面路由
      GoRoute(
        path: '/settings/profile',
        name: 'profileEdit',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileEditView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/circle',
        name: 'circleInfo',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CircleInfoView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/members',
        name: 'members',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MembersView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/visibility',
        name: 'visibility',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const VisibilityView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/time-lock',
        name: 'timeLock',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TimeLockView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/export',
        name: 'export',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExportView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/backup',
        name: 'backup',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BackupView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/about',
        name: 'about',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AboutView(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      GoRoute(
        path: '/settings/feedback',
        name: 'feedback',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FeedbackView(),
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
