import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  // 현재 모드에 맞는 .env 파일을 불러옵니다.
  const env = loadEnv(mode, process.cwd());

  return {
    plugins: [
      react(),
      // 이제 react-naver-maps 라이브러리를 사용하므로
      // index.html을 직접 변환하는 html-transform 로직은 삭제해도 무방합니다.
    ],
    server: {
      // 1. host를 true로 설정하여 localhost뿐만 아니라 127.0.0.1 접속을 허용합니다.
      host: true,
      port: 5173,
      // 2. 백엔드 API 프록시 설정
      proxy: {
        '/api': {
          target: 'http://localhost:8080',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
    // 환경 변수 정의 (필요 시 클라이언트에서 더 안전하게 접근 가능)
    define: {
      'process.env': env,
    },
  };
});
