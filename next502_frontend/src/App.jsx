import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './components/Home';
import WarehouseSearchPage from './components/warehouse/WarehouseSearchPage';

function App() {
  return (
    <Router>
      <Routes>
        {/* 메인 홈페이지 */}
        <Route path="/" element={<Home />} />

        {/* 창고 검색 및 이용 페이지 */}
        <Route path="/search" element={<WarehouseSearchPage />} />
      </Routes>
    </Router>
  );
}

export default App;
