import { Card, Badge, ProgressBar } from 'react-bootstrap';

// props로 부모(WarehouseList)가 전달해준 warehouse 데이터를 받습니다.
const WarehouseCard = ({ warehouse }) => {
  if (!warehouse) return null;

  // 임시로 사용률(ProgressBar) 데이터가 DB에 없다면 랜덤하게 보이게 하거나
  // 특정 수치를 부여할 수 있습니다. (여기선 85% 고정 유지)
  const usageRate = 85;

  return (
    <Card className="mb-3 border-0 shadow-sm" style={{ cursor: 'pointer' }}>
      <Card.Body>
        <div className="d-flex justify-content-between align-items-start">
          {/* DTO: sizeRank (L Grade 등) */}
          <Badge bg="primary" className="mb-2">
            {warehouse.sizeRank || 'Grade'}
          </Badge>
          {/* DTO: address (경기 이천시 등) */}
          <span className="text-muted small">{warehouse.address}</span>
        </div>

        {/* DTO: name (이천 신선 물류 센터) */}
        <Card.Title className="h6 fw-bold">{warehouse.name}</Card.Title>

        <div className="mt-3">
          <div className="d-flex justify-content-between x-small mb-1">
            <span>사용률</span>
            <span className="fw-bold">{usageRate}%</span>
          </div>
          <ProgressBar variant="warning" now={usageRate} style={{ height: '6px' }} />
        </div>

        {/* 추가 정보가 필요하다면 아래처럼 넣을 수 있습니다. */}
        <div className="mt-2 x-small text-secondary">
          면적: {warehouse.totalArea}㎡ | {warehouse.storageType}
        </div>
      </Card.Body>
    </Card>
  );
};

export default WarehouseCard;
