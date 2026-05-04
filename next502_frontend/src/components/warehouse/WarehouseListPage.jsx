import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Form, Button, InputGroup, Card, Badge } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { fetchWarehouses } from '../../service/ApiService';
import Header from '../layout/Header';
import Footer from '../layout/Footer';
import { MapPin, Maximize, Box, Search } from 'lucide-react';

// 백엔드 서버 주소
const API_BASE_URL = 'http://localhost:8080';

const WarehouseListPage = () => {
  const navigate = useNavigate();
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchName, setSearchName] = useState('');

  // 데이터 가져오기 함수
  const loadWarehouses = async (name = '') => {
    setLoading(true);
    try {
      const token = localStorage.getItem('ACCESS_TOKEN');
      const data = await fetchWarehouses('', '', name, token);
      setWarehouses(data);
    } catch (error) {
      console.error('데이터 로딩 실패:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadWarehouses();
  }, []);

  // 이미지 URL 변환 함수 추가
  const getImageUrl = (url) => {
    if (!url) return 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500&q=80';
    if (url.startsWith('http')) return url;

    const formattedUrl = url.replace(/\\/g, '/');
    return `${API_BASE_URL}${formattedUrl.startsWith('/') ? '' : '/'}${formattedUrl}`;
  };

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <Header />

      {/* 상단 검색 헤더 구역 */}
      <section className="bg-primary text-white py-5 mt-5">
        <Container className="pt-4">
          <Row className="align-items-center">
            <Col md={6}>
              <h2 className="fw-bold mb-2">창고 둘러보기</h2>
              <p className="opacity-75">부산 전역의 최적화된 물류 공간을 한눈에 확인하세요.</p>
            </Col>
            <Col md={6}>
              <InputGroup size="lg" className="shadow-sm">
                <Form.Control
                  placeholder="창고명을 입력하세요..."
                  value={searchName}
                  onChange={(e) => setSearchName(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && loadWarehouses(searchName)}
                />
                <Button variant="dark" onClick={() => loadWarehouses(searchName)}>
                  <Search size={20} className="me-2" /> 검색
                </Button>
              </InputGroup>
            </Col>
          </Row>
        </Container>
      </section>

      {/* 메인 리스트 구역 */}
      <Container className="py-5">
        <div className="d-flex justify-content-between align-items-end mb-4">
          <div>
            <span className="text-secondary">
              총 <span className="fw-bold text-primary">{warehouses.length}</span>개의 창고가
              있습니다.
            </span>
          </div>
          {/* 간단 필터 (기능 추가 가능) */}
          <div className="d-flex gap-2">
            <Form.Select size="sm" className="w-auto">
              <option>최신순</option>
              <option>면적순</option>
            </Form.Select>
          </div>
        </div>

        {loading ? (
          <div className="text-center py-5">로딩 중입니다...</div>
        ) : (
          <Row g={4}>
            {warehouses.map((item) => (
              <Col key={item.warehouseId} md={6} lg={4} className="mb-4">
                <Card
                  className="h-100 border-0 shadow-sm rounded-4 overflow-hidden warehouse-card-hover"
                  style={{ cursor: 'pointer', transition: 'transform 0.3s' }}
                  onClick={() => navigate(`/warehouse/${item.warehouseId}`)}
                >
                  <div className="position-relative">
                    <Card.Img
                      variant="top"
                      src={getImageUrl(item.repImageUrl)}
                      style={{ height: '200px', objectFit: 'cover' }}
                      onError={(e) => {
                        e.target.src =
                          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500&q=80';
                      }}
                    />
                    <Badge
                      bg="dark"
                      className="position-absolute top-0 end-0 m-3 opacity-75 fw-normal"
                    >
                      {item.storageType}
                    </Badge>
                  </div>

                  <Card.Body className="p-4">
                    <div className="d-flex justify-content-between align-items-start mb-2">
                      <Badge bg="primary" className="mb-2">
                        규모 {item.sizeRank}
                      </Badge>
                    </div>
                    <Card.Title className="fw-bold mb-2 text-truncate">{item.name}</Card.Title>
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
                        <span className="fw-bold text-truncate">
                          {item.operationStructure || '자가운영'}
                        </span>
                      </div>
                    </div>
                  </Card.Body>
                </Card>
              </Col>
            ))}
          </Row>
        )}

        {!loading && warehouses.length === 0 && (
          <div className="text-center py-5 bg-white rounded-4 shadow-sm">
            <p className="text-muted mb-0">검색 결과가 없습니다.</p>
          </div>
        )}
      </Container>

      <Footer />

      <style
        dangerouslySetInnerHTML={{
          __html: `
        .warehouse-card-hover:hover {
          transform: translateY(-10px);
          box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
        }
      `,
        }}
      />
    </div>
  );
};

export default WarehouseListPage;
