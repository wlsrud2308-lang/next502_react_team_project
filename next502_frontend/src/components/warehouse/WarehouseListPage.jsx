import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col, Form, Button, Card, Badge, Spinner } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { fetchWarehouses } from '../../service/ApiService'; // 경로 확인
import Header from '../layout/Header';
import Footer from '../layout/Footer';
import { MapPin, Maximize, Box, Search, RotateCcw } from 'lucide-react';

const API_BASE_URL = 'http://localhost:8080';

const WarehouseListPage = () => {
  const navigate = useNavigate();
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(false);

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

  // API 파라미터명과 동일하게 상태 관리
  const [filters, setFilters] = useState({
    location: '', // 지역
    type: '', // 보관유형
    sizeRank: '', // 규모
    name: '', // 창고명
  });

  // 데이터 로드 (API 파라미터 순서 및 명칭 매칭)
  const loadWarehouses = useCallback(async () => {
    setLoading(true);
    try {
      // fetchWarehouses(location, type, name, sizeRank)
      const data = await fetchWarehouses(
        filters.location,
        filters.type,
        filters.name,
        filters.sizeRank,
      );
      setWarehouses(data);
    } catch (error) {
      console.error('검색 실패:', error);
    } finally {
      setLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    loadWarehouses();
  }, []);

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
  };

  const handleReset = () => {
    setFilters({ location: '', type: '', sizeRank: '', name: '' });
  };

  const getImageUrl = (url) => {
    if (!url) return 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500&q=80';
    if (url.startsWith('http')) return url;
    const formattedUrl = url.replace(/\\/g, '/');
    return `${API_BASE_URL}${formattedUrl.startsWith('/') ? '' : '/'}${formattedUrl}`;
  };

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <Header />

      <section className="bg-white border-bottom py-5 mt-5">
        <Container className="pt-4">
          <div className="mb-4">
            <h2 className="fw-bold text-dark">창고 검색</h2>
            <p className="text-secondary">원하시는 최적의 물류 거점을 조건별로 찾아보세요.</p>
          </div>

          {/* 가로형 통합 검색바 디자인 */}
          <Card className="border-0 shadow-sm rounded-4 overflow-hidden border">
            <Card.Body className="p-0">
              <Row className="g-0 align-items-center">
                {/* 지역 선택 */}
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

                {/* 보관유형 선택 */}
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

                {/* 규모 선택 */}
                <Col lg={2} md={4} className="border-end p-3">
                  <Form.Label className="small fw-bold text-muted mb-1 ps-1">창고규모</Form.Label>
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

                {/* 키워드 검색 */}
                <Col lg={4} md={8} className="p-3">
                  <Form.Label className="small fw-bold text-muted mb-1 ps-1">창고명</Form.Label>
                  <Form.Control
                    name="name"
                    placeholder="검색어를 입력하세요"
                    value={filters.name}
                    onChange={handleFilterChange}
                    onKeyDown={(e) => e.key === 'Enter' && loadWarehouses()}
                    className="border-0 shadow-none fw-bold"
                  />
                </Col>

                {/* 버튼 영역 */}
                <Col lg={2} md={4} className="p-2 d-flex gap-1 bg-light">
                  <Button variant="dark" className="w-100 fw-bold py-2" onClick={loadWarehouses}>
                    <Search size={18} className="me-2" /> 검색
                  </Button>
                  <Button variant="outline-secondary" onClick={handleReset}>
                    <RotateCcw size={18} />
                  </Button>
                </Col>
              </Row>
            </Card.Body>
          </Card>
        </Container>
      </section>

      <Container className="py-5">
        {loading ? (
          <div className="text-center py-5">
            <Spinner animation="border" variant="primary" />
          </div>
        ) : (
          <Row className="g-4">
            {warehouses.length > 0 ? (
              warehouses.map((item) => (
                <Col key={item.warehouseId} lg={4} md={6}>
                  <Card
                    className="h-100 border-0 shadow-sm rounded-4 overflow-hidden warehouse-card-hover"
                    onClick={() => navigate(`/warehouse/${item.warehouseId}`)}
                    style={{ cursor: 'pointer', transition: 'all 0.3s' }}
                  >
                    <div className="position-relative">
                      <Card.Img
                        variant="top"
                        src={getImageUrl(item.repImageUrl)}
                        style={{ height: '220px', objectFit: 'cover' }}
                      />
                      <Badge
                        bg="dark"
                        className="position-absolute top-0 start-0 m-3 opacity-75 fw-normal"
                      >
                        {item.storageType}
                      </Badge>
                    </div>
                    <Card.Body className="p-4">
                      <div className="d-flex justify-content-between align-items-center mb-2">
                        <Badge bg="primary">규모 {item.sizeRank}</Badge>
                        <span className="text-muted small">{item.usageRate}% 사용중</span>
                      </div>
                      <Card.Title className="fw-bold mb-3 text-truncate">{item.name}</Card.Title>
                      <Card.Text className="text-secondary small mb-3">
                        <MapPin size={14} className="me-1 text-danger" /> {item.address}
                      </Card.Text>
                      <div className="d-flex gap-3 border-top pt-3">
                        <div className="small">
                          <Maximize size={14} className="me-1 text-primary" />
                          <span className="fw-bold">{item.totalArea}㎡</span>
                        </div>
                        <div className="small">
                          <Box size={14} className="me-1 text-primary" />
                          <span className="fw-bold">{item.operationStructure || '자가운영'}</span>
                        </div>
                      </div>
                    </Card.Body>
                  </Card>
                </Col>
              ))
            ) : (
              <Col className="text-center py-5">
                <p className="text-muted">검색 결과가 없습니다.</p>
              </Col>
            )}
          </Row>
        )}
      </Container>
      <Footer />
      <style>{`
        .warehouse-card-hover:hover { transform: translateY(-10px); box-shadow: 0 15px 30px rgba(0,0,0,0.1) !important; }
        .form-select:focus, .form-control:focus { box-shadow: none !important; }
        @media (max-width: 991px) { .border-end { border-right: none !important; border-bottom: 1px solid #dee2e6; } }
      `}</style>
    </div>
  );
};

export default WarehouseListPage;
