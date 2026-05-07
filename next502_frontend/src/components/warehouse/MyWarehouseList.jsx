import React, { useEffect, useState } from 'react';
import { getMyWarehouseList, deleteWarehouse } from '../../service/ApiService'; // ★ deleteWarehouse 추가
import { useNavigate } from 'react-router-dom';
import { MapPin, Maximize, Edit2, Trash2, Plus, PackageOpen, Activity } from 'lucide-react';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function MyWarehouseList() {
  const [myWarehouses, setMyWarehouses] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  const fetchMyWarehouses = async () => {
    try {
      const data = await getMyWarehouseList();
      setMyWarehouses(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchMyWarehouses();
  }, []);

  // ★ 삭제 처리 함수
  const handleDelete = async (e, id, name) => {
    e.stopPropagation(); // 카드 클릭 이벤트 방지
    if (
      window.confirm(`[${name}] 창고를 정말 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.`)
    ) {
      try {
        await deleteWarehouse(id);
        alert('삭제되었습니다.');
        fetchMyWarehouses();
      } catch (err) {
        alert('삭제 실패: ' + err);
      }
    }
  };

  if (isLoading) return <div className="text-center py-5 mt-5">목록을 불러오는 중...</div>;

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <Header />

      <div className="container" style={{ paddingTop: '120px', paddingBottom: '100px' }}>
        <div className="d-flex flex-column flex-md-row justify-content-between align-items-md-end mb-5 gap-3">
          <div>
            <h2 className="fw-bold mb-2 d-flex align-items-center text-dark">
              <PackageOpen className="me-3 text-primary" size={32} />내 창고 관리
            </h2>
            <p className="text-secondary mb-0 fs-5">
              등록하신 창고의 현황을 한눈에 확인하고 관리하세요.
            </p>
          </div>
          <button
            className="btn btn-primary rounded-pill px-4 py-3 fw-bold shadow-sm d-flex align-items-center"
            onClick={() => navigate('/whInput')}
          >
            <Plus size={20} className="me-2" />새 창고 등록하기
          </button>
        </div>

        {myWarehouses.length === 0 ? (
          <div className="card border-0 shadow-sm rounded-4 text-center py-5 bg-white">
            <div className="py-5 text-muted">
              <PackageOpen size={64} className="opacity-50 mb-3" />
              <h4>등록된 창고가 없습니다.</h4>
            </div>
          </div>
        ) : (
          <div className="row g-4">
            {myWarehouses.map((item) => (
              <div className="col-md-6 col-lg-4" key={item.warehouseId}>
                <div
                  className="card border-0 shadow-sm rounded-4 h-100 overflow-hidden bg-white position-relative"
                  style={{ cursor: 'pointer', transition: 'all 0.2s ease-in-out' }}
                  onClick={() => navigate(`/warehouse/${item.warehouseId}`)}
                  onMouseEnter={(e) => (e.currentTarget.style.transform = 'translateY(-8px)')}
                  onMouseLeave={(e) => (e.currentTarget.style.transform = 'translateY(0)')}
                >
                  {/* 사진 영역 */}
                  <div className="position-relative" style={{ height: '200px' }}>
                    <img
                      src={
                        item.repImageUrl
                          ? `http://localhost:8080${item.repImageUrl}`
                          : 'https://via.placeholder.com/400x200'
                      }
                      className="w-100 h-100"
                      style={{ objectFit: 'cover' }}
                      alt={item.name}
                    />
                    <div className="position-absolute top-0 start-0 p-3">
                      <span className="badge bg-dark bg-opacity-75 text-white px-3 py-2 rounded-pill border border-secondary border-opacity-25 fw-medium">
                        규모 {item.sizeRank}
                      </span>
                    </div>
                  </div>


                  <div className="card-body p-4 d-flex flex-column">
                    <div className="d-flex justify-content-between align-items-start mb-2">
                      <div style={{ maxWidth: '70%' }}>
                        <h4 className="fw-bold text-dark mb-1 text-truncate">{item.name}</h4>
                        <p className="text-secondary mb-0 text-truncate small d-flex align-items-center">
                          <MapPin size={14} className="me-1 text-danger" />
                          {item.address}
                        </p>
                      </div>


                      <div className="text-end">
                        <div className="small fw-bold text-primary mb-1">
                          <Activity size={14} className="me-1" />
                          {item.usageRate || 0}%
                        </div>
                        <div
                          className="progress"
                          style={{ height: '6px', width: '60px', backgroundColor: '#e9ecef' }}
                        >
                          <div
                            className="progress-bar"
                            style={{
                              width: `${item.usageRate || 0}%`,
                              backgroundColor: item.usageRate > 80 ? '#dc3545' : '#0d6efd',
                            }}
                          />
                        </div>
                      </div>
                    </div>

                    <div className="d-flex align-items-center text-dark mt-3 bg-light p-2 px-3 rounded-3 small">
                      <Maximize size={16} className="me-2 text-primary" />
                      <span className="fw-semibold me-auto">총 면적</span>
                      <span className="fw-bold">{item.totalArea} ㎡</span>
                    </div>
                  </div>

                  {/* 액션 버튼 영역 */}
                  <div className="card-footer bg-white border-top-0 p-4 pt-0 d-flex gap-2">
                    <button
                      className="btn flex-grow-1 fw-bold border-primary text-primary bg-primary bg-opacity-10 rounded-3 py-2"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/warehouse/edit/${item.warehouseId}`);
                      }}
                    >
                      <Edit2 size={16} className="me-2 mb-1" /> 수정
                    </button>
                    <button
                      className="btn flex-grow-1 fw-bold border-danger text-danger bg-danger bg-opacity-10 rounded-3 py-2"
                      onClick={(e) => handleDelete(e, item.warehouseId, item.name)} // ★ 삭제 호출
                    >
                      <Trash2 size={16} className="me-2 mb-1" /> 삭제
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <Footer />
    </div>
  );
}

export default MyWarehouseList;
