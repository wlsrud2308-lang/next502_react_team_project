// src/App.jsx
import WarehouseSearchPage from './components/warehouse/WarehouseSearchPage';
import 'bootstrap/dist/css/bootstrap.min.css'; // 부트스트랩 CSS 확인!

function App() {
  return (
    <div className="App">
      {/* 만약 레이아웃 헤더가 있다면 <Header /> 를 위에 두세요 */}
      <WarehouseSearchPage />
    </div>
  );
}

export default App;
