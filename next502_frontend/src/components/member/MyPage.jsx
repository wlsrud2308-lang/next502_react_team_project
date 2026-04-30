import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { getMyInfo } from '../../service/ApiService';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function MyPage() {
  const navigate = useNavigate();
  const { logout } = useAuth();
  const [memberInfo, setMemberInfo] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchInfo = async () => {
      try {
        const data = await getMyInfo();
        setMemberInfo(data);
      } catch (err) {
        console.error('데이터 로드 실패:', err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchInfo();
  }, []);

  const handleLogout = () => {
    if (window.confirm('정말 로그아웃 하시겠습니까?')) {
      logout();
      navigate('/');
    }
  };

  if (isLoading) return <div className="text-center py-5">로딩 중...</div>;

  return (
    <div className="wrapper bg-light">
      <Header />
      <main style={{ paddingTop: '150px', paddingBottom: '100px' }}>
        <div className="container">
          <div className="row justify-content-center">
            {/* 왼쪽 사이드 프로필 카드 */}
            <div className="col-lg-4 mb-4">
              <div className="card border-0 shadow-sm rounded-4 text-center p-4">
                <div className="d-flex justify-content-center mb-3">
                  <div
                    className="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center"
                    style={{ width: '100px', height: '100px' }}
                  >
                    <span style={{ fontSize: '3rem' }}>👤</span>
                  </div>
                </div>
                <h4 className="fw-bold mb-1">{memberInfo?.name || '사용자'}님</h4>
                <p className="text-secondary small mb-3">
                  {memberInfo?.userEmail || '이메일 정보 없음'}
                </p>
                {memberInfo?.role === 'ROLE_PROVIDER' && memberInfo?.businessName && (
                  <div className="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2 rounded-pill mb-3">
                    🏢 {memberInfo.businessName}
                  </div>
                )}

                <button
                  className="btn btn-outline-secondary btn-sm w-100 rounded-pill mt-2"
                  onClick={() => navigate('/api/member/me/edit', { state: { memberInfo } })} // 데이터 함께 전달
                >
                  회원 정보 수정
                </button>
              </div>
            </div>

            {/* 오른쪽 메뉴 영역 */}
            <div className="col-lg-6">
              {/* 나의 활동 카드 */}
              <div className="card border-0 shadow-sm rounded-4 mb-4 overflow-hidden">
                <div className="card-header bg-white border-0 pt-4 px-4">
                  <h5 className="fw-bold mb-0">나의 활동</h5>
                </div>
                <div className="card-body p-0">
                  <div className="list-group list-group-flush">
                    <button
                      className="list-group-item list-group-item-action d-flex align-items-center justify-content-between py-3 px-4 border-0"
                      onClick={() => navigate('/favorites')}
                    >
                      <div className="d-flex align-items-center">
                        <span className="me-3 fs-5">⭐</span>
                        <span>관심 창고 목록</span>
                      </div>
                      <span className="text-secondary small">❯</span>
                    </button>
                    <button
                      className="list-group-item list-group-item-action d-flex align-items-center justify-content-between py-3 px-4 border-0"
                      onClick={() => alert('준비 중입니다.')}
                    >
                      <div className="d-flex align-items-center">
                        <span className="me-3 fs-5">💬</span>
                        <span>채팅 문의 내역</span>
                      </div>
                      <span className="text-secondary small">❯</span>
                    </button>
                  </div>
                </div>
              </div>

              {/* 설정 카드 */}
              <div className="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div className="card-header bg-white border-0 pt-4 px-4">
                  <h5 className="fw-bold mb-0">설정</h5>
                </div>
                <div className="card-body p-0">
                  <div className="list-group list-group-flush">
                    <button
                      className="list-group-item list-group-item-action d-flex align-items-center justify-content-between py-3 px-4 border-0"
                      onClick={() => alert('준비 중입니다.')}
                    >
                      <div className="d-flex align-items-center">
                        <span className="me-3 fs-5">🔔</span>
                        <span>알림 설정</span>
                      </div>
                      <span className="text-secondary small">❯</span>
                    </button>
                    <button
                      className="list-group-item list-group-item-action d-flex align-items-center justify-content-between py-3 px-4 border-0"
                      onClick={() => navigate('/faq')}
                    >
                      <div className="d-flex align-items-center">
                        <span className="me-3 fs-5">❓</span>
                        <span>고객센터</span>
                      </div>
                      <span className="text-secondary small">❯</span>
                    </button>
                    <button
                      className="list-group-item list-group-item-action d-flex align-items-center justify-content-between py-3 px-4 border-0 text-danger"
                      onClick={handleLogout}
                    >
                      <div className="d-flex align-items-center">
                        <span className="me-3 fs-5">🚪</span>
                        <span className="fw-bold">로그아웃</span>
                      </div>
                      <span className="text-danger small">❯</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
}

export default MyPage;
