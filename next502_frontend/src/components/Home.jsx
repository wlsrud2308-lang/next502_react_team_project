import Footer from "./layout/Footer";
import Header from './layout/Header.jsx';

function Home() {

    return (
      <div>
        <Header />

        {/* ================= HERO ================= */}
        <div className="bg-primary text-white text-center py-5 mt-5">
          <h1 className="fw-bold">창고이음</h1>
          <p>창고 소유자와 창고 수요자를 연결하는 부산광역시 온라인 창고연계서비스</p>

          <div className="mt-3">
            <button className="btn btn-light me-2">창고 찾기</button>
            <button className="btn btn-outline-light">창고 등록</button>
          </div>
        </div>

        {/* ================= SEARCH ================= */}
        <div className="container py-5 text-center">
          <h3 className="mb-3">창고 검색</h3>

          <div className="input-group w-50 mx-auto">
            <input type="text" className="form-control" placeholder="지역 / 면적 / 유형 검색" />

            <button className="btn btn-primary">검색</button>
          </div>
        </div>

        {/* ================= WAREHOUSE ================= */}
        <div className="container py-5">
          <h3 className="mb-4">추천 창고</h3>

          <div className="row g-3">
            <div className="col-md-3">
              <div className="card p-3 shadow-sm">
                <h5>부산 물류센터 A</h5>
                <p>부산 강서구</p>
                <span className="badge bg-primary">상온</span>
              </div>
            </div>

            <div className="col-md-3">
              <div className="card p-3 shadow-sm">
                <h5>항만 창고 B</h5>
                <p>부산 사하구</p>
                <span className="badge bg-primary">냉장</span>
              </div>
            </div>

            <div className="col-md-3">
              <div className="card p-3 shadow-sm">
                <h5>창고 C</h5>
                <p>부산 북구</p>
                <span className="badge bg-primary">상온</span>
              </div>
            </div>

            <div className="col-md-3">
              <div className="card p-3 shadow-sm">
                <h5>창고 D</h5>
                <p>부산 사상구</p>
                <span className="badge bg-primary">냉동</span>
              </div>
            </div>
          </div>
        </div>

        {/* ================= NOTICE ================= */}
        <div className="container py-4">
          <h3>공지사항</h3>

          <ul className="list-group">
            <li className="list-group-item">시스템 점검 안내</li>
            <li className="list-group-item">창고 등록 기능 업데이트</li>
            <li className="list-group-item">이용약관 변경 안내</li>
            <li className="list-group-item">신규 창고 추가 안내</li>
          </ul>
        </div>

        <Footer />
      </div>
    );
}

export default Home;