import React, { useEffect, useState } from 'react';
import { getMyWarehouseList } from '../../service/ApiService';
import { useNavigate } from 'react-router-dom';

function MyWarehouseList() {
  const [myWarehouses, setMyWarehouses] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchMyWarehouses = async () => {
      try {
        const data = await getMyWarehouseList();
        setMyWarehouses(data);
      } catch (err) {
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchMyWarehouses();
  }, []);

  if (isLoading) return <div className="text-center py-5">로딩 중...</div>;

  return (
    <div className="container py-5">
      <div className="d-flex justify-content-between align-items-end mb-5">
        <div>
          <h2 className="fw-bold mb-1">📦 내 창고 관리</h2>
          <p className="text-secondary mb-0">등록하신 창고의 현황을 확인하고 관리할 수 있습니다.</p>
        </div>
        <button
          className="btn btn-primary rounded-pill px-4 py-2 fw-bold"
          onClick={() => navigate('/whInput')}
        >
          + 새 창고 등록하기
        </button>
      </div>

      <div className="card border-0 shadow-sm rounded-4 overflow-hidden">
        <div className="table-responsive">
          <table className="table table-hover align-middle mb-0">
            <thead className="table-light">
              <tr>
                <th className="px-4 py-3" style={{ width: '120px' }}>
                  창고
                </th>
                <th className="py-3">이름 / 주소</th>
                <th className="py-3">규모</th>
                <th className="py-3">총 면적</th>
                <th className="py-3 text-center">동작</th>
              </tr>
            </thead>
            <tbody>
              {myWarehouses.length === 0 ? (
                <tr>
                  <td colSpan="5" className="text-center py-5 text-secondary">
                    등록된 창고가 없습니다.
                  </td>
                </tr>
              ) : (
                myWarehouses.map((item) => (
                  <tr
                    key={item.warehouseId}
                    style={{ cursor: 'pointer' }}
                    onClick={() => navigate(`/warehouse/${item.warehouseId}`)}
                  >
                    <td className="px-4 py-3">
                      <div
                        className="rounded-3 overflow-hidden"
                        style={{ width: '80px', height: '60px' }}
                      >
                        <img
                          src={`http://localhost:8080${item.repImageUrl}`}
                          className="w-100 h-100"
                          style={{ objectFit: 'cover' }}
                          alt={item.name}
                        />
                      </div>
                    </td>
                    <td className="py-3">
                      <div className="fw-bold text-dark">{item.name}</div>
                      <div className="text-secondary small">{item.address}</div>
                    </td>
                    <td className="py-3">
                      <span className="badge bg-info-subtle text-info border border-info-subtle px-3">
                        {item.sizeRank}
                      </span>
                    </td>
                    <td className="py-3 fw-medium">{item.totalArea} ㎡</td>
                    <td className="py-3 text-center">
                      <button
                        className="btn btn-light btn-sm rounded-pill px-3 me-2"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate(`/api/member/me/edit-warehouse/${item.warehouseId}`);
                        }}
                      >
                        수정
                      </button>
                      <button
                        className="btn btn-outline-danger btn-sm rounded-circle"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <small>X</small>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default MyWarehouseList;
