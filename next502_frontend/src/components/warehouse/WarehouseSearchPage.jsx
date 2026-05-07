import React, { useState, useEffect, useCallback, useRef } from 'react';
import { Container, Row, Col, Form, Button, Card, Spinner } from 'react-bootstrap';
import { useNavigate, useLocation } from 'react-router-dom';
import WarehouseList from './WarehouseList';
import NaverMapContainer from './NaverMapContainer';
import { fetchWarehouses } from '../../service/ApiService';
import Header from '../layout/Header.jsx';
import Footer from '../layout/Footer.jsx';
import { Search, RotateCcw } from 'lucide-react';

const WarehouseSearchPage = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const busanDistricts = [
    '강서구',
    '금정구',
    '기장군',
    '남구',
    '동구',
    '동래구',
    '부산진구',
    '북구',
    '사상구',
    '사하구',
    '서구',
    '수영구',
    '연제구',
    '영도구',
    '중구',
    '해운대구',
  ];

  const STORAGE_TYPES = [
    '보통창고',
    '야적창고',
    '냉동/냉장창고',
    '저장창고',
    '간이창고',
    '위험물창고',
    '보관창고',
  ];

  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(false);

  // 비동기 요청 추적용 Ref (이전 요청 무시용)
  const searchRequestRef = useRef(0);

  const [filters, setFilters] = useState({
    location: '',
    type: '',
    sizeRank: '',
    name: '',
  });

  // 검색 로직 개선
  const handleSearch = useCallback(async (loc = '', type = '', name = '', size = '') => {
    // 1. 새로운 요청이 시작될 때마다 요청 ID 증가
    const currentRequestId = ++searchRequestRef.current;

    setLoading(true);
    // 2. 검색 시작 시 기존 데이터를 비워서 지도/리스트 잔상 제거
    setWarehouses([]);

    try {
      const data = await fetchWarehouses(loc, type, name, size);

      // 3. 응답이 왔을 때, 최신 요청인지 확인 (중요: 데이터 섞임 방지)
      if (currentRequestId === searchRequestRef.current) {
        setWarehouses(data);
      }
    } catch (error) {
      console.error('❌ 데이터 로딩 실패:', error);
    } finally {
      if (currentRequestId === searchRequestRef.current) {
        setLoading(false);
      }
    }
  }, []);

  // URL 파라미터 감지 및 자동 검색
  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const district = params.get('district') || '';
    const type = params.get('type') || '';
    const keyword = params.get('keyword') || '';

    setFilters((prev) => ({
      ...prev,
      location: district,
      type: type,
      name: keyword,
    }));

    handleSearch(district, type, keyword, '');
  }, [location.search, handleSearch]);

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
  };

  // 수동 검색 실행 버튼
  const onExecuteSearch = () => {
    handleSearch(filters.location, filters.type, filters.name, filters.sizeRank);
  };

  const handleReset = () => {
    const resetFilters = { location: '', type: '', sizeRank: '', name: '' };
    setFilters(resetFilters);
    handleSearch('', '', '', ''); // 전체 검색으로 리셋
  };

  const handleWarehouseClick = (id) => {
    navigate(`/warehouse/${id}`);
  };

  return (
    <div className="wrapper bg-light">
      <Header />
      <main style={{ paddingTop: '100px', paddingBottom: '50px' }}>
        <Container>
          <div className="mb-4 d-flex justify-content-between align-items-end">
            <div>
              <h2 className="fw-bold text-dark">창고 검색</h2>
              <p className="text-muted mb-0">
                지도를 통해 부산 전역의 물류 창고 위치를 확인하세요.
              </p>
            </div>
            <div className="text-primary fw-bold">검색 결과: {warehouses.length}건</div>
          </div>

          <Card className="border-0 shadow-sm rounded-4 overflow-hidden mb-4 border">
            <Card.Body className="p-0">
              <Row className="g-0 align-items-center">
                <Col lg={2} md={4} className="border-end p-3">
                  <Form.Label className="small fw-bold text-muted mb-1 ps-1">지역</Form.Label>
                  <Form.Select
                    name="location"
                    value={filters.location}
                    onChange={handleFilterChange}
                    className="border-0 shadow-none fw-bold"
                  >
                    <option value="">전체 지역</option>
                    {busanDistricts.map((d) => (
                      <option key={d} value={d}>
                        {d}
                      </option>
                    ))}
                  </Form.Select>
                </Col>

                <Col lg={2} md={4} className="border-end p-3">
                  <Form.Label className="small fw-bold text-muted mb-1 ps-1">보관유형</Form.Label>
                  <Form.Select
                    name="type"
                    value={filters.type}
                    onChange={handleFilterChange}
                    className="border-0 shadow-none fw-bold"
                  >
                    <option value="">전체 유형</option>
                    {STORAGE_TYPES.map((t) => (
                      <option key={t} value={t}>
                        {t}
                      </option>
                    ))}
                  </Form.Select>
                </Col>

                <Col lg={2} md={4} className="border-end p-3">
                  <Form.Label className="small fw-bold text-muted mb-1 ps-1">규모</Form.Label>
                  <Form.Select
                    name="sizeRank"
                    value={filters.sizeRank}
                    onChange={handleFilterChange}
                    className="border-0 shadow-none fw-bold"
                  >
                    <option value="">전체 규모</option>
                    <option value="L">대형(L)</option>
                    <option value="M">중형(M)</option>
                    <option value="S">소형(S)</option>
                  </Form.Select>
                </Col>

                <Col lg={4} md={8} className="p-3">
                  <Form.Label className="small fw-bold text-muted mb-1 ps-1">
                    창고명 검색
                  </Form.Label>
                  <Form.Control
                    name="name"
                    placeholder="창고 이름을 입력하세요"
                    value={filters.name}
                    onChange={handleFilterChange}
                    onKeyDown={(e) => e.key === 'Enter' && onExecuteSearch()}
                    className="border-0 shadow-none fw-bold"
                  />
                </Col>

                <Col lg={2} md={4} className="p-2 d-flex gap-1 bg-light">
                  <Button
                    variant="primary"
                    className="w-100 fw-bold py-2 shadow-sm"
                    onClick={onExecuteSearch}
                  >
                    <Search size={18} className="me-2" /> 검색
                  </Button>
                  <Button variant="outline-secondary" className="bg-white" onClick={handleReset}>
                    <RotateCcw size={18} />
                  </Button>
                </Col>
              </Row>
            </Card.Body>
          </Card>

          <Row className="g-3">
            <Col lg={4} md={5}>
              <Card
                className="border-0 shadow-sm rounded-4 overflow-hidden"
                style={{ height: '650px' }}
              >
                <div className="bg-white p-3 border-bottom d-flex justify-content-between align-items-center">
                  <span className="fw-bold">창고 목록</span>
                  {loading && <Spinner animation="border" size="sm" variant="primary" />}
                </div>
                <div className="flex-grow-1 overflow-auto bg-light p-2">
                  {/* 로딩 중일 때 빈 화면을 보여주어 데이터 섞임 방지 */}
                  {!loading && (
                    <WarehouseList
                      warehouses={warehouses}
                      loading={loading}
                      onItemClick={handleWarehouseClick}
                    />
                  )}
                </div>
              </Card>
            </Col>

            <Col lg={8} md={7}>
              <Card
                className="border-0 shadow-sm rounded-4 overflow-hidden"
                style={{ height: '650px' }}
              >
                <NaverMapContainer warehouses={warehouses} onMarkerClick={handleWarehouseClick} />
              </Card>
            </Col>
          </Row>
        </Container>
      </main>
      <Footer />

      <style>{`
        .form-select:focus, .form-control:focus {
          box-shadow: none !important;
        }
        @media (max-width: 991px) {
          .border-end { border-right: none !important; border-bottom: 1px solid #dee2e6; }
        }
      `}</style>
    </div>
  );
};

export default WarehouseSearchPage;
