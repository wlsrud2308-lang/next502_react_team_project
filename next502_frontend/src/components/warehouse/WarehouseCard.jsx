import { Card, Badge, ProgressBar } from 'react-bootstrap';

const WarehouseCard = ({ warehouse, onItemClick }) => {
  if (!warehouse) return null;

  const usageRate = warehouse.usageRate || 85;

  return (
    <Card
      className="mb-3 border-0 shadow-sm"
      style={{ cursor: 'pointer' }}
      // 클릭 시 부모의 navigate 로직 실행
      onClick={() => onItemClick(warehouse.warehouseId)}
    >
      <Card.Body>
        <div className="d-flex justify-content-between align-items-start">
          <Badge bg="primary" className="mb-2">
            {warehouse.sizeRank || 'Grade'}
          </Badge>
          <span className="text-muted small">{warehouse.address}</span>
        </div>

        <Card.Title className="h6 fw-bold">{warehouse.name}</Card.Title>

        <div className="mt-3">
          <div className="d-flex justify-content-between x-small mb-1">
            <span>사용률</span>
            <span className="fw-bold">{usageRate}%</span>
          </div>
          <ProgressBar variant="warning" now={usageRate} style={{ height: '6px' }} />
        </div>

        <div className="mt-2 x-small text-secondary">
          면적: {warehouse.totalArea}㎡ | {warehouse.storageType}
        </div>
      </Card.Body>
    </Card>
  );
};

export default WarehouseCard;
