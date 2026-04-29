import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './components/Home';
import WarehouseSearchPage from './components/warehouse/WarehouseSearchPage';
import WarehouseDetail from './components/warehouse/WarehouseDetail';
import WarehouseListPage from './components/warehouse/WarehouseListPage.jsx';

function App() {
  return (
    <Router>
      <Routes>
        {/* 메인 홈페이지 */}
        <Route path="/" element={<Home />} />

        {/* 창고 검색 페이지 (현재 /search로 설정되어 있음) */}
        <Route path="/search" element={<WarehouseSearchPage />} />

        {/* ★ 2. 상세 페이지 경로 추가 ★ */}
        {/* :id는 변수입니다. /warehouse/1, /warehouse/2 등을 모두 처리합니다. */}
        <Route path="/warehouse/:id" element={<WarehouseDetail />} />
        <Route path="/warehouse/list" element={<WarehouseListPage />} />
      </Routes>
    </Router>
  );
}

export default App;
