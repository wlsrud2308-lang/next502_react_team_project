import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Login from './components/auth/Login';
import Auth from './components/auth/Auth';

import Home from './components/Home';
import WarehouseSearchPage from './components/warehouse/WarehouseSearchPage';
import WarehouseDetail from './components/warehouse/WarehouseDetail';
import WarehouseListPage from './components/warehouse/WarehouseListPage.jsx';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/search" element={<WarehouseSearchPage />} />
          <Route path="/warehouse/:id" element={<WarehouseDetail />} />
          <Route path="/warehouse/list" element={<WarehouseListPage />} />

          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Auth />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
