import React, { useState } from 'react';
import { Form, Row, Col, Button } from 'react-bootstrap';

const FilterBar = ({ onSearch }) => {
  // 1. 사용자의 입력값을 저장할 상태(State)
  const [name, setName] = useState('');
  const [location, setLocation] = useState('');
  const [size, setSize] = useState(''); // 보관 형태(사이즈)

  // 2. 검색 버튼 클릭 시 실행
  const handleSearchClick = (e) => {
    e.preventDefault(); // 페이지 새로고침 방지
    // 부모(WarehouseSearchPage)가 준 handleSearch 함수에 값 전달
    onSearch(location, size, name);
  };

  return (
    <Form onSubmit={handleSearchClick}>
      <Form.Group className="mb-2">
        <Form.Control
          type="text"
          placeholder="창고명 검색"
          size="sm"
          value={name}
          onChange={(e) => setName(e.target.value)} // 입력할 때마다 상태 업데이트
        />
      </Form.Group>
      <Row className="g-2 mb-2">
        <Col>
          <Form.Select size="sm" value={location} onChange={(e) => setLocation(e.target.value)}>
            <option value="">전체 지역</option>
            <option value="서울">서울</option>
            <option value="부산">부산</option>
            <option value="인천">인천</option>
          </Form.Select>
        </Col>
        <Col>
          <Form.Select size="sm" value={size} onChange={(e) => setSize(e.target.value)}>
            <option value="">보관 형태</option>
            <option value="S">소형</option>
            <option value="M">중형</option>
            <option value="L">대형</option>
          </Form.Select>
        </Col>
      </Row>
      <Button type="submit" variant="primary" size="sm" className="w-100">
        검색하기
      </Button>
    </Form>
  );
};

export default FilterBar;
