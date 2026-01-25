/**
 * JWT Utilities
 * 
 * Simple JWT implementation using Web Crypto API
 */

import type { JwtPayload } from '../types';

const ALGORITHM = { name: 'HMAC', hash: 'SHA-256' };
const ACCESS_TOKEN_EXPIRY = 60 * 60; // 1 hour
const REFRESH_TOKEN_EXPIRY = 30 * 24 * 60 * 60; // 30 days

/**
 * Base64URL encode
 */
function base64UrlEncode(data: Uint8Array | string): string {
  const str = typeof data === 'string' ? data : String.fromCharCode(...data);
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/**
 * Base64URL decode
 */
function base64UrlDecode(str: string): string {
  const padded = str + '='.repeat((4 - (str.length % 4)) % 4);
  return atob(padded.replace(/-/g, '+').replace(/_/g, '/'));
}

/**
 * Get crypto key from secret
 */
async function getCryptoKey(secret: string): Promise<CryptoKey> {
  const encoder = new TextEncoder();
  return crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    ALGORITHM,
    false,
    ['sign', 'verify']
  );
}

/**
 * Sign a JWT token
 */
export async function signToken(
  payload: Omit<JwtPayload, 'iat' | 'exp'>,
  secret: string,
  expiresIn: number = ACCESS_TOKEN_EXPIRY
): Promise<string> {
  const header = { alg: 'HS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  
  const fullPayload: JwtPayload = {
    ...payload,
    iat: now,
    exp: now + expiresIn,
  };
  
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(fullPayload));
  const message = `${encodedHeader}.${encodedPayload}`;
  
  const key = await getCryptoKey(secret);
  const encoder = new TextEncoder();
  const signature = await crypto.subtle.sign(ALGORITHM, key, encoder.encode(message));
  
  const encodedSignature = base64UrlEncode(new Uint8Array(signature));
  
  return `${message}.${encodedSignature}`;
}

/**
 * Verify and decode a JWT token
 */
export async function verifyToken(token: string, secret: string): Promise<JwtPayload> {
  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('Invalid token format');
  }
  
  const [encodedHeader, encodedPayload, encodedSignature] = parts;
  const message = `${encodedHeader}.${encodedPayload}`;
  
  // Verify signature
  const key = await getCryptoKey(secret);
  const encoder = new TextEncoder();
  
  const signatureStr = base64UrlDecode(encodedSignature);
  const signatureBytes = Uint8Array.from(signatureStr, (c) => c.charCodeAt(0));
  
  const valid = await crypto.subtle.verify(
    ALGORITHM,
    key,
    signatureBytes,
    encoder.encode(message)
  );
  
  if (!valid) {
    throw new Error('Invalid signature');
  }
  
  // Decode payload
  const payload = JSON.parse(base64UrlDecode(encodedPayload)) as JwtPayload;
  
  // Check expiration
  const now = Math.floor(Date.now() / 1000);
  if (payload.exp && payload.exp < now) {
    throw new Error('Token expired');
  }
  
  return payload;
}

/**
 * Create access and refresh tokens
 */
export async function createTokenPair(
  userId: string,
  email: string,
  secret: string
): Promise<{ accessToken: string; refreshToken: string; expiresIn: number }> {
  const accessToken = await signToken(
    { sub: userId, email },
    secret,
    ACCESS_TOKEN_EXPIRY
  );
  
  const refreshToken = await signToken(
    { sub: userId, email },
    secret,
    REFRESH_TOKEN_EXPIRY
  );
  
  return {
    accessToken,
    refreshToken,
    expiresIn: ACCESS_TOKEN_EXPIRY,
  };
}

export { ACCESS_TOKEN_EXPIRY, REFRESH_TOKEN_EXPIRY };
