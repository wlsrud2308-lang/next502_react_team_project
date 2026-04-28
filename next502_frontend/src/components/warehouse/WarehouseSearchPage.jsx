import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col } from 'react-bootstrap';
import FilterBar from './FilterBar';
import WarehouseList from './WarehouseList';
import NaverMapContainer from './NaverMapContainer';
// API 경로 확인: src/service/ApiService.js 위치 기준
import { fetchWarehouses } from '../../service/ApiService';

const WarehouseSearchPage = () => {
  const [warehouses, setWarehouses] = useState([]); // 검색된 창고 데이터 상태
  const [loading, setLoading] = useState(false); // 로딩 상태 관리

  // 검색 로직: FilterBar에서 호출할 함수
  const handleSearch = useCallback(async (location = '', size = '', name = '') => {
    setLoading(true);
    try {
      // 1. ApiService.js가 4번째 인자로 토큰을 받으므로, 로컬 스토리지에서 꺼내줍니다.
      const token = localStorage.getItem('ACCESS_TOKEN');

      // 2. 인자 순서 준수: (location, size, name, token)
      const data = await fetchWarehouses(location, size, name, token);

      console.log('✅ 검색 성공 - 받은 데이터:', data);
      setWarehouses(data); // 검색된 결과로 상태 업데이트 -> 지도로 전달됨
    } catch (error) {
      console.error('❌ 데이터 로딩 실패:', error);
      // 만약 403 에러가 지속된다면 로그인이 풀린 것일 수 있으니 체크 필요
    } finally {
      setLoading(false);
    }
  }, []);

  // 페이지 초기 로드 시 전체 리스트 조회 (빈 값으로 호출)
  useEffect(() => {
    handleSearch();
  }, [handleSearch]);

  return (
    <Container fluid className="warehouse-search-page p-0" style={{ height: 'calc(100vh - 56px)' }}>
      <Row className="g-0 h-100">
        {/* 왼쪽 섹션: 필터 및 리스트 */}
        <Col md={5} lg={4} xl={3} className="d-flex flex-column bg-white border-end h-100">
          <div className="p-3 border-bottom shadow-sm">
            {/* FilterBar 컴포넌트 내부에서 onSearch(loc, sz, nm)를 호출해야 함 */}
            <FilterBar onSearch={(loc, sz, nm) => handleSearch(loc, sz, nm)} />
          </div>
          <div className="flex-grow-1 overflow-auto p-3 bg-light">
            <WarehouseList warehouses={warehouses} loading={loading} />
          </div>
        </Col>

        {/* 오른쪽 섹션: 네이버 맵 */}
        <Col md={7} lg={8} xl={9} className="h-100">
          {/* 핵심: warehouses 상태가 업데이트되면
              NaverMapContainer의 useEffect가 실행되어 마커를 다시 그려야 함
          */}
          <NaverMapContainer warehouses={warehouses} />
        </Col>
      </Row>
    </Container>
  );
};

export default WarehouseSearchPage;
