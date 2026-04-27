import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { NavermapsProvider } from 'react-naver-maps';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <NavermapsProvider ncpClientId={import.meta.env.VITE_NAVER_MAP_CLIENT_ID}>
      <App />
    </NavermapsProvider>
  </React.StrictMode>,
);
