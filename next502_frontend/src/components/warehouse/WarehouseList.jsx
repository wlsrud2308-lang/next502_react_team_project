import React from 'react';
import WarehouseCard from './WarehouseCard';

const WarehouseList = ({ warehouses = [] }) => {
  return (
    <div className="warehouse-list">
      <div className="mb-2 small text-muted">검색 결과 {warehouses.length}건</div>

      {warehouses.length > 0 ? (
        warehouses.map((item) => (
          // key값은 DTO의 warehouseId를 사용하고, 데이터 객체를 넘깁니다.
          <WarehouseCard key={item.warehouseId} warehouse={item} />
        ))
      ) : (
        <div className="text-center py-5 text-muted">데이터가 존재하지 않습니다.</div>
      )}
    </div>
  );
};

export default WarehouseList;
