//  File: BoardList.jsx
//  User: it
//  Date: 2026-04-23
//  Time: 오후 12:05
//  Desc : Home 화면과 톤앤매너를 맞춘 모던 창고 리스트 페이지

import React from 'react';
import Footer from '../layout/Footer.jsx';
import Header from '../layout/Header.jsx';

function BoardList(props) {
  // Home 화면과 동일한 창고 데이터 구조
  const warehouses = [
    {
      name: '부산항 신항 배후단지 창고',
      location: '부산 강서구 성북동',
      type: '일반상온',
      area: '5,280㎡',
      img: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500&q=80',
    },
    {
      name: '감천항 냉동 물류센터',
      location: '부산 사하구 암남동',
      type: '냉동냉장',
      area: '2,150㎡',
      img: 'https://images.unsplash.com/photo-1553413077-190dd305871c?w=500&q=80',
    },
    {
      name: '사상구 스마트 소형 창고',
      location: '부산 사상구 삼락동',
      type: '일반상온',
      area: '850㎡',
      img: 'https://images.unsplash.com/photo-1487017159396-6482aa3d46c8?w=500&q=80',
    },
  ];

  return (
    <div className="bg-light" style={{ minHeight: '100vh', paddingTop: '80px' }}>
      <Header/>
      {/* ================= 1. 서브 히어로 섹션 (Home의 Hero와 통일감) ================= */}
      <section
        className="text-white d-flex align-items-center"
        style={{
          height: '300px',
          background:
            'linear-gradient(rgba(0, 30, 80, 0.8), rgba(0, 30, 80, 0.8)), url("https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=1600&q=80") center/cover no-repeat',
        }}
      >
        <div className="container">
          <p className="small opacity-75 mb-2">HOME &gt; 창고정보 &gt; 창고검색</p>
          <h2 className="display-6 fw-bold tracking-tight">창고검색</h2>
          <p className="opacity-75">부산 전역의 검증된 창고 리스트를 확인하세요.</p>
        </div>
      </section>

      <main className="container mb-5" style={{ marginTop: '-40px' }}>
        {/* ================= 2. 통합 검색창 (Home의 검색창 스타일) ================= */}
        <div className="card border-0 shadow-lg p-2 mb-5" style={{ borderRadius: '15px' }}>
          <div className="card-body p-1">
            <div className="row g-0 align-items-center">
              <div className="col-md-3 border-end">
                <select className="form-select border-0 shadow-none fw-bold text-primary">
                  <option>지역(전체)</option>
                  <option>강서구</option>
                  <option>사하구</option>
                </select>
              </div>
              <div className="col-md-3 border-end">
                <select className="form-select border-0 shadow-none fw-bold text-primary">
                  <option>창고유형(전체)</option>
                  <option>일반상온</option>
                  <option>냉동냉장</option>
                </select>
              </div>
              <div className="col-md-4">
                <input
                  type="text"
                  className="form-control border-0 shadow-none"
                  placeholder="창고명 또는 주소를 입력하세요"
                />
              </div>
              <div className="col-md-2">
                <button
                  className="btn btn-primary w-100 py-3 fw-bold"
                  style={{ borderRadius: '10px' }}
                >
                  검색
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* ================= 3. 리스트 상단 필터/정보 ================= */}
        <div className="d-flex justify-content-between align-items-center mb-4 px-2">
          <div className="h5 fw-bold mb-0">
            검색 결과 <span className="text-primary">{warehouses.length}</span>건
          </div>
          <div className="d-flex gap-2">
            <button className="btn btn-white border shadow-sm btn-sm">최신순</button>
            <button className="btn btn-white border shadow-sm btn-sm">면적순</button>
          </div>
        </div>

        {/* ================= 4. 가로형 리스트 (Home의 카드 스타일 확장) ================= */}
        <div className="row g-4">
          {warehouses.map((w, i) => (
            <div className="col-12" key={i}>
              <div className="card h-100 border-0 shadow-sm rounded-4 overflow-hidden list-item-card">
                <div className="row g-0">
                  <div className="col-md-4 col-lg-3">
                    <div className="position-relative h-100" style={{ minHeight: '200px' }}>
                      <img
                        src={w.img}
                        className="w-100 h-100"
                        alt={w.name}
                        style={{ objectFit: 'cover' }}
                      />
                      <div className="position-absolute top-0 start-0 m-3 badge bg-primary">
                        {w.type}
                      </div>
                    </div>
                  </div>
                  <div className="col-md-8 col-lg-9">
                    <div className="card-body p-4 d-flex flex-column h-100 justify-content-center">
                      <div className="d-flex justify-content-between align-items-start mb-2">
                        <h4 className="fw-bold text-dark mb-0">{w.name}</h4>
                        <button className="btn btn-outline-light text-secondary border-0">
                          <i className="bi bi-heart"></i>
                        </button>
                      </div>
                      <p className="text-secondary mb-3">
                        <i className="bi bi-geo-alt-fill me-1 text-primary"></i>
                        {w.location}
                      </p>

                      <div className="row g-3 py-3 border-top mt-auto">
                        <div className="col-auto">
                          <span className="text-muted small d-block">보관면적</span>
                          <span className="fw-bold text-primary">{w.area}</span>
                        </div>
                        <div className="col-auto px-4 border-start">
                          <span className="text-muted small d-block">창고유형</span>
                          <span className="fw-bold">{w.type}</span>
                        </div>
                        <div className="col text-end align-self-center">
                          <button className="btn btn-dark rounded-pill px-4 fw-bold">
                            상세보기
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* ================= 5. 페이지네이션 ================= */}
        <nav className="mt-5">
          <ul className="pagination justify-content-center border-0">
            <li className="page-item mx-1">
              <a className="page-link rounded-circle border-0 shadow-sm" href="#">
                <i className="bi bi-chevron-left"></i>
              </a>
            </li>
            <li className="page-item mx-1 active">
              <a className="page-link rounded-circle border-0 shadow-sm px-3" href="#">
                1
              </a>
            </li>
            <li className="page-item mx-1">
              <a className="page-link rounded-circle border-0 shadow-sm px-3" href="#">
                2
              </a>
            </li>
            <li className="page-item mx-1">
              <a className="page-link rounded-circle border-0 shadow-sm" href="#">
                <i className="bi bi-chevron-right"></i>
              </a>
            </li>
          </ul>
        </nav>
      </main>

      <style
        dangerouslySetInnerHTML={{
          __html: `
        .tracking-tight { letter-spacing: -0.05rem; }
        .list-item-card { transition: all 0.3s ease; cursor: pointer; border: 1px solid transparent !important; }
        .list-item-card:hover { transform: scale(1.01); box-shadow: 0 1rem 3rem rgba(0,0,0,0.1) !important; border-color: #007bff !important; }
        .btn-white { background: #fff; }
        .page-link { color: #333; }
        .page-item.active .page-link { background-color: #007bff !important; }
      `,
        }}
      />

      <Footer />
    </div>
  );
}

export default BoardList;
