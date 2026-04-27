import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { NavermapsProvider } from 'react-naver-maps';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    {/* 여기서 ncpClientId를 한 번만 선언합니다 */}
    <NavermapsProvider ncpClientId={import.meta.env.VITE_NAVER_MAP_CLIENT_ID}>
      <App />
    </NavermapsProvider>
  </React.StrictMode>,
);
