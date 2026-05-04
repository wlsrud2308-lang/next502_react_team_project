import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Login from './components/auth/Login';
import Auth from './components/auth/Auth';
import Home from './components/Home';
import WarehouseSearchPage from './components/warehouse/WarehouseSearchPage';
import WarehouseDetail from './components/warehouse/WarehouseDetail';
import WarehouseListPage from './components/warehouse/WarehouseListPage';
import WarehouseInsert from './components/warehouse/WarehouseInsert';
import MyPage from './components/member/MyPage';
import EditProfile from './components/member/EditProfile';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/search" element={<WarehouseSearchPage />} />
          <Route path="/warehouse/:id" element={<WarehouseDetail />} />
          <Route path="/warehouse/list" element={<WarehouseListPage />} />
          <Route path="/warehouse/insert" element={<WarehouseInsert />} />
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Auth />} />
          <Route path="/api/member/me" element={<MyPage />} />
          <Route path="/api/member/me/edit" element={<EditProfile />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
