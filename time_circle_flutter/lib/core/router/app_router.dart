import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'transitions.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/circle_setup_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/splash/views/splash_view.dart';
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
import '../../features/settings/views/about_view.dart';
import '../../features/settings/views/feedback_view.dart';
import '../../shared/widgets/main_scaffold.dart';

/// 全局路由 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // 启动页 - 无底部导航
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder:
            (context, state) => AuraPageTransitions.fade(
              key: state.pageKey,
              child: const SplashView(),
              name: 'splash',
            ),
      ),

      // 登录页
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder:
            (context, state) => AuraPageTransitions.fade(
              key: state.pageKey,
              child: const LoginView(),
              name: 'login',
            ),
      ),

      // 注册页
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const RegisterView(),
              name: 'register',
            ),
      ),

      // 圈子设置页（创建/加入圈子）
      GoRoute(
        path: '/circle-setup',
        name: 'circleSetup',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const CircleSetupView(),
              name: 'circleSetup',
            ),
      ),

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
                (context, state) => AuraPageTransitions.fade(
                  key: state.pageKey,
                  child: const HomeView(),
                  name: 'home',
                ),
          ),
          GoRoute(
            path: '/timeline',
            name: 'timeline',
            pageBuilder:
                (context, state) => AuraPageTransitions.fade(
                  key: state.pageKey,
                  child: const TimelineView(),
                  name: 'timeline',
                ),
          ),
          GoRoute(
            path: '/letters',
            name: 'letters',
            pageBuilder:
                (context, state) => AuraPageTransitions.fade(
                  key: state.pageKey,
                  child: const LettersView(),
                  name: 'letters',
                ),
          ),
          GoRoute(
            path: '/world',
            name: 'world',
            pageBuilder:
                (context, state) => AuraPageTransitions.fade(
                  key: state.pageKey,
                  child: const WorldView(),
                  name: 'world',
                ),
          ),
        ],
      ),

      // 详情页 - 使用滑动上入动画
      GoRoute(
        path: '/moment/:id',
        name: 'momentDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AuraPageTransitions.slideUp(
            key: state.pageKey,
            child: MomentDetailView(momentId: id),
            name: 'momentDetail',
          );
        },
      ),

      GoRoute(
        path: '/letter/:id',
        name: 'letterDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AuraPageTransitions.slideUp(
            key: state.pageKey,
            child: LetterDetailView(letterId: id),
            name: 'letterDetail',
          );
        },
      ),

      GoRoute(
        path: '/letter/:id/edit',
        name: 'letterEditor',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AuraPageTransitions.slideUp(
            key: state.pageKey,
            child: LetterEditorView(letterId: id),
            name: 'letterEditor',
          );
        },
      ),

      // 设置页 - 使用滑动上入动画
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const SettingsView(),
              name: 'settings',
            ),
      ),

      // 设置子页面路由
      GoRoute(
        path: '/settings/profile',
        name: 'profileEdit',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const ProfileEditView(),
              name: 'profileEdit',
            ),
      ),

      GoRoute(
        path: '/settings/circle',
        name: 'circleInfo',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const CircleInfoView(),
              name: 'circleInfo',
            ),
      ),

      GoRoute(
        path: '/settings/members',
        name: 'members',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const MembersView(),
              name: 'members',
            ),
      ),

      GoRoute(
        path: '/settings/visibility',
        name: 'visibility',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const VisibilityView(),
              name: 'visibility',
            ),
      ),

      GoRoute(
        path: '/settings/time-lock',
        name: 'timeLock',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const TimeLockView(),
              name: 'timeLock',
            ),
      ),

      GoRoute(
        path: '/settings/export',
        name: 'export',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const ExportView(),
              name: 'export',
            ),
      ),

      GoRoute(
        path: '/settings/about',
        name: 'about',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const AboutView(),
              name: 'about',
            ),
      ),

      GoRoute(
        path: '/settings/feedback',
        name: 'feedback',
        pageBuilder:
            (context, state) => AuraPageTransitions.slideUp(
              key: state.pageKey,
              child: const FeedbackView(),
              name: 'feedback',
            ),
      ),
    ],
  );
});
