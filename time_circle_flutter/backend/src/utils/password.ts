/**
 * Password Hashing Utilities
 * 
 * Uses PBKDF2 with SHA-256 (Web Crypto API compatible with Workers)
 */

const ITERATIONS = 100000;
const KEY_LENGTH = 32;
const SALT_LENGTH = 16;

/**
 * Hash a password using PBKDF2
 */
export async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder();
  const salt = crypto.getRandomValues(new Uint8Array(SALT_LENGTH));
  
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(password),
    'PBKDF2',
    false,
    ['deriveBits']
  );
  
  const derivedBits = await crypto.subtle.deriveBits(
    {
      name: 'PBKDF2',
      salt: salt,
      iterations: ITERATIONS,
      hash: 'SHA-256',
    },
    keyMaterial,
    KEY_LENGTH * 8
  );
  
  const hashArray = new Uint8Array(derivedBits);
  const combined = new Uint8Array(salt.length + hashArray.length);
  combined.set(salt);
  combined.set(hashArray, salt.length);
  
  return btoa(String.fromCharCode(...combined));
}

/**
 * Verify a password against a hash
 */
export async function verifyPassword(password: string, storedHash: string): Promise<boolean> {
  try {
    const encoder = new TextEncoder();
    const combined = Uint8Array.from(atob(storedHash), (c) => c.charCodeAt(0));
    
    const salt = combined.slice(0, SALT_LENGTH);
    const storedHashBytes = combined.slice(SALT_LENGTH);
    
    const keyMaterial = await crypto.subtle.importKey(
      'raw',
      encoder.encode(password),
      'PBKDF2',
      false,
      ['deriveBits']
    );
    
    const derivedBits = await crypto.subtle.deriveBits(
      {
        name: 'PBKDF2',
        salt: salt,
        iterations: ITERATIONS,
        hash: 'SHA-256',
      },
      keyMaterial,
      KEY_LENGTH * 8
    );
    
    const newHashBytes = new Uint8Array(derivedBits);
    
    // Constant-time comparison
    if (newHashBytes.length !== storedHashBytes.length) {
      return false;
    }
    
    let result = 0;
    for (let i = 0; i < newHashBytes.length; i++) {
      result |= newHashBytes[i] ^ storedHashBytes[i];
    }
    
    return result === 0;
  } catch {
    return false;
  }
}
