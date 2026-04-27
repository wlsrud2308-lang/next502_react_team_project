import WarehouseCard from './WarehouseCard';

const WarehouseList = () => {
  // 나중에 API 데이터로 대체될 가짜 데이터(Mock Data)
  const dummyData = [1, 2, 3, 4, 5];

  return (
    <div className="warehouse-list">
      <div className="mb-2 small text-muted">검색 결과 {dummyData.length}건</div>
      {dummyData.map((item) => (
        <WarehouseCard key={item} />
      ))}
    </div>
  );
};

export default WarehouseList;
