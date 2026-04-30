import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { apiLogin, loginWithKakao } from '../../service/ApiService';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function Login() {
  const navigate = useNavigate();
  const { loginSuccess } = useAuth();

  const [userId, setUserId] = useState('');
  const [userPw, setUserPw] = useState('');
  const [isAutoLogin, setIsAutoLogin] = useState(false);

  // 일반 로그인
  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    if (!userId || !userPw) {
      alert('아이디와 비밀번호를 모두 입력해주세요.');
      return;
    }

    try {
      const data = await apiLogin(userId, userPw);
      loginSuccess(data.accessToken, data.role, data.id);
      alert('로그인에 성공했습니다!');
      navigate('/');
    } catch (err) {
      console.error(err);
      alert('아이디 또는 비밀번호가 일치하지 않습니다');
    }
  };

  // 카카오 로그인
  const handleKakaoLogin = () => {
    alert('웹 카카오 로그인은 Redirect URI 설정 후 연동됩니다.');
  };

  return (
    <div className="wrapper">
      <Header />
      <main
        className="bg-light"
        style={{ minHeight: '100vh', paddingTop: '150px', paddingBottom: '100px' }}
      >
        <div className="container">
          <div className="row justify-content-center">
            <div className="col-md-6 col-lg-5">
              <div className="text-center mb-5">
                <h3 className="fw-bold text-dark">로그인</h3>
                <p className="text-secondary">로그인이 필요합니다.</p>
              </div>

              <div className="card border-0 shadow-lg rounded-4 overflow-hidden">
                <div className="card-body p-5">
                  <form onSubmit={handleLoginSubmit}>
                    <div className="mb-4">
                      <label className="form-label small fw-bold text-secondary">아이디</label>
                      <div className="input-group border rounded-3 p-1 bg-white">
                        <input
                          type="text"
                          className="form-control border-0 shadow-none"
                          value={userId}
                          onChange={(e) => setUserId(e.target.value)}
                        />
                      </div>
                    </div>

                    <div className="mb-4">
                      <label className="form-label small fw-bold text-secondary">비밀번호</label>
                      <div className="input-group border rounded-3 p-1 bg-white">
                        <input
                          type="password"
                          className="form-control border-0 shadow-none"
                          value={userPw}
                          onChange={(e) => setUserPw(e.target.value)}
                        />
                      </div>
                    </div>

                    <div className="d-flex justify-content-between align-items-center mb-4 small">
                      <div className="form-check">
                        <input
                          className="form-check-input shadow-none"
                          type="checkbox"
                          id="autoLogin"
                          checked={isAutoLogin}
                          onChange={(e) => setIsAutoLogin(e.target.checked)}
                        />
                        <label
                          className="form-check-label text-secondary"
                          htmlFor="autoLogin"
                          style={{ cursor: 'pointer' }}
                        >
                          자동 로그인
                        </label>
                      </div>
                      <div className="auth-links">
                        <Link
                          to="/find-id"
                          className="text-decoration-none text-secondary me-2 hover-primary"
                        >
                          아이디 찾기
                        </Link>
                        <span className="text-muted opacity-50">|</span>
                        <Link
                          to="/find-pw"
                          className="text-decoration-none text-secondary ms-2 hover-primary"
                        >
                          비밀번호 찾기
                        </Link>
                      </div>
                    </div>

                    <button
                      type="submit"
                      className="btn btn-primary w-100 py-3 fw-bold rounded-3 shadow-sm mb-4"
                    >
                      로그인
                    </button>

                    <div className="position-relative text-center mb-4">
                      <hr className="text-muted opacity-25" />
                      <span className="position-absolute top-50 start-50 translate-middle bg-white px-3 text-muted small">
                        SNS 계정으로 간편 로그인
                      </span>
                    </div>

                    <div className="d-grid gap-2 mb-5">
                      <button
                        type="button"
                        onClick={handleKakaoLogin}
                        className="btn py-2 rounded-3 fw-bold border-0"
                        style={{ backgroundColor: '#FEE500', color: '#000000' }}
                      >
                        카카오톡으로 시작하기
                      </button>
                    </div>

                    <div className="text-center pt-3 border-top">
                      <p className="text-secondary small mb-0">
                        아직 회원이 아니신가요?
                        <Link
                          to="/signup"
                          className="text-primary fw-bold ms-2 text-decoration-none"
                        >
                          회원가입
                        </Link>
                      </p>
                    </div>
                  </form>
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

export default Login;
