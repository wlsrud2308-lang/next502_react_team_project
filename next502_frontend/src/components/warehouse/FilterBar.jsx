import { Form, Row, Col } from 'react-bootstrap';

const FilterBar = () => {
  return (
    <Form>
      <Form.Group className="mb-2">
        <Form.Control type="text" placeholder="창고명 또는 지역 검색" size="sm" />
      </Form.Group>
      <Row className="g-2">
        <Col>
          <Form.Select size="sm">
            <option>전체 지역</option>
          </Form.Select>
        </Col>
        <Col>
          <Form.Select size="sm">
            <option>보관 형태</option>
          </Form.Select>
        </Col>
      </Row>
    </Form>
  );
};

export default FilterBar;
