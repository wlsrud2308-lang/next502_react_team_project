import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchWarehouses } from '../service/ApiService'; // 경로 확인 필요
import Header from './layout/Header';
import Footer from './layout/Footer';
import { Container, Row, Col, Badge, Card, Button, Spinner } from 'react-bootstrap';

function Home() {
  const navigate = useNavigate();

  // 상태 관리
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const pageSize = 3;

  // --- 1. DB 데이터 연동: 컴포넌트 마운트 시 데이터 호출 ---
  useEffect(() => {
    const getTopWarehouses = async () => {
      try {
        setLoading(true);
        const token = localStorage.getItem('ACCESS_TOKEN');

        // 전체 데이터를 가져온 후 최신순 6개만 사용 (백엔드에서 정렬해준다고 가정)
        const data = await fetchWarehouses('', '', '', token);
        setWarehouses(data.slice(0, 6));
      } catch (error) {
        console.error('실시간 창고 데이터 로드 실패:', error);
      } finally {
        setLoading(false);
      }
    };
    getTopWarehouses();
  }, []);

  // 페이지네이션 계산
  const maxPage = warehouses.length > 0 ? Math.ceil(warehouses.length / pageSize) - 1 : 0;
  const currentItems = warehouses.slice(page * pageSize, page * pageSize + pageSize);

  return (
    <div className="wrapper">
      <Header />

      {/* ================= 1. 비주얼 히어로 섹션 ================= */}
      <section
        className="hero-section text-white d-flex align-items-center"
        style={{
          minHeight: '550px',
          background:
            'linear-gradient(rgba(0, 30, 80, 0.7), rgba(0, 30, 80, 0.7)), url("https://images.unsplash.com/photo-1580674285054-bed31e145f59?w=1600&q=80") center/cover no-repeat',
          paddingTop: '80px',
        }}
      >
        <div className="container text-center">
          <h1 className="display-4 fw-bold mb-3 tracking-tight">부산 물류의 중심, 창고이음</h1>
          <p className="fs-5 opacity-75 mb-5">
            부산광역시 내 모든 창고 정보를 스마트하게 연결합니다.
          </p>

          <div
            className="card border-0 shadow-lg p-2 mx-auto"
            style={{ maxWidth: '900px', borderRadius: '15px' }}
          >
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
                    placeholder="창고명을 입력하세요"
                  />
                </div>
                <div className="col-md-2">
                  <button
                    className="btn btn-primary w-100 py-3 fw-bold shadow-sm"
                    style={{ borderRadius: '10px' }}
                    onClick={() => navigate('/search')}
                  >
                    검색
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ================= 2. 현황 데이터 섹션 ================= */}
      <section className="bg-white py-4 shadow-sm border-bottom">
        <div className="container">
          <div className="row text-center">
            <div className="col-md-3 border-end">
              <div className="small text-secondary">전체 등록 창고</div>
              <div className="h3 fw-bold text-primary mb-0">1,245건</div>
            </div>
            <div className="col-md-3 border-end">
              <div className="small text-secondary">냉동/냉장 시설</div>
              <div className="h3 fw-bold text-info mb-0">342건</div>
            </div>
            <div className="col-md-3 border-end">
              <div className="small text-secondary">이달의 매칭 건수</div>
              <div className="h3 fw-bold text-success mb-0">89건</div>
            </div>
            <div className="col-md-3">
              <div className="small text-secondary">부산항 물동량</div>
              <div className="h3 fw-bold text-warning mb-0">↑ 12%</div>
            </div>
          </div>
        </div>
      </section>

      {/* ================= 3. 실시간 추천 창고 섹션 (DB 연동) ================= */}
      <section className="py-5 bg-light">
        <div className="container py-4">
          <div className="d-flex justify-content-between align-items-center mb-5">
            <h2 className="fw-bold border-start border-primary border-4 ps-3">실시간 추천 창고</h2>
            <div className="btn-group">
              <button
                className="btn btn-white shadow-sm border"
                disabled={page === 0}
                onClick={() => setPage((p) => Math.max(0, p - 1))}
              >
                <i className="bi bi-arrow-left"></i>
              </button>
              <button
                className="btn btn-white shadow-sm border"
                disabled={page >= maxPage}
                onClick={() => setPage((p) => Math.min(maxPage, p + 1))}
              >
                <i className="bi bi-arrow-right"></i>
              </button>
            </div>
          </div>

          {loading ? (
            <div className="text-center py-5">
              <Spinner animation="border" variant="primary" />
              <p className="mt-2 text-muted">창고 데이터를 불러오고 있습니다...</p>
            </div>
          ) : (
            <div className="row g-4">
              {currentItems.length > 0 ? (
                currentItems.map((w) => (
                  <div className="col-md-4" key={w.warehouseId}>
                    <div
                      className="card h-100 border-0 shadow-sm rounded-4 overflow-hidden warehouse-card"
                      onClick={() => navigate(`/warehouse/${w.warehouseId}`)}
                      style={{ cursor: 'pointer' }}
                    >
                      <div className="position-relative">
                        <img
                          src={
                            w.repImageUrl ||
                            'https://via.placeholder.com/500x320?text=Warehouse+Image'
                          }
                          className="card-img-top"
                          alt={w.name}
                          style={{ height: '220px', objectFit: 'cover' }}
                        />
                        <div className="position-absolute top-0 end-0 m-3 badge bg-dark opacity-75 fw-normal">
                          {w.storageType}
                        </div>
                      </div>
                      <div className="card-body p-4">
                        <div className="mb-2">
                          <Badge bg="primary" className="fw-normal">
                            규모 {w.sizeRank}
                          </Badge>
                        </div>
                        <h5 className="fw-bold text-dark mb-2 text-truncate">{w.name}</h5>
                        <p className="text-secondary small mb-3">
                          <i className="bi bi-geo-alt-fill me-1 text-danger"></i>
                          {w.address}
                        </p>
                        <div className="d-flex justify-content-between align-items-center border-top pt-3">
                          <span className="text-primary fw-bold">{w.totalArea}㎡</span>
                          <button
                            className="btn btn-sm btn-outline-primary rounded-pill px-3"
                            onClick={(e) => {
                              e.stopPropagation();
                              navigate(`/warehouse/${w.warehouseId}`);
                            }}
                          >
                            상세보기
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-5 text-muted">등록된 창고 정보가 없습니다.</div>
              )}
            </div>
          )}
        </div>
      </section>

      {/* ================= 4. 공지사항 & 퀵 메뉴 ================= */}
      <section className="container py-5">
        <div className="row g-5">
          <div className="col-lg-7">
            <h4 className="fw-bold mb-4">공지사항</h4>
            <div className="list-group list-group-flush border-top border-2 border-dark">
              {[
                '시스템 정기 점검 안내 (04/28)',
                '신규 회원 가입 혜택 안내',
                '창고 등록 시 주의사항 업데이트',
                '창고이음 모바일 앱 출시 안내',
              ].map((text, idx) => (
                <a
                  key={idx}
                  href="#"
                  className="list-group-item list-group-item-action py-3 d-flex justify-content-between border-bottom-light"
                >
                  <span className="text-truncate" style={{ maxWidth: '80%' }}>
                    {text}
                  </span>
                  <span className="text-muted small">2026.04.24</span>
                </a>
              ))}
            </div>
          </div>
          <div className="col-lg-5">
            <h4 className="fw-bold mb-4">주요 서비스</h4>
            <div className="row g-3">
              <div className="col-6">
                <div className="bg-primary text-white p-4 rounded-4 text-center cursor-pointer hover-opacity h-100">
                  <i className="bi bi-building fs-1 d-block mb-2"></i>
                  <span className="fw-bold">창고등록</span>
                </div>
              </div>
              <div className="col-6" onClick={() => navigate('/warehouse/list')}>
                <div className="bg-info text-white p-4 rounded-4 text-center cursor-pointer hover-opacity h-100">
                  <i className="bi bi-search fs-1 d-block mb-2"></i>
                  <span className="fw-bold">창고찾기</span>
                </div>
              </div>
              <div className="col-6" onClick={() => navigate('/search')}>
                <div className="bg-dark text-white p-4 rounded-4 text-center cursor-pointer hover-opacity h-100">
                  <i className="bi bi-map fs-1 d-block mb-2"></i>
                  <span className="fw-bold">지도검색</span>
                </div>
              </div>
              <div className="col-6">
                <div className="bg-secondary text-white p-4 rounded-4 text-center cursor-pointer hover-opacity h-100">
                  <i className="bi bi-question-circle fs-1 d-block mb-2"></i>
                  <span className="fw-bold">이용가이드</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <Footer />

      <style
        dangerouslySetInnerHTML={{
          __html: `
        .tracking-tight { letter-spacing: -0.05rem; }
        .warehouse-card { transition: all 0.3s ease; border: 1px solid #eee !important; }
        .warehouse-card:hover { transform: translateY(-10px); box-shadow: 0 10px 20px rgba(0,0,0,0.08) !important; }
        .hover-opacity:hover { opacity: 0.9; }
        .cursor-pointer { cursor: pointer; }
        .btn-white { background: #fff; }
        .border-bottom-light { border-bottom: 1px solid #eee; }
      `,
        }}
      />
    </div>
  );
}

export default Home;
