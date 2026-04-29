import React from 'react';
import WarehouseCard from './WarehouseCard';

const WarehouseList = ({ warehouses = [], loading, onItemClick }) => {
  if (loading) return <div className="text-center py-5">로딩 중...</div>;

  return (
    <div className="warehouse-list">
      <div className="mb-2 small text-muted">검색 결과 {warehouses.length}건</div>

      {warehouses.length > 0 ? (
        warehouses.map((item) => (
          <WarehouseCard
            key={item.warehouseId}
            warehouse={item}
            onItemClick={onItemClick} // 프롭스 전달
          />
        ))
      ) : (
        <div className="text-center py-5 text-muted">데이터가 존재하지 않습니다.</div>
      )}
    </div>
  );
};

export default WarehouseList;
