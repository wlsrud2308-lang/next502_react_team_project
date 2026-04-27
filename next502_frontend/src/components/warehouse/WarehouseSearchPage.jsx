import React from 'react';
import { Container, Row, Col } from 'react-bootstrap';
import FilterBar from './FilterBar';
import WarehouseList from './WarehouseList';
import NaverMapContainer from './NaverMapContainer';

const WarehouseSearchPage = () => {
  return (
    // d-flex flex-column: 헤더 아래 영역을 꽉 채우기 위함
    // vh-100에서 헤더 높이만큼 빼는 스타일은 App.css나 inline으로 조절 필요
    <Container fluid className="warehouse-search-page p-0" style={{ height: 'calc(100vh - 56px)' }}>
      <Row className="g-0 h-100">
        {/* 왼쪽: 필터 및 리스트 영역 (4/12 칸 차지) */}
        <Col md={5} lg={4} xl={3} className="d-flex flex-column bg-white border-end h-100">
          <div className="p-3 border-bottom shadow-sm">
            <FilterBar />
          </div>
          <div className="flex-grow-1 overflow-auto p-3 bg-light">
            <WarehouseList />
          </div>
        </Col>

        {/* 오른쪽: 지도 영역 (8/12 칸 차지) */}
        <Col md={7} lg={8} xl={9} className="h-100">
          <NaverMapContainer />
        </Col>
      </Row>
    </Container>
  );
};

export default WarehouseSearchPage;
