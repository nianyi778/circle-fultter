/// API 配置
///
/// 存储 API 相关的配置信息
class ApiConfig {
  ApiConfig._();

  /// API 基础 URL
  static const String baseUrl = 'https://aura-api.nianyi778.workers.dev';

  /// API 版本
  static const String apiVersion = 'v1';

  /// 请求超时时间（毫秒）
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 60000;

  /// Token 相关
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  /// 同步相关
  static const String lastSyncTimestampKey = 'last_sync_timestamp';
  static const String currentCircleIdKey = 'current_circle_id';

  /// 圈子选择相关
  static const String selectedCircleKey = 'selected_circle_id';

  /// 端点路径
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authPassword = '/auth/password';

  static const String circles = '/circles';
  static String circle(String id) => '/circles/$id';
  static String circleInvite(String id) => '/circles/$id/invite';
  static const String circleJoin = '/circles/join';
  static String circleMembers(String id) => '/circles/$id/members';
  static String circleMoments(String circleId) => '/circles/$circleId/moments';
  static String circleLetters(String circleId) => '/circles/$circleId/letters';

  static String moment(String id) => '/moments/$id';
  static String momentFavorite(String id) => '/moments/$id/favorite';
  static String momentWorld(String id) => '/moments/$id/world';

  static String letter(String id) => '/letters/$id';
  static String letterSeal(String id) => '/letters/$id/seal';
  static String letterUnlock(String id) => '/letters/$id/unlock';

  static const String worldChannels = '/world/channels';
  static const String worldPosts = '/world/posts';
  static const String worldGradients = '/world/gradients';
  static String worldPost(String id) => '/world/posts/$id';
  static String worldPostResonate(String id) => '/world/posts/$id/resonate';

  static String commentsMoment(String momentId) => '/comments/moment/$momentId';
  static String commentsWorld(String postId) => '/comments/world/$postId';
  static String comment(String id) => '/comments/$id';
  static String commentLike(String id) => '/comments/$id/like';

  static const String mediaUploadUrl = '/media/upload-url';
  static const String mediaComplete = '/media/complete';
  static String media(String key) => '/media/$key';
  static String mediaInfo(String key) => '/media/info/$key';

  static const String syncChanges = '/sync/changes';
  static const String syncPush = '/sync/push';
  static const String syncFull = '/sync/full';
  static const String syncStatus = '/sync/status';
}
