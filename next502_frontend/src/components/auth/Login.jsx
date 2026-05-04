import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { apiLogin, loginWithKakao } from '../../service/ApiService';

function Login() {
  const [userId, setUserId] = useState('');
  const [userPw, setUserPw] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();
  const { loginSuccess } = useAuth();

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      const data = await apiLogin(userId, userPw);

      // ⭐ 백엔드 응답 키: id, accessToken, refreshToken, role
      localStorage.setItem('ACCESS_TOKEN', data.accessToken);
      if (data.refreshToken) localStorage.setItem('REFRESH_TOKEN', data.refreshToken);
      loginSuccess(data.accessToken, data.role, data.id);

      navigate('/');
    } catch (err) {
      alert(err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="vh-100 d-flex align-items-center justify-content-center bg-light">
      <div
        className="container shadow-lg rounded-4 overflow-hidden bg-white"
        style={{ maxWidth: '900px', minHeight: '550px' }}
      >
        <div className="row g-0 h-100">
          <div
            className="col-lg-6 d-none d-lg-flex flex-column justify-content-center align-items-center text-white p-5"
            style={{ background: 'linear-gradient(135deg, #4e73df 0%, #224abe 100%)' }}
          >
            <h2 className="fw-bold mb-3">창고이음</h2>
            <p className="text-center opacity-75">
              부산광역시의 모든 창고 정보를 <br />
              한눈에 확인하고 스마트하게 예약하세요.
            </p>
            <div className="mt-4 fs-1">📦</div>
          </div>

          <div className="col-lg-6 p-5 d-flex flex-column justify-content-center">
            <div className="mb-4">
              <h3 className="fw-bold text-dark">로그인</h3>
              <p className="text-muted small">서비스를 이용하시려면 로그인이 필요합니다.</p>
            </div>

            <form onSubmit={handleLogin}>
              <div className="mb-3">
                <label className="form-label small fw-bold">아이디</label>
                <div className="input-group bg-light rounded-3 px-2">
                  <span className="input-group-text bg-transparent border-0 text-secondary">
                    👤
                  </span>
                  <input
                    type="text"
                    className="form-control bg-transparent border-0 py-2"
                    placeholder="아이디를 입력하세요"
                    value={userId}
                    onChange={(e) => setUserId(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className="mb-4">
                <label className="form-label small fw-bold">비밀번호</label>
                <div className="input-group bg-light rounded-3 px-2">
                  <span className="input-group-text bg-transparent border-0 text-secondary">
                    🔒
                  </span>
                  <input
                    type="password"
                    className="form-control bg-transparent border-0 py-2"
                    placeholder="비밀번호를 입력하세요"
                    value={userPw}
                    onChange={(e) => setUserPw(e.target.value)}
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="btn btn-primary w-100 py-3 fw-bold rounded-3 shadow-sm border-0 mb-3"
                style={{ background: '#4e73df' }}
              >
                {isLoading ? '로그인 중...' : '로그인'}
              </button>
            </form>

            <div className="text-center mb-4 text-muted small">또는</div>

            <button
              className="btn btn-warning w-100 py-2 fw-bold rounded-3 border-0 d-flex align-items-center justify-content-center mb-4"
              style={{ backgroundColor: '#FEE500', color: '#3c1e1e' }}
            >
              <span className="me-2">💬</span> 카카오 로그인
            </button>

            <p className="text-center small text-secondary mt-2">
              아직 계정이 없으신가요?{' '}
              <Link to="/signup" className="text-primary fw-bold text-decoration-none">
                회원가입
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Login;
