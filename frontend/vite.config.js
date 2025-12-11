import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
    plugins: [react()],
    server: {
        host: '0.0.0.0',
        port: 5173,
        watch: {
            usePolling: true,
        },
        proxy: {
            '/api': {
                target: 'http://backend:5000',
                changeOrigin: true
            },
            '/health': {
                target: 'http://backend:5000',
                changeOrigin: true
            }
        }
    },
    test: {
        exclude: ['**/node_modules/**', '**/e2e/**'],
        globals: true,
        environment: 'jsdom',
    }
})

