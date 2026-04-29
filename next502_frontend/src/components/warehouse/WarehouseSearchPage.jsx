import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col, Form, InputGroup, Button } from 'react-bootstrap';
import WarehouseList from './WarehouseList';
import NaverMapContainer from './NaverMapContainer';
import { fetchWarehouses } from '../../service/ApiService';
import Header from '../layout/Header.jsx';
import Footer from '../layout/Footer.jsx';

const WarehouseSearchPage = () => {
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchName, setSearchName] = useState(''); // 창고명 검색어 상태

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

  useEffect(() => {
    handleSearch();
  }, [handleSearch]);

  // 검색 실행 함수
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
            {/* 왼쪽 섹션 */}
            <Col md={5} lg={4} className="d-flex flex-column bg-white border-end h-100">
              {/* === 여기가 수정된 포인트: FilterBar 대신 직접 구현 === */}
              <div className="p-3 border-bottom bg-white">
                <InputGroup>
                  <Form.Control
                    size="lg" // 크기를 크게 키움
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
              {/* ==================================================== */}

              <div className="flex-grow-1 overflow-auto p-3 bg-light">
                <WarehouseList warehouses={warehouses} loading={loading} />
              </div>
            </Col>

            {/* 오른쪽: 지도 영역 (고정) */}
            <Col md={7} lg={8} className="h-100">
              <div style={{ width: '100%', height: '100%' }}>
                <NaverMapContainer warehouses={warehouses} />
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
