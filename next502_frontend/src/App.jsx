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
import FavoriteList from './components/member/FavoriteList';
import MyWarehouseList from './components/warehouse/MyWarehouseList';
import ChatPage from './components/chat/ChatPage';
import WarehouseEdit from './components/warehouse/WarehouseEdit';
import CommunityPage from './components/community/CommunityPage';
import CommunityDetailPage from './components/community/CommunityDetailPage';
import CommunityWritePage from './components/community/CommunityWritePage';
import About from './components/info/About';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* 공통 경로 */}
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Auth />} />
          <Route path="/search" element={<WarehouseSearchPage />} />

          <Route path="/warehouse/:id" element={<WarehouseDetail />} />
          <Route path="/warehouse/list" element={<WarehouseListPage />} />
          <Route path="/warehouse/insert" element={<WarehouseInsert />} />
          <Route path="/whInput" element={<WarehouseInsert />} />
          <Route path="/warehouse/edit/:id" element={<WarehouseEdit />} />
          <Route path="/my-warehouses" element={<MyWarehouseList />} />
          <Route path="/mypage" element={<MyPage />} />
          <Route path="/mypage/edit" element={<EditProfile />} />
          <Route path="/favorites" element={<FavoriteList />} />
          <Route path="/chat-list" element={<ChatPage />} />
          <Route path="/community/:category/:boardId" element={<CommunityDetailPage />} />
          <Route path="/community/:category" element={<CommunityPage />} />
          <Route path="/community/:category/write" element={<CommunityWritePage />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
