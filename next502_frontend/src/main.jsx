// src/main.jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { NavermapsProvider } from 'react-naver-maps';

const clientId = import.meta.env.VITE_NAVER_MAP_CLIENT_ID;

// 만약 clientId가 undefined로 찍힌다면 .env 파일을 못 읽고 있는 겁니다.
console.log('네이버 클라이언트 ID 확인:', clientId);

ReactDOM.createRoot(document.getElementById('root')).render(
  <NavermapsProvider ncpClientId={clientId}>
    <App />
  </NavermapsProvider>,
);
