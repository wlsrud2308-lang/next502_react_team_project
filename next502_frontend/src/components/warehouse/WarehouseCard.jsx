import { Card, Badge, ProgressBar } from 'react-bootstrap';

const WarehouseCard = () => {
  return (
    <Card className="mb-3 border-0 shadow-sm">
      <Card.Body>
        <div className="d-flex justify-content-between align-items-start">
          <Badge bg="primary" className="mb-2">
            L Grade
          </Badge>
          <span className="text-muted small">경기 이천시</span>
        </div>
        <Card.Title className="h6 fw-bold">이천 신선 물류 센터</Card.Title>
        <div className="mt-3">
          <div className="d-flex justify-content-between x-small mb-1">
            <span>사용률</span>
            <span className="fw-bold">85%</span>
          </div>
          <ProgressBar variant="warning" now={85} style={{ height: '6px' }} />
        </div>
      </Card.Body>
    </Card>
  );
};

export default WarehouseCard;
