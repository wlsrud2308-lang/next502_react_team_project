//  File: WarehouseMap.jsx
//  User: it
//  Date: 2026-04-23
//  Time: 오후 01:25
//  Desc : 기존 Header/Footer를 사용하는 지도 기반 검색 페이지

import React, { useState } from 'react';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function WarehouseMap() {
  const [isSidebarOpen, setSidebarOpen] = useState(true);

  // 샘플 데이터 (Home/List와 동일한 규격)
  const mapItems = [
    {
      id: 1,
      type: '일반상온',
      name: '부산항 신항 배후단지 창고',
      addr: '부산 강서구 성북동 123',
      area: '5,280㎡',
    },
    {
      id: 2,
      type: '냉동냉장',
      name: '감천항 냉동 물류센터',
      addr: '부산 사하구 암남동 56',
      area: '2,150㎡',
    },
    {
      id: 3,
      type: '일반상온',
      name: '사상구 스마트 소형 창고',
      addr: '부산 사상구 삼락동 89',
      area: '850㎡',
    },
  ];

  return (
    <div className="d-flex flex-column" style={{ height: '100vh', overflow: 'hidden' }}>
      {/* 기존 헤더 사용 */}
      <Header />

      {/* 메인 컨텐츠 (헤더 높이 80px 제외한 나머지 전체) */}
      <main className="d-flex flex-grow-1" style={{ marginTop: '80px', position: 'relative' }}>
        {/* [좌측 검색 사이드바] */}
        <aside
          className="bg-white shadow-sm d-flex flex-column"
          style={{
            width: isSidebarOpen ? '400px' : '0px',
            transition: 'width 0.3s ease',
            zIndex: 100,
            borderRight: '1px solid #eee',
          }}
        >
          {/* 사이드바 내부 컨텐츠 (너비 고정 필요) */}
          <div
            style={{ minWidth: '400px', display: 'flex', flexDirection: 'column', height: '100%' }}
          >
            {/* 검색창 영역 */}
            <div className="p-4 border-bottom">
              <h5 className="fw-bold mb-3 text-dark">지도 검색</h5>
              <div className="row g-2 mb-3">
                <div className="col-6">
                  <select className="form-select form-select-sm">
                    <option>지역(전체)</option>
                  </select>
                </div>
                <div className="col-6">
                  <select className="form-select form-select-sm">
                    <option>유형(전체)</option>
                  </select>
                </div>
              </div>
              <div className="input-group border rounded-3 p-1">
                <input
                  type="text"
                  className="form-control border-0 shadow-none small"
                  placeholder="창고명 입력"
                />
                <button className="btn btn-primary btn-sm px-3 rounded-2">
                  <i className="bi bi-search"></i>
                </button>
              </div>
            </div>

            {/* 결과 리스트 영역 (스크롤) */}
            <div className="flex-grow-1 overflow-auto bg-light p-3">
              <p className="small text-muted mb-3 px-1">
                검색 결과 <strong>{mapItems.length}</strong>건
              </p>
              {mapItems.map((item) => (
                <div key={item.id} className="card border-0 shadow-sm rounded-4 mb-3 map-list-card">
                  <div className="card-body p-3 text-start">
                    <span
                      className="badge bg-primary-subtle text-primary border border-primary-subtle mb-2"
                      style={{ fontSize: '11px' }}
                    >
                      {item.type}
                    </span>
                    <h6 className="fw-bold mb-1 text-dark">{item.name}</h6>
                    <p className="text-secondary mb-2" style={{ fontSize: '13px' }}>
                      {item.addr}
                    </p>
                    <div className="d-flex justify-content-between align-items-center mt-3 pt-2 border-top">
                      <span className="fw-bold text-primary small">{item.area}</span>
                      <button
                        className="btn btn-outline-primary btn-sm py-1 px-3 rounded-pill"
                        style={{ fontSize: '12px' }}
                      >
                        상세보기
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </aside>

        {/* [사이드바 열고 닫기 버튼] */}
        <button
          onClick={() => setSidebarOpen(!isSidebarOpen)}
          className="btn btn-white shadow-sm border bg-white"
          style={{
            position: 'absolute',
            left: isSidebarOpen ? '400px' : '0px',
            top: '50%',
            transform: 'translateY(-50%)',
            zIndex: 110,
            borderRadius: '0 8px 8px 0',
            padding: '15px 7px',
            transition: 'left 0.3s ease',
          }}
        >
          <i className={`bi bi-chevron-${isSidebarOpen ? 'left' : 'right'}`}></i>
        </button>

        {/* [지도 영역] */}
        <section className="flex-grow-1 position-relative" style={{ backgroundColor: '#eef0f3' }}>
          {/* 가상 지도 배경 이미지 */}
          <div
            style={{
              width: '100%',
              height: '100%',
              backgroundImage:
                'url("https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1600")',
              backgroundSize: 'cover',
              backgroundPosition: 'center',
              filter: 'brightness(0.95)',
            }}
          />

          {/* 지도 마커 예시 */}
          <div
            className="position-absolute"
            style={{ top: '40%', left: '50%', transform: 'translate(-50%, -50%)' }}
          >
            <div className="custom-map-marker shadow-lg">
              <i className="bi bi-geo-alt-fill me-1"></i>
              부산항 신항 창고
            </div>
            <div className="marker-point" />
          </div>

          {/* 우측 하단 지도 컨트롤 바 */}
          <div
            className="position-absolute bottom-0 end-0 m-4 d-flex flex-column gap-2"
            style={{ zIndex: 10 }}
          >
            <button
              className="btn btn-white shadow-sm border bg-white fw-bold"
              style={{ width: '40px', height: '40px' }}
            >
              +
            </button>
            <button
              className="btn btn-white shadow-sm border bg-white fw-bold"
              style={{ width: '40px', height: '40px' }}
            >
              -
            </button>
          </div>
        </section>
      </main>

      {/* 기존 푸터 사용 */}
      <Footer />

      <style
        dangerouslySetInnerHTML={{
          __html: `
        .map-list-card { transition: all 0.2s; cursor: pointer; border: 1px solid transparent !important; }
        .map-list-card:hover { transform: translateY(-3px); border-color: #007bff !important; box-shadow: 0 8px 20px rgba(0,0,0,0.1) !important; }
        .custom-map-marker { 
          background: #007bff; color: white; padding: 8px 18px; 
          border-radius: 30px; font-weight: bold; font-size: 14px; 
          white-space: nowrap; cursor: pointer;
        }
        .marker-point { 
          width: 2px; height: 15px; background: #007bff; margin: 0 auto;
        }
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-thumb { background: #ddd; border-radius: 10px; }
      `,
        }}
      />
    </div>
  );
}

export default WarehouseMap;
