import { Card, Badge, ProgressBar } from 'react-bootstrap';

// 백엔드 서버 주소
const API_BASE_URL = 'http://localhost:8080';

const WarehouseCard = ({ warehouse, onItemClick }) => {
  if (!warehouse) return null;

  const usageRate = warehouse.usageRate || 85;

  // 이미지 URL 변환 (백슬래시 대응 추가)
  const getImageUrl = (url) => {
    if (!url) return 'https://via.placeholder.com/400x200?text=No+Image';
    if (url.startsWith('http')) return url;

    // 윈도우 경로(\)가 저장되었을 경우 슬래시(/)로 치환
    const formattedUrl = url.replace(/\\/g, '/');
    return `${API_BASE_URL}${formattedUrl.startsWith('/') ? '' : '/'}${formattedUrl}`;
  };

  return (
    <Card
      className="mb-3 border-0 shadow-sm overflow-hidden"
      style={{ cursor: 'pointer' }}
      onClick={() => onItemClick(warehouse.warehouseId)}
    >
      <Card.Img
        variant="top"
        src={getImageUrl(warehouse.repImageUrl)}
        style={{ height: '200px', objectFit: 'cover' }}
        alt={warehouse.name}
        // URL이 틀렸거나 서버에서 이미지를 못 찾을 때 기본 이미지 노출
        onError={(e) => {
          e.target.src = 'https://via.placeholder.com/400x200?text=Image+Load+Error';
        }}
      />
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
