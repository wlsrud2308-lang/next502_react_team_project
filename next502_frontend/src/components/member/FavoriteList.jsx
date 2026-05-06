import React, { useEffect, useState } from 'react';
import { getFavoriteList, toggleFavorite } from '../../service/ApiService';
import { useNavigate } from 'react-router-dom';

function FavoriteList() {
  const [favorites, setFavorites] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    fetchFavorites();
  }, []);

  const fetchFavorites = async () => {
    try {
      const data = await getFavoriteList();
      setFavorites(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleRemove = async (e, whId) => {
    e.stopPropagation();
    if (window.confirm('관심 창고에서 제거하시겠습니까?')) {
      try {
        await toggleFavorite(whId);
        setFavorites(favorites.filter((item) => item.warehouseId !== whId));
      } catch (err) {
        alert('제거 실패');
      }
    }
  };

  if (isLoading) return <div className="text-center py-5">로딩 중...</div>;

  return (
    <div className="container py-5">
      <div className="d-flex align-items-center mb-5">
        <h2 className="fw-bold m-0">❤️ 관심 창고</h2>
        <span className="badge bg-secondary ms-3 rounded-pill">{favorites.length}</span>
      </div>

      {favorites.length === 0 ? (
        <div className="text-center py-5 bg-white rounded-4 shadow-sm">
          <p className="text-secondary mb-0">
            찜한 창고가 없습니다. 마음에 드는 창고를 찾아보세요!
          </p>
        </div>
      ) : (

        <div className="row row-cols-1 row-cols-md-2 row-cols-lg-3 row-cols-xl-4 g-4">
          {favorites.map((item) => (
            <div className="col" key={item.warehouseId}>
              <div
                className="card h-100 border-0 shadow-sm rounded-4 overflow-hidden favorite-card"
                onClick={() => navigate(`/warehouse/${item.warehouseId}`)}
                style={{ transition: 'transform 0.3s, shadow 0.3s', cursor: 'pointer' }}
              >
                {/* 이미지 영역 (비율 고정) */}
                <div
                  className="position-relative"
                  style={{ paddingBottom: '60%', overflow: 'hidden' }}
                >
                  <img
                    src={
                      item.repImageUrl
                        ? `http://localhost:8080${item.repImageUrl}`
                        : 'https://via.placeholder.com/300x200?text=No+Image'
                    }
                    className="position-absolute w-100 h-100"
                    style={{ objectFit: 'cover', top: 0, left: 0 }}
                    alt={item.name}
                  />
                  <button
                    className="btn btn-white position-absolute top-0 end-0 m-2 shadow-sm rounded-circle p-2"
                    onClick={(e) => handleRemove(e, item.warehouseId)}
                    style={{ backgroundColor: 'rgba(255,255,255,0.9)' }}
                  >
                    ❤️
                  </button>
                </div>

                {/* 정보 영역 */}
                <div className="card-body p-4">
                  <div className="mb-2">
                    <span className="badge bg-primary-subtle text-primary me-1">
                      {item.sizeRank}
                    </span>
                    <span className="badge bg-light text-dark border">
                      {item.storageType || '상온'}
                    </span>
                  </div>
                  <h5 className="card-title fw-bold text-truncate mb-1">{item.name}</h5>
                  <p
                    className="card-text text-secondary small mb-3 text-truncate-2"
                    style={{ height: '2.5rem' }}
                  >
                    {item.address}
                  </p>
                  <div className="d-grid">
                    <button className="btn btn-outline-primary btn-sm rounded-pill">
                      상세 보기
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default FavoriteList;
