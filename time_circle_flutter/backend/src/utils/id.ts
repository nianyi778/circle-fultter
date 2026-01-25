/**
 * ID Generation Utilities
 */

/**
 * Generate a unique ID with optional prefix
 */
export function generateId(prefix?: string): string {
  const timestamp = Date.now().toString(36);
  const randomPart = crypto.randomUUID().replace(/-/g, '').slice(0, 12);
  const id = `${timestamp}${randomPart}`;
  return prefix ? `${prefix}_${id}` : id;
}

/**
 * Generate a short invite code (6 characters)
 */
export function generateInviteCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 排除容易混淆的字符
  let code = '';
  const randomValues = new Uint8Array(6);
  crypto.getRandomValues(randomValues);
  for (let i = 0; i < 6; i++) {
    code += chars[randomValues[i] % chars.length];
  }
  return code;
}

/**
 * Generate a secure random token
 */
export function generateToken(length: number = 32): string {
  const bytes = new Uint8Array(length);
  crypto.getRandomValues(bytes);
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
