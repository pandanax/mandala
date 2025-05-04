import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  base: '/',  // Добавьте эту строку
  plugins: [react()],
  server: {
    headers: {
      'Content-Security-Policy': "frame-src 'self' https://telegram.org"
    }
  }
})
