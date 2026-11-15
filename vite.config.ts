import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { defineConfig } from 'vite';

export default defineConfig(() => {
  const disableHmr = process.env.DISABLE_HMR === 'true';
  return {
    plugins: [react(), tailwindcss()],
    resolve: {
      alias: {
        '@': path.resolve(import.meta.dirname, '.'),
      },
    },
    server: {
      allowedHosts: true as const,
      // HMR and file watching are disabled in AI Studio via DISABLE_HMR=true.
      hmr: !disableHmr,
      ws: disableHmr ? (false as const) : undefined,
      watch: disableHmr ? null : {},
    },
  };
});
