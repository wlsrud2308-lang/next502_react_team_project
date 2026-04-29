import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col, Form, InputGroup, Button } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom'; // 1. 추가
import WarehouseList from './WarehouseList';
import NaverMapContainer from './NaverMapContainer';
import { fetchWarehouses } from '../../service/ApiService';
import Header from '../layout/Header.jsx';
import Footer from '../layout/Footer.jsx';

const WarehouseSearchPage = () => {
  const navigate = useNavigate(); // 2. 추가
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchName, setSearchName] = useState('');

  const handleSearch = useCallback(async (location = '', size = '', name = '') => {
    setLoading(true);
    try {
      const token = localStorage.getItem('ACCESS_TOKEN');
      const data = await fetchWarehouses(location, size, name, token);
      setWarehouses(data);
    } catch (error) {
      console.error('❌ 데이터 로딩 실패:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  // 3. 클릭 시 상세 페이지로 이동하는 함수 정의
  const handleWarehouseClick = (id) => {
    navigate(`/warehouse/${id}`);
  };

  useEffect(() => {
    handleSearch();
  }, [handleSearch]);

  const onExecuteSearch = () => {
    handleSearch('', '', searchName);
  };

  return (
    <div className="wrapper">
      <Header />
      <main style={{ paddingTop: '100px', paddingBottom: '50px' }}>
        <Container>
          <div className="mb-4">
            <h2 className="fw-bold">창고 검색</h2>
            <p className="text-muted">원하시는 창고를 지도에서 확인해보세요.</p>
          </div>

          <Row
            className="g-0 border shadow-sm rounded-3 overflow-hidden"
            style={{ height: '700px' }}
          >
            <Col md={5} lg={4} className="d-flex flex-column bg-white border-end h-100">
              <div className="p-3 border-bottom bg-white">
                <InputGroup>
                  <Form.Control
                    size="lg"
                    placeholder="창고명을 입력하세요"
                    value={searchName}
                    onChange={(e) => setSearchName(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && onExecuteSearch()}
                  />
                  <Button variant="primary" onClick={onExecuteSearch}>
                    검색
                  </Button>
                </InputGroup>
              </div>

              <div className="flex-grow-1 overflow-auto p-3 bg-light">
                {/* 4. onItemClick 프롭스로 함수 전달 */}
                <WarehouseList
                  warehouses={warehouses}
                  loading={loading}
                  onItemClick={handleWarehouseClick}
                />
              </div>
            </Col>

            <Col md={7} lg={8} className="h-100">
              <div style={{ width: '100%', height: '100%' }}>
                {/* 5. 지도 마커 클릭 시에도 이동하려면 여기도 전달 가능 */}
                <NaverMapContainer warehouses={warehouses} onMarkerClick={handleWarehouseClick} />
              </div>
            </Col>
          </Row>
        </Container>
      </main>
      <Footer />
    </div>
  );
};

export default WarehouseSearchPage;
