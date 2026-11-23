import { AIProviderId } from '../types';

export interface GatewayRuntimeConfig {
  provider: AIProviderId;
  model: string;
  temperature: number;
  maxTokens: number;
  fallbackToOffline: boolean;
}

export type GatewayKeyVault = Partial<Record<Exclude<AIProviderId, 'offline'>, string>>;

const CONFIG_STORAGE_KEY = 'mizan_gateway_config';
const KEYS_STORAGE_KEY = 'mizan_gateway_keys';

export const DEFAULT_GATEWAY_RUNTIME_CONFIG: GatewayRuntimeConfig = {
  provider: 'gemini',
  model: 'gemini-3.8-flash',
  temperature: 0.4,
  maxTokens: 1024,
  fallbackToOffline: true,
};

export function loadGatewayConfig(): GatewayRuntimeConfig {
  try {
    const raw = localStorage.getItem(CONFIG_STORAGE_KEY);
    if (!raw) return DEFAULT_GATEWAY_RUNTIME_CONFIG;
    return { ...DEFAULT_GATEWAY_RUNTIME_CONFIG, ...JSON.parse(raw) };
  } catch {
    return DEFAULT_GATEWAY_RUNTIME_CONFIG;
  }
}

export function saveGatewayConfig(config: GatewayRuntimeConfig): void {
  try {
    localStorage.setItem(CONFIG_STORAGE_KEY, JSON.stringify(config));
  } catch {
    // Ignore quota errors
  }
}

export function loadGatewayKeys(): GatewayKeyVault {
  try {
    const raw = localStorage.getItem(KEYS_STORAGE_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

export function saveGatewayKey(provider: Exclude<AIProviderId, 'offline'>, key: string): GatewayKeyVault {
  const current = loadGatewayKeys();
  const trimmed = key.trim();
  const next: GatewayKeyVault = { ...current };
  if (trimmed) {
    next[provider] = trimmed;
  } else {
    delete next[provider];
  }
  try {
    localStorage.setItem(KEYS_STORAGE_KEY, JSON.stringify(next));
  } catch {
    // Ignore quota errors
  }
  return next;
}

export function clearGatewayKey(provider: Exclude<AIProviderId, 'offline'>): GatewayKeyVault {
  return saveGatewayKey(provider, '');
}

export function getActiveGatewayHeaders(): Record<string, string> {
  const cfg = loadGatewayConfig();
  const keys = loadGatewayKeys();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (cfg.provider !== 'offline') {
    const userKey = keys[cfg.provider];
    if (userKey && userKey.trim()) {
      headers['x-provider-api-key'] = userKey.trim();
    }
  }
  return headers;
}

export function maskApiKey(key?: string): string {
  if (!key || key.length < 8) return key ? '••••••••' : '';
  return `${key.slice(0, 5)}••••••••${key.slice(-4)}`;
}
